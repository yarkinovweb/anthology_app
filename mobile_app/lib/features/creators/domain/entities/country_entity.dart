import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final String id;
  final String name;
  final String code;

  const CountryEntity({
    required this.id,
    required this.name,
    required this.code,
  });

  String get flagEmoji {
    return code.toUpperCase().split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) + 0x1F1A5);
    }).join();
  }

  @override
  List<Object?> get props => [id, name, code];
}
