<%-- 
    Document   : ip-list
    Created on : Jun 20, 2026, 1:50:11 AM
    Author     : 84382
--%>

<%@page contentType="text/html"
        pageEncoding="UTF-8"%>

<%@taglib prefix="c"
          uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn"
          uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>IP Address Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">

    <style>
        body {
            background: #080c18;
            color: #f2f5ff;
            min-height: 100vh;
        }

        .ip-card {
            background: #10172a;
            border: 1px solid #2a3555;
            border-radius: 14px;
        }

        .summary-card {
            background: #161f36;
            border: 1px solid #2a3555;
            border-radius: 12px;
            padding: 16px;
        }

        .ip-address {
            font-family: "Courier New", monospace;
            color: #22d3ee;
            background: rgba(34, 211, 238, 0.08);
            border: 1px solid rgba(34, 211, 238, 0.2);
            border-radius: 6px;
            padding: 4px 9px;
        }

        .status-available {
            color: #4ade80;
            background: rgba(74, 222, 128, 0.12);
            border: 1px solid rgba(74, 222, 128, 0.3);
        }

        .status-assigned {
            color: #60a5fa;
            background: rgba(96, 165, 250, 0.12);
            border: 1px solid rgba(96, 165, 250, 0.3);
        }

        .status-other {
            color: #fbbf24;
            background: rgba(251, 191, 36, 0.12);
            border: 1px solid rgba(251, 191, 36, 0.3);
        }

        .status-badge {
            display: inline-block;
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 700;
        }

        .table {
            --bs-table-bg: transparent;
            --bs-table-color: #f2f5ff;
            --bs-table-border-color: #2a3555;
            --bs-table-hover-bg: rgba(139, 92, 246, 0.08);
            --bs-table-hover-color: #ffffff;
        }

        .table thead th {
            color: #9aa6c7;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .06em;
        }

        .page-link {
            background: #10172a;
            border-color: #2a3555;
            color: #c4b5fd;
        }

        .page-link:hover {
            background: #1c2540;
            border-color: #8b5cf6;
            color: white;
        }

        .page-item.active .page-link {
            background: #8b5cf6;
            border-color: #8b5cf6;
        }

        .page-item.disabled .page-link {
            background: #0c1120;
            border-color: #222c48;
            color: #5f6d91;
        }

        .inline-device {
            width: 120px;
            background: #0d1728;
            border-color: #30415f;
            color: #f2f5ff;
        }

        .inline-device:focus {
            background: #0d1728;
            border-color: #22d3ee;
            color: #f2f5ff;
            box-shadow: 0 0 0 .15rem rgba(34, 211, 238, .18);
        }

        .action-cell {
            min-width: 260px;
        }

        .search-panel {
            border-bottom: 1px solid #2a3555;
            padding: 16px;
        }

        .search-input {
            background: #0d1728;
            border-color: #30415f;
            color: #f2f5ff;
        }

        .search-input:focus {
            background: #0d1728;
            border-color: #22d3ee;
            color: #f2f5ff;
            box-shadow: 0 0 0 .15rem rgba(34, 211, 238, .18);
        }

        .search-input::placeholder {
            color: #7180a6;
        }

        .modal-content {
            background: #10172a;
            border: 1px solid #2a3555;
            color: #f2f5ff;
        }

        .modal-header,
        .modal-footer {
            border-color: #2a3555;
        }
    </style>
</head>

<body>

