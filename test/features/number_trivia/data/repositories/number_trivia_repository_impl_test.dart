import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_clean_architecture/core/error/exceptions.dart';
import 'package:number_trivia_clean_architecture/core/error/failure.dart';
import 'package:number_trivia_clean_architecture/core/network/network_info.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

class RemoteDataSourceMock extends Mock
    implements NumberTriviaRemoteDataSource {}

class LocalDataSorceMock extends Mock implements NumberTriviaLocalDataSource {}

class NetworkInfoMock extends Mock implements NetworkInfo {}

void main() {
  late RemoteDataSourceMock remoteDataSourceMock;
  late LocalDataSorceMock localDataSourceMock;
  late NetworkInfoMock networkInfoMock;

  late NumberTriviaRepositoryImpl repository;

  final tNumber = 1;
  final tNumberTriviaModel = NumberTriviaModel(text: 'Text', number: 1);
  final NumberTrivia tNumberTrivia = tNumberTriviaModel;

  setUp(() {
    remoteDataSourceMock = RemoteDataSourceMock();
    localDataSourceMock = LocalDataSorceMock();
    networkInfoMock = NetworkInfoMock();

    repository = NumberTriviaRepositoryImpl(
        remoteDataSource: remoteDataSourceMock,
        localDataSource: localDataSourceMock,
        networkInfo: networkInfoMock);

    when(() => localDataSourceMock.cacheNumberTrivia(tNumberTriviaModel))
        .thenAnswer((_) async => Future.value());
  });

  runTestsOnline(Function body){
    group('device is online', () {
      setUp(() {
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  runTestsOffline(Function body){
    group('device is offline', () {
      setUp(() {
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    test(
      "should check if the device is online",
      () async {
        when(() => remoteDataSourceMock.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => true);

        await repository.getConcreteNumberTrivia(tNumber);

        verify(() => networkInfoMock.isConnected).called(1);
      },
    );

    runTestsOnline(() {
      setUp(() {
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => true);
      });
      test(
        "should call remote data when the call to RemoteDataSource is succesfull",
        () async {
          when(() => remoteDataSourceMock.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => tNumberTriviaModel);

          final result = await repository.getConcreteNumberTrivia(tNumber);

          expect(result, equals(Right(tNumberTrivia)));
          verify(() => remoteDataSourceMock.getConcreteNumberTrivia(tNumber));
        },
      );

      test(
        "should cache the data locally data when the call to RemoteDataSource is succesful",
        () async {
          when(() => remoteDataSourceMock.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => tNumberTriviaModel);

          await repository.getConcreteNumberTrivia(tNumber);

          verify(
              () => localDataSourceMock.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        "should return ServerFailure when the call to RemoteDataSource is unsucessful",
        () async {
          when(() => remoteDataSourceMock.getConcreteNumberTrivia(any()))
              .thenThrow(ServerException());
          when(() => localDataSourceMock.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(() => remoteDataSourceMock.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(localDataSourceMock);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      setUp(() {
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => false);
      });
      test(
        "should return last locally cached data when device is offline",
        () async {
          when(() => localDataSourceMock.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          
          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(() => localDataSourceMock.getLastNumberTrivia());
          verifyZeroInteractions(remoteDataSourceMock);
          expect(result, equals(Right(tNumberTriviaModel)));
        },
      );

      test(
        "should return CacheFailure when there is no cached data present",
        () async {
          when(() => localDataSourceMock.getLastNumberTrivia())
              .thenThrow(CacheException());
          
          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(() => localDataSourceMock.getLastNumberTrivia());
          verifyZeroInteractions(remoteDataSourceMock);
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    test(
      "should check if the device is online",
      () async {
        when(() => remoteDataSourceMock.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => true);

        await repository.getRandomNumberTrivia();

        verify(() => networkInfoMock.isConnected).called(1);
      },
    );

    runTestsOnline(() {
      setUp(() {
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => true);
      });
      test(
        "should call remote data when the call to RemoteDataSource is succesfull",
        () async {
          when(() => remoteDataSourceMock.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          final result = await repository.getRandomNumberTrivia();

          expect(result, equals(Right(tNumberTrivia)));
          verify(() => remoteDataSourceMock.getRandomNumberTrivia());
        },
      );

      test(
        "should cache the data locally when the call to RemoteDataSource is succesful",
        () async {
          when(() => remoteDataSourceMock.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          await repository.getRandomNumberTrivia();

          verify(
              () => localDataSourceMock.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        "should return ServerFailure when the call to RemoteDataSource is unsucessful",
        () async {
          when(() => remoteDataSourceMock.getRandomNumberTrivia())
              .thenThrow(ServerException());
          when(() => localDataSourceMock.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          final result = await repository.getRandomNumberTrivia();

          verify(() => remoteDataSourceMock.getRandomNumberTrivia());
          verifyZeroInteractions(localDataSourceMock);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      setUp(() {
        when(() => networkInfoMock.isConnected).thenAnswer((_) async => false);
      });
      test(
        "should return last locally cached data when device is offline",
        () async {
          when(() => localDataSourceMock.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          
          final result = await repository.getRandomNumberTrivia();

          verify(() => localDataSourceMock.getLastNumberTrivia());
          verifyZeroInteractions(remoteDataSourceMock);
          expect(result, equals(Right(tNumberTriviaModel)));
        },
      );

      test(
        "should return CacheFailure when there is no cached data present",
        () async {
          when(() => localDataSourceMock.getLastNumberTrivia())
              .thenThrow(CacheException());
          
          final result = await repository.getRandomNumberTrivia();

          verify(() => localDataSourceMock.getLastNumberTrivia());
          verifyZeroInteractions(remoteDataSourceMock);
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

}
