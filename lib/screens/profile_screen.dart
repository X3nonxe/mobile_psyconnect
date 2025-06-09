import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  Map<String, dynamic>? _clientData;
  bool _isLoading = true;
  String _errorMessage = '';
  String _clientId = '';

  @override
  void initState() {
    super.initState();
    _loadClientId();
  }

  Future<void> _loadClientId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('id');

      if (id != null && id.isNotEmpty) {
        setState(() {
          _clientId = id;
        });
        await _fetchClientData();
      } else {
        setState(() {
          _errorMessage = 'ID Klien tidak ditemukan. Silakan login kembali.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengguna: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClientData() async {
    try {
      final response = await http.get(
        Uri.parse('https://psy-backend-production.up.railway.app/api/v1/clients/$_clientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _clientData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data klien: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Keluar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: bluePrimaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _fetchClientData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final dob = DateTime.parse(_clientData!['date_of_birth']);
    final createdAt = DateTime.parse(_clientData!['created_at']);

    return RefreshIndicator(
      onRefresh: _fetchClientData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            CircleAvatar(
              radius: 10.w,
              backgroundColor: bluePrimaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 15.w,
                color: bluePrimaryColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _clientData!['full_name'],
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            _buildInfoItem('Nomor Telepon', _clientData!['phone_number']),
            _buildInfoItem('Tanggal Lahir', dateFormat.format(dob)),
            _buildInfoItem('Bergabung Pada', dateFormat.format(createdAt)),
            SizedBox(height: 4.h),
            Divider(thickness: 1),
            SizedBox(height: 2.h),
            _buildActionButton(
              icon: Icons.edit,
              label: 'Edit Profil',
              onPressed: () {
                // Tambahkan navigasi ke edit profil
              },
            ),
            _buildActionButton(
              icon: Icons.history,
              label: 'Riwayat Konsultasi',
              onPressed: () {
                // Tambahkan navigasi ke riwayat
              },
            ),
            _buildActionButton(
              icon: Icons.logout,
              label: 'Keluar',
              onPressed: _confirmLogout,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigasi ke pengaturan
            },
          ),
        ],
        backgroundColor: bluePrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildProfileContent(),
    );
  }
}
