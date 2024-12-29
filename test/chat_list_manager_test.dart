import 'package:chat_manager/chat_list_manager.dart';
import 'package:chat_manager/chat_thread.dart';
import 'package:test/test.dart';

void main() {
  late ChatListManager manager;

  // Sample JSON data
  final sampleJsonData = [
    {
      "id": 1,
      "predecessorId": null,
      "successorId": 2,
      "lastMessageAt": "2024-01-01T10:00:00Z",
      "lastMessageText": "Hello",
      "isPinned": false
    },
    {
      "id": 2,
      "predecessorId": 1,
      "successorId": 3,
      "lastMessageAt": "2024-01-01T09:00:00Z",
      "lastMessageText": "Hi there",
      "isPinned": false
    },
    {
      "id": 3,
      "predecessorId": 2,
      "successorId": null,
      "lastMessageAt": "2024-01-01T08:00:00Z",
      "lastMessageText": "Good morning",
      "isPinned": false
    }
  ];

  setUp(() {
    manager = ChatListManager();
  });

  test('Load from JSON', () {
    manager.loadFromJson(sampleJsonData);
    expect(manager.firstChatId, equals(1));
    expect(manager.lastChatId, equals(3));
    expect(manager.chatThreads.length, equals(3));
  });

  test('Add new chat', () {
    final newChat = ChatThread(
        id: 4, lastMessageAt: DateTime.now(), lastMessageText: 'New chat');

    manager.loadFromJson(sampleJsonData);
    manager.addNewChat(newChat);

    expect(manager.firstChatId, equals(4));
    expect(manager.chatThreads[4]?.successorId, equals(1));
  });

  test('Move chat to top', () {
    manager.loadFromJson(sampleJsonData);
    manager.moveToTop(3);

    final orderedList = manager.getOrderedChatList();
    expect(orderedList.first.id, equals(3));
    expect(orderedList.last.id, equals(2));
  });

  test('Handle new message', () {
    manager.loadFromJson(sampleJsonData);
    manager.handleNewMessage(2, 'Updated message');

    final orderedList = manager.getOrderedChatList();
    expect(orderedList.first.id, equals(2));
    expect(orderedList.first.lastMessageText, equals('Updated message'));
  });

  test('Get ordered chat list', () {
    manager.loadFromJson(sampleJsonData);
    final orderedList = manager.getOrderedChatList();

    expect(orderedList.map((c) => c.id).toList(), equals([1, 2, 3]));
  });
}
