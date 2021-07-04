import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/number_trivia.dart';
import '../repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia extends Usecase<NumberTrivia, void>{
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);
  
  @override
  Future<Either<Failure, NumberTrivia>> call(_) {
    return repository.getRandomNumberTrivia();
  }

}