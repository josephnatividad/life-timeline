# Feature boundaries

Each non-trivial feature may contain:

```text
feature/
├── domain/          pure Dart models, rules, and meaningful ports
├── application/     use cases and orchestration
├── infrastructure/  Drift, filesystem, and platform implementations
└── presentation/    Flutter widgets and Riverpod presentation state
```

Dependencies point inward: presentation → application → domain.
Infrastructure implements ports owned by inner layers. Flutter, Riverpod,
Drift, and platform SDKs must not leak into domain code. Trivial features do
not need empty layers solely for ceremony.

The current files are navigation placeholders only. Product features, domain
models, persistence tables, authentication, backup, sharing, and intelligence
are intentionally not implemented in this scaffold.
