import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;

  Future<void> initialize() async {
    await _googleSignIn.initialize(
      serverClientId: ApiConstants.googleWebClientId,
      clientId: ApiConstants.googleWebClientId,
      // scopes: [
      //   'email',
      //   'https://www.googleapis.com/auth/userinfo.profile',
      // ],
    );
  }

  gsi.GoogleSignIn get instance => _googleSignIn;
}


final googleSignInService = GoogleSignInService();
