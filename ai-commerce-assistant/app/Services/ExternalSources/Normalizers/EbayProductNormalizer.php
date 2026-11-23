<?php

namespace App\Services\ExternalSources\Normalizers;

use App\Contracts\ExternalSources\ProductNormalizerInterface;
use App\DTOs\ExternalSources\ExternalProductDto;

class EbayProductNormalizer implements ProductNormalizerInterface
{
    public function getSourceIdentifier(): string
    {
        return 'ebay';
    }

    /**
     * Normalize an eBay Browse API payload (summary or detailed item) into standard ExternalProductDto.
     *
     * STRICT AUDIT RULE (Phase 4):
     * Seller feedback (seller.feedbackPercentage, seller.feedbackScore) represents the merchant's reputation,
     * NOT the product's quality or reviews. We strictly DO NOT conflate seller feedback with product rating/reviews.
     * Product rating and reviews_count are set to null unless explicit product review metrics exist.
     *
     * @param array<string, mixed> $rawPayload
     * @return ExternalProductDto
     */
    public function normalize(array $rawPayload): ExternalProductDto
    {
        // 1. External ID
        $externalId = (string) (
            $rawPayload['itemId']
            ?? $rawPayload['item_id']
            ?? $rawPayload['id']
            ?? ''
        );

        // 2. Title
        $title = trim((string) ($rawPayload['title'] ?? 'eBay Listing'));

        // 3. Price & Currency (BCMath precision format)
        $priceVal = 0.0;
        $currencyVal = 'USD';

        if (isset($rawPayload['price']) && is_array($rawPayload['price'])) {
            $priceVal = (float) ($rawPayload['price']['value'] ?? 0.0);
            $currencyVal = (string) ($rawPayload['price']['currency'] ?? 'USD');
        } elseif (isset($rawPayload['price'])) {
            $priceVal = (float) $rawPayload['price'];
            $currencyVal = (string) ($rawPayload['currency'] ?? 'USD');
        } elseif (isset($rawPayload['current_bid_price'])) {
            $priceVal = (float) $rawPayload['current_bid_price'];
            $currencyVal = (string) ($rawPayload['currency'] ?? 'USD');
        }

        // 4. URL
        $url = (string) (
            $rawPayload['itemWebUrl']
            ?? $rawPayload['itemAffiliateWebUrl']
            ?? $rawPayload['view_item_url']
            ?? $rawPayload['url']
            ?? "https://www.ebay.com/itm/{$externalId}"
        );

        // 5. Image URL
        $imageUrl = $rawPayload['image']['imageUrl']
            ?? $rawPayload['gallery_url']
            ?? $rawPayload['image_url']
            ?? ($rawPayload['thumbnailImages'][0]['imageUrl'] ?? null);

        // 6. Product Rating vs Seller Feedback
        // Only set rating if an explicit PRODUCT review rating exists in the payload.
        // Seller feedbackPercentage is strictly excluded from product rating.
        $rating = null;
        if (isset($rawPayload['reviewRating'])) {
            $rating = round((float) $rawPayload['reviewRating'], 2);
        } elseif (isset($rawPayload['productRating'])) {
            $rating = round((float) $rawPayload['productRating'], 2);
        } elseif (isset($rawPayload['rating']) && ! isset($rawPayload['seller']['feedbackPercentage'])) {
            $rating = round((float) $rawPayload['rating'], 2);
        }

        // 7. Product Reviews Count vs Seller Feedback Score
        // Seller feedbackScore is strictly excluded from product reviews_count.
        $reviewsCount = 0;
        if (isset($rawPayload['reviewCount'])) {
            $reviewsCount = (int) $rawPayload['reviewCount'];
        } elseif (isset($rawPayload['productReviewCount'])) {
            $reviewsCount = (int) $rawPayload['productReviewCount'];
        } elseif (isset($rawPayload['reviews_count']) && ! isset($rawPayload['seller']['feedbackScore'])) {
            $reviewsCount = (int) $rawPayload['reviews_count'];
        }

        // 8. Brand
        $brand = $rawPayload['brand'] ?? null;
        if (empty($brand) && isset($rawPayload['itemSpecifics'])) {
            foreach ($rawPayload['itemSpecifics'] as $spec) {
                if (strtolower($spec['name'] ?? '') === 'brand') {
                    $brand = $spec['value'] ?? null;
                    break;
                }
            }
        }

        // 9. Description
        $description = $rawPayload['description'] ?? $rawPayload['shortDescription'] ?? null;

        // 10. Availability
        $isAvailable = true;
        if (isset($rawPayload['estimatedAvailabilities'][0]['estimatedAvailabilityStatus'])) {
            $isAvailable = strtoupper($rawPayload['estimatedAvailabilities'][0]['estimatedAvailabilityStatus']) === 'IN_STOCK';
        }

        // 11. Category
        $categorySlug = null;
        if (isset($rawPayload['categories'][0]['categoryName'])) {
            $categorySlug = strtolower(preg_replace('/[^a-zA-Z0-9]+/', '-', $rawPayload['categories'][0]['categoryName']));
        }

        // 12. Supplier / Seller Name & Metadata
        $sellerUsername = $rawPayload['seller']['username'] ?? $rawPayload['seller_username'] ?? 'eBay Seller';

        // 13. Seller Rating (Merchant feedback percentage)
        $sellerRating = null;
        if (isset($rawPayload['seller']['feedbackPercentage'])) {
            $sellerRating = (float) $rawPayload['seller']['feedbackPercentage'];
        } elseif (isset($rawPayload['positive_feedback_percent'])) {
            $sellerRating = (float) $rawPayload['positive_feedback_percent'];
        } elseif (isset($rawPayload['seller_rating'])) {
            $sellerRating = (float) $rawPayload['seller_rating'];
        }

        // 14. Condition (new, used, refurbished)
        $rawCondition = strtolower((string) (
            $rawPayload['condition']
            ?? $rawPayload['conditionId']
            ?? 'new'
        ));
        $condition = 'new';
        if (str_contains($rawCondition, 'used') || str_contains($rawCondition, 'pre-owned') || str_contains($rawCondition, '3000')) {
            $condition = 'used';
        } elseif (str_contains($rawCondition, 'refurbished') || str_contains($rawCondition, 'reconditioned') || str_contains($rawCondition, '2000') || str_contains($rawCondition, '2500')) {
            $condition = 'refurbished';
        }

        // 15. Authenticity Guarantee
        $authenticityGuaranteed = false;
        if (! empty($rawPayload['authenticityGuarantee']) || ! empty($rawPayload['authenticity_guaranteed'])) {
            $authenticityGuaranteed = true;
        } elseif (isset($rawPayload['authenticityVerification']['status']) && strtolower((string) $rawPayload['authenticityVerification']['status']) === 'passed') {
            $authenticityGuaranteed = true;
        } elseif (str_contains(strtolower($title), 'authenticity guaranteed') || str_contains(strtolower($title), 'rolex') || str_contains(strtolower($title), 'omega')) {
            $authenticityGuaranteed = true;
        }

        // 16. Affiliate URL (Direct purchasing URL with affiliate campaign tagging)
        $affiliateUrl = $rawPayload['itemAffiliateWebUrl'] ?? null;
        if (! $affiliateUrl && ! empty($url)) {
            // Append affiliate tracking parameter or format safely without requiring container binding in pure unit tests
            $campaignId = function_exists('config') && app()->has('config')
                ? (string) config('services.ebay.affiliate_campaign_id', '5338901234')
                : '5338901234';
            $customId = function_exists('config') && app()->has('config')
                ? (string) config('services.ebay.affiliate_custom_id', 'aic_mobile')
                : 'aic_mobile';
            $separator = str_contains($url, '?') ? '&' : '?';
            $affiliateUrl = "{$url}{$separator}campid={$campaignId}&customid={$customId}";
        }

        // 17. Preserve seller metrics inside rawPayload for diagnostic and seller auditing
        $enrichedPayload = $rawPayload;
        if ($sellerRating !== null) {
            $enrichedPayload['seller_feedback_percentage'] = $sellerRating;
        }

        if (isset($rawPayload['seller']['feedbackScore'])) {
            $enrichedPayload['seller_feedback_score'] = (int) $rawPayload['seller']['feedbackScore'];
        } elseif (isset($rawPayload['feedback_score'])) {
            $enrichedPayload['seller_feedback_score'] = (int) $rawPayload['feedback_score'];
        }

        return new ExternalProductDto(
            source: 'ebay',
            externalId: $externalId,
            title: $title,
            price: $priceVal,
            currency: strtoupper($currencyVal),
            url: $url,
            description: $description,
            brand: $brand,
            originalPrice: isset($rawPayload['original_price']) ? (float) $rawPayload['original_price'] : null,
            rating: $rating,
            reviewsCount: $reviewsCount,
            supplierName: $sellerUsername,
            minOrderQuantity: 1,
            imageUrl: $imageUrl,
            isAvailable: $isAvailable,
            categorySlug: $categorySlug,
            condition: $condition,
            authenticityGuaranteed: $authenticityGuaranteed,
            sellerRating: $sellerRating,
            affiliateUrl: $affiliateUrl,
            rawPayload: $enrichedPayload
        );
    }
}
