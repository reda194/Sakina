import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ويدجت إدخال الصوت
class VoiceInputWidget extends StatefulWidget {
  final Function(String)? onTextReceived;
  final VoidCallback? onListeningStart;
  final VoidCallback? onListeningStop;
  final bool isEnabled;
  final String? locale;
  
  const VoiceInputWidget({
    super.key,
    this.onTextReceived,
    this.onListeningStart,
    this.onListeningStop,
    this.isEnabled = true,
    this.locale = 'ar-SA',
  });
  
  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isAvailable = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeechRecognition();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _initializeSpeechRecognition() {
    // محاكاة تهيئة خدمة التعرف على الصوت
    // في التطبيق الحقيقي، ستستخدم مكتبة speech_to_text
    setState(() {
      _isAvailable = true;
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _startListening() async {
    if (!_isAvailable || !widget.isEnabled) return;
    
    try {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _confidence = 0.0;
      });
      
      _animationController.repeat(reverse: true);
      widget.onListeningStart?.call();
      
      // محاكاة بدء الاستماع
      // في التطبيق الحقيقي، ستستخدم:
      // await _speechToText.listen(
      //   onResult: _onSpeechResult,
      //   localeId: widget.locale,
      //   listenFor: const Duration(seconds: 30),
      //   pauseFor: const Duration(seconds: 3),
      // );
      
      _simulateListening();
    } catch (e) {
      _showError('خطأ في بدء الاستماع: $e');
      _stopListening();
    }
  }
  
  void _stopListening() async {
    if (!_isListening) return;
    
    try {
      setState(() {
        _isListening = false;
      });
      
      _animationController.stop();
      _animationController.reset();
      widget.onListeningStop?.call();
      
      // محاكاة إيقاف الاستماع
      // في التطبيق الحقيقي، ستستخدم:
      // await _speechToText.stop();
      
      if (_recognizedText.isNotEmpty) {
        widget.onTextReceived?.call(_recognizedText);
      }
    } catch (e) {
      _showError('خطأ في إيقاف الاستماع: $e');
    }
  }
  
  void _simulateListening() {
    // محاكاة عملية التعرف على الصوت
    Future.delayed(const Duration(seconds: 2), () {
      if (_isListening) {
        setState(() {
          _recognizedText = 'مرحبا، كيف يمكنني مساعدتك اليوم؟';
          _confidence = 0.95;
        });
      }
    });
    
    // إيقاف تلقائي بعد 5 ثوان
    Future.delayed(const Duration(seconds: 5), () {
      if (_isListening) {
        _stopListening();
      }
    });
  }
  
  void _onSpeechResult(dynamic result) {
    // معالجة نتيجة التعرف على الصوت
    // في التطبيق الحقيقي، ستستخدم:
    // setState(() {
    //   _recognizedText = result.recognizedWords;
    //   _confidence = result.confidence;
    // });
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر الميكروفون
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isListening ? _scaleAnimation.value : 1.0,
              child: Opacity(
                opacity: _isListening ? _opacityAnimation.value : 1.0,
                child: _buildMicrophoneButton(),
              ),
            );
          },
        ),
        
        // مؤشر الحالة
        if (_isListening) ...[
          const SizedBox(height: 16),
          _buildListeningIndicator(),
        ],
        
        // النص المُتعرف عليه
        if (_recognizedText.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecognizedText(),
        ],
      ],
    );
  }
  
  Widget _buildMicrophoneButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isListening
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: (_isListening
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary)
                .withOpacity(0.3),
            blurRadius: _isListening ? 20 : 8,
            spreadRadius: _isListening ? 5 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: widget.isEnabled
              ? (_isListening ? _stopListening : _startListening)
              : null,
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
  
  Widget _buildListeningIndicator() {
    return Column(
      children: [
        Text(
          'أستمع...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildSoundWaves(),
      ],
    );
  }
  
  Widget _buildSoundWaves() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_animationController.value + delay) % 1.0;
            final height = 4 + (animationValue * 16);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
  
  Widget _buildRecognizedText() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'النص المُتعرف عليه:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_confidence > 0)
                Text(
                  '${(_confidence * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _confidence > 0.8
                        ? Colors.green
                        : _confidence > 0.6
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _recognizedText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _recognizedText = '';
                    _confidence = 0.0;
                  });
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('مسح'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onTextReceived?.call(_recognizedText);
                  setState(() {
                    _recognizedText = '';
                    _confidence = 0.0;
                  });
                },
                icon: const Icon(Icons.send, size: 16),
                label: const Text('إرسال'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ويدجت مبسط لزر الميكروفون
class SimpleMicrophoneButton extends StatefulWidget {
  final Function(String)? onTextReceived;
  final bool isEnabled;
  final double size;
  final Color? color;
  
  const SimpleMicrophoneButton({
    super.key,
    this.onTextReceived,
    this.isEnabled = true,
    this.size = 48,
    this.color,
  });
  
  @override
  State<SimpleMicrophoneButton> createState() => _SimpleMicrophoneButtonState();
}

class _SimpleMicrophoneButtonState extends State<SimpleMicrophoneButton> {
  bool _isListening = false;
  
  void _toggleListening() {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }
  
  void _startListening() {
    // محاكاة بدء الاستماع
    HapticFeedback.lightImpact();
    
    // محاكاة النتيجة بعد 3 ثوان
    Future.delayed(const Duration(seconds: 3), () {
      if (_isListening) {
        widget.onTextReceived?.call('مرحبا، هذا نص تجريبي من الميكروفون');
        setState(() {
          _isListening = false;
        });
      }
    });
  }
  
  void _stopListening() {
    HapticFeedback.lightImpact();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening
              ? Theme.of(context).colorScheme.error
              : (widget.color ?? Theme.of(context).colorScheme.primary),
          boxShadow: _isListening
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}

/// ويدجت إعدادات الصوت
class VoiceSettingsWidget extends StatefulWidget {
  final String? selectedLocale;
  final Function(String)? onLocaleChanged;
  final bool isEnabled;
  final Function(bool)? onEnabledChanged;
  
  const VoiceSettingsWidget({
    super.key,
    this.selectedLocale,
    this.onLocaleChanged,
    this.isEnabled = true,
    this.onEnabledChanged,
  });
  
  @override
  State<VoiceSettingsWidget> createState() => _VoiceSettingsWidgetState();
}

class _VoiceSettingsWidgetState extends State<VoiceSettingsWidget> {
  static const Map<String, String> supportedLocales = {
    'ar-SA': 'العربية (السعودية)',
    'ar-EG': 'العربية (مصر)',
    'ar-AE': 'العربية (الإمارات)',
    'en-US': 'English (US)',
    'en-GB': 'English (UK)',
  };
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات الصوت',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // تفعيل/إلغاء تفعيل الصوت
            SwitchListTile(
              title: const Text('تفعيل إدخال الصوت'),
              subtitle: const Text('السماح باستخدام الميكروفون'),
              value: widget.isEnabled,
              onChanged: widget.onEnabledChanged,
            ),
            
            const Divider(),
            
            // اختيار اللغة
            ListTile(
              title: const Text('لغة التعرف على الصوت'),
              subtitle: Text(
                supportedLocales[widget.selectedLocale] ?? 'غير محدد',
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: widget.isEnabled ? _showLocaleSelector : null,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLocaleSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر لغة التعرف على الصوت',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...supportedLocales.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                leading: Radio<String>(
                  value: entry.key,
                  groupValue: widget.selectedLocale,
                  onChanged: (value) {
                    widget.onLocaleChanged?.call(value!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  widget.onLocaleChanged?.call(entry.key);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}