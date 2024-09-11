import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'entities/classe.dart';
import 'features/explorer/explorer.dart';
import 'features/settings/settings_controller.dart';
import 'repositories/classes_repository.dart';
import 'shared/classes_store.dart';

Future<void> main() async {
  await Hive.initFlutter('.elpcd_database');
  Hive.registerAdapter<Classe>(ClasseAdapter());

  final classesBox = await Hive.openBox<Classe>('classes');
  final settingsBox = await Hive.openBox<Object>('settings');

  runApp(
    MultiProvider(
      providers: [
        Provider<ClassesRepository>.value(
          value: HiveClassesRepository(classesBox),
        ),
        ChangeNotifierProvider(
          create: (context) => ClassesStore(
            repository: context.read<ClassesRepository>(),
          ),
        ),
        Provider(create: (_) => ClassesTreeViewController()),
        ChangeNotifierProvider(create: (_) => SettingsController(settingsBox)),
      ],
      child: const ElPCDApp(),
    ),
  );
}
