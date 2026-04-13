import 'dart:math';

class MathProblem {
  final String question;
  final List<String> options; // always 4
  final int correctIndex;

  const MathProblem({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class MathGenerator {
  static final _rng = Random();

  /// Returns 20 problems: 7 easy, 7 medium, 6 hard.
  static List<MathProblem> generate20() {
    return [
      for (int i = 0; i < 7; i++) _easy(),
      for (int i = 0; i < 7; i++) _medium(),
      for (int i = 0; i < 6; i++) _hard(),
    ];
  }

  // ── Easy ────────────────────────────────────────────────────────────────

  static MathProblem _easy() =>
      _rng.nextBool() ? _multiplication() : _division();

  static MathProblem _multiplication() {
    final a = _rng.nextInt(11) + 2; // 2-12
    final b = _rng.nextInt(11) + 2;
    return _intProblem('$a × $b = ?', a * b);
  }

  static MathProblem _division() {
    final divisor = _rng.nextInt(9) + 2; // 2-10
    final quotient = _rng.nextInt(10) + 2; // 2-11
    final dividend = divisor * quotient;
    return _intProblem('$dividend ÷ $divisor = ?', quotient);
  }

  // ── Medium ───────────────────────────────────────────────────────────────

  static MathProblem _medium() =>
      _rng.nextBool() ? _percentage() : _fractionAdd();

  static MathProblem _percentage() {
    const percents = [10, 20, 25, 50];
    const bases = [20, 40, 60, 80, 100, 120, 200];
    final p = percents[_rng.nextInt(percents.length)];
    final b = bases[_rng.nextInt(bases.length)];
    final result = (p * b) ~/ 100;
    return _intProblem('$p% מתוך $b = ?', result);
  }

  static MathProblem _fractionAdd() {
    const denoms = [3, 4, 5, 6, 8];
    final d = denoms[_rng.nextInt(denoms.length)];
    final a = _rng.nextInt(d - 1) + 1; // 1..d-1
    final c = _rng.nextInt(d - 1) + 1;
    final sumNum = a + c;
    final correctStr = _frac(sumNum, d);

    // Build 3 wrong answers by shifting numerator
    final used = <String>{correctStr};
    final options = <String>[correctStr];
    for (final delta in [1, -1, 2, -2, 3, -3]) {
      final wn = sumNum + delta;
      if (wn > 0) {
        final ws = _frac(wn, d);
        if (!used.contains(ws)) {
          used.add(ws);
          options.add(ws);
        }
      }
      if (options.length >= 4) break;
    }
    // Pad if still short (rare edge case)
    int pad = 4;
    while (options.length < 4) {
      final ws = _frac(sumNum + pad, d);
      if (!used.contains(ws)) { used.add(ws); options.add(ws); }
      pad++;
    }

    options.shuffle(_rng);
    return MathProblem(
      question: '$a/$d + $c/$d = ?',
      options: options,
      correctIndex: options.indexOf(correctStr),
    );
  }

  // ── Hard ─────────────────────────────────────────────────────────────────

  static MathProblem _hard() {
    switch (_rng.nextInt(3)) {
      case 0: return _power();
      case 1: return _combinedAdd();
      default: return _combinedMul();
    }
  }

  static MathProblem _power() {
    const bases = [2, 3, 4, 5];
    const exps = [2, 3, 4];
    final base = bases[_rng.nextInt(bases.length)];
    final exp = exps[_rng.nextInt(exps.length)];
    final result = pow(base, exp).toInt();
    return _intProblem('$base^$exp = ?', result);
  }

  static MathProblem _combinedAdd() {
    final a = _rng.nextInt(9) + 2; // 2-10
    final b = _rng.nextInt(9) + 2;
    final c = _rng.nextInt(20) + 1; // 1-20
    return _intProblem('$a × $b + $c = ?', a * b + c);
  }

  static MathProblem _combinedMul() {
    final a = _rng.nextInt(10) + 1; // 1-10
    final b = _rng.nextInt(10) + 1;
    final c = _rng.nextInt(9) + 2; // 2-10
    return _intProblem('($a + $b) × $c = ?', (a + b) * c);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static MathProblem _intProblem(String question, int correct) {
    // Generate 3 plausible wrong answers
    final used = <int>{correct};
    final options = <int>[correct];
    for (final offset in [1, -1, 2, -2, 5, -5, 10, -10, 3, -3]) {
      final w = correct + offset;
      if (w > 0 && !used.contains(w)) {
        used.add(w);
        options.add(w);
      }
      if (options.length >= 4) break;
    }

    final strOptions = options.map((n) => n.toString()).toList()..shuffle(_rng);
    return MathProblem(
      question: question,
      options: strOptions,
      correctIndex: strOptions.indexOf(correct.toString()),
    );
  }

  static String _frac(int num, int den) {
    if (num <= 0) return '0';
    final g = _gcd(num, den);
    final sn = num ~/ g;
    final sd = den ~/ g;
    return sd == 1 ? '$sn' : '$sn/$sd';
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}
