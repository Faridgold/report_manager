import 'package:flutter/material.dart';
import 'package:report_manager/pages/edit_project_page.dart';
import 'package:report_manager/pages/reports_management_page.dart';
import 'package:report_manager/pages/database_helper.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;

  ProjectDetailsPage({required this.project});

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Map<String, dynamic> project;

  @override
  void initState() {
    super.initState();
    project = widget.project;
  }

  Future<void> _navigateToEditProject() async {
    final updatedProject = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProjectPage(
          project: project,
          onEditProject: (updatedProject) async {
            final db = DatabaseHelper.instance;
            int result = await db.updateProject(updatedProject);
            if (result > 0) {
              setState(() {
                project = updatedProject;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('پروژه با موفقیت ویرایش شد')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطا در ویرایش پروژه')),
              );
            }
          },
        ),
      ),
    );

    if (updatedProject != null && updatedProject is Map<String, dynamic>) {
      setState(() {
        project = updatedProject;
      });
    }
  }

  void _navigateToReportsManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportsManagementPage(projectId: project['id']),
      ),
    );
  }

  Future<void> _deleteProject() async {
    final db = DatabaseHelper.instance;
    int result = await db.deleteProject(project['id']);
    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('پروژه با موفقیت حذف شد')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف پروژه')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جزئیات پروژه'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('نام پروژه', project['name']),
            _buildDetailRow('کارفرما', project['client']),
            _buildDetailRow('آدرس', project['address']),
            _buildDetailRow('مدیر', project['manager']),
            _buildDetailRow('سرپرست', project['supervisor']),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _navigateToEditProject,
                  icon: Icon(Icons.edit),
                  label: Text('ویرایش'),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _navigateToReportsManagement,
                  icon: Icon(Icons.list),
                  label: Text('مدیریت گزارش‌ها'),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _deleteProject,
                  icon: Icon(Icons.delete),
                  label: Text('حذف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'نامشخص',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
