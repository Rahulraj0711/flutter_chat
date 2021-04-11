import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceUserLoggedInKey='isloggedin';
  static String sharedPreferenceUserNameKey='useridkey';
  static String sharedPreferenceUserEmailKey='useremailkey';
  static String sharedPreferenceUidKey='uid';
  static String sharedPreferencePhotoUrl='url';
  // static String sharedPreferencePhoneNo='phoneNo';

  static Future<bool> setUserLoggedInSharedPreference(bool isUserLoggedIn) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> setUserNameSharedPreference(String userName) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> setUserEmailSharedPreference(String userEmail) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  static Future<bool> setUIdSharedPreference(String uid) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUidKey, uid);
  }

  static Future<bool> setPhotoUrlSharedPreference(String photoUrl) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencePhotoUrl, photoUrl);
  }

    // static Future<bool> setPhoneNoSharedPreference(String phoneNo) async {
    //   SharedPreferences prefs=await SharedPreferences.getInstance();
    //   return await prefs.setString(sharedPreferencePhoneNo, phoneNo);
    // }

  static Future<bool> getUserLoggedInSharedPreference() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return prefs.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String> getUserNameSharedPreference() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserNameKey);
  }

  static Future<String> getUserEmailSharedPreference() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserEmailKey);
  }

  static Future<String> getUIdSharedPreference() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUidKey);
  }

  static Future<String> getPhotoUrlSharedPreference() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferencePhotoUrl);
  }

  // static Future<String> getPhoneNoSharedPreference() async {
  //   SharedPreferences prefs=await SharedPreferences.getInstance();
  //   return prefs.getString(sharedPreferencePhoneNo);
  // }

}