enum MessageType {
  user,
  assistant,
  system,
}

enum MessageCategory {
  general,
  mood,
  anxiety,
  depression,
  stress,
  therapy,
  meditation,
  crisis,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageCategory category;
  final List<String> suggestions;
  final Map<String, dynamic>? metadata;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.category = MessageCategory.general,
    this.suggestions = const [],
    this.metadata,
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageCategory? category,
    List<String>? suggestions,
    Map<String, dynamic>? metadata,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      suggestions: suggestions ?? this.suggestions,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'category': category.name,
      'suggestions': suggestions,
      'metadata': metadata,
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      category: MessageCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MessageCategory.general,
      ),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, content: $content, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}