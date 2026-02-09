import 'package:shared_preferences/shared_preferences.dart';

class ProfileCheckUtility {
  // Define minimum requirements for contribution
  static Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final congregation = prefs.getString('user_congregation');

    // Profile is complete if both name and congregation are present and not empty
    return name != null && name.trim().isNotEmpty && 
           congregation != null && congregation.trim().isNotEmpty;
  }
}