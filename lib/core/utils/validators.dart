class Validators {
  Validators._();

  static String? email(
    String? value, {
    String? emptyMessage,
    String? invalidMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'E-posta adresi boş olamaz.';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return invalidMessage ?? 'Geçerli bir e-posta adresi girin.';
    }
    return null;
  }

  static String? password(
    String? value, {
    String? emptyMessage,
    String? tooShortMessage,
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage ?? 'Şifre boş olamaz.';
    }
    if (value.length < 6) {
      return tooShortMessage ?? 'Şifre en az 6 karakter olmalıdır.';
    }
    return null;
  }

  static String? passwordConfirmation(
    String? value,
    String? original, {
    String? emptyMessage,
    String? mismatchMessage,
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage ?? 'Şifre tekrarı boş olamaz.';
    }
    if (value != original) {
      return mismatchMessage ?? 'Şifreler eşleşmiyor.';
    }
    return null;
  }

  static String? name(
    String? value, {
    String? emptyMessage,
    String? tooShortMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Ad Soyad boş olamaz.';
    }
    if (value.trim().length < 2) {
      return tooShortMessage ?? 'Ad Soyad en az 2 karakter olmalıdır.';
    }
    return null;
  }

  static String? phone(
    String? value, {
    String? emptyMessage,
    String? invalidMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Telefon numarası boş olamaz.';
    }
    final regex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!regex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return invalidMessage ?? 'Geçerli bir telefon numarası girin.';
    }
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} boş olamaz.';
    }
    return null;
  }
}

