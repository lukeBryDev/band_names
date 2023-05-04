import 'package:band_names/services/socket_service.dart';
import 'package:band_names/src/features/domain/entities/enums/enum_server_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Server connection status',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Status: ${socketService.serverStatus.label}'),
              Icon(
                Icons.circle,
                color: socketService.serverStatus.color,
              )
            ],
          ),
        ],
      ),
    );
  }
}
