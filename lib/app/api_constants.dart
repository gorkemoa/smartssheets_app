class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://smart-sheet.getsmarty.com.tr/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Brands
  static const String brands = '/brands';
  static String brandById(int id) => '/brands/$id';
}
