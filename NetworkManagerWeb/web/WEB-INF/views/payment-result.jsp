<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán — Network Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        *{box-sizing:border-box}body{margin:0;min-height:100vh;display:grid;place-items:center;padding:24px;background:radial-gradient(circle at 50% 0,rgba(139,92,246,.2),transparent 35%),#070b16;color:#eef2ff;font-family:"Segoe UI",Arial,sans-serif}.box{width:min(620px,100%);background:linear-gradient(180deg,#17213a,#0f172a);border:1px solid #2b3859;border-radius:20px;padding:28px;box-shadow:0 24px 70px rgba(0,0,0,.35)}.icon{width:72px;height:72px;border-radius:50%;display:grid;place-items:center;font-size:32px;margin:0 auto 16px}.success{background:rgba(52,211,153,.12);color:#6ee7b7;border:1px solid rgba(52,211,153,.32)}.fail{background:rgba(244,63,94,.12);color:#fda4af;border:1px solid rgba(244,63,94,.32)}.pending{background:rgba(245,158,11,.12);color:#fde68a;border:1px solid rgba(245,158,11,.32)}h1{text-align:center;font-size:25px;margin:0 0 8px}.lead{text-align:center;color:#9ba8c9;margin:0 0 24px}.details{border:1px solid #2b3859;border-radius:13px;padding:8px 16px}.row{display:flex;justify-content:space-between;gap:16px;padding:10px 0;border-bottom:1px solid rgba(255,255,255,.06);font-size:14px}.row:last-child{border:0}.row span:first-child{color:#9ba8c9}.buttons{display:flex;gap:10px;margin-top:22px}.btn{flex:1;text-align:center;text-decoration:none;color:white;padding:12px;border-radius:11px;font-weight:700;background:linear-gradient(135deg,#8b5cf6,#d946ef)}.btn.secondary{background:#1d2944;border:1px solid #344467;color:#dbe4ff}@media(max-width:520px){.buttons{flex-direction:column}.row{flex-direction:column;gap:4px}}
    </style>
</head>
<body>
<div class="box">
    <c:choose>
        <c:when test="${processingError}"><div class="icon fail"><i class="bi bi-exclamation-triangle"></i></div><h1>Chưa thể xác nhận giao dịch</h1><p class="lead">Hệ thống đang gặp lỗi khi đọc trạng thái. IPN của VNPAY sẽ tiếp tục xác nhận giao dịch ở phía server.</p></c:when>
        <c:when test="${empty callbackResult or not callbackResult.signatureValid}"><div class="icon fail"><i class="bi bi-shield-x"></i></div><h1>Phản hồi không hợp lệ</h1><p class="lead">Chữ ký VNPAY không hợp lệ. Giao dịch không được cập nhật.</p></c:when>
        <c:when test="${not empty payment and payment.status eq 'SUCCESS'}"><div class="icon success"><i class="bi bi-check-lg"></i></div><h1>Thanh toán thành công</h1><p class="lead">Gói dịch vụ đã được kích hoạt hoặc gia hạn cho tài khoản của bạn.</p></c:when>
        <c:when test="${not empty payment and payment.status eq 'PENDING' and (callbackResult.responseCode eq '00' or callbackResult.responseCode eq '02')}"><div class="icon pending"><i class="bi bi-hourglass-split"></i></div><h1>Đang chờ xác nhận</h1><p class="lead">VNPAY chưa trả trạng thái cuối cùng. Hệ thống sẽ cập nhật qua IPN.</p></c:when>
        <c:otherwise><div class="icon fail"><i class="bi bi-x-lg"></i></div><h1>Thanh toán chưa hoàn tất</h1><p class="lead">Giao dịch bị hủy, hết hạn hoặc không thành công. Tài khoản chưa bị trừ/gia hạn dịch vụ.</p></c:otherwise>
    </c:choose>

    <c:if test="${not empty payment}"><div class="details">
        <div class="row"><span>Mã đơn hàng</span><strong><c:out value="${payment.txnRef}"/></strong></div>
        <div class="row"><span>Gói dịch vụ</span><strong><c:out value="${payment.planName}"/></strong></div>
        <div class="row"><span>Số tiền</span><strong><fmt:formatNumber value="${payment.amount}" type="number"/> ₫</strong></div>
        <div class="row"><span>Trạng thái</span><strong><c:out value="${payment.status}"/></strong></div>
        <div class="row"><span>Mã giao dịch VNPAY</span><strong><c:out value="${empty payment.gatewayTransactionNo ? '—' : payment.gatewayTransactionNo}"/></strong></div>
        <div class="row"><span>Ngân hàng</span><strong><c:out value="${empty payment.bankCode ? '—' : payment.bankCode}"/></strong></div>
        <c:if test="${not empty subscription}"><div class="row"><span>Gói có hiệu lực đến</span><strong><fmt:formatDate value="${subscription.expiresAt}" pattern="dd/MM/yyyy HH:mm"/></strong></div></c:if>
    </div></c:if>

    <div class="buttons"><a class="btn" href="${pageContext.request.contextPath}/payment/checkout">Xem lịch sử / Thử lại</a><c:if test="${not empty sessionScope.user}"><a class="btn secondary" href="${pageContext.request.contextPath}/${sessionScope.role eq 'Viewer' ? 'userDashboard.jsp' : 'staffDashboard.jsp'}">Về dashboard</a></c:if></div>
</div>
</body>
</html>
