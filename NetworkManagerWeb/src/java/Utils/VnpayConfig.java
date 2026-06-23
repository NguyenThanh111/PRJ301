package Utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

public final class VnpayConfig {

    public static final String DEFAULT_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private final String payUrl;
    private final String tmnCode;
    private final String hashSecret;
    private final String configuredReturnUrl;
    private final String configuredIpnUrl;

    private VnpayConfig(String payUrl, String tmnCode, String hashSecret,
            String configuredReturnUrl, String configuredIpnUrl) {
        this.payUrl = hasText(payUrl) ? payUrl.trim() : DEFAULT_PAY_URL;
        this.tmnCode = trim(tmnCode);
        this.hashSecret = trim(hashSecret);
        this.configuredReturnUrl = trim(configuredReturnUrl);
        this.configuredIpnUrl = trim(configuredIpnUrl);
    }

    public static VnpayConfig load(ServletContext context) {
        Properties file = new Properties();
        try (InputStream input = context.getResourceAsStream("/WEB-INF/vnpay.properties")) {
            if (input != null) {
                file.load(input);
            }
        } catch (IOException ignored) {
            // Environment/system properties can still provide the configuration.
        }

        String payUrl = value("VNPAY_PAY_URL", "vnpay.payUrl", context, file);
        String tmnCode = value("VNPAY_TMN_CODE", "vnpay.tmnCode", context, file);
        String hashSecret = value("VNPAY_HASH_SECRET", "vnpay.hashSecret", context, file);
        String returnUrl = value("VNPAY_RETURN_URL", "vnpay.returnUrl", context, file);
        String ipnUrl = value("VNPAY_IPN_URL", "vnpay.ipnUrl", context, file);
        return new VnpayConfig(payUrl, tmnCode, hashSecret, returnUrl, ipnUrl);
    }

    private static String value(String envName, String propertyName,
            ServletContext context, Properties file) {
        String result = System.getenv(envName);
        if (!hasText(result)) result = System.getProperty(propertyName);
        if (!hasText(result)) result = file.getProperty(propertyName);
        if (!hasText(result)) result = context.getInitParameter(propertyName);
        return result;
    }

    public boolean isConfigured() {
        return hasText(tmnCode) && hasText(hashSecret);
    }

    public String getPayUrl() { return payUrl; }
    public String getTmnCode() { return tmnCode; }
    public String getHashSecret() { return hashSecret; }
    public String getConfiguredIpnUrl() { return configuredIpnUrl; }

    public String resolveReturnUrl(HttpServletRequest request) {
        if (hasText(configuredReturnUrl)) return configuredReturnUrl;
        return applicationBaseUrl(request) + "/vnpay/return";
    }

    public String resolveIpnUrl(HttpServletRequest request) {
        if (hasText(configuredIpnUrl)) return configuredIpnUrl;
        return applicationBaseUrl(request) + "/vnpay/ipn";
    }

    private static String applicationBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String host = request.getServerName();
        int port = request.getServerPort();
        boolean defaultPort = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443);
        return scheme + "://" + host + (defaultPort ? "" : ":" + port) + request.getContextPath();
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
