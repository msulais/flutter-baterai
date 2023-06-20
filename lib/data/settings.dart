import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'enums.dart';
import 'record_settings.dart';

class Settings extends ChangeNotifier {
    static late SharedPreferences prefs;

    final Map<SettingsKey, dynamic> _settings = {
        SettingsKey.color: Colors.green.value,
        SettingsKey.theme: ThemeMode.system,

        SettingsKey.recordPage: RecordPageSettings()
    };

    Color
    get color => Color(_settings[SettingsKey.color]);
    set color(Color value) => _update(SettingsKey.color, value.value);

    ThemeMode
    get theme => _settings[SettingsKey.theme];
    set theme(ThemeMode value) => _update(SettingsKey.theme, value);

    RecordPageSettings
    get recordPage => _settings[SettingsKey.recordPage];

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        _settings[key] = value;
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    Future<void> readFile() async {
        prefs = await SharedPreferences.getInstance();
        try {
            color = Color(Settings.get(SettingsKey.color) ?? Colors.green.value);
            theme = ThemeMode.values.byName(Settings.get(SettingsKey.theme) ?? ThemeMode.system.name);

            recordPage.readFile();
        } catch (e) {
            debugPrint('ERROR READ FILE SETTINGS: $e');
        }
    }

    static
    Settings read(BuildContext context) {
        return context.read<Settings>();
    }

    static
    Settings watch(BuildContext context) {
        return context.watch<Settings>();
    }

    static
    dynamic get(SettingsKey key) {
        return prefs.get(key.name);
    }

    /// `value.runtimeType` must be:
    /// * `int`
    /// * `String`
    /// * `bool`
    /// * `double`
    /// * `Enum`
    static
    Future<void> set(SettingsKey key, dynamic value) async {
        switch(value.runtimeType){
            case int   : prefs.setInt   (key.name, value); break;
            case String: prefs.setString(key.name, value); break;
            case bool  : prefs.setBool  (key.name, value); break;
            case double: prefs.setDouble(key.name, value); break;
            default    :
                if (value is! Enum) throw Exception('Data type not supported [value: $value, value.runtimeType: ${value.runtimeType}]');
                prefs.setString(key.name, value.name);
        }
    }
}