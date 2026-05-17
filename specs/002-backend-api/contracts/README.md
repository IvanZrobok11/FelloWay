# Contracts — feature `002-backend-api`

Canonical REST/OpenAPI definitions for this feature live in the monorepo shared tree:

**[shared/api-contracts/](../../../shared/api-contracts/)**

| Domain folder | OpenAPI |
|---------------|---------|
| [auth/](../../../shared/api-contracts/auth/openapi.yaml) | OAuth token exchange, Stream token |
| [users/](../../../shared/api-contracts/users/openapi.yaml) | Profile, avatar, preferences, reviews, block |
| [common/](../../../shared/api-contracts/common/openapi.yaml) | Errors, pagination, shared schemas |
| [events/](../../../shared/api-contracts/events/openapi.yaml) | Events, attendance, trips, reviews on events |

Legacy mobile index (being migrated): [001 rest-endpoints.md](../../001-event-networking-app/contracts/rest-endpoints.md).

Swashbuckle in `backend/` SHOULD reference these files or generated clients in a later task.
