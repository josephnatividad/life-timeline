import 'package:life_timeline/features/insights/domain/life_query_models.dart';

abstract final class LifeQueryLanguage {
  static const supportedExamples = [
    'How many phones have I owned?',
    'Which documents expire this year?',
    'What happened last year?',
    'What was my previous laptop?',
  ];

  static const Map<LifeEntityCategory, Set<String>> entityAliases = {
    LifeEntityCategory.phone: {
      'phone',
      'phones',
      'smartphone',
      'smartphones',
      'mobile phone',
      'mobile phones',
    },
    LifeEntityCategory.computer: {
      'computer',
      'computers',
      'laptop',
      'laptops',
      'desktop',
      'desktops',
      'tablet',
      'tablets',
    },
    LifeEntityCategory.vehicle: {
      'vehicle',
      'vehicles',
      'car',
      'cars',
      'motorcycle',
      'motorcycles',
      'truck',
      'trucks',
    },
    LifeEntityCategory.document: {
      'document',
      'documents',
      'passport',
      'passports',
      'license',
      'licenses',
      'warranty',
      'warranties',
    },
    LifeEntityCategory.place: {
      'place',
      'places',
      'country',
      'countries',
      'city',
      'cities',
      'destination',
      'destinations',
    },
    LifeEntityCategory.employer: {
      'job',
      'jobs',
      'career',
      'employer',
      'employers',
      'company',
      'companies',
      'work',
    },
  };

  static const Map<LifeEventKind, Set<String>> eventAliases = {
    LifeEventKind.acquisition: {
      'bought',
      'buy',
      'purchased',
      'purchase',
      'got',
      'acquired',
      'started using',
    },
    LifeEventKind.expiry: {
      'expires',
      'expire',
      'expired',
      'expiration',
      'renewal',
      'renewed',
      'valid until',
    },
    LifeEventKind.travel: {
      'travel',
      'traveled',
      'travelled',
      'trip',
      'trips',
      'visited',
      'visit',
      'flew',
    },
    LifeEventKind.careerStart: {
      'started',
      'joined',
      'hired',
      'began',
      'career',
      'job',
      'work',
    },
    LifeEventKind.replacement: {
      'replaced',
      'replacement',
      'upgraded',
      'switched',
    },
    LifeEventKind.disposal: {
      'sold',
      'disposed',
      'retired',
      'gave away',
      'replaced',
    },
  };

  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static LifeEntityCategory? categoryIn(String normalized) {
    for (final entry in entityAliases.entries) {
      if (entry.value.any((alias) => _containsPhrase(normalized, alias))) {
        return entry.key;
      }
    }
    return null;
  }

  static bool mentionsEvent(String normalized, LifeEventKind kind) =>
      eventAliases[kind]!.any((term) => _containsPhrase(normalized, term));

  static int? explicitYear(String normalized) {
    final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(normalized);
    return match == null ? null : int.parse(match.group(0)!);
  }

  static int requestedYear(String normalized, DateTime now) {
    final explicit = explicitYear(normalized);
    if (explicit != null) return explicit;
    if (_containsPhrase(normalized, 'last year')) return now.year - 1;
    return now.year;
  }

  static String categoryLabel(LifeEntityCategory value) => switch (value) {
    LifeEntityCategory.phone => 'phone',
    LifeEntityCategory.computer => 'computer',
    LifeEntityCategory.vehicle => 'vehicle',
    LifeEntityCategory.document => 'document',
    LifeEntityCategory.place => 'place',
    LifeEntityCategory.employer => 'career history',
  };

  static String pluralCategoryLabel(LifeEntityCategory value) =>
      switch (value) {
        LifeEntityCategory.phone => 'phones',
        LifeEntityCategory.computer => 'computers',
        LifeEntityCategory.vehicle => 'vehicles',
        LifeEntityCategory.document => 'documents',
        LifeEntityCategory.place => 'places',
        LifeEntityCategory.employer => 'career history',
      };

  static bool _containsPhrase(String normalized, String phrase) =>
      ' $normalized '.contains(' ${normalize(phrase)} ');
}
