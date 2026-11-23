<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('product_metrics', function (Blueprint $table) {
            $table->decimal('customs_rate', 5, 4)->default(0.0500)->after('shipping_cost');
            $table->decimal('customs_fee', 12, 4)->default(0.0000)->after('customs_rate');
            $table->decimal('vat_rate', 5, 4)->default(0.1500)->after('customs_fee');
            $table->decimal('vat_amount', 12, 4)->default(0.0000)->after('vat_rate');
            $table->decimal('landed_cost', 12, 4)->default(0.0000)->after('vat_amount');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('product_metrics', function (Blueprint $table) {
            $table->dropColumn([
                'customs_rate',
                'customs_fee',
                'vat_rate',
                'vat_amount',
                'landed_cost',
            ]);
        });
    }
};
