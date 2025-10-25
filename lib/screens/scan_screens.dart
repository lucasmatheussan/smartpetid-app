import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/pet_identification_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../main.dart' as main_app;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  CameraController? controller;
  bool isReady = false;
  String? error;
  bool isDetecting = false;
  bool animalDetected = false;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  Timer? _detectionTimer;
  final PetIdentificationService _petService = PetIdentificationService();

  @override
  void initState() {
    super.initState();
    
    // Animação de pulso para o círculo
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Animação de escaneamento
    _scanController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    _initializeCamera();
  }

  void _initializeCamera() async {
    if (!kIsWeb && main_app.cameras.isNotEmpty) {
      controller = CameraController(main_app.cameras[0], ResolutionPreset.medium);
      await controller!.initialize();
      if (mounted) {
        setState(() => isReady = true);
      }
    } else if (kIsWeb) {
      setState(() => isReady = true);
    } else {
      setState(() {
        error = 'Nenhuma câmera encontrada.';
      });
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (!isReady || isDetecting) return;

    setState(() {
      isDetecting = true;
      animalDetected = true;
    });
    _pulseController.repeat(reverse: true);
    _scanController.repeat();

    try {
      String? imagePath;
      
      if (kIsWeb) {
        // Para web, simular captura (seria necessário implementar captura real)
        imagePath = 'web_captured_image';
      } else if (controller != null) {
        // Capturar imagem da câmera
        final image = await controller!.takePicture();
        imagePath = image.path;
      }

      if (imagePath != null) {
        // Aguardar um pouco para mostrar a animação
        await Future.delayed(Duration(seconds: 2));
        
        if (mounted) {
          // Identificar o pet usando o serviço
          final petData = await _petService.identifyPet(imagePath: imagePath);
          
          // Verificar se houve erro de autenticação
          if (petData != null && petData['auth_error'] == true) {
            _redirectToLogin();
            return;
          }
          
          _navigateToResult(imagePath, petData);
        }
      } else {
        _showError('Erro ao capturar imagem');
      }
    } catch (e) {
      _showError('Erro ao identificar pet: ${e.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      isDetecting = false;
      animalDetected = false;
    });
    _pulseController.stop();
    _scanController.stop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToResult(String imagePath, Map<String, dynamic>? petData) {
    _pulseController.stop();
    _scanController.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          imagePath: imagePath,
          petData: petData,
        ),
      ),
    );
  }

  void _redirectToLogin() async {
    // Fazer logout
    await AuthService().logout();
    
    // Mostrar mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sessão expirada. Faça login novamente.'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Navegar para login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _detectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF9800), Color(0xFF424242)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.white),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error!,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!isReady) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF9800), Color(0xFF424242)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Inicializando câmera...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: kIsWeb
                ? CameraPreviewWeb()
                : (controller != null ? CameraPreview(controller!) : Container()),
          ),
          
          // Overlay escuro
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      Expanded(
                        child: Text(
                          'Posicione o focinho no círculo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Círculo de detecção
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: animalDetected ? _pulseAnimation.value : 1.0,
                  child: CustomPaint(
                    size: Size(280, 280),
                    painter: FocinhoPainter(
                      isDetecting: animalDetected,
                      scanProgress: animalDetected ? _scanAnimation.value : 0.0,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Status Text
          if (animalDetected)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF9800).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '🐕 Animal detectado!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Analisando focinho...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          
          // Botão de captura
          if (!animalDetected)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _captureAndAnalyze,
                    icon: Icon(
                      Icons.camera_alt,
                      color: Color(0xFFFF9800),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget para CameraPreview na Web
class CameraPreviewWeb extends StatefulWidget {
  @override
  _CameraPreviewWebState createState() => _CameraPreviewWebState();
}

class _CameraPreviewWebState extends State<CameraPreviewWeb> {
  CameraController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isReady = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return CameraPreview(_controller!);
  }
}

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? _image;
  final PetIdentificationService _petService = PetIdentificationService();
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = picked;
        _isAnalyzing = true;
      });
      
      try {
        // Identificar o pet usando o serviço
        final petData = await _petService.identifyPet(imagePath: picked.path);
        
        // Verificar se houve erro de autenticação
        if (petData != null && petData['auth_error'] == true) {
          _redirectToLogin();
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imagePath: picked.path,
              petData: petData,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao identificar pet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isAnalyzing = false);
        }
      }
    }
  }

  void _redirectToLogin() async {
    // Fazer logout
    await AuthService().logout();
    
    // Mostrar mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sessão expirada. Faça login novamente.'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Navegar para login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF9800),
              Color(0xFF424242),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    Expanded(
                      child: Text(
                        'Selecionar Imagem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          'Escolha uma foto do seu pet',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Selecione uma imagem clara do focinho\npara obter melhores resultados',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 48),
                        Container(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFFFF9800),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _pickImage,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library, size: 24),
                                SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    'Escolher da Galeria',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FocinhoPainter extends CustomPainter {
  final bool isDetecting;
  final double scanProgress;

  FocinhoPainter({
    this.isDetecting = false,
    this.scanProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Círculo principal
    final paint = Paint()
      ..color = isDetecting ? Color(0xFFFF9800) : Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, paint);

    // Círculo interno pulsante quando detectando
    if (isDetecting) {
      final innerPaint = Paint()
        ..color = Color(0xFFFF9800).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, radius * 0.8, innerPaint);
    }

    // Pontos de referência
    final dotPaint = Paint()
      ..color = isDetecting ? Color(0xFFFF9800) : Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Pontos nas posições 12, 3, 6, 9 horas
    final dotPositions = [
      Offset(center.dx, center.dy - radius), // 12h
      Offset(center.dx + radius, center.dy), // 3h
      Offset(center.dx, center.dy + radius), // 6h
      Offset(center.dx - radius, center.dy), // 9h
    ];

    for (final pos in dotPositions) {
      canvas.drawCircle(pos, 6, dotPaint);
    }

    // Linha de escaneamento animada
    if (isDetecting && scanProgress > 0) {
      final scanPaint = Paint()
        ..color = Color(0xFFFF9800).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final scanY = center.dy - radius + (2 * radius * scanProgress);
      canvas.drawLine(
        Offset(center.dx - radius, scanY),
        Offset(center.dx + radius, scanY),
        scanPaint,
      );
    }

    // Texto de instrução
    if (!isDetecting) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Posicione o focinho aqui',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy + radius + 20,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic>? petData;
  
  const ResultScreen({
    required this.imagePath,
    this.petData,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _identificationResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Se os dados do pet já foram fornecidos, use-os diretamente
    if (widget.petData != null) {
      _identificationResult = widget.petData;
    } else {
      // Caso contrário, mostre erro
      _errorMessage = 'Dados do pet não disponíveis';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPetImage() {
    // Se o pet foi identificado e tem imagens, mostrar a foto armazenada
    if (_identificationResult != null && 
        _identificationResult!['match_found'] == true &&
        _identificationResult!['images'] != null &&
        _identificationResult!['images'].isNotEmpty) {
      
      final images = _identificationResult!['images'] as List;
      // Procurar pela imagem primária ou usar a primeira disponível
      final primaryImage = images.firstWhere(
        (img) => img['is_primary'] == true,
        orElse: () => images.first,
      );
      
      final imageUrl = primaryImage['url'];
      print('DEBUG: Exibindo imagem armazenada do pet: $imageUrl');
      
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('DEBUG: Erro ao carregar imagem do pet: $error');
          return _buildFallbackImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Color(0xFFFF9800),
            ),
          );
        },
      );
    }
    
    // Caso contrário, mostrar a imagem capturada ou placeholder
    return _buildFallbackImage();
  }
  
  Widget _buildFallbackImage() {
    if (widget.imagePath != null) {
      return kIsWeb
          ? Image.network(widget.imagePath!, fit: BoxFit.cover)
          : Image.file(File(widget.imagePath!), fit: BoxFit.cover);
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.brown.shade300, Colors.brown.shade600],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 80,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9800),
              Color(0xFF424242),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    Expanded(
                      child: Text(
                        'Resultado da Análise',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Ação de compartilhar
                      },
                      icon: Icon(Icons.share, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              
              // Imagem do pet (armazenada ou capturada)
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildPetImage(),
                  ),
                ),
              ),
              
              // Informações do resultado
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _buildResultContent(),
                  ),
                ),
              ),
              
              // Botões de ação
              Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 2),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Text(
                          'Nova Análise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFFFF9800),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          // Ação de salvar ou mais informações
                        },
                        child: Text(
                          'Mais Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    if (_isLoading) {
      return Column(
        children: [
          CircularProgressIndicator(color: Color(0xFFFF9800)),
          SizedBox(height: 16),
          Text(
            'Analisando imagem...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Erro na Identificação',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    // Verificar se a resposta da API foi bem-sucedida e se o pet foi identificado
    bool petIdentified = false;
    Map<String, dynamic>? petResult;
    
    print('DEBUG: _identificationResult = $_identificationResult');
    
    if (_identificationResult != null && _identificationResult!['match_found'] == true) {
      petIdentified = true;
      petResult = _identificationResult; // Os dados do pet estão diretamente na resposta
      print('DEBUG: Pet identificado! petResult = $petResult');
    } else {
      print('DEBUG: Falha na verificação - match_found: ${_identificationResult?['match_found']}');
    }
    
    if (!petIdentified) {
      return Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.orange.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Pet Não Identificado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Não foi possível identificar este pet em nossa base de dados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    // Pet identificado com sucesso
    final result = petResult!;
    final confidence = result['confidence'] ?? 0.0;
    final petName = result['pet_name'] ?? 'Nome não disponível';
    final ownerContact = result['owner_contact'] ?? 'Contato não disponível';
    final breed = result['breed'] ?? 'Raça não identificada';
    final age = result['age'] ?? 'Idade não informada';
    final description = result['description'] ?? '';
    final lastSeen = result['last_seen'] ?? 'Data não informada';
    final status = result['status'] ?? 'unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text(
                    '✅ Identificado',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '${confidence.toStringAsFixed(1)}% de confiança',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          petName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF9800),
          ),
        ),
        SizedBox(height: 8),
        // Status do pet
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: status == 'lost' ? Colors.red.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            status == 'lost' ? '🔍 PERDIDO' : '🏠 ENCONTRADO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: status == 'lost' ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
        ),
        SizedBox(height: 16),
        // Informações do pet
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildInfoChip('🐕', breed),
            _buildInfoChip('🎂', age),
            if (lastSeen.isNotEmpty) _buildInfoChip('📅', lastSeen),
          ],
        ),
        if (description.isNotEmpty) ...[
          SizedBox(height: 16),
          Text(
            'Descrição:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
        SizedBox(height: 16),
        Text(
          'Contato do Proprietário:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.contact_phone, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  ownerContact,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String emoji, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}