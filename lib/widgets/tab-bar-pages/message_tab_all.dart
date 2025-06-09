import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:psyconnect/blocs/consultation/consultation_bloc.dart';
import 'package:psyconnect/models/consultation_model.dart';

class MessageTabAllClient extends StatefulWidget {
  const MessageTabAllClient({super.key});

  @override
  State<MessageTabAllClient> createState() => _MessageTabAllClientState();
}

class _MessageTabAllClientState extends State<MessageTabAllClient>
    with WidgetsBindingObserver {
  // Map to store psychologist data
  final Map<String, Map<String, dynamic>> _psychologistData = {};
  bool _isLoadingPsychologists = false;

  // Example messages for preview (you should replace with actual last messages)
  final Map<String, String> _lastMessages = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConsultations();

    // Add some sample last messages for demo (remove this in production)
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    // Remove this in production - just for demo
    _lastMessages['psych1'] = 'Bagaimana kabar Anda hari ini?';
    _lastMessages['psych2'] = 'Jangan lupa untuk sesi kita besok pagi.';
    _lastMessages['psych3'] = 'Terima kasih atas sesi yang produktif!';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadConsultations();
    }
  }

  void _loadConsultations() {
    context.read<ConsultationBloc>().add(LoadClientConsultations());
  }

  // Fetch psychologist profile data from API
  Future<Map<String, dynamic>> _fetchPsychologistData(
      String psychologistId) async {
    // Check if we already have fetched this psychologist's data
    if (_psychologistData.containsKey(psychologistId)) {
      return _psychologistData[psychologistId]!;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://psy-backend-production.up.railway.app/api/v1/psychologists/$psychologistId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profileData = {
          'full_name': data['full_name'] ?? 'Psikolog',
          'profile_image':
              data['profile_image'] ?? 'images/doctor1.png', // Default image
        };

        // Cache the data
        _psychologistData[psychologistId] = profileData;
        return profileData;
      } else {
        // If the server returns an error
        return {
          'full_name': 'Psikolog',
          'profile_image': 'images/doctor1.png' // Default image
        };
      }
    } catch (e) {
      // If there's a network error
      print('Error fetching psychologist data: $e');
      return {
        'full_name': 'Psikolog',
        'profile_image': 'images/doctor1.png' // Default image
      };
    }
  }

  // Fetch all psychologist data for the consultations at once
  Future<void> _fetchAllPsychologistData(
      List<Consultation> consultations) async {
    if (_isLoadingPsychologists) return;

    setState(() {
      _isLoadingPsychologists = true;
    });

    try {
      for (var consultation in consultations) {
        if (!_psychologistData.containsKey(consultation.psychologistId)) {
          await _fetchPsychologistData(consultation.psychologistId);
        }
      }
    } finally {
      setState(() {
        _isLoadingPsychologists = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Pesan', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 2,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<ConsultationBloc, ConsultationState>(
      listener: (context, state) {
        if (state is ConsultationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        // When consultations are loaded, fetch all psychologist data
        if (state is ClientConsultationsLoaded) {
          _fetchAllPsychologistData(state.consultations);
        }
      },
      builder: (context, state) {
        if (state is ConsultationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ClientConsultationsLoaded) {
          return _buildChatList(state.consultations);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildChatList(List<Consultation> consultations) {
    if (consultations.isEmpty) return _buildEmptyState();

    // Group consultations by psychologist
    final Map<String, Consultation> latestConsultations = {};

    // Find the latest consultation for each psychologist
    for (var consultation in consultations) {
      final String psychId = consultation.psychologistId;
      if (!latestConsultations.containsKey(psychId) ||
          latestConsultations[psychId]!
              .scheduledTime
              .isBefore(consultation.scheduledTime)) {
        latestConsultations[psychId] = consultation;
      }
    }

    final psychologists = latestConsultations.keys.toList();

    return RefreshIndicator(
      onRefresh: () async => _loadConsultations(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: psychologists.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final psychId = psychologists[index];
          return _buildChatItem(psychId, latestConsultations[psychId]!);
        },
      ),
    );
  }

  Widget _buildChatItem(String psychologistId, Consultation consultation) {
    final data = _psychologistData[psychologistId];
    final String displayName = data?['full_name'] ?? 'Memuat...';
    final String profileImage = data?['profile_image'] ?? 'images/doctor1.png';
    final String lastMessage =
        _lastMessages[psychologistId] ?? 'Belum ada pesan';
    final bool active = consultation.status == 'confirmed';

    // Format the date for display
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = consultation.scheduledTime;
    final messageDay =
        DateTime(messageDate.year, messageDate.month, messageDate.day);

    String timeDisplay;
    if (messageDay == today) {
      // Show time for today's messages
      timeDisplay = DateFormat('HH:mm').format(messageDate);
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      // Show "Kemarin" for yesterday's messages
      timeDisplay = 'Kemarin';
    } else if (today.difference(messageDay).inDays < 7) {
      // Show day name for messages within the last week
      timeDisplay = DateFormat('EEEE', 'id_ID').format(messageDate);
    } else {
      // Show date for older messages
      timeDisplay = DateFormat('dd/MM/yy').format(messageDate);
    }

    return InkWell(
      onTap: () => _navigateToChat(psychologistId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(
                      profileImage), // Use network image in production
                ),
                if (active)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Chat content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesan',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadwalkan konsultasi untuk memulai percakapan',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(String psychologistId) {
    print('Navigating to chat with $psychologistId');
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'receiverId': psychologistId},
    );
  }
}
