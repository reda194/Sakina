import 'package:flutter/material.dart';
import '../../../models/community_model.dart';

class CommunityProvider with ChangeNotifier {
  List<CommunityPostModel> _posts = [];
  List<SupportGroupModel> _groups = [];
  List<SuccessStoryModel> _stories = [];
  List<CommentModel> _comments = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<CommunityPostModel> get posts => _posts;
  List<SupportGroupModel> get groups => _groups;
  List<SuccessStoryModel> get stories => _stories;
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Filter getters
  List<CommunityPostModel> get supportPosts => 
      _posts.where((post) => post.type == PostType.support).toList();
  
  List<CommunityPostModel> get questionPosts => 
      _posts.where((post) => post.type == PostType.question).toList();
  
  List<CommunityPostModel> get celebrationPosts => 
      _posts.where((post) => post.type == PostType.celebration).toList();
  
  List<SupportGroupModel> get joinedGroups => 
      _groups.where((group) => group.isJoined).toList();
  
  List<SupportGroupModel> get recommendedGroups => 
      _groups.where((group) => !group.isJoined).take(5).toList();

  // Initialize with mock data
  CommunityProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _posts = [
      CommunityPostModel(
        id: '1',
        authorId: 'user1',
        authorName: 'مجهول',
        content: 'أشعر بتحسن كبير بعد بدء جلسات العلاج النفسي. أريد أن أشارككم تجربتي وأشجع من يتردد في طلب المساعدة.',
        tags: ['تحسن', 'علاج_نفسي', 'تشجيع'],
        type: PostType.celebration,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 24,
        commentsCount: 8,
        sharesCount: 3,
        isLiked: false,
        isBookmarked: false,
        isAnonymous: true,
        status: PostStatus.published,
        attachments: [],
        mood: PostMood.hopeful,
      ),
      CommunityPostModel(
        id: '2',
        authorId: 'user2',
        authorName: 'سارة أحمد',
        content: 'كيف يمكنني التعامل مع نوبات القلق في العمل؟ أحتاج نصائح عملية.',
        tags: ['قلق', 'عمل', 'نصائح'],
        type: PostType.question,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likesCount: 12,
        commentsCount: 15,
        sharesCount: 1,
        isLiked: true,
        isBookmarked: true,
        isAnonymous: false,
        status: PostStatus.published,
        attachments: [],
        mood: PostMood.anxious,
      ),
      CommunityPostModel(
        id: '3',
        authorId: 'user3',
        authorName: 'مجهول',
        content: 'أمر بفترة صعبة ولكن أحاول التركيز على الأشياء الإيجابية في حياتي. الامتنان يساعدني كثيراً.',
        tags: ['امتنان', 'إيجابية', 'دعم'],
        type: PostType.support,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 18,
        commentsCount: 6,
        sharesCount: 2,
        isLiked: false,
        isBookmarked: false,
        isAnonymous: true,
        status: PostStatus.published,
        attachments: [],
        mood: PostMood.grateful,
      ),
    ];

    _groups = [
      SupportGroupModel(
        id: '1',
        name: 'دعم القلق والتوتر',
        description: 'مجموعة آمنة للتحدث عن تجارب القلق والتوتر ومشاركة استراتيجيات التأقلم',
        type: GroupType.anxiety,
        privacy: GroupPrivacy.private,
        membersCount: 156,
        postsCount: 89,
        isJoined: true,
        isModerator: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        tags: ['قلق', 'توتر', 'دعم'],
        moderators: ['mod1', 'mod2'],
        rules: GroupRules(
          rules: [
            'احترام جميع الأعضاء',
            'عدم مشاركة معلومات شخصية',
            'التركيز على الدعم الإيجابي',
            'عدم تقديم نصائح طبية',
          ],
          allowAnonymousPosts: true,
          requireModeratorApproval: false,
          allowImages: false,
          allowLinks: false,
          maxPostLength: 500,
        ),
      ),
      SupportGroupModel(
        id: '2',
        name: 'رحلة التعافي من الاكتئاب',
        description: 'مساحة للمشاركة والدعم في رحلة التعافي من الاكتئاب',
        type: GroupType.depression,
        privacy: GroupPrivacy.private,
        membersCount: 203,
        postsCount: 145,
        isJoined: false,
        isModerator: false,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        tags: ['اكتئاب', 'تعافي', 'أمل'],
        moderators: ['mod3', 'mod4'],
        rules: GroupRules(
          rules: [
            'بيئة آمنة وداعمة',
            'احترام خصوصية الآخرين',
            'مشاركة التجارب الإيجابية',
            'طلب المساعدة المهنية عند الحاجة',
          ],
          allowAnonymousPosts: true,
          requireModeratorApproval: true,
          allowImages: false,
          allowLinks: false,
          maxPostLength: 800,
        ),
      ),
      SupportGroupModel(
        id: '3',
        name: 'العناية بالذات',
        description: 'نصائح وأفكار للعناية بالصحة النفسية والجسدية',
        type: GroupType.selfCare,
        privacy: GroupPrivacy.public,
        membersCount: 89,
        postsCount: 67,
        isJoined: true,
        isModerator: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        tags: ['عناية_بالذات', 'صحة', 'رفاهية'],
        moderators: ['mod5'],
        rules: GroupRules(
          rules: [
            'مشاركة نصائح إيجابية',
            'احترام اختيارات الآخرين',
            'التركيز على الحلول العملية',
          ],
          allowAnonymousPosts: false,
          requireModeratorApproval: false,
          allowImages: true,
          allowLinks: true,
          maxPostLength: 300,
        ),
      ),
    ];

