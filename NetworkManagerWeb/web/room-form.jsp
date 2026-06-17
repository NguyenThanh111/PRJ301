<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="room" value="${requestScope.room}" />
<c:set var="formRoom" value="${requestScope.formRoom}" />

<!-- Lấy returnTo từ Servlet hoặc trực tiếp từ URL/form -->
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
</head>

<body class="bg-light">

    <div class="container py-4">

        <h1 class="h3 mb-3">
            <c:choose>
                <c:when test="${editMode}">Edit Room</c:when>
                <c:otherwise>Add Room</c:otherwise>
            </c:choose>
        </h1>

        <!-- Hiển thị lỗi từ Servlet -->
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger">
                <c:out value="${requestScope.error}" />
            </div>
        </c:if>

        <form class="card p-4"
              action="MainController"
              method="post">

            <!-- Chọn action Insert hoặc Update -->
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

            <!-- Giữ thông tin trang cần quay lại -->
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
                           required>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Building</label>

                    <input class="form-control"
                           type="text"
                           name="building"
                           value="${fn:escapeXml(valueRoom.building)}"
                           maxlength="100">
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

            <div class="mt-4">
                <button class="btn btn-primary"
                        type="submit">
                    Save
                </button>

                <c:choose>
                    <c:when test="${returnTo eq 'dashboard'}">
                        <a class="btn btn-secondary"
                           href="staffDashboard.jsp?page=rooms">
                            Cancel
                        </a>
                    </c:when>

                    <c:otherwise>
                        <a class="btn btn-secondary"
                           href="MainController?action=roomList">
                            Cancel
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>

        </form>
    </div>

</body>
</html>

