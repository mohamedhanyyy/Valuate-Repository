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
      bool matchesFilter = selectedFilter == 'All' || selectedFilter == 'الكل';
      if (!matchesFilter) {
        final sf = selectedFilter.toLowerCase();
        final at = s.assetType.toLowerCase();
        if (at == sf) {
          matchesFilter = true;
        } else if ((sf == 'residential' || sf == 'سكني') && (at == 'residential' || at == 'سكني')) {
          matchesFilter = true;
        } else if ((sf == 'commercial' || sf == 'تجاري') && (at == 'commercial' || at == 'تجاري')) {
          matchesFilter = true;
        } else if ((sf == 'hospitality' || sf == 'ضيافة' || sf == 'فندقي') && (at == 'hospitality' || at == 'ضيافة' || at == 'فندقي')) {
          matchesFilter = true;
        } else if ((sf == 'industrial' || sf == 'صناعي') && (at == 'industrial' || at == 'صناعي')) {
          matchesFilter = true;
        } else if ((sf == 'mixeduse' || sf == 'استخدام مختلط' || sf == 'متعدد الاستخدامات') && (at == 'mixeduse' || at == 'استخدام مختلط' || at == 'متعدد الاستخدامات')) {
          matchesFilter = true;
        }
      }

      final q = searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.location.toLowerCase().contains(q) ||
          s.developerName.toLowerCase().contains(q) ||
          s.country.toLowerCase().contains(q) ||
          s.projectType.toLowerCase().contains(q);

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
