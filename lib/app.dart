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
      debugShowCheckedModeBanner: false,
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
                        final provider = KeyEventProvider();
                        print("KeyEventProvider created successfully");
                        return provider;
                      } catch (e) {
                        print("Error creating KeyEventProvider: $e");
                        return KeyEventProvider()..setError("Lỗi khởi tạo: $e");
                      }
                    }),
                    ChangeNotifierProvider(create: (_) {
                      try {
                        final provider = KeyStyleProvider();
                        print("KeyStyleProvider created successfully");
                        return provider;
                      } catch (e) {
                        print("Error creating KeyStyleProvider: $e");
                        return KeyStyleProvider();
                      }
                    }),
                  ],
                  child: const Material(
                    type: MaterialType.transparency,
                    color: Colors.transparent,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        KeyVisualizer(),
                        MouseVisualizer(),
                        SettingsWindow(),
                        ErrorView(),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Lỗi khởi tạo ứng dụng',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$e',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (Platform.isWindows) {
                            Process.run('cmd', ['/c', 'start', '', 'keyviz.exe']);
                          } else if (Platform.isMacOS) {
                            Process.run('open', ['-a', 'keyviz']);
                          } else if (Platform.isLinux) {
                            Process.run('keyviz', []);
                          }
                          exit(0);
                        },
                        child: const Text('Khởi động lại'),
                      ),
                    ],
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
