import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  List<Map<String, String>> messages = [];

  void connect(String roomId) {
    socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket.on('connect', (_) {
      socket.emit('join-room', roomId);
    });

    socket.on('receive-message', (data) {
      // Handle received message
    });
  }

  void sendMessage(String roomId, String senderId, String message) {
    final data = {
      'roomId': roomId,
      'senderId': senderId,
      'message': message,
    };

    socket.emit('send-message', data);
    messages.add({
      'senderId': senderId,
      'message': message,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
