enum AppRoute {
  timeline(name: 'timeline', path: '/'),
  addMemory(name: 'add-memory', path: '/memory/new'),
  memoryDetail(name: 'memory-detail', path: '/memory/:memoryId'),
  editMemory(name: 'edit-memory', path: '/memory/:memoryId/edit'),
  search(name: 'search', path: '/search'),
  askMyLife(name: 'ask-my-life', path: '/ask'),
  archive(name: 'archive', path: '/archive'),
  trash(name: 'trash', path: '/trash'),
  memoryInbox(name: 'memory-inbox', path: '/inbox'),
  candidateReview(name: 'candidate-review', path: '/inbox/:candidateId'),
  security(name: 'security', path: '/security'),
  setPin(name: 'set-pin', path: '/security/pin'),
  createBackup(name: 'create-backup', path: '/backup/create'),
  backupProgress(name: 'backup-progress', path: '/backup/progress'),
  backupComplete(name: 'backup-complete', path: '/backup/complete'),
  restoreEntry(name: 'restore-entry', path: '/restore'),
  chooseBackup(name: 'choose-backup', path: '/restore/choose'),
  enterRecoveryPassword(
    name: 'enter-recovery-password',
    path: '/restore/password',
  ),
  restorePreview(name: 'restore-preview', path: '/restore/preview'),
  restoreProgress(name: 'restore-progress', path: '/restore/progress'),
  restoreResult(name: 'restore-result', path: '/restore/result'),
  explore(name: 'explore', path: '/explore'),
  stories(name: 'stories', path: '/stories'),
  storyEditor(name: 'story-editor', path: '/stories/editor'),
  storyPreview(name: 'story-preview', path: '/stories/preview'),
  thenNowSelection(name: 'then-now-selection', path: '/stories/then-now'),
  storageManager(name: 'storage-manager', path: '/storage'),
  you(name: 'you', path: '/you');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}
