class GlobalVariables {
  static final GlobalVariables _instance = GlobalVariables._internal();

  factory GlobalVariables() {
    return _instance;
  }

  GlobalVariables._internal();

  // Define your global variables here
  bool showLogoScreen = false;
  bool isHomePageReady = false;
  bool isInitializationError = false;
  Map<String, dynamic> settings = {};
  int userId = 0;
}
