import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatSessionManager extends ChangeNotifier {
  final String _senderId;
  final String _receiverId;
  final FirebaseFirestore _db;

  Duration _sessionDuration;
  DateTime? _sessionStartTime;
  DateTime? _sessionEndTime;
  Timer? _sessionTimer;
  Timer? _warningTimer;
  StreamSubscription? _sessionStreamSubscription;

  final VoidCallback onSessionEnd;
  final VoidCallback onWarningTime;

  bool get isNotStarted => _sessionStartTime == null && _sessionEndTime == null;
  bool get isActive => _sessionStartTime != null && _sessionEndTime == null;
  bool get isEnded => _sessionEndTime != null;

  Duration get remainingTime {
    if (!isActive) return Duration.zero;
    final now = DateTime.now();
    final endTime = _sessionStartTime!.add(_sessionDuration);
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  String get formattedRemainingTime {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Duration get sessionDuration => _sessionDuration;

  ChatSessionManager({
    required String senderId,
    required String receiverId,
    required Duration sessionDuration,
    required this.onSessionEnd,
    required this.onWarningTime,
    FirebaseFirestore? firestore,
  })  : _senderId = senderId,
        _receiverId = receiverId,
        _sessionDuration = sessionDuration,
        _db = firestore ?? FirebaseFirestore.instance {
    _listenToSessionChanges();
  }

  String get _sessionDocId {
    final sortedIds = [_senderId, _receiverId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void _listenToSessionChanges() {
    try {
      _sessionStreamSubscription?.cancel();
      _sessionStreamSubscription = _db
          .collection('sessions')
          .doc(_sessionDocId)
          .snapshots()
          .listen((docSnapshot) {
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          if (data['isActive'] == true) {
            if (!isActive) {
              _sessionStartTime = (data['startTime'] as Timestamp).toDate();
              _sessionDuration =
                  Duration(minutes: data['durationMinutes'] ?? 60);
              _sessionEndTime = null;
              _setTimers();
              notifyListeners();
            }
          } else if (data['isEnded'] == true) {
            if (!isEnded) {
              _sessionEndTime = (data['endTime'] as Timestamp).toDate();
              _sessionTimer?.cancel();
              _warningTimer?.cancel();
              onSessionEnd();
              notifyListeners();
            }
          }
        }
      }, onError: (error) {});
    } catch (e) {}
  }

  void _setTimers() {
    if (!isActive) return;
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    final now = DateTime.now();
    final sessionEndTime = _sessionStartTime!.add(_sessionDuration);
    final remainingDuration = sessionEndTime.difference(now);
    if (remainingDuration.inSeconds <= 0) {
      endSession();
      return;
    }
    _sessionTimer = Timer(remainingDuration, endSession);
    final warningTimeRemaining = remainingDuration - const Duration(minutes: 5);
    if (warningTimeRemaining.inSeconds > 0) {
      _warningTimer = Timer(warningTimeRemaining, onWarningTime);
    }
  }

  Future<void> startSession() async {
    try {
      final now = DateTime.now();
      _sessionStartTime = now;
      _sessionEndTime = null;
      _setTimers();
      await _db.collection('sessions').doc(_sessionDocId).set({
        'startTime': Timestamp.fromDate(now),
        'durationMinutes': _sessionDuration.inMinutes,
        'isActive': true,
        'isEnded': false,
        'psychologistId': _senderId,
        'clientId': _receiverId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {}
  }

  Future<void> endSession() async {
    try {
      final now = DateTime.now();
      _sessionEndTime = now;
      _sessionTimer?.cancel();
      _warningTimer?.cancel();
      await _db.collection('sessions').doc(_sessionDocId).update({
        'endTime': Timestamp.fromDate(now),
        'isActive': false,
        'isEnded': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      onSessionEnd();
      notifyListeners();
    } catch (e) {}
  }

  Future<void> resetSession() async {
    try {
      _sessionStartTime = null;
      _sessionEndTime = null;
      _sessionTimer?.cancel();
      _warningTimer?.cancel();
      await _db.collection('sessions').doc(_sessionDocId).update({
        'isActive': false,
        'isEnded': false,
        'resetAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {}
  }

  void updateSessionDuration(Duration duration) {
    _sessionDuration = duration;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _sessionStreamSubscription?.cancel();
    super.dispose();
  }
}
