---
description: "Task list for Production LinkedIn OAuth Sign-In"
---

# Tasks: Production LinkedIn OAuth Sign-In

**Input**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md)

## Phase A — Backend (P1)

- [x] T001 [US1] Add `OAuthOptions` and `LinkedInOAuthOptions` in `backend/src/FelloWay.Infrastructure/Auth/OAuthOptions.cs`
- [x] T002 [US1] Implement `LinkedInOAuthTokenExchanger` in `backend/src/FelloWay.Infrastructure/Auth/LinkedInOAuthTokenExchanger.cs`
- [x] T003 [US1] Implement `CompositeOAuthTokenExchanger` in `backend/src/FelloWay.Infrastructure/Auth/CompositeOAuthTokenExchanger.cs`
- [x] T004 [US1] Register OAuth options + HttpClient + composite exchanger in `DependencyInjection.cs`
- [x] T005 [US1] Add `User.Email` + EF migration + `UserConfiguration`
- [x] T006 [US1] Map email in `AuthService.cs`
- [x] T007 [US1] Unit tests for LinkedIn exchanger + dev-code rejection in `backend/tests/FelloWay.Api.Tests/Auth/`

## Phase B — Flutter (P1)

- [x] T008 [US1] Change `oauth_sign_in_page.dart` to authorize → `AuthApi.exchangeLinkedIn`
- [x] T009 [US1] LinkedIn-only production path; Facebook uses dev backend sign-in when OAuth configured

## Phase C — Validation (P2)

- [x] T010 [US2] Verify quickstart.md steps; run `dotnet test` and `flutter test`
