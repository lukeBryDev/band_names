import 'dart:developer';

import 'package:band_names/src/core/env/env.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:band_names/src/features/domain/entities/enums/enum_server_status.dart';

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;

  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;

  IO.Socket get socket => _socket;

  Function get emit => _socket.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
// Dart client
    _socket = IO.io(Env.socketUri, {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    /*socket.on('connect', (_) {
      log('connect0', name: 'socket');
      _serverStatus = ServerStatus.onLine;
      notifyListeners();
      //socket.emit('msg', 'test');
    });*/
    _socket.onConnect((_) {
      log('connect', name: 'socket');
      _serverStatus = ServerStatus.online;
      notifyListeners();
      //socket.emit('msg', 'test');
    });
    _socket.onDisconnect((_) {
      log('disconnect', name: 'socket');
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _socket.on('mensaje', (payload) {
      log('$payload', name: 'socket');
    });

    _socket.on('emitir-mensaje', (payload) {
      log('$payload', name: 'socket - emitir-message');
    });
  }
}
