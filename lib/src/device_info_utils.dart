import 'package:device_info_plus/device_info_plus.dart';
import 'package:feedbacknest_core/src/device_info.dart';

class DeviceInfoUtils {
  static Future<DeviceInfo> getDeviceInfo() async {
    String deviceName;
    String deviceOS;
    String deviceOSVersion;
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    BaseDeviceInfo device = await deviceInfoPlugin.deviceInfo;
    if (device is AndroidDeviceInfo) {
      deviceName = device.model;
      deviceOS = 'Android';
      deviceOSVersion = device.version.release;
    } else if (device is IosDeviceInfo) {
      deviceName = device.name;
      deviceOS = 'iOS';
      deviceOSVersion = device.systemVersion;
    } else if (device is WebBrowserInfo) {
      deviceName = 'Web Browser';
      deviceOS = 'Web';
      deviceOSVersion = 'N/A';
    } else if (device is MacOsDeviceInfo) {
      deviceName = device.computerName;
      deviceOS = 'macOS';
      deviceOSVersion = device.osRelease;
    } else if (device is WindowsDeviceInfo) {
      deviceName = device.computerName;
      deviceOS = 'Windows';
      deviceOSVersion = device.majorVersion.toString();
    } else if (device is LinuxDeviceInfo) {
      deviceName = 'Linux Device';
      deviceOS = 'Linux';
      deviceOSVersion = device.version.toString();
    } else {
      deviceName = 'Unknown Device';
      deviceOS = 'Unknown OS';
      deviceOSVersion = 'Unknown Version';
    }

    return DeviceInfo(
      deviceName: deviceName,
      deviceOS: deviceOS,
      deviceOSVersion: deviceOSVersion,
    );
  }
}
