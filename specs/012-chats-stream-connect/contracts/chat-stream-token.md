# Contract: Chat Stream user token

## GET `/chat/stream-token`

Issues a GetStream user token for the authenticated FelloWay user.

### Authentication

Required. Accepts Bearer JWT (mobile / split-host web) or web session cookie (same-origin).

### Response

**200 OK**

```json
{
  "token": "string"
}
```

Client also accepts legacy field `streamToken` if present.

### Errors

| Status | When |
|--------|------|
| 401 | No authenticated user |
| 5xx | Server / Stream SDK failure |

### Client usage sequence

1. Verify non-empty Stream **public** API key in client config.
2. `GET /users/me` → user id + display name.
3. `GET /chat/stream-token` → token.
4. `StreamChatClient.connectUser(user, token)`.

### Out of scope

- Channel creation, membership, webhooks (existing trip/event flows).
