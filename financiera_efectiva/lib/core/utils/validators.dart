class Validators {
  const Validators._();

  static String? required(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'Correo');
    if (requiredError != null) return requiredError;
    final hasValidShape = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(value!.trim());
    return hasValidShape ? null : 'Ingresa un correo válido';
  }

  static String? dni(String? value) {
    final requiredError = required(value, fieldName: 'DNI');
    if (requiredError != null) return requiredError;
    final normalizedValue = value!.trim();
    final hasValidShape = RegExp(r'^\d{8}$').hasMatch(normalizedValue);
    return hasValidShape ? null : 'El DNI debe tener 8 dígitos';
  }

  static String? password(String? value) {
    final requiredError = required(value, fieldName: 'Contraseña');
    if (requiredError != null) return requiredError;
    return value!.length >= 6 ? null : 'Mínimo 6 caracteres';
  }
}
