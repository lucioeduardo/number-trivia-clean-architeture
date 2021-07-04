

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main(){
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');
  
  setUp((){

  });

  test(
     "should be a subclass of NumberTrivia entity",
     () {
       expect(tNumberTriviaModel, isA<NumberTrivia>());
     },
  );

  group('fromJson', () {
    test(
      "should return a valid model when the JSON number is an integer",
      () {
        final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));

        final result = NumberTriviaModel.fromJson(jsonMap);

        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      "should return a valid model when the JSON number is regarded as a double",
      () {
        final Map<String, dynamic> jsonMap = json.decode(fixture('trivia_double.json'));

        final result = NumberTriviaModel.fromJson(jsonMap);

        expect(result, equals(tNumberTriviaModel));
      },
    );

  });

  group('toJson', (){
    test(
       "should return a JSON map containing the proper data",
       () {
         final result = tNumberTriviaModel.toJson();

         final expectedMap = {
           "text": "Test Text",
           "number": 1
         };
         
         expect(result, equals(expectedMap));
       },
    );
  });

}
