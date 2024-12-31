import 'package:chat_manager/lib.dart';

abstract class ServerInterface {
  Future<List<Chat>> fetchChats({int limit = 20});
  Future<List<Message>> fetchMessages(int chatId, {int limit = 50});
  Stream<Message> get messageStream;
  Future<void> sendMessage(Message message);
}
