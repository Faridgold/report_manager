import 'dart:io';
import 'package:flutter/material.dart';
import 'package:report_manager/pages/reports_management_page.dart';
import 'package:report_manager/pages/database_helper.dart';

class ReportPreviewPage extends StatefulWidget {
  final int projectId;
  final String projectName;
  final String clientName;
  final String managerName;
  final String supervisorName;
  final String? companyLogo;
  final String? managerSignature;
  final String? supervisorSignature;
  final DateTime date;
  final String weatherType;
  final int minTemp;
  final int maxTemp;
  final String projectAddress;
  final String reportNumber;
  final Map<String, List<Map<String, dynamic>>> details;

  ReportPreviewPage({
    required this.projectId,
    required this.projectName,
    required this.clientName,
    required this.managerName,
    required this.supervisorName,
    this.companyLogo,
    this.managerSignature,
    this.supervisorSignature,
    required this.date,
    required this.weatherType,
    required this.minTemp,
    required this.maxTemp,
    required this.projectAddress,
    required this.reportNumber,
    required this.details,
  });

  @override
  _ReportPreviewPageState createState() => _ReportPreviewPageState();
}

class _ReportPreviewPageState extends State<ReportPreviewPage> {
  bool _isLoading = false;

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.companyLogo != null)
          Align(
            alignment: Alignment.topLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(widget.companyLogo!),
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Text(
                "گزارش روزانه پروژه",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                widget.projectName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildProjectInfoRow(
          'تاریخ گزارش:',
          '${widget.date.year}/${widget.date.month}/${widget.date.day}',
        ),
        _buildProjectInfoRow('شماره گزارش:', widget.reportNumber),
        _buildProjectInfoRow('نام کارفرما:', widget.clientName),
        _buildProjectInfoRow('آب و هوا:', widget.weatherType),
        _buildProjectInfoRow('دمای حداقل:', '${widget.minTemp}°C'),
        _buildProjectInfoRow('دمای حداکثر:', '${widget.maxTemp}°C'),
        Divider(thickness: 1, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildProjectInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '---' : value,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 8),
        items.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'اطلاعاتی اضافه نشده است',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                ),
              )
            : Table(
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(0.2),
                  1: FlexColumnWidth(0.8),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                    ),
                    children: [
                      _buildTableCell('ردیف', isHeader: true),
                      _buildTableCell('جزئیات', isHeader: true),
                    ],
                  ),
                  ...items.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    Map<String, dynamic> item = entry.value;
                    return TableRow(
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.grey.shade50
                            : Colors.white,
                      ),
                      children: [
                        _buildTableCell(index.toString()),
                        _buildTableCell(item['details'] ?? 'بدون توضیحات'),
                      ],
                    );
                  }).toList(),
                ],
              ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 14 : 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black87 : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseHelper.instance;

      Map<String, dynamic> reportToInsert = {
        'projectId': widget.projectId,
        'projectName': widget.projectName,
        'clientName': widget.clientName,
        'managerName': widget.managerName,
        'supervisorName': widget.supervisorName,
        'date': widget.date.toIso8601String(),
        'weatherType': widget.weatherType,
        'minTemp': widget.minTemp,
        'maxTemp': widget.maxTemp,
        'reportNumber': widget.reportNumber,
        'projectAddress': widget.projectAddress,
      };

      int result = await db.insertReport(reportToInsert);

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('گزارش با موفقیت تایید و ذخیره شد')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReportsManagementPage(projectId: widget.projectId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره گزارش. لطفاً مجدداً تلاش کنید.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در تایید گزارش: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSignatures() {
    return Column(
      children: [
        if (widget.supervisorSignature != null)
          _buildSignatureRow(
              'نام سرپرست کارگاه :', widget.supervisorName, widget.supervisorSignature),
        if (widget.managerSignature != null)
          _buildSignatureRow(
              'نام مدیر:', widget.managerName, widget.managerSignature),
      ],
    );
  }

  Widget _buildSignatureRow(String title, String name, String? signature) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title $name',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue.shade900),
                ),
                SizedBox(height: 8),
                signature != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image.file(
                          File(signature),
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Text('امضا موجود نیست',
                        style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پیش‌نمایش گزارش',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildSection(
                  'فعالیت‌های انجام شده', widget.details['activities'] ?? []),
              SizedBox(height: 16),
              _buildSection(
                  'نیروهای کاری مستقیم', widget.details['directWorkers'] ?? []),
              SizedBox(height: 16),
              _buildSection('نیروهای کاری غیرمستقیم',
                  widget.details['indirectWorkers'] ?? []),
              SizedBox(height: 16),
              _buildSection('نیروهای کاری قراردادی',
                  widget.details['contractWorkers'] ?? []),
              SizedBox(height: 16),
              _buildSection('مصالح', widget.details['materials'] ?? []),
              SizedBox(height: 16),
              _buildSection('ماشین‌آلات', widget.details['machines'] ?? []),
              SizedBox(height: 16),
              _buildSection(
                  'موانع و مشکلات', widget.details['safety'] ?? []),
              SizedBox(height: 16),
              _buildSection('فعالیت‌های روز بعد',
                  widget.details['nextActivities'] ?? []),
              SizedBox(height: 20),
              _buildSignatures(),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text('تایید گزارش',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'ویرایش گزارش',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
