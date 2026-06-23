<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="Models.SwitchDTO"%>
<%
    SwitchDTO sw = (SwitchDTO) request.getAttribute("switchItem");
    boolean editMode = sw != null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editMode ? "Edit Switch" : "Add Switch" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container py-4">
        <h1 class="h3 mb-3"><%= editMode ? "Edit Switch" : "Add Switch" %></h1>

        <form class="card p-4" action="MainController" method="post">
            <input type="hidden" name="action" value="<%= editMode ? "switchUpdate" : "switchInsert" %>">
            <% if (editMode) { %>
            <input type="hidden" name="switchId" value="<%= sw.getSwitchId() %>">
            <% } %>

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Switch Name</label>
                    <input class="form-control" type="text" name="switchName" value="<%= editMode ? sw.getSwitchName() : "" %>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">IP Address</label>
                    <input class="form-control" type="text" name="ipAddress" value="<%= editMode ? sw.getIpAddress() : "" %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Total Ports</label>
                    <input class="form-control" type="number" name="totalPorts" value="<%= editMode ? sw.getTotalPorts() : 0 %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Used Ports</label>
                    <input class="form-control" type="number" name="usedPorts" value="<%= editMode ? sw.getUsedPorts() : 0 %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Room ID</label>
                    <input class="form-control" type="number" name="roomId" value="<%= editMode ? sw.getRoomId() : 0 %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Status</label>
                    <input class="form-control" type="text" name="status" value="<%= editMode ? sw.getStatus() : "ONLINE" %>">
                </div>
            </div>

            <div class="mt-4">
                <button class="btn btn-primary" type="submit">Save</button>
                <a class="btn btn-secondary" href="MainController?action=switchList">Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>
