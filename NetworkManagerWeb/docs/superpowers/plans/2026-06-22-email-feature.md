# Email Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add email verification on registration, forgot/reset password, welcome emails, and network alert notifications.

**Architecture:** JavaMail SMTP sender (`EmailUtils`) + secure token generation (`TokenUtils`) + `VerificationToken` JPA entity for token persistence. Async sends for bulk alert emails. HTML templates with `{{PLACEHOLDER}}` substitution loaded via `ServletContext.getRealPath()`.

**Tech Stack:** Java 8, JavaMail API 1.6.2 (`javax.mail`), SQL Server, JPA (EclipseLink), JSP/Servlet

## Global Constraints

- Must use `javax.mail-1.6.2.jar` (add to `web/WEB-INF/lib/`)
- JDK 8 compatible (no Jakarta EE)
- SMTP config in `web/WEB-INF/smtp.properties` (gitignored)
- Token format: `iterations:salt:hash` style values (64-char hex via `SecureRandom`)
- All DB operations use existing `EntityManager` pattern
- Existing `UserDTO` entity has `email` column (VARCHAR, needs UNIQUE constraint added)
- Email templates stored in `web/email-templates/`, loaded via `ServletContext.getRealPath()`

---

### Task 1: Add javax.mail.jar + create SMTP config + EmailUtils + TokenUtils

**Files:**
- Create: `web/WEB-INF/lib/javax.mail-1.6.2.jar` (download from Maven Central)
- Create: `web/WEB-INF/smtp.properties`
- Create: `src/java/Utils/EmailUtils.java`
- Create: `src/java/Utils/TokenUtils.java`

**Interfaces:**
- Consumes: nothing
- Produces:
  - `EmailUtils.sendEmail(String to, String subject, String htmlBody)` — sends email
  - `EmailUtils.loadTemplate(ServletContext ctx, String templateName, Map<String, String> placeholders)` — returns HTML string
  - `TokenUtils.generateToken()` — returns 64-char hex string
  - `TokenUtils.getExpiryDate(int hoursFromNow)` — returns `LocalDateTime`

- [ ] **Step 1: Download javax.mail.jar**

Download `javax.mail-1.6.2.jar` from Maven Central (`https://repo1.maven.org/maven2/com/sun/mail/javax.mail/1.6.2/javax.mail-1.6.2.jar`) and place in `web/WEB-INF/lib/`.

```bash
# Run from NetworkManagerWeb directory
curl -o web/WEB-INF/lib/javax.mail-1.6.2.jar https://repo1.maven.org/maven2/com/sun/mail/javax.mail/1.6.2/javax.mail-1.6.2.jar
```

- [ ] **Step 2: Create smtp.properties**

```properties
smtp.host=smtp.gmail.com
smtp.port=587
smtp.username=your-email@gmail.com
smtp.password=your-app-password
smtp.auth=true
smtp.tls=true
```

- [ ] **Step 3: Create TokenUtils.java**

```java
package Utils;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HexFormat;

public final class TokenUtils {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 32; // 64 hex chars

    private TokenUtils() {}

    public static String generateToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        return HexFormat.of().formatHex(bytes);
    }

    public static LocalDateTime getExpiryDate(int hoursFromNow) {
        return LocalDateTime.now().plusHours(hoursFromNow);
    }
}
```

- [ ] **Step 4: Create EmailUtils.java**

