import 'dart:async';
import 'dart:math';

import 'package:chat_manager/lib.dart';

class MockServer implements ServerInterface {
  final _messageController = StreamController<Message>.broadcast();
  final _random = Random();
  int _messageIdCounter = 1000;

  @override
  Stream<Message> get messageStream => _messageController.stream;

  @override
  Future<List<Chat>> fetchChats({int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    // Generate mock chats
    return List.generate(
      5,
      (index) {
        final metadata = Metadata.create(index + 1);
        final message = Message(
          metadata: Metadata.create(_messageIdCounter++),
          chatId: metadata.id,
          content: 'Last message in chat ${metadata.id}',
          serverTimestamp: DateTime.now().subtract(Duration(minutes: index)),
          localTimestamp: DateTime.now().subtract(Duration(minutes: index)),
          serverSequence: index,
        );

        return Chat(metadata: metadata, lastMessage: message);
      },
    );
  }

  @override
  Future<List<Message>> fetchMessages(int chatId, {int limit = 50}) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    return List.generate(
      _random.nextInt(20),
      (index) => Message(
        metadata: Metadata.create(_messageIdCounter++),
        chatId: chatId,
        content: 'Message $index in chat $chatId',
        serverTimestamp: DateTime.now().subtract(Duration(minutes: index)),
        localTimestamp: DateTime.now().subtract(Duration(minutes: index)),
        serverSequence: index,
      ),
    );
  }

  @override
  Future<void> sendMessage(Message message) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
    _messageController.add(message);
  }

  // Start mock real-time updates
  void startMockUpdates() {
    Timer.periodic(Duration(seconds: 2 + _random.nextInt(3)), (_) {
      final chatId = _random.nextInt(5) + 1;
      final message = Message(
        metadata: Metadata.create(_messageIdCounter++),
        chatId: chatId,
        content: 'Real-time message ${DateTime.now()}',
        serverTimestamp: DateTime.now(),
        localTimestamp: DateTime.now(),
        serverSequence: _messageIdCounter,
      );
      _messageController.add(message);
    });
  }

  void dispose() {
    _messageController.close();
  }
}
