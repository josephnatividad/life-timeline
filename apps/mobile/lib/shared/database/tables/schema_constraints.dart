abstract final class SchemaValues {
  static const privacy = ['share_safe', 'personal', 'sensitive', 'never_share'];
  static const lifecycle = [
    'candidate',
    'confirmed',
    'archived',
    'soft_deleted',
  ];
  static const temporalPrecision = [
    'exact_date',
    'month',
    'year',
    'approximate',
    'range',
    'before',
    'after',
    'unknown',
  ];
}
