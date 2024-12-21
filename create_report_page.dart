import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:report_manager/pages/create_report_details_page.dart';
import 'package:report_manager/pages/database_helper.dart';

class CreateReportPage extends StatefulWidget {
  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedProject;
  String selectedProjectAddress = "آدرس پیش‌فرض پروژه"; // مقدار پیش‌فرض
  Jalali selectedDate = Jalali.now();
  String selectedWeatherType = 'آفتابی';
  int selectedMinTemp = 15;
  int selectedMaxTemp = 25;

  List<Map<String, dynamic>> projects = [];
  List<String> weatherTypes = ['آفتابی', 'بارانی', 'برفی'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final db = DatabaseHelper.instance;
    final loadedProjects = await db.getProjects();
    setState(() {
      projects = loadedProjects;
    });
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    final db = DatabaseHelper.instance;

    // دریافت اطلاعات پروژه از لیست
    final selectedProjectData =
        projects.firstWhere((project) => project['name'] == selectedProject);

    if (selectedProjectData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('پروژه‌ای با این نام یافت نشد')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReportDetailsPage(
          projectId: selectedProjectData['id'],
          projectName: selectedProjectData['name'],
          clientName: selectedProjectData['client'],
          managerName: selectedProjectData['manager'],
          supervisorName: selectedProjectData['supervisor'],
          companyLogo: selectedProjectData['companyLogo'],
          managerSignature: selectedProjectData['managerSignature'],
          supervisorSignature: selectedProjectData['supervisorSignature'],
          date: selectedDate.toDateTime(),
          weatherType: selectedWeatherType,
          minTemp: selectedMinTemp,
          maxTemp: selectedMaxTemp,
          projectAddress: selectedProjectAddress, // مقدار projectAddress (اضافه شده)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ایجاد گزارش'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedProject,
                decoration: InputDecoration(labelText: 'انتخاب پروژه'),
                items: projects
                    .map<DropdownMenuItem<String>>((project) => DropdownMenuItem<String>(
                          value: project['name'] as String, // تبدیل به String
                          child: Text(project['name'] as String), // تبدیل به String
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProject = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'لطفا پروژه را انتخاب کنید' : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                    'تاریخ: ${selectedDate.year}/${selectedDate.month}/${selectedDate.day}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    Jalali? picked = await showPersianDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: Jalali(1390, 1, 1),
                      lastDate: Jalali(1450, 12, 29),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text('انتخاب تاریخ'),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedWeatherType,
                decoration: InputDecoration(labelText: 'نوع آب و هوا'),
                items: weatherTypes
                    .map((weather) => DropdownMenuItem(
                          value: weather,
                          child: Text(weather),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWeatherType = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMinTemp,
                      decoration: InputDecoration(labelText: 'دمای حداقل'),
                      items: List.generate(
                              50,
                              (index) =>
                                  DropdownMenuItem(value: index, child: Text('$index')))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMinTemp = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMaxTemp,
                      decoration: InputDecoration(labelText: 'دمای حداکثر'),
                      items: List.generate(
                              50,
                              (index) =>
                                  DropdownMenuItem(value: index, child: Text('$index')))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMaxTemp = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveReport,
                child: Text('تایید'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('انصراف'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
