import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tree_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/tree_node_widget.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({Key? key}) : super(key: key);

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TreeProvider>(
      builder: (context, treeProvider, _) {
        final roots = treeProvider.roots;

        return Scaffold(
          appBar: AppBar(title: const Text('Ağaç'), centerTitle: true),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddRootDialog,
            icon: const Icon(Icons.add),
            label: const Text('Kök Eleman'),
          ),
          body: roots.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.nature, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz ağaç yok',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Başlamak için "Kök Eleman" butonuna tıklayın',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Toplam Kök',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  treeProvider.totalRoots.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Toplam Nod',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  treeProvider.getTotalNodeCount().toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[600],
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Max Derinlik',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  treeProvider.getMaxTreeDepth().toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[600],
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Trees
                      ...roots.asMap().entries.map((entry) {
                        final root = entry.value;
                        return Column(
                          children: [
                            TreeNodeWidget(
                              node: root,
                              onDelete: () {
                                treeProvider.deleteNode(root.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ağaç silindi')),
                                );
                              },
                              onEdit: () {
                                _showEditRootDialog(
                                  root.id,
                                  root.name,
                                  root.description,
                                );
                              },
                            ),
                            if (entry.key < roots.length - 1)
                              const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _showAddRootDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kök Eleman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Ad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (İsteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori (İşlem sırasında kullanılabilir)',
                hintText: 'Örn: Kira, Maaş, Alışveriş',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<TreeProvider>().addRoot(
                  nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  category: categoryController.text.trim().isEmpty
                      ? null
                      : categoryController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kök eleman eklendi')),
                );
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showEditRootDialog(String id, String currentName, String? currentDesc) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    final TextEditingController descController = TextEditingController(
      text: currentDesc,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kök Elemanı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<TreeProvider>().updateNode(
                  id,
                  nameController.text.trim(),
                  newDescription: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
