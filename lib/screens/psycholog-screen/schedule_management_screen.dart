import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psyconnect/blocs/schedule/schedule_bloc.dart';
import 'package:psyconnect/models/schedule_model.dart';
import 'package:psyconnect/widgets/psychologist/schedule_day_card.dart';
import 'package:psyconnect/widgets/psychologist/schedule_form_modal.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load schedules when screen is initialized
    context.read<ScheduleBloc>().add(LoadSchedules());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal Praktek',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 28),
            onPressed: () => _showSaveConfirmation(context),
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: BlocConsumer<ScheduleBloc, ScheduleState>(
          listener: (context, state) {
            if (state is ScheduleSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil disimpan')),
              );
            } else if (state is ScheduleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            if (state is ScheduleLoading || state is ScheduleSaving) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ScheduleLoaded || state is ScheduleSaved) {
              final schedules = state is ScheduleLoaded
                  ? state.schedules
                  : (state as ScheduleSaved).schedules;
              return _buildScheduleList(schedules);
            }
            return const Center(child: Text('Tidak ada jadwal'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () => _showAddScheduleDialog(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }


  void _showSaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simpan Perubahan'),
        content:
            const Text('Apakah Anda yakin ingin menyimpan perubahan jadwal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSaveSchedules(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleSaveSchedules(BuildContext context) {
    final bloc = BlocProvider.of<ScheduleBloc>(context);
    if (bloc.state is ScheduleLoaded) {
      final schedules = (bloc.state as ScheduleLoaded).schedules;
      bloc.add(SaveSchedules(schedules));
    }
  }

  void _showAddScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ScheduleFormModal(),
    ).then((_) {
      // Refresh data setelah menambah jadwal
      BlocProvider.of<ScheduleBloc>(context).add(LoadSchedules());
    });
  }

  Widget _buildScheduleList(List<Schedule> schedules) {
    // Buat list hari 1-7 (Senin-Minggu)
    final days = List.generate(7, (index) => index + 1);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final dayOfWeek = days[index];
        final daySchedules =
            schedules.where((s) => s.dayOfWeek == dayOfWeek).toList();

        return ScheduleDayCard(
          dayOfWeek: dayOfWeek, // Pastikan mengirim 1-7
          schedules: daySchedules,
        );
      },
    );
  }
}
