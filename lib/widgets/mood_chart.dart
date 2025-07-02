import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/analytics_viewmodel.dart';

class MoodChart extends StatelessWidget {
  final List<MoodTrendData> moodData;

  const MoodChart({
    Key? key,
    required this.moodData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (moodData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mood,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No mood data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
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
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
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
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < moodData.length) {
                  final date = moodData[index].date;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        minX: 0,
        maxX: (moodData.length - 1).toDouble(),
        minY: 0,
        maxY: 5,
        lineBarsData: [
          // Energy line
          LineChartBarData(
            spots: moodData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.energy);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.8),
                Colors.orange,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.orange,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.orange.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Focus line
          LineChartBarData(
            spots: moodData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.focus);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.8),
                Colors.blue,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
          
          // Clarity line
          LineChartBarData(
            spots: moodData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.clarity);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.8),
                Colors.green,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.green,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                String label = '';
                Color color = Colors.white;
                
                switch (barSpot.barIndex) {
                  case 0:
                    label = 'Energy';
                    color = Colors.orange;
                    break;
                  case 1:
                    label = 'Focus';
                    color = Colors.blue;
                    break;
                  case 2:
                    label = 'Clarity';
                    color = Colors.green;
                    break;
                }
                
                return LineTooltipItem(
                  '$label: ${flSpot.y.toStringAsFixed(1)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

