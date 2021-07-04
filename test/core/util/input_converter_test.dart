import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:number_trivia_clean_architecture/core/util/input_converter.dart';

main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      "should return an intenger when the string represents an unsigned integer",
      () {
        final str = '5678';

        final result = inputConverter.stringToUnsignedInteger(str);

        expect(result, Right(5678));
      },
    );

    test(
      "should return an InvalidInputFailure when the string represents an integer",
      () {
        final str = '1.0';

        final result = inputConverter.stringToUnsignedInteger(str);

        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      "should return an InvalidInputFailure when the string a negative integer",
      () {
        final str = '-123';

        final result = inputConverter.stringToUnsignedInteger(str);

        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}
