import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_manager/lib.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ServerInterface server;
  final DatabaseInterface database;
  final ChatRepository repository;
  StreamSubscription? _serverSubscription;
  StreamSubscription? _databaseChatSubscription;
  StreamSubscription? _databaseMessageSubscription;

  ChatBloc({
    required this.server,
    required this.database,
    required this.repository,
  }) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<SendMessage>(_onSendMessage);

    // Listen to real-time updates
    _serverSubscription = server.messageStream.listen((message) {
      add(NewMessageReceived(message));
    });

    // Listen to database updates
    _databaseChatSubscription = database.chatStream.listen((chats) {
      if (isClosed) return;
      if (state is MessagesLoaded) {
        emit(MessagesLoaded(
          chats,
          (state as MessagesLoaded).messages,
        ));
      } else {
        emit(ChatsLoaded(chats));
      }
    });

    _databaseMessageSubscription = database.messageStream.listen((messages) {
      if (isClosed) return;
      if (state is MessagesLoaded) {
        emit(MessagesLoaded(
          (state as MessagesLoaded).chats,
          messages,
        ));
      }
    });
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatsLoading());
      final chats = await server.fetchChats();
      await database.saveChats(chats);

      for (final chat in chats) {
        repository.updateChat(chat);
      }

      emit(ChatsLoaded(repository.getOrderedChats()));
    } catch (e) {
      emit(ChatError('Failed to load chats: $e'));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentChats = repository.getOrderedChats();
      emit(MessagesLoading(currentChats));

      final messages = await server.fetchMessages(event.chatId);
      await database.saveMessages(messages);

      for (final message in messages) {
        repository.addMessage(message);
      }

      if (state is MessagesLoading) {
        final allMessages = await database.getChatMessages(event.chatId);
        emit(MessagesLoaded(
          currentChats,
          {event.chatId: allMessages},
        ));
      }
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await database.saveMessage(event.message);
      repository.addMessage(event.message);
    } catch (e) {
      emit(ChatError('Failed to process new message: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = Message(
        metadata: Metadata.create(_getNextMessageId()),
        chatId: event.chatId,
        content: event.content,
        serverTimestamp: DateTime.now(),
        localTimestamp: DateTime.now(),
        serverSequence: repository.getLastSequence(event.chatId) + 1,
        isLocal: true,
      );

      // Save locally first
      await database.saveMessage(message);
      repository.addMessage(message);

      // Send to server
      await server.sendMessage(message);
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  int _getNextMessageId() {
    // In real app, this would be handled by the server
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<void> close() {
    _serverSubscription?.cancel();
    _databaseChatSubscription?.cancel();
    _databaseMessageSubscription?.cancel();
    return super.close();
  }
}
