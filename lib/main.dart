import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/tree_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  await initializeDateFormatting('tr_TR');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TreeProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final treeProvider = context.read<TreeProvider>();
            return TransactionProvider(treeProvider: treeProvider);
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Adiyok - Ağaç & Gelir/Gider Yönetimi',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D6A4F),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
