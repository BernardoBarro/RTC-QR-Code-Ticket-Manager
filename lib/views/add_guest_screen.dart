import 'package:flutter/material.dart';
import 'package:rtc_project/views/qr_code_screen.dart';

import '../model/guest_info.dart';
import '../service/firebase_service.dart';

class AddGuestScreen extends StatefulWidget {
  final GuestInfo? guestInfo;

  const AddGuestScreen({super.key, this.guestInfo});

  @override
  State<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _personNameController;
  late TextEditingController _personPhoneController;
  late String paymentInfo;
  late String _selectedOption;

  @override
  void initState() {
    super.initState();
    _personNameController =
        TextEditingController(text: widget.guestInfo?.name ?? '');
    _personPhoneController =
        TextEditingController(text: widget.guestInfo?.phone ?? '');
    paymentInfo = widget.guestInfo?.payed ?? 'Não ⚠️';
    _selectedOption = widget.guestInfo?.affiliated ?? 'Selecione';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor insira um nome';
                      }
                      return null;
                    },
                    controller: _personNameController,
                    decoration: const InputDecoration(
                      labelText: 'Coloque o nome do convidado:',
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    validator: (value) {
                      String pattern = r'(^\+?[0-9]{10,15}$)';
                      RegExp regExp = RegExp(pattern);

                      if (value == null || value.isEmpty) {
                        return 'Informe o número de telefone';
                      } else if (!regExp.hasMatch(value)) {
                        return 'Informe um número de telefone válido';
                      }
                      return null;
                    },
                    controller: _personPhoneController,
                    decoration: const InputDecoration(
                        labelText: 'Adicione o telefone do convidado:'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),
                  const Text('Já está pago?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: const Text('Sim'),
                          leading: Radio<String>(
                            value: 'Sim ✅',
                            groupValue: paymentInfo,
                            onChanged: (String? value) {
                              setState(() {
                                paymentInfo = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Não'),
                          leading: Radio<String>(
                            value: 'Não ⚠️',
                            groupValue: paymentInfo,
                            onChanged: (String? value) {
                              setState(() {
                                paymentInfo = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('Quem vendeu o ingresso?'),
                  DropdownButtonFormField<String>(
                    validator: (value) {
                      if (value == 'Selecione') {
                        return 'Por favor selecione uma opção';
                      }
                      return null;
                    },
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                      });
                    },
                    items: <String>[
                      'Selecione',
                      'Augusto',
                      'Bárbara',
                      'Bernardo',
                      'Brenda',
                      'Bruno',
                      'Eduarda',
                      'Fábio',
                      'Isabelle',
                      'José',
                      'Júlia',
                      'Kauã',
                      'Lara',
                      'Lucas',
                      'Mathias',
                      'Murillo',
                      'Raquel',
                      'Tales'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String key;
                          if (widget.guestInfo == null) {
                            key = FirebaseService.addGuest(
                                _personNameController.text,
                                _personPhoneController.text,
                                paymentInfo,
                                _selectedOption);
                          } else {
                            key = FirebaseService.editGuest(
                                widget.guestInfo!.uid,
                                _personNameController.text,
                                _personPhoneController.text,
                                paymentInfo,
                                _selectedOption,
                                widget.guestInfo!.checkedIn!);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QRCodeScreen(
                                    dataKey: key,
                                    name: _personNameController.text)),
                          );
                        }
                      },
                      child: const Text('Gerar QR Code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
