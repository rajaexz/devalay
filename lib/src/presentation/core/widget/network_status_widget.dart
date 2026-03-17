import 'package:flutter/material.dart';
import 'package:devalay_app/src/core/network/network_connectivity_service.dart';
import 'package:devalay_app/src/core/network/network_error_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NetworkStatusWidget extends StatefulWidget {
  const NetworkStatusWidget({super.key});

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  final NetworkConnectivityService _networkService = NetworkConnectivityService();
  bool _isConnected = true;
  String _connectionType = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initializeNetworkStatus();
  }

  void _initializeNetworkStatus() async {
    // Get initial status
    _isConnected = await _networkService.checkConnection();
    _connectionType = _networkService.getConnectionType();
    
    // Listen to connectivity changes
    _networkService.connectionStatus.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
        _connectionType = _networkService.getConnectionType();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      margin: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isConnected ? Icons.wifi : Icons.wifi_off,
                color: _isConnected ? Colors.green : Colors.red,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Network Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _isConnected ? 'Connected' : 'Disconnected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Connection Type: $_connectionType',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    NetworkErrorHandler.showNoInternetToast();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test No Internet Toast'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    NetworkErrorHandler.showConnectionRestoredToast();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Restored Toast'),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    NetworkErrorHandler.showWarningToast('This is a warning message');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Warning Toast'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    NetworkErrorHandler.showSuccessToast('Operation completed successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Success Toast'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 