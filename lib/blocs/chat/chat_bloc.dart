import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:psyconnect/blocs/chat/chat_event.dart';
import 'package:psyconnect/blocs/chat/chat_state.dart';
import 'package:psyconnect/models/chat_message.dart';
import 'package:psyconnect/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessages>(_onReceiveMessages);
    on<StopListeningToMessages>(_onStopListeningToMessages);
    on<DeleteChatHistory>(_onDeleteChatHistory);
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    try {
      _messagesSubscription?.cancel();
      _messagesSubscription =
          repository.getMessagesStream(event.userId, event.receiverId).listen(
                (messages) => add(ReceiveMessages(messages)),
                onError: (error) => add(ChatErrorEvent(error.toString())),
              );
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      await repository.sendMessage(
        senderId: event.senderId,
        receiverId: event.receiverId,
        message: event.message,
        isSystemMessage: event.isSystemMessage ?? false,
      );
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void _onReceiveMessages(ReceiveMessages event, Emitter<ChatState> emit) {
    emit(ChatLoaded(event.messages));
  }

  void _onStopListeningToMessages(
      StopListeningToMessages event, Emitter<ChatState> emit) {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  void _onDeleteChatHistory(
      DeleteChatHistory event, Emitter<ChatState> emit) async {
    try {
      await repository.deleteChatHistory(event.userId, event.receiverId);
    } catch (e) {
      emit(ChatError('Failed to delete chat history: $e'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    repository.dispose();
    return super.close();
  }
}
