enum AppRoute {
  timeline(name: 'timeline', path: '/'),
  explore(name: 'explore', path: '/explore'),
  stories(name: 'stories', path: '/stories'),
  you(name: 'you', path: '/you');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}
