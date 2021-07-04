import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_clean_architecture/core/error/exceptions.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

main() {
  late SharedPreferencesMock sharedPreferencesMock;
  late NumberTriviaLocalDataSourceImpl dataSource;

  setUp(() {
    sharedPreferencesMock = SharedPreferencesMock();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: sharedPreferencesMock);
  });

  group('getLastNumberTrivia', () {
    final triviaCached = fixture('trivia_cached.json');
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(triviaCached));

    test(
      "should return NumberTriviaModel from SharedPreferences when there is one in the cache",
      () async {
        when(() => sharedPreferencesMock.getString(any()))
            .thenReturn(triviaCached);

        final result = await dataSource.getLastNumberTrivia();

        verify(() => sharedPreferencesMock.getString(cachedNumberTrivia));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      "should throw CacheException when ther is not a cached value",
      () async {
        when(() => sharedPreferencesMock.getString(any())).thenReturn(null);

        final call = dataSource.getLastNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'Test', number: 1);
    test(
      "should call SharedPreferences to cache the data",
      () {
        when(() => sharedPreferencesMock.setString(any(), any()))
            .thenAnswer((_) => (Future.value(true)));

        dataSource.cacheNumberTrivia(tNumberTriviaModel);

        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());

        verify(() => sharedPreferencesMock.setString(
              cachedNumberTrivia,
              expectedJsonString,
            ));
      },
    );
  });
}
