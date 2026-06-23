<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="room" value="${requestScope.room}" />
<c:set var="formRoom" value="${requestScope.formRoom}" />
<c:set var="returnTo"
       value="${not empty requestScope.returnTo
                ? requestScope.returnTo
                : param.returnTo}" />
<c:set var="editMode"
       value="${not empty room
                or (not empty formRoom and formRoom.roomId > 0)}" />

<c:choose>
    <c:when test="${not empty formRoom}">
        <c:set var="valueRoom" value="${formRoom}" />
    </c:when>
    <c:otherwise>
        <c:set var="valueRoom" value="${room}" />
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
            <c:when test="${editMode}">Edit Room</c:when>
            <c:otherwise>Add Room</c:otherwise>
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
            --primary: #60a5fa;
            --success: #34d399;
        }

        body {
            min-height: 100vh;
            background:
                linear-gradient(rgba(7, 16, 31, .92), rgba(7, 16, 31, .96)),
                url("theme/79d83127c07915acf13c142fd22f87d0.png") center/cover fixed;
            color: var(--text);
        }

        .form-shell {
            max-width: 920px;
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
            background: rgba(96, 165, 250, .16);
            color: var(--primary);
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
            box-shadow: 0 0 0 .2rem rgba(96, 165, 250, .18);
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
            background: linear-gradient(135deg, #2563eb, #60a5fa);
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
                        <i class="bi bi-building"></i>
                    </div>
                    <div>
                        <h1 class="h3 mb-1">
                            <c:choose>
                                <c:when test="${editMode}">Edit Room</c:when>
                                <c:otherwise>Add Room</c:otherwise>
                            </c:choose>
                        </h1>
                        <div class="text-secondary">Manage room details for network locations</div>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${returnTo eq 'dashboard'}">
                        <a class="btn btn-outline-light"
                           href="staffDashboard.jsp?page=rooms">
                            <i class="bi bi-arrow-left me-1"></i>
                            Back
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-outline-light"
                           href="MainController?action=roomList">
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
                    <div class="fw-semibold">Room Information</div>
                    <div class="hint">Required fields are marked by browser validation.</div>
                </div>

                <div class="panel-body">
                    <c:choose>
                        <c:when test="${editMode}">
                            <input type="hidden"
                                   name="action"
                                   value="roomUpdate">
                            <input type="hidden"
                                   name="roomId"
                                   value="${valueRoom.roomId}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden"
                                   name="action"
                                   value="roomInsert">
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${not empty returnTo}">
                        <input type="hidden"
                               name="returnTo"
                               value="${returnTo}">
                    </c:if>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Room Name</label>
                            <input class="form-control"
                                   type="text"
                                   name="roomName"
                                   value="${fn:escapeXml(valueRoom.roomName)}"
                                   maxlength="100"
                                   placeholder="Example: Lab A101"
                                   required>
                            <div class="hint">A short name used across dashboard lists.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Building</label>
                            <input class="form-control"
                                   type="text"
                                   name="building"
                                   value="${fn:escapeXml(valueRoom.building)}"
                                   maxlength="100"
                                   placeholder="Example: Building A">
                            <div class="hint">Optional building or area name.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Floor</label>
                            <input class="form-control"
                                   type="number"
                                   name="floor"
                                   min="1"
                                   value="${empty valueRoom.floor
                                            ? 1
                                            : valueRoom.floor}"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Capacity</label>
                            <input class="form-control"
                                   type="number"
                                   name="capacity"
                                   min="0"
                                   value="${empty valueRoom.capacity
                                            ? 0
                                            : valueRoom.capacity}"
                                   required>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <c:choose>
                            <c:when test="${returnTo eq 'dashboard'}">
                                <a class="btn btn-outline-light"
                                   href="staffDashboard.jsp?page=rooms">
                                    Cancel
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a class="btn btn-outline-light"
                                   href="MainController?action=roomList">
                                    Cancel
                                </a>
                            </c:otherwise>
                        </c:choose>

                        <button class="btn btn-primary"
                                type="submit">
                            <i class="bi bi-check2 me-1"></i>
                            Save Room
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
