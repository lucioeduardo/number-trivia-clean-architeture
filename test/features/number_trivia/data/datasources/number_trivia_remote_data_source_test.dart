import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_clean_architecture/core/error/exceptions.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class HttpClientMock extends Mock implements http.Client {}

main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late HttpClientMock clientMock;

  setUp(() {
    clientMock = HttpClientMock();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: clientMock);

    registerFallbackValue(Uri());
  });

  void setUpMockHttpClientSuccess200() {
    when(() => clientMock.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }
  void setUpMockHttpClientFeilure404() {
    when(() => clientMock.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      "should perform a GET request on a URL with number being the endpoint and with application/json header",
      () {
        setUpMockHttpClientSuccess200();

        dataSource.getConcreteNumberTrivia(tNumber);

        verify(() => clientMock.get(
              Uri.parse('$numbersApiBaseUrl/$tNumber'),
              headers: {'Content-Type': 'application/json'},
            ));
      },
    );

    test(
      "should return NumberTrivia when response code is 200(success)",
      () async {
        setUpMockHttpClientSuccess200();

        final result = await dataSource.getConcreteNumberTrivia(tNumber);

        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      "should throw ServerException when response code is 404 or other",
      () async {
        setUpMockHttpClientFeilure404();

        final call = dataSource.getConcreteNumberTrivia;

        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      "should perform a GET request on a URL with number being the endpoint and with application/json header",
      () {
        setUpMockHttpClientSuccess200();

        dataSource.getRandomNumberTrivia();

        verify(() => clientMock.get(
              Uri.parse('$numbersApiBaseUrl/random'),
              headers: {'Content-Type': 'application/json'},
            ));
      },
    );

    test(
      "should return NumberTrivia when response code is 200(success)",
      () async {
        setUpMockHttpClientSuccess200();

        final result = await dataSource.getRandomNumberTrivia();

        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      "should throw ServerException when response code is 404 or other",
      () async {
        setUpMockHttpClientFeilure404();

        final call = dataSource.getRandomNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