```java
package Utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletContext;

public final class EmailUtils {

    private static final String PROPERTIES_PATH = "/WEB-INF/smtp.properties";
    private static final String TEMPLATE_DIR = "/email-templates/";

    private static String smtpHost;
    private static int smtpPort;
    private static String smtpUsername;
    private static String smtpPassword;
    private static boolean smtpAuth;
    private static boolean smtpTls;
    private static boolean initialized = false;

    private EmailUtils() {}

    public static void init(ServletContext ctx) {
        try (InputStream is = ctx.getResourceAsStream(PROPERTIES_PATH)) {
            if (is == null) {
                throw new RuntimeException("SMTP config not found at " + PROPERTIES_PATH);
            }
            Properties props = new Properties();
            props.load(is);
            smtpHost = props.getProperty("smtp.host");
            smtpPort = Integer.parseInt(props.getProperty("smtp.port"));
            smtpUsername = props.getProperty("smtp.username");
            smtpPassword = props.getProperty("smtp.password");
            smtpAuth = Boolean.parseBoolean(props.getProperty("smtp.auth", "true"));
            smtpTls = Boolean.parseBoolean(props.getProperty("smtp.tls", "true"));
            initialized = true;
        } catch (IOException e) {
            throw new RuntimeException("Failed to load SMTP config", e);
        }
    }

    private static Session createSession() {
        if (!initialized) {
            throw new IllegalStateException("EmailUtils not initialized. Call init(ServletContext) first.");
        }
        Properties props = new Properties();
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.auth", String.valueOf(smtpAuth));
        props.put("mail.smtp.starttls.enable", String.valueOf(smtpTls));
        props.put("mail.smtp.connectiontimeout", 10000);
        props.put("mail.smtp.timeout", 10000);

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUsername, smtpPassword);
            }
        });
        return session;
    }

    public static void sendEmail(String to, String subject, String htmlBody) throws MessagingException {
        Session session = createSession();
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(smtpUsername));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject(subject, "UTF-8");
        message.setContent(htmlBody, "text/html; charset=UTF-8");
        Transport.send(message);
    }

    public static String loadTemplate(ServletContext ctx, String templateName, Map<String, String> placeholders) throws IOException {
        String realPath = ctx.getRealPath(TEMPLATE_DIR + templateName + ".html");
        if (realPath == null) {
            throw new IOException("Template not found: " + templateName);
        }
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(ctx.getResourceAsStream(TEMPLATE_DIR + templateName + ".html"), StandardCharsets.UTF_8))) {
            String content = reader.lines().collect(Collectors.joining("\n"));
            for (Map.Entry<String, String> entry : placeholders.entrySet()) {
                content = content.replace("{{" + entry.getKey() + "}}", entry.getValue());
            }
            return content;
        }
    }
}
```

- [ ] **Step 5: Initialize EmailUtils in a ServletContextListener**

Create `src/java/Utils/EmailConfigListener.java`:

```java
package Utils;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class EmailConfigListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        EmailUtils.init(sce.getServletContext());
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
}
```

- [ ] **Step 6: Add smtp.properties to .gitignore**

Append to `.gitignore`:
```
web/WEB-INF/smtp.properties
```

---

### Task 2: Create VerificationToken entity + DAO + SQL migration

**Files:**
- Create: `src/java/Models/VerificationToken.java`
- Create: `src/java/Models_DAO/VerificationTokenDAO.java`
- Create: `web/lib/migration-002-verification-token.sql`

**Interfaces:**
- Consumes: nothing
- Produces:
  - `VerificationToken` JPA entity
  - `VerificationTokenDAO.findByToken(String token)` → `VerificationToken`
  - `VerificationTokenDAO.findByUserAndType(int userId, String type)` → `List<VerificationToken>`
  - `VerificationTokenDAO.save(VerificationToken token)` → void
  - `VerificationTokenDAO.markUsed(int id)` → void
  - `VerificationTokenDAO.markAllUsed(int userId, String type)` → void
  - `VerificationTokenDAO.countRecentByUser(int userId, String type, int minutes)` → long
  - `VerificationTokenDAO.deleteExpired(int olderThanDays)` → int

- [ ] **Step 1: Create SQL migration**

File `web/lib/migration-002-verification-token.sql`:

```sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='VerificationToken' AND xtype='U')
BEGIN
    CREATE TABLE VerificationToken (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        token VARCHAR(255) NOT NULL,
        type VARCHAR(20) NOT NULL,
        expiry_date DATETIME NOT NULL,
        used BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES [User](user_id)
    );

    CREATE UNIQUE INDEX idx_token ON VerificationToken(token);
    CREATE INDEX idx_user_id ON VerificationToken(user_id);
    CREATE INDEX idx_user_type ON VerificationToken(user_id, type);
END;
GO

-- Add UNIQUE constraint on email if not exists
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='uq_email' AND object_id = OBJECT_ID('[User]'))
BEGIN
    ALTER TABLE [User] ADD CONSTRAINT uq_email UNIQUE(email);
END;
GO
```

