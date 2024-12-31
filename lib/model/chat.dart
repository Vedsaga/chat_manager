import 'package:chat_manager/lib.dart';
import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final Metadata metadata;
  final int? predecessorId;
  final int? successorId;
  final Message? lastMessage; // Changed to Message type
  final bool isPinned;
  final bool hasUnreadMessages;

  const Chat({
    required this.metadata,
    this.predecessorId,
    this.successorId,
    this.lastMessage,
    this.isPinned = false,
    this.hasUnreadMessages = false,
  });

  Chat copyWith({
    int? predecessorId,
    int? successorId,
    Message? lastMessage,
    bool? isPinned,
    bool? hasUnreadMessages,
  }) {
    return Chat(
      metadata: metadata.copyWith(
        updatedAt: DateTime.now(),
      ),
      predecessorId: predecessorId ?? this.predecessorId,
      successorId: successorId ?? this.successorId,
      lastMessage: lastMessage ?? this.lastMessage,
      isPinned: isPinned ?? this.isPinned,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }

  @override
  List<Object?> get props => [
        metadata,
        predecessorId,
        successorId,
        lastMessage,
        isPinned,
        hasUnreadMessages,
      ];
}
