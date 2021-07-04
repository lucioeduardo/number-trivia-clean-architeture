import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_clean_architecture/core/usecase/usecase.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

class NumberTriviaRepositoryMock extends Mock
    implements NumberTriviaRepository {}
void main(){
  var repository = NumberTriviaRepositoryMock();
  var usecase = GetRandomNumberTrivia(repository);

  setUp((){
    repository = NumberTriviaRepositoryMock();
    usecase = GetRandomNumberTrivia(repository);
  });

  final tNumberTrivia = NumberTrivia(text: "texto", number: 1);


  test(
     "should get a random number trivia from the repository",
     () async {
        when(() => repository.getRandomNumberTrivia()).thenAnswer((_) async => Right(tNumberTrivia));

        final result = await usecase(NoParams());

        expect(result, Right(tNumberTrivia));
        verify(() => repository.getRandomNumberTrivia()).called(1);
        verifyNoMoreInteractions(repository);
     },
  );
  
}