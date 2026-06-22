package Utils;

import Models.PaymentTransactionDTO;

public class VnpayCallbackResult {

    private final String responseCode;
    private final String message;
    private final PaymentTransactionDTO payment;
    private final boolean signatureValid;

    public VnpayCallbackResult(String responseCode, String message,
            PaymentTransactionDTO payment, boolean signatureValid) {
        this.responseCode = responseCode;
        this.message = message;
        this.payment = payment;
        this.signatureValid = signatureValid;
    }

    public String getResponseCode() { return responseCode; }
    public String getMessage() { return message; }
    public PaymentTransactionDTO getPayment() { return payment; }
    public boolean isSignatureValid() { return signatureValid; }
}
