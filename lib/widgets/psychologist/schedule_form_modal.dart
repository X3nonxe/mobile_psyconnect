import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psyconnect/blocs/schedule/schedule_bloc.dart';
import 'package:psyconnect/models/schedule_model.dart';

class ScheduleFormModal extends StatefulWidget {
  final Schedule? initialSchedule;

  const ScheduleFormModal({super.key, this.initialSchedule});

  @override
  _ScheduleFormModalState createState() => _ScheduleFormModalState();
}

class _ScheduleFormModalState extends State<ScheduleFormModal> {
  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isRecurring;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSchedule?.dayOfWeek ?? 1;
    _startTime = widget.initialSchedule?.startTime ??
        const TimeOfDay(hour: 8, minute: 0);
    _endTime =
        widget.initialSchedule?.endTime ?? const TimeOfDay(hour: 12, minute: 0);
    _isRecurring = widget.initialSchedule?.isRecurring ?? true;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = selectedTime;
        } else {
          _endTime = selectedTime;
        }
      });
    }
  }

  /// Returns the localized day name for the given index (0 = Minggu).
  String _getDayName(int dayOfWeek) {
    const dayNames = [
      'Senin', // 1
      'Selasa', // 2
      'Rabu', // 3
      'Kamis', // 4
      'Jumat', // 5
      'Sabtu', // 6
      'Minggu' // 7
    ];
    return dayNames[dayOfWeek - 1];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
          widget.initialSchedule == null ? 'Tambah Jadwal Baru' : 'Edit Jadwal',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Hari',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              value: _selectedDay,
              items: List.generate(7, (index) => index + 1)
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child:
                            Text(_getDayName(day)), // Langsung menggunakan day
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDay = value!),
            ),
            const SizedBox(height: 16),
            _buildTimePickerField(
              context: context,
              label: 'Waktu Mulai',
              time: _startTime,
              onTap: () => _selectTime(context, true),
            ),
            const SizedBox(height: 16),
            _buildTimePickerField(
              context: context,
              label: 'Waktu Selesai',
              time: _endTime,
              onTap: () => _selectTime(context, false),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                title: const Text('Berulang Mingguan',
                    style: TextStyle(fontSize: 16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                activeColor: Colors.blue.shade800,
                activeTrackColor: Colors.blue.shade100,
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            final newSchedule = Schedule(
              id: widget.initialSchedule?.id ?? '',
              dayOfWeek: _selectedDay,
              startTime: _startTime,
              endTime: _endTime,
              isRecurring: _isRecurring,
              validFrom: null,
              validTo: null,
            );

            // Cek apakah ini operasi edit atau tambah baru
            if (widget.initialSchedule != null) {
              // Edit jadwal yang sudah ada
              context
                  .read<ScheduleBloc>()
                  .add(UpdateSchedule(newSchedule.id, newSchedule));
              print('Update jadwal: ${newSchedule.toJson()}');
            } else {
              // Tambah jadwal baru
              context.read<ScheduleBloc>().add(SaveSchedules([newSchedule]));
              print('Simpan jadwal baru: ${newSchedule.toJson()}');
            }

            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _buildTimePickerField({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue.shade800),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(time.format(context),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
