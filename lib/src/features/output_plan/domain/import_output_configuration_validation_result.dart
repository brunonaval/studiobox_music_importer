import 'import_output_configuration.dart';

class ImportOutputConfigurationValidationResult {
  const ImportOutputConfigurationValidationResult({
    required this.configuration,
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  final ImportOutputConfiguration configuration;
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  bool get hasErrors => errors.isNotEmpty;

  bool get hasWarnings => warnings.isNotEmpty;
}
