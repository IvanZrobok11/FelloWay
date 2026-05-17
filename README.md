# FelloWay

Monorepo for **FelloWay** — an event networking platform for IT conferences: discover events, join trip chats, and connect before you arrive.

| Layer | Stack (MVP) |
|-------|-------------|
| Mobile | Flutter (iOS + Android) — see [frontend/](frontend/) |
| API | ASP.NET Core + PostgreSQL — see [backend/](backend/) (placeholder) |
| Chat | GetStream |
| Auth | OAuth (LinkedIn, Facebook) |

---

## Repository layout

| Path | Role |
|------|------|
| [frontend/](frontend/) | Flutter app package `felloway_client` |
| [backend/](backend/) | API server (not started yet) |
| [shared/api-contracts/](shared/api-contracts/) | Shared REST/OpenAPI contracts by domain |
| [specs/](specs/) | Feature specs, data model, planning docs |
| [.specify/](.specify/) | Project constitution and Spec Kit templates |
| [.cursor/](.cursor/) | Cursor / Spec Kit command definitions |

---

## Quick start (Flutter)

From the repo root:

```bash
cd frontend
flutter pub get
flutter run
```

**Next steps**

- [frontend/README.md](frontend/README.md) — `flutter doctor`, `--dart-define` runtime config, API modes (`mock` / `live` / `auto`)
- [specs/001-event-networking-app/quickstart.md](specs/001-event-networking-app/quickstart.md) — quality gates (`flutter analyze`, tests, goldens, integration tests)

Open **`frontend/`** as the Flutter project root in your IDE.

---

## Documentation map

### Product & architecture

| Document | Description |
|----------|-------------|
| [PRD_Event_Networking.md](PRD_Event_Networking.md) | Product requirements (MVP scope, onboarding, events, trips, chat) |
| [TECH_PLAN.md](TECH_PLAN.md) | Technical stack, phases, and implementation timeline |

### API contracts (`shared/api-contracts/`)

| Path | Description |
|------|-------------|
| [shared/api-contracts/README.md](shared/api-contracts/README.md) | Layout, conventions, domain index |
| [shared/api-contracts/auth/](shared/api-contracts/auth/) | OAuth, sessions, Stream tokens |
| [shared/api-contracts/users/](shared/api-contracts/users/) | Profile, avatar, preferences, blocks, reviews |
| [shared/api-contracts/common/](shared/api-contracts/common/) | Shared types, errors, pagination |
| [shared/api-contracts/events/](shared/api-contracts/events/) | Events, attendance, trips, join flows |

### Feature `001-event-networking-app`

| Document | Description |
|----------|-------------|
| [specs/001-event-networking-app/spec.md](specs/001-event-networking-app/spec.md) | User stories and acceptance criteria |
| [specs/001-event-networking-app/plan.md](specs/001-event-networking-app/plan.md) | Implementation plan and structure decisions |
| [specs/001-event-networking-app/tasks.md](specs/001-event-networking-app/tasks.md) | Task checklist and progress |
| [specs/001-event-networking-app/quickstart.md](specs/001-event-networking-app/quickstart.md) | Dev setup, CI checklist, manual device checks |
| [specs/001-event-networking-app/data-model.md](specs/001-event-networking-app/data-model.md) | Domain entities and relationships |
| [specs/001-event-networking-app/research.md](specs/001-event-networking-app/research.md) | Research notes and decisions |
| [specs/001-event-networking-app/contracts/README.md](specs/001-event-networking-app/contracts/README.md) | Feature-level contract notes (links to `shared/api-contracts/`) |
| [specs/001-event-networking-app/contracts/rest-endpoints.md](specs/001-event-networking-app/contracts/rest-endpoints.md) | Legacy endpoint summary (migrate into `shared/api-contracts/`) |

### Engineering standards

| Document | Description |
|----------|-------------|
| [.specify/memory/constitution.md](.specify/memory/constitution.md) | Code quality, testing, UX, and performance gates |
| [frontend/analysis_options.yaml](frontend/analysis_options.yaml) | Dart analyzer / lint rules |
| [frontend/pubspec.yaml](frontend/pubspec.yaml) | Dependencies and assets |

---

## Backend

The [backend/](backend/) directory is reserved for the ASP.NET Core API described in [TECH_PLAN.md](TECH_PLAN.md). Until that project is added, the mobile app can run against mocks — see [frontend/README.md](frontend/README.md#api-modes-api_mode).

---

## Contributing

1. Read [PRD_Event_Networking.md](PRD_Event_Networking.md) and the active feature spec under [specs/](specs/).
2. Implement in [frontend/](frontend/) following [.specify/memory/constitution.md](.specify/memory/constitution.md).
3. Before opening a PR, run the checks in [specs/001-event-networking-app/quickstart.md](specs/001-event-networking-app/quickstart.md).
