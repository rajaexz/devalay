import 'package:flutter/material.dart';
import 'package:devalay_app/src/core/network/network_connectivity_service.dart';
import 'package:devalay_app/src/core/network/network_error_handler.dart';

class NetworkConnectivityWrapper extends StatefulWidget {
  final Widget child;
  
  const NetworkConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  State<NetworkConnectivityWrapper> createState() => _NetworkConnectivityWrapperState();
}

class _NetworkConnectivityWrapperState extends State<NetworkConnectivityWrapper> {
  final NetworkConnectivityService _networkService = NetworkConnectivityService();
  bool _isConnected = true;
  bool _hasShownNoInternetToast = false;
  bool _hasShownRestoredToast = false;

  @override
  void initState() {
    super.initState();
    _initializeNetworkListener();
  }

  void _initializeNetworkListener() async {
    // Get initial connection status
    _isConnected = await _networkService.checkConnection();
    
    // Listen to network connectivity changes
    _networkService.connectionStatus.listen((isConnected) {
      _handleNetworkChange(isConnected);
    });
  }

  void _handleNetworkChange(bool isConnected) {
    if (!mounted) return;

    setState(() {
      _isConnected = isConnected;
    });

    if (!isConnected) {
      // Show no internet toast when connection is lost
      if (!_hasShownNoInternetToast) {
        NetworkErrorHandler.showNoInternetToast();
        _hasShownNoInternetToast = true;
        _hasShownRestoredToast = false;
      }
    } else {
      // Show connection restored toast when connection is restored
      if (!_hasShownRestoredToast && _hasShownNoInternetToast) {
        NetworkErrorHandler.showConnectionRestoredToast();
        _hasShownRestoredToast = true;
        _hasShownNoInternetToast = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 