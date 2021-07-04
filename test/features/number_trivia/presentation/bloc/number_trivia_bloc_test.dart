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

    test(
      "should call the InputConverter to validate and convert the string to an unsigned integer",
      () async {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
            () => inputConverterMock.stringToUnsignedInteger(any()));

        verify(() => inputConverterMock.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      "should emit [Error] when the input is invalid",
      () {
        when(() => inputConverterMock.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));

        expectLater(
          bloc.stream,
          emitsInOrder([
            Error(message: invalidInputFailure),
          ]),
        );

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      "should get data from the getConcreteNumberTrivia usecase",
      () async {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(() => getConcreteNumberTriviaMock(any()));

        verify(() => getConcreteNumberTriviaMock(Params(tNumberParsed)));
      },
    );

    test(
      "should emit [Loading, Loaded] when data is gotten succesfully",
      () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        expectLater(
          bloc.stream,
          emitsInOrder([
            Loading(),
            Loaded(
              trivia: tNumberTrivia,
            )
          ]),
        );

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      "should emit [Loading, Error] when getting data fails with ServerFailureMessage",
      () {
        setUpMockInputConverterSuccess();
        when(() => getConcreteNumberTriviaMock(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

        expectLater(
          bloc.stream,
          emitsInOrder([
            Loading(),
            Error(
              message: serverFailureMessage,
            )
          ]),
        );

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      "should emit [Loading, Error] when getting data fails with CacheFailureMessage",
      () {
        setUpMockInputConverterSuccess();
        when(() => getConcreteNumberTriviaMock(any()))
          .thenAnswer((_) async => Left(CacheFailure()));

        expectLater(
          bloc.stream,
          emitsInOrder([
            Loading(),
            Error(
              message: cacheFailureMessage,
            )
          ]),
        );

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(text: 'Trivia', number: 1);

    void setUpMockGetRandomNumberTriviaSuccess() {
      when(() => getRandomNumberTriviaMock(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));
    }

    test(
      "should get data from the getRandomNumberTrivia usecase",
      () async {
        setUpMockGetRandomNumberTriviaSuccess();

        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(() => getRandomNumberTriviaMock(any()));

        verify(() => getRandomNumberTriviaMock(NoParams()));
      },
    );

    test(
      "should emit [Loading, Loaded] when data is gotten succesfully",
      () {
        setUpMockGetRandomNumberTriviaSuccess();

        expectLater(
          bloc.stream,
          emitsInOrder([
            Loading(),
            Loaded(
              trivia: tNumberTrivia,
            )
          ]),
        );

        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      "should emit [Loading, Error] when getting data fails with ServerFailureMessage",
      () {
        when(() => getRandomNumberTriviaMock(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

        expectLater(
          bloc.stream,
          emitsInOrder([
            Loading(),
            Error(
              message: serverFailureMessage,
            )
          ]),
        );

        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      "should emit [Loading, Error] when getting data fails with CacheFailureMessage",
      () {
        when(() => getRandomNumberTriviaMock(any()))
          .thenAnswer((_) async => Left(CacheFailure()));

        expectLater(
          bloc.stream,
          emitsInOrder([
            Loading(),
            Error(
              message: cacheFailureMessage,
            )
          ]),
        );

        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}
