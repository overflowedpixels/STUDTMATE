import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:study_mate/helpers/focusHelper.dart';
import 'package:flutter/services.dart';
import 'package:study_mate/utilities/color_theme.dart';

class FocusModePage extends StatefulWidget {
  final String fpath;
  const FocusModePage({super.key, required this.fpath});
  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool isFocusModeOn = false;
  bool _showToggleButton = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFE74C3C);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _hideToggleAfterDelay();
  }

  void _hideToggleAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showToggleButton = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if (isFocusModeOn) {
      FocusHelper.disableFocusMode();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      if (isFocusModeOn) {
        FocusHelper.disableFocusMode();
        setState(() {
          isFocusModeOn = false;
        });
      }
    }
  }

  Future<void> toggleFocusMode(bool enable) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  enable ? successColor : accentColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                enable ? 'Enabling Focus Mode...' : 'Disabling Focus Mode...',
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      if (enable) {
        await FocusHelper.enableFocusMode();
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        await FocusHelper.disableFocusMode();
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }

      setState(() {
        isFocusModeOn = enable;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${enable ? 'enable' : 'disable'} focus mode',
          ),
          backgroundColor: warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  Widget _buildFocusToggle() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showToggleButton ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !_showToggleButton,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isFocusModeOn
                ? successColor.withOpacity(0.1)
                : warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFocusModeOn ? successColor : warningColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFocusModeOn ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: isFocusModeOn ? successColor : warningColor,
              ),
              const SizedBox(width: 6),
              Text(
                isFocusModeOn ? "FOCUS ON" : "FOCUS OFF",
                style: TextStyle(
                  color: isFocusModeOn ? successColor : warningColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isFocusModeOn,
                  onChanged: (value) {
                    toggleFocusMode(value);
                    setState(() => _showToggleButton = true);
                    _hideToggleAfterDelay();
                  },
                  activeColor: successColor,
                  inactiveThumbColor: textSecondary,
                  inactiveTrackColor: textSecondary.withOpacity(0.3),
                  activeTrackColor: successColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          surface: surfaceColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!_showToggleButton) {
            setState(() => _showToggleButton = true);
            _hideToggleAfterDelay();
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.background,
          appBar: !isFocusModeOn
              ? AppBar(
                  elevation: 0,
                  backgroundColor: AppTheme.background,
                  foregroundColor: AppTheme.accentYellow,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: AppTheme.accentYellow,
                      ),
                      tooltip: 'About Focus Mode',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: const Text(
                              'Focus Mode Reader',
                              style: TextStyle(
                                color: AppTheme.accentYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: const Text(
                              'Focus Mode removes all UI distractions and prevents your phone from sleeping, creating an ideal environment for deep reading or writing.\n\n⚠️ Caution: Focus Mode keeps your screen awake. If you forget to disable it, your battery may drain quickly. Try your best to stay alert and avoid sleeping while using it.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Got it',
                                  style: TextStyle(color: AppTheme.accentYellow),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  title: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Focus Mode Reader",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppTheme.accentYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                  ),
                )
              : null,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PdfViewer.file(widget.fpath),
              ),
            ),
          ),
          floatingActionButton: _buildFocusToggle(),
        ),
      ),
    );
  }
}
