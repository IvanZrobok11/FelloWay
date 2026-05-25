# Contract: Interests catalog API

**Version**: 1.0  
**Date**: 2026-05-20  
**OpenAPI fragment**: `shared/api-contracts/reference/openapi.yaml` (new)

## GET /interests

**Summary**: List all professional interests (reference catalog).

**Security**: None (public reference data for onboarding).

**Response 200**:

```json
{
  "items": [
    {
      "id": "11111111-1111-1111-1111-111111110001",
      "name": "ІТ та розробка",
      "sortOrder": 1
    }
  ]
}
```

**Schema `InterestCatalogItem`**:

| Property | Type | Required |
|----------|------|----------|
| `id` | string (uuid) | yes |
| `name` | string | yes |
| `sortOrder` | integer | yes |

**Errors**: Standard envelope from `common/openapi.yaml` for 5xx only.

---

## UserProfile extension (users/openapi.yaml)

**`UserProfile`** adds:

```yaml
interests:
  type: array
  items:
    $ref: '#/components/schemas/InterestCatalogItem'
```

**Semantics**: Resolved catalog entries for ids in `interestIds`; empty array if none selected. Order follows `sortOrder`.

**`UserProfileUpdate`**: unchanged — still `interestIds: uuid[]` only.

---

## Client usage

| Flow | Calls |
|------|-------|
| Onboarding `/onboarding/interests` | `GET /interests` → chips by `name`, store `id` in draft |
| Profile view | `GET /users/me` → display `interests[].name` |
| Profile edit | `GET /interests` + selected ids from profile → chips → `PUT interestIds` |

---

## Versioning

Adding `GET /interests` and optional `UserProfile.interests` is backward compatible for clients that only use `interestIds`.
