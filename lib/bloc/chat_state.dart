part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatsLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<Chat> chats;
  ChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class MessagesLoading extends ChatState {
  final List<Chat> chats; // Keep current chats while loading messages
  MessagesLoading(this.chats);

  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends ChatState {
  final List<Chat> chats;
  final Map<int, List<Message>> messages;
  MessagesLoaded(this.chats, this.messages);

  @override
  List<Object?> get props => [chats, messages];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
