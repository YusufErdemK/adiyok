import 'package:flutter/material.dart';
import '../models/tree_node.dart';
import '../services/storage_service.dart';

class TreeProvider extends ChangeNotifier {
  TreeNode? _selectedNode;
  List<TreeNode> _roots = [];
  bool _isLoading = true;

  TreeProvider() {
    _initializeTree();
  }

  Future<void> _initializeTree() async {
    _roots = await StorageService.loadTreeData();
    _isLoading = false;
    notifyListeners();
  }

  List<TreeNode> get roots => _roots;
  TreeNode? get selectedNode => _selectedNode;
  int get totalRoots => _roots.length;
  bool get isLoading => _isLoading;

  void addRoot(String name, {String? description, String? category}) {
    final newRoot = TreeNode(
      name: name,
      description: description,
      category: category,
    );
    _roots.add(newRoot);
    _selectedNode = newRoot;
    _saveTreeData();
    notifyListeners();
  }

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
        _saveTreeData();
        notifyListeners();
        return;
      }
    }
  }

  void toggleNodeExpansion(String nodeId) {
    for (int i = 0; i < _roots.length; i++) {
      final node = _roots[i].findNodeById(nodeId);
      if (node != null) {
        node.isExpanded = !node.isExpanded;
        _roots[i] = _roots[i];
        _saveTreeData();
        notifyListeners();
        return;
      }
    }
  }

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

  void deleteNode(String nodeId) {
    final rootRemoved = _roots.any((root) => root.id == nodeId);
    _roots.removeWhere((root) => root.id == nodeId);

    if (rootRemoved) {
      if (_selectedNode?.id == nodeId) {
        _selectedNode = null;
      }
      _saveTreeData();
      notifyListeners();
      return;
    }

  for (var root in _roots) {
    if (_deleteNodeRecursive(root, nodeId)) {
      _saveTreeData();
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
        _saveTreeData();
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

  int getMaxTreeDepth() {
    if (_roots.isEmpty) return 0;
    return _roots
        .map((root) => root.getDepth())
        .reduce((a, b) => a > b ? a : b);
  }

  int getTotalNodeCount() {
    return _roots.fold(0, (sum, root) => sum + root.getTotalNodeCount());
  }

  void clearAllTrees() async {
    _roots.clear();
    _selectedNode = null;
    await StorageService.clearAllData();
    notifyListeners();
  }

  Future<void> _saveTreeData() async {
    await StorageService.saveTreeData(_roots);
  }
}
