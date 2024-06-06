import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../globals.dart';

class QRCodeScreen extends StatelessWidget {
  final String dataKey;
  final String name;

  const QRCodeScreen({super.key, required this.dataKey, required this.name});

  @override
  Widget build(BuildContext context) {
    String data = manager.encryptUserInfo(dataKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "III Festival de Tortas",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 200.0,
            ),
            Image.asset(
              'assets/logo.png',
              width: 250,
              height: 150,
              // fit: BoxFit.cover,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
