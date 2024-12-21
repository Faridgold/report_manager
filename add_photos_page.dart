import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPhotosPage extends StatefulWidget {
  final List<File>? existingPhotos; // لیست عکس‌های از پیش اضافه‌شده

  AddPhotosPage({this.existingPhotos});

  @override
  _AddPhotosPageState createState() => _AddPhotosPageState();
}

class _AddPhotosPageState extends State<AddPhotosPage> {
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // اضافه کردن عکس‌های موجود در حالت ویرایش
    if (widget.existingPhotos != null) {
      _photos.addAll(widget.existingPhotos!);
    }
  }

  Future<void> _pickImage({required ImageSource source}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80, // کاهش کیفیت عکس برای کارایی بهتر
    );

    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _savePhotos() {
    Navigator.pop(context, _photos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('آپلود عکس'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _savePhotos, // ذخیره عکس‌ها و بازگشت به صفحه قبل
            tooltip: 'ذخیره عکس‌ها',
          ),
        ],
      ),
      body: Column(
        children: [
          // دکمه‌های اضافه کردن عکس
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(source: ImageSource.gallery),
                icon: Icon(Icons.photo),
                label: Text('از گالری'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(source: ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('از دوربین'),
              ),
            ],
          ),
          Divider(),
          // نمایش لیست عکس‌ها
          Expanded(
            child: _photos.isEmpty
                ? Center(child: Text('هیچ عکسی اضافه نشده است.'))
                : GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // تعداد ستون‌ها
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _editPhoto(index),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _photos[index],
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 12,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.close, size: 14, color: Colors.white),
                                  onPressed: () => _removePhoto(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _editPhoto(int index) {
    // نمایش جزئیات یا ویرایش عکس در صورت نیاز
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ویرایش عکس ${index + 1}')),
    );
  }
}
