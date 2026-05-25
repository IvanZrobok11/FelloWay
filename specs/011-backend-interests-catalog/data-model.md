# Data Model: Backend Interests Catalog (011)

**Date**: 2026-05-20

## Entities

### Interest (catalog row)

| Field | Type | Rules |
|-------|------|-------|
| `Id` | UUID | Fixed seed GUID, immutable after publish |
| `Name` | string (max 80) | Ukrainian display label per spec FR-002 |
| `SortOrder` | int (optional column) | 1–10 for stable UI ordering |

**Table**: `interests` (existing)

### UserInterest (association)

| Field | Type | Rules |
|-------|------|-------|
| `UserId` | UUID | FK → users |
| `InterestId` | UUID | FK → interests, must exist in catalog |

**Table**: `user_interests` (existing, composite PK)

### InterestCatalogItem (API DTO)

| Field | Type | Notes |
|-------|------|-------|
| `id` | uuid | |
| `name` | string | |
| `sortOrder` | int | |

Used in `GET /interests` and embedded in `UserProfile.interests`.

### OnboardingDraft (client, transient)

| Field | Type | Change |
|-------|------|--------|
| `interests` | `List<String>` | Stores **interest id** strings (UUID), not display labels |

Authoritative persistence: `user_interests` after `PUT /users/me`.

## Canonical catalog (seed)

| Sort | Name (UK) | Suggested stable id prefix |
|------|-----------|----------------------------|
| 1 | ІТ та розробка | `11111111-1111-1111-1111-111111110001` |
| 2 | Маркетинг/Продажі | `...0002` |
| 3 | HR та рекрутинг | `...0003` |
| 4 | Дизайн та візуалізація | `...0004` |
| 5 | Освіта та навчання | `...0005` |
| 6 | Здоров'я та медицина | `...0006` |
| 7 | Розвиток бізнесу | `...0007` |
| 8 | Логістика та ритейл | `...0008` |
| 9 | Інвестиції та фінанси | `...0009` |
| 10 | Мілітарі | `...000a` |

*(Exact GUIDs defined in `InterestCatalogSeed.cs` at implementation.)*

## Validation rules

- `PUT /users/me` with `interestIds`: every id must exist in `interests` (existing `UserProfileService` rule).
- Duplicate ids in request: dedupe server-side or reject — prefer dedupe before count check.
- Empty `interestIds: []` allowed on update; onboarding requires ≥1 before continue (client rule FR-010).
- Unknown id → domain error → HTTP 400 with envelope.

## State transitions

```text
[Client loads GET /interests] → catalog in memory
[User selects chips] → draft.interests = [uuid...]
[PUT /users/me] → user_interests replaced
[GET /users/me] → interestIds + interests[{id,name}]
```

## Migration impact

- Remove legacy interest rows (.NET, Flutter, DevOps, Product).
- Clear `user_interests` for removed ids (dev/QA acceptable).
- Re-seed `event_interests` in dev `DataSeeder` to use new catalog ids.

## Out of scope

- Localized `nameEn` column (v2).
- User-created custom interests.
- Event `interest` query param mapping to catalog ids (separate feature).
