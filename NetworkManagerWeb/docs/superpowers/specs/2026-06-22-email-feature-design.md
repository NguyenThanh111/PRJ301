# Email Feature Design — NetworkManagerWeb

## Overview
Add email capabilities to NetworkManagerWeb: email verification on registration, welcome emails, forgot/reset password flow, and network alert notifications.

## 1. Email Types & Flows

| Email Type | Trigger | Description |
|------------|---------|-------------|
| **Verify Email** | User registers | Send verification link → user clicks → account activated |
| **Welcome** | Email verified | Notification + getting-started info |
| **Forgot Password** | User requests reset | Send reset link → user clicks → enters new password |
| **Alert** | Admin creates alert | Notify relevant users about network issues/maintenance (no token, direct send) |

### Verify Email Flow
```
Register → user status = 'PENDING' → create VERIFICATION token → send verify email
                                                                          ↓
                                                        User clicks link → verify token
                                                                          ↓
                                                             status = 'ACTIVE' → send Welcome
```

### Resend Verification Flow
```
Login page (blocked due to PENDING) → "Resend verification email"
  → check cooldown (created_at < 5 min ago?) → if expired, create new token → send
```
Requires session — user must be logged in (status PENDING) to trigger resend. Prevents anonymous spam.

### Forgot Password Flow
```
Login page → "Forgot Password?" → enter email → create RESET token → send reset link
                                                                           ↓
                                                          User clicks link → show reset form
                                                                           ↓
                                           POST new password (+ token in hidden field) → update DB
                                                                           ↓
                                                     markAllUsed(userId, "RESET") — keep audit trail
```

### Alert Flow (no token)
```
Admin creates alert → load relevant users → sendEmail() directly → done
```

## 2. Architecture

### New Files

#### Java Classes
| File | Purpose |
|------|---------|
| `Utils/EmailUtils.java` | SMTP sender using JavaMail API; load config; load HTML templates via `ServletContext.getRealPath()` |
| `Utils/TokenUtils.java` | Generate secure random tokens via `SecureRandom`; calculate expiry dates |
| `Models/VerificationToken.java` | JPA Entity: id, userId, token, type (VERIFICATION/RESET), expiryDate, used, createdAt |
| `Models_DAO/VerificationTokenDAO.java` | CRUD for tokens; findByToken(), markAllUsed(userId, type), markUsed(id), countRecentByUser(userId, type, minutes) |
| `Controller/VerifyEmailController.java` | GET `?token=xxx` — verify token → activate user → send Welcome |
| `Controller/ForgotPasswordController.java` | GET show form; POST validate email → check cooldown → create token → send reset email |
| `Controller/ResetPasswordController.java` | GET `?token=xxx` — validate token → show form; POST new password (token in hidden field) → update in transaction → invalidate old tokens → redirect login |
| `Controller/ResendVerificationController.java` | POST — resend verification email for PENDING users. Requires active session with PENDING user (CSRF protection via session check) |

#### JSP Pages
| File | Purpose |
|------|---------|
| `forgot-password.jsp` | Enter email to receive reset link |
| `reset-password.jsp` | Enter new password + confirm (token in hidden field). Response sets `Referrer-Policy: no-referrer` header |
| `check-email.jsp` | "Please check your email" — shown after register or resend |
| `email-verified.jsp` | Success page after verification |
| `verify-email-failed.jsp` | Error page (expired/invalid token or already verified) |

#### Email HTML Templates (`web/email-templates/`)
| File | Variables | Description |
|------|-----------|-------------|
| `verify-email.html` | `{{USERNAME}}`, `{{VERIFY_LINK}}`, `{{EXPIRY_HOURS}}` | Verification link button |
| `welcome.html` | `{{USERNAME}}`, `{{DASHBOARD_LINK}}` | Welcome + getting started |
| `reset-password.html` | `{{USERNAME}}`, `{{RESET_LINK}}`, `{{EXPIRY_HOURS}}` | Reset password button |
| `alert.html` | `{{USERNAME}}`, `{{ALERT_TITLE}}`, `{{ALERT_DETAIL}}`, `{{ALERT_SEVERITY}}` | Network alert notification |

#### Config
| File | Purpose |
|------|---------|
| `web/WEB-INF/smtp.properties` | SMTP host, port, username, password, auth, TLS settings (gitignored) |

### Database

```sql
CREATE TABLE VerificationToken (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,         -- 'VERIFICATION' | 'RESET'
    expiry_date DATETIME NOT NULL,
    used BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES [User](user_id)
);

CREATE UNIQUE INDEX idx_token ON VerificationToken(token);
CREATE INDEX idx_user_id ON VerificationToken(user_id);
CREATE INDEX idx_user_type ON VerificationToken(user_id, type);
```

