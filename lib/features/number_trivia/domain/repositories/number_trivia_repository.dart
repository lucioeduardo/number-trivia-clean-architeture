import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/number_trivia.dart';

abstract class NumberTriviaRepository {
   Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
   Future<Either<Failure,NumberTrivia>> getRandomNumberTrivia();
}