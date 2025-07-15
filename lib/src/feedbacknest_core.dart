import 'dart:math';
import 'dart:math' as Math;
import 'dart:ui';
import 'package:feedbacknest_core/src/models/device_info.dart';
import 'package:feedbacknest_core/src/utils.dart/api_client.dart';
import 'package:feedbacknest_core/src/utils.dart/device_info_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

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
  static String? _sessionId;
  static Map<String, dynamic> _screenData = {};
  static bool _isInitialized = false;
  static List<Map<String, dynamic>> _pendingScreenEvents = [];

  static DateTime? _appPausedTime;

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

    _lastSessionId = await _prefs?.getString('feedbacknest_session_id') ?? '';
    _sessionId = Uuid().v4();
    _prefs?.setString('feedbacknest_session_id', _sessionId!);

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

    Map<String, dynamic> data = {
      "id": _sessionId,
      "user_id": _userId,
      "user_identifier": _userIdentifier,
      "type": "start",
      "session_start_time": _sessionStartTime,
      "app_version": _appVersion,
      "platform": _deviceInfo?.deviceOS,
      "device_model": _deviceInfo?.deviceName,
      "device_os_version": _deviceInfo?.deviceOSVersion,
    };
    if (_lastSessionId.isNotEmpty && lastSessionDuration > 0) {
      data["last_session_id"] = _lastSessionId;
      data["last_session_duration"] = lastSessionDuration;
    }

    // Check for previous session screen data
    await _handlePreviousSessionScreenData();

    _apiClient?.post("/analytics/sessions/track", apiKey, data);

    // Mark as initialized and replay pending events
    _isInitialized = true;
    _replayPendingScreenEvents();
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
      _appPausedTime = DateTime.now().toUtc();

      // Initialize paused_duration for all active screens if not exists
      for (String screenName in _screenData.keys) {
        if (_screenData[screenName] != null) {
          _screenData[screenName]!["paused_duration"] =
              _screenData[screenName]!["paused_duration"] ?? 0;
        }
      }

      await _saveScreenDataToPrefs();

      _prefs?.setString(
          "feedbacnest_session_end_time", _inactiveTime.toIso8601String());
    } else if (state == AppLifecycleState.resumed) {
      if (_isPaused && _appPausedTime != null) {
        int gapDuration =
            DateTime.now().toUtc().difference(_appPausedTime!).inSeconds;

        // Add gap time to all screens that were active during pause
        for (String screenName in _screenData.keys) {
          if (_screenData[screenName] != null) {
            _screenData[screenName]!["paused_duration"] =
                (_screenData[screenName]!["paused_duration"] ?? 0) +
                    gapDuration;
          }
        }

        _sessionDurationGap += gapDuration;
      }
      print("session duration gap: $_sessionDurationGap seconds");
      _prefs?.setInt("feedbacknest_session_duration_gap", _sessionDurationGap);
      _isPaused = false;
      _appPausedTime = null;
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

  static void onScreenPushed(String screenName) {
    if (!_isInitialized) {
      // Queue the event for later processing
      _pendingScreenEvents.add({
        'type': 'push',
        'screenName': screenName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      return;
    }

    _screenData[screenName] = {
      "session_id": _sessionId!,
      "timestamp": DateTime.now().toUtc().toIso8601String(),
      "paused_duration": 0,
    };
  }

  static void onScreenPopped(String screenName) {
    if (!_isInitialized) {
      // Queue the event for later processing
      _pendingScreenEvents.add({
        'type': 'pop',
        'screenName': screenName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      return;
    }

    var duration = 0;
    if (_screenData.containsKey(screenName)) {
      var screenInfo = _screenData[screenName];
      if (screenInfo != null) {
        var timestamp = DateTime.parse(screenInfo["timestamp"]);
        var totalDuration =
            DateTime.now().toUtc().difference(timestamp).inSeconds;

        // Subtract the paused duration to get actual screen time
        int pausedDuration = screenInfo["paused_duration"] ?? 0;
        duration = totalDuration - pausedDuration;

        screenInfo["duration"] = duration;

        // Push screen data to API
        _pushScreenData(screenName, screenInfo);
      }

      _screenData.remove(screenName);
    }
  }

  static Future<void> _saveScreenDataToPrefs() async {
    String screenDataJson = jsonEncode(_screenData);
    await _prefs?.setString("feedbacknest_screen_data", screenDataJson);
  }

  static Future<void> _handlePreviousSessionScreenData() async {
    String? screenDataJson = _prefs?.getString("feedbacknest_screen_data");

    if (screenDataJson != null && screenDataJson.isNotEmpty) {
      try {
        Map<String, dynamic> previousScreenData = jsonDecode(screenDataJson);

        // Push all previous session screen data
        for (String screenName in previousScreenData.keys) {
          var screenInfo = previousScreenData[screenName];
          if (screenInfo != null) {
            var timestamp = DateTime.parse(screenInfo["timestamp"]);
            var pausedDuration = screenInfo["paused_duration"] ?? 0;

            // Calculate duration from when screen was pushed until app was paused
            String? lastEndTime =
                _prefs?.getString("feedbacnest_session_end_time");
            if (lastEndTime != null && lastEndTime.isNotEmpty) {
              DateTime endTime = DateTime.parse(lastEndTime);
              var totalDuration = endTime.difference(timestamp).inSeconds;
              var actualDuration = totalDuration - pausedDuration;

              screenInfo["duration"] = actualDuration;
              screenInfo["session_ended"] = true;

              _pushScreenData(screenName, screenInfo);
            }
          }
        }

        // Clear the saved screen data
        await _prefs?.remove("feedbacknest_screen_data");
      } catch (e) {
        print("Error handling previous session screen data: $e");
        await _prefs?.remove("feedbacknest_screen_data");
      }
    }
  }

  static Future<void> _pushScreenData(
      String screenName, Map<String, dynamic> screenInfo) async {
    if (_apiClient != null && _apiKey != null) {
      Map<String, dynamic> data = {
        "screen_name": screenName,
        "type": "end",
        "user_id": _userId,
        "user_identifier": _userIdentifier,
        "app_version": _appVersion,
        "platform": _deviceInfo?.deviceOS,
        "device_model": _deviceInfo?.deviceName,
        "device_os_version": _deviceInfo?.deviceOSVersion,
        ...screenInfo,
      };

      try {
        await _apiClient?.post("/analytics/screens/track", _apiKey!, data);
        print(
            "Screen data pushed for: $screenName, duration: ${screenInfo['duration']}s");
      } catch (e) {
        print("Error pushing screen data: $e");
      }
    }
  }

  static void _replayPendingScreenEvents() {
    for (var event in _pendingScreenEvents) {
      String eventType = event['type'];
      String screenName = event['screenName'];
      String timestamp = event['timestamp'];

      if (eventType == 'push') {
        _screenData[screenName] = {
          "session_id": _sessionId!,
          "timestamp": timestamp,
          "paused_duration": 0,
        };
      } else if (eventType == 'pop') {
        if (_screenData.containsKey(screenName)) {
          var screenInfo = _screenData[screenName];
          if (screenInfo != null) {
            var startTimestamp = DateTime.parse(screenInfo["timestamp"]);
            var endTimestamp = DateTime.parse(timestamp);
            var totalDuration =
                endTimestamp.difference(startTimestamp).inSeconds;

            // Subtract the paused duration to get actual screen time
            int pausedDuration = screenInfo["paused_duration"] ?? 0;
            var duration = totalDuration - pausedDuration;

            screenInfo["duration"] = duration;

            // Push screen data to API
            _pushScreenData(screenName, screenInfo);
          }

          _screenData.remove(screenName);
        }
      }
    }

    // Clear the pending events after replay
    _pendingScreenEvents.clear();
  }
}
