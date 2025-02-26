import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/key_event.dart';
import 'providers/key_style.dart';
import 'windows/error/error.dart';
import 'windows/settings/settings.dart';
import 'windows/key_visualizer/key_visualizer.dart';
import 'windows/mouse_visualizer/mouse_visualizer.dart';

class KeyvizApp extends StatelessWidget {
  const KeyvizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Keyviz",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return GestureDetector(
                onTap: _removePrimaryFocus,
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) {
                      try {
                        return KeyEventProvider();
                      } catch (e) {
                        print("Error creating KeyEventProvider: $e");
                        return KeyEventProvider();
                      }
                    }),
                    ChangeNotifierProvider(create: (_) {
                      try {
                        return KeyStyleProvider();
                      } catch (e) {
                        print("Error creating KeyStyleProvider: $e");
                        return KeyStyleProvider();
                      }
                    }),
                  ],
                  child: const Material(
                    type: MaterialType.transparency,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ErrorView(),
                        KeyVisualizer(),
                        SettingsWindow(),
                        MouseVisualizer(),
                      ],
                    ),
                  ),
                ),
              );
            } catch (e, stackTrace) {
              print("Error building app: $e");
              print("Stack trace: $stackTrace");
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.red.withOpacity(0.8),
                  child: Text(
                    'Lỗi khi khởi tạo ứng dụng: $e',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _removePrimaryFocus() {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      print("Error removing primary focus: $e");
    }
  }
}
