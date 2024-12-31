import 'package:chat_manager/lib.dart';

// lib/main.dart
void main() async {
  // Initialize components
  final server = MockServer();
  final database = MockDatabase();
  final repository = ChatRepository();

  final bloc = ChatBloc(
    server: server,
    database: database,
    repository: repository,
  );

  // Start mock real-time updates
  server.startMockUpdates();

  // Print formatted updates
  bloc.stream.listen((state) {
    print('\n${DateTime.now()} - Current State: ${state.runtimeType}');

    if (state is ChatsLoaded) {
      print('\nChats:');
      for (final chat in state.chats) {
        print('  Chat ${chat.metadata.id}: ${chat.lastMessage?.content}');
      }
    }

    if (state is MessagesLoaded) {
      print('\nChats:');
      for (final chat in state.chats) {
        print('  Chat ${chat.metadata.id}: ${chat.lastMessage?.content}');
      }

      print('\nMessages:');
      state.messages.forEach((chatId, messages) {
        print('  Chat $chatId:');
        for (final message in messages) {
          print('    ${message.content}');
        }
      });
    }
  });

  // Load initial data
  bloc.add(LoadChats());

  // Simulate user loading messages for chat 1
  await Future.delayed(Duration(seconds: 2));
  bloc.add(LoadMessages(1));

  // Simulate user sending a message
  await Future.delayed(Duration(seconds: 3));
  bloc.add(SendMessage(1, 'Hello from user!'));

  // Keep the program running
  await Future.delayed(Duration(seconds: 30));

  // Cleanup
  bloc.close();
  server.dispose();
  database.dispose();
  repository.dispose();
}
