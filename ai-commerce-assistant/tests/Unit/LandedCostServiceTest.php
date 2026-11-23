<?php

namespace Tests\Unit;

use App\Services\Analysis\LandedCostService;
use PHPUnit\Framework\TestCase;

class LandedCostServiceTest extends TestCase
{
    protected LandedCostService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new LandedCostService();
    }

    public function test_standard_landed_cost_calculation(): void
    {
        // Buy: $974, Shipping: $50, Selling: $1574, Platform Fee: $30
        // Customs (5%): 974 * 0.05 = 48.7000
        // VAT Base (CIF): 974 + 50 + 48.70 = 1072.7000
        // VAT (15%): 1072.70 * 0.15 = 160.9050
        // Landed Cost: 1072.70 + 160.9050 = 1233.6050
        // Total Cost: 1233.6050 + 30 = 1263.6050
        // True Net Profit: 1574 - 1263.6050 = 310.3950
        // True Margin %: (310.3950 / 1574) * 100 = 19.7201 %
        $res = $this->service->compute(
            buyPrice: 974.00,
            shippingCost: 50.00,
            sellingPrice: 1574.00,
            customsRate: 0.05,
            vatRate: 0.15,
            platformFee: 30.00
        );

        $this->assertEquals('974.0000', $res['purchase_price']);
        $this->assertEquals('50.0000', $res['shipping_cost']);
        $this->assertEquals('0.0500', $res['customs_rate']);
        $this->assertEquals('48.7000', $res['customs_fee']);
        $this->assertEquals('0.1500', $res['vat_rate']);
        $this->assertEquals('160.9050', $res['vat_amount']);
        $this->assertEquals('1233.6050', $res['landed_cost']);
        $this->assertEquals('1263.6050', $res['total_cost']);
        $this->assertEquals('310.3950', $res['true_net_profit']);
        $this->assertEquals('19.7201', $res['true_margin_percentage']);
        $this->assertTrue($res['is_profitable']);
    }

    public function test_custom_rates_as_percentages(): void
    {
        // 10% customs, 20% VAT passed as whole numbers
        $res = $this->service->compute(
            buyPrice: 100.00,
            shippingCost: 20.00,
            sellingPrice: 200.00,
            customsRate: 10,
            vatRate: 20
        );

        $this->assertEquals('0.1000', $res['customs_rate']);
        $this->assertEquals('10.0000', $res['customs_fee']);
        $this->assertEquals('0.2000', $res['vat_rate']);
        // Base = 100 + 20 + 10 = 130
        // VAT = 130 * 0.20 = 26.0000
        $this->assertEquals('26.0000', $res['vat_amount']);
        // Landed Cost = 130 + 26 = 156.0000
        $this->assertEquals('156.0000', $res['landed_cost']);
        $this->assertEquals('44.0000', $res['true_net_profit']);
    }
}
