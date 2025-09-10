import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    cameras = await availableCameras();
  }
  runApp(SmartPetApp());
}

class SmartPetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPet ID - Identificação Multifatorial',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFFF9800, {
          50: Color(0xFFFFF3E0),
          100: Color(0xFFFFE0B2),
          200: Color(0xFFFFCC80),
          300: Color(0xFFFFB74D),
          400: Color(0xFFFFA726),
          500: Color(0xFFFF9800),
          600: Color(0xFFFB8C00),
          700: Color(0xFFF57C00),
          800: Color(0xFFEF6C00),
          900: Color(0xFFE65100),
        }),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMobileOrWeb = kIsWeb || (Platform.isAndroid || Platform.isIOS);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF9800), // Laranja principal
              Color(0xFFF57C00), // Laranja mais escuro
              Color(0xFF424242), // Cinza escuro
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          SizedBox(height: 40),
                          // Novo ícone com as patas sobrepostas
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(70),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: Color.fromARGB(255, 242, 242, 242), // Fundo laranja
    shape: BoxShape.circle,
  ),
  child: Padding(
    padding: EdgeInsets.all(8),
    child: Image.asset(
      'assets/app_icon_192.png',
      fit: BoxFit.contain,
    ),
  ),
),
                          ),
                          SizedBox(height: 28),
                          Text(
                            'SmartPet ID',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tecnologia de Identificação\nMultifatorial para Pets',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Identifique seu pet pelo focinho\ncom inteligência artificial avançada',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 48),
                              
                              // Main Button
                              Container(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFFFF9800),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => CameraScreen()),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ImagePickerScreen()),
                                      );
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isMobileOrWeb ? Icons.camera_alt : Icons.photo_library,
                                        size: 26,
                                      ),
                                      SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          isMobileOrWeb ? 'Iniciar Escaneamento' : 'Selecionar Imagem',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Secondary Button
                              if (isMobileOrWeb)
                                Container(
                                  width: double.infinity,
                                  height: 54,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(color: Colors.white.withOpacity(0.8), width: 2.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(27),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ImagePickerScreen()),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.photo_library, size: 22),
                                        SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            'Escolher da Galeria',
                                            style: TextStyle(
                                              fontSize: 16,
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
                    
                    // Footer
                    Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Suporta cães e gatos • Resultados instantâneos • Tecnologia avançada',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter para o logo SmartPet ID
class SmartPetLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orangePaint = Paint()
      ..color = Color(0xFFFF9800)
      ..style = PaintingStyle.fill;
    
    final darkPaint = Paint()
      ..color = Color(0xFF424242)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Pata laranja (esquerda/inferior)
    final orangePawCenter = Offset(center.dx - 8, center.dy + 8);
    
    // Almofada principal laranja
    canvas.drawOval(
      Rect.fromCenter(
        center: orangePawCenter,
        width: 28,
        height: 32,
      ),
      orangePaint,
    );
    
    // Dedos laranja
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(orangePawCenter.dx - 12, orangePawCenter.dy - 18),
        width: 8,
        height: 12,
      ),
      orangePaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(orangePawCenter.dx - 4, orangePawCenter.dy - 20),
        width: 10,
        height: 14,
      ),
      orangePaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(orangePawCenter.dx + 6, orangePawCenter.dy - 18),
        width: 8,
        height: 12,
      ),
      orangePaint,
    );
    
    // Pata escura (direita/superior)
    final darkPawCenter = Offset(center.dx + 8, center.dy - 8);
    
    // Almofada principal escura
    canvas.drawOval(
      Rect.fromCenter(
        center: darkPawCenter,
        width: 28,
        height: 32,
      ),
      darkPaint,
    );
    
    // Dedos escuros
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(darkPawCenter.dx - 12, darkPawCenter.dy - 18),
        width: 8,
        height: 12,
      ),
      darkPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(darkPawCenter.dx - 4, darkPawCenter.dy - 20),
        width: 10,
        height: 14,
      ),
      darkPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(darkPawCenter.dx + 6, darkPawCenter.dy - 18),
        width: 8,
        height: 12,
      ),
      darkPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(darkPawCenter.dx + 14, darkPawCenter.dy - 16),
        width: 8,
        height: 12,
      ),
      darkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    if (!kIsWeb && cameras.isNotEmpty) {
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      await controller!.initialize();
      if (mounted) {
        setState(() => isReady = true);
        _startDetectionSimulation();
      }
    } else if (kIsWeb) {
      setState(() => isReady = true);
      _startDetectionSimulation();
    } else {
      setState(() {
        error = 'Nenhuma câmera encontrada.';
      });
    }
  }

  void _startDetectionSimulation() {
    // Simula a detecção após 3 segundos
    _detectionTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isDetecting = true;
          animalDetected = true;
        });
        _pulseController.repeat(reverse: true);
        _scanController.repeat();
        
        // Após 2 segundos de "análise", navega para o resultado
        Timer(Duration(seconds: 2), () {
          if (mounted) {
            _navigateToResult();
          }
        });
      }
    });
  }

  void _navigateToResult() {
    _pulseController.stop();
    _scanController.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(imagePath: null),
      ),
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
                    onPressed: _navigateToResult,
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = picked);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: picked.path),
        ),
      );
    }
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
  final String? imagePath;
  const ResultScreen({this.imagePath});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  PageController _pageController = PageController();
  int _currentImageIndex = 0;
  
  final List<String> _petImages = [
    'assets/cachorro.jpeg',
    'assets/cachorror2.jpeg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              
              // Carrossel de imagens
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
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: widget.imagePath != null ? 1 : _petImages.length,
                          itemBuilder: (context, index) {
                            if (widget.imagePath != null) {
                              return kIsWeb
                                  ? Image.network(widget.imagePath!, fit: BoxFit.cover)
                                  : Image.file(File(widget.imagePath!), fit: BoxFit.cover);
                            } else {
                              return Image.asset(
                                _petImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.brown.shade300, Colors.brown.shade600],
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.pets,
                                            size: 80,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Sabrina',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'SRD (Sem raça definida)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                        
                        // Indicadores de página (apenas se houver múltiplas imagens)
                        if (widget.imagePath == null && _petImages.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _petImages.length,
                                (index) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
                    child: Column(
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
                                '98% de confiança',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
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
                          'Sabrina',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SRD (Sem raça definida)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildInfoChip('🎂', '10 anos'),
                              SizedBox(width: 12),
                              _buildInfoChip('⚖️', '10 kg'),
                              SizedBox(width: 12),
                              _buildInfoChip('📏', 'Médio'),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Características: Carinhosa, brincalhona e muito leal. Cão de porte médio com personalidade única e temperamento dócil.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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

