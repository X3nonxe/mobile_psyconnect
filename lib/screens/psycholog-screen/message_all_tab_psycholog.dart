import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:psyconnect/blocs/consultation/consultation_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:psyconnect/screens/chat-screen/chat_screen.dart';
import 'package:psyconnect/models/consultation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageTabAllPsycholog extends StatefulWidget {
  const MessageTabAllPsycholog({super.key});

  @override
  State<MessageTabAllPsycholog> createState() => _MessageTabAllPsychologState();
}

class _MessageTabAllPsychologState extends State<MessageTabAllPsycholog>
    with WidgetsBindingObserver {
  // Map to store client data
  final Map<String, Map<String, dynamic>> _clientData = {};
  bool _isLoadingClients = false;

  // Map to store the latest message and unread count for each client
  final Map<String, String> _lastMessages = {};
  final Map<String, int> _unreadCounts = {};
  final Map<String, DateTime> _lastMessageTimes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConsultations();
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
    context.read<ConsultationBloc>().add(LoadConsultations());
  }

  // Fetch client profile data from API
  Future<Map<String, dynamic>> _fetchClientData(String clientId) async {
    // Check if we already have fetched this client's data
    if (_clientData.containsKey(clientId)) {
      return _clientData[clientId]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('https://psy-backend-production.up.railway.app/api/v1/clients/$clientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Client data: $data');
        final profileData = {
          'full_name': data['full_name'] ?? 'Klien',
          'profile_image':
              data['profile_image'] ?? 'lib/icons/default_profile.png',
        };

        // Cache the data
        _clientData[clientId] = profileData;
        return profileData;
      } else {
        // If the server returns an error
        return {
          'full_name': 'Klien $clientId',
          'profile_image': 'lib/icons/male-doctor.png'
        };
      }
    } catch (e) {
      // If there's a network error
      print('Error fetching client data: $e');
      return {
        'full_name': 'Klien $clientId',
        'profile_image': 'lib/icons/male-doctor.png'
      };
    }
  }

  // Fetch all client data for the consultations at once
  Future<void> _fetchAllClientData(List<Consultation> consultations) async {
    if (_isLoadingClients) return;

    setState(() {
      _isLoadingClients = true;
    });

    try {
      // Get unique client IDs
      final clientIds = consultations.map((c) => c.clientId).toSet().toList();

      for (var clientId in clientIds) {
        if (!_clientData.containsKey(clientId)) {
          await _fetchClientData(clientId);
        }
      }

      // You would also fetch message data here in a real application
      await _fetchMessageData(clientIds);
    } finally {
      setState(() {
        _isLoadingClients = false;
      });
    }
  }

  // Fetch message data for all clients
  Future<void> _fetchMessageData(List<String> clientIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      for (var clientId in clientIds) {
        // In a real app, you would get this from your message API
        // This is just a placeholder - replace with your actual API call

        try {
          final response = await http.get(
            Uri.parse(
                'http://172.22.56.81:3000/api/v1/messages/last/$clientId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            setState(() {
              _lastMessages[clientId] = data['content'] ?? 'Belum ada pesan';
              _unreadCounts[clientId] = data['unread_count'] ?? 0;
              _lastMessageTimes[clientId] =
                  DateTime.tryParse(data['created_at']) ?? DateTime.now();
            });
          } else {
            // For demo, set default values if the API fails
            setState(() {
              _lastMessages[clientId] = 'Belum ada pesan';
              _unreadCounts[clientId] = 0;
              _lastMessageTimes[clientId] = DateTime.now();
            });
          }
        } catch (e) {
          print('Error fetching message data: $e');
          // Set default values
          setState(() {
            _lastMessages[clientId] = 'Belum ada pesan';
            _unreadCounts[clientId] = 0;
            _lastMessageTimes[clientId] = DateTime.now();
          });
        }
      }
    } catch (e) {
      print('Error in _fetchMessageData: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Konsultasi dengan Klien",
            style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16.sp),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("lib/icons/bell.png"),
              )),
            ),
          ),
        ],
        backgroundColor: Colors.white,
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

        // When consultations are loaded, fetch all client data
        if (state is ConsultationLoaded) {
          _fetchAllClientData(state.consultations);
        }
      },
      builder: (context, state) {
        if (state is ConsultationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ConsultationLoaded) {
          return _buildChatList(state.consultations);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildChatList(List<Consultation> consultations) {
    if (consultations.isEmpty) return _buildEmptyState();

    // Group consultations by client
    final Map<String, Consultation> latestConsultations = {};

    // Find the latest consultation for each client
    for (var consultation in consultations) {
      final String clientId = consultation.clientId;
      if (!latestConsultations.containsKey(clientId) ||
          latestConsultations[clientId]!
              .scheduledTime
              .isBefore(consultation.scheduledTime)) {
        latestConsultations[clientId] = consultation;
      }
    }

    final clients = latestConsultations.keys.toList();

    return RefreshIndicator(
      onRefresh: () async => _loadConsultations(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: clients.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final clientId = clients[index];
          return _buildChatItem(clientId, latestConsultations[clientId]!);
        },
      ),
    );
  }

  Widget _buildChatItem(String clientId, Consultation consultation) {
    final data = _clientData[clientId];
    final String displayName = data?['full_name'] ?? 'Memuat...';
    final String profileImage =
        data?['profile_image'] ?? 'lib/icons/male-doctor.png';
    final String lastMessage = _lastMessages[clientId] ?? 'Belum ada pesan';
    final int unreadCount = _unreadCounts[clientId] ?? 0;
    final bool active = consultation.status == 'confirmed';

    // Get message date from state or use consultation date as fallback
    final DateTime messageDate =
        _lastMessageTimes[clientId] ?? consultation.scheduledTime;

    // Format the date for display
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
      onTap: () => _navigateToChat(clientId),
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
                  backgroundImage: AssetImage(profileImage),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            color: unreadCount > 0
                                ? Colors.black
                                : Colors.grey[600],
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
            'Anda akan melihat pesan dari klien di sini',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(String clientId) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: ChatScreen(receiverId: clientId),
      ),
    );
  }
}
