import 'dart:convert';

import 'package:battery_info/enums/charging_status.dart';
import 'package:sqflite/sqflite.dart' as sql;

import 'database.dart';
import 'battery_record.dart';
import 'enums.dart';

class BatteryRecordHistory {
    int _id;
    final DateTime date;
    final BatteryRecord record;

    BatteryRecordHistory({
        int? id,
        DateTime? date,
        required this.record,
    }) :
        _id = id ?? -1,
        date = date ?? DateTime.now()
    ;

    int get id => _id;

    Future<int> insertDB([DatabaseInsertOptions? options]) async {
        int id = await Database.insert(options ?? DatabaseInsertOptions(databaseTable, {
            'date': date.toIso8601String(),
            'level': jsonEncode(record.level),
            'current': jsonEncode(record.current),
            'voltage': jsonEncode(record.voltage),
            'temperature': jsonEncode(record.temperature),
            'technology': jsonEncode(record.technology),
            'time': jsonEncode(record.time.map((t) => t.toIso8601String()).toList()),
            'health': jsonEncode(record.health.map((h) => h.name).toList()),
            'plugged': jsonEncode(record.plugged.map((p) => p.name).toList()),
            'status': jsonEncode(record.status.map((s) => s.name).toList())
        }));
        _id = id;
        return id;
    }

    Future<int> deleteDB([DatabaseDeleteOptions? options]) async {
        return await Database.delete(options ?? DatabaseDeleteOptions(
            databaseTable,
            where: 'id = ?',
            whereArgs: [id]
        ));
    }

    Future<int> updateDB([DatabaseUpdateOptions? options]) async {
        return await Database.update(options ?? DatabaseUpdateOptions(
            databaseTable, {
                'date': date.toIso8601String(),
                'level': jsonEncode(record.level),
                'current': jsonEncode(record.current),
                'voltage': jsonEncode(record.voltage),
                'temperature': jsonEncode(record.temperature),
                'technology': jsonEncode(record.technology),
                'time': jsonEncode(record.time.map((t) => t.toIso8601String()).toList()),
                'health': jsonEncode(record.health.map((h) => h.name).toList()),
                'plugged': jsonEncode(record.plugged.map((p) => p.name).toList()),
                'status': jsonEncode(record.status.map((s) => s.name).toList())
            },
            where: 'id = ?',
            whereArgs: [id]
        ));
    }

    static DatabaseTables databaseTable = DatabaseTables.recordHistory;

    static Future<List<BatteryRecordHistory>> queryDB([DatabaseQueryOptions? options]) async {
        List<Map<String, dynamic>> items = await Database.query(options ?? DatabaseQueryOptions(databaseTable));
        return [for (var item in items) BatteryRecordHistory(
            id: item['id'] as int,
            date: DateTime.parse(item['date'] as String),
            record: (){
                List<num> level = List<num>.from(jsonDecode(item['level']));
                List<num> current = List<num>.from(jsonDecode(item['current']));
                List<num> voltage = List<num>.from(jsonDecode(item['voltage']));
                List<num> temperature = List<num>.from(jsonDecode(item['temperature']));
                List<String> technology = List<String>.from(jsonDecode(item['technology']));
                List<DateTime> time = List<String>.from(jsonDecode(item['time'])).map((t) => DateTime.parse(t)).toList();
                List<BatteryHealth> health = List<String>.from(jsonDecode(item['health'])).map((h) => BatteryHealth.values.byName(h)).toList();
                List<BatteryPlugged> plugged = List<String>.from(jsonDecode(item['plugged'])).map((p) => BatteryPlugged.values.byName(p)).toList();
                List<ChargingStatus> status = List<String>.from(jsonDecode(item['status'])).map((s) => ChargingStatus.values.byName(s)).toList();
                int length = level.length;
                return BatteryRecord(data: [for (int i = 0; i < length; i++) BatteryData(
                    level: level[i],
                    current: current[i],
                    voltage: voltage[i],
                    temperature: temperature[i],
                    health: health[i],
                    plugged: plugged[i],
                    technology: technology[i],
                    status: status[i],
                    time: time[i]
                )]);
            }(),
        )];
    }

    static Future<int> clearDB() async {
        return await Database.delete(DatabaseDeleteOptions(databaseTable));
    }

    static Future<void> dropDB(sql.Database db) async {
        return await db.execute('''DROP TABLE IF EXIST ${DatabaseTables.recordHistory.name}''');
    }

    static Future<void> createDB(sql.Database db) async {
        return await db.execute('''CREATE TABLE ${DatabaseTables.recordHistory.name} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            level TEXT,
            current TEXT,
            voltage TEXT,
            temperature TEXT,
            technology TEXT,
            time TEXT,
            health TEXT,
            plugged TEXT,
            status TEXT
        )''');
    }
}