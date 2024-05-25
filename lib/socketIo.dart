import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/io.dart';

class ScoketIo extends StatefulWidget {
  const ScoketIo({Key? key}) : super(key: key);

  @override
  State<ScoketIo> createState() => _ScoketIoState();
}

class _ScoketIoState extends State<ScoketIo> {

  IO.Socket? socket;
  StreamSocket streamSocket = StreamSocket();

  @override
  void initState() {
    super.initState();

    try {

      IO.Socket socket = IO.io(
          "wss://trk.livemtr.com/graphql",
          IO.OptionBuilder()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .setExtraHeaders({'Connection': 'upgrade', 'Upgrade': 'websocket'})
              .enableAutoConnect()
              .enableForceNew()
              .build());
      socket.connect();


      socket.onConnect((data) => print("=====>>   Connect"));

      socket.onError((data) => print("======>>> error ${data}"));

      socket.on("event", (data) => streamSocket.addResponse);

      socket.onDisconnect((data) => print("=====>>> Disconnect"));



    } catch (e) {
      print("====== --- >>> $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(socket?.id ?? ""),
      ),
    );
  }
}

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
