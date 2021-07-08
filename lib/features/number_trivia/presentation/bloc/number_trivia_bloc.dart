import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';
import 'number_trivia_event.dart';
import 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailure =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty());

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is GetTriviaForConcreteNumber) {
      final input = inputConverter.stringToUnsignedInteger(event.numberString);

      yield* input.fold(
        (failure) async* {
          yield Error(message: invalidInputFailure);
        },
        (integer) async* {
          yield* _proccessUsecase(
              () => getConcreteNumberTrivia(Params(integer)));
        },
      );
    } else if (event is GetTriviaForRandomNumber) {
      yield* _proccessUsecase(() => getRandomNumberTrivia(NoParams()));
    }
  }

  Stream<NumberTriviaState> _proccessUsecase(
      Future<Either<Failure, NumberTrivia>> Function() usecase) async* {
    yield Loading();
    final triviaEither = await usecase();
    yield triviaEither.fold(
      (failure) => Error(message: failure.message),
      (trivia) => Loaded(trivia: trivia),
    );
  }
}

extension MapFailureToMessage on Failure {
  String get message {
    switch (this.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected Error';
    }
  }
}
