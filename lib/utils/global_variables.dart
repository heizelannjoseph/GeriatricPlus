class GlobalVariables {
  static final GlobalVariables _instance = GlobalVariables._internal();

  factory GlobalVariables() {
    return _instance;
  }

  GlobalVariables._internal();

  // Define your global variables here
  bool showLogoScreen = false;
  bool isLoggedIn = false;
  bool isHomePageReady = false;
  bool isInitializationError = false;
  Map<String, dynamic> settings = {};
  Map<String, String> userData = {
    'name': "",
    'mobile': "",
    'email': "",
    'date_of_birth': "",
    'age': ""
  };
  int userId = 0;
}
