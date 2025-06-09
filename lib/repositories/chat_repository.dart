import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyconnect/models/chat_message.dart';

abstract class ChatRepository {
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    bool isSystemMessage = false,
  });

  Stream<List<ChatMessage>> getMessagesStream(String userId, String receiverId);

  Future<void> markMessageAsSeen(String messageId);

  Future<void> deleteChatHistory(String userId, String receiverId);

  void dispose();
}

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  @override
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    bool isSystemMessage = false,
  }) async {
    try {
      final chatId = _getChatId(senderId, receiverId);
      final timestamp = FieldValue.serverTimestamp();

      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      await messageRef.set({
        'id': messageRef.id,
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp,
        'seen': false,
        'isSystemMessage': isSystemMessage,
      });

      await _updateChatMetadata(
          chatId, senderId, receiverId, message, timestamp);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> _updateChatMetadata(String chatId, String senderId,
      String receiverId, String lastMessage, FieldValue timestamp) async {
    await _firestore
        .collection('users')
        .doc(senderId)
        .collection('chats')
        .doc(receiverId)
        .set({
      'chatId': chatId,
      'userId': receiverId,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'unreadCount': 0,
    }, SetOptions(merge: true));

    final receiverChatRef = _firestore
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(senderId);
    final receiverChatDoc = await receiverChatRef.get();

    int unreadCount = 0;
    if (receiverChatDoc.exists) {
      unreadCount = (receiverChatDoc.data()?['unreadCount'] ?? 0) + 1;
    } else {
      unreadCount = 1;
    }

    await receiverChatRef.set({
      'chatId': chatId,
      'userId': senderId,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'unreadCount': unreadCount,
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(
      String userId, String receiverId) {
    final chatId = _getChatId(userId, receiverId);

    _resetUnreadCount(userId, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      _markReceivedMessagesAsSeen(snapshot, userId, receiverId);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'] != null
            ? (data['timestamp'] as Timestamp).toDate()
            : DateTime.now();

        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'],
          receiverId: data['receiverId'],
          message: data['message'],
          timestamp: timestamp,
          seen: data['seen'] ?? false,
          isSystemMessage: data['isSystemMessage'] ?? false,
        );
      }).toList();
    });
  }

  void _markReceivedMessagesAsSeen(
      QuerySnapshot snapshot, String userId, String receiverId) {
    final batch = _firestore.batch();
    bool hasBatchOperations = false;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['senderId'] == receiverId &&
          data['receiverId'] == userId &&
          data['seen'] != true) {
        batch.update(doc.reference, {'seen': true});
        hasBatchOperations = true;
      }
    }

    if (hasBatchOperations) {
      batch.commit().catchError((_) {});
    }
  }

  Future<void> _resetUnreadCount(String userId, String receiverId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(receiverId)
          .update({'unreadCount': 0});
    } catch (e) {}
  }

  @override
  Future<void> markMessageAsSeen(String messageId) async {}

  @override
  Future<void> deleteChatHistory(String userId, String receiverId) async {
    try {
      final chatId = _getChatId(userId, receiverId);

      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(receiverId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete chat history: $e');
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }
}
