class MarketBenchmark {
  final String city;
  final String country;
  final String flag;
  final String currency;
  final double avgLandCostSqm;
  final double resConstructionSqm;
  final double comConstructionSqm;
  final double avgSalePriceSqm;
  final double avgRentalYieldPct;
  final double yoyGrowthPct;
  final String marketSentiment; // Bullish, Stable, Expanding

  MarketBenchmark({
    required this.city,
    required this.country,
    required this.flag,
    required this.currency,
    required this.avgLandCostSqm,
    required this.resConstructionSqm,
    required this.comConstructionSqm,
    required this.avgSalePriceSqm,
    required this.avgRentalYieldPct,
    required this.yoyGrowthPct,
    required this.marketSentiment,
  });

  static List<MarketBenchmark> get regionalData => [
        MarketBenchmark(
          city: 'Riyadh',
          country: 'Saudi Arabia',
          flag: '🇸🇦',
          currency: 'SAR',
          avgLandCostSqm: 4200,
          resConstructionSqm: 3800,
          comConstructionSqm: 5200,
          avgSalePriceSqm: 9400,
          avgRentalYieldPct: 8.4,
          yoyGrowthPct: 12.8,
          marketSentiment: 'Expanding / High Demand',
        ),
        MarketBenchmark(
          city: 'Dubai',
          country: 'United Arab Emirates',
          flag: '🇦🇪',
          currency: 'AED',
          avgLandCostSqm: 5800,
          resConstructionSqm: 4500,
          comConstructionSqm: 6200,
          avgSalePriceSqm: 14200,
          avgRentalYieldPct: 7.9,
          yoyGrowthPct: 15.2,
          marketSentiment: 'Bullish / Peak Volume',
        ),
        MarketBenchmark(
          city: 'Jeddah',
          country: 'Saudi Arabia',
          flag: '🇸🇦',
          currency: 'SAR',
          avgLandCostSqm: 3200,
          resConstructionSqm: 3400,
          comConstructionSqm: 4600,
          avgSalePriceSqm: 7200,
          avgRentalYieldPct: 7.1,
          yoyGrowthPct: 8.6,
          marketSentiment: 'Steady Growth',
        ),
        MarketBenchmark(
          city: 'Abu Dhabi',
          country: 'United Arab Emirates',
          flag: '🇦🇪',
          currency: 'AED',
          avgLandCostSqm: 4100,
          resConstructionSqm: 4200,
          comConstructionSqm: 5600,
          avgSalePriceSqm: 11800,
          avgRentalYieldPct: 7.4,
          yoyGrowthPct: 9.4,
          marketSentiment: 'Stable / High Yield',
        ),
        MarketBenchmark(
          city: 'Cairo (New Cairo)',
          country: 'Egypt',
          flag: '🇪🇬',
          currency: 'EGP',
          avgLandCostSqm: 28000,
          resConstructionSqm: 22000,
          comConstructionSqm: 31000,
          avgSalePriceSqm: 68000,
          avgRentalYieldPct: 9.8,
          yoyGrowthPct: 24.5,
          marketSentiment: 'Inflation Hedge / Strong Sales',
        ),
        MarketBenchmark(
          city: 'Doha',
          country: 'Qatar',
          flag: '🇶🇦',
          currency: 'QAR',
          avgLandCostSqm: 4800,
          resConstructionSqm: 4600,
          comConstructionSqm: 6100,
          avgSalePriceSqm: 12500,
          avgRentalYieldPct: 6.8,
          yoyGrowthPct: 5.8,
          marketSentiment: 'Consolidation',
        ),
      ];
}
