import 'package:flutter/material.dart';
import 'package:report_manager/pages/add_activity_page.dart';
import 'package:report_manager/pages/add_direct_worker_page.dart';
import 'package:report_manager/pages/add_indirect_worker_page.dart';
import 'package:report_manager/pages/add_materials_page.dart';
import 'package:report_manager/pages/add_machines_page.dart';
import 'package:report_manager/pages/add_safety_page.dart';
import 'package:report_manager/pages/add_next_activities_page.dart';
import 'package:report_manager/pages/add_photos_page.dart';
import 'package:report_manager/pages/add_contract_worker_page.dart';
import 'dart:io';
import 'package:report_manager/pages/report_preview_page.dart';

class CreateReportDetailsPage extends StatefulWidget {
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

  CreateReportDetailsPage({
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
  });

  @override
  _CreateReportDetailsPageState createState() =>
      _CreateReportDetailsPageState();
}

class _CreateReportDetailsPageState extends State<CreateReportDetailsPage> {
  Map<String, List<Map<String, dynamic>>> details = {
    'activities': [],
    'directWorkers': [],
    'indirectWorkers': [],
    'contractWorkers': [],
    'materials': [],
    'machines': [],
    'safety': [],
    'nextActivities': [],
    'photos': [],
  };

  bool _autoAddEnabled = false;

