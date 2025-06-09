import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psyconnect/blocs/schedule/schedule_bloc.dart';
import 'package:psyconnect/models/schedule_model.dart';
import 'package:psyconnect/widgets/psychologist/schedule_time_slot.dart';

class ScheduleDayCard extends StatelessWidget {
  final int dayOfWeek;
  final List<Schedule> schedules;

  const ScheduleDayCard({
    super.key,
    required this.dayOfWeek,
    required this.schedules,
  }) : assert(dayOfWeek >= 1 && dayOfWeek <= 7,
            'dayOfWeek harus antara 1-7. Diterima: $dayOfWeek');

  String _getDayName(int dayOfWeek) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[dayOfWeek - 1];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleOperationSuccess) {
          context.read<ScheduleBloc>().add(LoadSchedules());
        }
      },
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 20, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  Text(
                    _getDayName(dayOfWeek),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (schedules.isNotEmpty)
              ...schedules.map((schedule) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ScheduleTimeSlot(schedule: schedule),
                  )),
            if (schedules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Belum ada jadwal',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
