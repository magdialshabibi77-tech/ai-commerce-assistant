class FinancialMetricsModel {
  final double? purchasePrice;
  final double? sellingPrice;
  final double? shippingCost;
  final double? customsFee;
  final double? customsRate;
  final double? vatAmount;
  final double? vatRate;
  final double? landedCost;
  final double? estimatedFees;
  final double? otherCosts;
  final double? totalCost;
  final double? estimatedProfit;
  final double? profitMarginPercent;
  final double? roiPercent;
  final bool? isProfitable;
  final bool isShippingVerified;
  final String profitStatus; // CALCULATED_CONFIRMED | ESTIMATED_PENDING_SHIPPING | INSUFFICIENT_DATA | DATA_UNAVAILABLE
  final String? purchaseTruth;
  final String? sellingTruth;
  final String? shippingTruth;
  final String? customsTruth;
  final String? vatTruth;
  final String? landedCostTruth;
  final String? feesTruth;
  final String? otherCostsTruth;
  final String? totalCostTruth;
  final String? estimatedProfitTruth;

  const FinancialMetricsModel({
    this.purchasePrice,
    this.sellingPrice,
    this.shippingCost,
    this.customsFee,
    this.customsRate,
    this.vatAmount,
    this.vatRate,
    this.landedCost,
    this.estimatedFees,
    this.otherCosts,
    this.totalCost,
    this.estimatedProfit,
    this.profitMarginPercent,
    this.roiPercent,
    this.isProfitable,
    required this.isShippingVerified,
    required this.profitStatus,
    this.purchaseTruth,
    this.sellingTruth,
    this.shippingTruth,
    this.customsTruth,
    this.vatTruth,
    this.landedCostTruth,
    this.feesTruth,
    this.otherCostsTruth,
    this.totalCostTruth,
    this.estimatedProfitTruth,
  });

  bool get hasVerifiedShippingSource =>
      isShippingVerified &&
      shippingTruth != null &&
      shippingTruth!.toUpperCase() != 'ESTIMATED';

  static String? _extractTruth(dynamic raw) {
    if (raw is! Map) return null;
    final candidate = raw['truth'] ?? raw['tag'];
    if (candidate == null) return null;
    final normalized = candidate.toString().trim().toUpperCase();
    return normalized.isEmpty ? null : normalized;
  }

  static double? extractNullableVal(dynamic key) {
    final candidate = key is Map ? key['value'] : key;
    if (candidate == null || candidate is bool) return null;
    if (candidate is num) {
      final parsed = candidate.toDouble();
      return parsed.isFinite ? parsed : null;
    }
    if (candidate is String) {
      final trimmed = candidate.trim();
      if (trimmed.isEmpty) return null;
      final parsed = double.tryParse(trimmed);
      return (parsed != null && parsed.isFinite) ? parsed : null;
    }
    return null;
  }

  static bool? _parseNullableBool(dynamic raw) {
    final candidate = raw is Map ? raw['value'] : raw;
    if (candidate is bool) return candidate;
    if (candidate is String) {
      final trimmed = candidate.trim().toLowerCase();
      if (trimmed == 'true') return true;
      if (trimmed == 'false') return false;
    }
    return null;
  }

  static double? _parseNullablePercentage(dynamic raw) {
    final candidate = raw is Map ? raw['value'] : raw;
    if (candidate == null || candidate is bool) return null;
    if (candidate is num) {
      final parsed = candidate.toDouble();
      return parsed.isFinite ? parsed : null;
    }
    if (candidate is String) {
      var trimmed = candidate.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.endsWith('%')) {
        trimmed = trimmed.substring(0, trimmed.length - 1).trim();
      }
      if (trimmed.isEmpty) return null;
      final parsed = double.tryParse(trimmed);
      return (parsed != null && parsed.isFinite) ? parsed : null;
    }
    return null;
  }

  factory FinancialMetricsModel.fromJson(Map<String, dynamic> json) {
    final sellingBlock = json['selling_price'] is Map ? json['selling_price'] as Map<String, dynamic> : {};
    final shippingBlock = json['shipping_cost'] is Map ? json['shipping_cost'] as Map<String, dynamic> : {};
    final profitBlock = json['estimated_profit'] is Map ? json['estimated_profit'] as Map<String, dynamic> : {};

    final sellingPrice = extractNullableVal(json['selling_price']);
    final estimatedProfit = extractNullableVal(json['estimated_profit']);

    return FinancialMetricsModel(
      purchasePrice: extractNullableVal(json['purchase_price']),
      sellingPrice: sellingPrice,
      shippingCost: extractNullableVal(json['shipping_cost']),
      customsFee: extractNullableVal(json['customs_fee']),
      customsRate: extractNullableVal(json['customs_rate'] is Map ? (json['customs_rate'] as Map)['rate'] ?? (json['customs_rate'] as Map)['value'] : (json['customs_fee'] is Map ? (json['customs_fee'] as Map)['rate'] : json['customs_rate'])),
      vatAmount: extractNullableVal(json['vat_amount']),
      vatRate: extractNullableVal(json['vat_rate'] is Map ? (json['vat_rate'] as Map)['rate'] ?? (json['vat_rate'] as Map)['value'] : (json['vat_amount'] is Map ? (json['vat_amount'] as Map)['rate'] : json['vat_rate'])),
      landedCost: extractNullableVal(json['landed_cost']),
      estimatedFees: extractNullableVal(json['estimated_fees']),
      otherCosts: extractNullableVal(json['other_costs']),
      totalCost: extractNullableVal(json['total_cost']),
      estimatedProfit: estimatedProfit,
      profitMarginPercent: _parseNullablePercentage(json['profit_margin_percent']),
      roiPercent: _parseNullablePercentage(
        json['return_on_investment_percent'] ?? json['roi_percent'],
      ),
      isProfitable: _parseNullableBool(json['is_profitable']),
      isShippingVerified: shippingBlock['is_verified'] as bool? ?? false,
      profitStatus: profitBlock['status']?.toString() ??
          sellingBlock['status']?.toString() ??
          ((sellingPrice == null || estimatedProfit == null)
              ? 'DATA_UNAVAILABLE'
              : (shippingBlock['is_verified'] == true
                  ? 'CALCULATED_CONFIRMED'
                  : 'ESTIMATED_PENDING_SHIPPING')),
      purchaseTruth: _extractTruth(json['purchase_price']),
      sellingTruth: _extractTruth(json['selling_price']),
      shippingTruth: _extractTruth(json['shipping_cost']),
      customsTruth: _extractTruth(json['customs_fee']),
      vatTruth: _extractTruth(json['vat_amount']),
      landedCostTruth: _extractTruth(json['landed_cost']),
      feesTruth: _extractTruth(json['estimated_fees']),
      otherCostsTruth: _extractTruth(json['other_costs']),
      totalCostTruth: _extractTruth(json['total_cost']),
      estimatedProfitTruth: _extractTruth(json['estimated_profit']),
    );
  }
}