  void _autoAddIncompleteActivities() {
    if (_autoAddEnabled) {
      final incompleteActivities = details['activities']?.where((activity) {
        final progress = activity['progressPercentage'] ?? '0%';
        final progressValue = int.tryParse(progress.replaceAll('%', '')) ?? 0;
        return progressValue < 100;
      }).toList();

      if (incompleteActivities != null && incompleteActivities.isNotEmpty) {
        setState(() {
          details['nextActivities'] = [...incompleteActivities];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فعالیت‌های ناقص به فعالیت‌های روز بعد منتقل شدند.')),
        );
      }
    } else {
      setState(() {
        details['nextActivities']?.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فعالیت‌های روز بعد پاک‌سازی شدند.')),
      );
    }
  }

  void _openPage(BuildContext context, String type, Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    if (result != null) {
      setState(() {
        if (type == 'photos' && result is List<File>) {
          final List<Map<String, dynamic>> photoData = result
              .map((file) => {'file': file})
              .toList();
          details[type]?.addAll(photoData);
        } else {
          if (type == 'activities') {
            result['title'] ??= 'بدون عنوان';
            result['details'] ??= 'بدون جزئیات';
          }
          details[type]?.add(result);
        }
      });
    }
  }

  Widget _buildDetailList(String type) {
    final items = details[type] ?? [];
    if (items.isEmpty) {
      return Text(
        'اطلاعاتی اضافه نشده است',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    if (type == 'photos') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(items.length, (index) {
          final photo = items[index]['file'] as File?;
          if (photo == null) return SizedBox.shrink();

          return Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  photo,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    details[type]?.removeAt(index);
                  });
                },
              ),
            ],
          );
        }),
      );
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              child: Text((index + 1).toString()),
            ),
            title: Text(item['title'] ?? 'عنوان نامشخص'),
            subtitle: Text(item['details'] ?? 'توضیحات ثبت نشده'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editDetail(context, type, index, item),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      details[type]?.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _editDetail(BuildContext context, String type, int index, Map<String, dynamic> item) async {
    Widget page;

    if (type == 'activities') {
      item['activityName'] = item['title'];
    }

    switch (type) {
      case 'activities':
        page = AddActivityPage(existingActivity: item);
        break;
      case 'directWorkers':
        page = AddDirectWorkerPage(existingWorker: item);
        break;
      case 'indirectWorkers':
        page = AddIndirectWorkerPage(
          existingWorker: item,
          activities: details['activities']
                  ?.map((activity) => activity['activityName']?.toString() ?? 'نامشخص')
                  .toList() ?? [],
        );
        break;
      case 'contractWorkers':
        page = AddContractWorkerPage(
          existingWorker: item,
          activities: details['activities']
                  ?.map((activity) => activity['activityName']?.toString() ?? 'نامشخص')
                  .toList() ?? [],
          onWorkerAdded: (editedWorker) {
            setState(() {
              details[type]?[index] = editedWorker;
            });
          },
        );
        break;
      case 'materials':
        page = AddMaterialsPage(existingMaterial: item);
        break;
      case 'machines':
        page = AddMachinesPage(existingMachine: item);
        break;
      case 'safety':
        page = AddSafetyPage(existingSafety: item);
        break;
      case 'nextActivities':
        page = AddNextActivitiesPage(existingActivity: item);
        break;
      default:
        page = Container();
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    if (result != null) {
      setState(() {
        details[type]?[index] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ایجاد جزئیات گزارش'),
        actions: [
          Row(
            children: [
              Text('انتقال خودکار'),
              Switch(
                value: _autoAddEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoAddEnabled = value;
                    _autoAddIncompleteActivities();
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'پروژه: ${widget.projectName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('تاریخ: ${widget.date.year}/${widget.date.month}/${widget.date.day}'),
                  Text('آدرس پروژه: ${widget.projectAddress}'),
                  Text('آب و هوا: ${widget.weatherType}'),
                  Text('دمای حداقل: ${widget.minTemp}'),
                  Text('دمای حداکثر: ${widget.maxTemp}'),
                  Divider(),
                  _buildTile(context, 'فعالیت‌های انجام شده', Icons.work, () {
                    _openPage(context, 'activities', AddActivityPage());
                  }, _buildDetailList('activities')),
                  _buildTile(context, 'نیروهای کاری مستقیم', Icons.person, () {
                    _openPage(context, 'directWorkers', AddDirectWorkerPage());
                  }, _buildDetailList('directWorkers')),
                  _buildTile(context, 'نیروهای کاری غیرمستقیم', Icons.group_work, () {
                    _openPage(
                      context,
                      'indirectWorkers',
                      AddIndirectWorkerPage(
                        activities: details['activities']
                                ?.map((activity) => activity['title'] as String)
                                .toList() ?? [],
                      ),
                    );
                  }, _buildDetailList('indirectWorkers')),
                  _buildTile(context, 'نیروهای کاری مستقیم قراردادی', Icons.assignment_ind, () {
                    _openPage(
                      context,
                      'contractWorkers',
                      AddContractWorkerPage(
                        activities: details['activities']
                                ?.map((activity) => activity['title'] as String)
                                .toList() ?? [],
                        onWorkerAdded: (newWorker) {
                          setState(() {
                            details['contractWorkers']?.add(newWorker);
                          });
                        },
                      ),
                    );
                  }, _buildDetailList('contractWorkers')),
                  _buildTile(context, 'مصالح', Icons.construction, () {
                    _openPage(context, 'materials', AddMaterialsPage());
                  }, _buildDetailList('materials')),
                  _buildTile(context, 'ماشین‌آلات و ابزار', Icons.precision_manufacturing, () {
                    _openPage(context, 'machines', AddMachinesPage());
                  }, _buildDetailList('machines')),
                  _buildTile(context, 'موانع و مشکلات', Icons.error_outline, () {
                    _openPage(context, 'safety', AddSafetyPage());
                  }, _buildDetailList('safety')),
                  _buildTile(context, 'فعالیت‌های روز بعد', Icons.event_note, () {
                    _openPage(context, 'nextActivities', AddNextActivitiesPage());
                  }, _buildDetailList('nextActivities')),
                  _buildTile(context, 'آپلود عکس', Icons.camera_alt, () {
                    _openPage(context, 'photos', AddPhotosPage());
                  }, _buildDetailList('photos')),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPreviewPage(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      clientName: widget.clientName,
                      managerName: widget.managerName,
                      supervisorName: widget.supervisorName,
                      companyLogo: widget.companyLogo,
                      managerSignature: widget.managerSignature,
                      supervisorSignature: widget.supervisorSignature,
                      date: widget.date,
                      weatherType: widget.weatherType,
                      minTemp: widget.minTemp,
                      maxTemp: widget.maxTemp,
                      projectAddress: widget.projectAddress,
                      reportNumber: 1.toString(), // یا مقدار متغیر دیگر
                      details: details,
                    ),
                  ),
                );
              },
              child: Text('تایید و پیش‌نمایش کلی گزارش'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, VoidCallback onTap, Widget detailList) {
    return ExpansionTile(
      leading: Icon(icon, size: 40),
      title: Text(title, style: TextStyle(fontSize: 16)),
      children: [
        ElevatedButton(
          onPressed: onTap,
          child: Text('افزودن $title'),
        ),
        detailList,
      ],
    );
  }
}