<div class="container py-4">

    <div class="d-flex justify-content-between
                align-items-center mb-4">

        <div>
            <h1 class="h3 mb-1">
                <i class="bi bi-globe2 me-2"></i>
                IP Address Management
            </h1>

            <div class="text-secondary">
                View registered and assigned IP addresses
            </div>
        </div>

        <a class="btn btn-outline-light"
           href="staffDashboard.jsp?page=dashboard">

            <i class="bi bi-arrow-left me-1"></i>
            Back to Dashboard
        </a>
    </div>

    <c:if test="${not empty requestScope.error}">
        <div class="alert alert-danger">
            <c:out value="${requestScope.error}" />
        </div>
    </c:if>

    <!-- Summary -->
    <div class="row g-3 mb-4">

        <div class="col-md-4">
            <div class="summary-card">
                <div class="text-secondary small">
                    Total IP Addresses
                </div>

                <div class="fs-3 fw-bold">
                    <c:out value="${totalRecords}"/>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="summary-card">
                <div class="text-secondary small">
                    Available
                </div>

                <div class="fs-3 fw-bold text-success">
                    <c:out value="${availableCount}"/>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="summary-card">
                <div class="text-secondary small">
                    Assigned
                </div>

                <div class="fs-3 fw-bold text-primary">
                    <c:out value="${assignedCount}"/>
                </div>
            </div>
        </div>

    </div>

    <div class="ip-card">

        <div class="search-panel">
            <form action="MainController"
                  method="get"
                  class="row g-2 align-items-center">
                <input type="hidden"
                       name="action"
                       value="ipList">

                <div class="col-md-8">
                    <input class="form-control search-input"
                           type="search"
                           name="keyword"
                           value="${fn:escapeXml(keyword)}"
                           placeholder="Search by IP address, status, IP ID, or device ID">
                </div>

                <div class="col-md-4 d-flex gap-2">
                    <button class="btn btn-info flex-fill"
                            type="submit">
                        <i class="bi bi-search me-1"></i>
                        Search
                    </button>

                    <a class="btn btn-outline-light"
                       href="MainController?action=ipList">
                        Clear
                    </a>
                </div>
            </form>
        </div>

        <div class="table-responsive">

            <table class="table table-hover
                          align-middle mb-0">

                <thead>
                    <tr>
                        <th class="px-4 py-3">ID</th>
                        <th class="py-3">IP Address</th>
                        <th class="py-3">Status</th>
                        <th class="py-3">Assigned Device</th>
                        <th class="py-3">Actions</th>
                    </tr>
                </thead>

                <tbody>

                <c:choose>

                    <c:when test="${not empty ipList}">

                        <c:forEach var="ip"
                                   items="${ipList}">

                            <tr>
                                <td class="px-4">
                                    #<c:out value="${ip.ipId}"/>
                                </td>

                                <td>
                                    <span class="ip-address">
                                        <c:out value="${ip.ipAddress}"/>
                                    </span>
                                </td>

                                <td>
                                    <c:choose>

                                        <c:when test="${ip.status eq 'AVAILABLE'}">
                                            <span class="status-badge
                                                         status-available">
                                                AVAILABLE
                                            </span>
                                        </c:when>

                                        <c:when test="${ip.status eq 'ASSIGNED'}">
                                            <span class="status-badge
                                                         status-assigned">
                                                ASSIGNED
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="status-badge
                                                         status-other">
                                                <c:out value="${ip.status}"/>
                                            </span>
                                        </c:otherwise>

                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>

                                        <c:when test="${not empty ip.deviceId}">
                                            Device #
                                            <c:out value="${ip.deviceId}"/>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="text-secondary">
                                                Not assigned
                                            </span>
                                        </c:otherwise>

                                    </c:choose>
                                </td>

                                <td class="action-cell">
                                    <c:choose>
                                        <c:when test="${empty ip.deviceId}">
                                            <form action="MainController"
                                                  method="post"
                                                  class="d-flex flex-wrap gap-2 align-items-center">

                                                <input type="hidden"
                                                       name="action"
                                                       value="ipAssign">

                                                <input type="hidden"
                                                       name="ipId"
                                                       value="${ip.ipId}">

                                                <input type="hidden"
                                                       name="page"
                                                       value="${currentPage}">

                                                <c:if test="${not empty keyword}">
                                                    <input type="hidden"
                                                           name="keyword"
                                                           value="${fn:escapeXml(keyword)}">
                                                </c:if>

                                                <select class="form-select form-select-sm inline-device"
                                                        name="deviceId"
                                                        required>
                                                    <option value="">
                                                        Select device
                                                    </option>
                                                    <c:forEach var="device"
                                                               items="${availableDevices}">
                                                        <option value="${device.deviceId}">
                                                            #<c:out value="${device.deviceId}" />
                                                            -
                                                            <c:out value="${device.deviceName}" />
                                                        </option>
                                                    </c:forEach>
                                                </select>

                                                <button class="btn btn-sm btn-outline-info"
                                                        type="submit">
                                                    <i class="bi bi-link-45deg me-1"></i>
                                                    Assign
                                                </button>
                                            </form>
                                        </c:when>

                                        <c:otherwise>
                                            <button class="btn btn-sm btn-outline-warning release-ip-button"
                                                    type="button"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#releaseIpModal"
                                                    data-ip-id="${ip.ipId}"
                                                    data-ip-address="${fn:escapeXml(ip.ipAddress)}">
                                                <i class="bi bi-unlink me-1"></i>
                                                Release
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>

                        </c:forEach>

                    </c:when>

                    <c:otherwise>

                        <tr>
                            <td colspan="5"
                                class="text-center
                                       text-secondary py-5">

                                <i class="bi bi-globe2"
                                   style="font-size:40px;"></i>

                                <div class="mt-2">
                                    No IP addresses found.
                                </div>
                            </td>
                        </tr>

                    </c:otherwise>

                </c:choose>

                </tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 0}">

        <nav class="mt-4"
             aria-label="IP pagination">

            <ul class="pagination
                       justify-content-center">

                <li class="page-item
                           ${currentPage <= 1
                             ? 'disabled'
                             : ''}">

                    <c:url var="ipPrevUrl" value="MainController">
                        <c:param name="action" value="ipList" />
                        <c:param name="page" value="${currentPage - 1}" />
                        <c:if test="${not empty keyword}">
                            <c:param name="keyword" value="${keyword}" />
                        </c:if>
                    </c:url>
                    <a class="page-link"
                       href="${ipPrevUrl}">
                        Previous
                    </a>
                </li>

                <c:forEach var="pageNumber"
                           begin="1"
                           end="${totalPages}">

                    <li class="page-item
                               ${pageNumber eq currentPage
                                 ? 'active'
                                 : ''}">

                        <c:url var="ipPageUrl" value="MainController">
                            <c:param name="action" value="ipList" />
                            <c:param name="page" value="${pageNumber}" />
                            <c:if test="${not empty keyword}">
                                <c:param name="keyword" value="${keyword}" />
                            </c:if>
                        </c:url>
                        <a class="page-link"
                           href="${ipPageUrl}">

                            <c:out value="${pageNumber}"/>
                        </a>
                    </li>

                </c:forEach>

                <li class="page-item
                           ${currentPage >= totalPages
                             ? 'disabled'
                             : ''}">

                    <c:url var="ipNextUrl" value="MainController">
                        <c:param name="action" value="ipList" />
                        <c:param name="page" value="${currentPage + 1}" />
                        <c:if test="${not empty keyword}">
                            <c:param name="keyword" value="${keyword}" />
                        </c:if>
                    </c:url>
                    <a class="page-link"
                       href="${ipNextUrl}">
                        Next
                    </a>
                </li>

            </ul>
        </nav>

    </c:if>

