// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'record.dart';
import '../data/history.dart';
import '../utils/build_context.dart';
import '../utils/string.dart';

class _BatteryRecordHistoryGroup {
    final DateTime date;
    final List<BatteryRecordHistory> histories;

    _BatteryRecordHistoryGroup({required this.histories, required this.date});
}

class HistoryPage extends StatefulWidget {
    const HistoryPage({super.key});

    @override
    State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
    final _historiesGroups = <_BatteryRecordHistoryGroup>[];
    List<BatteryRecordHistory> _histories = [];
    bool _isLoading = true;

    void _clear() async {
        bool isCancel = (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                icon: const Icon(Icons.history_outlined),
                title: const Text("Clear history"),
                content: const Text("Are you sure want to clear all history?"),
                actions: [
                    TextButton(onPressed: () => context.navigateBack(), child: const Text("Cancel")),
                    FilledButton.tonal(onPressed: () => context.navigateBack(false), child: const Text("Clear")),
                ]
            )
        )) ?? true;

        if (isCancel) return;

        await BatteryRecordHistory.clearDB();
        _update();
    }

    void _update() async {
        _histories = await BatteryRecordHistory.queryDB();
        _historiesGroups.clear();
        _histories.sort((a, b) => (a.date).compareTo(b.date));

        List<BatteryRecordHistory> items = List.from(_histories.reversed.toList());
        for (BatteryRecordHistory item in items){
            if (_historiesGroups.isEmpty){
                _historiesGroups.add(_BatteryRecordHistoryGroup(histories: [item], date: item.date));
            } else if (DateUtils.isSameDay(_historiesGroups.last.date, item.date)) {
                _historiesGroups.last.histories.add(item);
            } else {
                _historiesGroups.add(_BatteryRecordHistoryGroup(histories: [item], date: item.date));
            }
        }
        setState(() {
            _isLoading = false;
        });
    }

    void _showDetail(BatteryRecordHistory history) async {
        context.navigate(builder: (context) => RecordPage(record: history.record));
    }

    @override
    void didChangeDependencies() async {
        super.didChangeDependencies();
        _update();
    }

    dynamic _appBar() {
        Widget leading = IconButton(
            onPressed: () => context.navigateBack(),
            icon: const Icon(Icons.arrow_back)
        );

        List<Widget> actions = [
            AnimatedCrossFade(
                firstChild: Container(),
                secondChild: PopupMenuButton(
                    onSelected: (value){ switch(value){ case "clear": _clear(); } },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(
                            value: 'clear',
                            child: Text("Clear"),
                        )
                    ]
                ),
                crossFadeState: _historiesGroups.isNotEmpty? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250)
            )
        ];

        if (context.isBigScreen) {
            return AppBar(
                leading: leading,
                title: const Text('History'),
                actions: actions,
            );
        }

        return SliverAppBar.large(
            leadingWidth: 52.0,
            title: const Text(
                'History',
                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans')
            ),
            leading: leading,
            actions: actions,
        );
    }

    List<Widget> historiesWidget(int index){
        return List.generate(_historiesGroups[index].histories.length, (index2) {
            var history = _historiesGroups[index].histories[index2];

            void delete(BatteryRecordHistory history, int index, int index2) async {
                await history.deleteDB();
                setState((){
                    _historiesGroups[index].histories.removeAt(index2);
                    if (_historiesGroups[index].histories.isEmpty) _historiesGroups.removeAt(index);
                });
                if (mounted) context.showSnackBar(const Text('Deleted'));
            }

            Widget backgroundDismissible = Container(
                color: context.colorScheme.error,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                    Icon(Icons.delete_outlined, color: context.colorScheme.onError),
                    const SizedBox(width: 16),
                    Text("Delete", style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.onError))
                ])
            );

            Widget secondaryBackgroundDismissible = Container(
                color: context.colorScheme.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(16),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text("Delete", style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.onError)),
                    const SizedBox(width: 16),
                    Icon(Icons.delete_outlined, color: context.colorScheme.onError),
                ])
            );

            Duration time = Duration(seconds: history.record.data.length);
            Widget title = Text('${
                history.record.avrCurrent.toStringAsFixed(3).removeTrailingZeros()
            }mA, ${
                history.record.avrVoltage.toStringAsFixed(3).removeTrailingZeros()
            }V, ${
                history.record.avrTemperature.toStringAsFixed(3).removeTrailingZeros()
            }°C');
            Widget subtitle = Text('${history.record.avrTechnology}, ${history.record.avrHealth.inString()}');
            Widget trailing = Text('${time.inHours}:${'${time.inMinutes % 60}'.padLeft(2, '0')}:${'${time.inSeconds % 60}'.padLeft(2, '0')}');

            return Dismissible(
                key: ValueKey("${history.id}"),
                onDismissed: (direction) => delete(history, index, index2),
                background: backgroundDismissible,
                secondaryBackground: secondaryBackgroundDismissible,
                child: ListTile(
                    title: title,
                    subtitle: subtitle,
                    trailing: trailing,
                    onTap: () => _showDetail(history),
                ),
            );
        });
    }

    Widget _body(){
        if (_isLoading){
            if (context.isBigScreen) return const Center(child: CircularProgressIndicator());
            return CustomScrollView(slivers: [
                _appBar(),
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            ]);
        }

        if (_historiesGroups.isEmpty){
            Widget message = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Icon(Icons.history_outlined, size: context.textTheme.displayLarge?.fontSize),
                    const SizedBox(height: 16,),
                    Text("No history", style: context.textTheme.titleLarge)
                ]
            );

            if (context.isBigScreen) return SizedBox.expand(child: message);

            return CustomScrollView(slivers: [
                _appBar(),
                SliverFillRemaining(child: message)
            ]);
        }

        List<Widget> histories = List.generate(_historiesGroups.length, (index){

            Widget date = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                    DateFormat.yMMMMd().format(_historiesGroups[index].date),
                    style: TextStyle(fontWeight: FontWeight.bold, color: context.colorScheme.onPrimaryContainer)
                ),
            );

            return Card(
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                clipBehavior: Clip.antiAlias,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        date,
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        ...historiesWidget(index),
                        const SizedBox(height: 8),
                    ]
                )
            );
        });

        if (context.isBigScreen) {
            return SafeArea(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: ListView(
                            padding: EdgeInsets.zero,
                            children: histories,
                        )
                    )
                ],
            ));
        }

        return CustomScrollView(slivers: [
            _appBar(),
            SliverList(delegate: SliverChildListDelegate(histories))
        ]);
    }

    @override
    Widget build(BuildContext context) {
        context.changeSystemUI();

        return Scaffold(
            appBar: context.isBigScreen? _appBar() : null,
            body: _body()
        );
    }
}