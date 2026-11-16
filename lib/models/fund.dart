class Fund {
  const Fund({required this.id, required this.name, required this.description});

  final String id;
  final String name;
  final String description;

  static const Fund globalIndex = Fund(
    id: 'global-index-fund',
    name: 'Global Index Fund',
    description: 'Low-cost exposure to large companies across world markets.',
  );
}
