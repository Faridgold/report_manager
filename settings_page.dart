import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تنظیمات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.language),
              title: Text('تغییر زبان'),
              onTap: () {
                // انتخاب زبان
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('انتخاب زبان'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('فارسی'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('English'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('درباره نرم‌افزار'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'گزارش نگار',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(Icons.app_settings_alt),
                  children: [
                    Text('این نرم‌افزار برای مدیریت گزارش‌های روزانه طراحی شده است.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
