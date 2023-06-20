import 'package:flutter/material.dart';

import 'enums.dart';
import 'settings.dart';

class RecordPageSettings extends ChangeNotifier  {
    RecordShowMode mode = RecordShowMode.chart;
    set setMode(RecordShowMode value){
        mode = value;
        _update(SettingsKey.recordPageMode, value);
    }

    bool showCurrent = true;
    set setShowCurrent(bool value){
        showCurrent = value;
        _update(SettingsKey.recordPageShowCurrent, value);
    }

    bool showVoltage = false;
    set setShowVoltage(bool value){
        showVoltage = value;
        _update(SettingsKey.recordPageShowVoltage, value);
    }

    bool showTemperature = false;
    set setShowTemperature(bool value){
        showTemperature = value;
        _update(SettingsKey.recordPageShowTemperature, value);
    }

    bool showLevel = false;
    set setShowLevel(bool value){
        showLevel = value;
        _update(SettingsKey.recordPageShowLevel, value);
    }

    bool showStatus = false;
    set setShowStatus(bool value){
        showStatus = value;
        _update(SettingsKey.recordPageShowStatus, value);
    }

    bool showHealth = false;
    set setShowHealth(bool value){
        showHealth = value;
        _update(SettingsKey.recordPageShowHealth, value);
    }

    bool showPlugged = false;
    set setShowPlugged(bool value){
        showPlugged = value;
        _update(SettingsKey.recordPageShowPlugged, value);
    }

    Time time = Time.seconds;
    set setTime(Time value){
        time = value;
        _update(SettingsKey.recordPageTime, value);
    }

    int timeValue = 1;
    set setTimeValue(int value){
        timeValue = value;
        _update(SettingsKey.recordPageTimeValue, value);
    }

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    void readFile(){
        setMode = RecordShowMode.values.byName(Settings.get(SettingsKey.recordPageMode) ?? RecordShowMode.chart.name);
        setShowCurrent = Settings.get(SettingsKey.recordPageShowCurrent) ?? true;
        setShowVoltage = Settings.get(SettingsKey.recordPageShowVoltage) ?? false;
        setShowTemperature = Settings.get(SettingsKey.recordPageShowTemperature) ?? false;
        setShowLevel = Settings.get(SettingsKey.recordPageShowLevel) ?? false;
        setShowStatus = Settings.get(SettingsKey.recordPageShowStatus) ?? false;
        setShowHealth = Settings.get(SettingsKey.recordPageShowHealth) ?? false;
        setShowPlugged = Settings.get(SettingsKey.recordPageShowPlugged) ?? false;
        setTime = Time.values.byName(Settings.get(SettingsKey.recordPageTime) ?? Time.seconds.name);
        setTimeValue = Settings.get(SettingsKey.recordPageTimeValue) ?? 1;
    }
}