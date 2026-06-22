package Utils;

import java.util.LinkedHashMap;
import java.util.Map;

/** Lightweight test that can run without JUnit. */
public class VnpayServiceSelfTest {

    public static void main(String[] args) {
        Map<String, String> params = new LinkedHashMap<String, String>();
        params.put("vnp_TxnRef", "NW123");
        params.put("vnp_Amount", "9900000");
        params.put("vnp_TmnCode", "DEMO");
        params.put("vnp_SecureHash",
                "a847445c2a13da6269910211df7b8b5639df69f932b7aee2f02d05fd42e7dc00"
                + "bf1c0b231abdf8b36a58aa95c763a30b8488d7cb245d9790d288f8ad88d5a2e8");

        require(VnpayService.verifySignature(params, "secret"), "valid signature rejected");
        params.put("vnp_Amount", "10000000");
        require(!VnpayService.verifySignature(params, "secret"), "tampered amount accepted");
        require(VnpayService.parseGatewayAmount("9900000") == 99000L, "amount conversion failed");
        require(VnpayService.parseGatewayAmount("9900001") == -1L, "fractional VND accepted");
        System.out.println("VnpayServiceSelfTest: PASS");
    }

    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }
}
