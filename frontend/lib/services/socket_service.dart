import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import '../features/announcements/announcement_provider.dart';
import 'package:provider/provider.dart';

class SocketService {
  static IO.Socket? socket;

  static void connect(BuildContext context, String userId) {
    socket = IO.io('http://192.168.1.102:5001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket?.connect();

    socket?.onConnect((_) {
      print('✅ Socket connected');
      socket?.emit('join', userId);
    });

    socket?.on('new_announcement', (data) {
      print('🔔 Нове оголошення: ${data['title']}');


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 Нове оголошення: ${data['title']}'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.blue,
          action: SnackBarAction(
            label: 'Оновити',
            textColor: Colors.white,
            onPressed: () {
              Provider.of<AnnouncementProvider>(context, listen: false)
                  .fetchAnnouncements();
            },
          ),
        ),
      );

      Provider.of<AnnouncementProvider>(context, listen: false)
          .fetchAnnouncements();
    });

    socket?.onDisconnect((_) => print('❌ Socket disconnected'));
  }

  static void disconnect() {
    socket?.disconnect();
  }
}