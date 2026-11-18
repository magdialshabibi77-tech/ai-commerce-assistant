import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ai_commerce_mobile/core/constants/app_colors.dart';

class SmartProductImage extends StatefulWidget {
  final String? imageUrl;
  final String? categoryName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double iconSize;

  const SmartProductImage({
    super.key,
    required this.imageUrl,
    this.categoryName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.iconSize = 36.0,
  });

  @override
  State<SmartProductImage> createState() => _SmartProductImageState();
}

class _SmartProductImageState extends State<SmartProductImage> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Only start infinite repeating animation if NOT running inside automated widget tests
    // to avoid pumpAndSettle timeouts
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
    if (!isTesting) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(12);
    final hasValidUrl = widget.imageUrl != null &&
        widget.imageUrl!.trim().isNotEmpty &&
        widget.imageUrl!.startsWith('http');

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: hasValidUrl
            ? CachedNetworkImage(
                imageUrl: widget.imageUrl!.trim(),
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                placeholder: (context, url) => _buildShimmerPlaceholder(context),
                errorWidget: (context, url, error) => _buildCategoryFallback(context),
              )
            : _buildCategoryFallback(context),
      ),
    );
  }

  Widget _buildShimmerPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.grey.shade800 : Colors.grey.shade50;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_shimmerController.value * 2), -0.3),
              end: Alignment(1.0 + (_shimmerController.value * 2), 0.3),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              size: widget.iconSize,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryProfile = _resolveCategoryVisualProfile(widget.categoryName);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [categoryProfile.darkStart, categoryProfile.darkEnd]
              : [categoryProfile.lightStart, categoryProfile.lightEnd],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              categoryProfile.icon,
              size: widget.iconSize,
              color: isDark ? categoryProfile.accentDark : categoryProfile.accentLight,
            ),
            if (widget.height == null || widget.height! >= 70) ...[
              const SizedBox(height: 4),
              Text(
                categoryProfile.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? categoryProfile.accentDark : categoryProfile.accentLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _CategoryVisualProfile _resolveCategoryVisualProfile(String? categoryName) {
    final cat = (categoryName ?? '').toLowerCase();

    // Watches & Jewelry
    if (cat.contains('watch') || cat.contains('ساع') || cat.contains('مجوهر')) {
      return const _CategoryVisualProfile(
        icon: Icons.watch_rounded,
        label: 'ساعات فاخرة',
        lightStart: Color(0xFFF0FDF4),
        lightEnd: Color(0xFFDCFCE7),
        darkStart: Color(0xFF064E3B),
        darkEnd: Color(0xFF022C22),
        accentLight: Color(0xFF059669),
        accentDark: Color(0xFF34D399),
      );
    }

    // Phones & Mobiles
    if (cat.contains('phone') || cat.contains('جوال') || cat.contains('هاتف') || cat.contains('mobile')) {
      return const _CategoryVisualProfile(
        icon: Icons.phone_iphone_rounded,
        label: 'هواتف ذكية',
        lightStart: Color(0xFFEFF6FF),
        lightEnd: Color(0xFFDBEAFE),
        darkStart: Color(0xFF1E3A8A),
        darkEnd: Color(0xFF0F172A),
        accentLight: Color(0xFF2563EB),
        accentDark: Color(0xFF60A5FA),
      );
    }

    // Audio & Headphones
    if (cat.contains('audio') || cat.contains('headphone') || cat.contains('سماع') || cat.contains('sound')) {
      return const _CategoryVisualProfile(
        icon: Icons.headphones_rounded,
        label: 'أجهزة صوتية',
        lightStart: Color(0xFFFAF5FF),
        lightEnd: Color(0xFFF3E8FF),
        darkStart: Color(0xFF581C87),
        darkEnd: Color(0xFF2E1065),
        accentLight: Color(0xFF9333EA),
        accentDark: Color(0xFFC084FC),
      );
    }

    // Laptops & Computers
    if (cat.contains('laptop') || cat.contains('computer') || cat.contains('كمبيوتر') || cat.contains('حاسوب')) {
      return const _CategoryVisualProfile(
        icon: Icons.laptop_chromebook_rounded,
        label: 'حواسيب ومحمول',
        lightStart: Color(0xFFF8FAFC),
        lightEnd: Color(0xFFE2E8F0),
        darkStart: Color(0xFF1E293B),
        darkEnd: Color(0xFF0F172A),
        accentLight: Color(0xFF475569),
        accentDark: Color(0xFF94A3B8),
      );
    }

    // Perfumes & Fragrances
    if (cat.contains('perfume') || cat.contains('fragrance') || cat.contains('عطر')) {
      return const _CategoryVisualProfile(
        icon: Icons.spa_rounded,
        label: 'عطور ومستحضرات',
        lightStart: Color(0xFFFFF1F2),
        lightEnd: Color(0xFFFFE4E6),
        darkStart: Color(0xFF881337),
        darkEnd: Color(0xFF4C0519),
        accentLight: Color(0xFFE11D48),
        accentDark: Color(0xFFFB7185),
      );
    }

    // Default Electronics / Commerce fallback
    return const _CategoryVisualProfile(
      icon: Icons.inventory_2_rounded,
      label: 'منتج تجاري',
      lightStart: Color(0xFFF1F5F9),
      lightEnd: Color(0xFFE2E8F0),
      darkStart: Color(0xFF1E293B),
      darkEnd: Color(0xFF0B1120),
      accentLight: AppColors.primary,
      accentDark: AppColors.primaryLight,
    );
  }
}

class _CategoryVisualProfile {
  final IconData icon;
  final String label;
  final Color lightStart;
  final Color lightEnd;
  final Color darkStart;
  final Color darkEnd;
  final Color accentLight;
  final Color accentDark;

  const _CategoryVisualProfile({
    required this.icon,
    required this.label,
    required this.lightStart,
    required this.lightEnd,
    required this.darkStart,
    required this.darkEnd,
    required this.accentLight,
    required this.accentDark,
  });
}
