# Contract: LinkedIn BFF split-host web (dev/test/prod)

## Endpoints

### GET `/auth/linkedin/login`

Starts the LinkedIn OAuth challenge (server-side).

**Query**:
- `platform`: `web`
- `returnUrl`: URL-encoded web origin (e.g. `https://<web-host>`)

**Response**:
- `302` redirect to LinkedIn authorize URL.

### GET `/auth/linkedin/callback`

OAuth callback handled server-side.

**Requirement**:
- Must be reachable as **HTTPS** (public URL).

**Response (success)**:
- `302` redirect to `https://<web-host>/auth/success?ticket=<ticket>`

**Response (error)**:
- `302` redirect to `https://<web-host>/sign-in?error=<error>`

### POST `/auth/linkedin/mobile/complete`

Consumes one-time ticket and returns FelloWay JWT tokens (used by mobile and split-host web).

**Request**:

```json
{ "ticket": "<opaque>" }
```

**Response** `200`:

```json
{
  "accessToken": "<jwt>",
  "refreshToken": "<opaque>",
  "expiresIn": 3600,
  "userId": "<guid>"
}
```

**Errors**:
- `400` for invalid/expired/consumed ticket.

## CORS

Browser calls to `POST /auth/linkedin/mobile/complete` must be allowed from the deployed web origin via `Cors:AllowedOrigins` per environment.

