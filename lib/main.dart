import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    CalculateScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: Platform.isWindows ? 400 : double.infinity,
          height: Platform.isWindows ? 600 : double.infinity,
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Рассчитать'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime minDate = DateTime(today.year - 18, today.month, today.day);
    String formattedDate = DateFormat('dd.MM.yyyy').format(minDate);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Минимальная дата покупки алкоголя:',
            style: TextStyle(fontSize: Platform.isWindows ? 22 : 18),
          ),
          SizedBox(height: 10),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: Platform.isWindows ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CalculateScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final focusNode = useFocusNode();
    final ageCheckResult = useState<String>('');
    final ageCheckColor = useState<Color>(Colors.black);

    void validateAge(String input) {
      if (input.length == 10) {
        try {
          DateTime inputDate = DateFormat('dd.MM.yyyy').parseStrict(input);
          DateTime minDate = DateTime.now().subtract(Duration(days: 18 * 365));
          if (inputDate.isBefore(minDate) || inputDate.isAtSameMomentAs(minDate)) {
            ageCheckResult.value = 'Можно продать';
            ageCheckColor.value = Colors.green;
          } else {
            ageCheckResult.value = 'Нельзя продать';
            ageCheckColor.value = Colors.red;
          }
        } catch (_) {
          ageCheckResult.value = 'Некорректная дата';
          ageCheckColor.value = Colors.orange;
        }
      } else {
        ageCheckResult.value = '';
      }
    }

    useEffect(() {
      Future.delayed(Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(focusNode);
      });
      return null;
    }, []);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              focusNode: focusNode,
              controller: textController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: 'Введите дату (дд.мм.гггг)',
                border: OutlineInputBorder(),
              ),
              onChanged: validateAge,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),

            ),
            SizedBox(height: 20),
            Text(
              ageCheckResult.value,
              style: TextStyle(
                fontSize: Platform.isWindows ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: ageCheckColor.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}