    _stories = [
      SuccessStoryModel(
        id: '1',
        title: 'كيف تغلبت على القلق الاجتماعي',
        content: 'كنت أعاني من القلق الاجتماعي لسنوات طويلة، لم أكن أستطيع التحدث أمام الناس أو حتى طلب شيء في المطعم. بدأت رحلة العلاج منذ عام، وتعلمت تقنيات التنفس والتأمل. اليوم أستطيع إلقاء العروض في العمل وأشعر بثقة أكبر في نفسي.',
        authorName: 'مجهول',
        isAnonymous: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        likesCount: 45,
        commentsCount: 12,
        isLiked: true,
        tags: ['قلق_اجتماعي', 'تعافي', 'ثقة'],
        category: StoryCategory.therapy,
        readingTimeMinutes: 3,
      ),
      SuccessStoryModel(
        id: '2',
        title: 'رحلتي مع الاكتئاب والأمل',
        content: 'مررت بفترة صعبة جداً من الاكتئاب، فقدت الاهتمام بكل شيء في حياتي. لكن بمساعدة الطبيب النفسي والدعم من الأصدقاء، تمكنت من العودة للحياة تدريجياً. الآن أمارس الرياضة وأقرأ وأستمتع بالأشياء البسيطة.',
        authorName: 'أحمد محمد',
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        likesCount: 67,
        commentsCount: 23,
        isLiked: false,
        tags: ['اكتئاب', 'أمل', 'تعافي'],
        category: StoryCategory.recovery,
        readingTimeMinutes: 5,
      ),
    ];

