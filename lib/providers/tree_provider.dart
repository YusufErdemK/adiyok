import 'package:flutter/material.dart';
import '../models/tree_node.dart';

class TreeProvider extends ChangeNotifier {
  TreeNode? _selectedNode;
  List<TreeNode> _roots = [];

  TreeProvider() {
    _initializeEmptyTree();
  }

  void _initializeEmptyTree() {
    _roots = [];
    notifyListeners();
  }

  List<TreeNode> get roots => _roots;
  TreeNode? get selectedNode => _selectedNode;
  int get totalRoots => _roots.length;

  /// Yeni bir kök nod ekle
  void addRoot(String name, {String? description, String? category}) {
    final newRoot = TreeNode(
      name: name,
      description: description,
      category: category,
    );
    _roots.add(newRoot);
    _selectedNode = newRoot;
    notifyListeners();
  }

  /// Belirtilen kökten alt eleman ekle
  void addChild(
    String parentId,
    String childName, {
    String? description,
    String? category,
  }) {
    for (var root in _roots) {
      final parent = root.findNodeById(parentId);
      if (parent != null) {
        final newChild = TreeNode(
          name: childName,
          description: description,
          category: category,
        );
        parent.addChild(newChild);
        _selectedNode = newChild;
        notifyListeners();
        return;
      }
    }
  }

  /// Bir nodu genişlet/daralt
  void toggleNodeExpansion(String nodeId) {
    for (int i = 0; i < _roots.length; i++) {
      final node = _roots[i].findNodeById(nodeId);
      if (node != null) {
        node.isExpanded = !node.isExpanded;
        // Root'u güncelle (immutable pattern)
        _roots[i] = _roots[i];
        notifyListeners();
        return;
      }
    }
  }

  /// Belirtilen nodu seç
  void selectNode(String nodeId) {
    for (var root in _roots) {
      final node = root.findNodeById(nodeId);
      if (node != null) {
        _selectedNode = node;
        notifyListeners();
        return;
      }
    }
  }

  /// Belirtilen nodu sil
  void deleteNode(String nodeId) {
    _roots.removeWhere((root) => root.id == nodeId);

    for (var root in _roots) {
      if (_deleteNodeRecursive(root, nodeId)) {
        if (_selectedNode?.id == nodeId) {
          _selectedNode = null;
        }
        notifyListeners();
        return;
      }
    }
  }

  bool _deleteNodeRecursive(TreeNode node, String targetId) {
    final childRemoved = node.removeChild(targetId);
    if (childRemoved) {
      if (_selectedNode?.id == targetId) {
        _selectedNode = null;
      }
      return true;
    }

    for (var child in node.children) {
      if (_deleteNodeRecursive(child, targetId)) {
        return true;
      }
    }
    return false;
  }

  /// Belirtilen nodu güncelle
  void updateNode(
    String nodeId,
    String newName, {
    String? newDescription,
    String? newCategory,
  }) {
    for (int i = 0; i < _roots.length; i++) {
      if (_updateNodeRecursive(
        _roots[i],
        nodeId,
        newName,
        newDescription,
        newCategory,
      )) {
        notifyListeners();
        return;
      }
    }
  }

  bool _updateNodeRecursive(
    TreeNode node,
    String targetId,
    String newName,
    String? newDescription,
    String? newCategory,
  ) {
    if (node.id == targetId) {
      node = node.copyWith(
        name: newName,
        description: newDescription,
        category: newCategory,
      );
      return true;
    }

    for (int i = 0; i < node.children.length; i++) {
      if (node.children[i].id == targetId) {
        node.children[i] = node.children[i].copyWith(
          name: newName,
          description: newDescription,
          category: newCategory,
        );
        return true;
      }
      if (_updateNodeRecursive(
        node.children[i],
        targetId,
        newName,
        newDescription,
        newCategory,
      )) {
        return true;
      }
    }
    return false;
  }

  /// Tüm kategorileri al (kök elemanlardan)
  List<String> getAllCategories() {
    final categories = <String>{};
    for (var root in _roots) {
      if (root.category != null && root.category!.isNotEmpty) {
        categories.add(root.category!);
      }
      _collectCategories(root, categories);
    }
    return categories.toList()..sort();
  }

  void _collectCategories(TreeNode node, Set<String> categories) {
    for (var child in node.children) {
      if (child.category != null && child.category!.isNotEmpty) {
        categories.add(child.category!);
      }
      _collectCategories(child, categories);
    }
  }

  /// Ağacın toplam derinliğini al
  int getMaxTreeDepth() {
    if (_roots.isEmpty) return 0;
    return _roots
        .map((root) => root.getDepth())
        .reduce((a, b) => a > b ? a : b);
  }

  /// Toplam nod sayısını al
  int getTotalNodeCount() {
    return _roots.fold(0, (sum, root) => sum + root.getTotalNodeCount());
  }

  /// Tüm ağacı temizle
  void clearAllTrees() {
    _roots.clear();
    _selectedNode = null;
    notifyListeners();
  }
}
