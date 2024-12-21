import 'package:flutter/material.dart';

class ReportDetailsPage extends StatelessWidget {
  final int reportId;
  final String projectName;
  final String date;
  final String weather;
  final int minTemp;
  final int maxTemp;

  ReportDetailsPage({
    required this.reportId,
    required this.projectName,
    required this.date,
    required this.weather,
    required this.minTemp,
    required this.maxTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جزئیات گزارش'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('پروژه: $projectName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('تاریخ: $date', style: TextStyle(fontSize: 16)),
            Text('آب و هوا: $weather', style: TextStyle(fontSize: 16)),
            Text('حداقل دما: $minTemp°', style: TextStyle(fontSize: 16)),
            Text('حداکثر دما: $maxTemp°', style: TextStyle(fontSize: 16)),
            Divider(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                children: [
                  _buildTile(context, 'فعالیت‌های انجام‌شده', Icons.work, () {
                    // Navigate to activity page
                  }),
                  _buildTile(context, 'نیروهای کاری مستقیم', Icons.person, () {
                    // Navigate to direct workforce page
                  }),
                  _buildTile(context, 'نیروهای کاری غیرمستقیم', Icons.group_work, () {
                    // Navigate to indirect workforce page
                  }),
                  _buildTile(context, 'مواد و مصالح', Icons.construction, () {
                    // Navigate to materials page
                  }),
                  _buildTile(context, 'ماشین‌آلات و تجهیزات', Icons.precision_manufacturing, () {
                    // Navigate to machinery page
                  }),
                  _buildTile(context, 'موانع و مشکلات', Icons.error_outline, () {
                    // Navigate to obstacles page
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue[700]),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
