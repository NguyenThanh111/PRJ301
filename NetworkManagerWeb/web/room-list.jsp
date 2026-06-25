<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Room Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
</head>

<body class="bg-light">

    <div class="container py-4">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h1 class="h3 mb-1">Room Management</h1>
                <div class="text-muted">
                    Total rooms:
                    <c:out value="${totalRecords}" />
                </div>
            </div>

            <div class="d-flex gap-2">
                <a class="btn btn-secondary"
                   href="staffDashboard.jsp?page=rooms">
                    Back to Dashboard
                </a>

                <a class="btn btn-primary"
                   href="MainController?action=roomAdd">
                    Add Room
                </a>
            </div>
        </div>

        <!-- Hiển thị lỗi được gửi từ RoomServlet -->
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
                           value="roomList">

                    <div class="col-md-9">
                        <input class="form-control"
                               type="search"
                               name="keyword"
                               value="${fn:escapeXml(keyword)}"
                               placeholder="Search by room name or building">
                    </div>

                    <div class="col-md-3 d-flex gap-2">
                        <button class="btn btn-primary flex-fill"
                                type="submit">
                            Search
                        </button>

                        <a class="btn btn-outline-secondary"
                           href="MainController?action=roomList">
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
                            <th>Room Name</th>
                            <th>Building</th>
                            <th>Floor</th>
                            <th>Capacity</th>
                            <th style="width: 180px;">Actions</th>
                        </tr>
                    </thead>

                    <tbody>

                        <c:choose>

                            <c:when test="${not empty rooms}">

                                <c:forEach var="room" items="${rooms}">

                                    <tr>
                                        <td>
                                            <c:out value="${room.roomId}" />
                                        </td>

                                        <td>
                                            <c:out value="${room.roomName}" />
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty room.building}">
                                                    <c:out value="${room.building}" />
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="text-muted">
                                                        Not specified
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:out value="${room.floor}" />
                                        </td>

                                        <td>
                                            <c:out value="${room.capacity}" />
                                        </td>

                                        <td>
                                            <div class="d-flex gap-2">

                                                <a class="btn btn-sm btn-outline-primary"
                                                   href="MainController?action=roomEdit&id=${room.roomId}">
                                                    Edit
                                                </a>

                                                <form action="MainController"
                                                      method="post"
                                                      class="d-inline"
                                                      onsubmit="return confirm('Are you sure you want to delete this room?');">

                                                    <input type="hidden"
                                                           name="action"
                                                           value="roomDelete">

                                                    <input type="hidden"
                                                           name="roomId"
                                                           value="${room.roomId}">

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
                                        class="text-center text-muted py-4">

                                        <div class="mb-2">
                                            No rooms found.
                                        </div>

                                        <a class="btn btn-sm btn-primary"
                                           href="MainController?action=roomAdd">
                                            Create the first room
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
                 aria-label="Room pagination">
                <ul class="pagination justify-content-center">
                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                        <c:url var="roomPrevUrl" value="MainController">
                            <c:param name="action" value="roomList" />
                            <c:param name="page" value="${currentPage - 1}" />
                            <c:if test="${not empty keyword}">
                                <c:param name="keyword" value="${keyword}" />
                            </c:if>
                        </c:url>
                        <a class="page-link"
                           href="${roomPrevUrl}">
                            Previous
                        </a>
                    </li>

                    <c:forEach var="pageNumber"
                               begin="1"
                               end="${totalPages}">
                        <li class="page-item ${pageNumber eq currentPage ? 'active' : ''}">
                            <c:url var="roomPageUrl" value="MainController">
                                <c:param name="action" value="roomList" />
                                <c:param name="page" value="${pageNumber}" />
                                <c:if test="${not empty keyword}">
                                    <c:param name="keyword" value="${keyword}" />
                                </c:if>
                            </c:url>
                            <a class="page-link"
                               href="${roomPageUrl}">
                                <c:out value="${pageNumber}" />
                            </a>
                        </li>
                    </c:forEach>

                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                        <c:url var="roomNextUrl" value="MainController">
                            <c:param name="action" value="roomList" />
                            <c:param name="page" value="${currentPage + 1}" />
                            <c:if test="${not empty keyword}">
                                <c:param name="keyword" value="${keyword}" />
                            </c:if>
                        </c:url>
                        <a class="page-link"
                           href="${roomNextUrl}">
                            Next
                        </a>
                    </li>
                </ul>
            </nav>
        </c:if>

    </div>

</body>
</html>
