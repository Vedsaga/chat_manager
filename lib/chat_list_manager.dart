import 'package:chat_manager/chat_thread.dart';

class ChatListManager {
  final Map<int, ChatThread> _chatThreads = {};
  int? _firstChatId;
  int? _lastChatId;

  // Getter for testing
  Map<int, ChatThread> get chatThreads => Map.from(_chatThreads);
  int? get firstChatId => _firstChatId;
  int? get lastChatId => _lastChatId;

  void addNewChat(ChatThread newChat) {
    if (_firstChatId != null) {
      final firstChat = _chatThreads[_firstChatId]!;
      newChat.successorId = firstChat.id;
      firstChat.predecessorId = newChat.id;
    } else {
      _lastChatId = newChat.id;
    }

    _firstChatId = newChat.id;
    _chatThreads[newChat.id] = newChat;
  }

  void moveToTop(int chatId) {
    final chat = _chatThreads[chatId]!;

    // Already at top
    if (_firstChatId == chatId) return;

    // Update previous and next chat references
    final previousChat =
        chat.predecessorId != null ? _chatThreads[chat.predecessorId] : null;
    final nextChat =
        chat.successorId != null ? _chatThreads[chat.successorId] : null;

    // Link previous and next chats together
    if (previousChat != null) {
      previousChat.successorId = chat.successorId;
    }
    if (nextChat != null) {
      nextChat.predecessorId = chat.predecessorId;
    }

    // If this was the last chat, update last chat pointer
    if (_lastChatId == chatId) {
      _lastChatId = chat.predecessorId;
    }

    // Move chat to top
    final oldFirstChat = _chatThreads[_firstChatId]!;
    oldFirstChat.predecessorId = chatId;

    chat.predecessorId = null;
    chat.successorId = _firstChatId;
    _firstChatId = chatId;
  }

  List<ChatThread> getOrderedChatList() {
    List<ChatThread> orderedList = [];
    int? currentId = _firstChatId;

    while (currentId != null) {
      final currentChat = _chatThreads[currentId]!;
      orderedList.add(currentChat);
      currentId = currentChat.successorId;
    }

    return orderedList;
  }

  void handleNewMessage(int chatId, String message) {
    final chat = _chatThreads[chatId]!;
    chat.lastMessageText = message;
    chat.lastMessageAt = DateTime.now();

    if (!chat.isPinned) {
      moveToTop(chatId);
    }
  }

  // Load chats from JSON
  void loadFromJson(List<Map<String, dynamic>> jsonList) {
    _chatThreads.clear();
    _firstChatId = null;
    _lastChatId = null;

    for (var json in jsonList) {
      final chat = ChatThread.fromJson(json);
      _chatThreads[chat.id] = chat;

      if (chat.predecessorId == null) {
        _firstChatId = chat.id;
      }
      if (chat.successorId == null) {
        _lastChatId = chat.id;
      }
    }
  }
}
