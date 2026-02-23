# Security Patterns

**Version**: 1.0.0  
**Category**: API Patterns  
**Purpose**: Security best practices and patterns for AI agents interacting with Structs APIs

---

## Overview

This pattern provides security best practices for AI agents when handling authentication, credentials, sessions, and sensitive data. It complements the Authentication Protocol by focusing on security implementation details.

**Key Principles**:
1. **Never expose credentials** in code, logs, or documentation
2. **Store secrets securely** using environment variables or secure storage
3. **Use secure connections** (HTTPS/WSS) in production
4. **Handle session expiration** gracefully
5. **Validate and sanitize** all inputs
6. **Monitor for security issues** and log suspicious activity

---

## Credential Management

### Pattern 1: Environment Variables

**Best Practice**: Store credentials in environment variables

**Implementation**:
```json
{
  "credentialStorage": {
    "method": "environment-variables",
    "variables": {
      "PRIVATE_KEY": "Blockchain private key",
      "WEBAPP_USERNAME": "Webapp username",
      "WEBAPP_PASSWORD": "Webapp password",
      "NATS_PASSWORD": "NATS password (if configured)"
    }
  }
}
```

**Code Example**:
```javascript
// ✅ Good: Use environment variables
const privateKey = process.env.PRIVATE_KEY;
const username = process.env.WEBAPP_USERNAME;
const password = process.env.WEBAPP_PASSWORD;

// ❌ Bad: Hardcode credentials
const privateKey = "0x1234567890abcdef...";
const username = "myusername";
const password = "mypassword";
```

**Security Benefits**:
- Credentials not in source code
- Easy to rotate credentials
- Different credentials per environment
- No accidental commits to version control

### Pattern 2: Secure Key Storage

**Best Practice**: Use secure key storage for production

**Implementation**:
```json
{
  "keyStorage": {
    "development": "environment-variables",
    "production": "secure-key-store",
    "options": [
      "AWS Secrets Manager",
      "HashiCorp Vault",
      "Azure Key Vault",
      "Encrypted file system"
    ]
  }
}
```

**Code Example**:
```javascript
// Production: Use secure key store
async function getPrivateKey() {
  if (process.env.NODE_ENV === 'production') {
    return await secretsManager.getSecret('structs/private-key');
  } else {
    return process.env.PRIVATE_KEY;
  }
}
```

### Pattern 3: Credential Rotation

**Best Practice**: Support credential rotation

**Implementation**:
```json
{
  "credentialRotation": {
    "enabled": true,
    "strategy": "hot-swap",
    "process": [
      "Load new credentials",
      "Test new credentials",
      "Switch to new credentials",
      "Invalidate old credentials"
    ]
  }
}
```

**Code Example**:
```javascript
class CredentialManager {
  async rotateCredentials() {
    // Load new credentials
    const newKey = await this.loadNewKey();
    
    // Test new credentials
    await this.testCredentials(newKey);
    
    // Switch to new credentials
    this.currentKey = newKey;
    
    // Invalidate old credentials
    await this.invalidateOldKey();
  }
}
```

---

## Session Security

### Pattern 1: Secure Session Storage

**Best Practice**: Store sessions securely

**Implementation**:
```json
{
  "sessionStorage": {
    "method": "encrypted-storage",
    "encryption": "AES-256",
    "storage": "memory-or-secure-database",
    "expiration": "automatic-cleanup"
  }
}
```

**Code Example**:
```javascript
// ✅ Good: Encrypt session data
const encryptedSession = encrypt(sessionCookie, encryptionKey);
await secureStorage.set('session', encryptedSession);

// ❌ Bad: Store session in plain text
await localStorage.setItem('session', sessionCookie);
```

### Pattern 2: Session Expiration Handling

**Best Practice**: Handle session expiration gracefully

**Implementation**:
```json
{
  "sessionExpiration": {
    "detection": "401-unauthorized-response",
    "handling": "automatic-reauthentication",
    "retry": "retry-request-after-reauth"
  }
}
```

