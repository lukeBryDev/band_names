import 'package:band_names/src/core/env/env.dart';
import 'package:band_names/src/features/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //** Load environment file for project
  await dotenv.load(fileName: './environments/.env');
  //** Load Class for Environment App
  Env(EnvMode.production, const EnvOptions(stageNumberSandbox: 2));
  runApp(const App());
}
