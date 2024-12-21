import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMaterialsPage extends StatefulWidget {
  final Map<String, dynamic>? existingMaterial;

  AddMaterialsPage({this.existingMaterial});

  @override
  _AddMaterialsPageState createState() => _AddMaterialsPageState();
}

class _AddMaterialsPageState extends State<AddMaterialsPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedMaterial = '';
  String _selectedUnit = '';
  int _todayVolume = 0;
  int _cumulativeVolume = 0;
  int _todayInventory = 0;

  List<String> _materials = ['سیمان', 'ماسه', 'شن', 'آجر'];
  List<String> _units = ['کیلوگرم', 'تن', 'مترمکعب'];
  List<String> _filteredMaterials = [];
  List<String> _filteredUnits = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _filteredMaterials = List.from(_materials);
    _filteredUnits = List.from(_units);

    if (widget.existingMaterial != null) {
      _selectedMaterial = widget.existingMaterial!['material'];
      _selectedUnit = widget.existingMaterial!['unit'];
      _todayVolume = widget.existingMaterial!['todayVolume'];
      _cumulativeVolume = widget.existingMaterial!['cumulativeVolume'];
      _todayInventory = widget.existingMaterial!['todayInventory'];
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _materials = prefs.getStringList('materials') ?? _materials;
      _units = prefs.getStringList('units') ?? _units;
      _filteredMaterials = List.from(_materials);
      _filteredUnits = List.from(_units);
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('materials', _materials);
    prefs.setStringList('units', _units);
  }

  void _saveMaterial() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'material': _selectedMaterial,
        'unit': _selectedUnit,
        'todayVolume': _todayVolume,
        'cumulativeVolume': _cumulativeVolume,
        'todayInventory': _todayInventory,
        'title': 'مواد: $_selectedMaterial',
        'details':
            'واحد: $_selectedUnit - امروز: $_todayVolume - تجمعی: $_cumulativeVolume - موجودی: $_todayInventory',
      });
    }
  }

  Future<void> _showPicker(
      {required String title,
      required List<String> items,
      required Function(String) onSelect,
      required Function(String) onAdd,
      required Function(String) onDelete}) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<String> tempItems = List.from(items);

        return StatefulBuilder(builder: (context, setModalState) {
          void filterItems(String query) {
            setModalState(() {
              searchQuery = query;
              tempItems = items.where((item) => item.contains(query)).toList();
            });
          }

          return Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'جستجو $title'),
                onChanged: filterItems,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tempItems.length,
                  itemBuilder: (context, index) {
                    final item = tempItems[index];
                    return ListTile(
                      title: Text(item),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          onDelete(item);
                          setModalState(() {
                            tempItems.remove(item);
                          });
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
                    builder: (context) {
                      return AlertDialog(
                        title: Text('افزودن $title'),
                        content: TextField(
                          onChanged: (value) => newItem = value,
                          decoration: InputDecoration(labelText: 'نام $title'),
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
                              }
                            },
                            child: Text('افزودن'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('افزودن $title جدید'),
              )
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
        title: Text(widget.existingMaterial == null
            ? 'افزودن مواد و مصالح'
            : 'ویرایش مواد و مصالح'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                    _selectedMaterial.isNotEmpty ? _selectedMaterial : 'نام مواد'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () => _showPicker(
                  title: 'مواد',
                  items: _materials,
                  onSelect: (value) => setState(() => _selectedMaterial = value),
                  onAdd: (value) {
                    setState(() => _materials.add(value));
                    _savePreferences();
                  },
                  onDelete: (value) {
                    setState(() => _materials.remove(value));
                    _savePreferences();
                  },
                ),
              ),
              ListTile(
                title: Text(_selectedUnit.isNotEmpty ? _selectedUnit : 'واحد'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () => _showPicker(
                  title: 'واحد',
                  items: _units,
                  onSelect: (value) => setState(() => _selectedUnit = value),
                  onAdd: (value) {
                    setState(() => _units.add(value));
                    _savePreferences();
                  },
                  onDelete: (value) {
                    setState(() => _units.remove(value));
                    _savePreferences();
                  },
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'حجم وارد شده امروز'),
                keyboardType: TextInputType.number,
                initialValue: _todayVolume.toString(),
                onSaved: (value) => _todayVolume = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'حجم وارد شده تجمعی'),
                keyboardType: TextInputType.number,
                initialValue: _cumulativeVolume.toString(),
                onSaved: (value) => _cumulativeVolume = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'موجودی امروز'),
                keyboardType: TextInputType.number,
                initialValue: _todayInventory.toString(),
                onSaved: (value) => _todayInventory = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMaterial,
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
