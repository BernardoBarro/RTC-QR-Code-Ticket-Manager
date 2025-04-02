import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../globals.dart';

class QRCodeScreen extends StatelessWidget {
  final String dataKey;
  final String name;

  QRCodeScreen({super.key, required this.dataKey, required this.name});

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    String data = manager.encryptUserInfo(dataKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "III Festival de Tortas",
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.share),
        onPressed: () async {
          try {
            final imageBytes = await screenshotController.capture();
            if (imageBytes != null) {
              final tempDir = await getTemporaryDirectory();
              final file = await File('${tempDir.path}/qrcode.png').create();
              await file.writeAsBytes(imageBytes);

              await Share.shareXFiles(
                [XFile(file.path)],
                text: 'Mensagem gerada automaticamente!',
              );
            }
          } catch (e) {
            debugPrint("Erro ao capturar ou compartilhar a imagem: $e");
          }
        },
      ),
    );
  }
}
