import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/rooms_catalog.dart';

import 'booking_screen.dart';
import 'room_detail_screen.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<AppProvider>().rooms;
    void open(Widget page) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    final theme = ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B142B),
        colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7DD3FC), surface: Color(0xFF142544)));
    return Theme(
        data: theme,
        child: Scaffold(
          body: SafeArea(
              child: Column(children: [
            Expanded(
                child: SingleChildScrollView(
                    child: RoomsCatalog(
                        rooms: rooms,
                        onDetails: (room) => open(RoomDetailScreen(room: room)),
                        onBook: (room) => open(BookingScreen(room: room))))),
          ])),
        ));
  }
}