- [ ] **Step 2: Create VerificationToken entity**

```java
package Models;

import java.io.Serializable;
import java.time.LocalDateTime;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Index;
import javax.persistence.Table;

@Entity
@Table(name = "VerificationToken", indexes = {
    @Index(name = "idx_token", columnList = "token", unique = true),
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_user_type", columnList = "user_id, type")
})
public class VerificationToken implements Serializable {

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

    public VerificationToken() {}

    public VerificationToken(int userId, String token, String type, LocalDateTime expiryDate) {
        this.userId = userId;
        this.token = token;
        this.type = type;
        this.expiryDate = expiryDate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDateTime getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDateTime expiryDate) { this.expiryDate = expiryDate; }
    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiryDate);
    }
}
```

- [ ] **Step 3: Create VerificationTokenDAO**

```java
package Models_DAO;

import Models.VerificationToken;
import java.time.LocalDateTime;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.NoResultException;
import javax.persistence.Persistence;
import javax.persistence.TypedQuery;

public class VerificationTokenDAO {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    private EntityManager getEntityManager() {
        return FACTORY.createEntityManager();
    }

    private boolean executeInTransaction(Consumer<EntityManager> action) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            action.accept(em);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public VerificationToken findByToken(String token) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<VerificationToken> query = em.createQuery(
                "SELECT t FROM VerificationToken t WHERE t.token = :token", VerificationToken.class);
            query.setParameter("token", token);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public List<VerificationToken> findByUserAndType(int userId, String type) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<VerificationToken> query = em.createQuery(
                "SELECT t FROM VerificationToken t WHERE t.userId = :userId AND t.type = :type ORDER BY t.createdAt DESC",
                VerificationToken.class);
            query.setParameter("userId", userId);
            query.setParameter("type", type);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public void save(VerificationToken token) {
        executeInTransaction(em -> em.persist(token));
    }

    public void markUsed(int id) {
        executeInTransaction(em -> {
            VerificationToken t = em.find(VerificationToken.class, id);
            if (t != null) {
                t.setUsed(true);
            }
        });
    }

    public void markAllUsed(int userId, String type) {
        executeInTransaction(em -> {
            em.createQuery(
                "UPDATE VerificationToken t SET t.used = true WHERE t.userId = :userId AND t.type = :type AND t.used = false")
                .setParameter("userId", userId)
                .setParameter("type", type)
                .executeUpdate();
        });
    }

    public long countRecentByUser(int userId, String type, int minutes) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(t) FROM VerificationToken t "
                + "WHERE t.userId = :userId AND t.type = :type AND t.createdAt > :cutoff",
                Long.class);
            query.setParameter("userId", userId);
            query.setParameter("type", type);
            query.setParameter("cutoff", LocalDateTime.now().minusMinutes(minutes));
            return query.getSingleResult();
        } finally {
            em.close();
        }
    }

    public int deleteExpired(int olderThanDays) {
        return executeInTransaction(em -> {
            LocalDateTime cutoff = LocalDateTime.now().minusDays(olderThanDays);
            return em.createQuery(
                "DELETE FROM VerificationToken t WHERE (t.used = true OR t.expiryDate < :now) AND t.createdAt < :cutoff")
                .setParameter("now", LocalDateTime.now())
                .setParameter("cutoff", cutoff)
                .executeUpdate();
        });
    }
}
```

---

### Task 3: Implement registration verification flow

**Files:**
- Modify: `src/java/Controller/RegisterUserController.java`
- Create: `src/java/Controller/VerifyEmailController.java`
- Create: `src/java/Controller/ResendVerificationController.java`
- Create: `web/check-email.jsp`
- Create: `web/email-verified.jsp`
- Create: `web/verify-email-failed.jsp`

