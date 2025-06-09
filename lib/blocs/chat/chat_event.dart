// Chat Events
import 'package:psyconnect/models/chat_message.dart';

abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final String userId;
  final String receiverId;

  LoadMessages(this.userId, this.receiverId);
}

class SendMessage extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String message;
  final bool? isSystemMessage;

  SendMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.isSystemMessage = false,
  });
}

class ReceiveMessages extends ChatEvent {
  final List<ChatMessage> messages;

  ReceiveMessages(this.messages);
}

class StopListeningToMessages extends ChatEvent {}

class DeleteChatHistory extends ChatEvent {
  final String userId;
  final String receiverId;

  DeleteChatHistory({
    required this.userId,
    required this.receiverId,
  });
}

class ChatErrorEvent extends ChatEvent {
  final String message;

  ChatErrorEvent(this.message);
}
