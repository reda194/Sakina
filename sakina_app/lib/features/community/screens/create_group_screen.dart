import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';
import '../../../widgets/loading_button.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  final _tagsController = TextEditingController();
  
  GroupType _selectedType = GroupType.general;
  GroupPrivacy _selectedPrivacy = GroupPrivacy.public;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء مجموعة جديدة'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: const Text(
              'إنشاء',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildTypeSection(),
            const SizedBox(height: 24),
            _buildPrivacySection(),
            const SizedBox(height: 24),
            _buildRulesSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 32),
            _buildPreview(),
            const SizedBox(height: 32),
            LoadingButton(
              onPressed: _createGroup,
              isLoading: _isLoading,
              text: 'إنشاء المجموعة',
              icon: Icons.group_add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'المعلومات الأساسية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة *',
                hintText: 'أدخل اسم المجموعة',
                prefixIcon: Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم المجموعة';
                }
                if (value.trim().length < 3) {
                  return 'يجب أن يكون اسم المجموعة 3 أحرف على الأقل';
                }
                return null;
              },
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'وصف المجموعة *',
                hintText: 'اكتب وصفاً مختصراً عن المجموعة وأهدافها',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال وصف المجموعة';
                }
                if (value.trim().length < 10) {
                  return 'يجب أن يكون الوصف 10 أحرف على الأقل';
                }
                return null;
              },
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.category,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'نوع المجموعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GroupType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getGroupTypeIcon(type),
                        size: 16,
                        color: isSelected ? Colors.white : _getGroupTypeColor(type),
                      ),
                      const SizedBox(width: 4),
                      Text(_getGroupTypeText(type)),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: _getGroupTypeColor(type),
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.privacy_tip,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'خصوصية المجموعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: GroupPrivacy.values.map((privacy) {
                return RadioListTile<GroupPrivacy>(
                  title: Text(_getPrivacyText(privacy)),
                  subtitle: Text(_getPrivacyDescription(privacy)),
                  value: privacy,
                  groupValue: _selectedPrivacy,
                  onChanged: (value) {
                    setState(() {
                      _selectedPrivacy = value!;
                    });
                  },
                  secondary: Icon(
                    _getPrivacyIcon(privacy),
                    color: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.rule,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'قوانين المجموعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'اختياري - ضع قوانين واضحة للمجموعة',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rulesController,
              decoration: const InputDecoration(
                labelText: 'قوانين المجموعة',
                hintText: 'مثال:\n1. احترام جميع الأعضاء\n2. عدم مشاركة معلومات شخصية\n3. التركيز على موضوع المجموعة',
                prefixIcon: Icon(Icons.gavel),
              ),
              maxLines: 5,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.tag,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'الكلمات المفتاحية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'اختياري - أضف كلمات مفتاحية لتسهيل العثور على المجموعة',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'الكلمات المفتاحية',
                hintText: 'مثال: دعم، علاج، تأمل (افصل بفاصلة)',
                prefixIcon: Icon(Icons.local_offer),
              ),
              maxLength: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_nameController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.preview,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'معاينة المجموعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.borderColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getGroupTypeColor(_selectedType),
                          _getGroupTypeColor(_selectedType).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            children: [
                              if (_selectedPrivacy == GroupPrivacy.private)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getGroupTypeText(_selectedType),
                                  style: TextStyle(
                                    color: _getGroupTypeColor(_selectedType),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 16,
                          left: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getGroupTypeIcon(_selectedType),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _nameController.text.trim(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_descriptionController.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _descriptionController.text.trim(),
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '1 عضو',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.article,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '0 منشور',
                                style: TextStyle(
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
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final rules = _rulesController.text.trim().isNotEmpty
          ? GroupRules(
              rules: _rulesController.text
                  .split('\n')
                  .map((rule) => rule.trim())
                  .where((rule) => rule.isNotEmpty)
                  .toList(),
              lastUpdated: DateTime.now(),
            )
          : null;

      final group = SupportGroupModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        privacy: _selectedPrivacy,
        membersCount: 1,
        postsCount: 0,
        createdAt: DateTime.now(),
        adminId: 'current_user_id', // Replace with actual user ID
        isJoined: true,
        tags: tags,
        rules: rules,
      );

      await Provider.of<CommunityProvider>(context, listen: false)
          .createGroup(group);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء المجموعة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
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

  IconData _getGroupTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.support:
        return Icons.favorite;
      case GroupType.therapy:
        return Icons.psychology;
      case GroupType.meditation:
        return Icons.self_improvement;
      case GroupType.anxiety:
        return Icons.sentiment_very_dissatisfied;
      case GroupType.depression:
        return Icons.sentiment_dissatisfied;
      case GroupType.addiction:
        return Icons.block;
      case GroupType.relationships:
        return Icons.people;
      case GroupType.parenting:
        return Icons.family_restroom;
      case GroupType.grief:
        return Icons.sentiment_neutral;
      case GroupType.trauma:
        return Icons.healing;
      case GroupType.stress:
        return Icons.warning;
      case GroupType.general:
        return Icons.forum;
    }
  }

  Color _getGroupTypeColor(GroupType type) {
    switch (type) {
      case GroupType.support:
        return AppTheme.errorColor;
      case GroupType.therapy:
        return AppTheme.primaryColor;
      case GroupType.meditation:
        return AppTheme.successColor;
      case GroupType.anxiety:
        return AppTheme.warningColor;
      case GroupType.depression:
        return Colors.blue;
      case GroupType.addiction:
        return Colors.red;
      case GroupType.relationships:
        return Colors.pink;
      case GroupType.parenting:
        return Colors.green;
      case GroupType.grief:
        return Colors.grey;
      case GroupType.trauma:
        return Colors.purple;
      case GroupType.stress:
        return Colors.deepOrange;
      case GroupType.general:
        return AppTheme.textSecondary;
    }
  }

  String _getGroupTypeText(GroupType type) {
    switch (type) {
      case GroupType.support:
        return 'دعم عام';
      case GroupType.therapy:
        return 'علاج نفسي';
      case GroupType.meditation:
        return 'تأمل';
      case GroupType.anxiety:
        return 'القلق';
      case GroupType.depression:
        return 'الاكتئاب';
      case GroupType.addiction:
        return 'الإدمان';
      case GroupType.relationships:
        return 'العلاقات';
      case GroupType.parenting:
        return 'الأبوة والأمومة';
      case GroupType.grief:
        return 'الحزن والفقدان';
      case GroupType.trauma:
        return 'الصدمات';
      case GroupType.stress:
        return 'التوتر';
      case GroupType.general:
        return 'عام';
    }
  }

  IconData _getPrivacyIcon(GroupPrivacy privacy) {
    switch (privacy) {
      case GroupPrivacy.public:
        return Icons.public;
      case GroupPrivacy.private:
        return Icons.lock;
      case GroupPrivacy.secret:
        return Icons.visibility_off;
    }
  }

  String _getPrivacyText(GroupPrivacy privacy) {
    switch (privacy) {
      case GroupPrivacy.public:
        return 'عامة';
      case GroupPrivacy.private:
        return 'خاصة';
      case GroupPrivacy.secret:
        return 'سرية';
    }
  }

  String _getPrivacyDescription(GroupPrivacy privacy) {
    switch (privacy) {
      case GroupPrivacy.public:
        return 'يمكن لأي شخص رؤية المجموعة والانضمام إليها';
      case GroupPrivacy.private:
        return 'يحتاج الأعضاء لطلب الانضمام والموافقة عليه';
      case GroupPrivacy.secret:
        return 'مجموعة سرية لا يمكن العثور عليها في البحث';
    }
  }
}