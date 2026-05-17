# API Contracts (feature `001-event-networking-app`)

REST boundaries for this feature are maintained in the monorepo contract tree:

**[shared/api-contracts/](../../../shared/api-contracts/)**

```
shared/api-contracts/
├── auth/
├── users/
├── common/
└── events/
```

- [rest-endpoints.md](./rest-endpoints.md) — legacy mobile consumer summary (to be split into domain folders above).

OpenAPI YAML should live under `shared/api-contracts/<domain>/` when the backend publishes canonical shapes.
