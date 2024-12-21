import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddContractWorkerPage extends StatefulWidget {
  final Map<String, dynamic>? existingWorker;
  final Function(Map<String, dynamic>) onWorkerAdded;
  final List<String> activities; // لیست فعالیت‌های موجود

  AddContractWorkerPage({
    this.existingWorker,
    required this.onWorkerAdded,
    required this.activities,
  });

  @override
  _AddContractWorkerPageState createState() => _AddContractWorkerPageState();
}

class _AddContractWorkerPageState extends State<AddContractWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  List<String> _activityList = [];
  int _amount = 0;

  List<String> _names = ['علی', 'حسن', 'محمد']; // نام‌های پیش‌فرض
  List<String> _filteredNames = [];
  List<String> _selectedActivities = [];

  @override
  void initState() {
    super.initState();
    _loadNames();
    _filteredNames = List.from(_names);
    if (widget.existingWorker != null) {
      _name = widget.existingWorker!['name'] ?? '';
      _selectedActivities =
          List<String>.from(widget.existingWorker!['activity'] ?? []);
      _amount = widget.existingWorker!['amount'] ?? 0;
    }
  }

  // ذخیره و بارگذاری نام‌ها
  Future<void> _loadNames() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNames = prefs.getStringList('names') ?? _names;
    setState(() {
      _names = savedNames;
      _filteredNames = List.from(_names);
    });
  }

  Future<void> _saveNames() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('names', _names);
  }

  // افزودن یا حذف فعالیت
  Future<void> _selectActivities() async {
    List<String> tempSelected = List.from(_selectedActivities);

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('انتخاب فعالیت‌ها', style: TextStyle(fontSize: 18)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.activities.length,
                    itemBuilder: (context, index) {
                      final activity = widget.activities[index];
                      return CheckboxListTile(
                        title: Text(activity),
                        value: tempSelected.contains(activity),
                        onChanged: (value) {
                          setModalState(() {
                            if (value == true) {
                              tempSelected.add(activity);
                            } else {
                              tempSelected.remove(activity);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedActivities = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('تأیید'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // انتخاب یا مدیریت نام‌ها
  Future<void> _showNamePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<String> tempNames = List.from(_filteredNames);
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterNames(String query) {
              setModalState(() {
                searchQuery = query;
                tempNames = _names
                    .where((name) => name.contains(query))
                    .toList();
              });
            }

            void addName(String newName) {
              if (newName.isNotEmpty && !_names.contains(newName)) {
                setState(() {
                  _names.add(newName);
                  _filteredNames.add(newName);
                });
                _saveNames();
                setModalState(() {
                  tempNames = _filteredNames;
                });
              }
            }

            void deleteName(String name) {
              setState(() {
                _names.remove(name);
                _filteredNames.remove(name);
                if (_name == name) _name = '';
              });
              _saveNames();
              setModalState(() {
                tempNames = _filteredNames;
              });
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'جستجوی نام'),
                    onChanged: filterNames,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tempNames.length,
                    itemBuilder: (context, index) {
                      final name = tempNames[index];
                      return ListTile(
                        title: Text(name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteName(name),
                        ),
                        onTap: () {
                          setState(() {
                            _name = name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String newName = '';
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('افزودن نام جدید'),
                          content: TextField(
                            onChanged: (value) => newName = value,
                            decoration: InputDecoration(labelText: 'نام'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('لغو'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                addName(newName);
                                Navigator.pop(context);
                              },
                              child: Text('افزودن'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('افزودن نام جدید'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveWorker() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final workerData = {
        'title': 'نام: $_name',
        'details': 'فعالیت‌ها: ${_selectedActivities.join(', ')}\nمبلغ: $_amount ریال',
        'name': _name,
        'activity': _selectedActivities,
        'amount': _amount,
      };
      widget.onWorkerAdded(workerData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('افزودن نیروی کاری قراردادی')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(_name.isNotEmpty ? _name : 'انتخاب نام'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showNamePicker,
              ),
              ListTile(
                title: Text(_selectedActivities.isNotEmpty
                    ? 'فعالیت‌ها: ${_selectedActivities.join(', ')}'
                    : 'انتخاب فعالیت'),
                trailing: Icon(Icons.link),
                onTap: _selectActivities,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'مبلغ (ریال)'),
                keyboardType: TextInputType.number,
                initialValue: _amount.toString(),
                validator: (value) =>
                    value!.isEmpty ? 'لطفاً مبلغ را وارد کنید' : null,
                onSaved: (value) => _amount = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorker,
                child: Text('ذخیره'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
