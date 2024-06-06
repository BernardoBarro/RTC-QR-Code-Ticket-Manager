import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rtc_project/provider/convidado_provider.dart';
import 'package:rtc_project/views/qr_code_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'globals.dart';
import 'model/user_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ChangeNotifierProvider(create: (context) => AnotationProvider());
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AnotationProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const QR_Code(),
    const ListScreen(),
    Add(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "III Festival de Tortas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Convidar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  void showDeleteDialog(
      BuildContext context, AnotationProvider list, UserInfoA anotation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Deleção'),
          content: Text(
              'Você tem certeza que deseja deletar o ingresso de ${anotation.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Fecha o diálogo sem realizar ação
              },
            ),
            TextButton(
              child: Text('Deletar'),
              onPressed: () {
                list.delete(anotation); // Chama a função para deletar o item
                Navigator.of(context).pop(); // Fecha o diálogo após a ação
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
            child: Consumer<AnotationProvider>(
              builder: (context, list, child) {
                return list.anotation.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Você ainda não tem anotações cadastradas!",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.anotation.length,
                        itemBuilder: (BuildContext context, int index) {
                          final anotation = list.anotation[index];

                          Widget paymentStatusWidget;
                          if (anotation.checked_in! &&
                              anotation.payed == 'Sim ✅') {
                            paymentStatusWidget = const Text(
                              '✅ Check-in realizado com sucesso!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            );
                          } else if (anotation.checked_in! &&
                              anotation.payed == 'Não ⚠️') {
                            paymentStatusWidget = const Text(
                              '⚠️ Check-in realizado sem pagar',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(196, 184, 14, 1)),
                            );
                          } else {
                            paymentStatusWidget = Text(
                              "Foi pago? ${anotation.payed}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          return ExpansionTile(
                            title: Text(anotation.name),
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
                                        builder: (context) => Add(
                                              userInfo: anotation,
                                            )));
                              },
                            ),
                            children: [
                              ListTile(
                                title: Text(
                                    "Responsável: ${anotation.affiliated}"),
                                subtitle: Text("Telefone: ${anotation.phone}"),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDeleteDialog(context, list, anotation);
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

class QR_Code extends StatefulWidget {
  const QR_Code({super.key});

  @override
  State<StatefulWidget> createState() => _QR_CodeState();
}

class _QR_CodeState extends State<QR_Code> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var result;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
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
              child: (result != null)
                  ? Text(
                      'Data: ${result}',
                      style: TextStyle(fontSize: 18),
                    )
                  : Text('Scan a code', style: TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        var decryptedData = manager.decryptUserInfo("${scanData.code}");
        _showInformationPopup(context, decryptedData.replaceAll('"', ""));
      });
    });
  }

  _realizarCheckInConvidado(UserInfoA user, bool check, String payed) {
    FirebaseDatabase db = FirebaseDatabase.instance;

    Map<String, dynamic> dataUser = {
      'name': user.name,
      'phone': user.phone,
      'payed': payed,
      'affiliated': user.affiliated,
      'checked_in': check,
    };

    var key = db.ref("convidados").child(user.uid);

    key.set(dataUser).then((value) => print("Cadastrado com sucesso!"));

    return key.key;
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
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Erro ao carregar dados"));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("Usuário não encontrado"));
            }

            if (snapshot.data!.value == null) {
              return Center(child: Text("Usuário não encontrado"));
            }

            String a = snapshot.data!.key!;

            final userData = snapshot.data!.value as Map<dynamic, dynamic>;
            UserInfoA userInfo = UserInfoA.fromJson(userData, a);

            return AlertDialog(
              title: Text('Informações'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nome: ${userInfo.name}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Telefone: ${userInfo.phone}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Foi pago? ${userInfo.payed}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Responsável: ${userInfo.affiliated}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  userInfo.payed == 'Sim ✅'
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
                    child: Text('Fazer check-in'),
                    onPressed: () {
                      _realizarCheckInConvidado(userInfo, true, userInfo.payed);
                      controller?.resumeCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  userInfo.payed == 'Não ⚠️'
                      ? TextButton(
                          child: Text('Pago no momento'),
                          onPressed: () {
                            _realizarCheckInConvidado(userInfo, true, "Sim ✅");
                            controller?.resumeCamera();
                            Navigator.of(context).pop();
                          },
                        )
                      : SizedBox(),
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class Add extends StatefulWidget {
  final UserInfoA? userInfo;

  Add({Key? key, this.userInfo}) : super(key: key);

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _personNameController;
  late TextEditingController _personPhoneController;
  late String yesNo;
  late String _selectedOption;

  _adicionarConvidado(
      String name, String phone, String payed, String affiliated) {
    FirebaseDatabase db = FirebaseDatabase.instance;

    Map<String, dynamic> dataUser = {
      'name': name,
      'phone': phone,
      'payed': payed,
      'affiliated': affiliated,
      'checked_in': false,
    };

    var key = db.ref("convidados").push();

    key.set(dataUser).then((value) => print("Cadastrado com sucesso!"));

    return key.key;
  }

  _editarConvidado(String uid, String name, String phone, String payed,
      String affiliated, bool checked_in) {
    FirebaseDatabase db = FirebaseDatabase.instance;

    Map<String, dynamic> dataUser = {
      'name': name,
      'phone': phone,
      'payed': payed,
      'affiliated': affiliated,
      'checked_in': checked_in,
    };

    var key = db.ref("convidados").child(uid);

    key.set(dataUser).then((value) => print("Cadastrado com sucesso!"));

    return key.key;
  }

  @override
  void initState() {
    super.initState();
    _personNameController =
        TextEditingController(text: widget.userInfo?.name ?? '');
    _personPhoneController =
        TextEditingController(text: widget.userInfo?.phone ?? '');
    yesNo = widget.userInfo?.payed ?? 'Não ⚠️';
    _selectedOption = widget.userInfo?.affiliated ?? 'Selecione';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
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
                    decoration: InputDecoration(
                      labelText: 'Coloque o nome do convidado:',
                    ),
                  ),
                  SizedBox(height: 30),
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
                    decoration: InputDecoration(
                        labelText: 'Adicione o telefone do convidado:'),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 30),
                  Text('Já está pago?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: const Text('Sim'),
                          leading: Radio<String>(
                            value: 'Sim ✅',
                            groupValue: yesNo,
                            onChanged: (String? value) {
                              setState(() {
                                yesNo = value!;
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
                            groupValue: yesNo,
                            onChanged: (String? value) {
                              setState(() {
                                yesNo = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text('Quem vendeu o ingresso?'),
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
                      'Daiana',
                      'Isabelle',
                      'José',
                      'Júlia',
                      'Kauã',
                      'Lara',
                      'Leonardo',
                      'Lucas',
                      'Mathias',
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
                          if (widget.userInfo == null) {
                            key = _adicionarConvidado(
                                _personNameController.text,
                                _personPhoneController.text,
                                yesNo,
                                _selectedOption);
                          } else {
                            key = _editarConvidado(
                                widget.userInfo!.uid,
                                _personNameController.text,
                                _personPhoneController.text,
                                yesNo,
                                _selectedOption,
                                widget.userInfo!.checked_in!);
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
                      child: Text('Gerar QR Code'),
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
