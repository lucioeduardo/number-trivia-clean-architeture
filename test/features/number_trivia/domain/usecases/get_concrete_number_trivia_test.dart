import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class NumberTriviaRepositoryMock extends Mock
    implements NumberTriviaRepository {}

main() {
  NumberTriviaRepository repository = NumberTriviaRepositoryMock();
  GetConcreteNumberTrivia usecase = GetConcreteNumberTrivia(repository);

  setUp(() {
    repository = NumberTriviaRepositoryMock();
    usecase = GetConcreteNumberTrivia(repository);
  });

  final tNumberTrivia = NumberTrivia(text: "texto", number: 1);
  final tNumber = 1;

  test(
    "should return a number trivia",
    () async {
      when(() => repository.getConcreteNumberTrivia(captureAny()))
          .thenAnswer((_) async => Right(tNumberTrivia));
      
      final result = await usecase(Params(tNumber));

      expect(result, Right(tNumberTrivia));
      verify(() => repository.getConcreteNumberTrivia(tNumber));
      verifyNoMoreInteractions(repository);
    },
  );
}