### JPA Entity — VerificationToken.java
```java
@Entity
@Table(name = "VerificationToken", indexes = {
    @Index(name = "idx_token", columnList = "token", unique = true),
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_user_type", columnList = "user_id, type")
})
public class VerificationToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "user_id", nullable = false)
    private int userId;

    @Column(name = "token", nullable = false, length = 255)
    private String token;

    @Column(name = "type", nullable = false, length = 20)
    private String type;

    @Column(name = "expiry_date", nullable = false)
    private LocalDateTime expiryDate;

    @Column(name = "used")
    private boolean used = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
```

### Changes to Existing Code

#### RegisterUserController
- After `insert()` succeeds: create VERIFICATION token → send verify email → redirect to `check-email.jsp`
- Set user status to `PENDING` on registration (not ACTIVE)
- If email send fails: **keep user PENDING in DB** (don't rollback insert), redirect to `check-email.jsp` with error "Cannot send verification email. Please try Resend Verification below." — user is not lost, can retry via ResendVerificationController

#### LoginController
- Block login if user status = `PENDING` (redirect to "Please verify email" message with "Resend verification" link)
- Add "Forgot Password?" link on login form

#### Alert/Notification Controller
- When a network alert is created, send email to all active users with relevant roles (direct sendEmail(), no token)
- **Async sending:** use `ExecutorService` (single-thread pool) to send emails in background thread — prevents blocking the admin's HTTP request

## 3. EmailUtils Architecture

```java
public final class EmailUtils {
    // Static init: load smtp.properties from classpath
    // sendEmail(to, subject, htmlBody) → throws EmailException
    // loadTemplate(ServletContext ctx, templateName, Map<String, String> placeholders)
    //   → ctx.getRealPath("/email-templates/" + name + ".html")
    //   → read file, replace {{KEY}} with values
    //   → return HTML string
}
```

**Template loading:** Uses `ServletContext.getRealPath()` to resolve absolute path to template files, ensuring it works both in development (exploded) and deployed (WAR) environments.

Templates use CSS inline (required by most email clients). Placeholder format: `{{VARIABLE_NAME}}`.

**Error handling:** If `sendEmail()` fails (SMTP timeout, auth failure, etc.), the caller must handle gracefully:
- Registration: keep user PENDING in DB, redirect to `check-email.jsp` with "Resend Verification" option — user data is preserved
- Welcome email: **log and ignore** — account activation is the primary action; welcome email is best-effort
- Forgot password: show error "Cannot send email. Try again later."
- Retry: no automatic retry (user can re-trigger the action manually)

## 4. SMTP Configuration

File: `web/WEB-INF/smtp.properties` (should be in .gitignore)

```properties
smtp.host=smtp.gmail.com
smtp.port=587
smtp.username=your-email@gmail.com
smtp.password=your-app-password
smtp.auth=true
smtp.tls=true
```

**Recommendation:**
- **Development:** Use [Mailtrap](https://mailtrap.io) (free, fake SMTP, emails captured in dashboard)
- **Demo/Production:** Use Gmail SMTP with App Password

## 5. Dependencies

Add `javax.mail.jar` (JavaMail API) to `web/WEB-INF/lib/`. Download from Maven Central: `javax.mail-1.6.2.jar`.

`activation.jar` is part of JDK 8+ so already available.

## 6. Security Considerations

- Tokens are 64-character random hex strings via `SecureRandom` (sufficient entropy to prevent guessing)
- Token expiry: 24 hours for verification/reset
- Tokens are single-use (`used` flag), checked before any operation
- Rate limiting: DB query — `WHERE user_id = ? AND type = ? AND created_at > (NOW() - 5 min)` — survive restart, use existing `created_at` column
- Reset password flow: **wrap in transaction** — invalidate old tokens AND update password in same transaction; if any step fails, rollback all changes
- Token in reset flow: GET loads token from query param to validate + display form; POST submits new password **with token in hidden form field** (not query param) to avoid token exposure in access logs
- `reset-password.jsp` response sets header `Referrer-Policy: no-referrer` — prevents token leakage via Referrer header to external resources (images, CSS) loaded by the page
- Already-verified user clicking verify link: show friendly message "Your account is already verified. Please login."
- SMTP credentials stored in properties file (not committed, added to .gitignore)
- All email links should use HTTPS in production (base URL configurable, e.g. `app.base.url=https://yourdomain.com`)
- `[User].email` must have a UNIQUE constraint — Forgot Password flow looks up by email; without uniqueness, a query could return multiple users. If not already present, add: `ALTER TABLE [User] ADD CONSTRAINT uq_email UNIQUE(email);`
- Expired token cleanup: a daily background task (or scheduled script) DELETES tokens older than 7 days (expired OR used) to keep the table size manageable
