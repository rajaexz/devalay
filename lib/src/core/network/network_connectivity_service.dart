import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:devalay_app/src/core/utils/logger.dart';

class NetworkConnectivityService {
  static final NetworkConnectivityService _instance = NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isConnected = true;
  List<ConnectivityResult> _currentConnectivityResults = [];

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool get isConnected => _isConnected;
  List<ConnectivityResult> get currentConnectivityResults => _currentConnectivityResults;


  Future<void> initialize() async {
    try {
    
      _currentConnectivityResults = await _connectivity.checkConnectivity();
      _isConnected = _currentConnectivityResults.any(
        (result) => result != ConnectivityResult.none
      );
      
     
      _connectionStatusController.add(_isConnected);
      
    
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
      
      Logger.log('Network Connectivity Service initialized. Connected: $_isConnected');
    } catch (e) {
      Logger.logError('Error initializing Network Connectivity Service: $e');
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _currentConnectivityResults = results;
    bool wasConnected = _isConnected;
    _isConnected = results.any((result) => result != ConnectivityResult.none);
    
   
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
      
      if (_isConnected) {
        Logger.log('Network connection restored');
      } else {
        Logger.log('Network connection lost');
      }
    }
  }

  // Check if currently connected
  Future<bool> checkConnection() async {
    try {
      _currentConnectivityResults = await _connectivity.checkConnectivity();
      _isConnected = _currentConnectivityResults.any(
        (result) => result != ConnectivityResult.none
      );
      return _isConnected;
    } catch (e) {
      Logger.logError('Error checking connection: $e');
      return false;
    }
  }

  // Get connection type
  String getConnectionType() {
    if (_currentConnectivityResults.isEmpty) return 'Unknown';
    
    if (_currentConnectivityResults.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (_currentConnectivityResults.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (_currentConnectivityResults.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (_currentConnectivityResults.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (_currentConnectivityResults.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else {
      return 'None';
    }
  }

  
  bool get isConnectionStable {
    return _isConnected && _currentConnectivityResults.isNotEmpty;
  }

 
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'connectionType': getConnectionType(),
      'connectivityResults': _currentConnectivityResults.map((e) => e.name).toList(),
      'isStable': isConnectionStable,
    };
  }

 
  void dispose() {
    _connectionStatusController.close();
  }
} 