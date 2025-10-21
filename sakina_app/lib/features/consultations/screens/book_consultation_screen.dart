import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/consultation_model.dart';
import '../providers/consultation_provider.dart';

class BookConsultationScreen extends StatefulWidget {
  final SpecialistModel specialist;

  const BookConsultationScreen({
    super.key,
    required this.specialist,
  });

  @override
  State<BookConsultationScreen> createState() => _BookConsultationScreenState();
}

class _BookConsultationScreenState extends State<BookConsultationScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  ConsultationType _selectedType = ConsultationType.video;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز استشارة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpecialistCard(),
            const SizedBox(height: 24),
            _buildConsultationTypeSection(),
            const SizedBox(height: 24),
            _buildDateSelectionSection(),
            const SizedBox(height: 24),
            _buildTimeSlotSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildPricingSection(),
            const SizedBox(height: 32),
            _buildBookButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                widget.specialist.name.substring(0, 1),
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
                    widget.specialist.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.specialist.title,
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
                        '${widget.specialist.rating}',
                        style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildConsultationTypeSection() {
    return _buildSection(
      'نوع الاستشارة',
      Icons.video_call,
      Column(
        children: ConsultationType.values.map((type) {
          return RadioListTile<ConsultationType>(
            value: type,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
            title: Row(
              children: [
                Icon(
                  _getTypeIcon(type),
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(_getTypeText(type)),
              ],
            ),
            subtitle: Text(
              _getTypeDescription(type),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            activeColor: AppTheme.primaryColor,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    return _buildSection(
      'اختيار التاريخ',
      Icons.calendar_today,
      TableCalendar<DateTime>(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: _selectedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _selectedTimeSlot = null; // Reset time slot when date changes
          });
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.saturday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(
            color: AppTheme.errorColor,
          ),
        ),
        enabledDayPredicate: (day) {
          // Disable past dates and weekends (Friday and Saturday)
          if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
            return false;
          }
          return day.weekday != DateTime.friday && day.weekday != DateTime.saturday;
        },
      ),
    );
  }

  Widget _buildTimeSlotSection() {
    return _buildSection(
      'اختيار الوقت',
      Icons.access_time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedDate.isBefore(DateTime.now().add(const Duration(days: 1))))
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يرجى اختيار موعد قبل 24 ساعة على الأقل',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _timeSlots[index];
              final isSelected = _selectedTimeSlot == timeSlot;
              final isAvailable = _isTimeSlotAvailable(timeSlot);

              return InkWell(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          _selectedTimeSlot = timeSlot;
                        });
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : isAvailable
                            ? AppTheme.backgroundColor
                            : AppTheme.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : isAvailable
                              ? AppTheme.primaryColor.withOpacity(0.3)
                              : AppTheme.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      'ملاحظات إضافية (اختيارية)',
      Icons.note_add,
      TextField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'اكتب أي ملاحظات أو تفاصيل تريد مشاركتها مع المختص...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return _buildSection(
      'تفاصيل الدفع',
      Icons.payment,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.primaryColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سعر الجلسة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${widget.specialist.pricePerSession.toInt()} ر.س',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رسوم الخدمة',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '0 ر.س',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.specialist.pricePerSession.toInt()} ر.س',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    final canBook = _selectedTimeSlot != null &&
        _selectedDate.isAfter(DateTime.now()) &&
        !_isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canBook ? _bookConsultation : null,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'تأكيد الحجز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
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
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
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
        return 'دردشة نصية';
      case ConsultationType.inPerson:
        return 'حضوري';
    }
  }

  String _getTypeDescription(ConsultationType type) {
    switch (type) {
      case ConsultationType.video:
        return 'استشارة مرئية عبر الإنترنت';
      case ConsultationType.audio:
        return 'استشارة صوتية عبر الهاتف';
      case ConsultationType.chat:
        return 'استشارة كتابية عبر الدردشة';
      case ConsultationType.inPerson:
        return 'استشارة وجهاً لوجه في العيادة';
    }
  }

  bool _isTimeSlotAvailable(String timeSlot) {
    // Simple logic to simulate availability
    // In a real app, this would check against the specialist's schedule
    final hour = int.parse(timeSlot.split(':')[0]);
    
    // Make some slots unavailable for demo purposes
    if (_selectedDate.weekday == DateTime.sunday && hour < 12) {
      return false;
    }
    
    if (_selectedDate.weekday == DateTime.thursday && (hour == 15 || hour == 16)) {
      return false;
    }
    
    return true;
  }

  Future<void> _bookConsultation() async {
    if (_selectedTimeSlot == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ConsultationProvider>(context, listen: false);
      
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(_selectedTimeSlot!.split(':')[0]),
        int.parse(_selectedTimeSlot!.split(':')[1]),
      );

      await provider.bookConsultation(
        specialistId: widget.specialist.id,
        scheduledDate: scheduledDateTime,
        type: _selectedType,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حجز الاستشارة بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحجز: $e'),
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
}