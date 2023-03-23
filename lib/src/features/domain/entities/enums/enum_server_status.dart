import 'package:flutter/material.dart';

enum ServerStatus { connecting, online, offline }

extension FromServerStatus on ServerStatus {
  String? get label {
    Map<ServerStatus?, String> fromServerStatus = {
      ServerStatus.connecting: 'Connecting...',
      ServerStatus.online: 'Online',
      ServerStatus.offline: 'Offline',
      null: '',
    };
    return fromServerStatus[this];
  }

  Color? get color {
    Map<ServerStatus?, Color> fromServerStatus = {
      ServerStatus.connecting: Colors.orangeAccent,
      ServerStatus.online: Colors.greenAccent,
      ServerStatus.offline: Colors.redAccent,
      null: Colors.white,
    };
    return fromServerStatus[this];
  }

  IconData? get icon {
    Map<ServerStatus?, IconData> fromServerStatus = {
      ServerStatus.connecting: Icons.cloud,
      ServerStatus.online: Icons.cloud_done_rounded,
      ServerStatus.offline: Icons.cloud_off_rounded,
      null: Icons.cloud,
    };
    return fromServerStatus[this];
  }
}
