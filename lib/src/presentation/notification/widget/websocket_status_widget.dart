import 'package:flutter/material.dart';
import 'package:devalay_app/src/presentation/notification/web_socket/web_socket.dart';

class WebSocketStatusWidget extends StatelessWidget {
  const WebSocketStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = NotificationSocketService();
    
    return ValueListenableBuilder<bool>(
      valueListenable: socketService.isConnected,
      builder: (context, isConnected, child) {
        return ValueListenableBuilder<String>(
          valueListenable: socketService.connectionStatus,
          builder: (context, status, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isConnected ? 'Connected' : status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class WebSocketDebugWidget extends StatelessWidget {
  const WebSocketDebugWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = NotificationSocketService();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WebSocket Debug Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: socketService.isConnected,
              builder: (context, isConnected, child) {
                return Row(
                  children: [
                    const Text('Status: '),
                    Icon(
                      isConnected ? Icons.check_circle : Icons.error,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(isConnected ? 'Connected' : 'Disconnected'),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: socketService.connectionStatus,
              builder: (context, status, child) {
                return Text('Details: $status');
              },
            ),
            const SizedBox(height: 8),
            Text('Reconnect Attempts: ${socketService.reconnectAttempts}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => socketService.connectWithCookie(),
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => socketService.disconnect(),
                  child: const Text('Disconnect'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => socketService.forceReconnect(),
                  child: const Text('Force Reconnect'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => socketService.ping(),
              child: const Text('Ping'),
            ),
          ],
        ),
      ),
    );
  }
}
