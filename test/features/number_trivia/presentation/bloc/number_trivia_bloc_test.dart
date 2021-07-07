import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_clean_architecture/core/error/failure.dart';
import 'package:number_trivia_clean_architecture/core/usecase/usecase.dart';
import 'package:number_trivia_clean_architecture/core/util/input_converter.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class GetConcreteNumberTriviaMock extends Mock
    implements GetConcreteNumberTrivia {}

class GetRandomNumberTriviaMock extends Mock implements GetRandomNumberTrivia {}

class InputConverterMock extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late GetConcreteNumberTriviaMock getConcreteNumberTriviaMock;
  late GetRandomNumberTriviaMock getRandomNumberTriviaMock;
  late InputConverterMock inputConverterMock;

  setUpAll(() {
    registerFallbackValue(Params(1));
  });

  setUp(() {
    getConcreteNumberTriviaMock = GetConcreteNumberTriviaMock();
    getRandomNumberTriviaMock = GetRandomNumberTriviaMock();
    inputConverterMock = InputConverterMock();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: getConcreteNumberTriviaMock,
      getRandomNumberTrivia: getRandomNumberTriviaMock,
      inputConverter: inputConverterMock,
    );
  });

  test("initial state should be empty", () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'Trivia', number: 1);

    void setUpMockGetConcreteNumberTriviaSuccess() {
      when(() => getConcreteNumberTriviaMock(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));
    }

    void setUpMockInputConverterSuccess() {
      when(() => inputConverterMock.stringToUnsignedInteger(any()))
          .thenReturn(Right(tNumberParsed));
    }

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        build: () {
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaSuccess();
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) {
          verify(
              () => inputConverterMock.stringToUnsignedInteger(tNumberString));
        });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Error] when the input is invalid',
      build: () {
        when(() => inputConverterMock.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [Error(message: invalidInputFailure)],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should get data from the getConcreteNumberTrivia usecase',
        build: () {
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaSuccess();
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) {
          verify(() => getConcreteNumberTriviaMock(Params(tNumberParsed)));
        });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Loaded] when data is gotten succesfully',
      build: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [Loading(), Loaded(trivia: tNumberTrivia)],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] when getting data fails with ServerFailureMessage',
      build: () {
        setUpMockInputConverterSuccess();
        when(() => getConcreteNumberTriviaMock(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [Loading(), Error(message: serverFailureMessage)],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] when getting data fails with CacheFailureMessage',
      build: () {
        setUpMockInputConverterSuccess();
        when(() => getConcreteNumberTriviaMock(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [Loading(), Error(message: cacheFailureMessage)],
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(text: 'Trivia', number: 1);

    void setUpMockGetRandomNumberTriviaSuccess() {
      when(() => getRandomNumberTriviaMock(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));
    }

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should get data from the getRandomNumberTrivia usecase',
        build: () {
          setUpMockGetRandomNumberTriviaSuccess();
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        verify: (_) {
          verify(() => getRandomNumberTriviaMock(NoParams()));
        });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading, Loaded] when data is gotten succesfully',
        build: () {
          setUpMockGetRandomNumberTriviaSuccess();
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: () => [Loading(), Loaded(trivia: tNumberTrivia)]);
    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading, Error] when getting data fails with ServerFailureMessage',
        build: () {
          when(() => getRandomNumberTriviaMock(any()))
              .thenAnswer((_) async => Left(ServerFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: () => [Loading(), Error(message: serverFailureMessage)]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading, Error] when getting data fails with ServerFailureMessage',
        build: () {
          when(() => getRandomNumberTriviaMock(any()))
              .thenAnswer((_) async => Left(CacheFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: () => [Loading(), Error(message: cacheFailureMessage)]);
  });
}
