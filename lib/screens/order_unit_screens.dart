import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../core/health_event_manager.dart';
import '../features/profile/multi_profile_engine.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OrderUnitScreen(
      title: 'المخابر',
      unitType: 'lab',
      intro:
          'طلب إلكتروني من الطبيب إلى المخبر ثم النتيجة تعود للطبيب. المريض يحضر مرة واحدة.',
      event: HealthEventType.labResultReceived,
    );
  }
}

class ImagingScreen extends StatelessWidget {
  const ImagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OrderUnitScreen(
      title: 'الأشعة',
      unitType: 'imaging',
      intro:
          'أرشيف المريض على نفس الخيط. ليست قراءة إشعاعية من Lifex. التفسير للطبيب.',
      event: HealthEventType.imagingResultReceived,
    );
  }
}

class _OrderUnitScreen extends StatefulWidget {
  const _OrderUnitScreen({
    required this.title,
    required this.unitType,
    required this.intro,
    required this.event,
  });

  final String title;
  final String unitType;
  final String intro;
  final HealthEventType event;

  @override
  State<_OrderUnitScreen> createState() => _OrderUnitScreenState();
}

class _OrderUnitScreenState extends State<_OrderUnitScreen> {
  final _summary = TextEditingController();
  final _result = TextEditingController();

  @override
  void dispose() {
    _summary.dispose();
    _result.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final store = context.watch<CareStore>();
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد ملف نشط')));
    }
    final orders = store
        .bag(profile.profileId)
        .orders
        .where((o) => o.unitType == widget.unitType)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.intro),
          TextField(
            controller: _summary,
            decoration: const InputDecoration(labelText: 'نص الطلب من الطبيب'),
          ),
          FilledButton(
            onPressed: () async {
              await store.mutate(profile.profileId, (bag) {
                bag.orders.add(
                  CareOrder(
                    id: newCareId(),
                    unitType: widget.unitType,
                    summaryAr: _summary.text.trim(),
                  ),
                );
              });
            },
            child: const Text('إنشاء طلب'),
          ),
          const Divider(),
          for (final order in orders)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(order.summaryAr),
                    Text('الحالة: ${order.status}'),
                    if (order.resultAr.isNotEmpty) Text(order.resultAr),
                    if (order.status != 'ready') ...[
                      TextField(
                        controller: _result,
                        decoration:
                            const InputDecoration(labelText: 'النتيجة للطبيب'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await store.mutate(profile.profileId, (bag) {
                            final target =
                                bag.orders.firstWhere((o) => o.id == order.id);
                            target.status = 'ready';
                            target.resultAr = _result.text.trim();
                          });
                          HealthEventManager.instance.emitQuick(
                            widget.event,
                            sourceModule: widget.unitType,
                            profileId: profile.profileId,
                          );
                        },
                        child: const Text('إرجاع النتيجة'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
