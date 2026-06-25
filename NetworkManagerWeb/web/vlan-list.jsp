
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>VLAN Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
</head>

<body class="bg-light">

    <div class="container py-4">

        <div class="d-flex justify-content-between align-items-center mb-3">

            <div>
                <h1 class="h3 mb-1">VLAN Management</h1>

                <c:if test="${not empty totalRecords}">
                    <div class="text-muted">
                        Total VLANs:
                        <c:out value="${totalRecords}" />
                    </div>
                </c:if>
            </div>

            <div class="d-flex gap-2">
                <a class="btn btn-secondary"
                   href="staffDashboard.jsp?page=vlan">
                    Back to Dashboard
                </a>

                <a class="btn btn-primary"
                   href="MainController?action=vlanAdd">
                    Add VLAN
                </a>
            </div>
        </div>

        <!-- Thông báo lỗi từ VLANServlet -->
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
                           value="vlanList">

                    <div class="col-md-9">
                        <input class="form-control"
                               type="search"
                               name="keyword"
                               value="${fn:escapeXml(keyword)}"
                               placeholder="Search by VLAN name, subnet, or purpose">
                    </div>

                    <div class="col-md-3 d-flex gap-2">
                        <button class="btn btn-primary flex-fill"
                                type="submit">
                            Search
                        </button>

                        <a class="btn btn-outline-secondary"
                           href="MainController?action=vlanList">
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
                            <th>VLAN Name</th>
                            <th>Subnet</th>
                            <th>Purpose</th>
                            <th>Room ID</th>
                            <th style="width: 180px;">Actions</th>
                        </tr>
                    </thead>

                    <tbody>

                        <c:choose>

                            <c:when test="${not empty vlans}">

                                <c:forEach var="vlan" items="${vlans}">

                                    <tr>
                                        <td>
                                            <c:out value="${vlan.vlanId}" />
                                        </td>

                                        <td>
                                            <c:out value="${vlan.vlanName}" />
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty vlan.subnet}">
                                                    <code>
                                                        <c:out value="${vlan.subnet}" />
                                                    </code>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="text-muted">
                                                        Not specified
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty vlan.purpose}">
                                                    <c:out value="${vlan.purpose}" />
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="text-muted">
                                                        Not specified
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty vlan.roomId}">
                                                    <c:out value="${vlan.roomId}" />
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="text-muted">
                                                        No room
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <div class="d-flex gap-2">

                                                <a class="btn btn-sm btn-outline-primary"
                                                   href="MainController?action=vlanEdit&id=${vlan.vlanId}">
                                                    Edit
                                                </a>

                                                <form action="MainController"
                                                      method="post"
                                                      class="d-inline"
                                                      onsubmit="return confirm('Are you sure you want to delete this VLAN?');">

                                                    <input type="hidden"
                                                           name="action"
                                                           value="vlanDelete">

                                                    <input type="hidden"
                                                           name="vlanId"
                                                           value="${vlan.vlanId}">

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
                                    <td colspan="6"
                                        class="text-center text-muted py-5">

                                        <div class="mb-3">
                                            No VLANs found.
                                        </div>

                                        <a class="btn btn-sm btn-primary"
                                           href="MainController?action=vlanAdd">
                                            Create the first VLAN
                                        </a>

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
                 aria-label="VLAN pagination">

                <ul class="pagination justify-content-center">

                    <!-- Previous -->
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <li class="page-item">
                                <c:url var="vlanPrevUrl" value="MainController">
                                    <c:param name="action" value="vlanList" />
                                    <c:param name="page" value="${currentPage - 1}" />
                                    <c:if test="${not empty keyword}">
                                        <c:param name="keyword" value="${keyword}" />
                                    </c:if>
                                </c:url>
                                <a class="page-link"
                                   href="${vlanPrevUrl}">
                                    Previous
                                </a>
                            </li>
                        </c:when>

                        <c:otherwise>
                            <li class="page-item disabled">
                                <span class="page-link">
                                    Previous
                                </span>
                            </li>
                        </c:otherwise>
                    </c:choose>

                    <!-- Page numbers -->
                    <c:forEach var="pageNumber"
                               begin="1"
                               end="${totalPages}">

                        <li class="page-item ${pageNumber eq currentPage ? 'active' : ''}">

                            <c:url var="vlanPageUrl" value="MainController">
                                <c:param name="action" value="vlanList" />
                                <c:param name="page" value="${pageNumber}" />
                                <c:if test="${not empty keyword}">
                                    <c:param name="keyword" value="${keyword}" />
                                </c:if>
                            </c:url>
                            <a class="page-link"
                               href="${vlanPageUrl}">

                                <c:out value="${pageNumber}" />
                            </a>
                        </li>

                    </c:forEach>

                    <!-- Next -->
                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <li class="page-item">
                                <c:url var="vlanNextUrl" value="MainController">
                                    <c:param name="action" value="vlanList" />
                                    <c:param name="page" value="${currentPage + 1}" />
                                    <c:if test="${not empty keyword}">
                                        <c:param name="keyword" value="${keyword}" />
                                    </c:if>
                                </c:url>
                                <a class="page-link"
                                   href="${vlanNextUrl}">
                                    Next
                                </a>
                            </li>
                        </c:when>

                        <c:otherwise>
                            <li class="page-item disabled">
                                <span class="page-link">
                                    Next
                                </span>
                            </li>
                        </c:otherwise>
                    </c:choose>

                </ul>
            </nav>

        </c:if>

    </div>

</body>
</html>
