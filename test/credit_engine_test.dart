import 'package:flutter_test/flutter_test.dart';
import 'package:questit/services/credit_engine.dart';

void main() {
  group('CreditEngine', () {
    test('settleDay calculates surplus correctly', () {
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: 3600,
        elapsedSeconds: 4000,
        currentCreditBalance: 0,
      );
      expect(result.newCreditBalance, 400);
      expect(result.penaltyTriggered, false);
      expect(result.surplusOrDeficit, 400);
    });

    test('settleDay calculates deficit correctly', () {
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: 3600,
        elapsedSeconds: 3000,
        currentCreditBalance: 0,
      );
      expect(result.newCreditBalance, -600);
      expect(result.penaltyTriggered, false);
      expect(result.surplusOrDeficit, -600);
    });

    test('settleDay enforces debt cap', () {
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: 3600,
        elapsedSeconds: 0,
        currentCreditBalance: -100,
      );
      // Proposed balance would be -3700, but cap is -3600
      expect(result.newCreditBalance, -3600);
      expect(result.penaltyTriggered, true);
    });

    test('effectiveGoalForToday factors in credit', () {
      final goal = CreditEngine.effectiveGoalForToday(
        dailyGoalSeconds: 3600,
        currentCreditBalance: 600,
      );
      expect(goal, 3000);
    });

    test('effectiveGoalForToday factors in debt', () {
      final goal = CreditEngine.effectiveGoalForToday(
        dailyGoalSeconds: 3600,
        currentCreditBalance: -600,
      );
      expect(goal, 4200);
    });
  });
}
