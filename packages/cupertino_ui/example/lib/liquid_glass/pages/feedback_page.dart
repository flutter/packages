import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _circularProgress = 0.5;
  double _linearProgress = 0.5;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  Timer? _uploadTimer;

  @override
  void dispose() {
    _uploadTimer?.cancel();
    super.dispose();
  }

  void _startSimulatedUpload() {
    setState(() {
      _uploadProgress = 0.0;
      _isUploading = true;
    });
    _uploadTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _uploadProgress += 0.01;
        if (_uploadProgress >= 1.0) {
          _uploadProgress = 1.0;
          _isUploading = false;
          timer.cancel();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _uploadProgress = 0.0);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      child: GlassScaffold(
        appBar: const GlassAppBar.pinned(),
        body: GlassScrollEdgeEffect(
          topFadeHeight: MediaQuery.paddingOf(context).top + 44 + 40,
          fadeBottom: false,
          child: CustomScrollView(
            slivers: [
              // Space for the app bar + safe area
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).top + 44,
                ),
              ),
              // ── Large page title (iOS 26 inline style) ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Feedback',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Circular Spinner ──────────────────────────────────
                      const _SectionTitle(title: 'Circular Spinner'),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _LabeledWidget(
                            label: 'Small',
                            child: GlassProgressIndicator.circular(
                              size: 14.0,
                              strokeWidth: 2.0,
                            ),
                          ),
                          _LabeledWidget(
                            label: 'Medium',
                            child: GlassProgressIndicator.circular(),
                          ),
                          _LabeledWidget(
                            label: 'Large',
                            child: GlassProgressIndicator.circular(
                              size: 28.0,
                              strokeWidth: 3.0,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── Circular Progress ────────────────────────────────
                      const _SectionTitle(title: 'Circular Progress'),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassProgressIndicator.circular(
                            value: _circularProgress,
                          ),
                          GlassProgressIndicator.circular(
                            value: _circularProgress,
                            size: 40.0,
                            strokeWidth: 4.0,
                            color: CupertinoColors.activeGreen,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      CupertinoSlider(
                        value: _circularProgress,
                        onChanged: (v) => setState(() => _circularProgress = v),
                        activeColor: const Color(0xFF007AFF),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProgressStage(value: 0.0, label: '0%'),
                          _ProgressStage(value: 0.25, label: '25%'),
                          _ProgressStage(value: 0.5, label: '50%'),
                          _ProgressStage(value: 0.75, label: '75%'),
                          _ProgressStage(value: 1.0, label: '100%'),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── Color Variants ────────────────────────────────────
                      const _SectionTitle(title: 'Color Variants'),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _LabeledWidget(
                            label: 'Info',
                            child: GlassProgressIndicator.circular(
                              value: 0.7,
                              color: Color(0xFF007AFF),
                              size: 32.0,
                              strokeWidth: 3.0,
                            ),
                          ),
                          _LabeledWidget(
                            label: 'Success',
                            child: GlassProgressIndicator.circular(
                              value: 0.7,
                              color: CupertinoColors.activeGreen,
                              size: 32.0,
                              strokeWidth: 3.0,
                            ),
                          ),
                          _LabeledWidget(
                            label: 'Warning',
                            child: GlassProgressIndicator.circular(
                              value: 0.7,
                              color: CupertinoColors.activeOrange,
                              size: 32.0,
                              strokeWidth: 3.0,
                            ),
                          ),
                          _LabeledWidget(
                            label: 'Error',
                            child: GlassProgressIndicator.circular(
                              value: 0.7,
                              color: CupertinoColors.systemRed,
                              size: 32.0,
                              strokeWidth: 3.0,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── Linear Progress ──────────────────────────────────
                      const _SectionTitle(title: 'Linear Progress'),
                      SizedBox(height: 16),
                      const GlassProgressIndicator.linear(),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GlassProgressIndicator.linear(
                              value: _linearProgress,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            '${(_linearProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      CupertinoSlider(
                        value: _linearProgress,
                        onChanged: (v) => setState(() => _linearProgress = v),
                        activeColor: const Color(0xFF007AFF),
                      ),

                      SizedBox(height: 40),

                      // ── Toast Notifications ──────────────────────────────
                      const _SectionTitle(title: 'Toast Notifications'),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _ToastButton(
                            label: 'Success',
                            icon: CupertinoIcons.check_mark_circled,
                            onTap: () => GlassToast.show(
                              context,
                              message: 'Settings saved successfully!',
                              type: GlassToastType.success,
                              icon: Icon(CupertinoIcons.check_mark_circled),
                              position: GlassToastPosition.top,
                            ),
                          ),
                          _ToastButton(
                            label: 'Error',
                            icon: CupertinoIcons.xmark_circle_fill,
                            onTap: () => GlassToast.show(
                              context,
                              message: 'Failed to connect to server',
                              type: GlassToastType.error,
                              position: GlassToastPosition.top,
                            ),
                          ),
                          _ToastButton(
                            label: 'Info',
                            icon: CupertinoIcons.info_circle_fill,
                            onTap: () => GlassToast.show(
                              context,
                              message: 'New message received from Alice',
                              type: GlassToastType.info,
                              position: GlassToastPosition.top,
                            ),
                          ),
                          _ToastButton(
                            label: 'Warning',
                            icon: CupertinoIcons.exclamationmark_triangle_fill,
                            onTap: () => GlassToast.show(
                              context,
                              message: 'Storage space running low',
                              type: GlassToastType.warning,
                              position: GlassToastPosition.top,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // ── File Upload Example ──────────────────────────────
                      const _SectionTitle(title: 'File Upload'),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(CupertinoIcons.doc,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                              size: 32),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'document.pdf',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.label
                                        .resolveFrom(context),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _isUploading
                                      ? 'Uploading... ${(_uploadProgress * 100).toInt()}%'
                                      : _uploadProgress == 1.0
                                          ? 'Upload complete!'
                                          : '2.4 MB',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _uploadProgress == 1.0
                                        ? CupertinoColors.activeGreen
                                        : CupertinoColors.tertiaryLabel
                                            .resolveFrom(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_uploadProgress == 1.0)
                            Icon(CupertinoIcons.checkmark_circle_fill,
                                color: CupertinoColors.activeGreen, size: 24),
                        ],
                      ),
                      SizedBox(height: 16),
                      GlassProgressIndicator.linear(
                        value: _uploadProgress,
                        color: _uploadProgress == 1.0
                            ? CupertinoColors.activeGreen
                            : const Color(0xFF007AFF),
                      ),
                      SizedBox(height: 16),
                      GlassButton.custom(
                        onTap: _isUploading ? () {} : _startSimulatedUpload,
                        enabled: !_isUploading,
                        width: double.infinity,
                        height: 44,
                        shape: const LiquidRoundedRectangle(borderRadius: 12),
                        child: Text(
                          _isUploading
                              ? 'Uploading...'
                              : _uploadProgress == 1.0
                                  ? 'Upload Again'
                                  : 'Start Upload',
                        ),
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label.resolveFrom(context),
      ),
    );
  }
}

class _LabeledWidget extends StatelessWidget {
  const _LabeledWidget({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        child,
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context)),
        ),
      ],
    );
  }
}

class _ProgressStage extends StatelessWidget {
  const _ProgressStage({required this.value, required this.label});
  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassProgressIndicator.circular(
          value: value,
          size: 24.0,
          strokeWidth: 3.0,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context)),
        ),
      ],
    );
  }
}

class _ToastButton extends StatelessWidget {
  const _ToastButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap,
      width: 160,
      height: 44,
      shape: const LiquidRoundedRectangle(borderRadius: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 16, color: CupertinoColors.label.resolveFrom(context)),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
