import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefManager {
  // setting user's logged-in status
  static void setLoggedInStatusTrue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(StringConstant.spIsLoggedIn, true);
  }
    static  setNotificationCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(StringConstant.unreadNotificationCount, count);
  }
Future<void> saveStepToPrefs(int step,templeId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'temple_step_${templeId ?? 'new'}';
  await prefs.setInt(key, step);
}
Future<int?> getStepFromPrefs(templeId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'temple_step_${templeId ?? 'new'}';
  return prefs.getInt(key);
}

  static void setUserAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserAccessToken, accessToken);
  }

  static void setUserSessionId(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserSessionId, sessionId);
  }
    static void setIsGuest(bool isGuest) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(StringConstant.isGuest, isGuest);
    }

  static void setUserCsrfToken(String csrfToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserCsrfToken, csrfToken);
  }

  static void setUserDevalayId(String devalayId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserDevalayId, devalayId);
  }

  static void setAdmin(String admin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.admin, admin);
  }

  static void setUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserName, userName);
  }
  static void setUserFristName(String firstName ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserFirstName, firstName);
  }

  static void setFcmToken(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.fcmTokenName, fcmToken);
  }
  static void setUserEmail(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserEmail, userEmail);
  }

  static void setUserProfileImage(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserImageUrl, imageUrl);
  }

  static void setUserProfileImageUrl(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserProfileUrl , imageUrl);
  }

      static  Future<bool> getIsGuest() async {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.getBool(StringConstant.isGuest);
 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool(StringConstant.isGuest);
    return value ?? false;
  
    }
  static Future<String?> getUserFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(StringConstant.fcmTokenName);
  

  }
  /// Checking whether user is logged in or not
  static Future<bool> getLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool(StringConstant.spIsLoggedIn);
    return value ?? false;
  }

  static Future<String?> getUserSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserSessionId);
  }

  static Future<String?> getUserAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserAccessToken);
  }


 static Future<int?> getUnreadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // First try to get as int (preferred method)
    int? intValue = prefs.getInt(StringConstant.unreadNotificationCount);
    if (intValue != null) {
      return intValue;
    }
    
    // Fallback to string parsing if int is not available
    String? stringValue = prefs.getString(StringConstant.unreadNotificationCount);
    if (stringValue != null && stringValue.isNotEmpty) {
      try {
        return int.parse(stringValue);
      } catch (e) {
        return 0; // Return 0 if parsing fails
      }
    }
    
    return 0; // Return 0 if no value is stored
  }
  static void setLoginMethod(String loginMethod) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(StringConstant.spUserLoginMethod, loginMethod);
  }
 static void setIsPandit(bool pantid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(StringConstant.spIsPandit, pantid);
  }

  static Future<String?> getUserCsrfToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserCsrfToken);
  }

  static Future<String?> getUserLoginMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserLoginMethod);
  }

  static Future<String?> getUserDevalayId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserDevalayId);
  }

  
 static Future<bool?> getIsPandit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StringConstant.spIsPandit);
  }
  static Future<String?> getAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.admin);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserEmail);
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserName);
  }
   static Future<String?> getUserFirstName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserFirstName);
  }

  static Future<String?> getUserProfileImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserProfileUrl);
  }
   static Future<String?> getUserProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(StringConstant.spUserImageUrl);
  }

  // State persistence methods for dashboard
  static Future<int?> getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> setInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }


  // Clearing the preferences (await this to ensure data is cleared before navigating)
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