**Interfaces:**
- Consumes: `EmailUtils`, `TokenUtils`, `VerificationTokenDAO`, `UserDAO`
- Produces:
  - `VerifyEmailController` — GET `?token=xxx`
  - `ResendVerificationController` — POST (session + userId)
  - `check-email.jsp` — request attrs: `error` (optional)
  - `email-verified.jsp` — success message
  - `verify-email-failed.jsp` — request attr: `error`

- [ ] **Step 1: Modify RegisterUserController — add PENDING + token creation + send verify email**

Add imports at top:
```java
import Utils.EmailUtils;
import Utils.TokenUtils;
import Models.VerificationToken;
import Models_DAO.VerificationTokenDAO;
```

In `handleNormalRegister()`, after `userDAO.insert(newUser)` succeeds, replace the redirect block:

```java
if (!inserted) {
    request.setAttribute("error", "Cannot create user. Please try again.");
    request.setAttribute("source", "normal");
    request.getRequestDispatcher(url).forward(request, response);
    return;
}

// Create verification token and send email
try {
    String token = TokenUtils.generateToken();
    VerificationToken vt = new VerificationToken(
        created.getUserId(), token, "VERIFICATION", TokenUtils.getExpiryDate(24));
    new VerificationTokenDAO().save(vt);

    String baseUrl = request.getScheme() + "://" + request.getServerName()
        + ":" + request.getServerPort() + request.getContextPath();
    String verifyLink = baseUrl + "/VerifyEmailController?token=" + token;

    Map<String, String> placeholders = new HashMap<>();
    placeholders.put("USERNAME", username);
    placeholders.put("VERIFY_LINK", verifyLink);
    placeholders.put("EXPIRY_HOURS", "24");

    String htmlBody = EmailUtils.loadTemplate(
        getServletContext(), "verify-email", placeholders);
    EmailUtils.sendEmail(email, "Verify your account", htmlBody);
} catch (Exception e) {
    e.printStackTrace();
    // Email failed — user still PENDING, they can use Resend
    request.setAttribute("error", "Cannot send verification email. Please use Resend Verification below.");
    request.getRequestDispatcher("check-email.jsp").forward(request, response);
    return;
}

request.setAttribute("success", "Register successfully. Please check your email to verify.");
request.getRequestDispatcher("check-email.jsp").forward(request, response);
```

Same changes in `handleGoogleFirstRegister()`.

Add imports to the top of the file:
```java
import java.util.HashMap;
import java.util.Map;
```

- [ ] **Step 2: Create VerifyEmailController.java**

```java
package Controller;

import Models.UserDTO;
import Models.VerificationToken;
import Models_DAO.UserDAO;
import Models_DAO.VerificationTokenDAO;
import Utils.EmailUtils;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "VerifyEmailController", urlPatterns = {"/VerifyEmailController"})
public class VerifyEmailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid verification link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();
        VerificationToken vt = tokenDAO.findByToken(token.trim());

        if (vt == null) {
            request.setAttribute("error", "Invalid verification link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isUsed()) {
            request.setAttribute("error", "This link has already been used.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isExpired()) {
            request.setAttribute("error", "Verification link has expired. Please request a new one.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        UserDTO user = userDAO.searchById(vt.getUserId());

        if (user == null) {
            request.setAttribute("error", "User not found.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if ("ACTIVE".equals(user.getStatus())) {
            request.setAttribute("error", "Your account is already verified. Please login.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Activate user
        user.setStatus("ACTIVE");
        userDAO.update(user);
        tokenDAO.markUsed(vt.getId());

        // Send welcome email (best-effort)
        try {
            String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
            Map<String, String> placeholders = new HashMap<>();
            placeholders.put("USERNAME", user.getUsername());
            placeholders.put("DASHBOARD_LINK", baseUrl + "/login.jsp");
            String htmlBody = EmailUtils.loadTemplate(
                getServletContext(), "welcome", placeholders);
            EmailUtils.sendEmail(user.getEmail(), "Welcome to Network Manager", htmlBody);
        } catch (Exception e) {
            e.printStackTrace(); // log and ignore — welcome is best-effort
        }

        request.setAttribute("success", "Email verified successfully! You can now login.");
        request.getRequestDispatcher("email-verified.jsp").forward(request, response);
    }
}
```

