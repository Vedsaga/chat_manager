import 'package:chat_manager/lib.dart';
import 'package:equatable/equatable.dart';
class Message extends Equatable {
  final Metadata metadata;
  final int chatId;
  final String content;
  final DateTime serverTimestamp;
  final DateTime localTimestamp;
  final int? nextMessageId;
  final int serverSequence;
  final bool isLocal;

  const Message({
    required this.metadata,
    required this.chatId,
    required this.content,
    required this.serverTimestamp,
    required this.localTimestamp,
    this.nextMessageId,
    required this.serverSequence,
    this.isLocal = false,
  });

  Message copyWith({
    DateTime? serverTimestamp,
    DateTime? localTimestamp,
    int? nextMessageId,
    bool? isLocal,
  }) {
    return Message(
      metadata: metadata.copyWith(
        updatedAt: DateTime.now(),
      ),
      chatId: chatId,
      content: content,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
      localTimestamp: localTimestamp ?? this.localTimestamp,
      nextMessageId: nextMessageId ?? this.nextMessageId,
      serverSequence: serverSequence,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  @override
  List<Object?> get props => [
        metadata,
        chatId,
        content,
        serverTimestamp,
        localTimestamp,
        nextMessageId,
        serverSequence,
        isLocal,
      ];
}
