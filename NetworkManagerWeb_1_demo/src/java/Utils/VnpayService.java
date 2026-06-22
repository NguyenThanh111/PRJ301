package Utils;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.HttpServletRequest;

public final class VnpayService {

    private static final TimeZone VIETNAM_TIME_ZONE = TimeZone.getTimeZone("Asia/Ho_Chi_Minh");
    private static final SecureRandom RANDOM = new SecureRandom();

    private VnpayService() {
    }

    public static String generateTxnRef(int userId) {
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmssSSS", Locale.US);
        format.setTimeZone(VIETNAM_TIME_ZONE);
        return "NW" + format.format(new Date()) + String.format(Locale.US, "%04d%03d",
                Math.abs(userId % 10000), RANDOM.nextInt(1000));
    }

    public static String createPaymentUrl(VnpayConfig config, String txnRef, long amount,
            String orderInfo, String bankCode, String ipAddress, String returnUrl) {
        if (!config.isConfigured()) {
            throw new IllegalStateException("VNPAY chưa được cấu hình TMN Code và Hash Secret");
        }
        if (amount <= 0 || amount > Long.MAX_VALUE / 100L) {
            throw new IllegalArgumentException("Số tiền không hợp lệ");
        }

        Calendar calendar = Calendar.getInstance(VIETNAM_TIME_ZONE, Locale.US);
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss", Locale.US);
        formatter.setTimeZone(VIETNAM_TIME_ZONE);
        String createDate = formatter.format(calendar.getTime());
        calendar.add(Calendar.MINUTE, 15);
        String expireDate = formatter.format(calendar.getTime());

        Map<String, String> params = new LinkedHashMap<String, String>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", config.getTmnCode());
        params.put("vnp_Amount", String.valueOf(amount * 100L));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef);
        params.put("vnp_OrderInfo", orderInfo);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", returnUrl);
        params.put("vnp_IpAddr", normalizeIpAddress(ipAddress));
        params.put("vnp_CreateDate", createDate);
        params.put("vnp_ExpireDate", expireDate);
        if (hasText(bankCode)) params.put("vnp_BankCode", bankCode.trim());

        String hashData = buildCanonicalData(params);
        String secureHash = hmacSha512(config.getHashSecret(), hashData);
        return config.getPayUrl() + "?" + hashData + "&vnp_SecureHash=" + secureHash;
    }

    public static Map<String, String> extractVnpayParams(HttpServletRequest request) {
        Map<String, String> result = new LinkedHashMap<String, String>();
        Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            if (name != null && name.startsWith("vnp_")) {
                result.put(name, request.getParameter(name));
            }
        }
        return result;
    }

    public static boolean verifySignature(Map<String, String> input, String hashSecret) {
        if (input == null || !hasText(hashSecret)) return false;
        String received = input.get("vnp_SecureHash");
        if (!hasText(received)) return false;

        Map<String, String> signed = new LinkedHashMap<String, String>(input);
        signed.remove("vnp_SecureHash");
        signed.remove("vnp_SecureHashType");
        String expected = hmacSha512(hashSecret, buildCanonicalData(signed));
        return MessageDigest.isEqual(expected.toLowerCase(Locale.ROOT).getBytes(StandardCharsets.US_ASCII),
                received.toLowerCase(Locale.ROOT).getBytes(StandardCharsets.US_ASCII));
    }

    public static String buildCanonicalData(Map<String, String> params) {
        List<String> keys = new ArrayList<String>(params.keySet());
        Collections.sort(keys);
        StringBuilder result = new StringBuilder();
        for (String key : keys) {
            String value = params.get(key);
            if (!hasText(value)) continue;
            if (result.length() > 0) result.append('&');
            result.append(urlEncode(key)).append('=').append(urlEncode(value));
        }
        return result.toString();
    }

    public static String auditData(Map<String, String> params) {
        Map<String, String> safe = new LinkedHashMap<String, String>(params);
        safe.remove("vnp_SecureHash");
        safe.remove("vnp_SecureHashType");
        return buildCanonicalData(safe);
    }

    public static Date parsePayDate(String value) {
        if (!hasText(value)) return null;
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss", Locale.US);
        formatter.setLenient(false);
        formatter.setTimeZone(VIETNAM_TIME_ZONE);
        try {
            return formatter.parse(value);
        } catch (ParseException ex) {
            return null;
        }
    }

    public static long parseGatewayAmount(String amount) {
        if (!hasText(amount)) return -1L;
        try {
            long value = Long.parseLong(amount);
            return value >= 0 && value % 100L == 0 ? value / 100L : -1L;
        } catch (NumberFormatException ex) {
            return -1L;
        }
    }

    public static String clientIp(HttpServletRequest request) {
        return normalizeIpAddress(request.getRemoteAddr());
    }

    private static String normalizeIpAddress(String value) {
        if (!hasText(value) || "0:0:0:0:0:0:0:1".equals(value) || "::1".equals(value)) {
            return "127.0.0.1";
        }
        String ip = value.trim();
        return ip.length() <= 45 ? ip : ip.substring(0, 45);
    }

    private static String hmacSha512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] bytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder result = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) result.append(String.format(Locale.US, "%02x", b & 0xff));
            return result.toString();
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("HmacSHA512 không được hỗ trợ", ex);
        } catch (InvalidKeyException ex) {
            throw new IllegalArgumentException("VNPAY Hash Secret không hợp lệ", ex);
        }
    }

    private static String urlEncode(String value) {
        try {
            return URLEncoder.encode(value, "UTF-8");
        } catch (UnsupportedEncodingException ex) {
            throw new IllegalStateException(ex);
        }
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
