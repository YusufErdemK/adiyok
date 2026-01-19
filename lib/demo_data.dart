// Bu dosya demo ve test amaçlı örnek veri oluşturur
// main.dart'ta çağrılıp test edilebilir

import 'providers/tree_provider.dart';
import 'providers/transaction_provider.dart';
import 'models/transaction.dart';

/// Demo uygulamasında kullanılmak üzere örnek veri oluşturur
void setupDemoData(
  TreeProvider treeProvider,
  TransactionProvider transactionProvider,
) {
  // Örnek Ağaç Yapısı
  treeProvider.addRoot(
    'Kişisel Projeler',
    description: 'Günlük kişisel çalışmalarım',
  );
  final personalId = treeProvider.roots[0].id;

  treeProvider.addChild(
    personalId,
    'Flutter Uygulaması',
    description: 'Adiyok app development',
  );
  treeProvider.addChild(
    personalId,
    'Web Sitesi',
    description: 'React ile web geliştirme',
  );

  // İkinci ağaç
  treeProvider.addRoot(
    'İş Projeler',
    description: 'Şirkette çalıştığım projeler',
  );
  final workId = treeProvider.roots[1].id;

  treeProvider.addChild(
    workId,
    'E-Commerce Platform',
    description: 'Online satış platformu',
  );
  treeProvider.addChild(
    workId,
    'Mobile App',
    description: 'Android/iOS uygulaması',
  );

  // Örnek İşlemler
  final today = DateTime.now();
  final lastMonth = today.subtract(const Duration(days: 30));

  // Gelirler
  transactionProvider.addTransaction(
    Transaction(
      title: 'Aylık Maaş',
      amount: 5000,
      category: TransactionCategory.salary,
      date: today,
      description: 'Ocak ayı maaşı',
    ),
  );

  transactionProvider.addTransaction(
    Transaction(
      title: 'Freelance Proje',
      amount: 1500,
      category: TransactionCategory.freelance,
      date: today.subtract(const Duration(days: 3)),
      description: 'Web tasarımı projesi',
    ),
  );

  transactionProvider.addTransaction(
    Transaction(
      title: 'Bonus',
      amount: 2000,
      category: TransactionCategory.salary,
      date: lastMonth,
      description: 'Aralık ayı performans bonusu',
    ),
  );

  // Giderler
  transactionProvider.addTransaction(
    Transaction(
      title: 'Daire Kirası',
      amount: 2500,
      category: TransactionCategory.rent,
      date: today,
      description: 'Şubat ayı kira ödemesi',
    ),
  );

  transactionProvider.addTransaction(
    Transaction(
      title: 'Elektrik Faturası',
      amount: 350,
      category: TransactionCategory.utilities,
      date: today.subtract(const Duration(days: 5)),
    ),
  );

  transactionProvider.addTransaction(
    Transaction(
      title: 'Restorana Gidiş',
      amount: 450,
      category: TransactionCategory.food,
      date: today.subtract(const Duration(days: 2)),
      description: 'Arkadaşlarla yemek',
    ),
  );

  transactionProvider.addTransaction(
    Transaction(
      title: 'Taksi Ücreti',
      amount: 80,
      category: TransactionCategory.transport,
      date: today.subtract(const Duration(days: 1)),
    ),
  );

  transactionProvider.addTransaction(
    Transaction(
      title: 'Mobilya',
      amount: 3000,
      category: TransactionCategory.shopping,
      date: lastMonth,
      description: 'Salon mobilyaları',
    ),
  );

  print('✅ Demo veri oluşturuldu!');
}
