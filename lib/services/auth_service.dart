import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.184:8000'; // URL do backend
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && _currentUser != null;

  // Inicializar o serviço carregando dados salvos
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);

    final userData = prefs.getString(userKey);
    if (userData != null) {
      try {
        _currentUser = User.fromJson(json.decode(userData));
      } catch (e) {
        print('Erro ao carregar dados do usuário: $e');
        await logout(); // Limpar dados corrompidos
      }
    }
  }

  // Método de login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        // Salvar token
        await _saveToken(data['access_token']);

        // Buscar dados do usuário usando o token
        try {
          final userResponse = await http.get(
            Uri.parse('$baseUrl/auth/me'),
            headers: await getAuthHeaders(),
          );

          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            await _saveUserData(User.fromJson(userData));
            return {'success': true, 'user': userData};
          }
        } catch (e) {
          print('Erro ao buscar dados do usuário: $e');
        }

        return {'success': true, 'user': null};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro no login'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }

  // Método de registro
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          if (phone != null) 'phone': phone,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Usuário registrado com sucesso!'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro no registro'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }

  // Logout do usuário
  Future<void> logout() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Salvar token
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Salvar dados do usuário localmente
  Future<void> _saveUserData(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  // Carregar token do SharedPreferences
  Future<void> _loadToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(tokenKey);
    }
  }

  // Obter headers com autenticação
  Future<Map<String, String>> getAuthHeaders() async {
    await _loadToken(); // Garantir que o token está carregado
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Verificar se o token ainda é válido
  Future<bool> validateToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'), // Endpoint para verificar token
        headers: await getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao validar token: $e');
      return false;
    }
  }

  // Registrar um novo pet
  Future<Map<String, dynamic>> registerPet({
    required String name,
    required String species,
    String? breed,
    int? age,
    String? description,
    required String ownerContact,
    required File image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pets/register'),
      );

      // Adicionar headers
      request.headers.addAll(await getAuthHeaders());

      // Adicionar campos do formulário
      request.fields['name'] = name;
      request.fields['species'] = species;
      request.fields['owner_contact'] = ownerContact;

      if (breed != null) request.fields['breed'] = breed;
      if (age != null) request.fields['age'] = age.toString();
      if (description != null) request.fields['description'] = description;

      // Adicionar imagem (o backend espera 'images' como lista)
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType:
              MediaType('image', 'jpeg'), // Definir content-type explicitamente
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        return {
          'success': true,
          'message': result['message'] ?? 'Pet cadastrado com sucesso!',
          'data': result
        };
      } else {
        return {
          'success': false,
          'message':
              'Erro ao cadastrar pet: ${response.statusCode} - $responseBody'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro ao cadastrar pet: $e'};
    }
  }
}
