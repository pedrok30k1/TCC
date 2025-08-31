class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu email';
    }
    
    // Regex para validar email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, digite um email válido';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite sua senha';
    }
    
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, digite $fieldName';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, digite seu nome';
    }
    
    if (value.trim().length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu telefone';
    }
    
    // Remove caracteres não numéricos
    final phoneDigits = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (phoneDigits.length < 10) {
      return 'Por favor, digite um telefone válido';
    }
    
    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu CPF';
    }
    
    // Remove caracteres não numéricos
    final cpfDigits = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cpfDigits.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Validação básica de CPF (verificação de dígitos repetidos)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfDigits)) {
      return 'CPF inválido';
    }
    
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite sua data de nascimento';
    }
    
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      final age = now.year - date.year;
      
      if (age < 0 || age > 120) {
        return 'Data de nascimento inválida';
      }
      
      return null;
    } catch (e) {
      return 'Formato de data inválido (YYYY-MM-DD)';
    }
  }

  // Converte data em formato brasileiro DD/MM/AAAA para DateTime
  static DateTime? parseBrazilianDate(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (year < 1900 || year > DateTime.now().year + 1) return null;
    if (month < 1 || month > 12) return null;

    // Usa DateTime para validar dias válidos do mês (inclui bissexto)
    try {
      final parsed = DateTime(year, month, day);
      if (parsed.day != day || parsed.month != month || parsed.year != year) {
        return null;
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  // Valida data no formato DD/MM/AAAA. Por padrão é obrigatório.
  static String? validateBrazilianDate(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Por favor, digite sua data de nascimento' : null;
    }

    final parsed = parseBrazilianDate(value);
    if (parsed == null) {
      return 'Data inválida (use DD/MM/AAAA)';
    }

    final now = DateTime.now();
    int age = now.year - parsed.year;
    if (now.month < parsed.month || (now.month == parsed.month && now.day < parsed.day)) {
      age -= 1;
    }

    if (age < 0 || age > 120) {
      return 'Data de nascimento inválida';
    }

    return null;
  }
} 