typedef JsonObject = Map<String, Object?>;

class AdminReadPage<T> {
  const AdminReadPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    this.ratingAverage,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final double? ratingAverage;

  factory AdminReadPage.fromJson(
    JsonObject json,
    T Function(JsonObject) parse,
  ) {
    final data = json['value'];
    if (data is! List<Object?>) {
      throw const FormatException('Respuesta paginada inválida.');
    }
    return AdminReadPage<T>(
      items: data.map((item) => parse(_object(item))).toList(growable: false),
      page: _int(json, 'page'),
      limit: _int(json, 'limit'),
      total: _int(json, 'total'),
      ratingAverage: _nullableDouble(json['ratingAverage']),
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isAccountActive,
    required this.createdAt,
    required this.updatedAt,
    required this.locality,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final bool isAccountActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? locality;
  final String? phone;
  final String? avatarUrl;
  String get fullName => '$firstName $lastName';

  factory AdminUser.fromJson(JsonObject json) {
    final locality = json['locality'];
    return AdminUser(
      id: _string(json, 'id'),
      firstName: _string(json, 'firstName'),
      lastName: _string(json, 'lastName'),
      email: _stringOrNull(json['email']),
      isAccountActive: _bool(json, 'isAccountActive'),
      createdAt: _date(json, 'createdAt'),
      updatedAt: _date(json, 'updatedAt'),
      locality: locality == null ? null : _string(_object(locality), 'name'),
      phone: _stringOrNull(json['phone']),
      avatarUrl: _stringOrNull(json['avatarUrl']),
    );
  }
}

class AdminProvider {
  const AdminProvider({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.accountActive,
    required this.locality,
    required this.primaryCategory,
    this.primaryCategoryId,
    required this.isAvailable,
    required this.shiftEndsAt,
    this.availabilityLocationSource,
    required this.lastPulseAt,
    required this.updatedAt,
    this.coverageRadiusKm,
    this.minPrice,
    this.chargesConsultation,
    this.consultationPrice,
    this.issuesInvoice,
    this.invoiceType,
    this.bio,
    this.experienceYears,
    this.isMatriculado,
    this.matriculaNumber,
    this.createdAt,
    this.secondaryCategories = const [],
    this.membershipTier,
    this.portfolioImagesCount,
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool accountActive;
  final String? locality;
  final String primaryCategory;
  final String? primaryCategoryId;
  final bool isAvailable;
  final DateTime? shiftEndsAt;
  final String? availabilityLocationSource;
  final DateTime lastPulseAt;
  final DateTime updatedAt;
  final int? coverageRadiusKm;
  final int? minPrice;
  final bool? chargesConsultation;
  final int? consultationPrice;
  final bool? issuesInvoice;
  final String? invoiceType;
  final String? bio;
  final int? experienceYears;
  final bool? isMatriculado;
  final String? matriculaNumber;
  final DateTime? createdAt;
  final List<String> secondaryCategories;
  final String? membershipTier;
  final int? portfolioImagesCount;
  String get fullName => '$firstName $lastName';

  factory AdminProvider.fromJson(JsonObject json) {
    final user = _object(json['user']);
    final primary = _object(json['primaryCategory']);
    final locality = user['locality'];
    final secondary = json['secondaryCategories'];
    final tier = json['membershipTier'];
    final count = json['_count'];
    final profileCount = count == null
        ? null
        : _object(count)['portfolioImages'];
    return AdminProvider(
      id: _string(json, 'id'),
      userId: _string(json, 'userId'),
      firstName: _string(user, 'firstName'),
      lastName: _string(user, 'lastName'),
      email: _stringOrNull(user['email']),
      phone: _stringOrNull(user['phone']),
      avatarUrl: _stringOrNull(user['avatarUrl']),
      accountActive: _bool(user, 'isAccountActive'),
      locality: locality == null ? null : _string(_object(locality), 'name'),
      primaryCategory: _string(primary, 'name'),
      primaryCategoryId: _stringOrNull(primary['id']),
      isAvailable: _bool(json, 'isAvailable'),
      shiftEndsAt: _dateOrNull(json['shiftEndsAt']),
      availabilityLocationSource: _stringOrNull(
        json['availabilityLocationSource'],
      ),
      lastPulseAt: _date(json, 'lastPulseAt'),
      updatedAt: _date(json, 'updatedAt'),
      coverageRadiusKm: _intOrNull(json['coverageRadiusKm']),
      minPrice: _intOrNull(json['minPrice']),
      chargesConsultation: _boolOrNull(json['chargesConsultation']),
      consultationPrice: _intOrNull(json['consultationPrice']),
      issuesInvoice: _boolOrNull(json['issuesInvoice']),
      invoiceType: _stringOrNull(json['invoiceType']),
      bio: _stringOrNull(json['bio']),
      experienceYears: _intOrNull(json['experienceYears']),
      isMatriculado: _boolOrNull(json['isMatriculado']),
      matriculaNumber: _stringOrNull(json['matriculaNumber']),
      createdAt: _dateOrNull(json['createdAt']),
      secondaryCategories: secondary is List<Object?>
          ? secondary
                .map(
                  (item) => _string(_object(_object(item)['category']), 'name'),
                )
                .toList(growable: false)
          : const [],
      membershipTier: tier == null ? null : _string(_object(tier), 'name'),
      portfolioImagesCount: _intOrNull(profileCount),
    );
  }
}

class AdminReview {
  const AdminReview({
    required this.id,
    required this.contactIntentId,
    required this.direction,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.author,
    this.targetName,
  });

  final String id;
  final String contactIntentId;
  final String direction;
  final int? rating;
  final String? comment;
  final DateTime createdAt;
  final String author;
  final String? targetName;

  factory AdminReview.fromJson(JsonObject json) {
    final author = _object(json['author']);
    final targetValue = json['target'];
    final target = targetValue == null ? null : _object(targetValue);
    return AdminReview(
      id: _string(json, 'id'),
      contactIntentId: _string(json, 'contactIntentId'),
      direction: _string(json, 'direction'),
      rating: _intOrNull(json['rating']),
      comment: _stringOrNull(json['comment']),
      createdAt: _date(json, 'createdAt'),
      author: '${_string(author, 'firstName')} ${_string(author, 'lastName')}',
      targetName: target == null
          ? null
          : '${_string(target, 'firstName')} ${_string(target, 'lastName')}',
    );
  }
}

class AdminPortfolioImage {
  const AdminPortfolioImage({
    required this.id,
    required this.providerProfileId,
    required this.imageUrl,
    required this.createdAt,
    required this.providerName,
  });

  final String id;
  final String providerProfileId;
  final String imageUrl;
  final DateTime createdAt;
  final String providerName;

  factory AdminPortfolioImage.fromJson(JsonObject json) {
    final provider = _object(json['provider']);
    final user = _object(provider['user']);
    return AdminPortfolioImage(
      id: _string(json, 'id'),
      providerProfileId: _string(json, 'providerProfileId'),
      imageUrl: _string(json, 'imageUrl'),
      createdAt: _date(json, 'createdAt'),
      providerName:
          '${_string(user, 'firstName')} ${_string(user, 'lastName')}',
    );
  }
}

class AdminContact {
  const AdminContact({
    required this.id,
    required this.clientName,
    required this.providerName,
    required this.category,
    required this.status,
    required this.scheduledFor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientName;
  final String providerName;
  final String category;
  final String status;
  final DateTime? scheduledFor;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AdminContact.fromJson(JsonObject json) {
    final client = _object(json['client']);
    final provider = _object(json['provider']);
    final providerUser = _object(provider['user']);
    final category = _object(json['category']);
    return AdminContact(
      id: _string(json, 'id'),
      clientName:
          '${_string(client, 'firstName')} ${_string(client, 'lastName')}',
      providerName:
          '${_string(providerUser, 'firstName')} ${_string(providerUser, 'lastName')}',
      category: _string(category, 'name'),
      status: _string(json, 'status'),
      scheduledFor: _dateOrNull(json['scheduledFor']),
      createdAt: _date(json, 'createdAt'),
      updatedAt: _date(json, 'updatedAt'),
    );
  }
}

class AdminMembershipTier {
  const AdminMembershipTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final int price;
  final DateTime createdAt;

  factory AdminMembershipTier.fromJson(JsonObject json) => AdminMembershipTier(
    id: _string(json, 'id'),
    name: _string(json, 'name'),
    description: _stringOrNull(json['description']),
    price: _int(json, 'price'),
    createdAt: _date(json, 'createdAt'),
  );
}

JsonObject _object(Object? value) {
  if (value is JsonObject) return value;
  throw const FormatException('Objeto de respuesta inválido.');
}

String _string(JsonObject json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Campo requerido inválido: $key');
}

String? _stringOrNull(Object? value) => value == null
    ? null
    : value is String
    ? value
    : throw const FormatException('Campo de texto inválido.');

int _int(JsonObject json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw FormatException('Campo entero inválido: $key');
}

int? _intOrNull(Object? value) => value == null
    ? null
    : value is int
    ? value
    : throw const FormatException('Campo entero inválido.');

bool _bool(JsonObject json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException('Campo booleano inválido: $key');
}

bool? _boolOrNull(Object? value) => value == null
    ? null
    : value is bool
    ? value
    : throw const FormatException('Campo booleano inválido.');

DateTime _date(JsonObject json, String key) {
  final value = _dateOrNull(json[key]);
  if (value != null) return value;
  throw FormatException('Fecha requerida inválida: $key');
}

DateTime? _dateOrNull(Object? value) => value == null
    ? null
    : value is String
    ? DateTime.tryParse(value) ??
          (throw const FormatException('Fecha inválida.'))
    : throw const FormatException('Fecha inválida.');

double? _nullableDouble(Object? value) => value == null
    ? null
    : value is num
    ? value.toDouble()
    : throw const FormatException('Campo decimal inválido.');
