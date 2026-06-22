<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="Models.NetworkDeviceDTO"%>
<%
    NetworkDeviceDTO device = (NetworkDeviceDTO) request.getAttribute("device");
    boolean editMode = device != null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editMode ? "Edit Device" : "Add Device" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container py-4">
        <h1 class="h3 mb-3"><%= editMode ? "Edit Device" : "Add Device" %></h1>

        <form class="card p-4" action="MainController" method="post">
            <input type="hidden" name="action" value="<%= editMode ? "deviceUpdate" : "deviceInsert" %>">
            <% if (editMode) { %>
            <input type="hidden" name="deviceId" value="<%= device.getDeviceId() %>">
            <% } %>

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Device Name</label>
                    <input class="form-control" type="text" name="deviceName" value="<%= editMode ? device.getDeviceName() : "" %>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">MAC Address</label>
                    <input class="form-control" type="text" name="macAddress" value="<%= editMode ? device.getMacAddress() : "" %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">IP Address</label>
                    <input class="form-control" type="text" name="ipAddress" value="<%= editMode ? device.getIpAddress() : "" %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Owner</label>
                    <input class="form-control" type="text" name="owner" value="<%= editMode ? device.getOwner() : "" %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Device Type</label>
                    <input class="form-control" type="text" name="deviceType" value="<%= editMode ? device.getDeviceType() : "" %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Status</label>
                    <input class="form-control" type="text" name="status" value="<%= editMode ? device.getStatus() : "ALLOWED" %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Room ID</label>
                    <input class="form-control" type="number" name="roomId" value="<%= editMode ? device.getRoomId() : 0 %>">
                </div>
            </div>

            <div class="mt-4">
                <button class="btn btn-primary" type="submit">Save</button>
                <a class="btn btn-secondary" href="MainController?action=deviceList">Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>
