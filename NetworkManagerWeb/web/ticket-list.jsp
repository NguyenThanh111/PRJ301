<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>Support Ticket Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
</head>

<body class="bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h1 class="h3 mb-1">Support Ticket Management</h1>
                <div class="text-muted">
                    Total tickets:
                    <c:out value="${totalRecords}" />
                </div>
            </div>
            <div class="d-flex gap-2">
                <a class="btn btn-secondary"
                   href="staffDashboard.jsp?page=tickets">
                    Back to Dashboard
                </a>
                <a class="btn btn-primary"
                   href="MainController?action=ticketAdd">
                    Add Ticket
                </a>
            </div>
        </div>

        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger">
                <c:out value="${requestScope.error}" />
            </div>
        </c:if>

        <div class="card shadow-sm">
            <div class="card-body border-bottom">
                <form action="MainController"
                      method="get"
                      class="row g-2 align-items-center">
                    <input type="hidden"
                           name="action"
                           value="ticketList">

                    <div class="col-md-9">
                        <input class="form-control"
                               type="search"
                               name="keyword"
                               value="${fn:escapeXml(keyword)}"
                               placeholder="Search by ticket title, status, user id, or device id">
                    </div>

                    <div class="col-md-3 d-flex gap-2">
                        <button class="btn btn-primary flex-fill"
                                type="submit">
                            Search
                        </button>

                        <a class="btn btn-outline-secondary"
                           href="MainController?action=ticketList">
                            Clear
                        </a>
                    </div>
                </form>
            </div>

            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Title</th>
                            <th>Status</th>
                            <th>Created Date</th>
                            <th>Created By</th>
                            <th>Device</th>
                            <th style="width: 260px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty tickets}">
                                <c:forEach var="ticket" items="${tickets}">
                                    <tr>
                                        <td><c:out value="${ticket.ticketId}" /></td>
                                        <td>
                                            <div class="fw-semibold">
                                                <c:out value="${ticket.title}" />
                                            </div>
                                            <c:if test="${not empty ticket.description}">
                                                <div class="small text-muted">
                                                    <c:out value="${ticket.description}" />
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <span class="badge text-bg-secondary">
                                                <c:out value="${ticket.status}" />
                                            </span>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${ticket.createdDate}"
                                                            pattern="yyyy-MM-dd HH:mm" />
                                        </td>
                                        <td>User #<c:out value="${ticket.createdBy}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty ticket.deviceId}">
                                                    Device #<c:out value="${ticket.deviceId}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">Not assigned</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex flex-wrap gap-2">
                                                <a class="btn btn-sm btn-outline-primary"
                                                   href="MainController?action=ticketEdit&id=${ticket.ticketId}">
                                                    Edit
                                                </a>
                                                <form action="MainController"
                                                      method="post"
                                                      class="d-inline">
                                                    <input type="hidden"
                                                           name="action"
                                                           value="ticketUpdateStatus">
                                                    <input type="hidden"
                                                           name="ticketId"
                                                           value="${ticket.ticketId}">
                                                    <select class="form-select form-select-sm"
                                                            name="status"
                                                            onchange="this.form.submit()">
                                                        <option value="OPEN"
                                                                ${ticket.status eq 'OPEN' ? 'selected' : ''}>
                                                            OPEN
                                                        </option>
                                                        <option value="IN_PROGRESS"
                                                                ${ticket.status eq 'IN_PROGRESS' ? 'selected' : ''}>
                                                            IN_PROGRESS
                                                        </option>
                                                        <option value="RESOLVED"
                                                                ${ticket.status eq 'RESOLVED' ? 'selected' : ''}>
                                                            RESOLVED
                                                        </option>
                                                        <option value="CLOSED"
                                                                ${ticket.status eq 'CLOSED' ? 'selected' : ''}>
                                                            CLOSED
                                                        </option>
                                                    </select>
                                                </form>
                                                <form action="MainController"
                                                      method="post"
                                                      class="d-inline"
                                                      onsubmit="return confirm('Are you sure you want to delete this ticket?');">
                                                    <input type="hidden"
                                                           name="action"
                                                           value="ticketDelete">
                                                    <input type="hidden"
                                                           name="ticketId"
                                                           value="${ticket.ticketId}">
                                                    <button class="btn btn-sm btn-outline-danger"
                                                            type="submit">
                                                        Delete
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7"
                                        class="text-center text-muted py-4">
                                        <div class="mb-2">No support tickets found.</div>
                                        <a class="btn btn-sm btn-primary"
                                           href="MainController?action=ticketAdd">
                                            Create the first ticket
                                        </a>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <c:if test="${totalPages > 0}">
            <nav class="mt-4"
                 aria-label="Ticket pagination">
                <ul class="pagination justify-content-center">
                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                        <c:url var="ticketPrevUrl" value="MainController">
                            <c:param name="action" value="ticketList" />
                            <c:param name="page" value="${currentPage - 1}" />
                            <c:if test="${not empty keyword}">
                                <c:param name="keyword" value="${keyword}" />
                            </c:if>
                        </c:url>
                        <a class="page-link"
                           href="${ticketPrevUrl}">
                            Previous
                        </a>
                    </li>

                    <c:forEach var="pageNumber"
                               begin="1"
                               end="${totalPages}">
                        <li class="page-item ${pageNumber eq currentPage ? 'active' : ''}">
                            <c:url var="ticketPageUrl" value="MainController">
                                <c:param name="action" value="ticketList" />
                                <c:param name="page" value="${pageNumber}" />
                                <c:if test="${not empty keyword}">
                                    <c:param name="keyword" value="${keyword}" />
                                </c:if>
                            </c:url>
                            <a class="page-link"
                               href="${ticketPageUrl}">
                                <c:out value="${pageNumber}" />
                            </a>
                        </li>
                    </c:forEach>

                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                        <c:url var="ticketNextUrl" value="MainController">
                            <c:param name="action" value="ticketList" />
                            <c:param name="page" value="${currentPage + 1}" />
                            <c:if test="${not empty keyword}">
                                <c:param name="keyword" value="${keyword}" />
                            </c:if>
                        </c:url>
                        <a class="page-link"
                           href="${ticketNextUrl}">
                            Next
                        </a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>
</body>
</html>
