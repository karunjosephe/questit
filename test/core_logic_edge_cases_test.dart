import 'package:flutter_test/flutter_test.dart';
import 'package:questit/services/credit_engine.dart';

void main() {
  group('CreditEngine Advanced Edge Cases', () {
    const int goal = 3600; // 1 hour

    test('Debt cap is enforced exactly', () {
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: goal,
        elapsedSeconds: 0,
        currentCreditBalance: -goal,
      );
      // Already at cap, should not go deeper
      expect(result.newCreditBalance, -goal);
      expect(result.penaltyTriggered, true);
      expect(result.streakBroken, true);
    });

    test('Partial progress still results in debt if below goal', () {
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: goal,
        elapsedSeconds: 1800, // half goal
        currentCreditBalance: 0,
      );
      expect(result.newCreditBalance, -1800);
      expect(result.streakIncremented, false);
      expect(result.streakBroken, false);
    });

    test('Exact goal completion maintains balance and increments streak', () {
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: goal,
        elapsedSeconds: goal,
        currentCreditBalance: 500,
      );
      expect(result.newCreditBalance, 500);
      expect(result.streakIncremented, true);
    });

    test('Debt repayment logic via settlement', () {
      // User has -1000 debt. 
      // Today they worked 4000 (goal 3600).
      // However, our real-time logic already added the +400 to the balance.
      // So currentCreditBalance is -600.
      // settleDay should recognize they met the goal and just maintain the -600.
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: goal,
        elapsedSeconds: 4000,
        currentCreditBalance: -600,
      );
      expect(result.newCreditBalance, -600);
      expect(result.streakIncremented, true);
    });

    test('Huge surplus is banked correctly', () {
      final result = CreditEngine.settleDay(
        dailyGoalSeconds: goal,
        elapsedSeconds: 10000,
        currentCreditBalance: 0,
      );
      // Real-time would have added 6400 (10000 - 3600)
      // So we simulate that
      final realTimeResult = CreditEngine.settleDay(
        dailyGoalSeconds: goal,
        elapsedSeconds: 10000,
        currentCreditBalance: 6400,
      );
      expect(realTimeResult.newCreditBalance, 6400);
    });
  });
}
