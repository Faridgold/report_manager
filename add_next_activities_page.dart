import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNextActivitiesPage extends StatefulWidget {
  final Map<String, dynamic>? existingActivity;

  AddNextActivitiesPage({this.existingActivity});

  @override
  _AddNextActivitiesPageState createState() => _AddNextActivitiesPageState();
}

class _AddNextActivitiesPageState extends State<AddNextActivitiesPage> {
  final _formKey = GlobalKey<FormState>();
  String _activityTitle = '';
  String _activityDescription = '';
  String _priority = 'کم';

  List<String> _activityTitles = ['تمیزکاری سایت', 'آماده‌سازی قالب', 'تخلیه بتن'];
  List<String> _filteredActivityTitles = [];

  @override
  void initState() {
    super.initState();
    _loadTitles();
    _filteredActivityTitles = List.from(_activityTitles);

    if (widget.existingActivity != null) {
      _activityTitle = widget.existingActivity!['activityTitle'] ?? '';
      _activityDescription = widget.existingActivity!['activityDescription'] ?? '';
      _priority = widget.existingActivity!['priority'] ?? 'کم';
    }
  }

  Future<void> _loadTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTitles = prefs.getStringList('nextActivityTitles') ?? _activityTitles;
    setState(() {
      _activityTitles = savedTitles;
      _filteredActivityTitles = List.from(_activityTitles);
    });
  }

  Future<void> _saveTitles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('nextActivityTitles', _activityTitles);
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'activityTitle': _activityTitle,
        'activityDescription': _activityDescription,
        'priority': _priority,
        'title': 'فعالیت: $_activityTitle',
        'details': 'اولویت: $_priority\nتوضیحات: $_activityDescription',
      });
    }
  }

  Future<void> _showTitlePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<String> tempTitles = List.from(_filteredActivityTitles);

        return StatefulBuilder(builder: (context, setModalState) {
          void filterTitles(String query) {
            setModalState(() {
              searchQuery = query;
              tempTitles = _activityTitles
                  .where((title) => title.contains(query))
                  .toList();
            });
          }

          void addTitle(String newTitle) {
            if (newTitle.isNotEmpty && !_activityTitles.contains(newTitle)) {
              setState(() {
                _activityTitles.add(newTitle);
                _filteredActivityTitles.add(newTitle);
              });
              _saveTitles();
              setModalState(() => tempTitles = _filteredActivityTitles);
            }
          }

          return Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'جستجوی فعالیت'),
                onChanged: filterTitles,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tempTitles.length,
                  itemBuilder: (context, index) {
                    final title = tempTitles[index];
                    return ListTile(
                      title: Text(title),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _activityTitles.remove(title);
                            _filteredActivityTitles.remove(title);
                          });
                          _saveTitles();
                          setModalState(() => tempTitles.remove(title));
                        },
                      ),
                      onTap: () {
                        setState(() => _activityTitle = title);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  String newTitle = '';
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('افزودن فعالیت جدید'),
                        content: TextField(
                          onChanged: (value) => newTitle = value,
                          decoration: InputDecoration(labelText: 'عنوان فعالیت'),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('لغو')),
                          ElevatedButton(
                              onPressed: () {
                                addTitle(newTitle);
                                Navigator.pop(context);
                              },
                              child: Text('افزودن')),
                        ],
                      );
                    },
                  );
                },
                child: Text('افزودن فعالیت جدید'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingActivity == null
            ? 'افزودن فعالیت روز کاری بعد'
            : 'ویرایش فعالیت روز کاری بعد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                    _activityTitle.isNotEmpty ? _activityTitle : 'عنوان فعالیت'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showTitlePicker,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'توضیحات فعالیت'),
                maxLines: 3,
                initialValue: _activityDescription,
                onSaved: (value) => _activityDescription = value!,
              ),
              ListTile(
                title: Text('اولویت: $_priority'),
                trailing: DropdownButton<String>(
                  value: _priority,
                  items: ['کم', 'متوسط', 'زیاد']
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _priority = value ?? 'کم');
                  },
                ),
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
