import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isScanned = false; // لتجنب استدعاء Get.back() مرتين

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final String? code = barcodes.isNotEmpty
              ? barcodes.first.rawValue
              : null;

          if (code != null && !isScanned) {
            isScanned = true; // تأكد من أن الباركود يتم معالجته مرة واحدة فقط
            Get.back(result: code);
          }
        },
      ),
    );
  }
}
