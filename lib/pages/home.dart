import 'dart:async';
import 'dart:math' as math;

import 'package:baterai/pages/history.dart';
import 'package:flutter/material.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

import '../data/enums.dart';
import 'settings.dart';
import 'record.dart';
import '../data/battery_record.dart';
import '../data/history.dart';
import '../utils/build_context.dart';

class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    final _level       = ValueNotifier<num>(0);
    final _current     = ValueNotifier<num>(0);
    final _minCurrent  = ValueNotifier<num>(0);
    final _maxCurrent  = ValueNotifier<num>(0);
    final _temperature = ValueNotifier<num>(0);
    final _voltage     = ValueNotifier<num>(0);
    final _technology  = ValueNotifier<String>('Unknown');
    final _health      = ValueNotifier<BatteryHealth>(BatteryHealth.unknown);
    final _plugged     = ValueNotifier<BatteryPlugged>(BatteryPlugged.unknown);
    final _status      = ValueNotifier<ChargingStatus>(ChargingStatus.Unknown);
    final _time        = ValueNotifier<Duration>(const Duration(seconds: 1));
    final _recordData      = <BatteryData>[];
    bool _isRecording  = false;
    Timer? _timer;

    void _measureDeviceBattery() async {
        if (await KeepScreenOn.isOn == true) await KeepScreenOn.turnOff();
        if (_isRecording) await KeepScreenOn.turnOn();

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            BatteryInfoPlugin().androidBatteryInfo.then((value) {
                _level      .value = value?.batteryLevel   ?? _level.value;
                _current    .value = ((value?.currentNow   ?? _current.value) / 1000).round();
                _voltage    .value = (value?.voltage       ?? _voltage.value) / 1000;
                _temperature.value = value?.temperature    ?? _temperature.value;
                _technology .value = value?.technology     ?? _technology.value;
                _status     .value = value?.chargingStatus ?? _status.value;
                _minCurrent .value = math.min<num>(_current.value, _minCurrent.value);
                _maxCurrent .value = math.max<num>(_current.value, _maxCurrent.value);

                switch (value?.health){
                    case 'health_good'        : _health.value = BatteryHealth.good              ; break;
                    case 'dead'               : _health.value = BatteryHealth.dead              ; break;
                    case 'over_heat'          : _health.value = BatteryHealth.overheat          ; break;
                    case 'over_voltage'       : _health.value = BatteryHealth.overvoltage       ; break;
                    case 'cold'               : _health.value = BatteryHealth.cold              ; break;
                    case 'unspecified_failure': _health.value = BatteryHealth.unspecifiedFailure; break;
                    default                   : _health.value = BatteryHealth.unknown           ; break;
                }

                switch (value?.pluggedStatus){
                    case 'AC'      : _plugged.value = BatteryPlugged.ac      ; break;
                    case 'USB'     : _plugged.value = BatteryPlugged.usb     ; break;
                    case 'wireless': _plugged.value = BatteryPlugged.wireless; break;
                    default        : _plugged.value = BatteryPlugged.unknown ; break;
                }

                // record battery state
                if (_isRecording){
                    _recordData.add(BatteryData(
                        level: _level.value,
                        current: _current.value,
                        voltage: _voltage.value,
                        technology: _technology.value,
                        temperature: _temperature.value,
                        health: _health.value,
                        plugged: _plugged.value,
                        status: _status.value,
                        time: DateTime.now()
                    ));
                }
            });

            if (_isRecording) _time.value += const Duration(seconds: 1);
        });
    }

    void _startRecorder(){
        _recordData.clear();
        _time.value = const Duration();
        _minCurrent.value = _maxCurrent.value = 0;
        setState((){
            _isRecording = true;
        });
        _measureDeviceBattery();
    }

    void _stopRecorderAndPreviewResult(){
        setState((){
            _isRecording = false;
        });
        if (_recordData.isEmpty) {
            context.showSnackBar(const Text('The record was canceled'));
            return;
        }

        final record = BatteryRecord(data: List.from(_recordData));

        BatteryRecordHistory(record: record).insertDB();
        context.navigate(builder: (context) => RecordPage(record: record));
    }

    @override
    void didChangeDependencies(){
        super.didChangeDependencies();
        _measureDeviceBattery();
    }

    @override
    void dispose(){
        _timer?.cancel();
        super.dispose();
    }

    dynamic _appBar(){
        List<Widget> actions = [
            IconButton(
                onPressed: () => context.navigate(builder: (context) => const HistoryPage()),
                icon: const Icon(Icons.history)
            ),
            IconButton(
                onPressed: () => context.navigate(builder: (context) => const SettingsPage()),
                icon: const Icon(Icons.settings_outlined)
            ),
        ];

        return AppBar(
            title: const Text('Baterai'),
            actions: [
                ...actions,
                const SizedBox(width: 8.0)
            ],
        );
    }

    Widget _body(){
        var textTheme = context.textTheme;
        var colorScheme = context.colorScheme;

        Widget current = ValueListenableBuilder<num>(
            valueListenable: _current,
            builder: (context, value, _) => Text(
                '$value mA',
                style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
            )
        );

        Widget minMaxCurrent = Card(
            elevation: 0,
            color: colorScheme.surfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99999.0)),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        ValueListenableBuilder<num>(
                            valueListenable: _minCurrent,
                            builder: (context, value, child) => Text(
                                '$value mA',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                            )
                        ),
                        Container(
                            height: 16.0,
                            width: 1.0,
                            color: colorScheme.onSurfaceVariant,
                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        ValueListenableBuilder<num>(
                            valueListenable: _maxCurrent,
                            builder: (context, value, child) => Text(
                                '$value mA',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                            )
                        ),
                    ]
                ),
            ),
        );

        Widget otherInfo = Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                    ValueListenableBuilder<ChargingStatus>(
                        valueListenable: _status,
                        builder: (context, value, child) => Chip(
                            avatar: const Icon(Icons.info_outline_rounded),
                            label: Text(value.name)
                        )
                    ),
                    ValueListenableBuilder<BatteryHealth>(
                        valueListenable: _health,
                        builder: (context, value, child) => Chip(
                            avatar: const Icon(Icons.favorite_border_outlined),
                            label: Text(value.inString())
                        )
                    ),
                    ValueListenableBuilder<num>(
                        valueListenable: _level,
                        builder: (context, value, child) => Chip(
                            avatar: const Icon(Icons.battery_4_bar_outlined),
                            label: Text('$value %')
                        )
                    ),
                    ValueListenableBuilder<num>(
                        valueListenable: _voltage,
                        builder: (context, value, child) => Chip(
                            avatar: const Icon(Icons.bolt_outlined),
                            label: Text('$value V')
                        )
                    ),
                    ValueListenableBuilder<num>(
                        valueListenable: _temperature,
                        builder: (context, value, child) => Chip(
                            avatar: const Icon(Icons.thermostat_outlined),
                            label: Text('$value °C')
                        )
                    ),
                    ValueListenableBuilder<String>(
                        valueListenable: _technology,
                        builder: (context, value, child) => Chip(
                            avatar: const Icon(Icons.memory_outlined),
                            label: Text(value),
                        )
                    ),
                    ValueListenableBuilder<BatteryPlugged>(
                        valueListenable: _plugged,
                        builder: (context, value, child) => Chip(
                            avatar: const Icon(Icons.power_outlined),
                            label: Text(value.inString()),
                        )
                    ),
                ],
            ),
        );

        return SafeArea(child: Center(child: SingleChildScrollView(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                current,
                minMaxCurrent,
                otherInfo,
                const SizedBox(height: 88.0) // floating action button
            ],
        ))));
    }

    Widget _floatingActionButton(){
        if (_isRecording) {
            return FloatingActionButton.extended(
                onPressed: _stopRecorderAndPreviewResult,
                icon: const Icon(Icons.pause_outlined),
                label: ValueListenableBuilder<Duration>(
                    valueListenable: _time,
                    builder: (context, time, child) => Text(
                        '${time.inMinutes >= 60? '${'${time.inHours}'}:':''}${'${time.inMinutes % 60}'.padLeft(2, '0')}:${'${time.inSeconds % 60}'.padLeft(2, '0')}'
                    )
                )
            );
        }
        return FloatingActionButton.extended(
            onPressed: _startRecorder,
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Record')
        );
    }

    @override
    Widget build(BuildContext context) {
        context.changeSystemUI();

        return Scaffold(
            appBar: _appBar(),
            body: _body(),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: _floatingActionButton(),
        );
    }
}