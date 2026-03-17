class AppConstant {
  static const baseUrl = "https://devalay.org/apis";
  static const baseUrls = "https://devalay.org/";
  // static const baseUrl = "http://192.168.1.7:8001/apis";
  // static const baseUrl = "http://192.168.1.42:8000/apis";
  static const forgetPassword = '/forgot-password/';
  static const validateOtp = '/validate-otp/';
  static const resetPassword = '/reset-password/';
  static const exploreDevalay = '/Devalay/?view=slider';
  static const exploreSingleDevalay = '/Devalay';
  static const exploreTempleFilter = '/Devalay/?view=filter';
  static const exploreFestival = '/Festival';
  static const exploreSingleFestival = '/Festival';
  static const exploreFestivalFilter = '/Festival/?view=filter';
  static const exploreDev = '/Dev/?view=slider';
  static const exploreSingleDev = '/Dev';
  static const exploreEvent = '/Event/?view=slider';
  static const exploreSingleEvent = '/Event';
  static const exploreEventFilter = '/Event/?view=filter';
  static const explorePuja = '/Puja/?view=slider';
  static const exploreSinglePuja = '/Puja';

  //login
  static const login = '/login/';
  static const register = '/signin/';
  static const appleLogin = '/apple-login/';
  static const googleLogin = '/google-login/';
  static const numberLogin = '/number-login/';
  static const numberLoginOtp = '/validate-number-login/';

  //Globle search
  static const globleSearch = '/search/';

  // Feed Home Url
  static const feedHomeGet = '/Post';
  static const feedReportGet = '/report/';

  static const feedCreatePost = '/Post/';
  static const feedFollowingPost = '/User/';
  static const devalayPeople = 'People';
  static const feedUser = '/User';
  static const feedUserDelete = '/user-delete/';

  static const notificationPost = '/Notification/';
    static const notificationSocket = '/notification/';
// Feed Comment Url
  static const feedCommentGet = '/Comment/?post_id=';
  static const feedCommentDetele = '/Comment/';

  static const feedCommentPost = '/Post/';
  static const feedCommentReplyPost = '/Comment-reply/';
//loaction |
  static const googleSerch = '/places/';

  // Services section
  static const pandits = '/Pandits';
  static const language = '/languages';
  static const service = '/Service-sections/';
   static const location = '/Devalay/?view=filter';
  static const order = '/Orders';

    static const adminOrder = '/admin-orders/';
     static const adminDetailOrder =  "/Orders/admin-orders/"; 
     static const adminConfirmOrder =  "/admin-confirm-order/"; 
  static const addOns = '/AddOns/';

  // Bank accounts
  static const bankAccounts = '/bank-accounts/';

  // Mentions section
  static const mentionPost = '/Post/mentions/';
}
