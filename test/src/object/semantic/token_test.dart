// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:lsp/lsp.dart';
import 'package:test/test.dart';

final _rng = Random();
int get x => _rng.nextInt(100);

void main() {
  group('SemanticToken', () {
    test('compareTo', () async {
      SemanticToken rsl(int r, int s, int l) => SemanticToken(
            row: r,
            start: s,
            length: l,
            tokenType: 0,
            tokenModifiers: [],
          );

      final a = x;
      final b = x;
      final big = max(a, b);
      final sml = min(a, b);

      // row order
      expect(rsl(sml, x, x).compareTo(rsl(big, x, x)), isNegative);
      expect(rsl(big, x, x).compareTo(rsl(sml, x, x)), isPositive);

      // start order
      final fix = x;
      expect(rsl(fix, sml, x).compareTo(rsl(fix, big, x)), isNegative);
      expect(rsl(fix, big, x).compareTo(rsl(fix, sml, x)), isPositive);

      // lenght order
      expect(rsl(fix, fix, sml).compareTo(rsl(fix, fix, big)), isNegative);
      expect(rsl(fix, fix, big).compareTo(rsl(fix, fix, sml)), isPositive);

      // ordering
      final _122 = rsl(1, 2, 2);
      final _123 = rsl(1, 2, 3);
      final _133 = rsl(1, 3, 3);
      final _134 = rsl(1, 3, 4);
      final _233 = rsl(2, 3, 3);
      final _234 = rsl(2, 3, 4);

      final l = [_133, _122, _234, _123, _134, _233];
      l.sort();

      expect(l, equals([_122, _123, _133, _134, _233, _234]));
    });
  });
}