- [ ] **Step 3: Create ResendVerificationController.java**

```java
package Controller;

import Models.UserDTO;
import Models.VerificationToken;
import Models_DAO.UserDAO;
import Models_DAO.VerificationTokenDAO;
import Utils.EmailUtils;
import Utils.TokenUtils;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ResendVerificationController", urlPatterns = {"/ResendVerificationController"})
public class ResendVerificationController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        UserDTO user = (UserDTO) session.getAttribute("LOGIN_USER");
        if (user == null || !"PENDING".equals(user.getStatus())) {
            response.sendRedirect("login.jsp");
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();

        // Cooldown check: 5 minutes
        long recent = tokenDAO.countRecentByUser(user.getUserId(), "VERIFICATION", 5);
        if (recent > 0) {
            request.setAttribute("error", "A verification email was already sent recently. Please check your email.");
            request.getRequestDispatcher("check-email.jsp").forward(request, response);
            return;
        }

        try {
            String token = TokenUtils.generateToken();
            VerificationToken vt = new VerificationToken(
                user.getUserId(), token, "VERIFICATION", TokenUtils.getExpiryDate(24));
            tokenDAO.save(vt);

            String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
            String verifyLink = baseUrl + "/VerifyEmailController?token=" + token;

            Map<String, String> placeholders = new HashMap<>();
            placeholders.put("USERNAME", user.getUsername());
            placeholders.put("VERIFY_LINK", verifyLink);
            placeholders.put("EXPIRY_HOURS", "24");

            String htmlBody = EmailUtils.loadTemplate(
                getServletContext(), "verify-email", placeholders);
            EmailUtils.sendEmail(user.getEmail(), "Verify your account", htmlBody);

            request.setAttribute("success", "Verification email sent. Please check your inbox.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Cannot send email. Please try again later.");
        }

        request.getRequestDispatcher("check-email.jsp").forward(request, response);
    }
}
```

- [ ] **Step 4: Create check-email.jsp**

```jsp
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Check Email</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>Check Your Email</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>
        <p>We sent a verification email. Please check your inbox and click the link to activate your account.</p>
        <p>Didn't receive the email?
        <form action="ResendVerificationController" method="post" style="display:inline;">
            <button type="submit" class="btn-link">Resend verification email</button>
        </form>
        </p>
        <a href="login.jsp">Back to Login</a>
    </div>
</body>
</html>
```

- [ ] **Step 5: Create email-verified.jsp**

```jsp
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Email Verified</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>Email Verified Successfully</h2>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>
        <a href="login.jsp" class="btn">Login Now</a>
    </div>
</body>
</html>
```

- [ ] **Step 6: Create verify-email-failed.jsp**

```jsp
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verification Failed</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>Verification Failed</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <a href="login.jsp" class="btn">Back to Login</a>
    </div>
</body>
</html>
```

---

### Task 4: Implement forgot/reset password flow

**Files:**
- Create: `src/java/Controller/ForgotPasswordController.java`
- Create: `src/java/Controller/ResetPasswordController.java`
- Modify: `src/java/Controller/LoginController.java`
- Create: `web/forgot-password.jsp`
- Create: `web/reset-password.jsp`

**Interfaces:**
- Consumes: `EmailUtils`, `TokenUtils`, `VerificationTokenDAO`, `UserDAO`
- Produces:
  - `ForgotPasswordController` — GET show form; POST send reset email
  - `ResetPasswordController` — GET `?token=xxx` validate; POST update password
  - `LoginController` — add PENDING block + forgot password link

- [ ] **Step 1: ForgotPasswordController.java**

