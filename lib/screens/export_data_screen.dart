import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/running_activity.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _isGenerating = false;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _generatePdf(BuildContext context) async {
    setState(() => _isGenerating = true);

    try {
      // 1. Ambil data dari Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .orderBy('startTime', descending: true)
          .get();

      List<RunningActivity> activities = snapshot.docs
          .map((doc) => RunningActivity.fromFirestore(doc))
          .toList();

      // 2. Load Logo untuk Kop PDF
      final ByteData logoData = await rootBundle.load('assets/images/app_logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

      final pdf = pw.Document();

      // 3. Buat Halaman PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) => pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 40,
                        height: 40,
                        child: pw.Image(logoImage),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("FIREFIT MOBILE",
                              style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.orange)),
                          pw.Text("Health & Activity Report",
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 20),
            ],
          ),
          build: (pw.Context context) {
            return [
              // Judul Grafik
              pw.Text("Distance Overview (Last Activities)",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 15),

              // 4. FIX: Perbaikan Grafik (Tanpa fromIterables)
              pw.Container(
                height: 150,
                child: pw.Chart(
                  grid: pw.CartesianGrid(
                    xAxis: pw.FixedAxis(
                      List.generate(activities.length, (i) => i.toDouble()),
                      format: (v) => activities.length > v.toInt() 
                          ? DateFormat('dd/MM').format(activities[v.toInt()].startTime) 
                          : '',
                    ),
                    yAxis: pw.FixedAxis(
                      [0, 2, 4, 6, 8, 10],
                      format: (v) => '${v.toInt()} km',
                    ),
                  ),
                  datasets: [
                    pw.LineDataSet(
                      color: PdfColors.orange,
                      drawPoints: true,
                      isCurved: true,
                      pointSize: 3,
                      data: List.generate(
                        activities.length,
                        (i) => pw.LineChartValue(i.toDouble(), activities[i].distance),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // 5. Tabel Detail
              pw.Text("History Details",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                border: null,
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.orange),
                headers: ['Date', 'Distance', 'Pace', 'Duration', 'Steps'],
                data: activities.map((a) {
                  return [
                    DateFormat('dd/MM/yy').format(a.startTime),
                    "${a.distance.toStringAsFixed(2)} km",
                    "${(a.duration.inMinutes / (a.distance == 0 ? 1 : a.distance)).toStringAsFixed(2)} min/km",
                    a.movingTime,
                    a.steps.toString(),
                  ];
                }).toList(),
              ),
            ];
          },
          footer: (pw.Context context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ),
        ),
      );

      // 6. Cetak / Simpan PDF
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'FireFit_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating report: $e")),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Export Data"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf, size: 80, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            const Text(
              "Export Running History",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Generate a professional PDF report containing your workout statistics, distance charts, and detailed history record.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            _isGenerating
                ? const CircularProgressIndicator(color: Colors.orange)
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _generatePdf(context),
                      icon: const Icon(Icons.file_download),
                      label: const Text("Generate PDF Report"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}