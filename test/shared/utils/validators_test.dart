import 'package:flutter_test/flutter_test.dart';
import 'package:sadad_mob/shared/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns error for empty value', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('notemail'), isNotNull);
        expect(Validators.email('missing@dot'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
      });
    });

    group('password', () {
      test('returns error for empty value', () {
        expect(Validators.password(''), isNotNull);
        expect(Validators.password(null), isNotNull);
      });

      test('returns error for short password', () {
        expect(Validators.password('12345'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('123456'), isNull);
      });
    });

    group('required', () {
      test('returns error for empty value', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('   '), isNotNull);
        expect(Validators.required(null), isNotNull);
      });

      test('returns null for non-empty value', () {
        expect(Validators.required('hello'), isNull);
      });
    });

    group('amount', () {
      test('returns error for empty value', () {
        expect(Validators.amount(''), isNotNull);
      });

      test('returns error for non-numeric', () {
        expect(Validators.amount('abc'), isNotNull);
      });

      test('returns error for zero or negative', () {
        expect(Validators.amount('0'), isNotNull);
        expect(Validators.amount('-10'), isNotNull);
      });

      test('returns null for valid amount', () {
        expect(Validators.amount('100'), isNull);
        expect(Validators.amount('50.5'), isNull);
      });
    });
  });
}
