// lib/repository/chat_repository.dart
import 'dart:async';

import 'package:chat_manager/lib.dart';



class ChatRepository {
  // In-memory storage
  final Map<int, Chat> _chats = {};
  final Map<int, List<Message>> _messages = {};
  final Map<int, int> _lastSequencePerChat = {};
  int? _firstChatId;
  int? _lastChatId;

  // Stream controllers
  final _chatController = StreamController<List<Chat>>.broadcast();
  final _messageController =
      StreamController<Map<int, List<Message>>>.broadcast();

  // Streams
  Stream<List<Chat>> get chatsStream => _chatController.stream;
  Stream<Map<int, List<Message>>> get messagesStream =>
      _messageController.stream;

  // Get ordered chat list
  List<Chat> getOrderedChats() {
    List<Chat> orderedList = [];
    int? currentId = _firstChatId;

    while (currentId != null) {
      final currentChat = _chats[currentId];
      if (currentChat != null) {
        orderedList.add(currentChat);
        currentId = currentChat.successorId;
      } else {
        break;
      }
    }

    return orderedList;
  }

  // Get messages for a specific chat
  List<Message> getChatMessages(int chatId) {
    return _messages[chatId] ?? [];
  }

  // Add or update chat
  void updateChat(Chat chat) {
    bool isNew = !_chats.containsKey(chat.metadata.id);
    _chats[chat.metadata.id] = chat;

    if (isNew && _firstChatId != chat.metadata.id) {
      _addToChain(chat);
    }

    _notifyChatsUpdate();
  }

  // Add new message
  void addMessage(Message message) {
    if (!_messages.containsKey(message.chatId)) {
      _messages[message.chatId] = [];
    }

    final chatMessages = _messages[message.chatId]!;
    if (chatMessages.isNotEmpty) {
      final lastMessage = chatMessages.last;
      _messages[message.chatId]![chatMessages.length - 1] =
          lastMessage.copyWith(nextMessageId: message.metadata.id);
    }

    chatMessages.add(message);
    _lastSequencePerChat[message.chatId] = message.serverSequence;

    _updateChatWithMessage(message);
    _notifyMessagesUpdate();
  }

  void _addToChain(Chat chat) {
    if (_firstChatId == null) {
      _firstChatId = chat.metadata.id;
      _lastChatId = chat.metadata.id;
    } else {
      final firstChat = _chats[_firstChatId]!;
      _chats[_firstChatId!] =
          firstChat.copyWith(predecessorId: chat.metadata.id);
      _chats[chat.metadata.id] = chat.copyWith(successorId: _firstChatId);
      _firstChatId = chat.metadata.id;
    }
  }

  void _updateChatWithMessage(Message message) {
    final chat = _chats[message.chatId];
    if (chat != null) {
      _chats[message.chatId] =
          chat.copyWith(lastMessage: message, hasUnreadMessages: true);

      if (!message.isLocal && !chat.isPinned) {
        _moveToTop(message.chatId);
      }
    }
  }

  void _moveToTop(int chatId) {
    if (_firstChatId == chatId) return;

    final chat = _chats[chatId]!;
    final previousChat =
        chat.predecessorId != null ? _chats[chat.predecessorId] : null;
    final nextChat = chat.successorId != null ? _chats[chat.successorId] : null;

    if (previousChat != null) {
      _chats[previousChat.metadata.id] =
          previousChat.copyWith(successorId: chat.successorId);
    }
    if (nextChat != null) {
      _chats[nextChat.metadata.id] =
          nextChat.copyWith(predecessorId: chat.predecessorId);
    }

    if (_lastChatId == chatId) {
      _lastChatId = chat.predecessorId;
    }

    final oldFirstChat = _chats[_firstChatId]!;
    _chats[_firstChatId!] = oldFirstChat.copyWith(predecessorId: chatId);
    _chats[chatId] =
        chat.copyWith(predecessorId: null, successorId: _firstChatId);
    _firstChatId = chatId;
  }

  void _notifyChatsUpdate() {
    _chatController.add(getOrderedChats());
  }

  void _notifyMessagesUpdate() {
    _messageController.add(Map.from(_messages));
  }

  // Mark chat as read
  void markChatAsRead(int chatId) {
    final chat = _chats[chatId];
    if (chat != null && chat.hasUnreadMessages) {
      _chats[chatId] = chat.copyWith(hasUnreadMessages: false);
      _notifyChatsUpdate();
    }
  }

  // Get last sequence number for a chat
  int getLastSequence(int chatId) {
    return _lastSequencePerChat[chatId] ?? 0;
  }

  void dispose() {
    _chatController.close();
    _messageController.close();
  }
}
