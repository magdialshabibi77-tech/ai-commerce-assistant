import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_commerce_mobile/core/constants/app_colors.dart';
import 'package:ai_commerce_mobile/core/constants/app_strings.dart';
import 'package:ai_commerce_mobile/core/utils/currency_formatter.dart';
import 'package:ai_commerce_mobile/core/widgets/smart_product_image.dart';
import 'package:ai_commerce_mobile/features/products/presentation/screens/product_details_screen.dart';
import 'package:ai_commerce_mobile/features/market_research/data/models/market_item_model.dart';
import 'package:ai_commerce_mobile/features/market_research/presentation/providers/market_search_notifier.dart';

class MarketSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const MarketSearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<MarketSearchScreen> createState() => _MarketSearchScreenState();
}

class _MarketSearchScreenState extends ConsumerState<MarketSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(marketSearchNotifierProvider.notifier).search(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      FocusScope.of(context).unfocus();
      ref.read(marketSearchNotifierProvider.notifier).search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(marketSearchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.marketSearch),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHint,
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  child: const Text('بحث'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search Body
          Expanded(
            child: switch (searchState) {
              MarketSearchInitial() => _buildInitialView(),
              MarketSearchLoading() => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'جاري فحص وتوحيد عروض الأسعار من كبرى المتاجر (جرير، نون، إكسترا، أمازون)...',
                        style: TextStyle(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              MarketSearchError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onSearch,
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              MarketSearchSuccess(:final result) => _buildResultsList(result.items),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'أدخل اسم المنتج للبحث في الأسواق والمتاجر',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'يقوم النظام باسترجاع عروض الأسعار الحية من كبرى المتاجر المحلية والعالمية (جرير، نون، إكسترا، أمازون، إيباي) وتوحيدها ومطابقتها هندسياً بدون تكرار.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<MarketItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondaryLight),
              const SizedBox(height: 12),
              const Text(
                AppStrings.noResults,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'جرّب البحث بكلمات عامة أو باللغة الإنجليزية.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              if (item.canonicalProductId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(productId: item.canonicalProductId!),
                  ),
                );
              } else {
                final rawUrl = (item.url != null && item.url!.trim().isNotEmpty)
                    ? item.url!.trim()
                    : null;
                final finalUrl = rawUrl ??
                    'https://www.google.com/search?q=${Uri.encodeComponent('${item.sourceName} ${item.title}')}';
                final uri = Uri.parse(finalUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {
                  try {
                    await launchUrl(uri);
                  } catch (e) {
                    debugPrint('Error launching store url: $e');
                  }
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStoreBadgeColor(item.sourceName).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.sourceName,
                          style: TextStyle(
                            color: _getStoreBadgeColor(item.sourceName),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.price != null
                            ? CurrencyFormatter.format(item.price, currency: item.currency)
                            : 'غير متاح',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: item.price != null
                              ? AppColors.primary
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmartProductImage(
                        imageUrl: item.imageUrl,
                        categoryName: item.title,
                        width: 60,
                        height: 60,
                        borderRadius: BorderRadius.circular(10),
                        iconSize: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        item.isAvailable == null
                            ? 'غير متاح'
                            : (item.isAvailable! ? 'متوفر بالسوق' : 'غير متوفر حالياً'),
                        style: TextStyle(
                          fontSize: 12,
                          color: item.isAvailable == null
                              ? AppColors.textSecondaryLight
                              : (item.isAvailable! ? AppColors.decisionBuy : AppColors.error),
                        ),
                      ),
                      const Spacer(),
                      if (item.canonicalProductId != null)
                        const Row(
                          children: [
                            Text(
                              'عرض التحليل ومطابقة الأسعار',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                          ],
                        )
                      else
                        const Row(
                          children: [
                            Text(
                              'شراء / فتح في المتجر',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.primary),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStoreBadgeColor(String sourceName) {
    final lower = sourceName.toLowerCase();
    if (lower.contains('جرير') || lower.contains('jarir')) {
      return const Color(0xFF00838F); // Jarir Cyan/Teal
    }
    if (lower.contains('نون') || lower.contains('noon')) {
      return const Color(0xFFD97706); // Noon Gold/Amber
    }
    if (lower.contains('إكسترا') || lower.contains('اكسترا') || lower.contains('extra')) {
      return const Color(0xFF1E40AF); // eXtra Navy
    }
    if (lower.contains('أمازون') || lower.contains('امازون') || lower.contains('amazon')) {
      return const Color(0xFFEA580C); // Amazon Orange
    }
    if (lower.contains('aliexpress') || lower.contains('alibaba') || lower.contains('علي')) {
      return const Color(0xFFDC2626); // Red
    }
    return const Color(0xFF2563EB); // eBay / default Blue
  }
}
