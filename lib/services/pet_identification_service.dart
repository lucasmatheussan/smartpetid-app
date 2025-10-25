import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class PetIdentificationService {
  static const String baseUrl = 'http://192.168.1.184:8000';

  /// Identifica um pet através de uma imagem
  Future<Map<String, dynamic>> identifyPet({
    required String imagePath,
    String species = 'auto',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/pets/identify');
      final request = http.MultipartRequest('POST', uri);

      // Adicionar headers de autenticação
      final authHeaders = await AuthService().getAuthHeaders();
      request.headers.addAll(authHeaders);

      // Adicionar a imagem
      if (kIsWeb) {
        // Para web, usar bytes da imagem
        final bytes = await http
            .get(Uri.parse(imagePath))
            .then((response) => response.bodyBytes);
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: 'pet_image.jpg',
          ),
        );
      } else {
        // Para mobile, usar arquivo local
        final file = File(imagePath);
        if (!await file.exists()) {
          return {
            'success': false,
            'message': 'Arquivo de imagem não encontrado',
          };
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
            filename: 'pet_image.jpg',
          ),
        );
      }

      // Adicionar espécie
      request.fields['species'] = species;

      // Enviar requisição
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token de autenticação inválido ou expirado',
          'auth_error': true,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Erro na identificação do pet',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  /// Identifica um pet através de bytes da imagem (para casos especiais)
  Future<Map<String, dynamic>> identifyPetFromBytes({
    required List<int> imageBytes,
    String species = 'auto',
    String filename = 'pet_image.jpg',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/pets/identify');
      final request = http.MultipartRequest('POST', uri);

      // Adicionar a imagem
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
        ),
      );

      // Adicionar espécie
      request.fields['species'] = species;

      // Enviar requisição
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Erro na identificação do pet',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  /// Busca todos os pets cadastrados
  Future<Map<String, dynamic>> getAllPets() async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeaders();

      final uri = Uri.parse('$baseUrl/pets');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token de autenticação inválido ou expirado',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Erro ao buscar pets',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  /// Busca detalhes de um pet específico
  Future<Map<String, dynamic>> getPetDetails(String petId) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeaders();

      final uri = Uri.parse('$baseUrl/pets/$petId');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token de autenticação inválido ou expirado',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Erro ao buscar detalhes do pet',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
}
