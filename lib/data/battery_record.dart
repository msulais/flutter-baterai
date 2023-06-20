import 'package:battery_info/enums/charging_status.dart';

import 'enums.dart';

class BatteryRecord {
    final List<BatteryData> data;
    final List<num> level;
    final List<num> current;
    final List<num> voltage;
    final List<num> temperature;
    final List<String> technology;
    final List<DateTime> time;
    final List<BatteryHealth> health;
    final List<BatteryPlugged> plugged;
    final List<ChargingStatus> status;

    BatteryRecord({ required this.data }) :
        assert(data.isNotEmpty),
        level       = data.map((data) => data.level      ).toList(),
        current     = data.map((data) => data.current    ).toList(),
        voltage     = data.map((data) => data.voltage    ).toList(),
        temperature = data.map((data) => data.temperature).toList(),
        technology  = data.map((data) => data.technology ).toList(),
        time        = data.map((data) => data.time       ).toList(),
        health      = data.map((data) => data.health     ).toList(),
        plugged     = data.map((data) => data.plugged    ).toList(),
        status      = data.map((data) => data.status     ).toList()
    ;

    num
    get sumLevel => level.reduce((a, b) => a + b);

    num
    get minLevel => level.reduce((a, b) => a < b? a : b);

    num
    get maxLevel => level.reduce((a, b) => a > b? a : b);

    num
    get avrLevel => sumLevel / data.length;

    num
    get sumCurrent => current.reduce((a, b) => a + b);

    num
    get minCurrent => current.reduce((a, b) => a < b? a : b);

    num
    get maxCurrent => current.reduce((a, b) => a > b? a : b);

    num
    get avrCurrent => sumCurrent / data.length;

    num
    get sumVoltage => voltage.reduce((a, b) => a + b);

    num
    get minVoltage => voltage.reduce((a, b) => a < b? a : b);

    num
    get maxVoltage => voltage.reduce((a, b) => a > b? a : b);

    num
    get avrVoltage => sumVoltage / data.length;

    num
    get sumTemperature => temperature.reduce((a, b) => a + b);

    num
    get minTemperature => temperature.reduce((a, b) => a < b? a : b);

    num
    get maxTemperature => temperature.reduce((a, b) => a > b? a : b);

    num
    get avrTemperature => sumTemperature / data.length;

    BatteryHealth
    get avrHealth => BatteryHealth.values[(health.map((e) => e.index).reduce((a, b) => a + b) / health.length).floor()];

    BatteryPlugged
    get avrPlugged => BatteryPlugged.values[(plugged.map((e) => e.index).reduce((a, b) => a + b) / plugged.length).floor()];

    ChargingStatus
    get avrStatus => ChargingStatus.values[(status.map((e) => e.index).reduce((a, b) => a + b) / status.length).floor()];

    String
    get avrTechnology => technology.first;
}

class BatteryData {
    final num level;
    final num current;
    final num voltage;
    final num temperature;
    final String technology;
    final DateTime time;
    final BatteryHealth health;
    final BatteryPlugged plugged;
    final ChargingStatus status;

    BatteryData({
        required this.level,
        required this.current,
        required this.voltage,
        required this.temperature,
        required this.health,
        required this.plugged,
        required this.technology,
        required this.status,
        required this.time,
    });
}