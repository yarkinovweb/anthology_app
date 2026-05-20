class CreatorFormParams {
  final String name;
  final String? bio;
  final int? bornYear;
  final int? diedYear;
  final String? countryId;
  final String? categoryId;

  const CreatorFormParams({
    required this.name,
    this.bio,
    this.bornYear,
    this.diedYear,
    this.countryId,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (bio != null && bio!.isNotEmpty) 'bio': bio,
        if (bornYear != null) 'born_year': bornYear,
        if (diedYear != null) 'died_year': diedYear,
        if (countryId != null) 'country_id': countryId,
        if (categoryId != null) 'category_id': categoryId,
      };
}
