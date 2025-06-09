import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:psyconnect/blocs/schedule/schedule_bloc.dart';
import 'package:psyconnect/widgets/psychologist/schedule_form_modal.dart';
import '../../../models/schedule_model.dart';

class ScheduleTimeSlot extends StatelessWidget {
  final Schedule schedule;

  const ScheduleTimeSlot({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(schedule.startTime)} – ${_formatTime(schedule.endTime)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (!schedule.isRecurring)
                  Text(
                    'Valid: ${DateFormat('dd MMM yyyy').format(schedule.validFrom!)}'
                    '${schedule.validTo != null ? ' s.d. ${DateFormat('dd MMM yyyy').format(schedule.validTo!)}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _showEditDialog(BuildContext context) async {
    // Tampilkan modal dengan data awal schedule yang akan diedit
    final Schedule? updatedSchedule = await showDialog<Schedule>(
      context: context,
      builder: (_) => ScheduleFormModal(initialSchedule: schedule),
    );

    // Jika user menekan update dan mengembalikan data valid
    if (updatedSchedule != null && context.mounted) {
      // Pastikan ID schedule yang diedit tetap dipertahankan
      final finalSchedule = updatedSchedule.copyWith(id: schedule.id);

      // Dispatch UpdateSchedule dengan ID dan data yang diperbarui
      context.read<ScheduleBloc>().add(
            UpdateSchedule(schedule.id, finalSchedule),
          );

      // Feedback untuk user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSchedule(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSchedule(BuildContext context) {
    context.read<ScheduleBloc>().add(DeleteSchedule(schedule.id));
    // BLoC _onDeleteSchedule() sudah fetch ulang dan emit ScheduleLoaded

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Jadwal berhasil dihapus!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
