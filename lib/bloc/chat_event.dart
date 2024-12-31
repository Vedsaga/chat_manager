part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final int chatId;
  LoadMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class NewMessageReceived extends ChatEvent {
  final Message message;
  NewMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class SendMessage extends ChatEvent {
  final int chatId;
  final String content;
  SendMessage(this.chatId, this.content);

  @override
  List<Object?> get props => [chatId, content];
}
