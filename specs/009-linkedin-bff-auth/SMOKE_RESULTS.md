# Manual smoke results (009-linkedin-bff-auth)

Record outcomes when validating FR-016 (HTTPS-only local). Copy relevant rows into the PR description (task T047).

| Step | Platform | Pass? | Notes |
|------|----------|-------|-------|
| API `dotnet run --launch-profile https` | — | ☐ | `https://localhost:7086` |
| Flutter web `--dart-define=API_BASE_URL=https://localhost:7086` | Web | ☐ | Port `7357` |
| LinkedIn portal redirect | — | ☐ | `https://localhost:7086/auth/linkedin/callback` |
| Tap **Continue with LinkedIn** → consent → `/auth/success` | Web | ☐ | Cookie `felloway.session` on API host |
| `GET /users/me` without Bearer (cookie) | Web | ☐ | |
| Mobile `flutter_web_auth_2` → ticket → JWT | iOS/Android | ☐ | |
| Dev `dev-*` with secrets empty | API | ☐ | `POST /auth/oauth/linkedin/token` |

**Tester / date**: _fill in_

**Commands**:

```bash
dotnet test backend/tests/FelloWay.Api.Tests --filter "FullyQualifiedName~Auth"
cd frontend && flutter analyze && flutter test test/unit/app_config_bff_test.dart test/unit/linkedin_bff_auth_test.dart test/widget/oauth_sign_in_bff_test.dart
```
