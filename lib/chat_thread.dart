class ChatThread {
  final int id;
  int? predecessorId;
  int? successorId;
  DateTime lastMessageAt;
  String lastMessageText;
  bool isPinned;

  ChatThread({
    required this.id,
    this.predecessorId,
    this.successorId,
    required this.lastMessageAt,
    required this.lastMessageText,
    this.isPinned = false,
  });

  // From JSON constructor
  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as int,
      predecessorId: json['predecessorId'] as int?,
      successorId: json['successorId'] as int?,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      lastMessageText: json['lastMessageText'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'predecessorId': predecessorId,
      'successorId': successorId,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessageText': lastMessageText,
      'isPinned': isPinned,
    };
  }

  @override
  String toString() {
    return 'ChatThread{id: $id, pred: $predecessorId, succ: $successorId, message: $lastMessageText}';
  }
}
