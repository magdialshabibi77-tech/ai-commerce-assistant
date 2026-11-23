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
        Schema::table('product_listings', function (Blueprint $table) {
            $table->string('condition')->default('new')->after('is_available'); // new, used, refurbished
            $table->boolean('authenticity_guaranteed')->default(false)->after('condition');
            $table->decimal('seller_rating', 5, 2)->nullable()->after('authenticity_guaranteed');
            $table->text('affiliate_url')->nullable()->after('seller_rating');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('product_listings', function (Blueprint $table) {
            $table->dropColumn([
                'condition',
                'authenticity_guaranteed',
                'seller_rating',
                'affiliate_url',
            ]);
        });
    }
};
