import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Could not reach the server. Check your internet connection and try again.',
  ]);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The server did not respond within 10 seconds.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on our side. Please try again.',
  ]);
}

final class InvalidAmountFailure extends Failure {
  const InvalidAmountFailure([
    super.message = 'The server did not accept this amount. Please edit it.',
  ]);
}
