import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _defaultTimeout = Duration(seconds: 10);

  // GET /users dengan Configurable Timeout (Latihan 5)
  Future<List<User>> getUsers({Duration timeout = _defaultTimeout}) async {
    try {
      print('Request GET: $_baseUrl/users');
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw HttpException('Gagal memuat data. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on FormatException {
      throw Exception('Format data JSON tidak valid.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // GET /users/{id}
  Future<User> getUserById(int id, {Duration timeout = _defaultTimeout}) async {
    try {
      print('Request GET: $_baseUrl/users/$id');
      final response = await http
          .get(Uri.parse('$_baseUrl/users/$id'))
          .timeout(timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw HttpException('Gagal memuat data. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // GET /posts (Solusi Latihan 3)
  Future<List<Post>> getPosts({Duration timeout = _defaultTimeout}) async {
    try {
      print('Request GET: $_baseUrl/posts');
      final response = await http
          .get(Uri.parse('$_baseUrl/posts'))
          .timeout(timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw HttpException('Gagal memuat posts. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout saat memuat posts.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Simulasi Login (Latihan 1)
  Future<String> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (email.isNotEmpty && password.isNotEmpty) {
        final token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
        // Safe Logging: Hanya mencetak identitas user non-sensitif
        print('Login berhasil untuk email: $email');
        return token;
      } else {
        throw Exception('Email dan password tidak boleh kosong');
      }
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }
}