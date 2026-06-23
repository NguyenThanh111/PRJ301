package Utils;

import java.security.SecureRandom;
import java.time.LocalDateTime;

public final class TokenUtils {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 32; // 64 hex chars
    private static final char[] HEX_CHARS = "0123456789abcdef".toCharArray();

    private TokenUtils() {}

    public static String generateToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        char[] hex = new char[bytes.length * 2];
        for (int i = 0; i < bytes.length; i++) {
            int v = bytes[i] & 0xFF;
            hex[i * 2] = HEX_CHARS[v >>> 4];
            hex[i * 2 + 1] = HEX_CHARS[v & 0x0F];
        }
        return new String(hex);
    }

    public static LocalDateTime getExpiryDate(int hoursFromNow) {
        return LocalDateTime.now().plusHours(hoursFromNow);
    }
}
