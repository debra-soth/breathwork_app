import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

// Singleton pattern for database 
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Initialize database only when accessed for the first time
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initializing database 
  Future<Database> _initDB() async {
    try {
      print("🔥 Initializing database...");
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, 'app_database.db');

      print("📂 Database Path: $path");

      return await openDatabase(
        path,
        version: 5,
        onCreate: (db, version) async {
          print("🛠️ Creating database...");
          await _createDB(db, version);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print("🔄 Upgrading database...");
          await _upgradeDB(db, oldVersion, newVersion);
        },
      );
    } catch (e) {
      print("❌ Database initialization error: $e"); // Debug print
      rethrow;
    }
  }

  // Create user table
  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
// Create breathwork patterns table
      await db.execute('''
      CREATE TABLE breathwork_patterns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        inhale_duration INTEGER NOT NULL,
        hold_after_inhale_duration INTEGER NOT NULL,
        exhale_duration INTEGER NOT NULL,
        hold_after_exhale_duration INTEGER NOT NULL,
        total_rounds INTEGER NOT NULL,
        total_duration INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        iconCode INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

      print("✅ Database tables created successfully!");

      // Insert test user
      await db.insert('users', {
        'username': 'test_user',
        'email': 'test@example.com',
        'password': 'test123',
      });

      print("✅ Test user inserted!");
    } catch (e) {
      print("❌ Error creating database tables: $e");
    }
  }

  // Database upgrade handling
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) { // Update to a new version (increment from previous version)
      // Check if 'iconCode' column exists before adding it
      List<Map<String, dynamic>> columns = await db.rawQuery("PRAGMA table_info(breathwork_patterns)");

      bool iconExists = columns.any((column) => column['name'] == 'iconCode');
      bool descriptionExists = columns.any((column) => column['name'] == 'description');

      if (!iconExists) {
        await db.execute('ALTER TABLE breathwork_patterns ADD COLUMN iconCode INTEGER NOT NULL DEFAULT 0');
        print("Added iconCode column.");
      } else {
        print("iconCode column already exists, skipping ALTER TABLE.");
      }

      if (!descriptionExists) {
        await db.execute('ALTER TABLE breathwork_patterns ADD COLUMN description TEXT DEFAULT ""');
        print("Added description column.");
      } else {
        print("description column already exists, skipping ALTER TABLE.");
      }
    }
  }


  // Check if email exists
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Check if username exists
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      columns: ['id', 'username', 'email'],  // Ensure 'username' is included
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }


  // Insert User
  Future<int?> insertUser(String username, String email, String password) async {
    print("Inserting user: $username, $email"); // Debug print
    final db = await instance.database;
    int userId = await db.insert(
      'users',
      {'username': username, 'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Inserted user ID: $userId"); // Debug print
    return userId > 0 ? userId : null;
  }


  // Authenticate User
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Add breathwork method
  Future<int?> insertBreathworkPattern({
    required String name,
    String? description,
    required int inhaleDuration,
    required int holdAfterInhaleDuration,
    required int exhaleDuration,
    required int holdAfterExhaleDuration,
    required int totalRounds,
    required int totalDuration,
    required int userId,
    required int iconCode,
  }) async {
    final db = await instance.database;

    print("Saving pattern: $name for user $userId"); // Debug log

    int patternId = await db.insert(
      'breathwork_patterns',
      {
        'name': name,
        'description': description ?? '',
        'inhale_duration': inhaleDuration,
        'hold_after_inhale_duration': holdAfterInhaleDuration,
        'exhale_duration': exhaleDuration,
        'hold_after_exhale_duration': holdAfterExhaleDuration,
        'total_rounds': totalRounds,
        'total_duration': totalDuration,
        'user_id': userId,
        'iconCode': iconCode,
      },
    );

    print("Pattern inserted with ID: $patternId"); // Debug log
    return patternId > 0 ? patternId : null;
  }



  // Fetch breathwork patterns
  Future<List<Map<String, dynamic>>> getBreathworkPatternsByUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'breathwork_patterns',
      where: 'user_id = ?', // Ensure only patterns for this user are returned
      whereArgs: [userId],
    );
  }

// Delete Pattern
  Future<int> deleteBreathworkPattern(int patternId) async {
    final db = await instance.database;
    return await db.delete(
      'breathwork_patterns',
      where: 'id = ?', // Delete pattern by ID
      whereArgs: [patternId],
    );
  }


}
