import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fruver/common/models/user_model.dart';

import 'common/services/storage_service.dart';
import 'main.dart';

class Global {
  static late StorageService storageService;
  static late UserModel userModel;
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    app = await Firebase.initializeApp(
      // name: 'move-work',
      // options: DefaultFirebaseOptions.currentPlatform,
    );

    auth = FirebaseAuth.instanceFor(app: app);

    const fatalError = true;
    // Non-async exceptions
    FlutterError.onError = (errorDetails) {
      if (fatalError) {
        // If you want to record a "fatal" exception
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        // ignore: dead_code
      } else {
        // If you want to record a "non-fatal" exception
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      }
    };
    // Async exceptions
    PlatformDispatcher.instance.onError = (error, stack) {
      if (fatalError) {
        // If you want to record a "fatal" exception
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        // ignore: dead_code
      } else {
        // If you want to record a "non-fatal" exception
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
      return true;
    };

    storageService = await StorageService().init();
    userModel = storageService.getUserProfile() ?? UserModel();
  }
}
