import 'package:freezed_annotation/freezed_annotation.dart';

part 'number_trivia_event.freezed.dart';

@freezed
abstract class NumberTriviaEvent with _$NumberTriviaEvent {
  const factory NumberTriviaEvent.getTriviaForConcreteNumber(String numberString) = GetTriviaForConcreteNumber;
  const factory NumberTriviaEvent.getTriviaForRandomNumber() = GetTriviaForRandomNumber;
}

// class GetTriviaForConcreteNumber extends NumberTriviaEvent{
//   final String numberString;

//   GetTriviaForConcreteNumber(this.numberString);

//   @override
//   List<Object> get props => [this.numberString];
// }

// class GetTriviaForRandomNumber extends NumberTriviaEvent {}