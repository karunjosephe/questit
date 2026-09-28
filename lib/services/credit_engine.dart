/// Result of running end-of-day settlement on a task.
class SettlementResult {
  final int newCreditBalance;
  final bool penaltyTriggered;
  final int surplusOrDeficit; // positive = surplus, negative = deficit
  final bool streakBroken;
  final bool streakIncremented;

  const SettlementResult({
    required this.newCreditBalance,
    required this.penaltyTriggered,
    required this.surplusOrDeficit,
    required this.streakBroken,
    required this.streakIncremented,
  });
}

/// Pure logic class — no Flutter/Hive dependencies.
/// Handles the banking/borrowing/debt-cap math described in the spec.
class CreditEngine {
  /// Runs once per task per day, typically triggered by a date-rollover
  /// check.
  static SettlementResult settleDay({
    required int dailyGoalSeconds,
    required int elapsedSeconds,
    required int currentCreditBalance,
  }) {
    // Logic:
    // If elapsedSeconds < dailyGoalSeconds, we have a deficit.
    // The deficit is (dailyGoalSeconds - elapsedSeconds).
    // This deficit must be subtracted from the currentCreditBalance.
    // However, if the user was working past the goal, the currentCreditBalance
    // ALREADY reflects those extra seconds due to real-time updates.
    // So at settlement, we ONLY need to apply the penalty if they failed to meet the goal.
    
    int proposedBalance = currentCreditBalance;
    bool streakIncremented = false;
    bool streakBroken = false;
    int diff = elapsedSeconds - dailyGoalSeconds;

    if (diff < 0) {
      // Deficit: subtract the shortfall from balance
      proposedBalance += diff;
    } else {
      // Met or exceeded goal
      streakIncremented = true;
    }

    // --- Debt & Credit cap enforcement ---
    // User requested: bank cap always equal to time per day for both debt and credit.
    final int debtCap = -dailyGoalSeconds;
    final int creditCap = dailyGoalSeconds;

    bool penalty = false;

    if (proposedBalance < debtCap) {
      proposedBalance = debtCap; // clamp
      penalty = true;
      streakBroken = true;
    } else if (proposedBalance > creditCap) {
      proposedBalance = creditCap; // clamp credit surplus
    }

    return SettlementResult(
      newCreditBalance: proposedBalance,
      penaltyTriggered: penalty,
      surplusOrDeficit: diff,
      streakBroken: streakBroken,
      streakIncremented: streakIncremented,
    );
  }

  /// Determines how much time a task effectively "owes" or "has available"
  /// for today, factoring in existing credit/debt.
  static int effectiveGoalForToday({
    required int dailyGoalSeconds,
    required int currentCreditBalance,
  }) {
    // If in debt, today's goal increases (you must pay it back).
    // If banked, today's goal decreases (you can "spend" the credit).
    final int effective = dailyGoalSeconds - currentCreditBalance;
    return effective < 0 ? 0 : effective; // can't go negative
  }

  /// Convenience check: is this task currently under a penalty lock?
  static bool isAtDebtCap({
    required int dailyGoalSeconds,
    required int currentCreditBalance,
  }) {
    return currentCreditBalance <= -dailyGoalSeconds;
  }
}