</div>

<div class="modal fade"
     id="releaseIpModal"
     tabindex="-1"
     aria-labelledby="releaseIpModalLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="MainController"
                  method="post">
                <div class="modal-header">
                    <h5 class="modal-title"
                        id="releaseIpModalLabel">
                        Release IP address?
                    </h5>
                    <button type="button"
                            class="btn-close btn-close-white"
                            data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden"
                           name="action"
                           value="ipRelease">
                    <input type="hidden"
                           name="ipId"
                           id="releaseIpId">
                    <input type="hidden"
                           name="page"
                           value="${currentPage}">
                    <c:if test="${not empty keyword}">
                        <input type="hidden"
                               name="keyword"
                               value="${fn:escapeXml(keyword)}">
                    </c:if>

                    <p class="mb-2">
                        Are you sure you want to release
                        <span class="ip-address"
                              id="releaseIpAddress"></span>?
                    </p>
                    <p class="text-secondary mb-0">
                        The device will no longer keep this assigned IP.
                    </p>
                </div>

                <div class="modal-footer">
                    <button type="button"
                            class="btn btn-outline-light"
                            data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="submit"
                            class="btn btn-warning">
                        <i class="bi bi-unlink me-1"></i>
                        Release
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.release-ip-button').forEach(function (button) {
        button.addEventListener('click', function () {
            document.getElementById('releaseIpId').value =
                    button.getAttribute('data-ip-id');
            document.getElementById('releaseIpAddress').textContent =
                    button.getAttribute('data-ip-address');
        });
    });
</script>

</body>
</html>
