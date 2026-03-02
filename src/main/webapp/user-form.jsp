<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="oceanview.model.User" %>
<%
    // Check admin access
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("access-denied.jsp");
        return;
    }
    
    String fullName = currentUser.getFullName();
    Boolean editMode = (Boolean) request.getAttribute("editMode");
    User editUser = (User) request.getAttribute("editUser");
    String error = (String) request.getAttribute("error");
    
    if (editMode == null) editMode = false;
    
    String formAction = editMode ? "update" : "add";
    String username = editMode && editUser != null ? editUser.getUsername() : "";
    String userFullName = editMode && editUser != null ? editUser.getFullName() : "";
    String email = editMode && editUser != null ? editUser.getEmail() : "";
    String role = editMode && editUser != null ? editUser.getRole() : "RECEPTIONIST";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editMode ? "Edit" : "Add" %> User - OceanView Hotel</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --success: #10b981;
            --danger: #ef4444;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-800: #1e293b;
            --white: #ffffff;
            --shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
            --radius: 12px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--gray-100);
            min-height: 100vh;
            display: flex;
        }

        .sidebar {
            width: 280px;
            background: var(--white);
            border-right: 1px solid var(--gray-200);
            position: fixed;
            height: 100vh;
            z-index: 50;
        }

        .sidebar-header {
            padding: 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary) 0%, #0ea5e9 100%);
            border-radius: var(--radius);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }

        .logo-text {
            font-size: 20px;
            font-weight: 700;
        }

        .logo-text span { color: var(--primary); }

        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 32px;
        }

        .form-container {
            max-width: 500px;
            margin: 0 auto;
            background: var(--white);
            padding: 32px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }

        .form-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 24px;
            text-align: center;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 6px;
            color: var(--gray-800);
        }

        .form-input, .form-select {
            width: 100%;
            padding: 12px;
            border: 2px solid var(--gray-200);
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
        }

        .form-input:focus, .form-select:focus {
            outline: none;
            border-color: var(--primary);
        }

        .btn {
            width: 100%;
            padding: 12px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            color: white;
            background: var(--primary);
        }

        .btn:hover {
            background: var(--primary-dark);
        }

        .btn-secondary {
            background: var(--gray-200);
            color: var(--gray-800);
            margin-top: 12px;
        }

        .btn-secondary:hover {
            background: var(--gray-300);
        }

        .error {
            background: rgba(239, 68, 68, 0.1);
            color: var(--danger);
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .hint {
            font-size: 12px;
            color: #64748b;
            margin-top: 4px;
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
        }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon">🏨</div>
            <div class="logo-text">Ocean<span>View</span></div>
        </div>
    </aside>

    <main class="main-content">
        <div class="form-container">
            <h2 class="form-title"><%= editMode ? "✏️ Edit User" : "➕ Add New User" %></h2>
            
            <% if (error != null) { %>
            <div class="error"><%= error %></div>
            <% } %>

            <form action="user-management" method="POST">
                <input type="hidden" name="action" value="<%= formAction %>">
                
                <div class="form-group">
                    <label class="form-label">Username *</label>
                    <input type="text" name="username" class="form-input" 
                           value="<%= username %>" 
                           <%= editMode ? "readonly" : "" %> required>
                    <% if (editMode) { %>
                    <p class="hint">Username cannot be changed</p>
                    <% } %>
                </div>

                <div class="form-group">
                    <label class="form-label">Password <%= editMode ? "(leave blank to keep current)" : "*" %></label>
                    <input type="password" name="password" class="form-input" 
                           <%= editMode ? "" : "required" %>>
                    <% if (!editMode) { %>
                    <p class="hint">Minimum 6 characters recommended</p>
                    <% } %>
                </div>

                <div class="form-group">
                    <label class="form-label">Full Name *</label>
                    <input type="text" name="fullName" class="form-input" 
                           value="<%= userFullName %>" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-input" 
                           value="<%= email != null ? email : "" %>">
                </div>

                <div class="form-group">
                    <label class="form-label">Role *</label>
                    <select name="role" class="form-select" required>
                        <option value="RECEPTIONIST" <%= "RECEPTIONIST".equals(role) ? "selected" : "" %>>
                            Receptionist (Limited Access)
                        </option>
                        <option value="ADMIN" <%= "ADMIN".equals(role) ? "selected" : "" %>>
                            Administrator (Full Access)
                        </option>
                    </select>
                    <p class="hint">Admins can manage users and access all features</p>
                </div>

                <button type="submit" class="btn">
                    <%= editMode ? "💾 Update User" : "➕ Create User" %>
                </button>
                
                <a href="user-management" class="btn btn-secondary" style="display: block; text-align: center; text-decoration: none;">
                    ← Cancel
                </a>
            </form>
        </div>
    </main>

</body>
</html>