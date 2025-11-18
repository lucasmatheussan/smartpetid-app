import 'package:flutter/material.dart';
import '../services/pet_identification_service.dart';
import '../services/auth_service.dart';
import 'pet_detail_screen.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final PetIdentificationService _petService = PetIdentificationService();
  List<Map<String, dynamic>> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('DEBUG: Carregando pets do backend...');
      final result = await _petService.getAllPets();
      
      if (result['success']) {
        final pets = List<Map<String, dynamic>>.from(result['data']['pets']);
        print('DEBUG: Recebidos ${pets.length} pets do backend');
        
        // Debug: verificar se há duplicatas
        final petIds = pets.map((pet) => pet['id']).toList();
        final uniqueIds = petIds.toSet();
        if (petIds.length != uniqueIds.length) {
          print('DEBUG: ATENÇÃO - Pets duplicados detectados! Total: ${petIds.length}, Únicos: ${uniqueIds.length}');
          // Mostrar quais IDs estão duplicados
          final duplicateIds = <String>[];
          final seenIds = <String>{};
          for (final id in petIds) {
            if (seenIds.contains(id)) {
              duplicateIds.add(id);
            } else {
              seenIds.add(id);
            }
          }
          print('DEBUG: IDs duplicados: $duplicateIds');
        }
        
        // Debug: listar todos os pets recebidos
        print('DEBUG: Lista completa de pets:');
        for (int i = 0; i < pets.length; i++) {
          final pet = pets[i];
          print('DEBUG: Pet $i - ID: ${pet['id']}, Nome: ${pet['name']}, Espécie: ${pet['species']}');
        }
        
        setState(() {
          _pets = pets;
          _isLoading = false;
        });
        
        print('DEBUG: Estado atualizado com ${_pets.length} pets');
      } else {
        // Verificar se é erro de autenticação
        if (result['message'].contains('Token de autenticação') || 
            result['message'].contains('inválido') ||
            result['message'].contains('expirado')) {
          // Redirecionar para login
          _redirectToLogin();
        } else {
          setState(() {
            _errorMessage = result['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('DEBUG: Erro ao carregar pets: $e');
      setState(() {
          _errorMessage = '${AppLocalizations.of(context)!.errorLoadingPets}: $e';
          _isLoading = false;
        });
    }
  }

  void _redirectToLogin() {
    // Fazer logout para limpar dados inválidos
    AuthService().logout();
    
    // Mostrar mensagem e redirecionar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.sessionExpiredLoginAgain),
        backgroundColor: Colors.orange,
      ),
    );
    
    Navigator.of(context).pushAndRemoveUntil(
       MaterialPageRoute(builder: (context) => LoginScreen()),
       (route) => false,
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.registeredAnimals,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPets,
          ),
        ],
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loadingAnimals,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white,
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
              onPressed: _loadPets,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
              ),
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      );
    }

    if (_pets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noAnimalsRegistered,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.registerFirstAnimalToSeeHere,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        final pet = _pets[index];
        return _buildPetCard(pet);
      },
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    print('DEBUG: Construindo card para pet ${pet['name']} (ID: ${pet['id']})');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('DEBUG: Navegando para detalhes do pet ${pet['name']}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetDetailScreen(petData: pet),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                // Imagem do pet
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: _buildPetImage(pet),
                  ),
                ),
                const SizedBox(width: 16),
                // Informações do pet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name'] ?? AppLocalizations.of(context)!.nameNotProvided,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getSpeciesName(pet['species']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (pet['breed'] != null) ...
                            [
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pet['breed'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]
                        ],
                      ),
                      if (pet['age'] != null) ...
                        [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.cake,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${pet['age']} ${AppLocalizations.of(context)!.years}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ]
                    ],
                  ),
                ),
                // Ícone de seta
                Row(
                  children: [
                    IconButton(
                      tooltip: 'QR Code',
                      icon: const Icon(Icons.qr_code, color: Color(0xFF4CAF50)),
                      onPressed: () {
                        final qrData = 'focinhoid:pet:${pet['id']}';
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'QR do ${pet['name'] ?? 'Pet'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    QrImageView(
                                      data: qrData,
                                      version: QrVersions.auto,
                                      size: 220,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      qrData,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4CAF50),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Fechar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage(Map<String, dynamic> pet) {
    print('DEBUG: Construindo imagem para pet ${pet['name']} (ID: ${pet['id']})');
    
    // Verificar se há imagens disponíveis
    if (pet['images'] != null && pet['images'] is List && (pet['images'] as List).isNotEmpty) {
      final images = pet['images'] as List;
      print('DEBUG: Pet ${pet['name']} tem ${images.length} imagens');
      
      // Tentar encontrar uma imagem válida
      for (var i = 0; i < images.length; i++) {
        var image = images[i];
        if (image['url'] != null && image['url'].toString().isNotEmpty) {
          final imageUrl = image['url'];
          
          print('DEBUG: Tentando carregar imagem $i para ${pet['name']}: $imageUrl');
          
          // Validar se a URL parece válida
          if (_isValidImageUrl(imageUrl)) {
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('DEBUG: Erro ao carregar imagem para ${pet['name']}: $error');
                // Se esta imagem falhar, tentar a próxima ou usar avatar padrão
                return _buildDefaultPetAvatar(pet['species']);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  print('DEBUG: Imagem carregada com sucesso para ${pet['name']}');
                  return child;
                }
                return Container(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                );
              },
            );
          } else {
            print('DEBUG: URL inválida para ${pet['name']}: $imageUrl');
          }
        }
      }
    } else {
      print('DEBUG: Pet ${pet['name']} não tem imagens válidas');
    }
    
    // Fallback para ícone padrão
    print('DEBUG: Usando avatar padrão para ${pet['name']}');
    return _buildDefaultPetAvatar(pet['species']);
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

  Widget _buildDefaultPetAvatar(String? species) {
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
      child: Icon(
        species == 'dog' ? Icons.pets : 
        species == 'cat' ? Icons.pets : Icons.pets,
        color: Colors.white,
        size: 35,
      ),
    );
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
}