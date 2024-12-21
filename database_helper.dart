import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 6, // نسخه جدید پایگاه داده
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    ).then((db) async {
      // فعال‌سازی کلیدهای خارجی
      await db.execute('PRAGMA foreign_keys = ON;');
      return db;
    });
  }

  Future<void> _onCreate(Database db, int version) async {
    print("ایجاد پایگاه داده در نسخه $version");

    try {
      await db.execute('''
        CREATE TABLE projects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          client TEXT NOT NULL,
          address TEXT,
          manager TEXT,
          supervisor TEXT,
          companyName TEXT DEFAULT '',
          companyLogo TEXT DEFAULT '',
          managerSignature TEXT DEFAULT '',
          supervisorSignature TEXT DEFAULT ''
        )
      ''');

      await db.execute('''
        CREATE TABLE reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          projectId INTEGER NOT NULL,
          projectName TEXT NOT NULL,
          date TEXT NOT NULL,
          weatherType TEXT,
          minTemp INTEGER,
          maxTemp INTEGER,
          isConfirmed INTEGER DEFAULT 0, -- گزارش تایید شده یا نشده
          FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
        )
      ''');
    } catch (e) {
      print("خطا در ایجاد جداول: $e");
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("ارتقا پایگاه داده از نسخه $oldVersion به نسخه $newVersion");

    try {
      if (oldVersion < 6) {
        await db.execute('ALTER TABLE reports ADD COLUMN isConfirmed INTEGER DEFAULT 0;');
        print("ستون isConfirmed اضافه شد.");
      }
    } catch (e) {
      print("خطا در ارتقای پایگاه داده: $e");
    }
  }

  // متدهای مربوط به پروژه‌ها
  Future<int> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    try {
      return await db.insert('projects', project);
    } catch (e) {
      print("خطا در درج پروژه: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    try {
      return await db.query('projects');
    } catch (e) {
      print("خطا در واکشی پروژه‌ها: $e");
      return [];
    }
  }

  Future<int> updateProject(Map<String, dynamic> project) async {
    final db = await database;
    try {
      return await db.update(
        'projects',
        project,
        where: 'id = ?',
        whereArgs: [project['id']],
      );
    } catch (e) {
      print("خطا در به‌روزرسانی پروژه: $e");
      return -1;
    }
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'projects',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("خطا در حذف پروژه: $e");
      return -1;
    }
  }

  // متدهای مربوط به گزارش‌ها
  Future<int> insertReport(Map<String, dynamic> report) async {
    final db = await database;
    try {
      return await db.insert('reports', report);
    } catch (e) {
      print("خطا در درج گزارش: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getReports({bool onlyConfirmed = false}) async {
    final db = await database;
    try {
      if (onlyConfirmed) {
        return await db.query('reports', where: 'isConfirmed = ?', whereArgs: [1]);
      }
      return await db.query('reports');
    } catch (e) {
      print("خطا در واکشی گزارش‌ها: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getReportsByProjectId(int projectId, {bool onlyConfirmed = false}) async {
    final db = await database;
    try {
      if (onlyConfirmed) {
        return await db.query(
          'reports',
          where: 'projectId = ? AND isConfirmed = ?',
          whereArgs: [projectId, 1],
        );
      }
      return await db.query(
        'reports',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );
    } catch (e) {
      print("خطا در واکشی گزارش‌های پروژه: $e");
      return [];
    }
  }

  Future<int> updateReport(Map<String, dynamic> report) async {
    final db = await database;
    try {
      return await db.update(
        'reports',
        report,
        where: 'id = ?',
        whereArgs: [report['id']],
      );
    } catch (e) {
      print("خطا در به‌روزرسانی گزارش: $e");
      return -1;
    }
  }

  Future<int> deleteReport(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'reports',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("خطا در حذف گزارش: $e");
      return -1;
    }
  }

  Future<int> confirmReport(int id) async {
    final db = await database;
    try {
      return await db.update(
        'reports',
        {'isConfirmed': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("خطا در تایید گزارش: $e");
      return -1;
    }
  }

  Future<Map<String, dynamic>?> getProjectByName(String name) async {
    final db = await database;
    try {
      final results = await db.query('projects', where: 'name = ?', whereArgs: [name]);
      if (results.isNotEmpty) {
        return results.first;
      } else {
        return null;
      }
    } catch (e) {
      print("خطا در واکشی پروژه با نام $name: $e");
      return null;
    }
  }
}
