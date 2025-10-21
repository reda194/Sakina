import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/consultation_model.dart';
import '../providers/consultation_provider.dart';
import 'specialist_details_screen.dart';
import 'book_consultation_screen.dart';
import 'consultation_details_screen.dart';

class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستشارات'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المختصين'),
            Tab(text: 'مواعيدي'),
            Tab(text: 'السجل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SpecialistsTab(),
          MyAppointmentsTab(),
          ConsultationHistoryTab(),
        ],
      ),
    );
  }
}

class SpecialistsTab extends StatelessWidget {
  const SpecialistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final specialists = provider.availableSpecialists;

        if (specialists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد مختصين متاحين حالياً',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: specialists.length,
            itemBuilder: (context, index) {
              final specialist = specialists[index];
              return _buildSpecialistCard(context, specialist);
            },
          ),
        );
      },
    );
  }

  Widget _buildSpecialistCard(BuildContext context, SpecialistModel specialist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialistDetailsScreen(specialist: specialist),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      specialist.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          specialist.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          specialist.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${specialist.rating}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${specialist.reviewsCount} تقييم)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'متاح',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${specialist.pricePerSession.toInt()} ر.س',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  specialist.specialization,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                specialist.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (specialist.nextAvailableSlot != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'أقرب موعد: ${specialist.nextAvailableSlot}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookConsultationScreen(
                          specialist: specialist,
                        ),
                      ),
                    );
                  },
                  child: const Text('احجز استشارة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAppointmentsTab extends StatelessWidget {
  const MyAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, child) {
        final upcomingConsultations = provider.upcomingConsultations;

        if (upcomingConsultations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.event_available,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد مواعيد قادمة',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'احجز استشارة جديدة من تبويب المختصين',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcomingConsultations.length,
          itemBuilder: (context, index) {
            final consultation = upcomingConsultations[index];
            return _buildConsultationCard(context, consultation);
          },
        );
      },
    );
  }

  Widget _buildConsultationCard(BuildContext context, ConsultationModel consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConsultationDetailsScreen(
                consultation: consultation,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      consultation.specialistName.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      ],
                    ),
                  ),
                  _buildStatusChip(consultation.status),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(consultation.scheduledDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${consultation.duration.inMinutes} دقيقة',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getTypeIcon(consultation.type),
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTypeText(consultation.type),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${consultation.price.toInt()} ر.س',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildStatusChip(ConsultationStatus status) {
    Color color;
    String text;

    switch (status) {
      case ConsultationStatus.pending:
        color = AppTheme.warningColor;
        text = 'في الانتظار';
        break;
      case ConsultationStatus.confirmed:
        color = AppTheme.successColor;
        text = 'مؤكد';
        break;
      case ConsultationStatus.inProgress:
        color = AppTheme.infoColor;
        text = 'جاري';
        break;
      case ConsultationStatus.completed:
        color = AppTheme.primaryColor;
        text = 'مكتمل';
        break;
      case ConsultationStatus.cancelled:
        color = AppTheme.errorColor;
        text = 'ملغي';
        break;
      case ConsultationStatus.rescheduled:
        color = AppTheme.secondaryColor;
        text = 'معاد جدولته';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
        return 'دردشة';
      case ConsultationType.inPerson:
        return 'حضوري';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'اليوم ${_formatTime(date)}';
    } else if (difference == 1) {
      return 'غداً ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'م' : 'ص';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}

class ConsultationHistoryTab extends StatelessWidget {
  const ConsultationHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, child) {
        final pastConsultations = provider.pastConsultations;

        if (pastConsultations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد استشارات سابقة',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pastConsultations.length,
          itemBuilder: (context, index) {
            final consultation = pastConsultations[index];
            return _buildHistoryCard(context, consultation);
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, ConsultationModel consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    consultation.specialistName.substring(0, 1),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.specialistName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(consultation.scheduledDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (consultation.rating != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${consultation.rating}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
            if (consultation.sessionNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  consultation.sessionNotes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