**Code Example**:
```javascript
async function makeAuthenticatedRequest(url, options = {}) {
  try {
    return await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Cookie': await getSessionCookie()
      }
    });
  } catch (error) {
    if (error.status === 401) {
      // Session expired, re-authenticate
      await reauthenticate();
      // Retry request
      return await fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Cookie': await getSessionCookie()
        }
      });
    }
    throw error;
  }
}
```

### Pattern 3: Session Validation

**Best Practice**: Validate session before use

**Implementation**:
```json
{
  "sessionValidation": {
    "check": "before-each-request",
    "validate": [
      "session-exists",
      "session-not-expired",
      "session-format-valid"
    ]
  }
}
```

**Code Example**:
```javascript
function isValidSession(session) {
  if (!session) return false;
  if (session.expires < Date.now()) return false;
  if (!session.cookie) return false;
  return true;
}

async function getValidSession() {
  const session = await getSession();
  if (!isValidSession(session)) {
    await reauthenticate();
    return await getSession();
  }
  return session;
}
```

---

## Private Key Security

### Pattern 1: Never Log Private Keys

**Best Practice**: Never log or expose private keys

**Implementation**:
```json
{
  "privateKeySecurity": {
    "never": [
      "log-private-key",
      "print-private-key",
      "include-in-error-messages",
      "expose-in-api-responses"
    ],
    "always": [
      "mask-in-logs",
      "validate-before-use",
      "store-securely"
    ]
  }
}
```

**Code Example**:
```javascript
// ✅ Good: Mask private key in logs
function logKey(key) {
  const masked = key.substring(0, 4) + '...' + key.substring(key.length - 4);
  console.log(`Private key: ${masked}`);
}

// ❌ Bad: Log full private key
console.log(`Private key: ${privateKey}`);
```

### Pattern 2: Secure Key Loading

**Best Practice**: Load keys securely

**Implementation**:
```json
{
  "keyLoading": {
    "source": "environment-variable-or-secure-storage",
    "validation": "validate-key-format",
    "storage": "memory-only",
    "cleanup": "clear-from-memory-after-use"
  }
}
```

**Code Example**:
```javascript
// ✅ Good: Load from environment, validate, use, clear
async function signTransaction(message) {
  const privateKey = process.env.PRIVATE_KEY;
  if (!isValidPrivateKey(privateKey)) {
    throw new Error('Invalid private key format');
  }
  
  const signature = await sign(message, privateKey);
  
  // Clear from memory (if possible)
  privateKey = null;
  
  return signature;
}
```

### Pattern 3: Key Derivation

**Best Practice**: Derive keys from master key when possible

**Implementation**:
```json
{
  "keyDerivation": {
    "method": "hkdf-or-pbkdf2",
    "purpose": "derive-keys-for-different-services",
    "benefit": "single-master-key"
  }
}
```

---

## Input Validation and Sanitization

### Pattern 1: Validate All Inputs

**Best Practice**: Validate all inputs before use

**Implementation**:
```json
{
  "inputValidation": {
    "validate": [
      "entity-ids",
      "request-parameters",
      "user-input",
      "api-responses"
    ],
    "rules": [
      "format-validation",
      "range-validation",
      "type-validation"
    ]
  }
}
```

**Code Example**:
```javascript
function validatePlayerId(playerId) {
  // Validate format: type-index (e.g., "1-11")
  if (!/^\d+-\d+$/.test(playerId)) {
    throw new Error('Invalid player ID format');
  }
  
  const [type, index] = playerId.split('-').map(Number);
  
  // Validate range
  if (type < 1 || type > 10) {
    throw new Error('Invalid player type');
  }
  
  if (index < 1 || index > 1000000) {
    throw new Error('Invalid player index');
  }
  
  return true;
}
```

### Pattern 2: Sanitize User Input

**Best Practice**: Sanitize user input before processing

