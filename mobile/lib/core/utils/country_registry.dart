class CountryData {
  final String name;
  final String code;
  const CountryData({required this.name, required this.code});
}

class CountryRegistry {
  static const List<CountryData> allCountries = [
    CountryData(name: "Cameroun", code: "+237"),
    CountryData(name: "Côte d'Ivoire", code: "+225"),
    CountryData(name: "Sénégal", code: "+221"),
    CountryData(name: "Gabon", code: "+241"),
    CountryData(name: "Congo (Brazzaville)", code: "+242"),
    CountryData(name: "Congo (RDC)", code: "+243"),
    CountryData(name: "Tchad", code: "+235"),
    CountryData(name: "Centrafrique", code: "+236"),
    CountryData(name: "Mali", code: "+223"),
    CountryData(name: "Burkina Faso", code: "+226"),
    CountryData(name: "Togo", code: "+228"),
    CountryData(name: "Bénin", code: "+229"),
    CountryData(name: "Guinée", code: "+224"),
    CountryData(name: "Guinée Équatoriale", code: "+240"),
    CountryData(name: "Rwanda", code: "+250"),
    CountryData(name: "Burundi", code: "+257"),
    CountryData(name: "Niger", code: "+227"),
    CountryData(name: "Nigéria", code: "+234"),
    CountryData(name: "Ghana", code: "+233"),
    CountryData(name: "Kenya", code: "+254"),
    CountryData(name: "Afrique du Sud", code: "+27"),
    CountryData(name: "Maroc", code: "+212"),
    CountryData(name: "Algérie", code: "+213"),
    CountryData(name: "Tunisie", code: "+216"),
    CountryData(name: "Égypte", code: "+20"),
    CountryData(name: "France", code: "+33"),
    CountryData(name: "Belgique", code: "+32"),
    CountryData(name: "Suisse", code: "+41"),
    CountryData(name: "Canada / USA", code: "+1"),
    CountryData(name: "Royaume-Uni", code: "+44"),
    CountryData(name: "Allemagne", code: "+49"),
    CountryData(name: "Italie", code: "+39"),
    CountryData(name: "Espagne", code: "+34"),
    CountryData(name: "Portugal", code: "+351"),
    CountryData(name: "Brésil", code: "+55"),
    CountryData(name: "Chine", code: "+86"),
    CountryData(name: "Inde", code: "+91"),
    CountryData(name: "Émirats Arabes Unis", code: "+971"),
  ];

  static CountryData? findByCode(String rawCode) {
    String clean = rawCode.replaceAll(RegExp(r'[^\d+]'), '').trim();
    if (!clean.startsWith('+')) {
      clean = '+$clean';
    }
    for (var country in allCountries) {
      if (clean == country.code) {
        return country;
      }
    }
    // Try prefix matching if exact match not found
    for (var country in allCountries) {
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
