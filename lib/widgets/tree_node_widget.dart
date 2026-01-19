import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tree_node.dart';
import '../providers/tree_provider.dart';
import 'glass_card.dart';

class TreeNodeWidget extends StatefulWidget {
  final TreeNode node;
  final int depth;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TreeNodeWidget({
    Key? key,
    required this.node,
    this.depth = 0,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  State<TreeNodeWidget> createState() => _TreeNodeWidgetState();
}

class _TreeNodeWidgetState extends State<TreeNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.node.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(TreeNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Node'un isExpanded state'i değiştiğinde animasyonu güncelle
    if (widget.node.isExpanded && !oldWidget.node.isExpanded) {
      _animationController.forward();
    } else if (!widget.node.isExpanded && oldWidget.node.isExpanded) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;

    // Animasyon controller'ı node state'i ile senkronize et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.node.isExpanded && !_animationController.isCompleted) {
        _animationController.forward();
      } else if (!widget.node.isExpanded && _animationController.isCompleted) {
        _animationController.reverse();
      }
    });

    final isSelected = context.select<TreeProvider, bool>(
      (provider) => provider.selectedNode?.id == widget.node.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node Card
        Padding(
          padding: EdgeInsets.only(left: widget.depth * 16.0),
          child: GlassCard(
            isSelected: isSelected,
            onTap: () {
              context.read<TreeProvider>().selectNode(widget.node.id);
              if (hasChildren) {
                context.read<TreeProvider>().toggleNodeExpansion(
                  widget.node.id,
                );
              }
            },
            backgroundColor: _getBackgroundColor(context, isSelected),
            child: Row(
              children: [
                // Expand/Collapse Button
                if (hasChildren)
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0,
                      end: 0.5,
                    ).animate(_animationController),
                    child: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  )
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 12),
                // Node Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.node.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.node.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.node.description!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (widget.node.category != null) ...[
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            widget.node.category!,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.blue[100],
                          side: BorderSide(color: Colors.blue[300]!),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${widget.node.getTotalNodeCount()} nod • Derinlik: ${widget.node.getDepth()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      widget.onDelete?.call();
                    } else if (value == 'edit') {
                      widget.onEdit?.call();
                    } else if (value == 'add_child') {
                      _showAddChildDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'add_child',
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 8),
                          Text('Alt Eleman Ekle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Children
        SizeTransition(
          sizeFactor: _animationController,
          child: Column(
            children: widget.node.children
                .map(
                  (child) => TreeNodeWidget(
                    node: child,
                    depth: widget.depth + 1,
                    onDelete: () {
                      context.read<TreeProvider>().deleteNode(child.id);
                    },
                    onEdit: () {
                      _showEditDialog(context, child);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context, bool isSelected) {
    if (isSelected) {
      return Theme.of(context).primaryColor.withAlpha(25);
    }
    return Colors.transparent;
  }

  void _showAddChildDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alt Eleman Ekle'),
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
                context.read<TreeProvider>().addChild(
                  widget.node.id,
                  nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  category: categoryController.text.trim().isEmpty
                      ? null
                      : categoryController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TreeNode node) {
    final TextEditingController nameController = TextEditingController(
      text: node.name,
    );
    final TextEditingController descController = TextEditingController(
      text: node.description,
    );
    final TextEditingController categoryController = TextEditingController(
      text: node.category,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elemanı Düzenle'),
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
                context.read<TreeProvider>().updateNode(
                  node.id,
                  nameController.text.trim(),
                  newDescription: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  newCategory: categoryController.text.trim().isEmpty
                      ? null
                      : categoryController.text.trim(),
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
