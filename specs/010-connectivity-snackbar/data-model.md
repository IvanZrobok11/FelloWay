# Data Model: Connectivity SnackBar (010)

**Date**: 2026-05-20

This feature is **UI-only** with no persistence or API schema changes. Entities below describe runtime concepts for implementation and tests.

## Entities

### ConnectivitySnackBarConfig (immutable, code constants)

| Field | Type | Value / rule |
|-------|------|----------------|
| `backgroundColor` | `Color` | `0xFF212121` |
| `borderRadius` | `double` | `12` |
| `behavior` | enum | `floating` |
| `duration` | `Duration` | `4 seconds` |
| `icon` | `IconData` | `Icons.wifi_off` |
| `iconColor` | `Color` | `Colors.white70` |
| `textColor` | `Color` | `Colors.white` |
| `contentSpacing` | `double` | `12` |

No serialization; lives in `connectivity_snack_bar.dart`.

### ConnectivityNotification (ephemeral UI)

Represents one visible snack bar instance bound to a `ScaffoldMessengerState`.

| Attribute | Description |
|-----------|-------------|
| `message` | Localized string from `AppLocalizations.connectivityActionUnavailable` |
| `visible` | True between `showSnackBar` and dismiss (timer or close) |
| `messenger` | Parent `ScaffoldMessenger` for clear/show |

**State transitions**:

```text
(none) --show()--> visible --timer 4s--> (none)
(none) --show()--> visible --close tap--> (none)
visible --show() again--> clearSnackBars --> visible (replaced)
```

### ConnectivityFailureSignal (classification input)

Not a stored entity; derived at error-handling time from:

| Source | Maps to connectivity UI? |
|--------|---------------------------|
| `DioExceptionType.connectionError` | Yes |
| `DioExceptionType.connectionTimeout` | Yes |
| `DioExceptionType.sendTimeout` | Yes |
| `DioExceptionType.receiveTimeout` | Yes |
| `DioException` unknown, `response == null` | Yes |
| `DioExceptionType.badResponse` (4xx/5xx) | No |
| `NetworkFailure` with `HTTP \d+` in message | No |
| `AuthFailure`, `ValidationFailure` | No |

### ShowInvocation (developer API)

| Field | Rule |
|-------|------|
| `context` | Must have ancestor `ScaffoldMessenger`; typically under `Scaffold` |
| `precondition` | Caller determined `isConnectivityFailure` (or raw `DioException`) |

## Relationships

```text
User action → Repository → Failure(AppFailure)
                              ↓
                    Presentation catch/switch
                              ↓
              isConnectivityFailure? ──yes──► ConnectivitySnackBar.show(context)
                              │
                              no──► generic SnackBar(error.message)
```

## Validation rules

- `show` MUST NOT be called without `context.mounted` check at call site (callers responsible).
- `show` MUST call `clearSnackBars()` before `showSnackBar`.
- Message MUST come from l10n, not hardcoded in widget (except tests using `AppLocalizations` delegates).

## Out of scope

- Database tables
- OpenAPI / backend contracts
- Proactive connectivity monitoring stream
