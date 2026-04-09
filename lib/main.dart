import 'package:flutter/material.dart';
import 'package:ridenowappsss/app.dart';
import 'package:ridenowappsss/core/services/smile_id_service.dart';
import 'package:ridenowappsss/core/services/google_signin_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await _initializeImportantResources();

  runApp(const App());
}

Future<void> _initializeImportantResources() async {
  await SmileIDService().initialize();
  googleSignInService.initialize();
}
