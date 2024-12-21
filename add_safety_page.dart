import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSafetyPage extends StatefulWidget {
  final Map<String, dynamic>? existingSafety;

  AddSafetyPage({this.existingSafety});

  @override
  _AddSafetyPageState createState() => _AddSafetyPageState();
}

class _AddSafetyPageState extends State<AddSafetyPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTitle = '';
  String _description = '';
  String _priority = 'کم';

  List<String> _titles = ['مشکل ایمنی', 'نقص تجهیزات', 'شرایط نامساعد'];
  List<String> _filteredTitles = [];

  @override
  void initState() {
    super.initState();
    _loadTitles();
    _filteredTitles = List.from(_titles);

    if (widget.existingSafety != null) {
      _selectedTitle = widget.existingSafety!['title'] ?? '';
      _description = widget.existingSafety!['description'] ?? '';
      _priority = widget.existingSafety!['priority'] ?? 'کم';
    }
  }

  Future<void> _loadTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTitles = prefs.getStringList('safetyTitles') ?? _titles;
    setState(() {
      _titles = savedTitles;
      _filteredTitles = List.from(_titles);
    });
  }

  Future<void> _saveTitles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('safetyTitles', _titles);
  }

  void _saveSafety() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'title': _selectedTitle,
        'description': _description,
        'priority': _priority,
        'details': 'اولویت: $_priority\nتوضیحات: $_description',
      });
    }
  }

  Future<void> _showTitlePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<String> tempTitles = List.from(_filteredTitles);

        return StatefulBuilder(builder: (context, setModalState) {
          void filterTitles(String query) {
            setModalState(() {
              searchQuery = query;
              tempTitles =
                  _titles.where((title) => title.contains(query)).toList();
            });
          }

          void addTitle(String newTitle) {
            if (newTitle.isNotEmpty && !_titles.contains(newTitle)) {
              setState(() {
                _titles.add(newTitle);
                _filteredTitles.add(newTitle);
              });
              _saveTitles();
              setModalState(() => tempTitles = _filteredTitles);
            }
          }

          return Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'جستجوی عنوان'),
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
                            _titles.remove(title);
                            _filteredTitles.remove(title);
                          });
                          _saveTitles();
                          setModalState(() => tempTitles.remove(title));
                        },
                      ),
                      onTap: () {
                        setState(() => _selectedTitle = title);
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
                        title: Text('افزودن عنوان جدید'),
                        content: TextField(
                          onChanged: (value) => newTitle = value,
                          decoration: InputDecoration(labelText: 'عنوان'),
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
                child: Text('افزودن عنوان جدید'),
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
        title: Text(widget.existingSafety == null
            ? 'افزودن موانع و مشکلات'
            : 'ویرایش موانع و مشکلات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                    _selectedTitle.isNotEmpty ? _selectedTitle : 'عنوان مشکل'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showTitlePicker,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'توضیحات مشکل'),
                maxLines: 3,
                initialValue: _description,
                onSaved: (value) => _description = value!,
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
                onPressed: _saveSafety,
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
