import 'package:band_names/services/socket_service.dart';
import 'package:band_names/src/features/app/presentation/pages/home_page.dart';
import 'package:band_names/src/features/app/presentation/pages/status_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SocketService(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: "home",
        routes: {
          "home": (_) => const HomePage(),
          "status": (_) => const StatusPage(),
        },
      ),
    );
  }
}
