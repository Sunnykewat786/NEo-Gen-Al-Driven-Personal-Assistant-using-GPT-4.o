import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:translator_plus/translator_plus.dart';  // Preserved translator import

// [Rest of your existing imports remain exactly the same...]
import 'package:neo_ai_assistant/controller/chat_controller.dart';
import 'package:neo_ai_assistant/controller/note_controller.dart';
import 'package:neo_ai_assistant/controller/todo_controller.dart';
import 'package:neo_ai_assistant/controller/translate_controller.dart';
import 'package:neo_ai_assistant/helper/global.dart';
import 'package:neo_ai_assistant/helper/pref.dart';
import 'package:neo_ai_assistant/model/note/note.dart';
import 'package:neo_ai_assistant/model/todo/todo.dart';
import 'package:neo_ai_assistant/model/chat/chat.dart';
import 'package:neo_ai_assistant/model/translate/translate.dart';
import 'package:neo_ai_assistant/screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ===== ONLY CHANGE STARTS HERE =====
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'todo_reminders',
        channelName: 'Task Reminders',
        channelDescription: 'Notifications for your scheduled tasks',
        importance: NotificationImportance.High,
        defaultColor: Colors.deepPurple,
        ledColor: Colors.deepPurple,
        playSound: true,
        soundSource: 'resource://raw/notification_sound.wav',
      )
    ],
  );
  // ===== ONLY CHANGE ENDS HERE =====

  // [Rest of your existing initialization code remains exactly the same...]
  await Pref.initialize();
  await MediaStore.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive
    ..registerAdapter(NoteAdapter())
    ..registerAdapter(TodoAdapter())
    ..registerAdapter(SubtaskAdapter())
    ..registerAdapter(ChatAdapter())
    ..registerAdapter(ChatTypeAdapter())
    ..registerAdapter(TranslationHistoryItemAdapter());

  try {
    await Future.wait([
      Hive.openBox<Note>('notes'),
      Hive.openBox<Todo>('todos'),
      Hive.openBox<Chat>('chat_history'),
      Hive.openBox<Translation>('translation_history'),
      Hive.openBox('myData'),
    ]);
  } catch (e) {
    print('Error opening Hive boxes: $e');
  }

  Get.put(NoteController(), permanent: true);
  Get.put(ChatController(), permanent: true);
  Get.put(TranslateController(), permanent: true);
  Get.put(TodoController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ===== ADDED NOTIFICATION PERMISSION CHECK =====
  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }
  // ===== END OF ADDITION =====

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      themeMode: Pref.defaultTheme,
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue),
          titleTextStyle: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightTextColor => brightness == Brightness.dark
      ? Colors.white70
      : Colors.black54;

  Color get buttonColor => brightness == Brightness.dark
      ? Colors.cyan.withOpacity(0.5)
      : Colors.blue;
}