import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/market_benchmark.dart';
import 'market_state.dart';

class MarketCubit extends Cubit<MarketState> {
  MarketCubit() : super(MarketInitial());

  void loadBenchmarks() {
    emit(MarketLoading());
    try {
      final list = MarketBenchmark.regionalData;
      emit(MarketLoaded(
        benchmarks: list,
        selectedCity: list.first,
      ));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }

  void selectCity(MarketBenchmark benchmark) {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      emit(currentState.copyWith(selectedCity: benchmark));
    }
  }
}
