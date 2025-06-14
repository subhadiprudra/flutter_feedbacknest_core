import 'dart:io';
import 'dart:math';
import 'package:feedbacknest_core/src/api_client.dart';
import 'package:feedbacknest_core/src/device_info.dart';
import 'package:feedbacknest_core/src/device_info_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Feedbacknest {
  static DeviceInfo? _deviceInfo;
  static String? _apiKey;
  static String? _userIdentifier;
  static SharedPreferences? _prefs;
  static ApiClient? _apiClient;
  static String _appVersion = "unknown";

  static final List<String> _allowedTypes = [
    "feedback",
    "bug",
    "feature_request",
    "contact",
  ];

  static Future<void> init(String apiKey, {String userIdentifier = ""}) async {
    _prefs = await SharedPreferences.getInstance();
    _deviceInfo = await DeviceInfoUtils.getDeviceInfo();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _apiClient = ApiClient();
    Feedbacknest._apiKey = apiKey;
    if (userIdentifier.isEmpty) {
      String userId = _prefs?.getString('userIdentifier') ?? '';
      if (userId.isNotEmpty) {
        Feedbacknest._userIdentifier = userId;
      } else {
        final random = Random();
        int num = 100000 + random.nextInt(900000);
        Feedbacknest._userIdentifier = "user_$num";
        _prefs?.setString('userIdentifier', Feedbacknest._userIdentifier!);
      }
    } else {
      Feedbacknest._userIdentifier = userIdentifier;
    }
    _apiClient?.post("/user/submit/log", apiKey, {
      "user_id": Feedbacknest._userIdentifier,
      "app_version": _appVersion,
      "platform": _deviceInfo?.deviceOS,
      "device_model": _deviceInfo?.deviceName,
      "device_os_version": _deviceInfo?.deviceOSVersion,
    });
  }

  static Future<void> submitRatingAndReview({
    required int rating,
    String? review,
  }) async {
    if (_apiKey == null) {
      throw Exception("Feedbacknest is not initialized. Call init() first.");
    }

    await _apiClient?.post("/user/submit/review", _apiKey!, {
      "user_id": _userIdentifier,
      "app_version": _appVersion,
      "platform": _deviceInfo?.deviceOS ?? "Unknown",
      "device_model": _deviceInfo?.deviceName ?? "Unknown",
      "device_os_version": _deviceInfo?.deviceOSVersion ?? "Unknown",
      "rating": rating,
      "review": review ?? "",
    });
  }

  static Future<void> submitCommunication({
    required String message,
    required String type,
    String? email,
    List<File>? files,
  }) async {
    type = type.toLowerCase();
    if (!_allowedTypes.contains(type)) {
      throw Exception(
        "Invalid communication type: $type. Allowed types are: ${_allowedTypes.join(', ')}",
      );
    }

    if (_apiKey == null) {
      throw Exception("Feedbacknest is not initialized. Call init() first.");
    }

    await _apiClient?.postWithMultipart(
      endpoint: "/user/submit/communication",
      apiKey: _apiKey!,
      fields: {
        "user_id": _userIdentifier ?? "Unknown",
        "app_version": _appVersion,
        "platform": _deviceInfo?.deviceOS ?? "Unknown",
        "device_model": _deviceInfo?.deviceName ?? "Unknown",
        "device_os_version": _deviceInfo?.deviceOSVersion ?? "Unknown",
        "message": message,
        "contact_email": email ?? "",
        "type": type,
      },
      files: files,
    );
  }
}
