import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:band_names/src/features/domain/entities/enums/enum_server_status.dart';

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;

  ServerStatus get serverStatus => _serverStatus;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
// Dart client
    io.Socket socket = io.io('http://localhost:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    /*socket.on('connect', (_) {
      log('connect0', name: 'socket');
      _serverStatus = ServerStatus.onLine;
      notifyListeners();
      //socket.emit('msg', 'test');
    });*/
    socket.onConnect((_) {
      log('connect', name: 'socket');
      _serverStatus = ServerStatus.online;
      notifyListeners();
      //socket.emit('msg', 'test');
    });
    socket.onDisconnect((_) {
      log('disconnect', name: 'socket');
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });
  }
}
