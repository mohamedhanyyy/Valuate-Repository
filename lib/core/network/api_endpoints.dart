class ApiEndpoints {
  static const String baseUrl = 'https://valuate.gateways.finance';

  // Auth endpoints
  static const String loginEn = '/en/login';
  static const String loginAr = '/ar/login';
  static const String registerEn = '/en/register';
  static const String registerAr = '/ar/register';
  static const String passwordReset = '/en/password/reset';
  static const String profile = '/api/v1/user/profile';

  // Feasibility & Projects API endpoints
  static const String feasibilityCalculate = '/api/v1/feasibility/calculate';
  static const String projects = '/api/v1/projects';
  static const String marketBenchmarks = '/api/v1/market/benchmarks';
}
