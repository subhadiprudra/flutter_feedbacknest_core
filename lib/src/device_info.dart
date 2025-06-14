class DeviceInfo {
  String? deviceName;
  String? deviceOS;
  String? deviceOSVersion;

  DeviceInfo({this.deviceName, this.deviceOS, this.deviceOSVersion});

  @override
  String toString() {
    return 'DeviceInfo(deviceName: $deviceName, deviceModel: deviceOS: $deviceOS, deviceOSVersion: $deviceOSVersion)';
  }
}
