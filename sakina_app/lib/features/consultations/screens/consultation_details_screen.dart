import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/consultation_model.dart';
import '../providers/consultation_provider.dart';

class ConsultationDetailsScreen extends StatelessWidget {
  final ConsultationModel consultation;

  const ConsultationDetailsScreen({
    super.key,
    required this.consultation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الاستشارة'),
        centerTitle: true,
        actions: [
          if (consultation.status == ConsultationStatus.pending ||
              consultation.status == ConsultationStatus.confirmed)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reschedule',
                  child: Row(
                    children: [
                      Icon(Icons.schedule),
                      SizedBox(width: 8),
                      Text('إعادة جدولة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('إلغاء الاستشارة', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 16),
            _buildSpecialistCard(context),
            const SizedBox(height: 16),
            _buildConsultationDetails(context),
            const SizedBox(height: 16),
            if (consultation.notes != null) ...[
              _buildNotesSection(context),
              const SizedBox(height: 16),
            ],
            if (consultation.sessionNotes != null) ...[
              _buildSessionNotesSection(context),
              const SizedBox(height: 16),
            ],
            if (consultation.status == ConsultationStatus.completed &&
                consultation.rating == null) ...[
              _buildRatingSection(context),
              const SizedBox(height: 16),
            ],
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor().withOpacity(0.1),
              _getStatusColor().withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(),
              size: 48,
              color: _getStatusColor(),
            ),
            const SizedBox(height: 12),
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                consultation.specialistName.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation.specialistName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    consultation.specialistTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      consultation.specialistSpecialization,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildConsultationDetails(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'تفاصيل الاستشارة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'التاريخ',
              _formatDate(consultation.scheduledDate),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.access_time,
              'الوقت',
              _formatTime(consultation.scheduledDate),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.timer,
              'المدة',
              '${consultation.duration.inMinutes} دقيقة',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              _getTypeIcon(consultation.type),
              'نوع الاستشارة',
              _getTypeText(consultation.type),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.payment,
              'السعر',
              '${consultation.price.toInt()} ر.س',
            ),
            if (consultation.meetingLink != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                Icons.link,
                'رابط الاجتماع',
                'متاح قبل الموعد بـ 15 دقيقة',
                isLink: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isLink ? AppTheme.primaryColor : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.note,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ملاحظاتك',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                consultation.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionNotesSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ملاحظات المختص',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                consultation.sessionNotes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_outline,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'تقييم الاستشارة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'كيف كانت تجربتك مع هذه الاستشارة؟',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRatingDialog(context),
                icon: const Icon(Icons.star),
                label: const Text('إضافة تقييم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (consultation.status == ConsultationStatus.confirmed &&
            consultation.meetingLink != null &&
            _canJoinMeeting()) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _joinMeeting(context),
              icon: const Icon(Icons.videocam),
              label: const Text(
                'انضم للاستشارة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (consultation.status == ConsultationStatus.pending ||
            consultation.status == ConsultationStatus.confirmed) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleConsultation(context),
                  icon: const Icon(Icons.schedule),
                  label: const Text('إعادة جدولة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelConsultation(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('إلغاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getStatusColor() {
    switch (consultation.status) {
      case ConsultationStatus.pending:
        return AppTheme.warningColor;
      case ConsultationStatus.confirmed:
        return AppTheme.successColor;
      case ConsultationStatus.inProgress:
        return AppTheme.infoColor;
      case ConsultationStatus.completed:
        return AppTheme.primaryColor;
      case ConsultationStatus.cancelled:
        return AppTheme.errorColor;
      case ConsultationStatus.rescheduled:
        return AppTheme.secondaryColor;
    }
  }

  IconData _getStatusIcon() {
    switch (consultation.status) {
      case ConsultationStatus.pending:
        return Icons.schedule;
      case ConsultationStatus.confirmed:
        return Icons.check_circle;
      case ConsultationStatus.inProgress:
        return Icons.play_circle;
      case ConsultationStatus.completed:
        return Icons.check_circle_outline;
      case ConsultationStatus.cancelled:
        return Icons.cancel;
      case ConsultationStatus.rescheduled:
        return Icons.update;
    }
  }

  String _getStatusText() {
    switch (consultation.status) {
      case ConsultationStatus.pending:
        return 'في الانتظار';
      case ConsultationStatus.confirmed:
        return 'مؤكدة';
      case ConsultationStatus.inProgress:
        return 'جارية';
      case ConsultationStatus.completed:
        return 'مكتملة';
      case ConsultationStatus.cancelled:
        return 'ملغية';
      case ConsultationStatus.rescheduled:
        return 'معاد جدولتها';
    }
  }

  String _getStatusDescription() {
    switch (consultation.status) {
      case ConsultationStatus.pending:
        return 'في انتظار تأكيد المختص';
      case ConsultationStatus.confirmed:
        return 'تم تأكيد الاستشارة من قبل المختص';
      case ConsultationStatus.inProgress:
        return 'الاستشارة جارية حالياً';
      case ConsultationStatus.completed:
        return 'تم إنهاء الاستشارة بنجاح';
      case ConsultationStatus.cancelled:
        return 'تم إلغاء الاستشارة';
      case ConsultationStatus.rescheduled:
        return 'تم تغيير موعد الاستشارة';
    }
  }

  IconData _getTypeIcon(ConsultationType type) {
    switch (type) {
      case ConsultationType.video:
        return Icons.videocam;
      case ConsultationType.audio:
        return Icons.phone;
      case ConsultationType.chat:
        return Icons.chat;
      case ConsultationType.inPerson:
        return Icons.person;
    }
  }

  String _getTypeText(ConsultationType type) {
    switch (type) {
      case ConsultationType.video:
        return 'مكالمة فيديو';
      case ConsultationType.audio:
        return 'مكالمة صوتية';
      case ConsultationType.chat:
        return 'دردشة نصية';
      case ConsultationType.inPerson:
        return 'حضوري';
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final period = date.hour >= 12 ? 'م' : 'ص';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  bool _canJoinMeeting() {
    final now = DateTime.now();
    final meetingTime = consultation.scheduledDate;
    final timeDifference = meetingTime.difference(now).inMinutes;
    
    // Allow joining 15 minutes before and up to the duration of the meeting
    return timeDifference <= 15 && timeDifference >= -consultation.duration.inMinutes;
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'reschedule':
        _rescheduleConsultation(context);
        break;
      case 'cancel':
        _cancelConsultation(context);
        break;
    }
  }

  void _joinMeeting(BuildContext context) {
    // In a real app, this would open the video call interface
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح رابط الاجتماع...'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _rescheduleConsultation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة جدولة الاستشارة'),
        content: const Text('هل تريد إعادة جدولة هذه الاستشارة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would navigate to the rescheduling screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم إعادة توجيهك لصفحة إعادة الجدولة'),
                ),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _cancelConsultation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الاستشارة'),
        content: const Text(
          'هل أنت متأكد من إلغاء هذه الاستشارة؟\n\nملاحظة: قد تطبق رسوم إلغاء حسب سياسة الإلغاء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                final provider = Provider.of<ConsultationProvider>(
                  context,
                  listen: false,
                );
                await provider.cancelConsultation(consultation.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إلغاء الاستشارة بنجاح'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ أثناء الإلغاء: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('إلغاء الاستشارة'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تقييم الاستشارة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كيف تقيم هذه الاستشارة؟'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppTheme.warningColor,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'اكتب تعليقك (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  final provider = Provider.of<ConsultationProvider>(
                    context,
                    listen: false,
                  );
                  await provider.rateConsultation(
                    consultation.id,
                    rating,
                    commentController.text.trim().isEmpty
                        ? null
                        : commentController.text.trim(),
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة التقييم بنجاح'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ أثناء إضافة التقييم: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              child: const Text('إرسال التقييم'),
            ),
          ],
        ),
      ),
    );
  }
}