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
        session.setDebug(true);
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
        try (InputStream is = ctx.getResourceAsStream(TEMPLATE_DIR + templateName + ".html")) {
            if (is == null) {
                throw new IOException("Template not found: " + templateName);
            }
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String content = reader.lines().collect(Collectors.joining("\n"));
                for (Map.Entry<String, String> entry : placeholders.entrySet()) {
                    content = content.replace("{{" + entry.getKey() + "}}", entry.getValue());
                }
                return content;
            }
        }
    }
}