**Implementation**:
```json
{
  "inputSanitization": {
    "sanitize": [
      "remove-special-characters",
      "escape-html",
      "trim-whitespace",
      "normalize-encoding"
    ]
  }
}
```

**Code Example**:
```javascript
function sanitizeInput(input) {
  return input
    .trim()
    .replace(/[<>]/g, '') // Remove HTML tags
    .replace(/[^\w\s-]/g, '') // Remove special characters
    .substring(0, 100); // Limit length
}
```

---

## Secure Communication

### Pattern 1: Use HTTPS/WSS

**Best Practice**: Always use secure connections in production

**Implementation**:
```json
{
  "secureCommunication": {
    "production": {
      "webapp": "https://api.structs.game",
      "consensus": "https://rpc.structs.game",
      "streaming": "wss://stream.structs.game"
    },
    "development": {
      "webapp": "http://localhost:8080",
      "consensus": "http://localhost:1317",
      "streaming": "ws://localhost:1443"
    }
  }
}
```

**Code Example**:
```javascript
const baseUrl = process.env.NODE_ENV === 'production'
  ? 'https://api.structs.game'
  : 'http://localhost:8080';
```

### Pattern 2: Certificate Validation

**Best Practice**: Validate SSL certificates

**Implementation**:
```json
{
  "certificateValidation": {
    "enabled": true,
    "verify": "ssl-certificate",
    "rejectUnauthorized": true
  }
}
```

**Code Example**:
```javascript
const https = require('https');

const agent = new https.Agent({
  rejectUnauthorized: true // Verify SSL certificates
});

fetch(url, { agent });
```

---

## Error Handling Security

### Pattern 1: Don't Expose Sensitive Data in Errors

**Best Practice**: Sanitize error messages

**Implementation**:
```json
{
  "errorHandling": {
    "neverExpose": [
      "private-keys",
      "passwords",
      "session-cookies",
      "internal-paths",
      "stack-traces-in-production"
    ],
    "sanitize": "all-error-messages"
  }
}
```

**Code Example**:
```javascript
// ✅ Good: Sanitize error messages
function handleError(error) {
  const sanitized = {
    message: error.message,
    code: error.code
  };
  
  // Don't include sensitive data
  if (process.env.NODE_ENV === 'production') {
    delete sanitized.stack;
  }
  
  return sanitized;
}

// ❌ Bad: Expose full error with sensitive data
function handleError(error) {
  return error; // May contain private keys, passwords, etc.
}
```

### Pattern 2: Secure Logging

**Best Practice**: Don't log sensitive data

**Implementation**:
```json
{
  "secureLogging": {
    "neverLog": [
      "private-keys",
      "passwords",
      "session-cookies",
      "authentication-tokens"
    ],
    "mask": "sensitive-data-in-logs"
  }
}
```

**Code Example**:
```javascript
function logRequest(request) {
  const sanitized = {
    ...request,
    headers: maskSensitiveHeaders(request.headers),
    body: maskSensitiveBody(request.body)
  };
  
  console.log('Request:', sanitized);
}

function maskSensitiveHeaders(headers) {
  const sensitive = ['authorization', 'cookie', 'x-api-key'];
  const masked = { ...headers };
  
  sensitive.forEach(key => {
    if (masked[key]) {
      masked[key] = '***MASKED***';
    }
  });
  
  return masked;
}
```

---

## Authentication Security

### Pattern 1: Secure Authentication Flow

**Best Practice**: Implement secure authentication

**Implementation**:
```json
{
  "authenticationSecurity": {
    "validate": "credentials-before-use",
    "store": "sessions-securely",
    "expire": "sessions-automatically",
    "reauthenticate": "on-session-expiration"
  }
}
```

**Code Example**:
```javascript
async function authenticate(username, password) {
  // Validate credentials format
  if (!isValidUsername(username) || !isValidPassword(password)) {
    throw new Error('Invalid credentials format');
  }
  
  // Authenticate
  const session = await login(username, password);
  
  // Store session securely
  await storeSessionSecurely(session);
  
  return session;
}
```

