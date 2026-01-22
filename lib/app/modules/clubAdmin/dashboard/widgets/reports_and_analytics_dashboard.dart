import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_analytics_card.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsAndAnalyticsDashboard extends StatelessWidget {
  const ReportsAndAnalyticsDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reports & Analytics", style: AppTextStyles.subHeading),
        SizedBox(height: 15),
        Row(
          children: [
            // Active Players (Line Chart)
            Expanded(
              child: AnalyticsCard(
                style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Inter'),
                title: "Active Players",
                value: "48 Players",
                percentage: "+9.3%",
                chart: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 1),
                          const FlSpot(1, 3),
                          const FlSpot(2, 2),
                          const FlSpot(3, 5),
                          const FlSpot(4, 3),
                          const FlSpot(5, 4),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.flashyGreen,
                        ),
                      ),
                    ],
                  ),
                ), stats: 'This Month',
              ),
            ),
            const SizedBox(width: 15),
            // Games Played (Bar Chart)
            Expanded(
              child: AnalyticsCard(
                style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Inter'),
                stats: "This Month",
                title: "Games Played",
                value: "22 Games",
                percentage: "+5.4%",
                chart: _buildScrollableMonthBarChart(),
              ),
            ),
          ],
        ),
        // 5. View All Button
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              // Get.to(()=>ReportsAndAnalytics());
            },
            icon: const Icon(Icons.grid_view, size: 18),
            label: const Text("View All"),
            
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableMonthBarChart() {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
    final values = [5.0, 8.0, 6.0, 9.0, 7.0, 10.0];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: months.length * 35, // controls scrolling
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),

            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= months.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        months[value.toInt()],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            barGroups: List.generate(
              values.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index],
                    width: 24,
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
