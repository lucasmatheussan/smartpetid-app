import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/pet_identification_service.dart';
import '../services/auth_service.dart';
import 'pet_detail_screen.dart';
import 'login_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final PetIdentificationService _petService = PetIdentificationService();
  bool _handled = false;
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
            content: Text('Faça login para usar o leitor de QRCode.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      });
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue ?? '';
    if (value.isEmpty) return;

    setState(() {
      _handled = true;
      _message = 'Lido: $value';
    });

    final petId = _parsePetId(value);
    if (petId == null) {
      setState(() {
        _handled = false;
        _message = 'QR inválido. Use um QR do SmartPet ID.';
      });
      return;
    }

    final result = await _petService.getPetDetails(petId);
    if (mounted) {
      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PetDetailScreen(petData: result['data']),
          ),
        );
      } else {
        setState(() {
          _handled = false;
          _message = result['message'] ?? 'Erro ao buscar detalhes do pet.';
        });
      }
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
    final canUseCamera = kIsWeb || Platform.isAndroid || Platform.isIOS;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler QRCode'),
        backgroundColor: const Color(0xFFFF9800),
      ),
      body: canUseCamera
          ? Stack(
              children: [
                MobileScanner(onDetect: _onDetect),
                if (_message != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _message!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Leitura de QRCode disponível apenas em dispositivos móveis.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}