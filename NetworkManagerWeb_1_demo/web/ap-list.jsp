<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="Models.AccessPointDTO"%>
<%
    ArrayList<AccessPointDTO> accessPoints = (ArrayList<AccessPointDTO>) request.getAttribute("accessPoints");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Points</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1 class="h3 mb-0">Access Points</h1>
            <a class="btn btn-primary" href="MainController?action=apAdd">Add Access Point</a>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>SSID</th>
                            <th>IP</th>
                            <th>Users</th>
                            <th>Status</th>
                            <th>Location</th>
                            <th>Room</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (accessPoints != null && !accessPoints.isEmpty()) {
                                for (AccessPointDTO ap : accessPoints) {
                        %>
                        <tr>
                            <td><%= ap.getApId() %></td>
                            <td><%= ap.getApName() %></td>
                            <td><%= ap.getSsid() %></td>
                            <td><%= ap.getIpAddress() %></td>
                            <td><%= ap.getConnectedUsers() %></td>
                            <td><span class="badge text-bg-secondary"><%= ap.getStatus() %></span></td>
                            <td><%= ap.getLocation() %></td>
                            <td><%= ap.getRoomId() %></td>
                            <td>
                                <a class="btn btn-sm btn-outline-primary" href="MainController?action=apEdit&id=<%= ap.getApId() %>">Edit</a>
                                <a class="btn btn-sm btn-outline-danger" href="MainController?action=apDelete&id=<%= ap.getApId() %>">Delete</a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">No access points found.</td>
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
