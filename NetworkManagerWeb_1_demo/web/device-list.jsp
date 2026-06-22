<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="Models.NetworkDeviceDTO"%>
<%
    ArrayList<NetworkDeviceDTO> devices = (ArrayList<NetworkDeviceDTO>) request.getAttribute("devices");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Network Devices</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1 class="h3 mb-0">Network Devices</h1>
            <a class="btn btn-primary" href="MainController?action=deviceAdd">Add Device</a>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>MAC</th>
                            <th>IP</th>
                            <th>Owner</th>
                            <th>Type</th>
                            <th>Status</th>
                            <th>Room</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (devices != null && !devices.isEmpty()) {
                                for (NetworkDeviceDTO device : devices) {
                        %>
                        <tr>
                            <td><%= device.getDeviceId() %></td>
                            <td><%= device.getDeviceName() %></td>
                            <td><%= device.getMacAddress() %></td>
                            <td><%= device.getIpAddress() %></td>
                            <td><%= device.getOwner() %></td>
                            <td><%= device.getDeviceType() %></td>
                            <td><span class="badge text-bg-secondary"><%= device.getStatus() %></span></td>
                            <td><%= device.getRoomId() %></td>
                            <td>
                                <a class="btn btn-sm btn-outline-primary" href="MainController?action=deviceEdit&id=<%= device.getDeviceId() %>">Edit</a>
                                <a class="btn btn-sm btn-outline-warning" href="MainController?action=deviceBlock&id=<%= device.getDeviceId() %>">Block</a>
                                <a class="btn btn-sm btn-outline-success" href="MainController?action=deviceUnblock&id=<%= device.getDeviceId() %>">Unblock</a>
                                <a class="btn btn-sm btn-outline-danger" href="MainController?action=deviceDelete&id=<%= device.getDeviceId() %>">Delete</a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">No devices found.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
