<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

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
            <h1 class="h3 mb-0">Room Management</h1>

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

    </div>

</body>
</html>
