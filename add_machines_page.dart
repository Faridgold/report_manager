import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMachinesPage extends StatefulWidget {
  final Map<String, dynamic>? existingMachine;
  final List<Map<String, dynamic>> previousMachines;

  AddMachinesPage({
    this.existingMachine,
    this.previousMachines = const [],
  });

  @override
  _AddMachinesPageState createState() => _AddMachinesPageState();
}

class _AddMachinesPageState extends State<AddMachinesPage> {
  final _formKey = GlobalKey<FormState>();

  String _selectedMachine = '';
  int _nameCount = 1;
  String _activeStatus = 'فعال';
  String _ownership = 'ملکی';

  List<String> _machines = ['بیل مکانیکی', 'لودر', 'جرثقیل'];
  List<String> _filteredMachines = [];
  bool _copyFromPrevious = false;

  @override
  void initState() {
    super.initState();
    _loadMachines();
    _filteredMachines = List.from(_machines);

    if (widget.existingMachine != null) {
      _selectedMachine = widget.existingMachine!['machine'];
      _nameCount = widget.existingMachine!['nameCount'];
      _activeStatus = widget.existingMachine!['activeStatus'];
      _ownership = widget.existingMachine!['ownership'];
    }
  }

  Future<void> _loadMachines() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _machines = prefs.getStringList('machines') ?? _machines;
      _filteredMachines = List.from(_machines);
    });
  }

  Future<void> _saveMachines() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('machines', _machines);
  }

  void _fillFromPrevious() {
    if (widget.previousMachines.isNotEmpty) {
      final lastMachine = widget.previousMachines.last;
      setState(() {
        _selectedMachine = lastMachine['machine'];
        _nameCount = lastMachine['nameCount'];
        _activeStatus = lastMachine['activeStatus'];
        _ownership = lastMachine['ownership'];
      });
    }
  }

  void _saveMachine() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'machine': _selectedMachine,
        'nameCount': _nameCount,
        'activeStatus': _activeStatus,
        'ownership': _ownership,
        'title': 'ماشین: $_selectedMachine',
        'details':
            'تعداد: $_nameCount - وضعیت: $_activeStatus - مالکیت: $_ownership',
      });
    }
  }

  Future<void> _showMachinePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<String> tempMachines = List.from(_filteredMachines);

        return StatefulBuilder(builder: (context, setModalState) {
          void filterMachines(String query) {
            setModalState(() {
              searchQuery = query;
              tempMachines =
                  _machines.where((machine) => machine.contains(query)).toList();
            });
          }

          void addMachine(String newMachine) {
            if (newMachine.isNotEmpty && !_machines.contains(newMachine)) {
              setState(() {
                _machines.add(newMachine);
                _filteredMachines.add(newMachine);
              });
              _saveMachines();
              setModalState(() => tempMachines = _filteredMachines);
            }
          }

          return Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'جستجوی ماشین'),
                onChanged: filterMachines,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tempMachines.length,
                  itemBuilder: (context, index) {
                    final machine = tempMachines[index];
                    return ListTile(
                      title: Text(machine),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _machines.remove(machine);
                            _filteredMachines.remove(machine);
                          });
                          _saveMachines();
                          setModalState(
                              () => tempMachines.remove(machine));
                        },
                      ),
                      onTap: () {
                        setState(() => _selectedMachine = machine);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  String newMachine = '';
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('افزودن ماشین جدید'),
                        content: TextField(
                          onChanged: (value) => newMachine = value,
                          decoration: InputDecoration(labelText: 'نام ماشین'),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('لغو')),
                          ElevatedButton(
                              onPressed: () {
                                addMachine(newMachine);
                                Navigator.pop(context);
                              },
                              child: Text('افزودن')),
                        ],
                      );
                    },
                  );
                },
                child: Text('افزودن ماشین جدید'),
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
        title: Text(widget.existingMachine == null
            ? 'افزودن ماشین‌آلات'
            : 'ویرایش ماشین‌آلات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CheckboxListTile(
                title: Text('تیک مانند روز قبل'),
                value: _copyFromPrevious,
                onChanged: (value) {
                  setState(() {
                    _copyFromPrevious = value!;
                    if (value) _fillFromPrevious();
                  });
                },
              ),
              ListTile(
                title: Text(
                    _selectedMachine.isNotEmpty ? _selectedMachine : 'نام ماشین'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showMachinePicker,
              ),
              ListTile(
                title: Text('نام تعداد: $_nameCount'),
                trailing: DropdownButton<int>(
                  value: _nameCount,
                  items: List.generate(
                    20,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _nameCount = value!);
                  },
                ),
              ),
              ListTile(
                title: Text('وضعیت فعال'),
                trailing: DropdownButton<String>(
                  value: _activeStatus,
                  items: ['فعال', 'غیرفعال']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _activeStatus = value ?? 'فعال');
                  },
                ),
              ),
              ListTile(
                title: Text('مالکیت'),
                trailing: DropdownButton<String>(
                  value: _ownership,
                  items: ['ملکی', 'اجاره‌ای']
                      .map((ownership) => DropdownMenuItem(
                            value: ownership,
                            child: Text(ownership),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _ownership = value ?? 'ملکی');
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMachine,
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
