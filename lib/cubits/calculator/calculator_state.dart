import '../../models/feasibility_study.dart';

class CalculatorState {
  final FeasibilityStudy study;
  final bool isCalculating;
  final String activeScenario; // 'Base', 'Bull', 'Bear'
  final String? voiceTranscript;

  CalculatorState({
    required this.study,
    this.isCalculating = false,
    this.activeScenario = 'Base',
    this.voiceTranscript,
  });

  FeasibilityStudy get activeStudy {
    final scenarios = study.getScenarios();
    return scenarios[activeScenario] ?? study;
  }

  CalculatorState copyWith({
    FeasibilityStudy? study,
    bool? isCalculating,
    String? activeScenario,
    String? voiceTranscript,
    bool clearVoiceTranscript = false,
  }) {
    return CalculatorState(
      study: study ?? this.study,
      isCalculating: isCalculating ?? this.isCalculating,
      activeScenario: activeScenario ?? this.activeScenario,
      voiceTranscript: clearVoiceTranscript
          ? null
          : (voiceTranscript ?? this.voiceTranscript),
    );
  }
}
