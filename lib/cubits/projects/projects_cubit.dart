import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/preferences_service.dart';
import '../../models/feasibility_study.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final PreferencesService preferencesService;
  final DioClient? dioClient;

  ProjectsCubit({
    required this.preferencesService,
    this.dioClient,
  }) : super(ProjectsInitial());

  void loadProjects() {
    emit(ProjectsLoading());
    try {
      final saved = preferencesService.getSavedProjects();
      List<FeasibilityStudy> list = [];

      if (saved.isNotEmpty) {
        list = saved.map((e) => FeasibilityStudy.fromJson(e)).toList();
      } else {
        // Seed initial realistic regional projects for immediate experience
        list = [
          FeasibilityStudy(
            id: 'prj_01',
            title: 'Al-Narjis Premium Residences',
            developerName: 'mohamed hany',
            assetType: 'Residential',
            projectType: 'Sell',
            country: 'Saudi Arabia',
            location: 'Riyadh, Saudi Arabia',
            landPaymentMode: 'Cash Payment',
            landArea: 4200,
            far: 3.0,
            efficiencyPct: 86,
            landCost: 17640000,
            constructionCostPerSqm: 4100,
            softCostPct: 7.5,
            contingencyPct: 5.0,
            expectedRevenuePerSqm: 10500,
            developmentMonths: 24,
            currency: 'SAR',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          FeasibilityStudy(
            id: 'prj_02',
            title: 'Business Bay Prime Offices',
            developerName: 'mohamed hany',
            assetType: 'Commercial',
            projectType: 'Rent',
            country: 'United Arab Emirates',
            location: 'Dubai, UAE',
            landPaymentMode: 'Revenue Share',
            landArea: 3200,
            far: 4.5,
            efficiencyPct: 82,
            landCost: 22400000,
            constructionCostPerSqm: 5800,
            softCostPct: 8.0,
            contingencyPct: 5.0,
            expectedRevenuePerSqm: 16800,
            developmentMonths: 30,
            currency: 'AED',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          FeasibilityStudy(
            id: 'prj_03',
            title: 'New Cairo Gated Villas',
            developerName: 'mohamed hany',
            assetType: 'Residential',
            projectType: 'Sell',
            country: 'Egypt',
            location: 'Cairo, Egypt',
            landPaymentMode: 'In Kind Share',
            landArea: 8000,
            far: 1.6,
            efficiencyPct: 90,
            landCost: 192000000,
            constructionCostPerSqm: 24000,
            softCostPct: 6.5,
            contingencyPct: 6.0,
            expectedRevenuePerSqm: 74000,
            developmentMonths: 28,
            currency: 'EGP',
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
          FeasibilityStudy(
            id: 'prj_04',
            title: 'Lusail Waterfront Mixed-Use',
            developerName: 'mohamed hany',
            assetType: 'MixedUse',
            projectType: 'Hold',
            country: 'Qatar',
            location: 'Doha, Qatar',
            landPaymentMode: 'Cash Payment',
            landArea: 5000,
            far: 3.5,
            efficiencyPct: 84,
            landCost: 28000000,
            constructionCostPerSqm: 6200,
            softCostPct: 8.0,
            contingencyPct: 5.0,
            expectedRevenuePerSqm: 14500,
            developmentMonths: 36,
            currency: 'QAR',
            createdAt: DateTime.now().subtract(const Duration(days: 14)),
          ),
        ];
        _persistProjects(list);
      }

      emit(ProjectsLoaded(studies: list));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> addOrUpdateStudy(FeasibilityStudy study) async {
    if (state is ProjectsLoaded) {
      final current = (state as ProjectsLoaded).studies;
      final existingIndex = current.indexWhere((s) => s.id == study.id);
      List<FeasibilityStudy> updated;
      if (existingIndex >= 0) {
        updated = List.from(current)..[existingIndex] = study;
      } else {
        updated = [study, ...current];
      }
      await _persistProjects(updated);
      emit(ProjectsLoaded(
        studies: updated,
        selectedFilter: (state as ProjectsLoaded).selectedFilter,
        searchQuery: (state as ProjectsLoaded).searchQuery,
      ));

      // Attempt remote backend sync asynchronously if dioClient is available
      if (dioClient != null) {
        try {
          await dioClient!.post(
            ApiEndpoints.projects,
            data: study.toJson(),
          );
        } catch (_) {
          // Keep local state intact if network/offline
        }
      }
    }
  }

  Future<void> deleteStudy(String studyId) async {
    if (state is ProjectsLoaded) {
      final current = (state as ProjectsLoaded).studies;
      final updated = current.where((s) => s.id != studyId).toList();
      await _persistProjects(updated);
      emit(ProjectsLoaded(
        studies: updated,
        selectedFilter: (state as ProjectsLoaded).selectedFilter,
        searchQuery: (state as ProjectsLoaded).searchQuery,
      ));
    }
  }

  void filterByAssetType(String assetType) {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsLoaded(
        studies: currentState.studies,
        selectedFilter: assetType,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  void searchProjects(String query) {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsLoaded(
        studies: currentState.studies,
        selectedFilter: currentState.selectedFilter,
        searchQuery: query,
      ));
    }
  }

  Future<void> _persistProjects(List<FeasibilityStudy> list) async {
    final raw = list.map((s) => s.toJson()).toList();
    await preferencesService.saveProjects(raw);
  }
}
