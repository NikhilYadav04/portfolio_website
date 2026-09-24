import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';

class DeviceModel {
  DeviceInfo device;
  IconData icon;

  /// Name shown in the device switch under the phone.
  String label;

  DeviceModel({required this.device, required this.icon, required this.label});
}
