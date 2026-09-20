import '../../models/feasibility_study.dart';

abstract class ProjectsState {}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectsLoaded extends ProjectsState {
  final List<FeasibilityStudy> studies;
  final String selectedFilter; // 'All', 'Residential', 'Commercial', 'MixedUse'
  final String searchQuery;

  ProjectsLoaded({
    required this.studies,
    this.selectedFilter = 'All',
    this.searchQuery = '',
  });

  List<FeasibilityStudy> get filteredStudies {
    return studies.where((s) {
      final matchesFilter = selectedFilter == 'All' || s.assetType.toLowerCase() == selectedFilter.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.location.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  double get totalPipelineValue =>
      studies.fold(0.0, (acc, s) => acc + s.grossRevenue);

  double get totalInvestmentCost =>
      studies.fold(0.0, (acc, s) => acc + s.totalDevelopmentCost);

  double get averageRoi =>
      studies.isEmpty ? 0.0 : studies.fold(0.0, (acc, s) => acc + s.roiPct) / studies.length;

  int get goCount => studies.where((s) => s.verdict == VerdictType.go).length;
}

class ProjectsError extends ProjectsState {
  final String message;
  ProjectsError(this.message);
}
