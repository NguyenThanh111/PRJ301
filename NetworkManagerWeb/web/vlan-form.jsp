<%-- 
    Document   : vlan-form
    Created on : Jun 20, 2026, 1:10:27 AM
    Author     : 84382
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="vlan"
       value="${requestScope.vlan}" />

<c:set var="formVLAN"
       value="${requestScope.formVLAN}" />

<c:set var="returnTo"
       value="${not empty requestScope.returnTo
                ? requestScope.returnTo
                : param.returnTo}" />

<!--
    Edit mode khi:
    - Servlet gửi vlan sang
    - Hoặc Update bị validation lỗi và formVLAN vẫn có vlanId
-->
<c:set var="editMode"
       value="${not empty vlan
                or (not empty formVLAN and formVLAN.vlanId > 0)}" />

<!-- Ưu tiên dữ liệu người dùng vừa nhập khi validation lỗi -->
<c:choose>
    <c:when test="${not empty formVLAN}">
        <c:set var="valueVLAN"
               value="${formVLAN}" />
    </c:when>

    <c:otherwise>
        <c:set var="valueVLAN"
               value="${vlan}" />
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
            <c:when test="${editMode}">
                Edit VLAN
            </c:when>

            <c:otherwise>
                Add VLAN
            </c:otherwise>
        </c:choose>
    </title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
</head>

<body class="bg-light">

    <div class="container py-4">

        <h1 class="h3 mb-3">

            <c:choose>
                <c:when test="${editMode}">
                    Edit VLAN
                </c:when>

                <c:otherwise>
                    Add VLAN
                </c:otherwise>
            </c:choose>

        </h1>

        <!-- Thông báo lỗi -->
        <c:if test="${not empty requestScope.error}">

            <div class="alert alert-danger">
                <c:out value="${requestScope.error}" />
            </div>

        </c:if>

        <form class="card p-4 shadow-sm"
              action="MainController"
              method="post">

            <!-- Chọn action Insert hoặc Update -->
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

            <!-- Giữ vị trí quay lại -->
            <c:if test="${not empty returnTo}">

                <input type="hidden"
                       name="returnTo"
                       value="${returnTo}">

            </c:if>

            <div class="row g-3">

                <!-- VLAN Name -->
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

                    <div class="form-text">
                        VLAN name must be unique.
                    </div>
                </div>

                <!-- Subnet -->
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

                    <div class="form-text">
                        Enter an IPv4 subnet in CIDR format.
                    </div>
                </div>

                <!-- Purpose -->
                <div class="col-md-8">

                    <label class="form-label"
                           for="purpose">
                        Purpose
                    </label>

                    <textarea class="form-control"
                              id="purpose"
                              name="purpose"
                              rows="3"
                              maxlength="255"
                              placeholder="Describe the purpose of this VLAN"><c:out value="${valueVLAN.purpose}" /></textarea>

                    <div class="form-text">
                        Maximum 255 characters.
                    </div>
                </div>

                <!-- Room -->
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

                                (Floor
                                <c:out value="${room.floor}" />)
                            </option>

                        </c:forEach>

                    </select>

                    <div class="form-text">
                        Room is optional, but the selected room must exist.
                    </div>
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
                           href="staffDashboard.jsp?page=vlan">
                            Cancel
                        </a>

                    </c:when>

                    <c:otherwise>

                        <a class="btn btn-secondary"
                           href="MainController?action=vlanList">
                            Cancel
                        </a>

                    </c:otherwise>

                </c:choose>

            </div>

        </form>

    </div>

</body>
</html>

