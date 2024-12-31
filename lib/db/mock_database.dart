import 'dart:async';

import 'package:chat_manager/lib.dart';

class MockDatabase implements DatabaseInterface {
  final Map<int, Chat> _chats = {};
  final Map<int, List<Message>> _messages = {};

  final _chatController = StreamController<List<Chat>>.broadcast();
  final _messageController =
      StreamController<Map<int, List<Message>>>.broadcast();

  @override
  Stream<List<Chat>> get chatStream => _chatController.stream;

  @override
  Stream<Map<int, List<Message>>> get messageStream =>
      _messageController.stream;

  @override
  Future<void> saveChat(Chat chat) async {
    await Future.delayed(Duration(milliseconds: 100)); // Simulate disk write
    _chats[chat.metadata.id] = chat;
    _notifyChatsUpdate();
  }

  @override
  Future<void> saveChats(List<Chat> chats) async {
    await Future.delayed(Duration(milliseconds: 100));
    for (final chat in chats) {
      _chats[chat.metadata.id] = chat;
    }
    _notifyChatsUpdate();
  }

  @override
  Future<Chat?> getChat(int id) async {
    await Future.delayed(Duration(milliseconds: 50));
    return _chats[id];
  }

  @override
  Future<List<Chat>> getAllChats() async {
    await Future.delayed(Duration(milliseconds: 50));
    return _chats.values.toList();
  }

  @override
  Future<void> saveMessage(Message message) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (!_messages.containsKey(message.chatId)) {
      _messages[message.chatId] = [];
    }
    _messages[message.chatId]!.add(message);
    _notifyMessagesUpdate();
  }

  @override
  Future<void> saveMessages(List<Message> messages) async {
    await Future.delayed(Duration(milliseconds: 100));
    for (final message in messages) {
      if (!_messages.containsKey(message.chatId)) {
        _messages[message.chatId] = [];
      }
      _messages[message.chatId]!.add(message);
    }
    _notifyMessagesUpdate();
  }

  @override
  Future<List<Message>> getChatMessages(int chatId) async {
    await Future.delayed(Duration(milliseconds: 50));
    return _messages[chatId] ?? [];
  }

  void _notifyChatsUpdate() {
    _chatController.add(_chats.values.toList());
  }

  void _notifyMessagesUpdate() {
    _messageController.add(Map.from(_messages));
  }

  void dispose() {
    _chatController.close();
    _messageController.close();
  }
}
