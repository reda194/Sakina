import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/analytics_provider.dart';
import '../../tools/providers/mood_provider.dart';
import 'package:provider/provider.dart';

class MoodTrendChart extends StatelessWidget {
  final AnalyticsProvider analytics;

  const MoodTrendChart({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'اتجاه المزاج',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Consumer<MoodProvider>(
              builder: (context, moodProvider, child) {
                final entries = _getChartData(moodProvider);
                
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد بيانات للعرض',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return _buildBottomTitle(value.toInt(), entries);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return _buildLeftTitle(value.toInt());
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    minX: 0,
                    maxX: (entries.length - 1).toDouble(),
                    minY: 1,
                    maxY: 5,
                    lineBarsData: [
                      // Mood line
                      LineChartBarData(
                        spots: entries.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value['mood'].toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.primaryColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.3),
                              AppTheme.primaryColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Energy line
                      if (_hasEnergyData(entries))
                        LineChartBarData(
                          spots: entries.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value['energy'] ?? 3).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.successColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: AppTheme.successColor,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      // Sleep line
                      if (_hasSleepData(entries))
                        LineChartBarData(
                          spots: entries.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value['sleep'] ?? 3).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.infoColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: AppTheme.infoColor,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final entry = entries[spot.x.toInt()];
                            final date = DateFormat('dd/MM').format(entry['date']);
                            
                            String label;
                            Color color;
                            
                            if (spot.barIndex == 0) {
                              label = 'المزاج: ${spot.y.toStringAsFixed(1)}';
                              color = AppTheme.primaryColor;
                            } else if (spot.barIndex == 1) {
                              label = 'الطاقة: ${spot.y.toStringAsFixed(1)}';
                              color = AppTheme.successColor;
                            } else {
                              label = 'النوم: ${spot.y.toStringAsFixed(1)}';
                              color = AppTheme.infoColor;
                            }
                            
                            return LineTooltipItem(
                              '$date\n$label',
                              TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildInsights(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('المزاج', AppTheme.primaryColor),
        const SizedBox(width: 12),
        _buildLegendItem('الطاقة', AppTheme.successColor),
        const SizedBox(width: 12),
        _buildLegendItem('النوم', AppTheme.infoColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTitle(int index, List<Map<String, dynamic>> entries) {
    if (index >= 0 && index < entries.length) {
      final date = entries[index]['date'] as DateTime;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          DateFormat('dd/MM').format(date),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildLeftTitle(int value) {
    String label;
    switch (value) {
      case 1:
        label = 'سيء جداً';
        break;
      case 2:
        label = 'سيء';
        break;
      case 3:
        label = 'عادي';
        break;
      case 4:
        label = 'جيد';
        break;
      case 5:
        label = 'ممتاز';
        break;
      default:
        return const SizedBox();
    }
    
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildInsights() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getInsightText(),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getChartData(MoodProvider moodProvider) {
    final now = DateTime.now();
    final startDate = _getStartDate(now);
    final entries = moodProvider.getMoodEntriesInRange(startDate, now);
    
    // Group by date and get the latest entry for each day
    final Map<String, Map<String, dynamic>> dailyData = {};
    
    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      dailyData[dateKey] = {
        'date': entry.timestamp,
        'mood': entry.mood,
        'energy': entry.energyLevel,
        'sleep': entry.sleepQuality,
      };
    }
    
    // Convert to list and sort by date
    final result = dailyData.values.toList();
    result.sort((a, b) => a['date'].compareTo(b['date']));
    
    return result;
  }

  DateTime _getStartDate(DateTime now) {
    switch (analytics.selectedPeriod) {
      case 'week':
        return now.subtract(const Duration(days: 7));
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'quarter':
        return DateTime(now.year, now.month - 3, now.day);
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  bool _hasEnergyData(List<Map<String, dynamic>> entries) {
    return entries.any((entry) => entry['energy'] != null);
  }

  bool _hasSleepData(List<Map<String, dynamic>> entries) {
    return entries.any((entry) => entry['sleep'] != null);
  }

  String _getInsightText() {
    if (analytics.averageMood >= 4) {
      return 'مزاجك في تحسن مستمر! استمر في الأنشطة الإيجابية.';
    } else if (analytics.averageMood >= 3) {
      return 'مزاجك مستقر. حاول إضافة المزيد من الأنشطة المفيدة.';
    } else {
      return 'مزاجك يحتاج إلى اهتمام. فكر في التحدث مع مختص.';
    }
  }
}