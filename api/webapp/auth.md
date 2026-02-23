# Webapp Authentication API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Auth
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## v0.8.0-beta Notes

**Hash Permission**: Authentication and authorization may need to support Hash permission (bit 64) in v0.8.0-beta. Permission checking may include permission_hash information.

**See**: `reviews/webapp-v0.8.0-beta-review.md` for review status

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| POST | `/api/auth/signup` | Sign up new user | No |
| POST | `/api/auth/login` | Login user | No |
| GET | `/api/auth/logout` | Logout user | Yes |

---

## Endpoint Details

### POST `/api/auth/signup`

Sign up new user.

- **ID**: `webapp-auth-signup`
- **Authentication**: None

---

### POST `/api/auth/login`

Login user.

- **ID**: `webapp-auth-login`
- **Authentication**: None

---

### GET `/api/auth/logout`

Logout user.

- **ID**: `webapp-auth-logout`
- **Authentication**: Required

---

## Related Documentation

- **Protocol**: `../../protocols/authentication.md` - Authentication patterns
- **Example**: `../../examples/auth/webapp-login.md` - Working login example

---

*Last Updated: January 1, 2026*
