enum AppRoute {
  timeline(name: 'timeline', path: '/'),
  addMemory(name: 'add-memory', path: '/memory/new'),
  memoryDetail(name: 'memory-detail', path: '/memory/:memoryId'),
  editMemory(name: 'edit-memory', path: '/memory/:memoryId/edit'),
  search(name: 'search', path: '/search'),
  archive(name: 'archive', path: '/archive'),
  explore(name: 'explore', path: '/explore'),
  stories(name: 'stories', path: '/stories'),
  you(name: 'you', path: '/you');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}
