import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddActivityPage extends StatefulWidget {
  final Map<String, dynamic>? existingActivity;

  AddActivityPage({this.existingActivity});

  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  String activityName = '';
  int estimatedVolume = 0;
  String unit = '';
  int todayVolume = 0;
  int cumulativeVolume = 0;
  String progressPercentage = '۰٪';
  String description = '';
  List<String> units = ['متر', 'کیلوگرم', 'تن'];
  List<String> filteredUnits = [];
  List<String> progressOptions = [];

  @override
  void initState() {
    super.initState();
    _loadUnits();
    _generateProgressOptions();
    if (widget.existingActivity != null) {
    activityName = widget.existingActivity!['activityName'] ?? '';
    estimatedVolume = widget.existingActivity!['estimatedVolume'] ?? 0;
    unit = widget.existingActivity!['unit'] ?? '';
    todayVolume = widget.existingActivity!['todayVolume'] ?? 0;
    cumulativeVolume = widget.existingActivity!['cumulativeVolume'] ?? 0;

    // تبدیل مقدار درصد پیشرفت به فرمت مورد نیاز (مثلاً "۵۰ درصد" به "۵۰٪")
    String savedProgress = widget.existingActivity!['progressPercentage'] ?? '۰٪';
    progressPercentage = _convertToStandardProgress(savedProgress);
    
    description = widget.existingActivity!['description'] ?? '';
  }
}

String _convertToStandardProgress(String input) {
  // حذف " درصد" و تبدیل به "٪"
  return input.replaceAll(' درصد', '٪');
}
  Future<void> _loadUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnits = prefs.getStringList('units') ?? ['متر', 'کیلوگرم', 'تن'];
    setState(() {
      units = savedUnits;
      filteredUnits = List.from(units);
    });
  }

  void _generateProgressOptions() {
    setState(() {
      progressOptions = List.generate(
          11, (index) => '${_convertToPersianNumber((index * 10).toString())}٪');
    });
  }

  Future<void> _saveUnits() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('units', units);
  }

  void _saveActivity() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  _formKey.currentState!.save();

  Map<String, dynamic> activityData = {
    'title': activityName, // نام فعالیت به عنوان title
    'details': 'حجم برآوردی: $estimatedVolume $unit\n'
        'حجم امروز: $todayVolume\n'
        'حجم تجمعی: $cumulativeVolume\n'
        'درصد پیشرفت: $progressPercentage\n'
        'توضیحات: $description', // جزئیات ترکیبی
    'estimatedVolume': estimatedVolume,
    'unit': unit,
    'todayVolume': todayVolume,
    'cumulativeVolume': cumulativeVolume,
    'progressPercentage': _convertToPersianPercentage(progressPercentage),
  };

  Navigator.pop(context, activityData);
}

  void _showAddUnitDialog() {
    String newUnit = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('افزودن واحد جدید'),
          content: TextField(
            onChanged: (value) => newUnit = value,
            decoration: InputDecoration(labelText: 'واحد جدید'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newUnit.isNotEmpty && !units.contains(newUnit)) {
                  setState(() {
                    units.add(newUnit);
                    filteredUnits.add(newUnit);
                    _saveUnits();
                  });
                }
                Navigator.pop(context);
              },
              child: Text('افزودن'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveUnitDialog(String unitToRemove) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف واحد'),
          content: Text('آیا می‌خواهید "$unitToRemove" را حذف کنید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  units.remove(unitToRemove);
                  filteredUnits.remove(unitToRemove);
                  if (unit == unitToRemove) unit = '';
                  _saveUnits();
                });
                Navigator.pop(context);
              },
              child: Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  String _convertToPersianNumber(String input) {
    const englishToPersian = {
      '0': '۰',
      '1': '۱',
      '2': '۲',
      '3': '۳',
      '4': '۴',
      '5': '۵',
      '6': '۶',
      '7': '۷',
      '8': '۸',
      '9': '۹',
    };
    return input.split('').map((e) => englishToPersian[e] ?? e).join();
  }

  String _convertToPersianPercentage(String input) {
    return input.replaceAll('٪', ' درصد');
  }

  Future<void> _showUnitPicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<String> currentFilteredUnits = List.from(filteredUnits);
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterUnitsInModal(String query) {
              setModalState(() {
                searchQuery = query;
                currentFilteredUnits = units
                    .where((u) => u.contains(query))
                    .toList();
              });
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'جستجوی واحد'),
                    onChanged: filterUnitsInModal,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentFilteredUnits.length,
                    itemBuilder: (context, index) {
                      final unit = currentFilteredUnits[index];
                      return ListTile(
                        title: Text(unit),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showRemoveUnitDialog(unit),
                        ),
                        onTap: () {
                          setState(() {
                            this.unit = unit;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _showAddUnitDialog,
                  child: Text('افزودن واحد جدید'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingActivity == null ? 'اضافه کردن فعالیت' : 'ویرایش فعالیت'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: activityName,
                decoration: InputDecoration(labelText: 'نام فعالیت'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'این فیلد نمی‌تواند خالی باشد';
                  }
                  return null;
                },
                onSaved: (value) => activityName = value!,
              ),
              TextFormField(
                initialValue: estimatedVolume.toString(),
                decoration: InputDecoration(labelText: 'کل حجم برآوردی'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'این فیلد نمی‌تواند خالی باشد';
                  }
                  if (int.tryParse(value) == null) {
                    return 'لطفا یک مقدار عددی وارد کنید';
                  }
                  return null;
                },
                onSaved: (value) => estimatedVolume = int.parse(value!),
              ),
              ListTile(
                title: Text(unit.isNotEmpty ? unit : 'انتخاب واحد'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showUnitPicker,
              ),
              TextFormField(
                initialValue: todayVolume.toString(),
                decoration: InputDecoration(labelText: 'حجم کار انجام شده امروز'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'این فیلد نمی‌تواند خالی باشد';
                  }
                  if (int.tryParse(value) == null) {
                    return 'لطفا یک مقدار عددی وارد کنید';
                  }
                  return null;
                },
                onSaved: (value) => todayVolume = int.parse(value!),
              ),
              TextFormField(
                initialValue: cumulativeVolume.toString(),
                decoration: InputDecoration(labelText: 'حجم کار انجام شده تجمعی'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'این فیلد نمی‌تواند خالی باشد';
                  }
                  if (int.tryParse(value) == null) {
                    return 'لطفا یک مقدار عددی وارد کنید';
                  }
                  return null;
                },
                onSaved: (value) => cumulativeVolume = int.parse(value!),
              ),
              DropdownButtonFormField<String>(
                value: progressPercentage,
                decoration: InputDecoration(labelText: 'درصد پیشرفت'),
                items: progressOptions
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    progressPercentage = value!;
                  });
                },
                onSaved: (value) => progressPercentage = value ?? '۰٪',
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'توضیحات'),
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveActivity,
                child: Text('ذخیره'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('لغو'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
