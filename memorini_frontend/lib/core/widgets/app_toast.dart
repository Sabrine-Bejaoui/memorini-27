import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/colors.dart';

enum AppToastType { success, error, warning, info }

class AppToast {
  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);

    _activeEntry?.remove();
    _activeEntry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
          entry.remove();
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _autoDismissTimer;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _autoDismissTimer = Timer(widget.duration, close);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> close() async {
    if (_isClosing) return;
    _isClosing = true;
    _autoDismissTimer?.cancel();
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _ToastPalette.fromType(widget.type);
    final width = MediaQuery.of(context).size.width;
    final alignRight = width > 780;

    return SafeArea(
      child: IgnorePointer(
        ignoring: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: alignRight ? Alignment.topRight : Alignment.topCenter,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: palette.softColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            palette.icon,
                            size: 18,
                            color: palette.mainColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: close,
                          tooltip: 'Fermer',
                          icon: const Icon(Icons.close, size: 18),
                          color: AppColors.textMuted,
                          splashRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastPalette {
  final Color mainColor;
  final Color softColor;
  final Color borderColor;
  final IconData icon;

  const _ToastPalette({
    required this.mainColor,
    required this.softColor,
    required this.borderColor,
    required this.icon,
  });

  factory _ToastPalette.fromType(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const _ToastPalette(
          mainColor: Colors.green,
          softColor: Color(0xFFE7F7ED),
          borderColor: Color(0xFFBEE8CC),
          icon: Icons.check_circle_outline,
        );
      case AppToastType.error:
        return const _ToastPalette(
          mainColor: Colors.red,
          softColor: Color(0xFFFDECEC),
          borderColor: Color(0xFFF7C7C7),
          icon: Icons.error_outline,
        );
      case AppToastType.warning:
        return const _ToastPalette(
          mainColor: Colors.orange,
          softColor: Color(0xFFFFF3E3),
          borderColor: Color(0xFFF8D8AB),
          icon: Icons.warning_amber_outlined,
        );
      case AppToastType.info:
        return const _ToastPalette(
          mainColor: AppColors.burgundy,
          softColor: Color(0xFFF5EFF2),
          borderColor: Color(0xFFE6D9E0),
          icon: Icons.info_outline,
        );
    }
  }
}
