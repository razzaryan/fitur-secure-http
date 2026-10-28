import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../services/api_service.dart';
import 'user_list_screen.dart';
import 'post_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  final ApiService _apiService = ApiService();

  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _savedToken;
  bool _hasToken = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkToken() async {
    final hasToken = await _storageService.hasToken();
    final token = await _storageService.getToken();
    setState(() {
      _hasToken = hasToken;
      _savedToken = token;
    });
  }

  // Simpan Token Manual
  Future<void> _saveToken() async {
    if (_tokenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await _storageService.saveToken(_tokenController.text.trim());
    _tokenController.clear();
    await _checkToken();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token berhasil disimpan di Secure Storage'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Solusi Latihan 1: Fitur Login dengan Token
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan Password wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      final token = await _apiService.login(email, password);
      await _storageService.saveToken(token);
      _emailController.clear();
      _passwordController.clear();
      await _checkToken();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil! Token otomatis disimpan.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoggingIn = false);
    }
  }

  // Solusi Latihan 2: Fitur Logout dengan Dialog Konfirmasi
  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin menghapus token dan keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteToken();
      await _checkToken();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout berhasil. Token dihapus.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage & HTTP'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Secure Storage Status & Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'Secure Storage',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Simpan token atau PIN di secure storage (terenkripsi AES).',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tokenController,
                        decoration: const InputDecoration(
                          labelText: 'Token Manual',
                          hintText: 'Masukkan token dummy',
                          prefixIcon: Icon(Icons.vpn_key),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveToken,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _hasToken ? _handleLogout : null,
                              icon: const Icon(Icons.delete),
                              label: const Text('Logout/Hapus'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _hasToken ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hasToken ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _hasToken ? Icons.check_circle : Icons.cancel,
                              color: _hasToken ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hasToken
                                    ? 'Token Tersimpan: ${_savedToken != null && _savedToken!.length > 10 ? _savedToken!.substring(0, 10) : _savedToken}...'
                                    : 'Belum ada token tersimpan',
                                style: TextStyle(
                                  color: _hasToken ? Colors.green[800] : Colors.red[800],
                                  fontWeight: FontWeight.bold,
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

              const SizedBox(height: 16),

              // Section 2: Form Login (Solusi Latihan 1)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Form Login (Latihan 1)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoggingIn ? null : _handleLogin,
                          icon: _isLoggingIn
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.login),
                          label: const Text('Login & Simpan Token'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Section 3: HTTP Request & Navigation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'HTTP Request',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ambil data dari REST API (JSONPlaceholder) menggunakan request GET.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserListScreen()),
                          );
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('Lihat Daftar Pengguna (Users)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PostListScreen()),
                          );
                        },
                        icon: const Icon(Icons.article),
                        label: const Text('Lihat Daftar Postingan (Latihan 3)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
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
    );
  }
}