```java
package Controller;

import Models.UserDTO;
import Models.VerificationToken;
import Models_DAO.UserDAO;
import Models_DAO.VerificationTokenDAO;
import Utils.EmailUtils;
import Utils.TokenUtils;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/ForgotPasswordController"})
public class ForgotPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your email.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        UserDTO user = userDAO.searchByNameOrEmail(email.trim());

        if (user == null) {
            request.setAttribute("error", "No account found with this email.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();

        // Cooldown check: 5 minutes
        long recent = tokenDAO.countRecentByUser(user.getUserId(), "RESET", 5);
        if (recent > 0) {
            request.setAttribute("error", "A reset email was already sent recently. Please check your inbox.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            String token = TokenUtils.generateToken();
            VerificationToken vt = new VerificationToken(
                user.getUserId(), token, "RESET", TokenUtils.getExpiryDate(24));
            tokenDAO.save(vt);

            String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
            String resetLink = baseUrl + "/ResetPasswordController?token=" + token;

            Map<String, String> placeholders = new HashMap<>();
            placeholders.put("USERNAME", user.getUsername());
            placeholders.put("RESET_LINK", resetLink);
            placeholders.put("EXPIRY_HOURS", "24");

            String htmlBody = EmailUtils.loadTemplate(
                getServletContext(), "reset-password", placeholders);
            EmailUtils.sendEmail(user.getEmail(), "Reset your password", htmlBody);

            request.setAttribute("success", "Reset link sent. Please check your email.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Cannot send email. Please try again later.");
        }

        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }
}
```

- [ ] **Step 2: ResetPasswordController.java**

```java
package Controller;

import Models.UserDTO;
import Models.VerificationToken;
import Models_DAO.UserDAO;
import Models_DAO.VerificationTokenDAO;
import Utils.PasswordUtils;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ResetPasswordController", urlPatterns = {"/ResetPasswordController"})
public class ResetPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid reset link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();
        VerificationToken vt = tokenDAO.findByToken(token.trim());

        if (vt == null) {
            request.setAttribute("error", "Invalid reset link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isUsed()) {
            request.setAttribute("error", "This reset link has already been used.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isExpired()) {
            request.setAttribute("error", "Reset link has expired. Please request a new one.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        // Show form with token in hidden field
        request.setAttribute("token", token);
        response.setHeader("Referrer-Policy", "no-referrer");
        request.getRequestDispatcher("reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (token == null || newPassword == null || confirmPassword == null
            || newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();
        VerificationToken vt = tokenDAO.findByToken(token);

        if (vt == null || vt.isUsed() || vt.isExpired()) {
            request.setAttribute("error", "Invalid or expired reset link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        // Update password (may also activate PENDING user)
        UserDAO userDAO = new UserDAO();
        UserDTO user = userDAO.searchById(vt.getUserId());
        if (user != null) {
            user.setPassword(PasswordUtils.hashPassword(newPassword));
            if ("PENDING".equals(user.getStatus())) {
                user.setStatus("ACTIVE");
            }
            userDAO.update(user);
        }
        // Invalidate all reset tokens for this user (independent transaction)
        tokenDAO.markAllUsed(vt.getUserId(), "RESET");

        request.setAttribute("success", "Password reset successfully. Please login.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
```

- [ ] **Step 3: Modify LoginController — block PENDING + add forgot link**

In the login validation block, after user != null check, add PENDING check:
```java
if ("PENDING".equals(user.getStatus())) {
    request.setAttribute("error", "Please verify your email before logging in. "
        + "<a href='check-email.jsp'>Resend verification</a>");
    request.getRequestDispatcher("login.jsp").forward(request, response);
    return;
}
```

No new import needed (uses existing UserDTO status field comparison).

On the login.jsp page, add a "Forgot Password?" link below the login form.

- [ ] **Step 4: Create forgot-password.jsp**

```jsp
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Forgot Password</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>Forgot Password</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>
        <form action="ForgotPasswordController" method="post">
            <label for="email">Enter your email:</label>
            <input type="email" id="email" name="email" required>
            <button type="submit" class="btn">Send Reset Link</button>
        </form>
        <a href="login.jsp">Back to Login</a>
    </div>
</body>
</html>
```

- [ ] **Step 5: Create reset-password.jsp (with Referrer-Policy header)**

