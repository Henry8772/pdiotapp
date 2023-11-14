import 'package:pdiot_app/model/current_user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<void> initDatabase() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'user_database.db'),
      onCreate: (db, version) async {
        // Create users table
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)',
        );
        // Create activities table
        await db.execute(
          'CREATE TABLE activities(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
        );
        // Create sessions table
        await db.execute(
          'CREATE TABLE sessions(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, startTime TEXT, endTime TEXT, FOREIGN KEY(userId) REFERENCES users(id))',
        );
        // Create session_activities table
        await db.execute(
          'CREATE TABLE session_activities(id INTEGER PRIMARY KEY AUTOINCREMENT, sessionId INTEGER, activityId INTEGER, duration INTEGER, FOREIGN KEY(sessionId) REFERENCES sessions(id), FOREIGN KEY(activityId) REFERENCES activities(id))',
        );

        await _populateActivities(db);
      },
      version: 1,
    );
  }

  static Future<void> _populateActivities(Database db) async {
    // List of activities to be added
    const activities = [
      'Shuffle walking',
      'Lying down on stomach',
      'Ascending stairs',
      'Sitting/standing',
      'Running',
      'Lying down right',
      'Descending stairs',
      'Miscellaneous movements',
      'Normal walking',
      'Lying down on left',
      'Lying down back'
    ]; // Add more activities here

    for (String activity in activities) {
      await db.insert('activities', {'name': activity});
    }
  }

  // Insert a user
  static Future<int> insertUser(Map<String, dynamic> user) async {
    return await _database!
        .insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Get all users
  static Future<List<Map<String, dynamic>>> getUsers() async {
    return await _database!.query('users');
  }

// Update a user
  static Future<int> updateUser(Map<String, dynamic> user) async {
    return await _database!
        .update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

// Delete a user
  static Future<int> deleteUser(int id) async {
    return await _database!.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Insert an activity
  static Future<int> insertActivity(Map<String, dynamic> activity) async {
    return await _database!.insert('activities', activity,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Get all activities
  static Future<List<Map<String, dynamic>>> getActivities() async {
    return await _database!.query('activities');
  }

// Update an activity
  static Future<int> updateActivity(Map<String, dynamic> activity) async {
    return await _database!.update('activities', activity,
        where: 'id = ?', whereArgs: [activity['id']]);
  }

// Delete an activity
  static Future<int> deleteActivity(int id) async {
    return await _database!
        .delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // Insert a session
  static Future<int> insertSession(Map<String, dynamic> session) async {
    return await _database!.insert('sessions', session,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Get all sessions
  static Future<List<Map<String, dynamic>>> getSessions() async {
    return await _database!.query('sessions');
  }

// Update a session
  static Future<int> updateSession(Map<String, dynamic> session) async {
    return await _database!.update('sessions', session,
        where: 'id = ?', whereArgs: [session['id']]);
  }

// Delete a session
  static Future<int> deleteSession(int id) async {
    return await _database!
        .delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  // Insert a session activity
  static Future<int> insertSessionActivity(
      Map<String, dynamic> sessionActivity) async {
    return await _database!.insert('session_activities', sessionActivity,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Get all session activities
  static Future<List<Map<String, dynamic>>> getSessionActivities() async {
    return await _database!.query('session_activities');
  }

// Update a session activity
  static Future<int> updateSessionActivity(
      Map<String, dynamic> sessionActivity) async {
    return await _database!.update('session_activities', sessionActivity,
        where: 'id = ?', whereArgs: [sessionActivity['id']]);
  }

  static Future<int> createNewSession(int userId, DateTime startTime) async {
    // Assuming the current time as the start time for the session
    String endTime = DateTime.now().toIso8601String();
    String startTimeString = startTime.toIso8601String();

    // Insert the new session and get its ID
    int sessionId = await _database!.insert(
      'sessions',
      {
        'userId': userId,
        'startTime': startTimeString,
        'endTime': endTime,
        // 'endTime' can be updated later when the session ends
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return sessionId;
  }

  static Future<int> getActivityIdByName(String activityName) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'activities',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [activityName],
    );

    if (maps.isNotEmpty) {
      return maps.first['id']; // Return the ID of the activity
    } else {
      // Handle the case where the activity does not exist.
      // You might want to insert the new activity here or return an error
      return -1; // Indicate that the activity was not found
    }
  }

// Delete a session activity
  static Future<int> deleteSessionActivity(int id) async {
    return await _database!
        .delete('session_activities', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, int>> getTimeSpentOnActivitiesByDay(
      DateTime selectedDateTime) async {
    int userId =
        int.parse(CurrentUser.instance.id.value); // Get the current user's ID

    // Get today's date in the required format
    String todayDate = DateTime(
            selectedDateTime.year, selectedDateTime.month, selectedDateTime.day)
        .toIso8601String();

    // Query to join tables and calculate the sum of duration for each activity for the current user
    String query = '''
    SELECT a.name, SUM(sa.duration) as totalDuration
    FROM activities a
    JOIN session_activities sa ON a.id = sa.activityId
    JOIN sessions s ON sa.sessionId = s.id
    WHERE s.userId = ? AND (DATE(s.startTime) = DATE(?) OR DATE(s.endTime) = DATE(?))
    GROUP BY a.name
  ''';

    // Execute the query with the user ID
    List<Map<String, dynamic>> activityResults =
        await _database!.rawQuery(query, [userId, todayDate, todayDate]);

    // Convert the query results to a more readable format
    Map<String, int> activityDurations = {};
    for (var row in activityResults) {
      activityDurations[row['name']] = row['totalDuration'];
    }

    return activityDurations;
  }

  static Future<Map<String, int>> getTimeSpentOnActivitiesInRange(
      DateTime startDate, DateTime endDate) async {
    int userId = int.parse(CurrentUser.instance.id.value);

    // Convert dates to the required format
    String startDateStr =
        DateTime(startDate.year, startDate.month, startDate.day)
            .toIso8601String();
    String endDateStr =
        DateTime(endDate.year, endDate.month, endDate.day).toIso8601String();

    // Modified query to incorporate userId
    String query = '''
  SELECT a.name, SUM(sa.duration) as totalDuration
  FROM activities a
  JOIN session_activities sa ON a.id = sa.activityId
  JOIN sessions s ON sa.sessionId = s.id
  WHERE s.userId = ? AND DATE(s.startTime) >= DATE(?) AND DATE(s.endTime) <= DATE(?)
  GROUP BY a.name
  ''';

    // Execute the query with the userId included in the parameters
    List<Map<String, dynamic>> results =
        await _database!.rawQuery(query, [userId, startDateStr, endDateStr]);

    // Convert the query results to a more readable format
    Map<String, int> activityDurations = {};
    for (var row in results) {
      activityDurations[row['name']] = row['totalDuration'];
    }

    return activityDurations;
  }

  // Add methods to insert and retrieve sessions, activities, and session activities

  // You would add similar methods for sessions and session_activities
}
