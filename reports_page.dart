import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> projectReports;

  ReportsPage({required this.projectReports});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> filteredReports = [];

  @override
  void initState() {
    super.initState();
    filteredReports = _allReports();
  }

  List<Map<String, dynamic>> _allReports() {
    return widget.projectReports.values.expand((reports) => reports).toList();
  }

  void _searchReports(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredReports = _allReports();
      } else {
        filteredReports = _allReports().where((report) {
          final name = report['name']?.toString().toLowerCase() ?? '';
          final date = report['date']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) || date.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _confirmDeleteReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف گزارش'),
        content: Text('آیا از حذف این گزارش اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (var reports in widget.projectReports.values) {
                  reports.remove(report);
                }
                filteredReports.remove(report);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('گزارش با موفقیت حذف شد.')),
              );
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('گزارش‌ها'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ReportSearchDelegate(
                  allReports: _allReports(),
                  onSelected: (report) => _viewReportDetails(report),
                ),
              );
            },
          ),
        ],
      ),
      body: widget.projectReports.isEmpty
          ? Center(child: Text('هیچ گزارشی برای نمایش وجود ندارد.'))
          : ListView.builder(
              itemCount: widget.projectReports.keys.length,
              itemBuilder: (context, index) {
                final projectName = widget.projectReports.keys.elementAt(index);
                final projectReports = widget.projectReports[projectName]!;
                return ExpansionTile(
                  title: Text(projectName),
                  children: projectReports.isEmpty
                      ? [Text('گزارشی موجود نیست.')]
                      : projectReports.map((report) {
                          return ListTile(
                            title: Text(report['name'] ?? 'نام گزارش'),
                            subtitle: Text(report['date'] ?? 'تاریخ'),
                            onTap: () => _viewReportDetails(report),
                          );
                        }).toList(),
                );
              },
            ),
    );
  }

  void _viewReportDetails(Map<String, dynamic> report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsPage(
          report: report,
          onDelete: () => _confirmDeleteReport(report),
        ),
      ),
    );
  }
}

class ReportSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> allReports;
  final Function(Map<String, dynamic>) onSelected;

  ReportSearchDelegate({required this.allReports, required this.onSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allReports.where((report) {
      final name = report['name']?.toString().toLowerCase() ?? '';
      final date = report['date']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) || date.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final report = results[index];
        return ListTile(
          title: Text(report['name'] ?? 'نام گزارش'),
          subtitle: Text(report['date'] ?? 'تاریخ'),
          onTap: () {
            onSelected(report);
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allReports.where((report) {
      final name = report['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final report = suggestions[index];
        return ListTile(
          title: Text(report['name'] ?? 'نام گزارش'),
          subtitle: Text(report['date'] ?? 'تاریخ'),
          onTap: () {
            onSelected(report);
            close(context, null);
          },
        );
      },
    );
  }
}

class ReportDetailsPage extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onDelete;

  ReportDetailsPage({required this.report, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report['name'] ?? 'جزئیات گزارش'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نام گزارش: ${report['name'] ?? 'نامشخص'}'),
            Text('تاریخ: ${report['date'] ?? 'تاریخ نامشخص'}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => print('ویرایش گزارش: ${report['name']}'),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.green),
                  onPressed: () => print('اشتراک‌گذاری گزارش: ${report['name']}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
