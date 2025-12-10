import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class VpnProvider with ChangeNotifier {
  bool _isConnected = false;
  String _statusText = "Disconnected";
  String _currentServer = "WhatsApp Optimized Server 1";
  Duration _connectionDuration = Duration.zero;
  Timer? _timer;

  bool get isConnected => _isConnected;
  String get statusText => _statusText;
  String get currentServer => _currentServer;
  String get durationString {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(_connectionDuration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(_connectionDuration.inSeconds.remainder(60));
    return "${twoDigits(_connectionDuration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  VpnProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _isConnected = prefs.getBool('isConnected') ?? false;
    if (_isConnected) {
      _statusText = "Connected";
      _startTimer();
    }
    notifyListeners();
  }

  Future<void> connect() async {
    _statusText = "Connecting...";
    notifyListeners();

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));

    _isConnected = true;
    _statusText = "Connected";
    _startTimer();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConnected', true);
    
    notifyListeners();
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _statusText = "Disconnected";
    _stopTimer();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConnected', false);
    
    notifyListeners();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _connectionDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _connectionDuration = Duration.zero;
  }
}
