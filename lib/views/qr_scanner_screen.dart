import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../globals.dart';
import '../model/guest_info.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (scanResult != null)
                  ? Text(
                      'Data: $scanResult',
                      style: const TextStyle(fontSize: 18),
                    )
                  : const Text('Scan a code', style: TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        String decryptedData = manager.decryptUserInfo("${scanData.code}");
        _showInformationPopup(context, decryptedData.replaceAll('"', ""));
      });
    });
  }

  void _showInformationPopup(BuildContext context, String decryptedData) {
    controller?.pauseCamera();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance
              .ref("convidados")
              .child(decryptedData)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Erro ao carregar dados"));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Usuário não encontrado"));
            }

            if (snapshot.data!.value == null) {
              return const Center(child: Text("Usuário não encontrado"));
            }

            String key = snapshot.data!.key!;

            final guestData = snapshot.data!.value as Map<dynamic, dynamic>;
            GuestInfo guestInfo = GuestInfo.fromJson(guestData, key);

            return AlertDialog(
              title: const Text('Informações'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nome: ${guestInfo.name}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Telefone: ${guestInfo.phone}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Foi pago? ${guestInfo.payed}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Responsável: ${guestInfo.affiliated}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  guestInfo.payed == 'Sim ✅'
                      ? const Text(
                          '✅ Check-in realizado com sucesso!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        )
                      : const Text(
                          '⚠️ Pagamento pendente.',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(196, 184, 14, 1)),
                        ),
                ],
              ),
              actions: <Widget>[
                Row(children: [
                  TextButton(
                    child: const Text('Fazer check-in'),
                    onPressed: () {
                      _guestCheckInProcess(guestInfo, true, guestInfo.payed);
                      controller?.resumeCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  guestInfo.payed == 'Não ⚠️'
                      ? TextButton(
                          child: const Text('Pago no momento'),
                          onPressed: () {
                            _guestCheckInProcess(guestInfo, true, "Sim ✅");
                            controller?.resumeCamera();
                            Navigator.of(context).pop();
                          },
                        )
                      : const SizedBox(),
                ]),
              ],
            );
          },
        );
      },
    ).then((value) {
      controller?.resumeCamera();
    });
  }

  _guestCheckInProcess(GuestInfo guest, bool check, String payed) {
    FirebaseDatabase db = FirebaseDatabase.instance;

    Map<String, dynamic> guestData = {
      'name': guest.name,
      'phone': guest.phone,
      'payed': payed,
      'affiliated': guest.affiliated,
      'checked_in': check,
    };

    var key = db.ref("convidados").child(guest.uid);

    key.set(guestData).then((value) => print("Cadastrado com sucesso!"));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
