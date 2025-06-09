import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isSeen;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSeen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMessageContainer(context),
        ],
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.7;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? bluePrimaryColor : whiteSecondaryColor,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomRight: isMe ? const Radius.circular(0) : null,
          bottomLeft: !isMe ? const Radius.circular(0) : null,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(message.timestamp);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          formattedTime,
          style: TextStyle(
            color: isMe ? Colors.white70 : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            isSeen ? Icons.done_all : Icons.check,
            size: 14,
            color: isSeen ? Colors.blue[100] : Colors.white70,
          ),
        ],
      ],
    );
  }
}
