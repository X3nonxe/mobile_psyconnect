import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:psyconnect/blocs/schedule/schedule_bloc.dart';
import 'package:psyconnect/repositories/schedule_repository.dart';
import 'package:psyconnect/screens/psycholog-screen/schedule_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PsychologistDashboard extends StatelessWidget {
  const PsychologistDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Psikolog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              // Get psychologist ID before navigating
              final prefs = await SharedPreferences.getInstance();
              final psychologistId = prefs.getString('id') ?? '';

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => ScheduleBloc(
                        repository:
                            ScheduleRepositoryImpl(client: http.Client()),
                        psychologistId: psychologistId,
                      )..add(LoadSchedules()),
                      child: const ScheduleManagementScreen(),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAppointmentsOverview(),
          _buildClientList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentsOverview() {
    // Implementasi daftar janji temu
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Janji Temu Mendatang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Konsultasi dengan Budi'),
              subtitle: const Text('Senin, 10 April 2023 - 10:00 AM'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Tambahkan aksi untuk detail janji temu
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Konsultasi dengan Siti'),
              subtitle: const Text('Selasa, 11 April 2023 - 2:00 PM'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Tambahkan aksi untuk detail janji temu
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientList() {
    // Implementasi daftar klien
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Klien',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Budi Santoso'),
              subtitle: const Text('Status: Aktif'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Tambahkan aksi untuk detail klien
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Siti Aminah'),
              subtitle: const Text('Status: Aktif'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Tambahkan aksi untuk detail klien
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
