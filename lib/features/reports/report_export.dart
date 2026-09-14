import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'stamped_report.dart';

class ReportExport {
  Future<File> writePlainFile(StampedReport report) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${report.reportId}.txt');
    await file.writeAsString(report.toPlainText());
    return file;
  }
}
