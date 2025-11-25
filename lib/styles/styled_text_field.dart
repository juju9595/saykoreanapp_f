import 'package:flutter/material.dart';
import 'package:saykoreanapp_f/main.dart'; // themeColorNotifier 접근용

/// 커스텀 스타일 TextField 위젯 (main.dart 테마 정확히 적용)
class StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final int? maxLines;

  const StyledTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixWidget,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';

    // 테마별 색상 설정 (main.dart와 동일)
    late final Color cardBg;
    late final Color labelColor;
    late final Color textColor;
    late final Color hintColor;
    late final Color iconColor;

    if (isDark) {
      // 다크 모드
      cardBg = theme.colorScheme.surfaceContainerHigh; // #29201D
      labelColor = const Color(0xFFB0A3A0);
      textColor = const Color(0xFFF7E0B4);
      hintColor = const Color(0x66F7E0B4);
      iconColor = theme.colorScheme.primary;
    } else if (isMint) {
      // 민트 테마
      cardBg = Colors.white;
      labelColor = const Color(0xFF2F7A69);
      textColor = const Color(0xFF2F7A69);
      hintColor = const Color(0x662F7A69);
      iconColor = const Color(0xFF2F7A69);
    } else {
      // 라이트 모드 (기본)
      cardBg = Colors.white;
      labelColor = const Color(0xFF9C7C68);
      textColor = const Color(0xFF6B4E42);
      hintColor = const Color(0x669C7C68);
      iconColor = const Color(0xFF6B4E42);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.brown.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, color: iconColor, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 13,
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 입력 필드
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: hintColor,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                suffixIcon: suffixWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// IntlPhoneField용 스타일 컨테이너 (main.dart 테마 적용)
class StyledPhoneFieldContainer extends StatelessWidget {
  final Widget child;
  final String labelText;
  final IconData? prefixIcon;

  const StyledPhoneFieldContainer({
    super.key,
    required this.child,
    required this.labelText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';

    late final Color cardBg;
    late final Color labelColor;
    late final Color iconColor;

    if (isDark) {
      cardBg = theme.colorScheme.surfaceContainerHigh;
      labelColor = const Color(0xFFB0A3A0);
      iconColor = theme.colorScheme.primary;
    } else if (isMint) {
      cardBg = Colors.white;
      labelColor = const Color(0xFF2F7A69);
      iconColor = const Color(0xFF2F7A69);
    } else {
      cardBg = Colors.white;
      labelColor = const Color(0xFF9C7C68);
      iconColor = const Color(0xFF6B4E42);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.brown.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, color: iconColor, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 13,
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// 스타일 버튼 (main.dart 테마 정확히 적용)
class StyledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isPrimary;
  final IconData? icon;

  const StyledButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';

    late final Color buttonBg;
    late final Color buttonFg;

    if (isPrimary) {
      if (isDark) {
        buttonBg = scheme.primaryContainer;
        buttonFg = scheme.onPrimaryContainer;
      } else if (isMint) {
        buttonBg = const Color(0xFF2F7A69); // 진한 민트
        buttonFg = Colors.white;
      } else {
        buttonBg = const Color(0xFF6B4E42); // 갈색
        buttonFg = Colors.white;
      }
    } else {
      if (isDark) {
        buttonBg = scheme.surfaceContainerHigh;
        buttonFg = scheme.onSurface;
      } else if (isMint) {
        buttonBg = const Color(0xFFA8E6CF); // 연민트
        buttonFg = const Color(0xFF2F7A69);
      } else {
        buttonBg = const Color(0xFFA8E6CF); // 민트
        buttonFg = const Color(0xFF6B4E42);
      }
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBg,
        foregroundColor: buttonFg,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: isDark ? 0 : 4,
        shadowColor: isDark ? null : Colors.brown.withOpacity(0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 컨테이너 (main.dart 테마 적용)
class StyledSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const StyledSectionCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';

    late final Color cardBg;

    if (isDark) {
      cardBg = const Color(0xFF261E1B); // theme.cardTheme.color
    } else if (isMint) {
      cardBg = const Color(0xFFF4FFFA); // mintTheme.cardTheme.color
    } else {
      cardBg = Colors.white;
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.brown.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 섹션 타이틀 (main.dart 테마 적용)
class StyledSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const StyledSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';

    late final Color titleColor;
    late final Color subtitleColor;
    late final Color iconColor;

    if (isDark) {
      titleColor = const Color(0xFFF7E0B4);
      subtitleColor = const Color(0xFFB0A3A0);
      iconColor = theme.colorScheme.primary;
    } else if (isMint) {
      titleColor = const Color(0xFF2F7A69);
      subtitleColor = const Color(0xFF2F7A69);
      iconColor = const Color(0xFF2F7A69);
    } else {
      titleColor = const Color(0xFF6B4E42);
      subtitleColor = const Color(0xFF9C7C68);
      iconColor = const Color(0xFF6B4E42);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
        ],
      ],
    );
  }
}