<?php

namespace App\Services\Product;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ProductImageService
{
    /**
     * Download and store a remote product image locally in public storage to bypass hotlink blocks.
     *
     * @param string|null $remoteUrl
     * @return string|null Local asset URL or original URL, or fallback
     */
    public function downloadAndStore(?string $remoteUrl): ?string
    {
        if (empty($remoteUrl) || ! filter_var($remoteUrl, FILTER_VALIDATE_URL)) {
            return null;
        }

        // Avoid actual external network I/O in automated tests
        if (app()->runningUnitTests()) {
            return $remoteUrl;
        }

        try {
            // Check if already downloaded by hashing the remote URL
            $urlHash = md5($remoteUrl);
            $extension = pathinfo(parse_url($remoteUrl, PHP_URL_PATH) ?? '', PATHINFO_EXTENSION);
            if (! in_array(strtolower($extension), ['jpg', 'jpeg', 'png', 'webp', 'gif'], true)) {
                $extension = 'jpg';
            }

            $storagePath = "products/{$urlHash}.{$extension}";

            if (Storage::disk('public')->exists($storagePath)) {
                return Storage::disk('public')->url($storagePath);
            }

            // Download image with realistic browser User-Agent to bypass Anti-hotlink
            $response = Http::timeout(4)
                ->withHeaders([
                    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                    'Accept' => 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                ])
                ->get($remoteUrl);

            if ($response->successful() && strlen($response->body()) > 500) {
                Storage::disk('public')->put($storagePath, $response->body());
                return Storage::disk('public')->url($storagePath);
            }
        } catch (\Throwable $e) {
            Log::warning('product_image.download_failed', [
                'url' => $remoteUrl,
                'error' => $e->getMessage(),
            ]);
        }

        // Fallback to original URL if download fails
        return $remoteUrl;
    }

    /**
     * Get a curated high-resolution category fallback image when no photo is provided.
     *
     * @param string|null $categorySlugOrName
     * @return string
     */
    public function getCategoryFallbackImage(?string $categorySlugOrName = null): string
    {
        $category = strtolower(trim((string) $categorySlugOrName));

        if (str_contains($category, 'watch') || str_contains($category, 'ساعة')) {
            return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80';
        }

        if (str_contains($category, 'phone') || str_contains($category, 'هاتف') || str_contains($category, 'جوال')) {
            return 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&auto=format&fit=crop&q=80';
        }

        if (str_contains($category, 'audio') || str_contains($category, 'headphone') || str_contains($category, 'سماع')) {
            return 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80';
        }

        if (str_contains($category, 'laptop') || str_contains($category, 'computer') || str_contains($category, 'حاسوب')) {
            return 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&auto=format&fit=crop&q=80';
        }

        if (str_contains($category, 'perfume') || str_contains($category, 'fragrance') || str_contains($category, 'عطر')) {
            return 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=600&auto=format&fit=crop&q=80';
        }

        // Default premium commerce fallback
        return 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&auto=format&fit=crop&q=80';
    }
}
