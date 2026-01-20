import 'package:uuid/uuid.dart';

const uuid = Uuid();

class TreeNode {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final List<TreeNode> children;
  final DateTime createdAt;
  bool isExpanded;

  TreeNode({
    String? id,
    required this.name,
    this.description,
    this.category,
    List<TreeNode>? children,
    DateTime? createdAt,
    this.isExpanded = false,
  }) : id = id ?? uuid.v4(),
       children = children ?? [],
       createdAt = createdAt ?? DateTime.now();

  void addChild(TreeNode child) {
    children.add(child);
  }

  bool removeChild(String childId) {
    final originalLength = children.length;
    children.removeWhere((child) => child.id == childId);
    return children.length < originalLength;
  }

  TreeNode? findNodeById(String nodeId) {
    if (id == nodeId) return this;
    for (var child in children) {
      final found = child.findNodeById(nodeId);
      if (found != null) return found;
    }
    return null;
  }

  int getDepth() {
    if (children.isEmpty) return 1;
    return 1 +
        children
            .map((child) => child.getDepth())
            .reduce((a, b) => a > b ? a : b);
  }

  int getTotalNodeCount() {
    return 1 +
        children.fold(0, (sum, child) => sum + child.getTotalNodeCount());
  }

  TreeNode copyWith({
    String? name,
    String? description,
    String? category,
    List<TreeNode>? children,
    bool? isExpanded,
  }) {
    return TreeNode(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      children: children ?? this.children,
      createdAt: createdAt,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  String toString() =>
      'TreeNode(id: $id, name: $name, children: ${children.length})';
}
