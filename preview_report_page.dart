import 'package:flutter/material.dart';

class PreviewReportPage extends StatelessWidget {
  final String project;
  final DateTime date;
  final String activities;

  PreviewReportPage({required this.project, required this.date, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('پیش‌نمایش گزارش'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'پروژه: $project',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'تاریخ: ${date.toLocal()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'فعالیت‌ها:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              activities,
              style: TextStyle(fontSize: 14),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('بازگشت'),
            ),
          ],
        ),
      ),
    );
  }
}
