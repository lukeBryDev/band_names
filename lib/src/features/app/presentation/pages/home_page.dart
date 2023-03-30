import 'package:band_names/services/socket_service.dart';
import 'package:band_names/src/features/domain/entities/enums/enum_server_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';

import 'package:band_names/src/features/data/models/band_model.dart';
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
    socketService.socket.on('active-bands', (payload) {
      log('$payload', name: 'socket - active-bands');
      if (payload is List) {
        bands = (payload).map((e) => BandModel.fromJson(e)).toList();
      }
      setState(() {});
    });

    super.initState();
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
        title: const Text('Band Names'),
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
      body: RefreshIndicator(
        onRefresh: () async {
          bands = [
            BandModel(id: '1', name: 'Pink Floyd', votes: 100),
            BandModel(id: '2', name: 'Guns & Roses', votes: 50),
            BandModel(id: '3', name: 'Metallica', votes: 60),
            BandModel(id: '4', name: 'Tame Impala', votes: 40),
            BandModel(id: '5', name: 'The Doors', votes: 100),
          ];
        },
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
              return Dismissible(
                key: Key(bands[realIdx].id ?? '$realIdx'),
                onDismissed: (direction) {
                  bands.removeAt(realIdx);
                  // TODO: call delete form server
                },
                background: Container(
                  padding: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(color: Colors.redAccent),
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
                  onTap: () {},
                  leading: IntrinsicWidth(
                    child: Row(
                      children: [
                        Text('${realIdx + 1}'),
                        const SizedBox(width: 5),
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child:
                              Text(bands[realIdx].name?.substring(0, 2) ?? ''),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _addNewBandDialog();
        },
        elevation: 1,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _addNewBandDialog() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('New band name'),
              content: TextField(
                controller: _banNameTxtCtrl,
                onChanged: (String t) {
                  setState(() {});
                },
              ),
              actions: [
                MaterialButton(
                  onPressed: _addNewBand,
                  elevation: 5,
                  textColor: Colors.blue,
                  child: const Text('Add'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  elevation: 5,
                  child: const Text('Cancel'),
                ),
              ],
            );
          });
    } else if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: const Text('New band name'),
              content: CupertinoTextField(
                controller: _banNameTxtCtrl,
                onChanged: (String t) {
                  setState(() {});
                },
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Dismiss'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: _addNewBand,
                  child: const Text('Add'),
                ),
              ],
            );
          });
    } else {
      return;
    }
  }

  Future<void> _addNewBand() async {
    if (_banNameTxtCtrl.text.isNotEmpty) {
      log(_banNameTxtCtrl.text, name: 'name:');
      bands.add(BandModel(
          id: DateTime.now().toString(),
          name: _banNameTxtCtrl.text,
          votes: _banNameTxtCtrl.text.length));
      setState(() {});
    }
    Navigator.of(context).pop();
  }
}
