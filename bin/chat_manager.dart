
import 'package:chat_manager/chat_list_manager.dart';
import 'package:chat_manager/chat_thread.dart';

void main() {
  final manager = ChatListManager();

  // Load sample data
  final sampleData = [
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
      "successorId": null,
      "lastMessageAt": "2024-01-01T09:00:00Z",
      "lastMessageText": "Hi there",
      "isPinned": false
    }
  ];

  manager.loadFromJson(sampleData);

  // Print initial order
  print('Initial order:');
  print(manager.getOrderedChatList());

  // Add new message to chat 2
  manager.handleNewMessage(2, 'New message in chat 2');

  // Print new order
  print('\nOrder after new message:');
  print(manager.getOrderedChatList());

  // Add new chat
  final newChat = ChatThread(
      id: 3, lastMessageAt: DateTime.now(), lastMessageText: 'Brand new chat');
  manager.addNewChat(newChat);

  // Print final order
  print('\nOrder after adding new chat:');
  print(manager.getOrderedChatList());
}