    notifyListeners();
  }

  // Posts methods
  Future<void> loadPosts() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // Posts are already loaded in _loadMockData
      _setError(null);
    } catch (e) {
      _setError('فشل في تحميل المنشورات');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPost({
    required String content,
    required PostType type,
    required List<String> tags,
    bool isAnonymous = false,
    PostMood? mood,
    String? groupId,
  }) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final newPost = CommunityPostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: 'current_user',
        authorName: isAnonymous ? 'مجهول' : 'أنت',
        content: content,
        tags: tags,
        type: type,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
        isLiked: false,
        isBookmarked: false,
        isAnonymous: isAnonymous,
        status: PostStatus.published,
        groupId: groupId,
        attachments: [],
        mood: mood,
      );
      
      _posts.insert(0, newPost);
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('فشل في إنشاء المنشور');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في تحديث الإعجاب');
    }
  }

  Future<void> bookmarkPost(String postId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          isBookmarked: !post.isBookmarked,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في حفظ المنشور');
    }
  }

  // Groups methods
  Future<void> loadGroups() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // Groups are already loaded in _loadMockData
      _setError(null);
    } catch (e) {
      _setError('فشل في تحميل المجموعات');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      final groupIndex = _groups.indexWhere((group) => group.id == groupId);
      if (groupIndex != -1) {
        final group = _groups[groupIndex];
        _groups[groupIndex] = SupportGroupModel(
          id: group.id,
          name: group.name,
          description: group.description,
          coverImage: group.coverImage,
          type: group.type,
          privacy: group.privacy,
          membersCount: group.isJoined ? group.membersCount - 1 : group.membersCount + 1,
          postsCount: group.postsCount,
          isJoined: !group.isJoined,
          isModerator: group.isModerator,
          createdAt: group.createdAt,
          tags: group.tags,
          moderators: group.moderators,
          rules: group.rules,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في الانضمام للمجموعة');
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      final groupIndex = _groups.indexWhere((group) => group.id == groupId);
      if (groupIndex != -1) {
        final group = _groups[groupIndex];
        _groups[groupIndex] = SupportGroupModel(
          id: group.id,
          name: group.name,
          description: group.description,
          coverImage: group.coverImage,
          type: group.type,
          privacy: group.privacy,
          membersCount: group.membersCount - 1,
          postsCount: group.postsCount,
          isJoined: false,
          isModerator: group.isModerator,
          createdAt: group.createdAt,
          tags: group.tags,
          moderators: group.moderators,
          rules: group.rules,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في مغادرة المجموعة');
    }
  }

  List<CommunityPostModel> getGroupPosts(String groupId) {
    return _posts.where((post) => post.groupId == groupId).toList();
  }

  Future<void> loadGroupPosts(String groupId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      // In real app, fetch group posts from API
      notifyListeners();
    } catch (e) {
      _setError('فشل في تحميل منشورات المجموعة');
    }
  }

  List<Map<String, dynamic>> getGroupMembers(String groupId) {
    // Mock data for group members
    return [
      {
        'id': '1',
        'name': 'أحمد محمد',
        'joinedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'isAdmin': true,
      },
      {
        'id': '2',
        'name': 'فاطمة علي',
        'joinedAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'isAdmin': false,
      },
      {
        'id': '3',
        'name': 'محمد حسن',
        'joinedAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'isAdmin': false,
      },
    ];
  }

  Future<void> loadGroupMembers(String groupId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      // In real app, fetch group members from API
      notifyListeners();
    } catch (e) {
      _setError('فشل في تحميل أعضاء المجموعة');
    }
  }

  List<SupportGroupModel> getFilteredGroups({
    GroupType? type,
    String? searchQuery,
    bool? joinedOnly,
  }) {
    var filtered = _groups.where((group) {
      if (type != null && group.type != type) {
        return false;
      }
      if (joinedOnly == true && !group.isJoined) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return group.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               group.description.toLowerCase().contains(searchQuery.toLowerCase());
      }
      return true;
    }).toList();
    
    // Sort by member count (most popular first)
    filtered.sort((a, b) => b.membersCount.compareTo(a.membersCount));
    return filtered;
  }

  // Stories methods
  Future<void> loadStories() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // Stories are already loaded in _loadMockData
      _setError(null);
    } catch (e) {
      _setError('فشل في تحميل قصص النجاح');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> likeStory(String storyId) async {
    try {
      final storyIndex = _stories.indexWhere((story) => story.id == storyId);
      if (storyIndex != -1) {
        final story = _stories[storyIndex];
        _stories[storyIndex] = SuccessStoryModel(
          id: story.id,
          title: story.title,
          content: story.content,
          authorName: story.authorName,
          authorAvatar: story.authorAvatar,
          isAnonymous: story.isAnonymous,
          createdAt: story.createdAt,
          likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
          commentsCount: story.commentsCount,
          isLiked: !story.isLiked,
          tags: story.tags,
          category: story.category,
          readingTimeMinutes: story.readingTimeMinutes,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في تحديث الإعجاب');
    }
  }

  // Comments methods
  Future<void> loadComments(String postId) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock comments
      _comments = [
        CommentModel(
          id: '1',
          postId: postId,
          authorId: 'user1',
          authorName: 'مجهول',
          content: 'شكراً لك على المشاركة، هذا مشجع جداً',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          likesCount: 3,
          isLiked: false,
          isAnonymous: true,
          replies: [],
        ),
        CommentModel(
          id: '2',
          postId: postId,
          authorId: 'user2',
          authorName: 'أحمد',
          content: 'أتفق معك تماماً، العلاج النفسي غير حياتي أيضاً',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          likesCount: 5,
          isLiked: true,
          isAnonymous: false,
          replies: [],
        ),
      ];
      
      _setError(null);
    } catch (e) {
      _setError('فشل في تحميل التعليقات');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addComment({
    required String postId,
    required String content,
    bool isAnonymous = false,
    String? parentCommentId,
  }) async {
    try {
      final newComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: postId,
        authorId: 'current_user',
        authorName: isAnonymous ? 'مجهول' : 'أنت',
        content: content,
        createdAt: DateTime.now(),
        likesCount: 0,
        isLiked: false,
        isAnonymous: isAnonymous,
        parentCommentId: parentCommentId,
        replies: [],
      );
      
      _comments.insert(0, newComment);
      
      // Update post comments count
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          commentsCount: post.commentsCount + 1,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _setError('فشل في إضافة التعليق');
    }
  }

  // Search methods
  List<CommunityPostModel> searchPosts(String query) {
    if (query.isEmpty) return _posts;
    
    return _posts.where((post) {
      return post.content.toLowerCase().contains(query.toLowerCase()) ||
             post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  List<SupportGroupModel> searchGroups(String query) {
    if (query.isEmpty) return _groups;
    
    return _groups.where((group) {
      return group.name.toLowerCase().contains(query.toLowerCase()) ||
             group.description.toLowerCase().contains(query.toLowerCase()) ||
             group.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Filter methods
  List<CommunityPostModel> getPostsByType(PostType type) {
    return _posts.where((post) => post.type == type).toList();
  }

  List<CommunityPostModel> getPostsByMood(PostMood mood) {
    return _posts.where((post) => post.mood == mood).toList();
  }

  List<SupportGroupModel> getGroupsByType(GroupType type) {
    return _groups.where((group) => group.type == type).toList();
  }

  List<SuccessStoryModel> getStoriesByCategory(StoryCategory category) {
    return _stories.where((story) => story.category == category).toList();
  }

  // Success Stories methods
  Future<void> loadSuccessStories() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // In real app, fetch from API
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> likeSuccessStory(String storyId) async {
    try {
      final storyIndex = _stories.indexWhere((s) => s.id == storyId);
      if (storyIndex != -1) {
        final story = _stories[storyIndex];
        _stories[storyIndex] = SuccessStoryModel(
          id: story.id,
          title: story.title,
          content: story.content,
          authorName: story.authorName,
          authorAvatar: story.authorAvatar,
          isAnonymous: story.isAnonymous,
          createdAt: story.createdAt,
          likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
          commentsCount: story.commentsCount,
          isLiked: !story.isLiked,
          tags: story.tags,
          category: story.category,
          readingTimeMinutes: story.readingTimeMinutes,
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  List<SuccessStoryModel> getFilteredSuccessStories({
    StoryCategory? category,
    String? searchQuery,
  }) {
    var filtered = _stories.where((story) {
      if (category != null && story.category != category) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return story.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               story.content.toLowerCase().contains(searchQuery.toLowerCase());
      }
      return true;
    }).toList();
    
    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<void> createSuccessStory({
    required String title,
    required String content,
    required StoryCategory category,
    required bool isAnonymous,
  }) async {
    try {
      final newStory = SuccessStoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        category: category,
        authorName: isAnonymous ? 'مجهول' : 'المستخدم الحالي',
        isAnonymous: isAnonymous,
        likesCount: 0,
        commentsCount: 0,
        isLiked: false,
        tags: _extractTags(content),
        createdAt: DateTime.now(),
        readingTimeMinutes: (content.length / 200).ceil(),
      );
      
      _stories.insert(0, newStory);
      notifyListeners();
    } catch (e) {
      throw Exception('فشل في إنشاء القصة');
    }
  }

  List<SuccessStoryModel> getRelatedSuccessStories(String currentStoryId, StoryCategory category) {
    return _stories
        .where((story) => story.id != currentStoryId && story.category == category)
        .take(5)
        .toList();
  }

  List<String> _extractTags(String content) {
    // Simple tag extraction - in real app, use more sophisticated method
    final words = content.split(' ');
    final tags = <String>[];
    
    for (final word in words) {
      if (word.length > 4 && !tags.contains(word.toLowerCase())) {
        tags.add(word.toLowerCase());
        if (tags.length >= 5) break;
      }
    }
    
    return tags;
  }

  // Create new group
  Future<void> createGroup(SupportGroupModel group) async {
    try {
      _setLoading(true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _groups.insert(0, group);
      notifyListeners();
    } catch (e) {
      throw Exception('فشل في إنشاء المجموعة: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}