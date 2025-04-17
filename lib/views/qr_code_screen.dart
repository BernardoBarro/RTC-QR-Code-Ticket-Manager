import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            child: Screenshot(
              controller: screenshotController,
              child: Stack(children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/qrcodeview.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0.0, -0.35),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.dmSans(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      QrImageView(
                        backgroundColor: Colors.white,
                        data: data,
                        version: QrVersions.auto,
                        size: 170.0,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.share),
        onPressed: () async {
          try {
            final imageBytes = await screenshotController.capture();
            if (imageBytes != null) {
              final tempDir = await getTemporaryDirectory();
              final file = await File('${tempDir.path}/qrcode.png').create();
              await file.writeAsBytes(imageBytes);

              await Share.shareXFiles(
                [XFile(file.path)],
                text: 'Este é seu ingresso para o III Festival de Tortas do Rotaract Club de Erechim aguardaremos ansiosamente a sua presença!',
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
