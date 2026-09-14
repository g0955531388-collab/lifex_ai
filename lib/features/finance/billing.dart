import '../profile/health_profile.dart';

class ExemptionDecision {
  const ExemptionDecision({required this.isExempt, this.reasonAr});
  final bool isExempt;
  final String? reasonAr;
}

class BillingExemptionPolicy {
  ExemptionDecision evaluate(HealthProfile profile) {
    if (profile.accreditedDisability || profile.chronicAccredited) {
      return const ExemptionDecision(
        isExempt: true,
        reasonAr:
            'رسوم Lifex صفر لعضو معتمد من ذوي الهمم أو المرضى المزمنين.',
      );
    }
    return const ExemptionDecision(isExempt: false);
  }
}

enum TransactionType {
  topUp,
  hospitalPayment,
  donationPayment,
  refund,
  subscriptionPayment,
  appStoreSale,
}

class WalletTransaction {
  const WalletTransaction({
    required this.transactionId,
    required this.profileId,
    required this.type,
    required this.amountInSmallestUnit,
    required this.currencyCode,
    required this.recordedAt,
    this.relatedGatewayTransactionId,
  });

  final String transactionId;
  final String profileId;
  final TransactionType type;
  final int amountInSmallestUnit;
  final String currencyCode;
  final DateTime recordedAt;
  final String? relatedGatewayTransactionId;
}

class TransactionLedger {
  final List<WalletTransaction> _items = [];
  int _counter = 0;

  List<WalletTransaction> get all => List.unmodifiable(_items);

  WalletTransaction record({
    required String profileId,
    required TransactionType type,
    required int amountInSmallestUnit,
    required String currencyCode,
    String? relatedGatewayTransactionId,
  }) {
    _counter++;
    final tx = WalletTransaction(
      transactionId: 'TXN-$_counter',
      profileId: profileId,
      type: type,
      amountInSmallestUnit: amountInSmallestUnit,
      currencyCode: currencyCode,
      recordedAt: DateTime.now(),
      relatedGatewayTransactionId: relatedGatewayTransactionId,
    );
    _items.add(tx);
    return tx;
  }

  int currentBalanceFor(String profileId) {
    var sum = 0;
    for (final tx in _items.where((t) => t.profileId == profileId)) {
      if (tx.type == TransactionType.topUp ||
          tx.type == TransactionType.refund) {
        sum += tx.amountInSmallestUnit;
      } else {
        sum -= tx.amountInSmallestUnit;
      }
    }
    return sum;
  }
}
