import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../services/pet_identification_service.dart';
import '../services/auth_service.dart';
import 'pet_detail_screen.dart';
import 'login_screen.dart';

class RfcScannerScreen extends StatefulWidget {
  const RfcScannerScreen({super.key});

  @override
  State<RfcScannerScreen> createState() => _RfcScannerScreenState();
}

class _RfcScannerScreenState extends State<RfcScannerScreen> {
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
            content: Text('Faça login para usar a leitura de RFC.'),
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
    if (_sessionActive) return;
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      setState(() {
        _message = 'RFC disponível apenas em dispositivos móveis.';
      });
      return;
    }

    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _message = 'NFC/RFC não disponível neste dispositivo.';
      });
      return;
    }

    setState(() {
      _sessionActive = true;
      _message = 'Aproxime o RFC do dispositivo...';
    });

    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        final petId = _extractPetId(tag);
        if (petId == null) {
          setState(() {
            _message = 'RFC inválido. Use um RFC do SmartPet ID.';
          });
        } else {
          final result = await _petService.getPetDetails(petId);
          if (!mounted) return;
          if (result['success']) {
            await NfcManager.instance.stopSession();
            setState(() {
              _sessionActive = false;
            });
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PetDetailScreen(petData: result['data']),
              ),
            );
            return;
          } else {
            setState(() {
              _message = result['message'] ?? 'Erro ao buscar detalhes do pet.';
            });
          }
        }
      } catch (e) {
        setState(() {
          _message = 'Erro: ${e.toString()}';
        });
      } finally {
        await NfcManager.instance.stopSession();
        setState(() {
          _sessionActive = false;
        });
      }
    });
  }

  String? _extractPetId(NfcTag tag) {
    try {
      final ndef = Ndef.from(tag);
      if (ndef == null || ndef.cachedMessage == null) return null;
      final records = ndef.cachedMessage!.records;
      for (final r in records) {
        // Try text record: payload contains language code length etc.
        final tnf = r.typeNameFormat;
        if (tnf == NdefTypeNameFormat.nfcWellknown &&
            String.fromCharCodes(r.type) == 'T') {
          final payload = r.payload;
          if (payload.isNotEmpty) {
            final langLen = payload[0] & 0x3F;
            final text = String.fromCharCodes(payload.sublist(1 + langLen));
            final id = _parsePetId(text);
            if (id != null) return id;
          }
        }
        // Try URI record
        if (tnf == NdefTypeNameFormat.nfcWellknown &&
            String.fromCharCodes(r.type) == 'U') {
          final uriText = String.fromCharCodes(r.payload);
          final id = _parsePetId(uriText);
          if (id != null) return id;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler RFC'),
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
              const Text('Aproxime o RFC para reconhecer o animal'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sessionActive ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
                child: Text(_sessionActive ? 'Lendo...' : 'Ler RFC'),
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