import 'package:flutter/material.dart';
class NoMediaView extends StatelessWidget {
  final VoidCallback onRefresh;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOnRefresh;

  const NoMediaView({
    super.key,
    required this.onRefresh,
    this.title = "No Media Available",
    this.subtitle =
        "You haven’t shared anything yet.\nTap the button below to refresh.",
    this.icon = Icons.feed_outlined,
    this.isOnRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Center(
        child:       Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center, 
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                   
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center, 
                  style: const TextStyle(
                    fontSize: 15,
                  
                  ),
                ),
                const SizedBox(height: 25),
                if (isOnRefresh)
                  ElevatedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
    
      ),
    );
  }
}
