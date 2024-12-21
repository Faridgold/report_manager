import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProjectPage extends StatefulWidget {
  final Map<String, dynamic> project;
  final Future<void> Function(Map<String, dynamic>) onEditProject;

  EditProjectPage({required this.project, required this.onEditProject});

  @override
  _EditProjectPageState createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _clientController;
  late TextEditingController _addressController;
  late TextEditingController _managerController;
  late TextEditingController _supervisorController;
  late TextEditingController _companyNameController;

  File? _companyLogo;
  File? _managerSignature;
  File? _supervisorSignature;

  @override
  void initState() {
    super.initState();
    try {
      _nameController = TextEditingController(text: widget.project['name'] ?? '');
      _clientController = TextEditingController(text: widget.project['client'] ?? '');
      _addressController = TextEditingController(text: widget.project['address'] ?? '');
      _managerController = TextEditingController(text: widget.project['manager'] ?? '');
      _supervisorController = TextEditingController(text: widget.project['supervisor'] ?? '');
      _companyNameController = TextEditingController(text: widget.project['companyName'] ?? '');

      if (widget.project['companyLogo'] != null && widget.project['companyLogo'].toString().isNotEmpty) {
        _companyLogo = File(widget.project['companyLogo']);
      }
      if (widget.project['managerSignature'] != null && widget.project['managerSignature'].toString().isNotEmpty) {
        _managerSignature = File(widget.project['managerSignature']);
      }
      if (widget.project['supervisorSignature'] != null && widget.project['supervisorSignature'].toString().isNotEmpty) {
        _supervisorSignature = File(widget.project['supervisorSignature']);
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _addressController.dispose();
    _managerController.dispose();
    _supervisorController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(Function(File) onImagePicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        onImagePicked(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitEdit() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      _formKey.currentState!.save();

      final updatedProject = {
        'id': widget.project['id'],
        'name': _nameController.text.trim(),
        'client': _clientController.text.trim(),
        'address': _addressController.text.trim(),
        'manager': _managerController.text.trim(),
        'supervisor': _supervisorController.text.trim(),
        'companyName': _companyNameController.text.trim(),
        'companyLogo': _companyLogo?.path ?? '',
        'managerSignature': _managerSignature?.path ?? '',
        'supervisorSignature': _supervisorSignature?.path ?? '',
      };

      // فراخوانی تابع ویرایش (async)
      await widget.onEditProject(updatedProject);

      // پس از اتمام آپدیت، بازگشت به صفحه قبل با پروژه آپدیت‌شده
      Navigator.pop(context, updatedProject);
    } catch (e) {
      debugPrint('Error during submit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ویرایش پروژه: $e')),
      );
    }
  }

  Widget _buildImageUploadSection(String title, File? file, Function(File) onImagePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        file == null
            ? Text('هیچ تصویری انتخاب نشده است', style: TextStyle(fontStyle: FontStyle.italic))
            : Image.file(file, height: 100, fit: BoxFit.cover),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _pickImage(onImagePicked),
          child: Text('انتخاب تصویر'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ویرایش پروژه'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                labelText: 'نام پروژه',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'لطفاً نام پروژه را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _clientController,
                labelText: 'نام کارفرما',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'لطفاً نام کارفرما را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _addressController,
                labelText: 'آدرس پروژه',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'لطفاً آدرس پروژه را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _managerController,
                labelText: 'نام مدیر',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'لطفاً نام مدیر را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _supervisorController,
                labelText: 'نام سرپرست کارگاه',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'لطفاً نام سرپرست کارگاه را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _companyNameController,
                labelText: 'نام شرکت',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'لطفاً نام شرکت را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildImageUploadSection('لوگوی شرکت', _companyLogo, (file) => _companyLogo = file),
              SizedBox(height: 20),
              _buildImageUploadSection('امضای دیجیتال مدیر', _managerSignature, (file) => _managerSignature = file),
              SizedBox(height: 20),
              _buildImageUploadSection('امضای دیجیتال سرپرست', _supervisorSignature, (file) => _supervisorSignature = file),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEdit,
                child: Text('ذخیره تغییرات'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
