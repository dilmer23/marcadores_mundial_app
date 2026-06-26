import 'package:flutter/material.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';

class AppErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorDialog({
    super.key,
    required this.message,
    this.onRetry,
  });

  static void show(BuildContext context, String message, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AppErrorDialog(message: message, onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? AppColors.bgCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('Error', 'Error'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textMuted : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry?.call();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.tr('Retry', 'Reintentar')),
                ),
              ),
            if (onRetry != null) const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('Dismiss', 'Descartar')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
