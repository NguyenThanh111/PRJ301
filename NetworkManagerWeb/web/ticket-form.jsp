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
</head>

<body class="bg-light">
    <div class="container py-4">
        <h1 class="h3 mb-3">
            <c:choose>
                <c:when test="${editMode}">Edit Support Ticket</c:when>
                <c:otherwise>Add Support Ticket</c:otherwise>
            </c:choose>
        </h1>

        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger">
                <c:out value="${requestScope.error}" />
            </div>
        </c:if>

        <form class="card p-4"
              action="MainController"
              method="post">
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
                           required>
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
                              rows="5"><c:out value="${valueTicket.description}" /></textarea>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Created By User ID</label>
                    <input class="form-control"
                           type="number"
                           name="createdBy"
                           min="1"
                           value="${valueTicket.createdBy > 0
                                    ? valueTicket.createdBy
                                    : ''}"
                           required>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Device ID</label>
                    <input class="form-control"
                           type="number"
                           name="deviceId"
                           min="1"
                           value="${empty valueTicket.deviceId
                                    ? ''
                                    : valueTicket.deviceId}">
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
                           href="staffDashboard.jsp?page=tickets">
                            Cancel
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-secondary"
                           href="MainController?action=ticketList">
                            Cancel
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </form>
    </div>
</body>
</html>
