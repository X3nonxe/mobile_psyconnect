import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:psyconnect/models/psychologist.dart';
import 'package:psyconnect/screens/psycholog-screen/components/description_card.dart';
import 'package:psyconnect/screens/psycholog-screen/components/education_card.dart';
import 'package:psyconnect/screens/psycholog-screen/components/info_card.dart';
import 'package:psyconnect/screens/psycholog-screen/components/profile_header.dart';
import 'package:psyconnect/screens/psycholog-screen/components/specialization_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePsychologScreen extends StatefulWidget {
  const ProfilePsychologScreen({super.key});

  @override
  State<ProfilePsychologScreen> createState() => _ProfilePsychologScreenState();
}

class _ProfilePsychologScreenState extends State<ProfilePsychologScreen> {
  bool _isLoading = true;
  PsychologistModel? _psychologist;
  String? _errorMessage;
  String _psychologistId = '';

  @override
  void initState() {
    super.initState();
    _loadPsychologistId();
  }

  Future<void> _loadPsychologistId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('id');

      if (id != null && id.isNotEmpty) {
        setState(() {
          _psychologistId = id;
        });
        await _fetchPsychologistData();
      } else {
        setState(() {
          _errorMessage = 'ID Psikolog tidak ditemukan. Silakan login kembali.';
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

  Future<void> _fetchPsychologistData() async {
    try {
      if (_psychologistId.isEmpty) {
        setState(() {
          _errorMessage = 'ID Psikolog tidak tersedia';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://psy-backend-production.up.railway.app/api/v1/psychologists/$_psychologistId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _psychologist = PsychologistModel.fromJson(responseData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Gagal memuat data profil. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan jaringan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur edit profil akan datang'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_psychologist == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: _fetchPsychologistData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(psychologist: _psychologist!),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    title: 'Informasi Pribadi',
                    psychologist: _psychologist!,
                    currencyFormat: currencyFormat,
                  ),
                  const SizedBox(height: 24),
                  DescriptionCard(
                    description: _psychologist!.description,
                    onEdit: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur edit deskripsi akan datang'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SpecializationCard(
                    specializations: _psychologist!.specializations,
                    onEdit: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur edit spesialisasi akan datang'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  EducationCard(
                    education: _psychologist!.education,
                    onEdit: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur edit pendidikan akan datang'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildUpcomingSessionsButton(),
                  const SizedBox(height: 16),
                  _buildAnalyticsButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to upcoming sessions
          Navigator.pushNamed(context, '/consultation-management');
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('Lihat Jadwal Konsultasi'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Navigate to analytics
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur analitik akan datang'),
            ),
          );
        },
        icon: const Icon(Icons.insert_chart_outlined),
        label: const Text('Statistik & Analitik'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
