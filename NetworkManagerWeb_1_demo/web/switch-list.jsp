<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="Models.SwitchDTO"%>
<%
    ArrayList<SwitchDTO> switches = (ArrayList<SwitchDTO>) request.getAttribute("switches");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Switches</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1 class="h3 mb-0">Switches</h1>
            <a class="btn btn-primary" href="MainController?action=switchAdd">Add Switch</a>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="table table-striped table-hover mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Total Ports</th>
                            <th>Used Ports</th>
                            <th>IP</th>
                            <th>Status</th>
                            <th>Room</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (switches != null && !switches.isEmpty()) {
                                for (SwitchDTO sw : switches) {
                        %>
                        <tr>
                            <td><%= sw.getSwitchId() %></td>
                            <td><%= sw.getSwitchName() %></td>
                            <td><%= sw.getTotalPorts() %></td>
                            <td><%= sw.getUsedPorts() %></td>
                            <td><%= sw.getIpAddress() %></td>
                            <td><span class="badge text-bg-secondary"><%= sw.getStatus() %></span></td>
                            <td><%= sw.getRoomId() %></td>
                            <td>
                                <a class="btn btn-sm btn-outline-primary" href="MainController?action=switchEdit&id=<%= sw.getSwitchId() %>">Edit</a>
                                <a class="btn btn-sm btn-outline-danger" href="MainController?action=switchDelete&id=<%= sw.getSwitchId() %>">Delete</a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center text-muted py-4">No switches found.</td>
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