### Pattern 2: Token Security (If Implemented)

**Best Practice**: Secure token handling

**Implementation**:
```json
{
  "tokenSecurity": {
    "store": "securely",
    "validate": "before-use",
    "expire": "automatically",
    "refresh": "before-expiration"
  }
}
```

---

## Monitoring and Detection

### Pattern 1: Security Monitoring

**Best Practice**: Monitor for security issues

**Implementation**:
```json
{
  "securityMonitoring": {
    "monitor": [
      "failed-authentication-attempts",
      "suspicious-request-patterns",
      "unusual-api-usage",
      "session-anomalies"
    ],
    "alert": "on-security-issues"
  }
}
```

**Code Example**:
```javascript
class SecurityMonitor {
  trackFailedAuth(username) {
    this.failedAttempts[username] = (this.failedAttempts[username] || 0) + 1;
    
    if (this.failedAttempts[username] > 5) {
      this.alert('Multiple failed authentication attempts', { username });
    }
  }
  
  trackSuspiciousActivity(activity) {
    if (this.isSuspicious(activity)) {
      this.alert('Suspicious activity detected', activity);
    }
  }
}
```

### Pattern 2: Audit Logging

**Best Practice**: Log security-relevant events

**Implementation**:
```json
{
  "auditLogging": {
    "log": [
      "authentication-events",
      "authorization-failures",
      "sensitive-operations",
      "credential-changes"
    ],
    "retention": "long-term",
    "access": "restricted"
  }
}
```

---

## Best Practices Summary

### 1. Credential Management
- ✅ Use environment variables
- ✅ Store secrets securely
- ✅ Support credential rotation
- ❌ Never hardcode credentials
- ❌ Never commit credentials to version control

### 2. Session Security
- ✅ Store sessions securely
- ✅ Handle expiration gracefully
- ✅ Validate sessions before use
- ❌ Don't store sessions in plain text
- ❌ Don't ignore session expiration

### 3. Private Key Security
- ✅ Never log private keys
- ✅ Load keys securely
- ✅ Clear keys from memory when possible
- ❌ Never expose private keys
- ❌ Never include keys in error messages

### 4. Input Validation
- ✅ Validate all inputs
- ✅ Sanitize user input
- ✅ Check format and range
- ❌ Don't trust user input
- ❌ Don't skip validation

### 5. Secure Communication
- ✅ Use HTTPS/WSS in production
- ✅ Validate SSL certificates
- ✅ Use secure protocols
- ❌ Don't use HTTP in production
- ❌ Don't disable certificate validation

### 6. Error Handling
- ✅ Sanitize error messages
- ✅ Don't expose sensitive data
- ✅ Secure logging
- ❌ Don't log sensitive data
- ❌ Don't expose stack traces in production

### 7. Monitoring
- ✅ Monitor security events
- ✅ Log audit events
- ✅ Alert on suspicious activity
- ❌ Don't ignore security warnings
- ❌ Don't skip monitoring

---

## Related Documentation

- **Authentication Protocol**: `protocols/authentication.md` - Complete authentication guide
- **Error Handling**: `protocols/error-handling.md` - Error handling patterns
- **Retry Strategies**: `patterns/retry-strategies.md` - Retry patterns
- **Authentication Examples**: `examples/auth/` - Authentication examples

---

## Quick Reference

### Never Do
- ❌ Hardcode credentials
- ❌ Log private keys
- ❌ Expose sensitive data in errors
- ❌ Use HTTP in production
- ❌ Skip input validation
- ❌ Ignore session expiration

### Always Do
- ✅ Use environment variables
- ✅ Store secrets securely
- ✅ Validate all inputs
- ✅ Use HTTPS/WSS in production
- ✅ Handle errors securely
- ✅ Monitor security events

---

*Pattern Version: 1.0.0 - December 7, 2025*

