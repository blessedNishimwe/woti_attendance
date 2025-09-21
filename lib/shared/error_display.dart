import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String? error;
  final VoidCallback? onDismiss;

  const ErrorDisplay({
    Key? key,
    this.error,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error!,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: Colors.red[700], size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
