import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psyconnect/blocs/chat/chat_bloc.dart';
import 'package:psyconnect/blocs/chat/chat_event.dart';
import 'package:psyconnect/blocs/chat/chat_state.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/repositories/chat_repository.dart';
import 'package:psyconnect/widgets/chat_bubble.dart';
import 'package:psyconnect/widgets/chat_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:psyconnect/utils/chat_session_manager.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatBloc _chatBloc;
  String _senderId = '';
  String _receiverName = 'Chat';
  String _userRole = '';
  bool _isLoading = true;

  ChatSessionManager? _sessionManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sessionManager = ChatSessionManager(
      sessionDuration: const Duration(minutes: 60),
      onSessionEnd: _handleSessionEnd,
      onWarningTime: _showTimeWarning,
      senderId: _senderId,
      receiverId: widget.receiverId,
    );

    _initChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatBloc.add(StopListeningToMessages());
    _sessionManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_senderId.isNotEmpty) {
        _chatBloc.add(LoadMessages(_senderId, widget.receiverId));
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _chatBloc.add(StopListeningToMessages());
    }
  }

  void _handleSessionEnd() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi konsultasi telah berakhir'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showTimeWarning() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi konsultasi akan berakhir dalam 5 menit'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _initChat() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id') ?? '';
      final role = prefs.getString('role') ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID not found');
      }

      setState(() {
        _senderId = userId;
        _userRole = role;
      });

      _sessionManager?.dispose();
      _sessionManager = ChatSessionManager(
        senderId: _senderId,
        receiverId: widget.receiverId,
        sessionDuration: const Duration(minutes: 60),
        onSessionEnd: _handleSessionEnd,
        onWarningTime: _showTimeWarning,
      );

      _chatBloc = ChatBloc(
        repository: ChatRepositoryImpl(),
      );

      _chatBloc.add(LoadMessages(_senderId, widget.receiverId));

      await _fetchReceiverDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReceiverDetails() async {
    try {
      final endpoint = _userRole == 'psychologist'
          ? 'clients/${widget.receiverId}'
          : 'psychologists/${widget.receiverId}';

      final response = await http.get(
        Uri.parse('https://psy-backend-production.up.railway.app/api/v1/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body));
        setState(() {
          _receiverName = data['full_name'] ?? 'Chat';
        });
      }
    } catch (e) {
      debugPrint('Error fetching receiver details: $e');
    }
  }

  void _startSession() {
    _sessionManager?.startSession();

    _chatBloc.add(SendMessage(
      senderId: _senderId,
      receiverId: widget.receiverId,
      message: "Sesi konsultasi dimulai",
      isSystemMessage: true,
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_senderId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Silakan login terlebih dahulu',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _sessionManager!,
      child: BlocProvider.value(
        value: _chatBloc,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              if (_userRole == 'psychologist') _buildSessionControlPanel(),
              _buildSessionTimerDisplay(),
              Expanded(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (state is ChatError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatLoaded) {
                      return _buildMessageList(state);
                    } else if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatError) {
                      return _buildErrorView(state.message);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Consumer<ChatSessionManager>(
                builder: (context, sessionManager, _) {
                  final canSendMessages =
                      _userRole == 'psychologist' || sessionManager.isActive;

                  if (sessionManager.isEnded) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: const Text(
                        'Sesi konsultasi telah berakhir',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  if (_userRole == 'client' && !sessionManager.isActive) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: const Text(
                        'Menunggu psikolog memulai sesi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ChatInput(
                    senderId: _senderId,
                    receiverId: widget.receiverId,
                    enabled: canSendMessages,
                    onSendMessage: (message) {
                      if (canSendMessages && !sessionManager.isEnded) {
                        _chatBloc.add(SendMessage(
                          senderId: _senderId,
                          receiverId: widget.receiverId,
                          message: message,
                        ));
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionControlPanel() {
    return Consumer<ChatSessionManager>(
      builder: (context, sessionManager, _) {
        return Container(
          decoration: BoxDecoration(
            color: whiteSecondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              if (sessionManager.isEnded)
                _buildSessionStatus(
                  "Sesi konsultasi telah berakhir",
                  Colors.orange,
                  resetAction: () => sessionManager.resetSession(),
                )
              else if (sessionManager.isActive)
                _buildSessionStatus(
                  "Sesi konsultasi berlangsung",
                  Colors.green,
                  endAction: () => sessionManager.endSession(),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _startSession,
                      child: const Text(
                        'Mulai Konsultasi',
                        style: TextStyle(
                          color: bluePrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Setiap sesi konsultasi akan berlangsung selama 60 menit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionStatus(
    String text,
    Color color, {
    VoidCallback? endAction,
    VoidCallback? resetAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (endAction != null)
            TextButton(
              onPressed: endAction,
              child: Text(
                'Akhiri Sesi',
                style: TextStyle(color: color),
              ),
            )
          else if (resetAction != null)
            ElevatedButton(
              onPressed: resetAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset Sesi'),
            )
        ],
      ),
    );
  }

  Widget _buildSessionTimerDisplay() {
    return Consumer<ChatSessionManager>(
      builder: (context, sessionManager, _) {
        if (sessionManager.isNotStarted) {
          return const SizedBox.shrink();
        }

        Color timerColor = Colors.green;

        if (sessionManager.remainingTime.inMinutes < 5) {
          timerColor = Colors.red;
        } else if (sessionManager.remainingTime.inMinutes < 10) {
          timerColor = Colors.orange;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer),
              const SizedBox(width: 8),
              Text(
                'Sisa waktu: ${sessionManager.formattedRemainingTime}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_receiverName),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            _showChatInfo();
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(ChatLoaded state) {
    if (state.messages.isEmpty) {
      return _buildEmptyChat();
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMe = message.senderId == _senderId;

        if (message.isSystemMessage == true) {
          return _buildSystemMessage(message.message, message.timestamp);
        }

        final showDateHeader = index == state.messages.length - 1 ||
            !_isSameDay(state.messages[index].timestamp,
                state.messages[index + 1].timestamp);

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.timestamp),
            ChatBubble(
              message: message,
              isMe: isMe,
              isSeen: message.seen,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSystemMessage(String message, DateTime timestamp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[800],
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String headerText;
    if (messageDate == today) {
      headerText = 'Hari ini';
    } else if (messageDate == yesterday) {
      headerText = 'Kemarin';
    } else {
      headerText = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          headerText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Consumer<ChatSessionManager>(
            builder: (context, sessionManager, _) {
              if (_userRole == 'psychologist' && sessionManager.isNotStarted) {
                return Text(
                  'Mulai konsultasi dengan klik tombol "Mulai Konsultasi"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                );
              } else if (_userRole == 'client' && sessionManager.isNotStarted) {
                return Text(
                  'Menunggu psikolog memulai sesi konsultasi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                );
              } else {
                return Text(
                  'Mulai percakapan dengan mengirim pesan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initChat,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  void _showChatInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _receiverName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Hapus riwayat chat'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Laporkan masalah'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus riwayat chat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus seluruh riwayat chat? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _chatBloc.add(DeleteChatHistory(
                userId: _senderId,
                receiverId: widget.receiverId,
              ));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
