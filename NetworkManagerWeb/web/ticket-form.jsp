<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ticket" value="${requestScope.ticket}" />
<c:set var="formTicket" value="${requestScope.formTicket}" />
<c:set var="returnTo"
       value="${not empty requestScope.returnTo
                ? requestScope.returnTo
                : param.returnTo}" />
<c:set var="editMode"
       value="${not empty ticket
                or (not empty formTicket and formTicket.ticketId > 0)}" />

<c:choose>
    <c:when test="${not empty formTicket}">
        <c:set var="valueTicket" value="${formTicket}" />
    </c:when>
    <c:otherwise>
        <c:set var="valueTicket" value="${ticket}" />
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
            <c:when test="${editMode}">Edit Support Ticket</c:when>
            <c:otherwise>Add Support Ticket</c:otherwise>
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
            --warning: #f59e0b;
            --danger: #fb7185;
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
            background: rgba(245, 158, 11, .16);
            color: var(--warning);
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
            border-color: var(--warning);
            color: var(--text);
            box-shadow: 0 0 0 .2rem rgba(245, 158, 11, .18);
        }

        .hint {
            color: var(--muted);
            font-size: 12px;
            margin-top: 6px;
        }

        .btn {
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-primary {
            background: linear-gradient(135deg, #dc2626, #f59e0b);
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
                        <i class="bi bi-ticket-perforated"></i>
                    </div>
                    <div>
                        <h1 class="h3 mb-1">
                            <c:choose>
                                <c:when test="${editMode}">Edit Support Ticket</c:when>
                                <c:otherwise>Add Support Ticket</c:otherwise>
                            </c:choose>
                        </h1>
                        <div class="text-secondary">Track network issues and device-related requests</div>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${returnTo eq 'dashboard'}">
                        <a class="btn btn-outline-light"
                           href="staffDashboard.jsp?page=tickets">
                            <i class="bi bi-arrow-left me-1"></i>
                            Back
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-outline-light"
                           href="MainController?action=ticketList">
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
                    <div class="fw-semibold">Ticket Information</div>
                    <div class="hint">Use a clear title and assign the related user or device when available.</div>
                </div>

                <div class="panel-body">
                    <c:choose>
                        <c:when test="${editMode}">
                            <input type="hidden"
                                   name="action"
                                   value="ticketUpdate">
                            <input type="hidden"
                                   name="ticketId"
                                   value="${valueTicket.ticketId}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden"
                                   name="action"
                                   value="ticketInsert">
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${not empty returnTo}">
                        <input type="hidden"
                               name="returnTo"
                               value="${returnTo}">
                    </c:if>

                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label">Title</label>
                            <input class="form-control"
                                   type="text"
                                   name="title"
                                   value="${fn:escapeXml(valueTicket.title)}"
                                   maxlength="150"
                                   placeholder="Example: Router connection is unstable"
                                   required>
                            <div class="hint">Keep it short enough to scan in the dashboard.</div>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Status</label>
                            <select class="form-select"
                                    name="status"
                                    required>
                                <option value="OPEN"
                                        ${empty valueTicket.status
                                          or valueTicket.status eq 'OPEN'
                                          ? 'selected'
                                          : ''}>
                                    OPEN
                                </option>
                                <option value="IN_PROGRESS"
                                        ${valueTicket.status eq 'IN_PROGRESS'
                                          ? 'selected'
                                          : ''}>
                                    IN_PROGRESS
                                </option>
                                <option value="RESOLVED"
                                        ${valueTicket.status eq 'RESOLVED'
                                          ? 'selected'
                                          : ''}>
                                    RESOLVED
                                </option>
                                <option value="CLOSED"
                                        ${valueTicket.status eq 'CLOSED'
                                          ? 'selected'
                                          : ''}>
                                    CLOSED
                                </option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea class="form-control"
                                      name="description"
                                      rows="5"
                                      placeholder="Describe the issue, observed time, and affected device or room"><c:out value="${valueTicket.description}" /></textarea>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Created By</label>
                            <select class="form-select"
                                    name="createdBy"
                                    required>
                                <option value=""
                                        ${empty valueTicket.createdBy
                                          or valueTicket.createdBy <= 0
                                          ? 'selected'
                                          : ''}>
                                    Choose a user
                                </option>
                                <c:forEach var="user"
                                           items="${users}">
                                    <option value="${user.userId}"
                                            ${valueTicket.createdBy eq user.userId
                                              ? 'selected'
                                              : ''}>
                                        #${user.userId} - ${fn:escapeXml(user.fullName)}
                                        (${fn:escapeXml(user.username)})
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="hint">Pick the user who created or reported this ticket.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Related Device</label>
                            <select class="form-select"
                                    name="deviceId">
                                <option value=""
                                        ${empty valueTicket.deviceId
                                          ? 'selected'
                                          : ''}>
                                    No device assigned
                                </option>
                                <c:forEach var="device"
                                           items="${devices}">
                                    <option value="${device.deviceId}"
                                            ${valueTicket.deviceId eq device.deviceId
                                              ? 'selected'
                                              : ''}>
                                        #${device.deviceId} - ${fn:escapeXml(device.deviceName)}
                                        <c:if test="${not empty device.deviceType}">
                                            - ${fn:escapeXml(device.deviceType)}
                                        </c:if>
                                        <c:if test="${not empty device.ipAddress}">
                                            - ${fn:escapeXml(device.ipAddress)}
                                        </c:if>
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="hint">Leave it unassigned when the ticket is not tied to a device.</div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <c:choose>
                            <c:when test="${returnTo eq 'dashboard'}">
                                <a class="btn btn-outline-light"
                                   href="staffDashboard.jsp?page=tickets">
                                    Cancel
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a class="btn btn-outline-light"
                                   href="MainController?action=ticketList">
                                    Cancel
                                </a>
                            </c:otherwise>
                        </c:choose>

                        <button class="btn btn-primary"
                                type="submit">
                            <i class="bi bi-check2 me-1"></i>
                            Save Ticket
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
