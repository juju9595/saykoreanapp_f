import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final Widget child;
  final double height;
  const AppFooter({super.key, required this.child, this.height = 56});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // 🔥 라이트/다크에 따라 배경/테두리 색 분리
    final Color bgColor =
        theme.bottomNavigationBarTheme.backgroundColor ??
            (isDark ? scheme.surface : Colors.white);
    final Color borderColor = isDark
        ? scheme.outline.withOpacity(0.4)
        : const Color(0xFFE5E7EB);

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor)),
          color: bgColor,
        ),
        child: child,
      ),
    );
  }
}

// 사용 그대로
// bottomNavigationBar: const AppFooter(child: Text('© 2025 SayKorean')),
