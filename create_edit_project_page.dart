import 'package:flutter/material.dart';
import 'database_helper.dart';

class CreateEditProjectPage extends StatefulWidget {
  final Map<String, dynamic>? project; // برای ویرایش پروژه
  final VoidCallback onProjectSaved;

  CreateEditProjectPage({this.project, required this.onProjectSaved});

  @override
  _CreateEditProjectPageState createState() => _CreateEditProjectPageState();
}

class _CreateEditProjectPageState extends State<CreateEditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String client = '';
  String address = '';
  String manager = '';
  String supervisor = '';

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      name = widget.project!['name'];
      client = widget.project!['client'];
      address = widget.project!['address'];
      manager = widget.project!['manager'];
      supervisor = widget.project!['supervisor'];
    }
  }

  Future<void> _saveProject() async {
    final db = DatabaseHelper.instance;
    if (widget.project == null) {
      // پروژه جدید
      await db.insertProject({
        'name': name,
        'client': client,
        'address': address,
        'manager': manager,
        'supervisor': supervisor,
      });
    } else {
      // ویرایش پروژه
      await db.updateProject({
        'id': widget.project!['id'],
        'name': name,
        'client': client,
        'address': address,
        'manager': manager,
        'supervisor': supervisor,
      });
    }
    widget.onProjectSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'ایجاد پروژه جدید' : 'ویرایش پروژه'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'نام پروژه'),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'این فیلد الزامی است' : null,
              ),
              TextFormField(
                initialValue: client,
                decoration: InputDecoration(labelText: 'نام کارفرما'),
                onChanged: (value) => client = value,
              ),
              TextFormField(
                initialValue: address,
                decoration: InputDecoration(labelText: 'آدرس پروژه'),
                onChanged: (value) => address = value,
              ),
              TextFormField(
                initialValue: manager,
                decoration: InputDecoration(labelText: 'نام مدیر'),
                onChanged: (value) => manager = value,
              ),
              TextFormField(
                initialValue: supervisor,
                decoration: InputDecoration(labelText: 'نام سرپرست کارگاه'),
                onChanged: (value) => supervisor = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveProject();
                  }
                },
                child: Text('تایید'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
