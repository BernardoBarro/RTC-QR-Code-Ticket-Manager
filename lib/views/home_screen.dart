import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/guess_provider.dart';
import 'qr_scanner_screen.dart';
import 'list_screen.dart';
import 'add_guest_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = const [
    QRScannerScreen(),
    ListScreen(),
    AddGuestScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _copyCheckedInNames(BuildContext context) {
    final guests = Provider.of<GuestsProvider>(context, listen: false).guest;
    final names = guests
        .where((g) => g.checkedIn == true)
        .map((g) => g.name)
        .join('\n');

    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum convidado com check-in.')),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: names));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nomes copiados para área de transferência!')),
    );
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
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            tooltip: 'Copiar nomes checked-in',
            onPressed: () => _copyCheckedInNames(context),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Convidar'),
        ],
      ),
    );
  }
}
