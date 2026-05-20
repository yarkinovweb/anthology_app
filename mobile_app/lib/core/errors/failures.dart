import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Backend 4xx/5xx javoblar
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Hive read/write xatolari
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Internet yo'q yoki timeout
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// 401 va token yangilanmasa
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
