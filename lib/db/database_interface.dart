import 'package:chat_manager/lib.dart';

abstract class DatabaseInterface {
  // Chat operations
  Future<void> saveChat(Chat chat);
  Future<void> saveChats(List<Chat> chats);
  Future<Chat?> getChat(int id);
  Future<List<Chat>> getAllChats();
  Stream<List<Chat>> get chatStream;

  // Message operations
  Future<void> saveMessage(Message message);
  Future<void> saveMessages(List<Message> messages);
  Future<List<Message>> getChatMessages(int chatId);
  Stream<Map<int, List<Message>>> get messageStream;
}
