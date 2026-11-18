<?php

namespace Database\Seeders;

use App\Models\CanonicalProduct;
use App\Models\Category;
use App\Models\ProductListing;
use App\Models\ProductSource;
use Illuminate\Database\Seeder;

class MultiMarketProductSeeder extends Seeder
{
    public function run(): void
    {
        $electronics = Category::where('slug', 'electronics')->first()
            ?? Category::firstOrCreate(['name' => 'Electronics', 'slug' => 'electronics']);

        $jarir = ProductSource::where('code', 'jarir')->first()
            ?? ProductSource::create(['code' => 'jarir', 'name' => 'مكتبة جرير | Jarir Bookstore', 'base_url' => 'https://www.jarir.com', 'is_active' => true]);

        $noon = ProductSource::where('code', 'noon')->first()
            ?? ProductSource::create(['code' => 'noon', 'name' => 'متجر نون | Noon Marketplace', 'base_url' => 'https://www.noon.com', 'is_active' => true]);

        $extra = ProductSource::where('code', 'extra')->first()
            ?? ProductSource::create(['code' => 'extra', 'name' => 'إكسترا للإلكترونيات | eXtra Stores', 'base_url' => 'https://www.extra.com', 'is_active' => true]);

        $amazon = ProductSource::where('code', 'amazon')->first()
            ?? ProductSource::create(['code' => 'amazon', 'name' => 'Amazon Marketplace', 'base_url' => 'https://www.amazon.com', 'is_active' => true]);

        $alibaba = ProductSource::where('code', 'alibaba')->first()
            ?? ProductSource::create(['code' => 'alibaba', 'name' => 'Alibaba Wholesale', 'base_url' => 'https://www.alibaba.com', 'is_active' => true]);

        $ebay = ProductSource::where('code', 'ebay')->first()
            ?? ProductSource::create(['code' => 'ebay', 'name' => 'eBay Marketplace', 'base_url' => 'https://www.ebay.com', 'is_active' => true]);

        $aliexpress = ProductSource::where('code', 'aliexpress')->first()
            ?? ProductSource::create(['code' => 'aliexpress', 'name' => 'AliExpress Global', 'base_url' => 'https://www.aliexpress.com', 'is_active' => true]);

        // 1. Sony WH-1000XM4 Wireless Headphones
        $sony = CanonicalProduct::firstOrCreate(
            ['slug' => 'sony-wh-1000xm4-wireless-headphones'],
            [
                'category_id' => $electronics->id,
                'name' => 'Sony WH-1000XM4 Wireless Headphones',
                'brand' => 'Sony',
                'model_number' => 'WH-1000XM4',
                'description' => 'Industry-leading noise canceling overhead Bluetooth headphones with microphone.',
                'base_currency' => 'USD',
            ]
        );

        // Sony @ Jarir Bookstore
        ProductListing::updateOrCreate(
            ['source_id' => $jarir->id, 'external_id' => 'JARIR-SONY-1000XM4'],
            [
                'canonical_product_id' => $sony->id,
                'category_id' => $electronics->id,
                'title' => 'سماعات سوني WH-1000XM4 عازلة للضوضاء بلوتوث - مكتبة جرير (ضمان سنتين معتمد)',
                'description' => 'عرض مكتبة جرير الرسمي مع ضمان الوكيل المحلي سنتين والتوصيل السريع.',
                'brand' => 'Sony',
                'url' => 'https://www.jarir.com/sa-ar/sony-wh-1000xm4-headphone-554201.html',
                'image_url' => 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 346.4000,
                'original_price' => 399.0000,
                'rating' => 4.90,
                'reviews_count' => 3420,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Sony @ Noon
        ProductListing::updateOrCreate(
            ['source_id' => $noon->id, 'external_id' => 'NOON-SONY-XM4-BLK'],
            [
                'canonical_product_id' => $sony->id,
                'category_id' => $electronics->id,
                'title' => 'سماعات رأس سوني WH-1000XM4 مانعة للتشويش فوق الأذن - نون إكسبرس أصلي 100%',
                'description' => 'نون إكسبرس توصيل خلال 24 ساعة وضمان محلي شامل.',
                'brand' => 'Sony',
                'url' => 'https://www.noon.com/saudi-ar/sony-wh-1000xm4/N39521340A/p/',
                'image_url' => 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 306.4000,
                'original_price' => 379.0000,
                'rating' => 4.75,
                'reviews_count' => 8950,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Sony @ eXtra Stores
        ProductListing::updateOrCreate(
            ['source_id' => $extra->id, 'external_id' => 'EXTRA-SONY-XM4-SA'],
            [
                'canonical_product_id' => $sony->id,
                'category_id' => $electronics->id,
                'title' => 'سوني سماعة لاسلكية مانعة للإزعاج WH-1000XM4 أسود - معارض إكسترا للإلكترونيات',
                'description' => 'متوفر في معارض إكسترا وخدمة الاستلام من الفرع خلال ساعتين.',
                'brand' => 'Sony',
                'url' => 'https://www.extra.com/ar-sa/electronics/audio/headphones/sony-wh1000xm4/p/100188921',
                'image_url' => 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 333.0000,
                'original_price' => 389.0000,
                'rating' => 4.80,
                'reviews_count' => 2100,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Sony @ Amazon
        ProductListing::updateOrCreate(
            ['source_id' => $amazon->id, 'external_id' => 'B0863TXGM3'],
            [
                'canonical_product_id' => $sony->id,
                'category_id' => $electronics->id,
                'title' => 'Sony WH-1000XM4 Wireless Industry Leading Noise Canceling Overhead Headphones - Black',
                'description' => 'Amazon offer with fast prime delivery.',
                'brand' => 'Sony',
                'url' => 'https://www.amazon.com/dp/B0863TXGM3',
                'image_url' => 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 348.0000,
                'original_price' => 399.9900,
                'rating' => 4.70,
                'reviews_count' => 54200,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Sony @ Alibaba
        ProductListing::updateOrCreate(
            ['source_id' => $alibaba->id, 'external_id' => 'ALB-SONY-991'],
            [
                'canonical_product_id' => $sony->id,
                'category_id' => $electronics->id,
                'title' => 'Original Sony WH-1000XM4 ANC Wireless Headphones Factory Wholesale Offer',
                'description' => 'Wholesale supplier on Alibaba with MOQs.',
                'brand' => 'Sony',
                'url' => 'https://www.alibaba.com/product-detail/ALB-SONY-991.html',
                'image_url' => 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 180.0000,
                'original_price' => 220.0000,
                'rating' => 4.60,
                'reviews_count' => 320,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Sony @ eBay
        ProductListing::updateOrCreate(
            ['source_id' => $ebay->id, 'external_id' => 'EBAY-SONY-772'],
            [
                'canonical_product_id' => $sony->id,
                'category_id' => $electronics->id,
                'title' => 'Sony WH-1000XM4 Wireless Noise Cancelling Over-Ear Headphones - Sealed New',
                'description' => 'Authorized refurbished and brand new eBay listings.',
                'brand' => 'Sony',
                'url' => 'https://www.ebay.com/itm/EBAY-SONY-772',
                'image_url' => 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 310.0000,
                'original_price' => 349.9900,
                'rating' => 4.80,
                'reviews_count' => 1420,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // 2. Anker 737 Power Bank
        $anker = CanonicalProduct::firstOrCreate(
            ['slug' => 'anker-737-power-bank-24000mah'],
            [
                'category_id' => $electronics->id,
                'name' => 'Anker 737 Power Bank (PowerCore 24K)',
                'brand' => 'Anker',
                'model_number' => 'A1289',
                'description' => 'High capacity 24,000mAh portable charger with 140W bi-directional smart display.',
                'base_currency' => 'USD',
            ]
        );

        // Anker @ Jarir
        ProductListing::updateOrCreate(
            ['source_id' => $jarir->id, 'external_id' => 'JARIR-ANKER-737'],
            [
                'canonical_product_id' => $anker->id,
                'category_id' => $electronics->id,
                'title' => 'أنكر باور كور 737 شاحن متنقل سعة 24000 مللي أمبير بقوة 140 واط - مكتبة جرير',
                'description' => 'شاحن أنكر الأصلي معتمد جرير شاشة رقمية تفاعلية.',
                'brand' => 'Anker',
                'url' => 'https://www.jarir.com/sa-ar/anker-737-power-bank-598214.html',
                'image_url' => 'https://images.unsplash.com/photo-1609592424367-6e9f291e2b69?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 154.4000,
                'original_price' => 179.0000,
                'rating' => 4.85,
                'reviews_count' => 1250,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Anker @ Noon
        ProductListing::updateOrCreate(
            ['source_id' => $noon->id, 'external_id' => 'NOON-ANKER-737-KSA'],
            [
                'canonical_product_id' => $anker->id,
                'category_id' => $electronics->id,
                'title' => 'شاحن متنقل أنكر 737 باور كور 24 ألف ملي أمبير ثلاثي المنافذ - نون إكسبرس',
                'description' => 'توصيل نون إكسبرس المميز خلال 24 ساعة.',
                'brand' => 'Anker',
                'url' => 'https://www.noon.com/saudi-ar/anker-737-power-bank/N53284910A/p/',
                'image_url' => 'https://images.unsplash.com/photo-1609592424367-6e9f291e2b69?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 133.0000,
                'original_price' => 165.0000,
                'rating' => 4.70,
                'reviews_count' => 3120,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Anker @ eXtra
        ProductListing::updateOrCreate(
            ['source_id' => $extra->id, 'external_id' => 'EXTRA-ANKER-737-PB'],
            [
                'canonical_product_id' => $anker->id,
                'category_id' => $electronics->id,
                'title' => 'أنكر باور بانك 737 شاحن محمول للابتوب والجوال شاشة ذكية - معارض إكسترا',
                'description' => 'متوفر في جميع معارض إكسترا بالمملكة.',
                'brand' => 'Anker',
                'url' => 'https://www.extra.com/ar-sa/electronics/mobile-accessories/power-banks/anker-737-140w/p/100312450',
                'image_url' => 'https://images.unsplash.com/photo-1609592424367-6e9f291e2b69?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 146.4000,
                'original_price' => 175.0000,
                'rating' => 4.80,
                'reviews_count' => 840,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Anker @ Amazon
        ProductListing::updateOrCreate(
            ['source_id' => $amazon->id, 'external_id' => 'B09V3KXK7G'],
            [
                'canonical_product_id' => $anker->id,
                'category_id' => $electronics->id,
                'title' => 'Anker 737 Power Bank, 24,000mAh 3-Port Laptop Portable Charger 140W Output',
                'description' => 'Amazon prime certified.',
                'brand' => 'Anker',
                'url' => 'https://www.amazon.com/dp/B09V3KXK7G',
                'image_url' => 'https://images.unsplash.com/photo-1609592424367-6e9f291e2b69?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 149.9900,
                'original_price' => 179.9900,
                'rating' => 4.60,
                'reviews_count' => 8400,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // Anker @ AliExpress
        ProductListing::updateOrCreate(
            ['source_id' => $aliexpress->id, 'external_id' => 'ALI-ANKER-448'],
            [
                'canonical_product_id' => $anker->id,
                'category_id' => $electronics->id,
                'title' => 'Anker 737 Power Bank PowerCore 24K 140W Fast Charging Official Store',
                'description' => 'AliExpress global delivery.',
                'brand' => 'Anker',
                'url' => 'https://www.aliexpress.com/item/ALI-ANKER-448.html',
                'image_url' => 'https://images.unsplash.com/photo-1609592424367-6e9f291e2b69?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 99.5000,
                'original_price' => 129.0000,
                'rating' => 4.70,
                'reviews_count' => 1890,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // 3. Apple iPhone 15 Pro 256GB
        $iphone = CanonicalProduct::firstOrCreate(
            ['slug' => 'apple-iphone-15-pro-256gb'],
            [
                'category_id' => $electronics->id,
                'name' => 'Apple iPhone 15 Pro 256GB Natural Titanium',
                'brand' => 'Apple',
                'model_number' => 'A3102',
                'description' => 'Flagship smartphone featuring Aerospace-grade titanium design, A17 Pro chip, 48MP camera system.',
                'base_currency' => 'USD',
            ]
        );

        // iPhone @ Jarir
        ProductListing::updateOrCreate(
            ['source_id' => $jarir->id, 'external_id' => 'JARIR-IPHONE15PRO-256'],
            [
                'canonical_product_id' => $iphone->id,
                'category_id' => $electronics->id,
                'title' => 'آبل آيفون 15 برو تيتانيوم طبيعي 256 جيجابايت 5G - مكتبة جرير (ضمان حاسبات العرب سنتين)',
                'description' => 'نسخة الشرق الأوسط معتمدة مع ضمان سنتين من الوكيل الرسمي حاسبات العرب.',
                'brand' => 'Apple',
                'url' => 'https://www.jarir.com/sa-ar/apple-iphone-15-pro-smartphones-621301.html',
                'image_url' => 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 1253.0000,
                'original_price' => 1349.0000,
                'rating' => 4.95,
                'reviews_count' => 14200,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // iPhone @ Noon
        ProductListing::updateOrCreate(
            ['source_id' => $noon->id, 'external_id' => 'NOON-IPHONE15P-256-NT'],
            [
                'canonical_product_id' => $iphone->id,
                'category_id' => $electronics->id,
                'title' => 'أبل آيفون 15 برو 256 جيجا تيتانيوم طبيعي 5G - نون إكسبرس أصلي مع فيس تايم',
                'description' => 'توصيل سوبر سريع في نفس اليوم وضمان استرجاع مجاني.',
                'brand' => 'Apple',
                'url' => 'https://www.noon.com/saudi-ar/iphone-15-pro-256gb/N53432910A/p/',
                'image_url' => 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 1199.7000,
                'original_price' => 1320.0000,
                'rating' => 4.85,
                'reviews_count' => 22400,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // iPhone @ eXtra
        ProductListing::updateOrCreate(
            ['source_id' => $extra->id, 'external_id' => 'EXTRA-IP15P-256-TITANIUM'],
            [
                'canonical_product_id' => $iphone->id,
                'category_id' => $electronics->id,
                'title' => 'آيفون 15 برو 256 جيجا الجيل الخامس تيتانيوم طبيعي - معارض إكسترا',
                'description' => 'متوفر للشراء بالتقسيط وبكافة معارض إكسترا السعودية.',
                'brand' => 'Apple',
                'url' => 'https://www.extra.com/ar-sa/mobiles-tablets/mobiles/iphone/iphone-15-pro-256gb/p/100344210',
                'image_url' => 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 1226.4000,
                'original_price' => 1335.0000,
                'rating' => 4.90,
                'reviews_count' => 5800,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // iPhone @ Amazon
        ProductListing::updateOrCreate(
            ['source_id' => $amazon->id, 'external_id' => 'AMZ-IPHONE15P-256GB'],
            [
                'canonical_product_id' => $iphone->id,
                'category_id' => $electronics->id,
                'title' => 'Apple iPhone 15 Pro, 256GB, Natural Titanium - Fully Unlocked',
                'description' => 'Amazon Prime offer with international warranty.',
                'brand' => 'Apple',
                'url' => 'https://www.amazon.com/dp/B0CHWR8XZT',
                'image_url' => 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 1199.0000,
                'original_price' => 1299.0000,
                'rating' => 4.80,
                'reviews_count' => 18900,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // 4. Apple AirPods Max
        $airpods = CanonicalProduct::firstOrCreate(
            ['slug' => 'apple-airpods-max-silver'],
            [
                'category_id' => $electronics->id,
                'name' => 'Apple AirPods Max Silver',
                'brand' => 'Apple',
                'model_number' => 'MGYJ3AM/A',
                'description' => 'High-fidelity audio, Active Noise Cancellation with Transparency mode, personalized spatial audio.',
                'base_currency' => 'USD',
            ]
        );

        // AirPods @ Jarir
        ProductListing::updateOrCreate(
            ['source_id' => $jarir->id, 'external_id' => 'JARIR-AIRPODS-MAX-SLV'],
            [
                'canonical_product_id' => $airpods->id,
                'category_id' => $electronics->id,
                'title' => 'سماعات رأس أبل إيربودز ماكس فضي مع حافظة ذكية - مكتبة جرير (ضمان سنتين)',
                'description' => 'سماعة أبل الاحترافية الأصلية معتمدة من مكتبة جرير.',
                'brand' => 'Apple',
                'url' => 'https://www.jarir.com/sa-ar/apple-airpods-max-headphone-557812.html',
                'image_url' => 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 586.4000,
                'original_price' => 649.0000,
                'rating' => 4.90,
                'reviews_count' => 1950,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // AirPods @ Noon
        ProductListing::updateOrCreate(
            ['source_id' => $noon->id, 'external_id' => 'NOON-AIRPODS-MAX-SILVER'],
            [
                'canonical_product_id' => $airpods->id,
                'category_id' => $electronics->id,
                'title' => 'سماعة أبل إيربودز ماكس لاسلكية عازلة للضوضاء لون فضي - نون إكسبرس',
                'description' => 'سعر منافس على نون إكسبرس مع شحن مجاني وضمان أصلي.',
                'brand' => 'Apple',
                'url' => 'https://www.noon.com/saudi-ar/airpods-max-silver/N42851230A/p/',
                'image_url' => 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 519.7000,
                'original_price' => 599.0000,
                'rating' => 4.75,
                'reviews_count' => 4210,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );

        // AirPods @ eXtra
        ProductListing::updateOrCreate(
            ['source_id' => $extra->id, 'external_id' => 'EXTRA-AIRPODS-MAX-SLV'],
            [
                'canonical_product_id' => $airpods->id,
                'category_id' => $electronics->id,
                'title' => 'أبل سماعة رأس إيربودز ماكس محيطية فضي - معارض إكسترا',
                'description' => 'ضمان سنتين إكسترا مع إمكانية الشراء بنظام الأقساط الميسرة.',
                'brand' => 'Apple',
                'url' => 'https://www.extra.com/ar-sa/electronics/audio/headphones/airpods-max-silver/p/100224150',
                'image_url' => 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80',
                'currency' => 'USD',
                'price' => 559.7000,
                'original_price' => 629.0000,
                'rating' => 4.85,
                'reviews_count' => 1120,
                'is_available' => true,
                'observed_at' => now(),
            ]
        );
    }
}
