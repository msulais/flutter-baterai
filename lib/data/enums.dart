enum SettingsKey {
    theme,
    color,

    // record page
    recordPage,
    recordPageMode,
    recordPageShowCurrent,
    recordPageShowVoltage,
    recordPageShowTemperature,
    recordPageShowLevel,
    recordPageShowStatus,
    recordPageShowHealth,
    recordPageShowPlugged,
    recordPageTime,
    recordPageTimeValue
}

enum BatteryHealth {
    unknown,
    dead,
    unspecifiedFailure,
    cold,
    overvoltage,
    overheat,
    good;

    String inString(){switch (this){
        case BatteryHealth.cold: return 'Cold';
        case BatteryHealth.dead: return 'Dead';
        case BatteryHealth.good: return 'Good';
        case BatteryHealth.overheat: return 'Overheat';
        case BatteryHealth.overvoltage: return 'Overvoltage';
        case BatteryHealth.unknown: return 'Unknown';
        case BatteryHealth.unspecifiedFailure: return 'Unspecified failure';
    }}
}

enum BatteryPlugged {
    unknown,
    ac,
    usb,
    wireless;

    String inString(){switch (this){
        case BatteryPlugged.ac: return 'AC';
        case BatteryPlugged.unknown: return 'On battery';
        case BatteryPlugged.usb: return 'USB';
        case BatteryPlugged.wireless: return 'Wireless';
    }}
}

enum RecordShowMode {
    table,
    chart
}

enum Time {
    seconds,
    minutes,
    hours
}

enum DatabaseTables {
    recordHistory,
    batteryData,
}