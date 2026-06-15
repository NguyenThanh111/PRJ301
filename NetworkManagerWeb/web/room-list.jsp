<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rooms</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">
    <div class="container py-4">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1 class="h3 mb-0">Rooms</h1>

            <div>
                <a class="btn btn-secondary" href="staffDashboard.jsp">Back Dashboard</a>
                <a class="btn btn-primary" href="MainController?action=roomAdd">Add Room</a>
            </div>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="table table-striped table-hover mb-0">

                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Room Name</th>
                            <th>Building</th>
                            <th>Floor</th>
                            <th>Capacity</th>
                            <th>Actions</th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:choose>
                            <c:when test="${not empty rooms}">
                                <c:forEach var="room" items="${rooms}">
                                    <tr>
                                        <td>${room.roomId}</td>
                                        <td><c:out value="${room.roomName}" /></td>
                                        <td><c:out value="${room.building}" /></td>
                                        <td>${room.floor}</td>
                                        <td>${room.capacity}</td>
                                        <td>
                                            <a class="btn btn-sm btn-outline-primary"
                                               href="MainController?action=roomEdit&id=${room.roomId}">
                                                Edit
                                            </a>

                                            <a class="btn btn-sm btn-outline-danger"
                                               href="MainController?action=roomDelete&roomId=${room.roomId}"
                                               onclick="return confirm('Are you sure you want to delete this room?');">
                                                Delete
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>

                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">
                                        No rooms found.
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