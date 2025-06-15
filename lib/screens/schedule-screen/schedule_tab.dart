import 'dart:async';
import 'package:flutter/material.dart';
import 'package:psyconnect/models/consultation_model.dart';
import 'package:psyconnect/models/psychologist.dart';
import 'package:psyconnect/repositories/consultation_repository.dart';
import 'package:psyconnect/widgets/schedule_card.dart';
import 'package:http/http.dart' as http;

class ScheduleTab extends StatefulWidget {
  final String status;

  const ScheduleTab({super.key, required this.status});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  late Future<List<Consultation>> futureConsultations;
  final ConsultationRepository repository = ConsultationRepositoryImpl(
    client: http.Client(),
  );

  final Map<String, PsychologistModel> _psychologistCache = {};

  @override
  void initState() {
    super.initState();
    futureConsultations = repository.getClientConsultations();
  }

  Future<PsychologistModel> _getPsychologist(String psychologistId) async {
    if (_psychologistCache.containsKey(psychologistId)) {
      return _psychologistCache[psychologistId]!;
    }

    try {
      final psychologist = await repository.getPsychologistById(psychologistId);
      _psychologistCache[psychologistId] = psychologist;
      return psychologist;
    } catch (e) {
      return PsychologistModel(
        id: psychologistId,
        fullName: "Nama Psikolog",
        licenseNumber: "",
        available: true,
        consultationFee: 0,
        email: "",
        specializations: ["Spesialisasi"],
        description: "",
        education: [],
      );
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case "confirmed":
        return "Terkonfirmasi";
      case "completed":
        return "Selesai";
      case "cancelled":
        return "Batal";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Consultation>>(
        future: futureConsultations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final consultations = snapshot.data ?? [];

          // Filter berdasarkan status
          final filteredConsultations =
              consultations.where((c) => c.status == widget.status).toList();

          if (filteredConsultations.isEmpty) {
            return Center(
              child: Text(
                "Belum ada jadwal ${getStatusText(widget.status).toLowerCase()}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 30),
            itemCount: filteredConsultations.length,
            itemBuilder: (context, index) {
              final consultation = filteredConsultations[index];
              return FutureBuilder<PsychologistModel>(
                future: _getPsychologist(consultation.psychologistId),
                builder: (context, psychSnapshot) {
                  if (psychSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ScheduleCard(
                      confirmation: "Loading...",
                      mainText: "Memuat data...",
                      subText: "",
                      date: "",
                      time: "",
                      image: "lib/icons/male-doctor.png",
                    );
                  }

                  final psychologist = psychSnapshot.data ??
                      PsychologistModel(
                        id: consultation.psychologistId,
                        fullName: "Nama Psikolog",
                        licenseNumber: "",
                        available: true,
                        consultationFee: 0,
                        email: "",
                        specializations: ["Spesialisasi"],
                        description: "",
                        education: [],
                      );

                  // Gabungkan spesialisasi menjadi string
                  final specializations =
                      psychologist.specializations.join(", ");

                  return ScheduleCard(
                    confirmation: getStatusText(consultation.status),
                    mainText: psychologist.fullName,
                    subText: specializations,
                    date: _formatDate(consultation.scheduledTime),
                    time: _formatTime(consultation.scheduledTime),
                    // Tetap gunakan placeholder karena model tidak memiliki URL gambar
                    image: "lib/icons/male-doctor.png",
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $amPm';
  }
}
