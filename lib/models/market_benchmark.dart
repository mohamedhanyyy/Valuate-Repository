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
          city: 'Giza (6th of October)',
          country: 'Egypt',
          flag: '🇪🇬',
          currency: 'EGP',
          avgLandCostSqm: 22000,
          resConstructionSqm: 19000,
          comConstructionSqm: 27000,
          avgSalePriceSqm: 54000,
          avgRentalYieldPct: 9.2,
          yoyGrowthPct: 21.0,
          marketSentiment: 'Active Expansion',
        ),
      ];
}
