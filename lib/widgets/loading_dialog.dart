// lib/widgets/loading_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// A beautiful loading dialog with progress indicator
class LoadingDialog extends StatelessWidget {
  final String title;
  final String message;
  final double? progress;
  final bool showProgress;

  const LoadingDialog({
    super.key,
    this.title = 'Loading',
    this.message = 'Please wait...',
    this.progress,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.warmPaper,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spinner or progress
            if (showProgress && progress != null) ...[
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: AppTheme.softCream,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.caramel),
                      ),
                    ),
                    Text(
                      '${(progress! * 100).toInt()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.caramel),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoal,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.charcoal.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show the loading dialog and return a controller to update it
  static LoadingDialogController show(
    BuildContext context, {
    String title = 'Loading',
    String message = 'Please wait...',
  }) {
    final controller = LoadingDialogController();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => LoadingDialog(
          title: controller.title,
          message: controller.message,
          progress: controller.progress,
          showProgress: controller.showProgress,
        ),
      ),
    );

    return controller;
  }
}

/// Controller for updating the loading dialog
class LoadingDialogController extends ChangeNotifier {
  String _title = 'Loading';
  String _message = 'Please wait...';
  double? _progress;
  bool _showProgress = true;

  String get title => _title;
  String get message => _message;
  double? get progress => _progress;
  bool get showProgress => _showProgress;

  void update({
    String? title,
    String? message,
    double? progress,
    bool? showProgress,
  }) {
    if (title != null) _title = title;
    if (message != null) _message = message;
    _progress = progress;
    if (showProgress != null) _showProgress = showProgress;
    notifyListeners();
  }

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}
