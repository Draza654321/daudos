import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/analytics_viewmodel.dart';

class ProgressChart extends StatelessWidget {
  final List<ProgressData> progressData;

  const ProgressChart({
    Key? key,
    required this.progressData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (progressData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No progress data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final percentage = (rod.toY * 100).toStringAsFixed(0);
              return BarTooltipItem(
                '${progressData[group.x].label}\n$percentage%',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < progressData.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      progressData[index].label,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return Container();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                final percentage = (value * 100).toInt();
                return Text(
                  '$percentage%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        barGroups: progressData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.value,
                gradient: LinearGradient(
                  colors: _getGradientColors(data.value),
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 1.0,
                  color: Colors.grey[200],
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  List<Color> _getGradientColors(double value) {
    if (value >= 0.8) {
      // Excellent performance - Green gradient
      return [
        Colors.green.shade400,
        Colors.green.shade600,
      ];
    } else if (value >= 0.6) {
      // Good performance - Blue gradient
      return [
        Colors.blue.shade400,
        Colors.blue.shade600,
      ];
    } else if (value >= 0.4) {
      // Average performance - Orange gradient
      return [
        Colors.orange.shade400,
        Colors.orange.shade600,
      ];
    } else {
      // Poor performance - Red gradient
      return [
        Colors.red.shade400,
        Colors.red.shade600,
      ];
    }
  }
}