```jsp
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    response.setHeader("Referrer-Policy", "no-referrer");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset Password</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>Reset Password</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <form action="ResetPasswordController" method="post">
            <input type="hidden" name="token" value="<%= request.getAttribute("token") %>">
            <label for="newPassword">New Password:</label>
            <input type="password" id="newPassword" name="newPassword" required>
            <label for="confirmPassword">Confirm Password:</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required>
            <button type="submit" class="btn">Reset Password</button>
        </form>
        <a href="login.jsp">Back to Login</a>
    </div>
</body>
</html>
```

---

### Task 5: Create email HTML templates + implement alert email

**Files:**
- Create: `web/email-templates/verify-email.html`
- Create: `web/email-templates/welcome.html`
- Create: `web/email-templates/reset-password.html`
- Create: `web/email-templates/alert.html`
- Modify: (find and modify the alert/notification controller)

**Interfaces:**
- Consumes: `EmailUtils`
- Produces: HTML email templates with `{{PLACEHOLDER}}` variables

- [ ] **Step 1: verify-email.html**

```html
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 20px;">
    <table style="max-width:600px; margin:0 auto; background:#fff; border-radius:8px; overflow:hidden;">
        <tr><td style="background:#2563eb; padding:20px; text-align:center;">
            <h1 style="color:#fff; margin:0;">Verify Your Email</h1>
        </td></tr>
        <tr><td style="padding:30px;">
            <p>Hi {{USERNAME}},</p>
            <p>Thank you for registering. Please click the button below to verify your email address.</p>
            <p style="text-align:center; margin:30px 0;">
                <a href="{{VERIFY_LINK}}" style="display:inline-block; padding:12px 30px; background:#2563eb; color:#fff; text-decoration:none; border-radius:5px; font-size:16px;">Verify Email</a>
            </p>
            <p>This link expires in {{EXPIRY_HOURS}} hours.</p>
            <p>If you didn't create this account, please ignore this email.</p>
        </td></tr>
    </table>
</body>
</html>
```

- [ ] **Step 2: welcome.html**

```html
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 20px;">
    <table style="max-width:600px; margin:0 auto; background:#fff; border-radius:8px; overflow:hidden;">
        <tr><td style="background:#16a34a; padding:20px; text-align:center;">
            <h1 style="color:#fff; margin:0;">Welcome!</h1>
        </td></tr>
        <tr><td style="padding:30px;">
            <p>Hi {{USERNAME}},</p>
            <p>Your email has been verified successfully. You can now log in and start using the Network Manager system.</p>
            <p style="text-align:center; margin:30px 0;">
                <a href="{{DASHBOARD_LINK}}" style="display:inline-block; padding:12px 30px; #16a34a; color:#fff; text-decoration:none; border-radius:5px; font-size:16px;">Go to Dashboard</a>
            </p>
        </td></tr>
    </table>
</body>
</html>
```

- [ ] **Step 3: reset-password.html**

```html
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 20px;">
    <table style="max-width:600px; margin:0 auto; background:#fff; border-radius:8px; overflow:hidden;">
        <tr><td style="background:#dc2626; padding:20px; text-align:center;">
            <h1 style="color:#fff; margin:0;">Reset Password</h1>
        </td></tr>
        <tr><td style="padding:30px;">
            <p>Hi {{USERNAME}},</p>
            <p>We received a request to reset your password. Click the button below to set a new one.</p>
            <p style="text-align:center; margin:30px 0;">
                <a href="{{RESET_LINK}}" style="display:inline-block; padding:12px 30px; background:#dc2626; color:#fff; text-decoration:none; border-radius:5px; font-size:16px;">Reset Password</a>
            </p>
            <p>This link expires in {{EXPIRY_HOURS}} hours.</p>
            <p>If you didn't request this, please ignore this email.</p>
        </td></tr>
    </table>
</body>
</html>
```

- [ ] **Step 4: alert.html**

