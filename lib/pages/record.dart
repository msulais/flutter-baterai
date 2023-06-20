// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:baterai/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/services.dart';

import '../data/battery_record.dart';
import '../data/enums.dart';
import '../utils/build_context.dart';

class RecordPage extends StatefulWidget {
    const RecordPage({super.key, required this.record});

    final BatteryRecord record;

    @override
    State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {

    late BatteryRecord record;
    bool _isLoading = true;

    void _copy(String text){
        Clipboard.setData(ClipboardData(text: text));
        context.showSnackBar(const Text('Copied to clipboard'));
    }


    void _updateData(){
        setState(() => _isLoading = true);
        final settings = context.settings();
        final time = settings.recordPage.time;
        final timeValue = settings.recordPage.timeValue;
        List<BatteryData> data = [];

        setState((){
            for (int i = 1; i <= widget.record.data.length; i++){
                if (
                    (time == Time.seconds && i %  timeValue == 0        ) ||
                    (time == Time.minutes && i % (timeValue * 60  ) == 0) ||
                    (time == Time.hours   && i % (timeValue * 3600) == 0)
                ){
                    data.add(widget.record.data[i-1]);
                }
            }

            if (data.isEmpty) data.add(widget.record.data[0]);

            record = BatteryRecord(data: data);
            _isLoading = false;
        });
    }

    @override
    void initState(){
        super.initState();
        record = BatteryRecord(data: widget.record.data);
    }

    @override
    void didChangeDependencies(){
        super.didChangeDependencies();
        _updateData();
    }

    List<Widget> _timelineData(){
        final settings = context.settings(true);

        num lowest = record.minCurrent;
        Widget currentChart = _chartBar(
            name: 'Current (mA)',
            unit: 'mA',
            lowest: lowest,
            highest: record.maxCurrent,
            data: ChartData([List.generate(record.data.length, (index){
                num value = record.current[index];
                num y0 = lowest < 0 ? value > 0 ? lowest.abs() : (lowest.abs() - value.abs()) : 0;
                num y1 = y0 + value.abs();
                return ChartItem(y1.toDouble(), value: '$value'.removeTrailingZeros());
            })])
        );

        lowest = record.minVoltage;
        Widget voltageChart = _chartBar(
            name: 'Voltage (V)',
            unit: 'V',
            lowest: lowest,
            highest: record.maxVoltage,
            data: ChartData([List.generate(record.data.length, (index){
                num value = record.voltage[index];
                num y0 = lowest < 0 ? value > 0 ? lowest.abs() : (lowest.abs() - value.abs()) : 0;
                num y1 = y0 + value.abs();
                return ChartItem(y1.toDouble(), value: '$value'.removeTrailingZeros());
            })])
        );

        lowest = record.minTemperature;
        Widget temperatureChart = _chartBar(
            name: 'Temperature (°C)',
            unit: '°C',
            lowest: lowest,
            highest: record.maxTemperature,
            data: ChartData([List.generate(record.data.length, (index){
                num value = record.temperature[index];
                num y0 = lowest < 0 ? value > 0 ? lowest.abs() : (lowest.abs() - value.abs()) : 0;
                num y1 = y0 + value.abs();
                return ChartItem(y1.toDouble(), value: '$value'.removeTrailingZeros());
            })])
        );

        lowest = record.minLevel;
        Widget levelChart = _chartBar(
            name: 'Level (%)',
            unit: '%',
            lowest: lowest,
            highest: record.maxLevel,
            data: ChartData([List.generate(record.data.length, (index){
                num value = record.level[index];
                num y0 = lowest < 0 ? value > 0 ? lowest.abs() : (lowest.abs() - value.abs()) : 0;
                num y1 = y0 + value.abs();
                return ChartItem(y1.toDouble(), value: '$value'.removeTrailingZeros());
            })])
        );

        lowest = 1;
        Widget statusChart = _chartBar(
            name: 'Status',
            data: ChartData([List.generate(record.data.length, (index){
                num value = record.status[index].index + 1;
                num y0 = lowest < 0 ? value > 0 ? lowest.abs() : (lowest.abs() - value.abs()) : 0;
                num y1 = y0 + value.abs();
                return ChartItem(y1.toDouble(), value: record.status[index].name);
            })])
        );

        lowest = 1;
        Widget healthChart = _chartBar(
            name: 'Health',
            data: ChartData([List.generate(record.data.length, (index){
                num value = record.health[index].index + 1;
                num y0 = lowest < 0 ? value > 0 ? lowest.abs() : (lowest.abs() - value.abs()) : 0;
                num y1 = y0 + value.abs();
                return ChartItem(y1.toDouble(), value: record.health[index].inString());
            })])
        );

        lowest = 1;
        Widget pluggedChart = _chartBar(
            name: 'Plugged',
            data: ChartData([List.generate(record.data.length, (index){
                num value = record.plugged[index].index + 1;
                num y0 = lowest < 0 ? value > 0 ? lowest.abs() : (lowest.abs() - value.abs()) : 0;
                num y1 = y0 + value.abs();
                return ChartItem(y1.toDouble(), value: record.plugged[index].inString());
            })])
        );

        List<Widget> timelineData = [
            if (settings.recordPage.showCurrent) currentChart,
            if (settings.recordPage.showVoltage) voltageChart,
            if (settings.recordPage.showTemperature) temperatureChart,
            if (settings.recordPage.showLevel) levelChart,
            if (settings.recordPage.showStatus) statusChart,
            if (settings.recordPage.showHealth) healthChart,
            if (settings.recordPage.showPlugged) pluggedChart
        ];

        if (settings.recordPage.mode == RecordShowMode.table){
            List<List<String>> data = [
                [
                    if (
                        settings.recordPage.showCurrent ||
                        settings.recordPage.showVoltage ||
                        settings.recordPage.showTemperature ||
                        settings.recordPage.showLevel ||
                        settings.recordPage.showStatus ||
                        settings.recordPage.showHealth ||
                        settings.recordPage.showPlugged
                    ) 'Time',
                    if (settings.recordPage.showCurrent) 'Current (mA)',
                    if (settings.recordPage.showVoltage) 'Voltage (V)',
                    if (settings.recordPage.showTemperature) 'Temperature (°C)',
                    if (settings.recordPage.showLevel) 'Level (%)',
                    if (settings.recordPage.showStatus) 'Status',
                    if (settings.recordPage.showHealth) 'Health',
                    if (settings.recordPage.showPlugged) 'Plugged'
                ],
                ...record.data.map<List<String>>((record) => [
                    if (
                        settings.recordPage.showCurrent ||
                        settings.recordPage.showVoltage ||
                        settings.recordPage.showTemperature ||
                        settings.recordPage.showLevel ||
                        settings.recordPage.showStatus ||
                        settings.recordPage.showHealth ||
                        settings.recordPage.showPlugged
                    ) '${record.time.hour}:${'${record.time.minute}'.padLeft(2, '0')}:${'${record.time.second}'.padLeft(2, '0')}',
                    if (settings.recordPage.showCurrent) '${record.current}'.removeTrailingZeros(),
                    if (settings.recordPage.showVoltage) '${record.voltage}'.removeTrailingZeros(),
                    if (settings.recordPage.showTemperature) '${record.temperature}'.removeTrailingZeros(),
                    if (settings.recordPage.showLevel) '${record.level}'.removeTrailingZeros(),
                    if (settings.recordPage.showStatus) record.status.name,
                    if (settings.recordPage.showHealth) record.health.inString(),
                    if (settings.recordPage.showPlugged) record.plugged.inString()
                ])
            ];

            List<Widget> dataWidget = List.generate(data.length, (i){
                return IntrinsicWidth(child: Column(children: List.generate(data[i].length, (j) => Container(
                    decoration: BoxDecoration(
                        color: j % 2 == 0? context.colorScheme.primaryContainer : context.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.only(
                            topLeft    : i == 0             && j == 0               ? const Radius.circular(10.0) : const Radius.circular(0),
                            bottomLeft : i == 0             && j == data[i].length-1? const Radius.circular(10.0) : const Radius.circular(0),
                            topRight   : i == data.length-1 && j == 0               ? const Radius.circular(10.0) : const Radius.circular(0),
                            bottomRight: i == data.length-1 && j == data[i].length-1? const Radius.circular(10.0) : const Radius.circular(0),
                        )
                    ),
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Center(child: Text(
                        data[i][j],
                        style: TextStyle(
                            color: j % 2 == 0? context.colorScheme.onPrimaryContainer : context.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold
                        )
                    )),
                ))));
            });

            timelineData = [Row(children: [Flexible(child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                    onLongPress: () => _copy(<String>[
                        ...List.generate(record.data.length, (i) {
                            var data = record.data[i];
                            var date = data.time;
                            return [
                                '${'${date.hour}'.padLeft(2, '0')}:${'${date.minute}'.padLeft(2, '0')}:${'${date.second}'.padLeft(2, '0')}',
                                if (settings.recordPage.showCurrent) '${'${data.current}'.removeTrailingZeros()}mA',
                                if (settings.recordPage.showVoltage) '${'${data.voltage}'.removeTrailingZeros()}V',
                                if (settings.recordPage.showTemperature) '${'${data.temperature}'.removeTrailingZeros()}°C',
                                if (settings.recordPage.showLevel) '${'${data.level}'.removeTrailingZeros()}%',
                                if (settings.recordPage.showStatus) data.status.name,
                                if (settings.recordPage.showHealth) data.health.inString(),
                                if (settings.recordPage.showPlugged) data.plugged.inString()
                            ].join('   ');
                        })
                    ].join('\n')),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(children: dataWidget),
                        ),
                    ),
                ),
            ))])];
        }
        return timelineData;
    }

    Widget _chartBar({
        required String name,
        required ChartData<dynamic> data,
        num lowest = 0,
        num highest = 0,
        String unit = ''
    }){
        const chartHeight = 200.0;

        Widget chart = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                child: Chart(
                    width: 300,
                    height: chartHeight,
                    state: ChartState(
                        data: data,
                        behaviour: const ChartBehaviour(scrollSettings: ScrollSettings(visibleItems: 5)),
                        itemOptions: WidgetItemOptions(widgetItemBuilder: (data){
                            num value = (){
                                if (double.tryParse('${data.item.value}') == null) return 0;

                                final value = double.parse('${data.item.value}');
                                if (value >= 0) {
                                    if (lowest < 0) return lowest.abs();
                                    else return 0;
                                }

                                return lowest.abs() - value.abs();
                            }().abs();
                            num max = highest.abs() + lowest.abs();
                            if (max <= 0) max = 1;

                            Widget bar = Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: context.colorScheme.primary
                                ),
                                margin: EdgeInsets.fromLTRB(4, 0, 4, chartHeight * value / max),
                            );

                            Widget barValue = Positioned(
                                top: -16,
                                left: 8,
                                child: Text(
                                    data.item.value.toString(),
                                    style: context.textTheme.labelSmall,
                                )
                            );

                            DateTime date = record.time[data.itemIndex];
                            Widget barTime = Positioned(
                                bottom: -16,
                                left: 8,
                                child: Text(
                                    '${date.hour}:${'${date.minute}'.padLeft(2, '0')}:${'${date.second}'.padLeft(2, '0')}',
                                    style: context.textTheme.labelSmall,
                                )
                            );

                            return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                    bar,
                                    barValue,
                                    barTime
                                ],
                            );
                        })
                    )
                ),
            ),
        );

        return Row(children: [Flexible(child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
                onLongPress: () => _copy([...List.generate(record.data.length, (i){
                    DateTime date = record.time[i];
                    return '${'${date.hour}'.padLeft(2, '0')}:${'${date.minute}'.padLeft(2, '0')}:${'${date.second}'.padLeft(2, '0')}   ${data.items[0][i].value}$unit';
                })].join('\n')),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        chart,
                    ]
                ),
            ),
        ))]);
    }

    dynamic _appBar(){
        var settings = context.settings(true);

        List<Widget> actions = [IconButton(
            onPressed: () => _copy(<String>[
                if (
                    settings.recordPage.showCurrent ||
                    settings.recordPage.showVoltage ||
                    settings.recordPage.showTemperature ||
                    settings.recordPage.showLevel ||
                    settings.recordPage.showStatus ||
                    settings.recordPage.showHealth ||
                    settings.recordPage.showPlugged
                ) List<String>.generate(record.data.length, (i) {
                    var data = record.data[i];
                    var date = data.time;
                    return <String>[
                        '${'${date.hour}'.padLeft(2, '0')}:${'${date.minute}'.padLeft(2, '0')}:${'${date.second}'.padLeft(2, '0')}',
                        if (settings.recordPage.showCurrent) '${'${data.current}'.removeTrailingZeros()}mA',
                        if (settings.recordPage.showVoltage) '${'${data.voltage}'.removeTrailingZeros()}V',
                        if (settings.recordPage.showTemperature) '${'${data.temperature}'.removeTrailingZeros()}°C',
                        if (settings.recordPage.showLevel) '${'${data.level}'.removeTrailingZeros()}%',
                        if (settings.recordPage.showStatus) data.status.name,
                        if (settings.recordPage.showHealth) data.health.inString(),
                        if (settings.recordPage.showPlugged) data.plugged.inString()
                    ].join('   ');
                }).join('\n'),
                'Current (mA)\n${[
                    'Avr: ${record.avrCurrent.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minCurrent}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxCurrent}'.removeTrailingZeros()}'
                ].join(', ')}',
                'Voltage (V)\n${[
                    'Avr: ${record.avrVoltage.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minVoltage}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxVoltage}'.removeTrailingZeros()}'
                ].join(', ')}',
                'Temperature (°C)\n${[
                    'Avr: ${record.avrTemperature.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minTemperature}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxTemperature}'.removeTrailingZeros()}'
                ].join(', ')}',
                'Technology\n${record.avrTechnology}'
            ].join('\n\n')),
            icon: const Icon(Icons.copy_outlined)
        )];

        return SliverAppBar.large(
            leadingWidth: 52.0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.navigateBack()
            ),
            title: const Text(
                'Record',
                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans')
            ),
            actions: [
                ...actions,
                const SizedBox(width: 8)
            ],
        );
    }

    Widget _body(){
        var settings = context.settings(true);

        Widget modeOptions = Container();
        if (
            settings.recordPage.showCurrent ||
            settings.recordPage.showVoltage ||
            settings.recordPage.showTemperature ||
            settings.recordPage.showLevel ||
            settings.recordPage.showStatus ||
            settings.recordPage.showHealth ||
            settings.recordPage.showPlugged
        ){
            modeOptions = Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                child: Row(children: [Flexible(child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    width: context.mediaQueryData.size.width,
                    child: SegmentedButton(
                        segments: const [
                            ButtonSegment(
                                value: RecordShowMode.table,
                                icon: Icon(Icons.table_chart_outlined),
                                label: Text('Table')
                            ),
                            ButtonSegment(
                                value: RecordShowMode.chart,
                                icon: Icon(Icons.assessment_outlined),
                                label: Text('Chart')
                            ),
                        ],
                        selected: {settings.recordPage.mode},
                        onSelectionChanged: (value) => setState(() => settings.recordPage.mode = value.first),
                    ),
                ))]),
            );
        }

        Widget dataOptions = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                child: Row(children: [
                    FilterChip(
                        avatar: settings.recordPage.showCurrent? null : Icon(Icons.text_increase_outlined, color: context.colorScheme.primary),
                        label: const Text('Current'),
                        selected: settings.recordPage.showCurrent,
                        onSelected: (value) => setState(() => settings.recordPage.showCurrent = value)
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                        avatar: settings.recordPage.showVoltage? null : Icon(Icons.bolt_outlined, color: context.colorScheme.primary),
                        label: const Text('Voltage'),
                        selected: settings.recordPage.showVoltage,
                        onSelected: (value) => setState(() => settings.recordPage.showVoltage = value)
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                        avatar: settings.recordPage.showTemperature? null : Icon(Icons.thermostat_outlined, color: context.colorScheme.primary),
                        label: const Text('Temperature'),
                        selected: settings.recordPage.showTemperature,
                        onSelected: (value) => setState(() => settings.recordPage.showTemperature = value)
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                        avatar: settings.recordPage.showLevel? null : Icon(Icons.battery_4_bar_outlined, color: context.colorScheme.primary),
                        label: const Text('Level'),
                        selected: settings.recordPage.showLevel,
                        onSelected: (value) => setState(() => settings.recordPage.showLevel = value)
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                        avatar: settings.recordPage.showStatus? null : Icon(Icons.info_outline_rounded, color: context.colorScheme.primary),
                        label: const Text('Status'),
                        selected: settings.recordPage.showStatus,
                        onSelected: (value) => setState(() => settings.recordPage.showStatus = value)
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                        avatar: settings.recordPage.showHealth? null : Icon(Icons.favorite_border_outlined, color: context.colorScheme.primary),
                        label: const Text('Health'),
                        selected: settings.recordPage.showHealth,
                        onSelected: (value) => setState(() => settings.recordPage.showHealth = value)
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                        avatar: settings.recordPage.showPlugged? null : Icon(Icons.power_outlined, color: context.colorScheme.primary),
                        label: const Text('Plugged'),
                        selected: settings.recordPage.showPlugged,
                        onSelected: (value) => setState(() => settings.recordPage.showPlugged = value)
                    ),
                ]),
            ),
        );

        Widget timeOptions = Container();
        if (
            settings.recordPage.showCurrent ||
            settings.recordPage.showVoltage ||
            settings.recordPage.showTemperature ||
            settings.recordPage.showLevel ||
            settings.recordPage.showStatus ||
            settings.recordPage.showHealth ||
            settings.recordPage.showPlugged
        ){
            timeOptions = Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(children: [
                    const SizedBox(width: 8),
                    const Text('Every: '),
                    PopupMenuButton(
                        itemBuilder: (context) => List<PopupMenuEntry<int>>.generate(60, (i) => CheckedPopupMenuItem(
                            checked: settings.recordPage.timeValue == i+1,
                            value: i+1,
                            padding: EdgeInsets.zero,
                            child: Text('${i+1}', style: context.textTheme.labelLarge)
                        )),
                        child: Chip(label: Text('${settings.recordPage.timeValue}')),
                        onSelected: (value){
                            settings.recordPage.setTimeValue = value;
                            _updateData();
                        },
                    ),
                    const SizedBox(width: 4.0),
                    PopupMenuButton(
                        itemBuilder: (context) => Time.values.map<PopupMenuEntry<Time>>((t) => CheckedPopupMenuItem(
                            checked: settings.recordPage.time == t,
                            value: t,
                            padding: EdgeInsets.zero,
                            child: Text(t.name, style: context.textTheme.labelLarge)
                        )).toList(),
                        child: Chip(label: Text(settings.recordPage.time.name)),
                        onSelected: (value){
                            settings.recordPage.setTime = value;
                            _updateData();
                        },
                    )
                ]),
            );
        }

        List<Widget> otherInfo = [
            ListTile(
                leading: const Icon(Icons.text_increase_outlined),
                title: const Text('Current (mA)'),
                subtitle: Text([
                    'Avr: ${record.avrCurrent.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minCurrent}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxCurrent}'.removeTrailingZeros()}'
                ].join(', ')),
                onLongPress: () => _copy('Current (mA)\n${[
                    'Avr: ${record.avrCurrent.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minCurrent}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxCurrent}'.removeTrailingZeros()}'
                ].join(', ')}'),
            ),
            ListTile(
                leading: const Icon(Icons.bolt_outlined),
                title: const Text('Voltage (V)'),
                subtitle: Text([
                    'Avr: ${record.avrVoltage.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minVoltage}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxVoltage}'.removeTrailingZeros()}'
                ].join(', ')),
                onLongPress: () => _copy('Voltage (V)\n${[
                    'Avr: ${record.avrVoltage.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minVoltage}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxVoltage}'.removeTrailingZeros()}'
                ].join(', ')}'),
            ),
            ListTile(
                leading: const Icon(Icons.thermostat_outlined),
                title: const Text('Temperature (°C)'),
                subtitle: Text([
                    'Avr: ${record.avrTemperature.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minTemperature}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxTemperature}'.removeTrailingZeros()}'
                ].join(', ')),
                onLongPress: () => _copy('Temperature (°C)\n${[
                    'Avr: ${record.avrTemperature.toStringAsFixed(3).removeTrailingZeros()}',
                    'Min: ${'${record.minTemperature}'.removeTrailingZeros()}',
                    'Max: ${'${record.maxTemperature}'.removeTrailingZeros()}'
                ].join(', ')}'),
            ),
            ListTile(
                leading: const Icon(Icons.memory_outlined),
                title: const Text('Technology'),
                subtitle: Text(record.avrTechnology),
                onLongPress: () => _copy('Technology\n${record.avrTechnology}'),
            ),
            ListTile(
                leading: const Icon(Icons.favorite_border_outlined),
                title: const Text('Health'),
                subtitle: Text(record.avrHealth.inString()),
                onLongPress: () => _copy('Health\n${record.avrHealth.inString()}'),
            ),
        ];

        Widget body = const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        if (!_isLoading){
            body = SliverList(delegate: SliverChildListDelegate([
                modeOptions,
                dataOptions,
                timeOptions,
                ..._timelineData(),
                const Divider(),
                ...otherInfo
            ]));
        }

        return SafeArea(
            top: false,
            child: CustomScrollView(slivers: [
                _appBar(),
                body
            ]),
        );
    }

    @override
    Widget build(BuildContext context) {
        context.changeSystemUI();
        return Scaffold(body: _body());
    }
}