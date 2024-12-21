import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'database_helper.dart';

class CreateProjectPage extends StatefulWidget {
  final Map<String, dynamic>? existingProject;

  CreateProjectPage({this.existingProject});

  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _client = '';
  String _address = '';
  String _manager = '';
  String _supervisor = '';
  String _companyName = ''; // نام شرکت
  File? _companyLogo;
  File? _managerSignature;
  File? _supervisorSignature;

  @override
  void initState() {
    super.initState();
    if (widget.existingProject != null) {
      _name = widget.existingProject!['name'] ?? '';
      _client = widget.existingProject!['client'] ?? '';
      _address = widget.existingProject!['address'] ?? '';
      _manager = widget.existingProject!['manager'] ?? '';
      _supervisor = widget.existingProject!['supervisor'] ?? '';
      _companyName = widget.existingProject!['companyName'] ?? ''; // مقداردهی نام شرکت
      _companyLogo = widget.existingProject!['companyLogo'] != null
          ? File(widget.existingProject!['companyLogo'])
          : null;
      _managerSignature = widget.existingProject!['managerSignature'] != null
          ? File(widget.existingProject!['managerSignature'])
          : null;
      _supervisorSignature = widget.existingProject!['supervisorSignature'] != null
          ? File(widget.existingProject!['supervisorSignature'])
          : null;
    }
  }

  Future<void> _pickImage(ImageSource source, Function(File?) onPicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        onPicked(File(pickedFile.path));
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    final db = DatabaseHelper.instance;

    final projectData = {
      'name': _name,
      'client': _client,
      'address': _address.isEmpty ? null : _address,
      'manager': _manager.isEmpty ? null : _manager,
      'supervisor': _supervisor.isEmpty ? null : _supervisor,
      'companyName': _companyName.isEmpty ? null : _companyName,
      'companyLogo': _companyLogo?.path ?? '',
      'managerSignature': _managerSignature?.path ?? '',
      'supervisorSignature': _supervisorSignature?.path ?? '',
    };

    if (widget.existingProject != null) {
      projectData['id'] = widget.existingProject!['id'];
      await db.updateProject(projectData);
    } else {
      await db.insertProject(projectData);
    }

    Navigator.pop(context, true);
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildImageUploader(String label, File? file, Function(File?) onPicked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: file == null
              ? Text('انتخاب نشده', style: TextStyle(color: Colors.grey))
              : Image.file(file, height: 60, fit: BoxFit.cover),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo, color: Colors.blue),
                onPressed: () => _pickImage(ImageSource.gallery, onPicked),
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.green),
                onPressed: () => _pickImage(ImageSource.camera, onPicked),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اطلاعات شرکت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: 'نام شرکت',
                initialValue: _companyName,
                onSaved: (value) => _companyName = value ?? '',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: _buildImageUploader(
                'لوگوی شرکت',
                _companyLogo,
                (file) => _companyLogo = file,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProject == null ? 'ایجاد پروژه جدید' : 'ویرایش پروژه'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: 'نام پروژه',
                initialValue: _name,
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value!.isEmpty ? 'این فیلد نمی‌تواند خالی باشد' : null,
              ),
              _buildTextField(
                label: 'نام کارفرما',
                initialValue: _client,
                onSaved: (value) => _client = value ?? '',
                validator: (value) => value!.isEmpty ? 'این فیلد نمی‌تواند خالی باشد' : null,
              ),
              _buildTextField(
                label: 'آدرس پروژه',
                initialValue: _address,
                onSaved: (value) => _address = value ?? '',
              ),
              _buildCompanySection(),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'نام مدیر',
                      initialValue: _manager,
                      onSaved: (value) => _manager = value ?? '',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _buildImageUploader(
                      'امضای مدیر',
                      _managerSignature,
                      (file) => _managerSignature = file,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'نام سرپرست',
                      initialValue: _supervisor,
                      onSaved: (value) => _supervisor = value ?? '',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _buildImageUploader(
                      'امضای سرپرست',
                      _supervisorSignature,
                      (file) => _supervisorSignature = file,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProject,
                child: Text('ذخیره'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
