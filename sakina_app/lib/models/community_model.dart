class CommunityPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final List<String> tags;
  final PostType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isBookmarked;
  final bool isAnonymous;
  final PostStatus status;
  final String? groupId;
  final List<String> attachments;
  final PostMood? mood;

  CommunityPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.tags,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    required this.isBookmarked,
    required this.isAnonymous,
    required this.status,
    this.groupId,
    required this.attachments,
    this.mood,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      isAnonymous: json['isAnonymous'] ?? false,
      status: PostStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      groupId: json['groupId'],
      attachments: List<String>.from(json['attachments'] ?? []),
      mood: json['mood'] != null
          ? PostMood.values.firstWhere(
              (e) => e.toString().split('.').last == json['mood'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'tags': tags,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'isAnonymous': isAnonymous,
      'status': status.toString().split('.').last,
      'groupId': groupId,
      'attachments': attachments,
      'mood': mood?.toString().split('.').last,
    };
  }

  CommunityPostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    List<String>? tags,
    PostType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isBookmarked,
    bool? isAnonymous,
    PostStatus? status,
    String? groupId,
    List<String>? attachments,
    PostMood? mood,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      groupId: groupId ?? this.groupId,
      attachments: attachments ?? this.attachments,
      mood: mood ?? this.mood,
    );
  }
}

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final bool isLiked;
  final bool isAnonymous;
  final String? parentCommentId;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.likesCount,
    required this.isLiked,
    required this.isAnonymous,
    this.parentCommentId,
    required this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['postId'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isAnonymous: json['isAnonymous'] ?? false,
      parentCommentId: json['parentCommentId'],
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((reply) => CommentModel.fromJson(reply))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likesCount': likesCount,
      'isLiked': isLiked,
      'isAnonymous': isAnonymous,
      'parentCommentId': parentCommentId,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}

class SupportGroupModel {
  final String id;
  final String name;
  final String description;
  final String? coverImage;
  final GroupType type;
  final GroupPrivacy privacy;
  final int membersCount;
  final int postsCount;
  final bool isJoined;
  final bool isModerator;
  final DateTime createdAt;
  final DateTime lastActivity;
  final List<String> tags;
  final List<String> moderators;
  final GroupRules rules;

  SupportGroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage,
    required this.type,
    required this.privacy,
    required this.membersCount,
    required this.postsCount,
    required this.isJoined,
    required this.isModerator,
    required this.createdAt,
    required this.lastActivity,
    required this.tags,
    required this.moderators,
    required this.rules,
  });

  factory SupportGroupModel.fromJson(Map<String, dynamic> json) {
    return SupportGroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coverImage: json['coverImage'],
      type: GroupType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      privacy: GroupPrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == json['privacy'],
      ),
      membersCount: json['membersCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      isJoined: json['isJoined'] ?? false,
      isModerator: json['isModerator'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'])
          : DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
      moderators: List<String>.from(json['moderators'] ?? []),
      rules: GroupRules.fromJson(json['rules'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'type': type.toString().split('.').last,
      'privacy': privacy.toString().split('.').last,
      'membersCount': membersCount,
      'postsCount': postsCount,
      'isJoined': isJoined,
      'isModerator': isModerator,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'tags': tags,
      'moderators': moderators,
      'rules': rules.toJson(),
    };
  }
}

class GroupRules {
  final List<String> rules;
  final bool allowAnonymousPosts;
  final bool requireModeratorApproval;
  final bool allowImages;
  final bool allowLinks;
  final int maxPostLength;

  GroupRules({
    required this.rules,
    required this.allowAnonymousPosts,
    required this.requireModeratorApproval,
    required this.allowImages,
    required this.allowLinks,
    required this.maxPostLength,
  });

  factory GroupRules.fromJson(Map<String, dynamic> json) {
    return GroupRules(
      rules: List<String>.from(json['rules'] ?? []),
      allowAnonymousPosts: json['allowAnonymousPosts'] ?? true,
      requireModeratorApproval: json['requireModeratorApproval'] ?? false,
      allowImages: json['allowImages'] ?? true,
      allowLinks: json['allowLinks'] ?? false,
      maxPostLength: json['maxPostLength'] ?? 1000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rules': rules,
      'allowAnonymousPosts': allowAnonymousPosts,
      'requireModeratorApproval': requireModeratorApproval,
      'allowImages': allowImages,
      'allowLinks': allowLinks,
      'maxPostLength': maxPostLength,
    };
  }
}

class SuccessStoryModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String authorName;
  final String? authorAvatar;
  final bool isAnonymous;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLiked;
  final List<String> tags;
  final StoryCategory category;
  final int readingTimeMinutes;

  SuccessStoryModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.authorName,
    this.authorAvatar,
    required this.isAnonymous,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isLiked,
    required this.tags,
    required this.category,
    required this.readingTimeMinutes,
  });

  factory SuccessStoryModel.fromJson(Map<String, dynamic> json) {
    return SuccessStoryModel(
      id: json['id'],
      title: json['title'],
      summary: json['summary'] ?? '',
      content: json['content'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      category: StoryCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      readingTimeMinutes: json['readingTimeMinutes'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'isLiked': isLiked,
      'tags': tags,
      'category': category.toString().split('.').last,
      'readingTimeMinutes': readingTimeMinutes,
    };
  }
}

enum PostType {
  text,
  question,
  support,
  celebration,
  resource,
  poll,
}

enum PostStatus {
  published,
  pending,
  hidden,
  reported,
}

enum PostMood {
  happy,
  sad,
  anxious,
  angry,
  excited,
  hopeful,
  grateful,
  frustrated,
  peaceful,
  overwhelmed,
}

enum GroupType {
  support,
  therapy,
  meditation,
  anxiety,
  depression,
  stress,
  relationships,
  parenting,
  trauma,
  selfCare,
  addiction,
  grief,
  general,
}

enum GroupPrivacy {
  public,
  private,
  secret,
}

enum StoryCategory {
  recovery,
  therapy,
  personal,
  health,
  education,
  selfCare,
  relationships,
  career,
  family,
  general,
}