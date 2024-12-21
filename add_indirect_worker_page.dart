import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddIndirectWorkerPage extends StatefulWidget {
  final Map<String, dynamic>? existingWorker;
  final List<String> activities;

  AddIndirectWorkerPage({this.existingWorker, required this.activities});

  @override
  _AddIndirectWorkerPageState createState() => _AddIndirectWorkerPageState();
}

class _AddIndirectWorkerPageState extends State<AddIndirectWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  String _role = '';
  int _numPeople = 1;
  List<String> _relatedActivities = [];
  List<String> _roles = ['ناظر', 'سرپرست', 'مشاور', 'کارگر'];
  List<String> _filteredRoles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _filteredRoles = List.from(_roles);
    if (widget.existingWorker != null) {
      _role = widget.existingWorker!['role'] ?? '';
      _numPeople = widget.existingWorker!['numPeople'] ?? 1;
      _relatedActivities =
          List<String>.from(widget.existingWorker!['relatedActivities'] ?? []);
    }
  }

  Future<void> _loadRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoles = prefs.getStringList('roles') ?? _roles;
    setState(() {
      _roles = savedRoles;
      _filteredRoles = List.from(_roles);
    });
  }

  Future<void> _saveRoles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('roles', _roles);
  }

  void _showRolePicker() async {
    String searchQuery = '';
    List<String> tempRoles = List.from(_roles);

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterRoles(String query) {
              setModalState(() {
                searchQuery = query;
                tempRoles = _roles
                    .where((role) => role.contains(query))
                    .toList();
              });
            }

            void addRole(String newRole) {
              if (newRole.isNotEmpty && !_roles.contains(newRole)) {
                setState(() {
                  _roles.add(newRole);
                  _filteredRoles.add(newRole);
                });
                _saveRoles();
                setModalState(() {
                  tempRoles = _filteredRoles;
                });
              }
            }

            void deleteRole(String role) {
              setState(() {
                _roles.remove(role);
                _filteredRoles.remove(role);
                if (_role == role) _role = '';
              });
              _saveRoles();
              setModalState(() {
                tempRoles = _filteredRoles;
              });
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'جستجوی سمت'),
                    onChanged: filterRoles,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tempRoles.length,
                    itemBuilder: (context, index) {
                      final role = tempRoles[index];
                      return ListTile(
                        title: Text(role),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteRole(role),
                        ),
                        onTap: () {
                          setState(() {
                            _role = role;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String newRole = '';
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('افزودن سمت جدید'),
                          content: TextField(
                            onChanged: (value) => newRole = value,
                            decoration: InputDecoration(labelText: 'سمت'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('لغو'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                addRole(newRole);
                                Navigator.pop(context);
                              },
                              child: Text('افزودن'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('افزودن سمت جدید'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectActivities() async {
  List<String> validActivities = widget.activities
      .where((activity) => activity != null && activity.isNotEmpty)
      .toList();

  List<String> tempSelected = List.from(_relatedActivities);

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('انتخاب فعالیت مرتبط',
                    style: TextStyle(fontSize: 18)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: validActivities.length,
                  itemBuilder: (context, index) {
                    final activity = validActivities[index];
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
                    _relatedActivities = tempSelected;
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

  void _saveWorker() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'role': _role,
        'numPeople': _numPeople,
        'relatedActivities': _relatedActivities,
        'title': 'سمت: $_role',
        'details':
            'تعداد نفرات: $_numPeople - فعالیت مرتبط: ${_relatedActivities.join(', ')}',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('افزودن نیروی کاری غیرمستقیم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(_role.isNotEmpty ? _role : 'انتخاب سمت'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showRolePicker,
              ),
              ListTile(
                title: Text('تعداد نفرات: $_numPeople'),
                trailing: DropdownButton<int>(
                  value: _numPeople,
                  items: List.generate(
                    20,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _numPeople = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text(_relatedActivities.isNotEmpty
                    ? 'فعالیت‌های مرتبط: ${_relatedActivities.join(', ')}'
                    : 'انتخاب فعالیت مرتبط'),
                trailing: Icon(Icons.link),
                onTap: _selectActivities,
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
