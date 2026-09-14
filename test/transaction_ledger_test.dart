import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/finance/billing.dart';

void main() {
  test('السجل append-only يزيد العدد', () {
    final ledger = TransactionLedger();
    ledger.record(
      profileId: 'p1',
      type: TransactionType.topUp,
      amountInSmallestUnit: 1000,
      currencyCode: 'USD',
    );
    ledger.record(
      profileId: 'p1',
      type: TransactionType.subscriptionPayment,
      amountInSmallestUnit: 200,
      currencyCode: 'USD',
    );
    expect(ledger.all.length, 2);
    expect(ledger.currentBalanceFor('p1'), 800);
  });
}