```html
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 20px;">
    <table style="max-width:600px; margin:0 auto; background:#fff; border-radius:8px; overflow:hidden;">
        <tr><td style="background:{{ALERT_COLOR}}; padding:20px; text-align:center;">
            <h1 style="color:#fff; margin:0;">{{ALERT_TITLE}}</h1>
        </td></tr>
        <tr><td style="padding:30px;">
            <p>Hi {{USERNAME}},</p>
            <p><strong>Severity:</strong> {{ALERT_SEVERITY}}</p>
            <p>{{ALERT_DETAIL}}</p>
            <p>Please check the system for more information.</p>
        </td></tr>
    </table>
</body>
</html>
```

- [ ] **Step 5: Update alert controller (async)**

Find the existing alert creation controller (e.g., `NetworkAlertController` or similar). After the alert is saved to DB, add:

```java
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import Utils.EmailUtils;
import java.util.HashMap;
import java.util.Map;

// Inside the method after alert is saved:
ExecutorService executor = Executors.newSingleThreadExecutor();
executor.submit(() -> {
    try {
        UserDAO userDAO = new UserDAO();
        String alertTitle = request.getParameter("title");
        String alertDetail = request.getParameter("detail");
        String severity = request.getParameter("severity");

        // Color based on severity
        String color = "#f59e0b"; // default warning
        if ("CRITICAL".equalsIgnoreCase(severity)) color = "#dc2626";
        else if ("INFO".equalsIgnoreCase(severity)) color = "#2563eb";
        else if ("LOW".equalsIgnoreCase(severity)) color = "#16a34a";

        for (UserDTO u : userDAO.ListAll()) {
            if ("ACTIVE".equals(u.getStatus())) {
                Map<String, String> placeholders = new HashMap<>();
                placeholders.put("USERNAME", u.getUsername());
                placeholders.put("ALERT_TITLE", alertTitle);
                placeholders.put("ALERT_DETAIL", alertDetail);
                placeholders.put("ALERT_SEVERITY", severity);
                placeholders.put("ALERT_COLOR", color);
                String html = EmailUtils.loadTemplate(
                    getServletContext(), "alert", placeholders);
                EmailUtils.sendEmail(u.getEmail(), "Alert: " + alertTitle, html);
            }
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }
});
executor.shutdown();
```

---

### Task 6: Make UserDAO.executeInTransaction public

**Files:**
- Modify: `src/java/Models_DAO/UserDAO.java` (change `executeInTransaction` from `private` to `public`)

**Note:** `UserDAO.searchById(Integer)` already exists (line 92), no need to add.

- [ ] **Step 1: Make executeInTransaction public in UserDAO.java**

Change line 28 from:
```java
    private boolean executeInTransaction(Consumer<EntityManager> action) {
```
to:
```java
    public boolean executeInTransaction(Consumer<EntityManager> action) {
```

This allows `ResetPasswordController` (Task 4) to call `userDAO.executeInTransaction(...)`. Follows the same pattern used by `updateStatus()` which already calls `executeInTransaction` internally.

---

### Task 7: Compile and verify

- [ ] **Step 1: Clean build and compile all files**

```bash
javac -encoding UTF-8 -cp "web/lib/*;web/WEB-INF/lib/*;build/web/WEB-INF/classes" -d build/web/WEB-INF/classes -sourcepath src/java src/java/Utils/EmailUtils.java src/java/Utils/TokenUtils.java src/java/Models/VerificationToken.java src/java/Models_DAO/VerificationTokenDAO.java src/java/Controller/VerifyEmailController.java src/java/Controller/ForgotPasswordController.java src/java/Controller/ResetPasswordController.java src/java/Controller/ResendVerificationController.java src/java/Controller/RegisterUserController.java src/java/Controller/LoginController.java src/java/Models_DAO/UserDAO.java 2>&1
```

Expected: Compilation success (0 errors). Ignore pre-existing encoding warnings on Vietnamese comments.

- [ ] **Step 2: Run SQL migration against database**

Execute `web/lib/migration-002-verification-token.sql` in SQL Server Management Studio or via sqlcmd against the `network_simulation_db3` database.

- [ ] **Step 3: Commit all changes**

```bash
git add -A
git commit -m "feat: add email verification, password reset, and alert notifications"
```
