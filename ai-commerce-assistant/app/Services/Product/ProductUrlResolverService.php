<?php

namespace App\Services\Product;

class ProductUrlResolverService
{
    /**
     * Resolve a valid purchasing or search URL for any store.
     * If affiliate_url or original url exists, it returns it;
     * otherwise, it generates a direct search query URL for the specific marketplace.
     */
    public function resolveBuyUrl(
        ?string $affiliateUrl,
        ?string $originalUrl,
        string $storeCode,
        string $productTitle
    ): string {
        if (! empty($affiliateUrl)) {
            return $affiliateUrl;
        }

        if (! empty($originalUrl) && filter_var($originalUrl, FILTER_VALIDATE_URL)) {
            return $originalUrl;
        }

        $encodedQuery = urlencode(trim($productTitle));
        $normalizedCode = strtolower(trim($storeCode));

        return match ($normalizedCode) {
            'jarir' => "https://www.jarir.com/sa-en/catalogsearch/result/?q={$encodedQuery}",
            'noon' => "https://www.noon.com/saudi-en/search/?q={$encodedQuery}",
            'extra' => "https://www.extra.com/en-sa/search/?text={$encodedQuery}",
            'amazon', 'amazon_sa' => "https://www.amazon.sa/s?k={$encodedQuery}",
            'ebay' => "https://www.ebay.com/sch/i.html?_nkw={$encodedQuery}",
            'aliexpress' => "https://www.aliexpress.com/wholesale?SearchText={$encodedQuery}",
            'alibaba' => "https://www.alibaba.com/trade/search?SearchText={$encodedQuery}",
            default => "https://www.google.com/search?q=" . urlencode("{$productTitle} {$storeCode}"),
        };
    }
}
