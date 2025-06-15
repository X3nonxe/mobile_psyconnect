import 'dart:convert';

import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/models/psychologist.dart';
import 'package:psyconnect/models/schedule_model.dart';
import 'package:psyconnect/screens/schedule_screen.dart';
import 'package:psyconnect/utils/date_select.dart';
import 'package:psyconnect/utils/time_select.dart';
import 'package:psyconnect/widgets/psycholog_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PsychologDetails extends StatefulWidget {
  final String psychologId;

  const PsychologDetails({super.key, required this.psychologId});

  @override
  _PsychologDetailsState createState() => _PsychologDetailsState();
}

class _PsychologDetailsState extends State<PsychologDetails> {
  bool showExtendedText = false;
  PsychologistModel? psychologist;
  List<Schedule> schedules = [];
  Map<int, List<Schedule>> schedulesByDay = {};
  int? selectedDay;
  String? selectedTime;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final psych = await fetchPsychologistDetails();
      final scheds = await fetchSchedules();

      setState(() {
        psychologist = psych;
        schedules = scheds;
        schedulesByDay = groupSchedulesByDay(schedules);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data: $e';
        isLoading = false;
      });
    }
  }

  Map<int, List<Schedule>> groupSchedulesByDay(List<Schedule> schedules) {
    Map<int, List<Schedule>> result = {};
    for (var schedule in schedules) {
      final day = schedule.dayOfWeek;
      if (!result.containsKey(day)) {
        result[day] = [];
      }
      result[day]!.add(schedule);
    }
    return result;
  }

  Future<PsychologistModel> fetchPsychologistDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
          'https://psy-backend-production.up.railway.app/api/v1/psychologists/${widget.psychologId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return PsychologistModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat data psikolog');
    }
  }

  Future<List<Schedule>> fetchSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
          'https://psy-backend-production.up.railway.app/api/v1/schedules/psychologists/${widget.psychologId}/schedules'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat jadwal');
    }
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  List<String> _generateTimeSlots(Schedule schedule) {
    final start = TimeOfDay(
      hour: schedule.startTime.hour,
      minute: schedule.startTime.minute,
    );
    final end = TimeOfDay(
      hour: schedule.endTime.hour,
      minute: schedule.endTime.minute,
    );

    List<String> slots = [];
    TimeOfDay current = start;

    while (current.hour < end.hour ||
        (current.hour == end.hour && current.minute < end.minute)) {
      slots.add(
          '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}');
      current = current.replacing(
        hour: current.minute + 30 >= 60 ? current.hour + 1 : current.hour,
        minute: (current.minute + 30) % 60,
      );
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty || psychologist == null) {
      return Scaffold(
        body: Center(child: Text(errorMessage)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  PsychologList(
                    harga: "Rp.${psychologist!.consultationFee}",
                    image: "lib/icons/male-doctor.png",
                    namaPsikolog: psychologist!.fullName,
                    spesialisasi: psychologist!.specializations.join(', '),
                    psychologId: psychologist!.id,
                  ),
                  const SizedBox(height: 20),
                  _buildProfessionalInfo(),
                  const SizedBox(height: 15),
                  _buildDescriptionSection(),
                  const SizedBox(height: 20),
                  _buildDateSelection(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),
                  const SizedBox(height: 20),
                  _buildTimeSelection(),
                  // Add bottom padding to prevent content overlap
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Fixed button at bottom
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.assignment_ind_outlined,
            label: "Nomor Lisensi",
            value: psychologist?.licenseNumber ?? '-',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.school_outlined,
            label: "Pendidikan",
            value: psychologist?.education
                    .map((e) => "${e.degree} - ${e.university}")
                    .join("\n") ??
                '-',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: "Alamat Praktik",
            value: psychologist?.address ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: bluePrimaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                height: 1.4,
              ),
              maxLines: null,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ]),
        )
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return GestureDetector(
      onTap: toggleTextVisibility,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tentang Psikolog",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              psychologist?.description ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.black87, height: 1.5),
              maxLines: showExtendedText ? null : 3,
              overflow: showExtendedText
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if ((psychologist?.description.length ?? 0) > 100)
              Text(
                showExtendedText ? "Lebih Sedikit" : "Selengkapnya",
                style: GoogleFonts.poppins(
                    color: bluePrimaryColor, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    final days = schedulesByDay.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            return GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: DateSelect(
                date: _getDayName(day).substring(0, 3),
                maintext: _getDayName(day),
                isSelected: selectedDay == day,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    if (selectedDay == null) return SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final timeSlots = schedulesByDay[selectedDay]!
        .expand((s) => _generateTimeSlots(s))
        .toList();

    return SizedBox(
      height: screenHeight * 0.24,
      width: screenWidth * 0.9,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          final time = timeSlots[index];
          return TimeSelect(
            mainText: time,
            isSelected: selectedTime == time,
            onTap: () => setState(() => selectedTime = time),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bluePrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 50),
        ),
        onPressed: () {
          if (selectedDay == null || selectedTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(
                    'Pilih hari dan waktu terlebih dahulu',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                backgroundColor: bluePrimaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: SheduleScreen(
                  // psychologist: psychologist!,
                  // selectedDay: selectedDay!,
                  // selectedTime: selectedTime!,
                  ),
            ),
          );
        },
        child: Text(
          'Buat Janji',
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void toggleTextVisibility() {
    setState(() {
      showExtendedText = !showExtendedText;
    });
  }
}

AppBar _buildAppBar(BuildContext context) {
  return AppBar(
    leading: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: const Icon(Icons.arrow_back_ios),
    ),
    title: Text(
      "Detail Psikolog",
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp),
    ),
    centerTitle: true,
    elevation: 0,
    toolbarHeight: 100,
    backgroundColor: Colors.white,
  );
}
