import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:ndef_record/ndef_record.dart';
import '../services/pet_identification_service.dart';
import '../services/auth_service.dart';
import 'pet_detail_screen.dart';
import 'login_screen.dart';

class RfidScannerScreen extends StatefulWidget {
  const RfidScannerScreen({super.key});

  @override
  State<RfidScannerScreen> createState() => _RfidScannerScreenState();
}

class _RfidScannerScreenState extends State<RfidScannerScreen> {
  final PetIdentificationService _petService = PetIdentificationService();
  bool _sessionActive = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _ensureAuth();
  }

  Future<void> _ensureAuth() async {
    final auth = AuthService();
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faça login para usar a leitura de RFID.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      });
    }
  }

  Future<void> _startScan() async {
    // Web não suporta NFC
    if (kIsWeb) {
      setState(() {
        _message = 'NFC/RFID não disponível no Web.';
      });
      return;
    }

    // Verificar disponibilidade do NFC no dispositivo
    try {
      final availability = await NfcManager.instance.checkAvailability();
      if (availability != NfcAvailability.enabled) {
        bool enabled = false;
        bool secureSupported = false;
        bool secureEnabled = false;
        try {
          enabled = await NfcManagerAndroid.instance.isEnabled();
          secureSupported = await NfcManagerAndroid.instance.isSecureNfcSupported();
          secureEnabled = await NfcManagerAndroid.instance.isSecureNfcEnabled();
        } catch (_) {}
        setState(() {
          _message = 'NFC indisponível neste dispositivo. Detalhes: enabled=$enabled, secureSupported=$secureSupported, secureEnabled=$secureEnabled';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'NFC indisponível: $e';
      });
    }

    setState(() {
      _sessionActive = true;
      _message = 'Aproxime a tag RFID/NFC...';
    });

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (NfcTag tag) async {
      try {
        final ndef = NdefAndroid.from(tag);
        if (ndef == null) {
          setState(() {
            _message = 'Tag sem NDEF. Use uma tag com NDEF.';
          });
          return;
        }

        final cached = await ndef.getNdefMessage();
        String? petId;

        for (final rec in cached?.records ?? const <NdefRecord>[]) {
          final typeNameFormat = rec.typeNameFormat;
          final typeBytes = rec.type;
          final payload = rec.payload;

          // Texto (TNF Well Known, tipo 'T')
          if (typeNameFormat == TypeNameFormat.wellKnown &&
              _bytesEquals(typeBytes, utf8.encode('T')) &&
              payload.isNotEmpty) {
            final text = _decodeNdefText(payload);
            petId = _parsePetId(text);
          }

          // URI (TNF Well Known, tipo 'U')
          if (typeNameFormat == TypeNameFormat.wellKnown &&
              _bytesEquals(typeBytes, utf8.encode('U')) &&
              payload.isNotEmpty) {
            final uri = _decodeNdefUri(payload);
            if (uri != null) petId = _parsePetId(uri.toString());
          }

          if (petId != null) break;
        }

        if (petId == null) {
          setState(() {
            _message = 'Não foi possível extrair o ID do pet na tag.';
          });
          return;
        }

        await NfcManager.instance.stopSession();
        setState(() {
          _sessionActive = false;
          _message = 'Tag lida com ID: $petId';
        });

        // Buscar detalhes do pet e navegar
        final auth = AuthService();
        if (!auth.isLoggedIn) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }

        final resp = await _petService.getPetDetails(petId);
        if (resp['success'] == true && resp['data'] != null) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PetDetailScreen(petData: resp['data']),
            ),
          );
        } else {
          setState(() {
            _message = resp['message'] ?? 'Falha ao carregar detalhes do pet.';
          });
        }
      } catch (e) {
        setState(() {
          _message = 'Erro ao ler NFC: $e';
        });
        try {
          await NfcManager.instance.stopSession();
        } catch (_) {}
        setState(() {
          _sessionActive = false;
        });
      }
    });
  }

  String? _extractPetId() => null;

  String? _parsePetId(String content) {
    try {
      if (content.startsWith('focinhoid:pet:')) {
        return content.substring('focinhoid:pet:'.length);
      }
      final uri = Uri.tryParse(content);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final idx = uri.pathSegments.indexOf('pets');
        if (idx != -1 && uri.pathSegments.length > idx + 1) {
          return uri.pathSegments[idx + 1];
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Utilitário: comparar bytes
  bool _bytesEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Decodifica NDEF Texto (RTD_TEXT)
  String _decodeNdefText(List<int> payload) {
    final status = payload[0];
    final langCodeLen = status & 0x3F;
    return utf8.decode(payload.sublist(1 + langCodeLen));
  }

  // Decodifica NDEF URI (RTD_URI)
  Uri? _decodeNdefUri(List<int> payload) {
    if (payload.isEmpty) return null;
    final prefixCode = payload[0];
    final rest = utf8.decode(payload.sublist(1));
    final prefix = _uriPrefix(prefixCode);
    final full = '$prefix$rest';
    return Uri.tryParse(full);
  }

  String _uriPrefix(int code) {
    const p = [
      '', 'http://www.', 'https://www.', 'http://', 'https://',
      'tel:', 'mailto:', 'ftp://anonymous:anonymous@', 'ftp://ftp.', 'ftps://',
      'sftp://', 'sms:', 'smsto:', 'mmsto:', 'geo:', 'tel:', 'urn:',
      'news:', 'irc:', 'gopher://', 'nntp://', 'telnet://', 'imap:', 'pop:',
      'sip:', 'sips:', 'tftp:', 'btspp://', 'btl2cap://', 'btgoep://',
      'tcpobex://', 'irdaobex://', 'file://', 'urn:epc:id:', 'urn:epc:tag:',
      'urn:epc:pat:', 'urn:epc:raw:', 'urn:epc:', 'urn:nfc:'
    ];
    if (code >= 0 && code < p.length) return p[code];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler RFID'),
        backgroundColor: const Color(0xFFFF9800),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.nfc, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Aproxime o RFID para reconhecer o animal'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sessionActive ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
                child: Text(_sessionActive ? 'Lendo...' : 'Ler RFID'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
