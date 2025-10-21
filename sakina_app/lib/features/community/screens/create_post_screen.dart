import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';
import '../../../widgets/loading_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  PostType _selectedType = PostType.text;
  PostMood? _selectedMood;
  bool _isAnonymous = false;
  bool _isLoading = false;
  
  final List<String> _tags = [];

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء منشور جديد'),
        centerTitle: true,
        actions: [
          LoadingButton(
            onPressed: _isLoading ? null : _createPost,
            isLoading: _isLoading,
            text: 'نشر',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostTypeSelector(),
              const SizedBox(height: 16),
              _buildContentField(),
              const SizedBox(height: 16),
              if (_selectedType == PostType.support) ...[
                _buildMoodSelector(),
                const SizedBox(height: 16),
              ],
              _buildTagsField(),
              const SizedBox(height: 16),
              _buildAnonymousToggle(),
              const SizedBox(height: 24),
              _buildPostPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع المنشور',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PostType.values.map((type) {
            final isSelected = _selectedType == type;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  if (type != PostType.support) {
                    _selectedMood = null;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPostTypeIcon(type),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPostTypeText(type),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المحتوى',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: _getContentHint(),
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال محتوى المنشور';
            }
            if (value.trim().length < 10) {
              return 'يجب أن يكون المحتوى 10 أحرف على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المزاج الحالي',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PostMood.values.map((mood) {
            final isSelected = _selectedMood == mood;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedMood = isSelected ? null : mood;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getMoodColor(mood).withOpacity(0.2)
                      : AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? _getMoodColor(mood)
                        : AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getMoodEmoji(mood),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getMoodText(mood),
                      style: TextStyle(
                        color: isSelected
                            ? _getMoodColor(mood)
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'العلامات (اختيارية)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            hintText: 'أدخل العلامات مفصولة بفواصل',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTags,
            ),
          ),
          onFieldSubmitted: (_) => _addTags(),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) {
              return Chip(
                label: Text('#$tag'),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAnonymousToggle() {
    return Row(
      children: [
        Switch(
          value: _isAnonymous,
          onChanged: (value) {
            setState(() {
              _isAnonymous = value;
            });
          },
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'نشر بشكل مجهول',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(
          Icons.info_outline,
          size: 20,
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _buildPostPreview() {
    if (_contentController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معاينة المنشور',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        _isAnonymous ? Icons.person : Icons.account_circle,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isAnonymous ? 'مستخدم مجهول' : 'أنت',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPostTypeColor(_selectedType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPostTypeIcon(_selectedType),
                            size: 12,
                            color: _getPostTypeColor(_selectedType),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPostTypeText(_selectedType),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getPostTypeColor(_selectedType),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _contentController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (_selectedMood != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMoodColor(_selectedMood!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getMoodEmoji(_selectedMood!),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getMoodText(_selectedMood!),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getMoodColor(_selectedMood!),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addTags() {
    final text = _tagsController.text.trim();
    if (text.isNotEmpty) {
      final newTags = text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty && !_tags.contains(tag))
          .toList();
      
      setState(() {
        _tags.addAll(newTags);
        _tagsController.clear();
      });
    }
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      
      await provider.createPost(
        content: _contentController.text.trim(),
        type: _selectedType,
        tags: _tags,
        isAnonymous: _isAnonymous,
        mood: _selectedMood,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نشر المنشور بنجاح'),
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

  String _getContentHint() {
    switch (_selectedType) {
      case PostType.text:
        return 'شارك أفكارك مع المجتمع...';
      case PostType.question:
        return 'اطرح سؤالك هنا...';
      case PostType.support:
        return 'شارك ما تشعر به واطلب الدعم...';
      case PostType.celebration:
        return 'شارك إنجازك أو لحظة سعيدة...';
      case PostType.resource:
        return 'شارك مورداً مفيداً مع المجتمع...';
      case PostType.poll:
        return 'اطرح استطلاع رأي...';
    }
  }

  IconData _getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.text:
        return Icons.article;
      case PostType.question:
        return Icons.help;
      case PostType.support:
        return Icons.favorite;
      case PostType.celebration:
        return Icons.celebration;
      case PostType.resource:
        return Icons.library_books;
      case PostType.poll:
        return Icons.poll;
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.text:
        return AppTheme.textSecondary;
      case PostType.question:
        return AppTheme.infoColor;
      case PostType.support:
        return AppTheme.errorColor;
      case PostType.celebration:
        return AppTheme.successColor;
      case PostType.resource:
        return AppTheme.warningColor;
      case PostType.poll:
        return AppTheme.primaryColor;
    }
  }

  String _getPostTypeText(PostType type) {
    switch (type) {
      case PostType.text:
        return 'نص';
      case PostType.question:
        return 'سؤال';
      case PostType.support:
        return 'دعم';
      case PostType.celebration:
        return 'احتفال';
      case PostType.resource:
        return 'مورد';
      case PostType.poll:
        return 'استطلاع';
    }
  }

  String _getMoodEmoji(PostMood mood) {
    switch (mood) {
      case PostMood.happy:
        return '😊';
      case PostMood.sad:
        return '😢';
      case PostMood.anxious:
        return '😰';
      case PostMood.angry:
        return '😠';
      case PostMood.excited:
        return '🤗';
      case PostMood.grateful:
        return '🙏';
      case PostMood.hopeful:
        return '🌟';
      case PostMood.frustrated:
        return '😤';
      case PostMood.peaceful:
        return '😌';
      case PostMood.overwhelmed:
        return '😵';
    }
  }

  String _getMoodText(PostMood mood) {
    switch (mood) {
      case PostMood.happy:
        return 'سعيد';
      case PostMood.sad:
        return 'حزين';
      case PostMood.anxious:
        return 'قلق';
      case PostMood.angry:
        return 'غاضب';
      case PostMood.excited:
        return 'متحمس';
      case PostMood.grateful:
        return 'ممتن';
      case PostMood.hopeful:
        return 'متفائل';
      case PostMood.frustrated:
        return 'محبط';
      case PostMood.peaceful:
        return 'هادئ';
      case PostMood.overwhelmed:
        return 'مرهق';
    }
  }

  Color _getMoodColor(PostMood mood) {
    switch (mood) {
      case PostMood.happy:
        return AppTheme.successColor;
      case PostMood.sad:
        return Colors.blue;
      case PostMood.anxious:
        return AppTheme.warningColor;
      case PostMood.angry:
        return AppTheme.errorColor;
      case PostMood.excited:
        return Colors.purple;
      case PostMood.grateful:
        return Colors.green;
      case PostMood.hopeful:
        return AppTheme.primaryColor;
      case PostMood.frustrated:
        return Colors.orange;
      case PostMood.peaceful:
        return Colors.teal;
      case PostMood.overwhelmed:
        return Colors.grey;
    }
  }
}