import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chatapp/chat/repo/chat_repo.dart';
import 'package:chatapp/home/repo/home_repo.dart';
import 'package:chatapp/home/view_model/home_view_model.dart';
import 'package:chatapp/utils/app_state.dart';
import 'package:chatapp/utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:chatapp/chat/view_model/chat_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatapp/login/repository/login_repo.dart';
import 'package:chatapp/login/view/login_view.dart';
import 'package:chatapp/login/view_model/login_view_model.dart';
import 'package:chatapp/splash/view/splash_view.dart';
import 'package:chatapp/splash/view_model/splash_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../login/model/department_user_permission_response.dart' as response;
import 'dart:developer' as developer;
import 'dart:io' as platform;
import 'chat_bubble.dart';
import 'helpers/notification_helper.dart';
import 'home/view/home_view.dart';
import 'locator.dart';

SpeechToText speechToText = SpeechToText();
ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);
ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
ValueNotifier<bool> speakCompleted = ValueNotifier<bool>(true);
FlutterTts tts = FlutterTts();
Completer<void> ttsCompleter = Completer<void>();
// int response = 1;
bool speechEnabled = false;
bool shouldListen = true;
bool isListening = false;
String bgChatSessionId = '';
int prevChatLength = 0;
// String AppState.instance.triggeredWord = "";
PermissionStatus? notificationStatus;

ValueNotifier<SpeechStatus> speechStatus =
    ValueNotifier<SpeechStatus>(SpeechStatus.idle);

enum SpeechStatus { listening, speaking, idle }

bool? isVoiceEnabled;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final permissionsGranted = await requestPermissions();


  setupLocator();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(repo: locator<LoginRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(repo: locator<ChatRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => SplashViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(repo: locator<HomeRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // await initializeService();
}


Future<bool> requestPermissions() async {
  // Request notification permission
  final microphoneStatus = await Permission.microphone.request();
  notificationStatus = await Permission.notification.request();

  // Check if both permissions are granted
  if (microphoneStatus == PermissionStatus.granted &&
      notificationStatus == PermissionStatus.granted) {
    return true;
  } else {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatBot',
        initialRoute: constants.initialRoute,
        routes: {
          constants.initialRoute: (context) => const SplashScreenWidget(),
          constants.roleRoute: (context) => const LoginScreenWidget(),
          // constants.loginRoute: (context) => const LoginScreenWidget(),
          constants.homeRoute: (context) => const HomeScreenWidget(),
        },
        onGenerateRoute: (settings) {
          final String? data = settings.arguments as String?;
          if (settings.name == constants.loginRoute) {
            return MaterialPageRoute(
              builder: (context) => LoginScreenWidget(role: data ?? ''),
            );
          } else if (settings.name == constants.departmentLoginRoute) {
            return MaterialPageRoute(
              builder: (context) => LoginScreenWidget(role: data ?? ''),
            );
          }
          return null;
        },
      ),
    );
  }
}

