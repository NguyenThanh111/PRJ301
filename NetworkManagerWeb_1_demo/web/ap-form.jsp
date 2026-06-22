<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="Models.AccessPointDTO"%>
<%
    AccessPointDTO ap = (AccessPointDTO) request.getAttribute("accessPoint");
    boolean editMode = ap != null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editMode ? "Edit Access Point" : "Add Access Point" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container py-4">
        <h1 class="h3 mb-3"><%= editMode ? "Edit Access Point" : "Add Access Point" %></h1>

        <form class="card p-4" action="MainController" method="post">
            <input type="hidden" name="action" value="<%= editMode ? "apUpdate" : "apInsert" %>">
            <% if (editMode) { %>
            <input type="hidden" name="apId" value="<%= ap.getApId() %>">
            <% } %>

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">AP Name</label>
                    <input class="form-control" type="text" name="apName" value="<%= editMode ? ap.getApName() : "" %>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">SSID</label>
                    <input class="form-control" type="text" name="ssid" value="<%= editMode ? ap.getSsid() : "" %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">IP Address</label>
                    <input class="form-control" type="text" name="ipAddress" value="<%= editMode ? ap.getIpAddress() : "" %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Connected Users</label>
                    <input class="form-control" type="number" name="connectedUsers" value="<%= editMode ? ap.getConnectedUsers() : 0 %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Status</label>
                    <input class="form-control" type="text" name="status" value="<%= editMode ? ap.getStatus() : "ONLINE" %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Room ID</label>
                    <input class="form-control" type="number" name="roomId" value="<%= editMode ? ap.getRoomId() : 0 %>">
                </div>
                <div class="col-12">
                    <label class="form-label">Location</label>
                    <input class="form-control" type="text" name="location" value="<%= editMode ? ap.getLocation() : "" %>">
                </div>
            </div>

            <div class="mt-4">
                <button class="btn btn-primary" type="submit">Save</button>
                <a class="btn btn-secondary" href="MainController?action=apList">Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>
