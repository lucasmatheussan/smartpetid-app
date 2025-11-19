import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_pet_screen.dart';
import 'screens/scan_screens.dart';
import 'screens/pet_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/rfid_scanner_screen.dart';
import 'services/auth_service.dart';
import 'services/localization_service.dart';
import 'l10n/app_localizations.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    try {
      cameras = await availableCameras();
    } catch (e) {
      print('Erro ao inicializar câmeras: $e');
      cameras = [];
    }
  }

  // Inicializar AuthService para carregar token salvo
  await AuthService().initialize();

  // Inicializar LocalizationService
  final localizationService = LocalizationService();
  await localizationService.initialize();

  runApp(SmartPetApp(localizationService: localizationService));
}

class SmartPetApp extends StatelessWidget {
  final LocalizationService localizationService;

  const SmartPetApp({Key? key, required this.localizationService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: localizationService,
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          print(
              'MaterialApp rebuilding with locale: ${localizationService.currentLocale}');
          return MaterialApp(
            title: 'SmartPet ID',
            locale: localizationService.currentLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              primarySwatch: const MaterialColor(0xFFFF9800, {
                50: const Color(0xFFFFF3E0),
                100: const Color(0xFFFFE0B2),
                200: const Color(0xFFFFCC80),
                300: const Color(0xFFFFB74D),
                400: const Color(0xFFFFA726),
                500: const Color(0xFFFF9800),
                600: const Color(0xFFFB8C00),
                700: const Color(0xFFF57C00),
                800: const Color(0xFFEF6C00),
                900: const Color(0xFFE65100),
              }),
              fontFamily: 'Roboto',
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
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
            initialRoute: '/login',
            routes: {
              '/': (context) => HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/register-pet': (context) => RegisterPetScreen(),
              '/qr-scanner': (context) => const QrScannerScreen(),
              '/rfid-scanner': (context) => const RfidScannerScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Verificar se o usuário está logado
    if (!_authService.isLoggedIn) {
      // Se não estiver logado, redirecionar para login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }

    // Verificar se o token ainda é válido
    final isValid = await _authService.validateToken();
    if (!isValid) {
      // Token inválido, fazer logout e redirecionar
      await _authService.logout();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Faça login novamente.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }

    // Usuário autenticado, mostrar tela
    setState(() {
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF9800),
                Color(0xFFF57C00),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Verificando autenticação...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    bool isMobileOrWeb = kIsWeb || (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartPet ID'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF9800),
                Color(0xFFF57C00),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF9800),
                Color(0xFFF57C00),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFF9800),
                      Color(0xFFF57C00),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Color(0xFFFF9800),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SmartPet ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Identificação Multifatorial',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Escanear Pet',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Manter na tela atual
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: Colors.white),
                title: const Text(
                  'Ler QRCode',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/qr-scanner');
                },
              ),
              ListTile(
                leading: const Icon(Icons.nfc, color: Colors.white),
                title: const Text(
                  'Ler RFID',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/rfid-scanner');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.white),
                title: const Text(
                  'Cadastrar Animal',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/register-pet');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list, color: Colors.white),
                title: const Text(
                  'Ver Animais Cadastrados',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  // Verificar se o usuário está autenticado
                  final authService = AuthService();
                  if (!authService.isLoggedIn) {
                    // Mostrar mensagem e redirecionar para login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Você precisa fazer login para ver os animais cadastrados.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    Navigator.pushNamed(context, '/login');
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PetListScreen(),
                    ),
                  );
                },
              ),
              Divider(color: Colors.white.withOpacity(0.3)),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text(
                  'Configurações',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.white),
                title: const Text(
                  'Ajuda',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Sair',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Novo ícone com as patas sobrepostas
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(70),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(
                                    255, 242, 242, 242), // Fundo laranja
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/app_icon_192.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
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
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Identificação Multifatorial de Pets',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Primary Button
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFFF9800),
                                  elevation: 12,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                onPressed: () {
                                  if (kIsWeb ||
                                      Platform.isAndroid ||
                                      Platform.isIOS) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => CameraScreen()),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePickerScreen()),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isMobileOrWeb
                                          ? Icons.camera_alt
                                          : Icons.photo_library,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        isMobileOrWeb
                                            ? 'Iniciar Escaneamento'
                                            : 'Selecionar Imagem',
                                        style: const TextStyle(
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

                            const SizedBox(height: 24),

                            // Secondary Button
                            if (isMobileOrWeb)
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.8),
                                        width: 2.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(27),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePickerScreen()),
                                    );
                                  },
                                  child: const Row(
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

                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.white.withOpacity(0.8),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tecnologia segura e confiável',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Versão 1.0.0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
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
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    // Desenhar patas sobrepostas
    // Pata 1 (superior esquerda)
    canvas.drawCircle(
      Offset(center.dx - radius * 0.6, center.dy - radius * 0.6),
      radius * 0.8,
      paint,
    );

    // Pata 2 (superior direita)
    canvas.drawCircle(
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.6),
      radius * 0.8,
      paint,
    );

    // Pata 3 (inferior esquerda)
    canvas.drawCircle(
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.6),
      radius * 0.8,
      paint,
    );

    // Pata 4 (inferior direita)
    canvas.drawCircle(
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.6),
      radius * 0.8,
      paint,
    );

    // Círculo central
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
