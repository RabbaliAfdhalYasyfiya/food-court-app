import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class DeviceStatus {
  BluetoothDevice device;
  bool isConnected;

  DeviceStatus({
    required this.device,
    this.isConnected = false,
  });
}
