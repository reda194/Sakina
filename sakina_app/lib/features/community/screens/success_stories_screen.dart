import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';
import 'story_details_screen.dart';

class SuccessStoriesScreen extends StatefulWidget {
  const SuccessStoriesScreen({super.key});

  @override
  State<SuccessStoriesScreen> createState() => _SuccessStoriesScreenState();
}

class _SuccessStoriesScreenState extends State<SuccessStoriesScreen> {
  StoryCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).loadSuccessStories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قصص النجاح'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _buildStoriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateStoryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, 'الكل'),
          ...StoryCategory.values.map((category) {
            return _buildCategoryChip(category, _getCategoryText(category));
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(StoryCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStoriesList() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final stories = provider.getFilteredSuccessStories(
          category: _selectedCategory,
          searchQuery: _searchQuery,
        );

        if (stories.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            return _buildStoryCard(story, provider);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد قصص نجاح',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'كن أول من يشارك قصة نجاحه',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(SuccessStoryModel story, CommunityProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryDetailsScreen(story: story),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(story.category),
                    _getCategoryColor(story.category).withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryText(story.category),
                        style: TextStyle(
                          color: _getCategoryColor(story.category),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Icon(
                                story.isAnonymous
                                    ? Icons.person
                                    : Icons.account_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              story.authorName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.summary,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => provider.likeSuccessStory(story.id),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              story.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: story.isLiked
                                  ? AppTheme.errorColor
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              story.likesCount.toString(),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            story.viewsCount.toString(),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(story.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في قصص النجاح'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'ابحث عن قصة...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchController.clear();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _getCategoryText(StoryCategory category) {
    switch (category) {
      case StoryCategory.recovery:
        return 'التعافي';
      case StoryCategory.therapy:
        return 'العلاج';
      case StoryCategory.relationships:
        return 'العلاقات';
      case StoryCategory.career:
        return 'المهنة';
      case StoryCategory.personal:
        return 'شخصي';
      case StoryCategory.health:
        return 'الصحة';
      case StoryCategory.education:
        return 'التعليم';
      case StoryCategory.family:
        return 'الأسرة';
    }
  }

  Color _getCategoryColor(StoryCategory category) {
    switch (category) {
      case StoryCategory.recovery:
        return AppTheme.successColor;
      case StoryCategory.therapy:
        return AppTheme.primaryColor;
      case StoryCategory.relationships:
        return Colors.pink;
      case StoryCategory.career:
        return Colors.orange;
      case StoryCategory.personal:
        return Colors.purple;
      case StoryCategory.health:
        return Colors.green;
      case StoryCategory.education:
        return Colors.blue;
      case StoryCategory.family:
        return Colors.teal;
    }
  }
}

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  StoryCategory _selectedCategory = StoryCategory.personal;
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مشاركة قصة نجاح'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitStory,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('نشر'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildSummaryField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 16),
            _buildAnonymousSwitch(),
            const SizedBox(height: 24),
            _buildPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'عنوان القصة',
        hintText: 'اكتب عنواناً جذاباً لقصتك',
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال عنوان القصة';
        }
        if (value.trim().length < 5) {
          return 'العنوان قصير جداً';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فئة القصة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StoryCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(_getCategoryText(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                  selectedColor: _getCategoryColor(category).withOpacity(0.2),
                  checkmarkColor: _getCategoryColor(category),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? _getCategoryColor(category)
                        : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryField() {
    return TextFormField(
      controller: _summaryController,
      decoration: const InputDecoration(
        labelText: 'ملخص القصة',
        hintText: 'اكتب ملخصاً مختصراً عن قصتك',
        prefixIcon: Icon(Icons.summarize),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال ملخص القصة';
        }
        if (value.trim().length < 20) {
          return 'الملخص قصير جداً';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'محتوى القصة',
        hintText: 'اكتب قصتك كاملة هنا...',
        prefixIcon: Icon(Icons.article),
        alignLabelWithHint: true,
      ),
      maxLines: 10,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال محتوى القصة';
        }
        if (value.trim().length < 100) {
          return 'المحتوى قصير جداً';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildAnonymousSwitch() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: const Text('نشر بشكل مجهول'),
        subtitle: const Text('لن يظهر اسمك مع القصة'),
        value: _isAnonymous,
        onChanged: (value) {
          setState(() {
            _isAnonymous = value;
          });
        },
        secondary: const Icon(Icons.visibility_off),
      ),
    );
  }

  Widget _buildPreview() {
    if (_titleController.text.trim().isEmpty &&
        _summaryController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(_selectedCategory).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.preview,
                      color: _getCategoryColor(_selectedCategory),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'معاينة القصة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(_selectedCategory),
                      ),
                    ),
                  ],
                ),
                if (_titleController.text.trim().isNotEmpty) ..[
                  const SizedBox(height: 12),
                  Text(
                    _titleController.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_summaryController.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _summaryController.text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitStory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      await provider.createSuccessStory(
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نشر قصة النجاح بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCategoryText(StoryCategory category) {
    switch (category) {
      case StoryCategory.recovery:
        return 'التعافي';
      case StoryCategory.therapy:
        return 'العلاج';
      case StoryCategory.relationships:
        return 'العلاقات';
      case StoryCategory.career:
        return 'المهنة';
      case StoryCategory.personal:
        return 'شخصي';
      case StoryCategory.health:
        return 'الصحة';
      case StoryCategory.education:
        return 'التعليم';
      case StoryCategory.family:
        return 'الأسرة';
    }
  }

  Color _getCategoryColor(StoryCategory category) {
    switch (category) {
      case StoryCategory.recovery:
        return AppTheme.successColor;
      case StoryCategory.therapy:
        return AppTheme.primaryColor;
      case StoryCategory.relationships:
        return Colors.pink;
      case StoryCategory.career:
        return Colors.orange;
      case StoryCategory.personal:
        return Colors.purple;
      case StoryCategory.health:
        return Colors.green;
      case StoryCategory.education:
        return Colors.blue;
      case StoryCategory.family:
        return Colors.teal;
    }
  }
}