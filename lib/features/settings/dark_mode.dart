import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization.dart';
import 'settings_controller.dart';

class DarkModeSwitchIconButton extends StatelessWidget {
  const DarkModeSwitchIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = context.select<SettingsController, bool?>(
      (controller) => controller.darkMode,
    );

    final (icon, nextValue) = switch (darkMode) {
      null => (Icons.settings_brightness, true),
      true => (Icons.dark_mode_outlined, false),
      false => (Icons.light_mode_outlined, null),
    };

    return IconButton(
      tooltip: AppLocalizations.of(context).themeModeButtonText,
      icon: Icon(icon),
      onPressed: () {
        context.read<SettingsController>().updateDarkMode(nextValue);
      },
    );
  }
}
