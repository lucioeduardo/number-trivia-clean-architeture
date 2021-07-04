import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/number_trivia.dart';

import '../models/number_trivia_model.dart';
import 'package:http/http.dart' as http;


abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

const numbersApiBaseUrl = "http://numbersapi.com";

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      _getNumberTrivia('$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() =>
      _getNumberTrivia('random');

  Future<NumberTriviaModel> _getNumberTrivia(String url) async {
    final response = await client.get(
      Uri.parse("$numbersApiBaseUrl/$url"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
