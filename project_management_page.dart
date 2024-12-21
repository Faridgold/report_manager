import 'package:flutter/material.dart';
import 'project_details_page.dart';
import 'create_project_page.dart';
import 'database_helper.dart';

class ProjectManagementPage extends StatefulWidget {
  @override
  _ProjectManagementPageState createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  List<Map<String, dynamic>> projects = [];

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

  Future<void> _deleteProject(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteProject(id);
    _loadProjects();
  }

  void _confirmDeleteProject(int id, String projectName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('"$projectName" !حذف پروژه'),
          content: Text(
              'آیا مطمئن هستید که می‌خواهید پروژه را حذف کنید؟ تمامی گزارش‌های مرتبط نیز حذف خواهند شد.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('لغو'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteProject(id);
    }
  }

  void _navigateToCreateProject([Map<String, dynamic>? existingProject]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateProjectPage(existingProject: existingProject),
      ),
    );
    if (result == true) {
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مدیریت پروژه‌ها'),
      ),
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'پروژه‌ای تعریف نشده است.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _navigateToCreateProject(),
                    child: Text('ایجاد پروژه جدید'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ListTile(
                  title: Text(project['name']),
                  subtitle: Text('کارفرما: ${project['client']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(project: project),
                      ),
                    ).then((_) => _loadProjects());
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _confirmDeleteProject(project['id'], project['name']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateProject(),
        child: Icon(Icons.add),
      ),
    );
  }
}
