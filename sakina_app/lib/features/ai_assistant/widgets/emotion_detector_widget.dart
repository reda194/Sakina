import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/themes/app_theme.dart';

class EmotionDetectorWidget extends StatefulWidget {
  final String currentEmotion;
  final double confidence;
  final Function(String emotion, double confidence) onEmotionChanged;

  const EmotionDetectorWidget({
    super.key,
    required this.currentEmotion,
    required this.confidence,
    required this.onEmotionChanged,
  });

  @override
  State<EmotionDetectorWidget> createState() => _EmotionDetectorWidgetState();
}

class _EmotionDetectorWidgetState extends State<EmotionDetectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  bool _isAnalyzing = false;
  
  final Map<String, EmotionData> _emotions = {
    'happy': EmotionData(
      name: 'سعيد',
      icon: Icons.sentiment_very_satisfied,
      color: Colors.green,
      description: 'مزاج إيجابي ومتفائل',
    ),
    'sad': EmotionData(
      name: 'حزين',
      icon: Icons.sentiment_very_dissatisfied,
      color: Colors.blue,
      description: 'مزاج منخفض يحتاج للدعم',
    ),
    'angry': EmotionData(
      name: 'غاضب',
      icon: Icons.sentiment_dissatisfied,
      color: Colors.red,
      description: 'مشاعر غضب أو إحباط',
    ),
    'anxious': EmotionData(
      name: 'قلق',
      icon: Icons.psychology,
      color: Colors.orange,
      description: 'توتر أو قلق',
    ),
    'calm': EmotionData(
      name: 'هادئ',
      icon: Icons.self_improvement,
      color: Colors.teal,
      description: 'حالة استرخاء وهدوء',
    ),
    'neutral': EmotionData(
      name: 'محايد',
      icon: Icons.sentiment_neutral,
      color: Colors.grey,
      description: 'حالة عاطفية متوازنة',
    ),
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startEmotionDetection();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);
    
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _startEmotionDetection() {
    // Simulate emotion detection
    Future.delayed(const Duration(seconds: 2), () {
      _simulateEmotionChange();
    });
  }

  void _simulateEmotionChange() {
    if (!mounted) return;
    
    final emotions = _emotions.keys.toList();
    final random = math.Random();
    final newEmotion = emotions[random.nextInt(emotions.length)];
    final confidence = 0.6 + random.nextDouble() * 0.4; // 60-100%
    
    setState(() {
      _isAnalyzing = true;
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        widget.onEmotionChanged(newEmotion, confidence);
        setState(() {
          _isAnalyzing = false;
        });
      }
    });
    
    // Schedule next detection
    Future.delayed(const Duration(seconds: 10), () {
      _simulateEmotionChange();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEmotionData = _emotions[widget.currentEmotion] ?? _emotions['neutral']!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            currentEmotionData.color.withOpacity(0.1),
            currentEmotionData.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentEmotionData.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'كاشف المشاعر',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_isAnalyzing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentEmotionData.color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Emotion Display
          Row(
            children: [
              // Animated Emotion Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: currentEmotionData.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: currentEmotionData.color,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        currentEmotionData.icon,
                        color: currentEmotionData.color,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              
              // Emotion Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentEmotionData.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentEmotionData.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentEmotionData.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Confidence Bar
                    _buildConfidenceBar(currentEmotionData.color),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Emotion Spectrum
          _buildEmotionSpectrum(),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'الثقة: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(widget.confidence * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: widget.confidence,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmotionSpectrum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طيف المشاعر:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        Row(
          children: _emotions.entries.map((entry) {
            final isActive = entry.key == widget.currentEmotion;
            final emotionData = entry.value;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onEmotionChanged(entry.key, 0.8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? emotionData.color.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isActive 
                        ? Border.all(color: emotionData.color)
                        : null,
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: isActive ? _waveAnimation.value * 0.1 : 0,
                            child: Icon(
                              emotionData.icon,
                              color: emotionData.color,
                              size: isActive ? 20 : 16,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emotionData.name,
                        style: TextStyle(
                          fontSize: 8,
                          color: emotionData.color,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class EmotionData {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  EmotionData({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}