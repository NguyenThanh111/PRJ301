<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán VNPAY — Network Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            background: #070b16;
            color: #f2f5ff;
            font-family: "Segoe UI", Arial, sans-serif;
        }
        .wrap { width: 96%; max-width: 1120px; margin: 0 auto; padding: 28px 0 56px; }
        .top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; }
        .brand { display: flex; align-items: center; }
        .brand-icon {
            width: 44px; height: 44px; margin-right: 12px; border-radius: 13px;
            display: flex; align-items: center; justify-content: center;
            background: #8b5cf6; box-shadow: 0 0 24px rgba(139,92,246,.25);
        }
        h1 { font-size: 26px; margin: 0; }
        .muted { color: #9ba8c9; }
        .back { color: #c4b5fd; text-decoration: none; }
        .notice { padding: 14px 16px; border-radius: 12px; margin-bottom: 18px; border: 1px solid; }
        .notice.error { background: rgba(244,63,94,.09); border-color: rgba(251,113,133,.35); color: #fecdd3; }
        .notice.warn { background: rgba(245,158,11,.09); border-color: rgba(251,191,36,.35); color: #fde68a; }
        .grid { display: grid; grid-template-columns: 2fr 1fr; grid-gap: 20px; }
        .card {
            background: #11192c; border: 1px solid #2b3859; border-radius: 16px;
            padding: 20px; box-shadow: 0 18px 48px rgba(0,0,0,.18);
        }
        .card h2 { font-size: 18px; margin: 0 0 16px; }
        .plans { display: grid; grid-gap: 12px; }
        .plan {
            display: block; position: relative; border: 1px solid #2b3859;
            border-radius: 14px; padding: 16px; cursor: pointer; transition: .18s;
        }
        .plan:hover { border-color: #6d5ca8; }
        .plan input { position: absolute; opacity: 0; }
        .plan.selected {
            border-color: #8b5cf6; background: rgba(139,92,246,.1);
            box-shadow: 0 0 0 1px rgba(139,92,246,.35);
        }
        .plan-row { display: flex; justify-content: space-between; }
        .plan-name { font-weight: 700; }
        .price { font-weight: 800; color: #d8b4fe; font-size: 18px; margin-left: 12px; }
        .description { color: #9ba8c9; font-size: 13px; margin-top: 6px; }
        .bank-options { display: grid; grid-template-columns: 1fr 1fr; grid-gap: 8px; margin: 16px 0; }
        .bank { border: 1px solid #2b3859; padding: 11px; border-radius: 10px; color: #cbd5e1; }
        .pay-btn {
            width: 100%; border: 0; border-radius: 12px; padding: 13px 16px;
            color: white; font-weight: 800; font-size: 15px; cursor: pointer;
            background: #8b5cf6; box-shadow: 0 10px 24px rgba(139,92,246,.22);
        }
        .pay-btn:disabled { opacity: .45; cursor: not-allowed; }
        .secure { font-size: 12px; color: #9ba8c9; text-align: center; margin-top: 12px; }
        .sub {
            border: 1px solid rgba(52,211,153,.28); background: rgba(52,211,153,.07);
            border-radius: 12px; padding: 14px; margin-bottom: 14px;
        }
        .sub strong { color: #6ee7b7; }
        .summary-row {
            display: flex; justify-content: space-between; padding: 9px 0;
            border-bottom: 1px solid rgba(255,255,255,.06); font-size: 13px;
        }
        .summary-row:last-child { border: 0; }
        .history { margin-top: 20px; }
        .table-wrap { overflow: auto; }
        .table { width: 100%; border-collapse: collapse; min-width: 720px; }
        .table th, .table td { text-align: left; padding: 11px 10px; border-bottom: 1px solid rgba(255,255,255,.07); font-size: 13px; }
        .table th { color: #8998bd; font-size: 11px; text-transform: uppercase; }
        .status { font-size: 11px; font-weight: 800; border-radius: 999px; padding: 4px 8px; }
        .SUCCESS { color: #6ee7b7; background: rgba(52,211,153,.12); }
        .PENDING { color: #fde68a; background: rgba(245,158,11,.12); }
        .FAILED, .CANCELLED, .EXPIRED { color: #fda4af; background: rgba(244,63,94,.12); }
        @media (max-width: 800px) {
            .grid { grid-template-columns: 1fr; }
            .top { align-items: flex-start; flex-direction: column; }
            .back { margin-top: 12px; }
            .bank-options { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<c:set var="backPage" value="${sessionScope.role eq 'Viewer' ? 'userDashboard.jsp' : 'staffDashboard.jsp'}"/>
<div class="wrap">
    <div class="top">
        <div class="brand"><span class="brand-icon"><i class="bi bi-shield-lock-fill"></i></span><div><h1>Thanh toán dịch vụ</h1><div class="muted">Cổng thanh toán bảo mật VNPAY</div></div></div>
        <a class="back" href="${pageContext.request.contextPath}/${backPage}"><i class="bi bi-arrow-left"></i> Quay lại dashboard</a>
    </div>

    <c:if test="${not empty error}"><div class="notice error"><i class="bi bi-exclamation-circle"></i> <c:out value="${error}"/></div></c:if>
    <c:if test="${vnpayConfigured eq false}"><div class="notice warn"><strong>Chưa có khóa VNPAY.</strong> Giao diện và toàn bộ luồng đã sẵn sàng; nút thanh toán sẽ hoạt động sau khi thêm TMN Code và Hash Secret.</div></c:if>
    <c:if test="${databaseReady eq false}"><div class="notice warn">Database chưa có bảng thanh toán. Chạy <strong>web/lib/VnpayMigration.sql</strong> một lần trên database hiện tại.</div></c:if>

    <div class="grid">
        <section class="card">
            <h2><i class="bi bi-box-seam"></i> Chọn gói dịch vụ</h2>
            <form method="post" action="${pageContext.request.contextPath}/payment/checkout">
                <input type="hidden" name="csrfToken" value="${fn:escapeXml(csrfToken)}">
                <div class="plans">
                    <c:forEach var="plan" items="${plans}">
                        <label class="plan ${plan.code eq selectedPlan.code ? 'selected' : ''}">
                            <c:choose>
                                <c:when test="${plan.code eq selectedPlan.code}">
                                    <input type="radio" name="planCode" value="${plan.code}" checked>
                                </c:when>
                                <c:otherwise>
                                    <input type="radio" name="planCode" value="${plan.code}">
                                </c:otherwise>
                            </c:choose>
                            <span class="plan-row"><span><span class="plan-name"><c:out value="${plan.name}"/></span><span class="description" style="display:block"><c:out value="${plan.durationDays}"/> ngày sử dụng</span></span><span class="price"><fmt:formatNumber value="${plan.amount}" type="number" groupingUsed="true"/> ₫</span></span>
                            <span class="description"><c:out value="${plan.description}"/></span>
                        </label>
                    </c:forEach>
                </div>
                <h2 style="margin-top:22px"><i class="bi bi-credit-card"></i> Kênh thanh toán</h2>
                <div class="bank-options">
                    <label class="bank"><input type="radio" name="bankCode" value="" checked> VNPAY đề xuất</label>
                    <label class="bank"><input type="radio" name="bankCode" value="VNPAYQR"> QR Code</label>
                    <label class="bank"><input type="radio" name="bankCode" value="VNBANK"> ATM / Ngân hàng</label>
                    <label class="bank"><input type="radio" name="bankCode" value="INTCARD"> Thẻ quốc tế</label>
                </div>
                <c:choose>
                    <c:when test="${vnpayConfigured eq false or databaseReady eq false}">
                        <button class="pay-btn" type="submit" disabled><i class="bi bi-shield-check"></i> Thanh toán qua VNPAY</button>
                    </c:when>
                    <c:otherwise>
                        <button class="pay-btn" type="submit"><i class="bi bi-shield-check"></i> Thanh toán qua VNPAY</button>
                    </c:otherwise>
                </c:choose>
                <div class="secure"><i class="bi bi-lock"></i> Số tiền được xác thực tại server. Bạn sẽ được chuyển đến trang chính thức của VNPAY.</div>
            </form>
        </section>

        <aside class="card">
            <h2>Thông tin tài khoản</h2>
            <c:choose><c:when test="${not empty subscription}"><div class="sub"><div class="muted">Gói đang sử dụng</div><strong><c:out value="${subscription.planName}"/></strong><div class="description">Hết hạn: <fmt:formatDate value="${subscription.expiresAt}" pattern="dd/MM/yyyy HH:mm"/></div></div></c:when><c:otherwise><div class="sub" style="border-color:#2b3859;background:rgba(255,255,255,.025)"><div class="muted">Chưa có gói dịch vụ đang hoạt động</div></div></c:otherwise></c:choose>
            <div class="summary-row"><span class="muted">Khách hàng</span><strong><c:out value="${sessionScope.user.fullName}"/></strong></div>
            <div class="summary-row"><span class="muted">Đơn vị tiền</span><strong>VND</strong></div>
            <div class="summary-row"><span class="muted">Thời gian thanh toán</span><strong>15 phút</strong></div>
            <div class="summary-row"><span class="muted">Xác nhận</span><strong>Return URL + IPN</strong></div>
            <div class="description" style="margin-top:16px">IPN đăng ký tại VNPAY:<br><code style="color:#c4b5fd;word-break:break-all"><c:out value="${ipnUrl}"/></code></div>
        </aside>
    </div>

    <section class="card history">
        <h2><i class="bi bi-clock-history"></i> Lịch sử giao dịch</h2>
        <div class="table-wrap"><table class="table"><thead><tr><th>Mã đơn</th><th>Gói</th><th>Số tiền</th><th>Trạng thái</th><th>Ngân hàng</th><th>Thời gian</th></tr></thead><tbody>
        <c:choose><c:when test="${not empty payments}"><c:forEach var="payment" items="${payments}"><tr><td><c:out value="${payment.txnRef}"/></td><td><c:out value="${payment.planName}"/></td><td><fmt:formatNumber value="${payment.amount}" type="number"/> ₫</td><td><span class="status ${payment.status}"><c:out value="${payment.status}"/></span></td><td><c:out value="${empty payment.bankCode ? '—' : payment.bankCode}"/></td><td><fmt:formatDate value="${payment.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td></tr></c:forEach></c:when><c:otherwise><tr><td colspan="6" class="muted">Chưa có giao dịch nào.</td></tr></c:otherwise></c:choose>
        </tbody></table></div>
    </section>
</div>
<script>
    document.querySelectorAll('input[name="planCode"]').forEach(function (input) {
        input.addEventListener('change', function () {
            document.querySelectorAll('.plan').forEach(function (plan) {
                plan.classList.remove('selected');
            });
            this.closest('.plan').classList.add('selected');
        });
    });
</script>
</body>
</html>
