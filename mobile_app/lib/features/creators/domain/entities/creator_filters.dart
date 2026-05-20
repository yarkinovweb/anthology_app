import 'package:equatable/equatable.dart';

class CreatorFilters extends Equatable {
  final String? search;
  final String? countryId;
  final String? categoryId;
  final String? period;

  const CreatorFilters({
    this.search,
    this.countryId,
    this.categoryId,
    this.period,
  });

  CreatorFilters copyWith({
    String? search,
    String? countryId,
    String? categoryId,
    String? period,
    bool clearSearch    = false,
    bool clearCountry   = false,
    bool clearCategory  = false,
    bool clearPeriod    = false,
  }) {
    return CreatorFilters(
      search:     clearSearch   ? null : search     ?? this.search,
      countryId:  clearCountry  ? null : countryId  ?? this.countryId,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      period:     clearPeriod   ? null : period      ?? this.period,
    );
  }

  bool get isEmpty =>
      search == null && countryId == null && categoryId == null && period == null;

  Map<String, dynamic> toQueryParams() {
    return {
      if (search     != null && search!.isNotEmpty) 'search':      search,
      if (countryId  != null) 'country_id':  countryId,
      if (categoryId != null) 'category_id': categoryId,
      if (period     != null) 'period':       period,
    };
  }

  @override
  List<Object?> get props => [search, countryId, categoryId, period];
}
