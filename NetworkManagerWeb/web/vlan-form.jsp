<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="vlan" value="${requestScope.vlan}" />
<c:set var="formVLAN" value="${requestScope.formVLAN}" />
<c:set var="returnTo"
       value="${not empty requestScope.returnTo
                ? requestScope.returnTo
                : param.returnTo}" />
<c:set var="editMode"
       value="${not empty vlan
                or (not empty formVLAN and formVLAN.vlanId > 0)}" />

<c:choose>
    <c:when test="${not empty formVLAN}">
        <c:set var="valueVLAN" value="${formVLAN}" />
    </c:when>
    <c:otherwise>
        <c:set var="valueVLAN" value="${vlan}" />
    </c:otherwise>
</c:choose>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${editMode}">Edit VLAN</c:when>
            <c:otherwise>Add VLAN</c:otherwise>
        </c:choose>
    </title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">
    <style>
        :root {
            --bg: #07101f;
            --panel: #10192b;
            --panel-2: #16233a;
            --border: #2b3b59;
            --text: #f4f7ff;
            --muted: #9fb0d0;
            --primary: #8b5cf6;
            --cyan: #22d3ee;
        }

        body {
            min-height: 100vh;
            background:
                linear-gradient(rgba(7, 16, 31, .92), rgba(7, 16, 31, .96)),
                url("theme/79d83127c07915acf13c142fd22f87d0.png") center/cover fixed;
            color: var(--text);
        }

        .form-shell {
            max-width: 980px;
            margin: 0 auto;
        }

        .page-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 18px;
        }

        .title-mark {
            width: 46px;
            height: 46px;
            border-radius: 8px;
            display: grid;
            place-items: center;
            background: rgba(139, 92, 246, .16);
            color: #c4b5fd;
            font-size: 22px;
        }

        .form-panel {
            background: rgba(16, 25, 43, .94);
            border: 1px solid var(--border);
            border-radius: 8px;
            box-shadow: 0 18px 40px rgba(0, 0, 0, .28);
        }

        .panel-header {
            padding: 18px 22px;
            border-bottom: 1px solid var(--border);
            background: rgba(22, 35, 58, .74);
        }

        .panel-body {
            padding: 24px;
        }

        .form-label {
            color: #dbe7ff;
            font-weight: 600;
            font-size: 13px;
        }

        .form-control,
        .form-select {
            background-color: #0d1728;
            border-color: #30415f;
            color: var(--text);
            border-radius: 8px;
        }

        .form-control:focus,
        .form-select:focus {
            background-color: #0d1728;
            border-color: var(--primary);
            color: var(--text);
            box-shadow: 0 0 0 .2rem rgba(139, 92, 246, .18);
        }

        .form-text,
        .hint {
            color: var(--muted);
            font-size: 12px;
        }

        .btn {
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-primary {
            background: linear-gradient(135deg, #6d28d9, #22d3ee);
            border: 0;
        }

        .btn-outline-light {
            border-color: #526480;
            color: #e7eefc;
        }
    </style>
</head>

<body>
    <div class="container py-4">
        <div class="form-shell">
            <div class="page-head">
                <div class="d-flex align-items-center gap-3">
                    <div class="title-mark">
                        <i class="bi bi-diagram-3"></i>
                    </div>
                    <div>
                        <h1 class="h3 mb-1">
                            <c:choose>
                                <c:when test="${editMode}">Edit VLAN</c:when>
                                <c:otherwise>Add VLAN</c:otherwise>
                            </c:choose>
                        </h1>
                        <div class="text-secondary">Define subnet purpose and optional room assignment</div>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${returnTo eq 'dashboard'}">
                        <a class="btn btn-outline-light"
                           href="staffDashboard.jsp?page=vlan">
                            <i class="bi bi-arrow-left me-1"></i>
                            Back
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-outline-light"
                           href="MainController?action=vlanList">
                            <i class="bi bi-arrow-left me-1"></i>
                            Back
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger">
                    <c:out value="${requestScope.error}" />
                </div>
            </c:if>

            <form class="form-panel"
                  action="MainController"
                  method="post">
                <div class="panel-header">
                    <div class="fw-semibold">VLAN Information</div>
                    <div class="hint">Use clear names and CIDR subnet notation for easier operations.</div>
                </div>

                <div class="panel-body">
                    <c:choose>
                        <c:when test="${editMode}">
                            <input type="hidden"
                                   name="action"
                                   value="vlanUpdate">
                            <input type="hidden"
                                   name="vlanId"
                                   value="${valueVLAN.vlanId}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden"
                                   name="action"
                                   value="vlanInsert">
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${not empty returnTo}">
                        <input type="hidden"
                               name="returnTo"
                               value="${returnTo}">
                    </c:if>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label"
                                   for="vlanName">
                                VLAN Name
                            </label>
                            <input class="form-control"
                                   id="vlanName"
                                   type="text"
                                   name="vlanName"
                                   value="${fn:escapeXml(valueVLAN.vlanName)}"
                                   maxlength="100"
                                   placeholder="Example: Student VLAN"
                                   required>
                            <div class="form-text">VLAN name must be unique.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label"
                                   for="subnet">
                                Subnet
                            </label>
                            <input class="form-control"
                                   id="subnet"
                                   type="text"
                                   name="subnet"
                                   value="${fn:escapeXml(valueVLAN.subnet)}"
                                   maxlength="50"
                                   placeholder="Example: 192.168.10.0/24">
                            <div class="form-text">Enter an IPv4 subnet in CIDR format.</div>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label"
                                   for="purpose">
                                Purpose
                            </label>
                            <textarea class="form-control"
                                      id="purpose"
                                      name="purpose"
                                      rows="4"
                                      maxlength="255"
                                      placeholder="Describe the purpose of this VLAN"><c:out value="${valueVLAN.purpose}" /></textarea>
                            <div class="form-text">Maximum 255 characters.</div>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label"
                                   for="roomId">
                                Room
                            </label>
                            <select class="form-select"
                                    id="roomId"
                                    name="roomId">
                                <option value=""
                                        ${empty valueVLAN.roomId
                                          ? 'selected="selected"'
                                          : ''}>
                                    No room assigned
                                </option>

                                <c:forEach var="room"
                                           items="${rooms}">
                                    <option value="${room.roomId}"
                                            ${valueVLAN.roomId eq room.roomId
                                              ? 'selected="selected"'
                                              : ''}>
                                        <c:out value="${room.roomName}" />
                                        <c:if test="${not empty room.building}">
                                            -
                                            <c:out value="${room.building}" />
                                        </c:if>
                                        (Floor <c:out value="${room.floor}" />)
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="form-text">Room is optional, but the selected room must exist.</div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <c:choose>
                            <c:when test="${returnTo eq 'dashboard'}">
                                <a class="btn btn-outline-light"
                                   href="staffDashboard.jsp?page=vlan">
                                    Cancel
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a class="btn btn-outline-light"
                                   href="MainController?action=vlanList">
                                    Cancel
                                </a>
                            </c:otherwise>
                        </c:choose>

                        <button class="btn btn-primary"
                                type="submit">
                            <i class="bi bi-check2 me-1"></i>
                            Save VLAN
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
