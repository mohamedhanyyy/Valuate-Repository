import '../../models/market_benchmark.dart';

abstract class MarketState {}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final List<MarketBenchmark> benchmarks;
  final MarketBenchmark selectedCity;

  MarketLoaded({
    required this.benchmarks,
    required this.selectedCity,
  });

  MarketLoaded copyWith({
    List<MarketBenchmark>? benchmarks,
    MarketBenchmark? selectedCity,
  }) {
    return MarketLoaded(
      benchmarks: benchmarks ?? this.benchmarks,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }
}

class MarketError extends MarketState {
  final String message;
  MarketError(this.message);
}
