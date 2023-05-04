import 'package:band_names/services/socket_service.dart';
import 'package:band_names/src/features/domain/entities/enums/enum_server_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';

import 'package:band_names/src/features/data/models/band_model.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BandModel> bands = [
    /*BandModel(id: '1', name: 'Pink Floyd', votes: 100),
    BandModel(id: '2', name: 'Guns & Roses', votes: 50),
    BandModel(id: '3', name: 'Metallica', votes: 60),
    BandModel(id: '4', name: 'Tame Impala', votes: 40),
    BandModel(id: '5', name: 'The Doors', votes: 100),*/
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  void _handleActiveBands(dynamic payload) {
    log('$payload', name: 'socket - payload');

    switch (payload.runtimeType) {
      case List:
        bands.clear();
        for (var e in (payload as List)) {
          bands.add(BandModel.fromJson(e));
        }
        for (var e in bands) {
          int idx = bands.indexWhere((i) => i.id == e.id);
          bands[idx] = bands[idx].copyWith(
              color: Colors
                  .primaries[(e.name?.length ?? 0) % Colors.primaries.length]);
        }
        break;
    }
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  final TextEditingController _banNameTxtCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Band Names',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, 'status'),
            icon: Icon(
              socketService.serverStatus.icon,
              color: socketService.serverStatus.color,
            ),
            tooltip:
                'server connection status: ${socketService.serverStatus.label}',
          )
        ],
      ),
      body: IgnorePointer(
        ignoring: socketService.serverStatus == ServerStatus.offline ||
            socketService.serverStatus == ServerStatus.connecting,
        child: Column(
          children: [
            _pieChart(),
            Expanded(
              child: ListView.builder(
                  itemCount: bands.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return const ListTile(
                        leading: Text(
                          '#',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        title: Center(
                            child: Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        )),
                        trailing: Text(
                          'Votes',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }
                    final int realIdx = i - 1;
                    final socketService =
                        Provider.of<SocketService>(context, listen: false);
                    return Dismissible(
                      key: Key(bands[realIdx].id ?? '$realIdx'),
                      onDismissed: (_) => socketService.socket
                          .emit('delete-band', {"id": bands[realIdx].id}),
                      background: Container(
                        padding: const EdgeInsets.only(left: 8),
                        decoration:
                            const BoxDecoration(color: Colors.redAccent),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: const [
                                Text(
                                  'Delete band',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.restore_from_trash_sharp,
                                  color: Colors.white,
                                )
                              ],
                            )),
                      ),
                      child: ListTile(
                        onTap: () {
                          final socketService = Provider.of<SocketService>(
                              context,
                              listen: false);
                          socketService.socket
                              .emit('vote-band', {"id": bands[realIdx].id});
                        },
                        leading: IntrinsicWidth(
                          child: Row(
                            children: [
                              Text('${realIdx + 1}'),
                              const SizedBox(width: 5),
                              CircleAvatar(
                                backgroundColor: bands[realIdx].color,
                                child: Text(
                                    bands[realIdx].name?.substring(0, 2) ?? ''),
                              )
                            ],
                          ),
                        ),
                        title: Text(bands[realIdx].name ?? ''),
                        trailing: Text('${bands[realIdx].votes}'),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: IgnorePointer(
        ignoring: socketService.serverStatus == ServerStatus.offline ||
            socketService.serverStatus == ServerStatus.connecting,
        child: FloatingActionButton(
          onPressed: () async {
            _addNewBandDialog();
          },
          elevation: 1,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _pieChart() {
    if (bands.isEmpty) return const SizedBox();

    Map<String, double> dataMap = {};

    for (var e in bands) {
      dataMap.putIfAbsent(e.name ?? '', () => e.votes?.toDouble() ?? 0.0);
    }

    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 2,
        colorList: bands
            .map((e) =>
                e.color ??
                Colors.primaries[e.name?.length ?? 0 % Colors.primaries.length])
            .toList(),
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 20,
        centerText: "VOTES",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.left,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }

  Future<void> _addNewBandDialog() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('New band name'),
                content: TextField(
                  controller: _banNameTxtCtrl,
                  onChanged: (String t) => setState(() {}),
                ),
                actions: [
                  MaterialButton(
                    onPressed: _addNewBand,
                    elevation: 5,
                    textColor: Colors.blue,
                    child: const Text('Add'),
                  ),
                  MaterialButton(
                    onPressed: () => Navigator.of(context).pop(),
                    elevation: 5,
                    child: const Text('Cancel'),
                  ),
                ],
              ));
    } else if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: const Text('New band name'),
                content: CupertinoTextField(
                  controller: _banNameTxtCtrl,
                  onChanged: (String t) => setState(() {}),
                ),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: _addNewBand,
                    child: const Text('Add'),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
    } else {
      return;
    }
  }

  Future<void> _addNewBand() async {
    if (_banNameTxtCtrl.text.isNotEmpty) {
      final band = BandModel(name: _banNameTxtCtrl.text);
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', band.toJson());
    }
    Navigator.of(context).pop(); // Closes dialog
    _banNameTxtCtrl.text = ''; // reset input
  }
}
