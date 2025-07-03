import 'dart:math';
import 'dart:math' as Math;
import 'dart:ui';
import 'package:feedbacknest_core/src/models/device_info.dart';
import 'package:feedbacknest_core/src/utils.dart/api_client.dart';
import 'package:feedbacknest_core/src/utils.dart/device_info_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FeedbackNestCore {
  static DeviceInfo? _deviceInfo;
  static String? _apiKey;
  static String? _userIdentifier;
  static SharedPreferences? _prefs;
  static ApiClient? _apiClient;
  static String _appVersion = "unknown";
  static String _userId = '';
  static late String _sessionStartTime;
  static late DateTime _inactiveTime;
  static late int _sessionDurationGap;
  static late String _lastSessionId;
  static late String _sessionId;

  static final List<String> _allowedTypes = [
    "feedback",
    "bug",
    "feature_request",
    "contact",
  ];

  static Future<void> init(String apiKey,
      {String userIdentifier = "", Map<String, dynamic>? props}) async {
    _sessionStartTime = DateTime.now().toUtc().toIso8601String();
    _sessionDurationGap = 0;
    _inactiveTime = DateTime.now().toUtc();
    _prefs = await SharedPreferences.getInstance();
    _deviceInfo = await DeviceInfoUtils.getDeviceInfo();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;

    _lastSessionId = _prefs?.getString('feedbacknest_session_id') ?? '';
    _sessionId = Uuid().v4();
    _prefs?.setString('feedbacknest_session_id', _sessionId);

    _userId = _prefs?.getString('feedbacknest_user_id') ?? '';
    if (_userId.isEmpty) {
      final random = Random();
      _userId = Uuid().v4();
      _prefs?.setString('feedbacknest_user_id', _userId);
    }
    _userIdentifier = userIdentifier;
    _apiClient = ApiClient();
    _apiKey = apiKey;

    int lastSessionDuration = calculateLastSessionDuration();
    print("last session duration: $lastSessionDuration seconds");

    _prefs?.setString("feedbacnest_session_start_time", _sessionStartTime);
    _prefs?.setInt("feedbacknest_session_duration_gap", 0);

    print("session start time : " + _sessionStartTime);

    _apiClient?.post("/analytics/sessions/track", apiKey, {
      "session_id": _sessionId,
      "user_id": _userId,
      "user_identifier": _userIdentifier,
      "type": "start",
      "app_version": _appVersion,
      "platform": _deviceInfo?.deviceOS,
      "device_model": _deviceInfo?.deviceName,
      "device_os_version": _deviceInfo?.deviceOSVersion,
      "last_session_id": _lastSessionId,
      "session_start_time": _sessionStartTime,
      "last_session_duration": lastSessionDuration,
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
    List<dynamic>? files,
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

    // Convert File list to CrossPlatformFile list
    List<CrossPlatformFile>? crossPlatformFiles;
    if (files != null && files.isNotEmpty) {
      crossPlatformFiles = <CrossPlatformFile>[];
      for (var file in files) {
        final crossPlatformFile = await CrossPlatformFile.fromFile(file);
        crossPlatformFiles.add(crossPlatformFile);
      }
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
      files: crossPlatformFiles,
    );
  }

  static bool _isPaused = false;

  static onLifeCycleEventChange(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      _isPaused = true;
      _inactiveTime = DateTime.now().toUtc();
      _prefs?.setString(
          "feedbacnest_session_end_time", _inactiveTime.toIso8601String());
    } else if (state == AppLifecycleState.resumed) {
      if (_isPaused) {
        _sessionDurationGap +=
            DateTime.now().toUtc().difference(_inactiveTime).inSeconds;
      }
      print("session duration gap: $_sessionDurationGap seconds");
      _prefs?.setInt("feedbacknest_session_duration_gap", _sessionDurationGap);
      _isPaused = false;
    }
  }

  static int calculateLastSessionDuration() {
    int lastSessionDurationGap =
        _prefs?.getInt("feedbacknest_session_duration_gap") ?? 0;
    String lastSessionStartTime =
        _prefs?.getString("feedbacnest_session_start_time") ?? '';
    String lastSessionEndTime =
        _prefs?.getString("feedbacnest_session_end_time") ?? '';
    int lastSessionDuration = 0;

    if (lastSessionStartTime.isNotEmpty && lastSessionEndTime.isNotEmpty) {
      DateTime lastStartTime = DateTime.parse(lastSessionStartTime).toUtc();
      DateTime lastEndTime = DateTime.parse(lastSessionEndTime).toUtc();
      lastSessionDuration = lastEndTime.difference(lastStartTime).inSeconds -
          lastSessionDurationGap;
    }

    return lastSessionDuration;
  }
}
