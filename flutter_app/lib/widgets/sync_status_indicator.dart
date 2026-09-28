import 'package:flutter/material.dart';

class SyncStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final int pendingCount;
  final VoidCallback onSyncTap;

  const SyncStatusIndicator({
    super.key,
    required this.isOnline,
    required this.pendingCount,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      color: isOnline ? Colors.amber.shade100 : Colors.blueGrey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.sync : Icons.cloud_off,
            size: 18,
            color: isOnline ? Colors.amber.shade900 : Colors.blueGrey.shade900,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !isOnline
                  ? 'Working Offline • Auto-saves to local device'
                  : '$pendingCount records queued for sync',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOnline ? Colors.amber.shade900 : Colors.blueGrey.shade900,
              ),
            ),
          ),
          if (isOnline && pendingCount > 0)
            GestureDetector(
              onTap: onSyncTap,
              child: const Text(
                'Sync',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
