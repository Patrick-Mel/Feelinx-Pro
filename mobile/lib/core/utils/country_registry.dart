class CountryData {
  final String name;
  final String code;
  final String iso;
  const CountryData({required this.name, required this.code, this.iso = ""});
}

class CountryRegistry {
  static const List<CountryData> allCountries = [
    // Afrique
    CountryData(name: "Cameroun", code: "+237", iso: "CM"),
    CountryData(name: "Côte d'Ivoire", code: "+225", iso: "CI"),
    CountryData(name: "Sénégal", code: "+221", iso: "SN"),
    CountryData(name: "Gabon", code: "+241", iso: "GA"),
    CountryData(name: "Congo (Brazzaville)", code: "+242", iso: "CG"),
    CountryData(name: "Congo (RDC)", code: "+243", iso: "CD"),
    CountryData(name: "Tchad", code: "+235", iso: "TD"),
    CountryData(name: "Centrafrique", code: "+236", iso: "CF"),
    CountryData(name: "Mali", code: "+223", iso: "ML"),
    CountryData(name: "Burkina Faso", code: "+226", iso: "BF"),
    CountryData(name: "Togo", code: "+228", iso: "TG"),
    CountryData(name: "Bénin", code: "+229", iso: "BJ"),
    CountryData(name: "Guinée", code: "+224", iso: "GN"),
    CountryData(name: "Guinée Équatoriale", code: "+240", iso: "GQ"),
    CountryData(name: "Rwanda", code: "+250", iso: "RW"),
    CountryData(name: "Burundi", code: "+257", iso: "BI"),
    CountryData(name: "Niger", code: "+227", iso: "NE"),
    CountryData(name: "Nigéria", code: "+234", iso: "NG"),
    CountryData(name: "Ghana", code: "+233", iso: "GH"),
    CountryData(name: "Kenya", code: "+254", iso: "KE"),
    CountryData(name: "Afrique du Sud", code: "+27", iso: "ZA"),
    CountryData(name: "Maroc", code: "+212", iso: "MA"),
    CountryData(name: "Algérie", code: "+213", iso: "DZ"),
    CountryData(name: "Tunisie", code: "+216", iso: "TN"),
    CountryData(name: "Égypte", code: "+20", iso: "EG"),
    CountryData(name: "Éthiopie", code: "+251", iso: "ET"),
    CountryData(name: "Tanzanie", code: "+255", iso: "TZ"),
    CountryData(name: "Ouganda", code: "+256", iso: "UG"),
    CountryData(name: "Angola", code: "+244", iso: "AO"),
    CountryData(name: "Mozambique", code: "+258", iso: "MZ"),
    CountryData(name: "Madagascar", code: "+261", iso: "MG"),
    CountryData(name: "Maurice", code: "+230", iso: "MU"),
    CountryData(name: "Cap-Vert", code: "+238", iso: "CV"),
    CountryData(name: "Mauritanie", code: "+222", iso: "MR"),
    CountryData(name: "Soudan", code: "+249", iso: "SD"),
    CountryData(name: "Libye", code: "+218", iso: "LY"),
    CountryData(name: "Zambie", code: "+260", iso: "ZM"),
    CountryData(name: "Zimbabwe", code: "+263", iso: "ZW"),
    CountryData(name: "Comores", code: "+269", iso: "KM"),
    CountryData(name: "Djibouti", code: "+253", iso: "DJ"),

    // Europe
    CountryData(name: "France", code: "+33", iso: "FR"),
    CountryData(name: "Belgique", code: "+32", iso: "BE"),
    CountryData(name: "Suisse", code: "+41", iso: "CH"),
    CountryData(name: "Royaume-Uni", code: "+44", iso: "GB"),
    CountryData(name: "Allemagne", code: "+49", iso: "DE"),
    CountryData(name: "Italie", code: "+39", iso: "IT"),
    CountryData(name: "Espagne", code: "+34", iso: "ES"),
    CountryData(name: "Portugal", code: "+351", iso: "PT"),
    CountryData(name: "Pays-Bas", code: "+31", iso: "NL"),
    CountryData(name: "Luxembourg", code: "+352", iso: "LU"),
    CountryData(name: "Grèce", code: "+30", iso: "GR"),
    CountryData(name: "Suède", code: "+46", iso: "SE"),
    CountryData(name: "Norvège", code: "+47", iso: "NO"),
    CountryData(name: "Danemark", code: "+45", iso: "DK"),
    CountryData(name: "Finlande", code: "+358", iso: "FI"),
    CountryData(name: "Pologne", code: "+48", iso: "PL"),
    CountryData(name: "Roumanie", code: "+40", iso: "RO"),
    CountryData(name: "Autriche", code: "+43", iso: "AT"),
    CountryData(name: "Irlande", code: "+353", iso: "IE"),
    CountryData(name: "République Tchèque", code: "+420", iso: "CZ"),
    CountryData(name: "Hongrie", code: "+36", iso: "HU"),
    CountryData(name: "Russie", code: "+7", iso: "RU"),
    CountryData(name: "Turquie", code: "+90", iso: "TR"),
    CountryData(name: "Ukraine", code: "+380", iso: "UA"),

    // Amériques
    CountryData(name: "États-Unis / Canada", code: "+1", iso: "US"),
    CountryData(name: "Brésil", code: "+55", iso: "BR"),
    CountryData(name: "Mexique", code: "+52", iso: "MX"),
    CountryData(name: "Argentine", code: "+54", iso: "AR"),
    CountryData(name: "Colombie", code: "+57", iso: "CO"),
    CountryData(name: "Chili", code: "+56", iso: "CL"),
    CountryData(name: "Pérou", code: "+51", iso: "PE"),
    CountryData(name: "Venezuela", code: "+58", iso: "VE"),
    CountryData(name: "Haïti", code: "+509", iso: "HT"),
    CountryData(name: "Guadeloupe / Martinique", code: "+590", iso: "GP"),

    // Asie & Moyen-Orient
    CountryData(name: "Chine", code: "+86", iso: "CN"),
    CountryData(name: "Inde", code: "+91", iso: "IN"),
    CountryData(name: "Japon", code: "+81", iso: "JP"),
    CountryData(name: "Corée du Sud", code: "+82", iso: "KR"),
    CountryData(name: "Émirats Arabes Unis", code: "+971", iso: "AE"),
    CountryData(name: "Arabie Saoudite", code: "+966", iso: "SA"),
    CountryData(name: "Qatar", code: "+974", iso: "QA"),
    CountryData(name: "Koweït", code: "+965", iso: "KW"),
    CountryData(name: "Liban", code: "+961", iso: "LB"),
    CountryData(name: "Israël", code: "+972", iso: "IL"),
    CountryData(name: "Thaïlande", code: "+66", iso: "TH"),
    CountryData(name: "Viêt Nam", code: "+84", iso: "VN"),
    CountryData(name: "Indonésie", code: "+62", iso: "ID"),
    CountryData(name: "Malaisie", code: "+60", iso: "MY"),
    CountryData(name: "Singapour", code: "+65", iso: "SG"),
    CountryData(name: "Pakistan", code: "+92", iso: "PK"),

    // Océanie
    CountryData(name: "Australie", code: "+61", iso: "AU"),
    CountryData(name: "Nouvelle-Zélande", code: "+64", iso: "NZ"),
  ];

  static String normalizeCode(String rawCode) {
    String clean = rawCode.replaceAll(RegExp(r'[^\d+]'), '').trim();
    if (clean.startsWith('00')) {
      clean = '+${clean.substring(2)}';
    } else if (!clean.startsWith('+') && clean.isNotEmpty) {
      clean = '+$clean';
    }
    return clean;
  }

  static CountryData? findByCode(String rawCode) {
    String clean = normalizeCode(rawCode);
    if (clean.isEmpty || clean == '+') return null;

    // 1. Exact match
    for (var country in allCountries) {
      if (clean == country.code) {
        return country;
      }
    }

    // 2. Prefix match (e.g. user typed +237690 or +336)
    // Sort by code length descending to match +237 before +23
    final sorted = List<CountryData>.from(allCountries)
      ..sort((a, b) => b.code.length.compareTo(a.code.length));

    for (var country in sorted) {
      if (clean.startsWith(country.code)) {
        return country;
      }
    }

    return null;
  }

  static bool isValidCode(String rawCode) {
    return findByCode(rawCode) != null;
  }
}
