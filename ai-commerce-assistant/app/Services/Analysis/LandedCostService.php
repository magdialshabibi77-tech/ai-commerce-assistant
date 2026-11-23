<?php

namespace App\Services\Analysis;

class LandedCostService
{
    public const DEFAULT_VAT_RATE = '0.1500';      // 15% VAT (KSA)
    public const DEFAULT_CUSTOMS_RATE = '0.0500';  // 5% Customs duty

    /**
     * Compute landed cost and true net profit breakdown using BCMath precision.
     *
     * @param string|float $buyPrice Purchase price in target currency
     * @param string|float $shippingCost Shipping cost in target currency
     * @param string|float|null $sellingPrice Target selling price in target currency (optional)
     * @param string|float $customsRate Customs duty rate (default 0.05)
     * @param string|float $vatRate VAT rate (default 0.15)
     * @param string|float $platformFee Platform / marketplace fees (default 0.0)
     * @param string|float $otherCosts Other incidental costs (default 0.0)
     * @return array<string, mixed>
     */
    public function compute(
        mixed $buyPrice,
        mixed $shippingCost = 0.0,
        mixed $sellingPrice = null,
        mixed $customsRate = null,
        mixed $vatRate = null,
        mixed $platformFee = 0.0,
        mixed $otherCosts = 0.0
    ): array {
        $buyStr = $this->formatAmount($buyPrice);
        $shipStr = $this->formatAmount($shippingCost);
        $customsRateStr = $customsRate !== null ? $this->formatRate($customsRate) : self::DEFAULT_CUSTOMS_RATE;
        $vatRateStr = $vatRate !== null ? $this->formatRate($vatRate) : self::DEFAULT_VAT_RATE;
        $feeStr = $this->formatAmount($platformFee);
        $otherStr = $this->formatAmount($otherCosts);

        // 1. Customs Fee = buyPrice * customsRate
        $customsFee = bcmul($buyStr, $customsRateStr, 4);

        // 2. VAT Base = buyPrice + shippingCost + customsFee (GCC / Saudi ZATCA standard)
        $vatBase = bcadd(bcadd($buyStr, $shipStr, 4), $customsFee, 4);
        $vatAmount = bcmul($vatBase, $vatRateStr, 4);

        // 3. Landed Cost = buyPrice + shippingCost + customsFee + vatAmount
        $landedCost = bcadd($vatBase, $vatAmount, 4);

        // 4. Total Cost = landedCost + platformFee + otherCosts
        $totalCost = bcadd(bcadd($landedCost, $feeStr, 4), $otherStr, 4);

        // 5. True Net Profit & Margin (if selling price is supplied)
        $hasSelling = $sellingPrice !== null && $sellingPrice !== '' && is_numeric($sellingPrice);
        $sellStr = $hasSelling ? $this->formatAmount($sellingPrice) : null;
        $trueNetProfit = null;
        $trueMargin = null;
        $roi = null;
        $isProfitable = null;

        if ($hasSelling && $sellStr !== null) {
            $trueNetProfit = bcsub($sellStr, $totalCost, 4);
            $isProfitable = bccomp($trueNetProfit, '0.0000', 4) > 0;

            if (bccomp($sellStr, '0.0000', 4) <= 0) {
                $trueMargin = '0.0000';
            } else {
                $trueMargin = bcdiv(bcmul($trueNetProfit, '100.0000', 6), $sellStr, 4);
            }

            if (bccomp($totalCost, '0.0000', 4) <= 0) {
                $roi = '0.0000';
            } else {
                $roi = bcdiv(bcmul($trueNetProfit, '100.0000', 6), $totalCost, 4);
            }
        }

        return [
            'purchase_price' => $buyStr,
            'shipping_cost' => $shipStr,
            'customs_rate' => $customsRateStr,
            'customs_fee' => $customsFee,
            'vat_rate' => $vatRateStr,
            'vat_amount' => $vatAmount,
            'landed_cost' => $landedCost,
            'platform_fee' => $feeStr,
            'other_costs' => $otherStr,
            'total_cost' => $totalCost,
            'selling_price' => $sellStr,
            'true_net_profit' => $trueNetProfit,
            'true_margin_percentage' => $trueMargin,
            'return_on_investment' => $roi,
            'is_profitable' => $isProfitable,
        ];
    }

    protected function formatAmount(mixed $amount): string
    {
        return number_format((float) ($amount ?? 0.0), 4, '.', '');
    }

    protected function formatRate(mixed $rate): string
    {
        $val = (float) $rate;
        // If passed as e.g. 5 or 15 instead of 0.05 or 0.15, normalize to decimal fraction
        if ($val > 1.0) {
            $val = $val / 100.0;
        }
        return number_format($val, 4, '.', '');
    }
}
