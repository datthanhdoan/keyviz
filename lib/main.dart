import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hid_listener/hid_listener.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

void main() async {
  try {
    // ensure flutter plugins are intialized and ready to use
    WidgetsFlutterBinding.ensureInitialized();
    
    // Khởi tạo Window với xử lý lỗi
    try {
      await Window.initialize();
      print("Window initialized successfully");
    } catch (e) {
      print("Error initializing Window: $e");
    }
    
    // Khởi tạo window manager với xử lý lỗi
    try {
      await windowManager.ensureInitialized();
      print("Window manager initialized successfully");
    } catch (e) {
      print("Error initializing window manager: $e");
    }

    // Khởi tạo listener backend với xử lý lỗi
    try {
      if (getListenerBackend() != null) {
        if (!getListenerBackend()!.initialize()) {
          print("Failed to initialize listener backend");
        } else {
          print("Listener backend initialized successfully");
        }
      } else {
        print("No listener backend for this platform");
      }
    } catch (e) {
      print("Error initializing listener backend: $e");
    }

    // Chạy ứng dụng
    runApp(const KeyvizApp());

    // Khởi tạo cửa sổ với xử lý lỗi
    try {
      await _initWindow();
      print("Window initialization completed");
    } catch (e) {
      print("Error during window initialization: $e");
    }
  } catch (e, stackTrace) {
    // Xử lý lỗi tổng thể
    print("Fatal error during app initialization: $e");
    print("Stack trace: $stackTrace");
    
    // Hiển thị thông báo lỗi
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Không thể khởi động ứng dụng: $e',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
}

Future<void> _initWindow() async {
  try {
    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        skipTaskbar: true,
        alwaysOnTop: true,
        fullScreen: !Platform.isMacOS,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        try {
          await windowManager.setIgnoreMouseEvents(true);
          await windowManager.setHasShadow(false);
          await windowManager.setAsFrameless();
          print("Window options applied successfully");
        } catch (e) {
          print("Error applying window options: $e");
        }
      },
    );

    if (Platform.isMacOS) {
      try {
        WindowManipulator.makeWindowFullyTransparent();
        await WindowManipulator.zoomWindow();
        print("macOS specific window setup completed");
      } catch (e) {
        print("Error in macOS window setup: $e");
      }
    } else {
      try {
        Window.setEffect(
          effect: WindowEffect.transparent,
          color: Colors.transparent,
        );
        print("Non-macOS window effect applied");
      } catch (e) {
        print("Error applying window effect: $e");
      }
    }
    
    try {
      await windowManager.blur();
      print("Window blur applied");
    } catch (e) {
      print("Error applying window blur: $e");
    }
  } catch (e) {
    print("Error in _initWindow: $e");
    rethrow;
  }
}
