<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="oceanview.model.User" %>
<%
    // Check if already logged in
    User currentUser = (User) session.getAttribute("user");
    if (currentUser != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    // Get error from session and remove it immediately (so it shows only once)
    String error = (String) session.getAttribute("loginError");
    if (error != null) {
        session.removeAttribute("loginError");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Ocean View RMS</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .error-message {
            color: #ef4444;
            background: rgba(239, 68, 68, 0.1);
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 16px;
            font-size: 14px;
            border: 1px solid #ef4444;  /* Added border to make it visible */
            display: block;  /* Ensure it's displayed */
        }
    </style>
</head>
<body>

<!-- Hidden debug info - view page source to see -->
<!-- Error value: <%= error %> -->
<!-- Error is null: <%= (error == null) %> -->

<div class="login-container">
    <h2>Ocean View Resort Reservation System</h2>
    
    <% if (error != null) { %>
    <div class="error-message">
        <%= error %>
    </div>
    <% } %>
    
    <form action="login" method="post">
        <input type="text" name="username" placeholder="Username" required>
        <input type="password" name="password" placeholder="Password" required>
        <input type="submit" value="Login">
    </form>
    
    <a href="#">Forgot Password?</a>
</div>

</body>
</html>