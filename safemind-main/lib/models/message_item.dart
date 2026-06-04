class SafeMindMessage {
  const SafeMindMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.conversationId,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? conversationId;

  factory SafeMindMessage.fromMap(String id, Map<String, dynamic> data) {
    return SafeMindMessage(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'User',
      recipientId: data['recipientId'] as String? ?? '',
      recipientName: data['recipientName'] as String? ?? 'User',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      conversationId: data['conversationId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'senderName': senderName,
    'recipientId': recipientId,
    'recipientName': recipientName,
    'content': content,
    'createdAt': createdAt,
    'isRead': isRead,
    'conversationId': conversationId,
  };

  SafeMindMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? recipientId,
    String? recipientName,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    String? conversationId,
  }) {
    return SafeMindMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

class SafeMindConversation {
  const SafeMindConversation({
    required this.id,
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  final String id;
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  factory SafeMindConversation.fromMap(String id, Map<String, dynamic> data) {
    return SafeMindConversation(
      id: id,
      user1Id: data['user1Id'] as String? ?? '',
      user1Name: data['user1Name'] as String? ?? 'User',
      user2Id: data['user2Id'] as String? ?? '',
      user2Name: data['user2Name'] as String? ?? 'User',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: (data['lastMessageTime'] as dynamic)?.toDate() ?? DateTime.now(),
      unreadCount: data['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'user1Id': user1Id,
    'user1Name': user1Name,
    'user2Id': user2Id,
    'user2Name': user2Name,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime,
    'unreadCount': unreadCount,
  };

  SafeMindConversation copyWith({
    String? id,
    String? user1Id,
    String? user1Name,
    String? user2Id,
    String? user2Name,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return SafeMindConversation(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user1Name: user1Name ?? this.user1Name,
      user2Id: user2Id ?? this.user2Id,
      user2Name: user2Name ?? this.user2Name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
