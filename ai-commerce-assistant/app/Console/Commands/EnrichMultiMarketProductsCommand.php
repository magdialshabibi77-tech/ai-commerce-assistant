<?php

namespace App\Console\Commands;

use App\Services\Product\MultiMarketEnricherService;
use Illuminate\Console\Command;

class EnrichMultiMarketProductsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'commerce:enrich-markets';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Automatically enrich all canonical products with multi-market offers from Jarir, Noon, eXtra, Amazon, Alibaba, and AliExpress';

    /**
     * Execute the console command.
     */
    public function handle(MultiMarketEnricherService $enricher): int
    {
        $this->info('Starting multi-market product enrichment...');

        $count = $enricher->enrichAll();

        $this->info("Successfully enriched all {$count} canonical products with multi-market store listings!");

        return Command::SUCCESS;
    }
}
