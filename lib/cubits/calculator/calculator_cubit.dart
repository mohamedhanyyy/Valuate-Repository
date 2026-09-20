import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/feasibility_study.dart';
import 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit()
      : super(
          CalculatorState(
            study: FeasibilityStudy(
              id: 'initial_study',
              title: 'Al-Narjis Residential Towers',
              assetType: 'Residential',
              location: 'Riyadh, Saudi Arabia',
              landArea: 3500.0,
              far: 2.8,
              efficiencyPct: 85.0,
              landCost: 14700000.0, // 3,500m² * 4,200 SAR/m²
              constructionCostPerSqm: 3900.0,
              softCostPct: 7.0,
              contingencyPct: 5.0,
              expectedRevenuePerSqm: 9500.0,
              developmentMonths: 24,
              currency: 'SAR',
            ),
          ),
        );

  void updateAssetType(String assetType) {
    emit(state.copyWith(study: state.study.copyWith(assetType: assetType)));
  }

  void updateLocation(String location) {
    emit(state.copyWith(study: state.study.copyWith(location: location)));
  }

  void updateTitle(String title) {
    emit(state.copyWith(study: state.study.copyWith(title: title)));
  }

  void updateLandArea(double landArea) {
    emit(state.copyWith(study: state.study.copyWith(landArea: landArea)));
  }

  void updateFar(double far) {
    emit(state.copyWith(study: state.study.copyWith(far: far)));
  }

  void updateEfficiencyPct(double efficiencyPct) {
    emit(state.copyWith(study: state.study.copyWith(efficiencyPct: efficiencyPct)));
  }

  void updateLandCost(double landCost) {
    emit(state.copyWith(study: state.study.copyWith(landCost: landCost)));
  }

  void updateConstructionCostPerSqm(double cost) {
    emit(state.copyWith(study: state.study.copyWith(constructionCostPerSqm: cost)));
  }

  void updateSoftCostPct(double pct) {
    emit(state.copyWith(study: state.study.copyWith(softCostPct: pct)));
  }

  void updateContingencyPct(double pct) {
    emit(state.copyWith(study: state.study.copyWith(contingencyPct: pct)));
  }

  void updateExpectedRevenuePerSqm(double revenue) {
    emit(state.copyWith(study: state.study.copyWith(expectedRevenuePerSqm: revenue)));
  }

  void updateDevelopmentMonths(int months) {
    emit(state.copyWith(study: state.study.copyWith(developmentMonths: months)));
  }

  void updateCurrency(String currency) {
    emit(state.copyWith(study: state.study.copyWith(currency: currency)));
  }

  void setScenario(String scenario) {
    emit(state.copyWith(activeScenario: scenario));
  }

  void loadStudy(FeasibilityStudy study, {String? voiceTranscript}) {
    emit(
      state.copyWith(
        study: study,
        activeScenario: 'Base',
        voiceTranscript: voiceTranscript,
        clearVoiceTranscript: voiceTranscript == null,
      ),
    );
  }

  void clearVoiceTranscript() {
    emit(state.copyWith(clearVoiceTranscript: true));
  }

  void resetToDefaults() {
    emit(
      CalculatorState(
        study: FeasibilityStudy(
          id: 'study_${DateTime.now().millisecondsSinceEpoch}',
          title: 'New Feasibility Model',
          assetType: 'Residential',
          location: 'Riyadh, Saudi Arabia',
          landArea: 2500.0,
          far: 2.5,
          efficiencyPct: 85.0,
          landCost: 10000000.0,
          constructionCostPerSqm: 3800.0,
          softCostPct: 7.0,
          contingencyPct: 5.0,
          expectedRevenuePerSqm: 9200.0,
          developmentMonths: 24,
          currency: 'SAR',
        ),
      ),
    );
  }
}
