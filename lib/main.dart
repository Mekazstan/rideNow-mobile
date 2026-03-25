import 'package:flutter/material.dart';
import 'package:ridenowappsss/app.dart';
import 'package:ridenowappsss/core/services/smile_id_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeImportantResources();

  runApp(const App());
}

Future<void> _initializeImportantResources() async {
  await SmileIDService().initialize();
  await GoogleSignIn.instance.initialize();
}
