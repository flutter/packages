import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// iOS 26 lock screen keypad demo.
///
/// Demonstrates `GlassButton` with `persistPressOnDrag: false` — the same
/// behaviour as the camera/torch buttons on the iOS lock screen where the
/// pressed state cancels if you drag away.
///
/// Run standalone:
/// ```
/// flutter run -t lib/demos/keypad_lock_screen_demo.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    child: CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: const KeypadLockScreenDemo(),
    ),
  ));
}

/// iOS 26 lock screen keypad — uses [GlassButton] with
/// `persistPressOnDrag: false` so the pressed state cancels on drag-away.
class KeypadLockScreenDemo extends StatefulWidget {
  const KeypadLockScreenDemo({super.key});

  @override
  State<KeypadLockScreenDemo> createState() => _KeypadLockScreenDemoState();
}

class _KeypadLockScreenDemoState extends State<KeypadLockScreenDemo>
    with TickerProviderStateMixin {
  static const int _passcodeLength = 6;
  final List<int> _enteredDigits = [];
  bool _isError = false;

  // Shake animation for error feedback
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  // Fade animation for success
  late final AnimationController _successController;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onDigitTap(int digit) {
    if (_enteredDigits.length >= _passcodeLength || _isError) return;

    unawaited(HapticFeedback.lightImpact());

    setState(() {
      _enteredDigits.add(digit);
    });

    if (_enteredDigits.length == _passcodeLength) {
      // Simulate passcode check after a short delay
      Future.delayed(const Duration(milliseconds: 200), () {
        _onPasscodeComplete();
      });
    }
  }

  void _onDeleteTap() {
    if (_enteredDigits.isEmpty || _isError) return;

    unawaited(HapticFeedback.lightImpact());

    setState(() {
      _enteredDigits.removeLast();
    });
  }

  void _onPasscodeComplete() {
    // Demo: always "fail" to show the shake animation, then clear
    setState(() => _isError = true);
    unawaited(HapticFeedback.heavyImpact());
    _shakeController.forward(from: 0).then((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() {
          _enteredDigits.clear();
          _isError = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return GlassPage(
      background: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bulldog.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              CupertinoColors.black
                  .withValues(alpha: 0.3), // Adjust opacity for darkness
              BlendMode.darken, // Or BlendMode.srcOver for a solid overlay
            ),
            alignment: Alignment(0, 0),
          ),
        ),
      ),
      child: GlassScaffold(
        backgroundColor: const Color(0x00000000),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Lock icon + Face ID bar
              _buildStatusBar(),

              SizedBox(height: screenHeight * 0.03),

              // "Swipe up for Face ID or Enter Passcode"
              _buildPromptText(),

              SizedBox(height: screenHeight * 0.02),

              // Passcode dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                ),
                child: _buildPasscodeDots(),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Number pad
              Expanded(
                child: AdaptiveLiquidGlassLayer(
                  settings: const LiquidGlassSettings(
                    glassColor:
                        Color.from(alpha: 0.08, red: 1, green: 1, blue: 1),
                    blur: 3,
                    thickness: 30,
                    lightIntensity: 1.2,
                    saturation: 1.2,
                  ),
                  quality: GlassQuality.premium,
                  child: _buildNumberPad(),
                ),
              ),

              // Emergency / Cancel row
              _buildBottomActions(),

              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.lock,
            color: CupertinoColors.white.withValues(alpha: 0.9),
            size: 16,
          ),
          SizedBox(width: 24),
          Icon(
            CupertinoIcons.smiley,
            color: CupertinoColors.activeGreen.withValues(alpha: 0.9),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildPromptText() {
    return Column(
      children: [
        Text(
          'Swipe up for Face ID or',
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          'Enter Passcode',
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPasscodeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_passcodeLength, (index) {
        final isFilled = index < _enteredDigits.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 14 : 13,
          height: isFilled ? 14 : 13,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? (_isError ? CupertinoColors.systemRed : CupertinoColors.white)
                : const Color(0x00000000),
            border: Border.all(
              color: _isError
                  ? CupertinoColors.systemRed
                  : CupertinoColors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad() {
    const subtitles = {
      2: 'ABC',
      3: 'DEF',
      4: 'GHI',
      5: 'JKL',
      6: 'MNO',
      7: 'PQRS',
      8: 'TUV',
      9: 'WXYZ',
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row 1: 1, 2, 3
          _buildKeyRow([1, 2, 3], subtitles),
          SizedBox(height: 14),
          // Row 2: 4, 5, 6
          _buildKeyRow([4, 5, 6], subtitles),
          SizedBox(height: 14),
          // Row 3: 7, 8, 9
          _buildKeyRow([7, 8, 9], subtitles),
          SizedBox(height: 14),
          // Row 4: _, 0, delete
          _buildBottomKeyRow(),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<int> digits, Map<int, String> subtitles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return _KeypadButton(
          digit: digit,
          subtitle: subtitles[digit],
          onTap: () => _onDigitTap(digit),
        );
      }).toList(),
    );
  }

  Widget _buildBottomKeyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Empty space where a button would be
        SizedBox(width: 80, height: 80),

        // 0 button
        _KeypadButton(
          digit: 0,
          onTap: () => _onDigitTap(0),
        ),

        // Delete button
        SizedBox(
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: _onDeleteTap,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Icon(
                CupertinoIcons.trash,
                color: CupertinoColors.white.withValues(alpha: 0.9),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Text(
              'Emergency',
              style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.85),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.85),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual keypad button using GlassButton with persistPressOnDrag: false
/// to match the iOS lock screen behavior (press cancels on drag-away).
class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.digit,
    required this.onTap,
    this.subtitle,
  });

  final int digit;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap,
      width: 80,
      height: 80,
      shape: const LiquidOval(),
      // Pressed state persists while dragging
      persistPressOnDrag: true,
      interactionScale: 1.05,
      // Overall stretch multiplier on drag offset (higher = more stretch)
      stretch: 1.0,
      // Drag resistance (higher = more sticky, slower build-up)
      resistance: 0.04,
      // Anchor mode — button stays in place, shape elongates (default)
      // anchorStretch: true, // ← already the default!
      // ── Tune these to taste ──────────────────────────────────
      anchorStretchSettings: const AnchorStretchSettings(
        intensity: 0.6, // elongation amount (0 = none, 1 = max)
        squashFactor: 0.15, // perpendicular squash (0 = none, 1 = full)
        translationDamping: 0.12, // center shift for bounce (0 = fixed)
        bounciness: 0.15, // elastic overshoot on release (0 = standard)
      ),
      glowRadius: 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$digit',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 34,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 1),
            Text(
              subtitle!,
              style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
