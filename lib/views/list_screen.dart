import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:rtc_project/views/add_guest_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../model/guest_info.dart';
import '../provider/guess_provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  void showDeleteDialog(
      BuildContext context, GuestsProvider list, GuestInfo guestInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Deleção'),
          content: Text(
              'Você tem certeza que deseja deletar o ingresso de ${guestInfo.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Deletar'),
              onPressed: () {
                list.delete(guestInfo);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String removeEmojis(String input) {
    final filtered = input.runes.where((r) => r <= 0xFF);
    return String.fromCharCodes(filtered).trim();
  }

  Future<void> _exportToPdf() async {
    final guests = Provider.of<GuestsProvider>(context, listen: false).guest;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(24),
        header: (pw.Context ctx) {
          return pw.Text(
            'Lista de Convidados',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          );
        },
        build: (pw.Context ctx) => [
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Nome', 'Responsável', 'Telefone', 'Check-in', 'Pago'],
            data: guests.map((g) {
              return [
                g.name,
                g.affiliated,
                g.phone,
                g.checkedIn == true? 'Sim' : 'Não',
                removeEmojis(g.payed),
              ];
            }).toList(),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            headerStyle: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: .5, color: PdfColors.grey),
              ),
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/FestivalDeTortasIII.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Lista de Convidados PDF');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF salvo em: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GuestsProvider>(
        builder: (context, list, child) {
          final count = list.guest.length;
          Color bgColor;
          if (count < 70) {
            bgColor = Colors.green;
          } else if (count < 80) {
            bgColor = Colors.yellow;
          } else if (count == 80) {
            bgColor = Colors.pink;
          } else {
            bgColor = Colors.red;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: bgColor,
                child: Text(
                  '$count/80',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              Expanded(
                child: list.guest.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Você ainda não tem convidados cadastrados!",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.guest.length,
                        itemBuilder: (BuildContext context, int index) {
                          final guest = list.guest[index];

                          Widget paymentStatusWidget;
                          if (guest.checkedIn! && guest.payed == 'Sim ✅') {
                            paymentStatusWidget = const Text(
                              '✅ Check-in realizado com sucesso!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            );
                          } else if (guest.checkedIn! &&
                              guest.payed == 'Não ⚠️') {
                            paymentStatusWidget = const Text(
                              '⚠️ Check-in realizado sem pagar',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(196, 184, 14, 1)),
                            );
                          } else {
                            paymentStatusWidget = Text(
                              "Foi pago? ${guest.payed}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          return ExpansionTile(
                            title: Text(guest.name),
                            subtitle: paymentStatusWidget,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddGuestScreen(
                                              guestInfo: guest,
                                            )));
                              },
                            ),
                            children: [
                              ListTile(
                                title: Text("Responsável: ${guest.affiliated}"),
                                subtitle: Text("Telefone: ${guest.phone}"),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDeleteDialog(context, list, guest);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportToPdf,
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
