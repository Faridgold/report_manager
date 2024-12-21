import 'package:flutter/material.dart';

class ReportsManagementPage extends StatefulWidget {
  final int projectId;

  ReportsManagementPage({required this.projectId});

  @override
  _ReportsManagementPageState createState() => _ReportsManagementPageState();
}

class _ReportsManagementPageState extends State<ReportsManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مدیریت گزارش‌ها'),
      ),
      body: Center(
        child: Text('گزارش‌های مربوط به پروژه ${widget.projectId}'),
      ),
    );
  }
}
