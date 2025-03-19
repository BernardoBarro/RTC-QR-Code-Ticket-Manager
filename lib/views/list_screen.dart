import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rtc_project/views/add_guest_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Consumer<GuestsProvider>(
              builder: (context, list, child) {
                return list.guest.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Você ainda não tem anotações cadastradas!",
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
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
