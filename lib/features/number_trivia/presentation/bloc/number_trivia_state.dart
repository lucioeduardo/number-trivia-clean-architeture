import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/number_trivia.dart';

part 'number_trivia_state.freezed.dart';

@freezed
abstract class NumberTriviaState with _$NumberTriviaState{
  const factory NumberTriviaState.empty() = Empty;
  const factory NumberTriviaState.loading() = Loading;
  const factory NumberTriviaState.loaded({required NumberTrivia trivia}) = Loaded;
  const factory NumberTriviaState.error({required String message}) = Error;
}
