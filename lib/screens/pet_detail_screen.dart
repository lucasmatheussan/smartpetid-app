import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/pet_identification_service.dart';
import '../services/auth_service.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ndef_record/ndef_record.dart';
import '../l10n/app_localizations.dart';

class PetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> petData;

  const PetDetailScreen({super.key, required this.petData});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final PetIdentificationService _petService = PetIdentificationService();
  Map<String, dynamic> petData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    petData = widget.petData;
    _loadPetDetails();
  }

  Future<void> _loadPetDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final petId = petData['id'].toString();
      final result = await _petService.getPetDetails(petId);
      
      if (result['success']) {
        setState(() {
          petData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? AppLocalizations.of(context)!.errorLoadingPetDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.connectionError}: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          petData['name'] ?? AppLocalizations.of(context)!.animalDetails,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPetDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2E7D32),
                          ),
                          child: Text(AppLocalizations.of(context)!.tryAgain),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPetHeader(),
                        const SizedBox(height: 24),
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildContactCard(),
                        const SizedBox(height: 16),
                        _buildRegistrationCard(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPetHeader() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Carrossel de fotos
            _buildPhotoCarousel(),
            const SizedBox(height: 16),
            // Nome do pet
            Text(
              petData['name'] ?? AppLocalizations.of(context)!.nameNotProvided,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Espécie e raça
            Text(
              '${_getSpeciesName(petData['species'])} • ${petData['breed'] ?? AppLocalizations.of(context)!.breedNotProvided}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCarousel() {
    final images = petData['images'];
    
    if (images != null && images is List && images.isNotEmpty) {
      // Filtrar apenas imagens válidas
      final validImages = images.where((image) {
        if (image['url'] == null || image['url'].toString().isEmpty) return false;
        final imageUrl = image['url'];
        return _isValidImageUrl(imageUrl);
      }).toList();
      
      if (validImages.isEmpty) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildDefaultPetImage(),
          ),
        );
      }
      
      return Container(
        height: 200,
        child: PageView.builder(
          itemCount: validImages.length,
          itemBuilder: (context, index) {
            final image = validImages[index];
            final imageUrl = image['url'];
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultPetImage();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                            ),
                          ),
                        );
                      },
                    ),
                    // Indicador de qualidade da foto
                    if (image['quality_score'] != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getQualityColor(image['quality_score']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getQualityText(image['quality_score']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Indicador de posição
                    if (validImages.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            validImages.length,
                            (dotIndex) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: dotIndex == index ? 8 : 6,
                              height: dotIndex == index ? 8 : 6,
                              decoration: BoxDecoration(
                                color: dotIndex == index 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Fallback para imagem padrão
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildDefaultPetImage(),
      ),
    );
  }

  Widget _buildDefaultPetImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getPetIcon(petData['species']),
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }

  Color _getQualityColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getQualityText(double score) {
    if (score >= 0.8) return AppLocalizations.of(context)!.high;
    if (score >= 0.6) return AppLocalizations.of(context)!.medium;
    return AppLocalizations.of(context)!.low;
  }

  Widget _buildPhotoQualitySection() {
    final images = petData['images'];
    
    if (images == null || images is! List || images.isEmpty) {
      return _buildInfoRow(AppLocalizations.of(context)!.photoQuality, AppLocalizations.of(context)!.noPhotosAvailable);
    }
    
    // Calcular qualidade média das fotos
    double totalQuality = 0;
    int photosWithQuality = 0;
    
    for (var image in images) {
      if (image['quality_score'] != null) {
        totalQuality += image['quality_score'];
        photosWithQuality++;
      }
    }
    
    if (photosWithQuality == 0) {
      return _buildInfoRow(AppLocalizations.of(context)!.photoQuality, AppLocalizations.of(context)!.notEvaluated);
    }
    
    double averageQuality = totalQuality / photosWithQuality;
    String qualityText = _getQualityText(averageQuality);
    Color qualityColor = _getQualityColor(averageQuality);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.photoQuality,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: qualityColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  qualityText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(averageQuality * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: qualityColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.information,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID', petData['id']?.toString() ?? 'N/A'),
            _buildInfoRow(AppLocalizations.of(context)!.species, _getSpeciesName(petData['species'])),
            _buildInfoRow(AppLocalizations.of(context)!.breed, petData['breed'] ?? AppLocalizations.of(context)!.notProvided),
            if (petData['age'] != null)
              _buildInfoRow(AppLocalizations.of(context)!.age, '${petData['age']} ${AppLocalizations.of(context)!.years}'),
            _buildPhotoQualitySection(),
            if (petData['description'] != null && petData['description'].toString().isNotEmpty)
              _buildDescriptionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_phone,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.ownerContact,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(AppLocalizations.of(context)!.contact, petData['owner_contact'] ?? AppLocalizations.of(context)!.notProvided),
            if (petData['owner_id'] != null)
              _buildInfoRow(AppLocalizations.of(context)!.ownerId, petData['owner_id'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.registration,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(AppLocalizations.of(context)!.registrationDate, _formatDate(petData['registration_date'])),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _writeRfid,
                icon: const Icon(Icons.nfc),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                label: const Text('Gravar RFID com dados do animal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          '${AppLocalizations.of(context)!.description}:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            petData['description'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPetIcon(String? species) {
    switch (species?.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  String _getSpeciesName(String? species) {
    switch (species?.toLowerCase()) {
      case 'dog':
        return AppLocalizations.of(context)!.dog;
      case 'cat':
        return AppLocalizations.of(context)!.cat;
      default:
        return AppLocalizations.of(context)!.animal;
    }
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // Verificar se a URL tem um esquema válido e não contém caracteres problemáticos
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             !url.contains(' ') && // URLs não devem ter espaços
             (url.toLowerCase().endsWith('.jpg') || 
              url.toLowerCase().endsWith('.jpeg') || 
              url.toLowerCase().endsWith('.png') || 
              url.toLowerCase().endsWith('.gif') ||
              url.toLowerCase().endsWith('.webp'));
    } catch (e) {
      return false;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return AppLocalizations.of(context)!.notProvided;
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _writeRfid() async {
    if (kIsWeb) {
      _showSnack('NFC/RFID não disponível no Web.');
      return;
    }
    if (!Platform.isAndroid) {
      _showSnack('Gravação de RFID disponível apenas no Android neste build.');
      return;
    }

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
        _showSnack('NFC indisponível neste dispositivo. Detalhes: enabled=$enabled, secureSupported=$secureSupported, secureEnabled=$secureEnabled');
      }
    } catch (e) {
      _showSnack('NFC indisponível: $e');
    }

    final petId = petData['id']?.toString();
    if (petId == null || petId.isEmpty) {
      _showSnack('ID do pet inválido para gravação.');
      return;
    }

    final textContent = 'focinhoid:pet:$petId';
    final base = AuthService.baseUrl;
    final uriStr = '$base/pets/$petId';
    final uri = Uri.parse(uriStr);
    final scheme = uri.scheme.toLowerCase();
    final prefixCode = scheme == 'https' ? 4 : 3; // 4=https://, 3=http://
    final rest = uriStr.replaceFirst(RegExp('^https?://'), '');

    final textPayload = Uint8List.fromList([
      2, // status byte: lang code length (2 -> 'pt')
      ...utf8.encode('pt'),
      ...utf8.encode(textContent),
    ]);
    final uriPayload = Uint8List.fromList([
      prefixCode,
      ...utf8.encode(rest),
    ]);

    final message = NdefMessage(records: [
      NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList(utf8.encode('T')),
        identifier: Uint8List(0),
        payload: textPayload,
      ),
      NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList(utf8.encode('U')),
        identifier: Uint8List(0),
        payload: uriPayload,
      ),
    ]);

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (tag) async {
        try {
          final ndef = NdefAndroid.from(tag);
          if (ndef != null) {
            if (!ndef.isWritable) {
              _showSnack('Tag NDEF encontrada, porém não é gravável.');
              await NfcManager.instance.stopSession();
              return;
            }
            await ndef.writeNdefMessage(message);
            _showSnack('RFID gravado com sucesso.');
            await NfcManager.instance.stopSession();
            return;
          }

          // Tentar formatar se for NDEF formatable
          final formatable = NdefFormatableAndroid.from(tag);
          if (formatable != null) {
            await formatable.format(message);
            _showSnack('Tag formatada e gravada com sucesso.');
            await NfcManager.instance.stopSession();
            return;
          }

          _showSnack('Tag não suporta NDEF.');
          await NfcManager.instance.stopSession();
        } catch (e) {
          _showSnack('Erro ao gravar NFC: $e');
          try {
            await NfcManager.instance.stopSession();
          } catch (_) {}
        }
      },
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF4CAF50)),
    );
  }
}
