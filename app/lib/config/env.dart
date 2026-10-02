/// Build-time environment, from `--dart-define-from-file=config/<brand>.<env>.json`.
///
/// Every value is read with `const ...fromEnvironment`: it is only guaranteed
/// to work in a const context. The define files are flat (key → string), and
/// hold public values only: anything in them ends up in the binary.
abstract final class Env {
  /// `dev`, `staging` or `prod`.
  static const String name = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// Backend base URL. Empty selects the in-memory fakes (no backend yet).
  static const String apiUrl = String.fromEnvironment('API_URL');

  /// Sentry DSN. Empty disables crash reporting.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const bool isProd = name == 'prod';
  static const bool hasBackend = apiUrl != '';
}
