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
      
      // Thiết lập cửa sổ cơ bản ngay từ đầu
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(false);
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      print("Basic window options applied early");
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
    
    // Áp dụng hiệu ứng trong suốt trước khi chạy ứng dụng
    try {
      if (Platform.isMacOS) {
        try {
          await MacOSWindowUtils.initialize();
          WindowManipulator.makeWindowFullyTransparent();
          print("macOS transparency applied early");
        } catch (e) {
          print("Error in early macOS transparency: $e");
        }
      } else {
        try {
          Window.setEffect(
            effect: WindowEffect.transparent,
            color: Colors.transparent,
          );
          print("Non-macOS transparency applied early");
        } catch (e) {
          print("Error applying early transparency: $e");
        }
      }
    } catch (e) {
      print("Error applying early transparency effects: $e");
    }

    // Chạy ứng dụng
    runApp(const KeyvizApp());

    // Hoàn thiện cấu hình cửa sổ sau khi ứng dụng đã chạy
    try {
      await _finalizeWindow();
      print("Window finalization completed");
    } catch (e) {
      print("Error during window finalization: $e");
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

Future<void> _finalizeWindow() async {
  try {
    // Đợi ngắn để ứng dụng hiển thị
    await Future.delayed(Duration(milliseconds: 500));
    print("Short wait before finalizing window...");
    
    // Thiết lập cửa sổ cuối cùng
    await windowManager.waitUntilReadyToShow(null, () async {
      try {
        // Hiển thị cửa sổ
        await windowManager.show();
        print("Window shown");
        
        // Đợi ngắn để đảm bảo cửa sổ đã hiển thị
        await Future.delayed(Duration(milliseconds: 300));
        
        // Áp dụng các thiết lập cuối cùng
        if (Platform.isMacOS) {
          try {
            await WindowManipulator.zoomWindow();
            print("macOS window zoomed");
          } catch (e) {
            print("Error zooming macOS window: $e");
          }
        }
        
        // Áp dụng các thiết lập cuối cùng
        await windowManager.setIgnoreMouseEvents(true);
        await windowManager.setSkipTaskbar(true);
        print("Final window settings applied");
      } catch (e) {
        print("Error in window finalization steps: $e");
      }
    });
  } catch (e) {
    print("Error in _finalizeWindow: $e");
    rethrow;
  }
}
