import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_commerce_mobile/core/constants/app_colors.dart';
import 'package:ai_commerce_mobile/core/constants/app_strings.dart';
import 'package:ai_commerce_mobile/core/utils/currency_formatter.dart';
import 'package:ai_commerce_mobile/core/widgets/smart_product_image.dart';
import 'package:ai_commerce_mobile/features/price_comparison/data/models/price_comparison_model.dart';
import 'package:ai_commerce_mobile/features/price_comparison/presentation/providers/price_comparison_provider.dart';

class PriceComparisonScreen extends ConsumerWidget {
  final int productId;

  const PriceComparisonScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(priceComparisonProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.priceComparison),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: comparisonAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'جاري جمع وتحليل أسعار المتاجر...',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(priceComparisonProvider(productId)),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (comparison) => _buildComparisonContent(context, comparison),
        ),
      ),
    );
  }

  Widget _buildComparisonContent(BuildContext context, PriceComparisonModel data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Separate Listings (Live vs Estimated)
    final liveListings = data.offers.where((o) => o.normalizedPrice != null && o.normalizedPrice! > 0).toList();
    final estimatedListings = data.offers.where((o) => o.normalizedPrice == null || o.normalizedPrice! <= 0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card (Product Title & Currency Notice)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2_rounded, color: AppColors.primaryLight, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data.canonicalProductName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.currency_exchange_rounded, size: 14, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Text(
                          'تم توحيد وحساب الأسعار بعملة: ${data.targetCurrency} بواسطة خادم Laravel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Price Spread & Arbitrage Summary Card
          Card(
            elevation: 0,
            color: isDark
                ? AppColors.cardDark
                : AppColors.primary.withValues(alpha: 0.04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.primaryLight.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: AppColors.primaryLight, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.priceSpread,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.priceSpread != null
                                  ? CurrencyFormatter.format(data.priceSpread, currency: data.targetCurrency)
                                  : 'غير متاح',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: data.priceSpread != null
                                    ? (isDark ? Colors.white : AppColors.primary)
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.buy.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.buy.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'هامش الربح الإجمالي المحتمل',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.formatPercent(data.potentialGrossMarginPercentage),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.buy),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (data.totalOffers > 0) ...[
                    const Divider(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'متوسط السعر: ${data.averagePrice != null ? CurrencyFormatter.format(data.averagePrice, currency: data.targetCurrency) : 'غير متاح'}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        Text(
                          'نسبة الفارق: ${data.priceSpreadPercentage != null ? CurrencyFormatter.formatPercent(data.priceSpreadPercentage) : 'غير متاح'}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Main Offers Header
          Row(
            children: [
              Text(
                '${AppStrings.marketOffers} (${data.totalOffers})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (liveListings.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.buy.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 13, color: AppColors.buy),
                      SizedBox(width: 4),
                      Text(
                        'أسعار حية ومحدثة',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.buy),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (data.offers.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    AppStrings.noResults,
                    style: TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ),
              ),
            )
          else ...[
            // Live Listings
            ...liveListings.map((offer) => _buildOfferCard(context, offer, data.targetCurrency, isDark, isLive: true)),

            // Estimated / Unavailable Listings
            ...estimatedListings.map((offer) => _buildOfferCard(context, offer, data.targetCurrency, isDark, isLive: false)),
          ],

          const SizedBox(height: 16),

          // 3. Expandable Section for Syncing / Upcoming Stores
          _buildUpcomingAndSyncingSection(context, isDark),
        ],
      ),
    );
  }

  /// Store Offer Card (supports both Live and Estimated)
  Widget _buildOfferCard(
    BuildContext context,
    ComparisonOfferModel offer,
    String targetCurrency,
    bool isDark, {
    required bool isLive,
  }) {
    final sellerLabel = offer.seller?.displayName ?? AppStrings.dataUnavailable;
    final storeColors = _getStoreBrandColors(offer.source.code);
    final arabicStoreName = _extractArabicStoreName(offer.source.name, offer.source.code);
    final englishStoreSubtitle = _extractEnglishStoreSubtitle(offer.source.name, offer.source.code);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Store Badge + Live/Estimated Badge + Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Icon & Name Column
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: storeColors.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: storeColors.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_rounded, size: 16, color: storeColors),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            arabicStoreName,
                            style: TextStyle(
                              color: storeColors,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (englishStoreSubtitle.isNotEmpty && englishStoreSubtitle != arabicStoreName)
                            Text(
                              englishStoreSubtitle,
                              style: TextStyle(
                                color: storeColors.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Live or Estimated Badge
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.buy.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 11, color: AppColors.buy),
                        SizedBox(width: 3),
                        Text(
                          'سعر مباشر',
                          style: TextStyle(color: AppColors.buy, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_outlined, size: 11, color: Colors.amber),
                        SizedBox(width: 3),
                        Text(
                          'سعر تقديري',
                          style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Normalized Target Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      offer.normalizedPrice != null
                          ? CurrencyFormatter.format(offer.normalizedPrice, currency: targetCurrency)
                          : 'غير متاح',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: offer.normalizedPrice != null
                            ? (isDark ? Colors.white : AppColors.primary)
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (offer.originalCurrency != targetCurrency)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'السعر الأصلي: ${offer.originalPrice != null ? CurrencyFormatter.format(offer.originalPrice, currency: offer.originalCurrency) : 'غير متاح'}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Product Title and Thumbnail Line
            if (offer.title.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartProductImage(
                    imageUrl: offer.imageUrl,
                    categoryName: offer.source.name,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(8),
                    iconSize: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      offer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade300 : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            // Seller and Trust Indicators
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    sellerLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                if (offer.seller?.feedbackPercentage != null || offer.seller?.feedbackScore != null) ...[
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    '${offer.seller?.feedbackPercentage != null ? CurrencyFormatter.formatPercent(offer.seller!.feedbackPercentage!) : ''}'
                    '${offer.seller?.feedbackScore != null ? ' (${offer.seller!.feedbackScore})' : ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Expandable Section for Syncing / Upcoming Stores
  Widget _buildUpcomingAndSyncingSection(BuildContext context, bool isDark) {
    const upcomingStores = [
      _UpcomingStoreItem(nameAr: 'لولو هايبر ماركت', nameEn: 'LuLu Hypermarket', status: 'جاري الربط الفني...'),
      _UpcomingStoreItem(nameAr: 'شرف دي جي', nameEn: 'Sharaf DG Online', status: 'جاري المزامنة...'),
      _UpcomingStoreItem(nameAr: 'كارفور السعودية', nameEn: 'Carrefour KSA', status: 'قيد الاعتماد...'),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sync_rounded, size: 18, color: Colors.amber),
          ),
          title: const Text(
            'متاجر جاري تحديث أسعارها (قريباً)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'يتم فحص العروض وتخطي الحماية تدريجياً لضمان الدقة',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: upcomingStores.map((store) {
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hourglass_top_rounded, size: 15, color: Colors.amber),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.nameAr,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              store.nameEn,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            store.status,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStoreBrandColors(String code) {
    switch (code.toLowerCase()) {
      case 'jarir':
        return const Color(0xFF0070BA); // Jarir Cyan/Blue
      case 'noon':
        return const Color(0xFFF5B400); // Noon Gold/Yellow
      case 'extra':
        return const Color(0xFF059669); // eXtra Emerald Green
      case 'amazon':
        return const Color(0xFFFF9900); // Amazon Orange
      case 'ebay':
        return const Color(0xFF0064D2); // eBay Blue
      case 'alibaba':
        return const Color(0xFFFF6000); // Alibaba Orange
      case 'aliexpress':
        return const Color(0xFFFF4747); // AliExpress Red
      default:
        return AppColors.primaryLight;
    }
  }

  String _extractArabicStoreName(String sourceName, String code) {
    if (sourceName.contains('|')) {
      return sourceName.split('|')[0].trim();
    }
    switch (code.toLowerCase()) {
      case 'amazon':
        return 'متجر أمازون';
      case 'ebay':
        return 'eBay Marketplace';
      case 'alibaba':
        return 'Alibaba Wholesale';
      case 'aliexpress':
        return 'AliExpress Global';
      case 'jarir':
        return 'مكتبة جرير';
      case 'noon':
        return 'متجر نون';
      case 'extra':
        return 'إكسترا للإلكترونيات';
      default:
        return sourceName;
    }
  }

  String _extractEnglishStoreSubtitle(String sourceName, String code) {
    if (sourceName.contains('|')) {
      return sourceName.split('|')[1].trim();
    }
    switch (code.toLowerCase()) {
      case 'amazon':
        return 'Amazon Marketplace';
      case 'ebay':
        return 'eBay Marketplace';
      case 'alibaba':
        return 'Alibaba Wholesale';
      case 'aliexpress':
        return 'AliExpress Global Hub';
      case 'jarir':
        return 'Jarir Bookstore';
      case 'noon':
        return 'Noon Express';
      case 'extra':
        return 'eXtra Stores';
      default:
        return sourceName;
    }
  }
}

class _UpcomingStoreItem {
  final String nameAr;
  final String nameEn;
  final String status;

  const _UpcomingStoreItem({
    required this.nameAr,
    required this.nameEn,
    required this.status,
  });
}
