import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDirectWorkerPage extends StatefulWidget {
  final Map<String, dynamic>? existingWorker;

  AddDirectWorkerPage({this.existingWorker});

  @override
  _AddDirectWorkerPageState createState() => _AddDirectWorkerPageState();
}

class _AddDirectWorkerPageState extends State<AddDirectWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _role = '';
  String _workingHours = '7:30 تا 16:30';
  List<String> _names = [];
  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.existingWorker != null) {
      final worker = widget.existingWorker!;
      _name = worker['name'] ?? '';
      _role = worker['role'] ?? '';
      _workingHours = worker['workingHours'] ?? '7:30 تا 16:30';
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _names = prefs.getStringList('names') ?? ['علی', 'حسن', 'محمد'];
      _roles = prefs.getStringList('roles') ?? ['کارگر', 'سرکارگر', 'مدیر'];
    });
  }

  Future<void> _saveData(String key, List<String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, data);
  }

  void _saveWorker() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'name': _name,
        'role': _role,
        'workingHours': _workingHours,
        'title': 'نام: $_name',
        'details': 'سمت: $_role، ساعات کاری: $_workingHours',
      });
    }
  }

  Future<void> _selectWorkingHours() async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 7, minute: 30),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 16, minute: 30),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (endTime == null) return;

    setState(() {
      _workingHours = '${startTime.format(context)} تا ${endTime.format(context)}';
    });
  }

  Future<void> _showItemPicker({
    required String title,
    required String key,
    required List<String> items,
    required Function(String) onSelect,
    required Function(String) onAdd,
    required Function(String) onDelete,
  }) async {
    String searchQuery = '';
    List<String> filteredItems = List.from(items);
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterItems(String query) {
              setModalState(() {
                searchQuery = query;
                filteredItems = items
                    .where((item) => item.contains(query))
                    .toList();
              });
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'جستجو'),
                    onChanged: filterItems,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        title: Text(item),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            onDelete(item);
                            setModalState(() {
                              filteredItems.remove(item);
                            });
                            _saveData(key, items);
                          },
                        ),
                        onTap: () {
                          onSelect(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String newItem = '';
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('افزودن آیتم جدید'),
                          content: TextField(
                            decoration: InputDecoration(labelText: 'نام آیتم'),
                            onChanged: (value) => newItem = value,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('لغو'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (newItem.isNotEmpty) {
                                  onAdd(newItem);
                                  Navigator.pop(context);
                                  setModalState(() {
                                    filteredItems.add(newItem);
                                  });
                                  _saveData(key, items);
                                }
                              },
                              child: Text('افزودن'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('افزودن آیتم جدید'),
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
      appBar: AppBar(title: Text('نیروهای کاری مستقیم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(_name.isNotEmpty ? _name : 'انتخاب نام'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () => _showItemPicker(
                  title: 'انتخاب نام',
                  key: 'names',
                  items: _names,
                  onSelect: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                  onAdd: (value) {
                    setState(() {
                      _names.add(value);
                    });
                  },
                  onDelete: (value) {
                    setState(() {
                      _names.remove(value);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text(_role.isNotEmpty ? _role : 'انتخاب سمت'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () => _showItemPicker(
                  title: 'انتخاب سمت',
                  key: 'roles',
                  items: _roles,
                  onSelect: (value) {
                    setState(() {
                      _role = value;
                    });
                  },
                  onAdd: (value) {
                    setState(() {
                      _roles.add(value);
                    });
                  },
                  onDelete: (value) {
                    setState(() {
                      _roles.remove(value);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('ساعات کاری: $_workingHours'),
                trailing: Icon(Icons.edit),
                onTap: _selectWorkingHours,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorker,
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
