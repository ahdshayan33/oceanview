<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="oceanview.model.Room" %>

<%
    // Session check
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    
    // Determine mode
    Boolean editModeObj = (Boolean) request.getAttribute("editMode");
    boolean editMode = editModeObj != null && editModeObj.booleanValue();
    
    Room room = (Room) request.getAttribute("room");
    
    // Default values for add mode
    String roomNumber = "";
    int floorNumber = 1;
    String roomType = "Standard";
    double basePrice = 100.0;
    String status = "VACANT";
    int roomId = 0;
    
    // If edit mode and room exists, use room data
    if (editMode && room != null) {
        roomNumber = room.getRoomNumber();
        floorNumber = room.getFloorNumber();
        roomType = room.getRoomType();
        basePrice = room.getBasePrice();
        status = room.getStatus();
        roomId = room.getRoomId();
    }
    
    String title = editMode ? "Edit Room" : "Add New Room";
    String formAction = editMode ? "update" : "add";
    String submitButton = editMode ? "💾 Save Changes" : "➕ Add Room";
    
    // Check for error message to preserve form data
    String errorMessage = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    
    // If there was an error and we have form data in request, use it
    String reqRoomNumber = request.getParameter("roomNumber");
    if (reqRoomNumber != null) roomNumber = reqRoomNumber;
    
    String reqFloor = request.getParameter("floorNumber");
    if (reqFloor != null) try { floorNumber = Integer.parseInt(reqFloor); } catch (Exception e) {}
    
    String reqType = request.getParameter("roomType");
    if (reqType != null) roomType = reqType;
    
    String reqPrice = request.getParameter("basePrice");
    if (reqPrice != null) try { basePrice = Double.parseDouble(reqPrice); } catch (Exception e) {}
    
    String reqStatus = request.getParameter("status");
    if (reqStatus != null) status = reqStatus;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= title %> - OceanView Hotel</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --primary-light: #818cf8;
            --secondary: #0ea5e9;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --dark: #1e293b;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-400: #94a3b8;
            --gray-500: #64748b;
            --gray-600: #475569;
            --gray-700: #334155;
            --gray-800: #1e293b;
            --gray-900: #0f172a;
            --white: #ffffff;
            --shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
            --radius: 12px;
            --radius-sm: 8px;
            --transition: all 0.3s ease;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--gray-100);
            color: var(--gray-800);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
        }

        /* Sidebar */
        .sidebar {
            width: 280px;
            background: var(--white);
            border-right: 1px solid var(--gray-200);
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            z-index: 50;
            box-shadow: var(--shadow-lg);
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
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }

        .logo-text {
            font-size: 20px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .logo-text span { color: var(--primary); }

        .sidebar-nav {
            flex: 1;
            padding: 20px 16px;
        }

        .nav-section { margin-bottom: 24px; }

        .nav-section-title {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--gray-400);
            padding: 0 12px;
            margin-bottom: 8px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            border-radius: var(--radius-sm);
            color: var(--gray-600);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: var(--transition);
            margin-bottom: 4px;
        }

        .nav-item:hover {
            background: var(--gray-50);
            color: var(--gray-800);
        }

        .nav-item.active {
            background: linear-gradient(135deg, rgba(79, 70, 229, 0.1) 0%, rgba(14, 165, 233, 0.1) 100%);
            color: var(--primary);
            font-weight: 600;
        }

        .sidebar-footer {
            padding: 20px;
            border-top: 1px solid var(--gray-200);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-radius: var(--radius);
            background: var(--gray-50);
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
        }

        .user-name {
            font-size: 14px;
            font-weight: 600;
            color: var(--gray-800);
        }

        .user-role { font-size: 12px; color: var(--gray-500); }

        .logout-btn {
            width: 36px;
            height: 36px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-400);
            text-decoration: none;
            border: 1px solid var(--gray-200);
        }

        .logout-btn:hover {
            background: var(--danger);
            color: white;
            border-color: var(--danger);
        }

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 280px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .top-header {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            padding: 16px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .dashboard-content {
            flex: 1;
            padding: 32px;
            max-width: 600px;
            margin: 0 auto;
            width: 100%;
        }

        /* Alert */
        .alert {
            padding: 16px;
            border-radius: var(--radius-sm);
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid var(--danger);
            color: var(--danger);
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid var(--success);
            color: var(--success);
        }

        /* Form */
        .form-container {
            background: var(--white);
            border-radius: var(--radius);
            padding: 32px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
        }

        .form-header {
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 2px solid var(--gray-100);
        }

        .form-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--gray-700);
            margin-bottom: 8px;
        }

        .form-input, .form-select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-family: inherit;
            transition: var(--transition);
        }

        .form-input:focus, .form-select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 32px;
            padding-top: 24px;
            border-top: 2px solid var(--gray-100);
        }

        .btn {
            padding: 12px 24px;
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            border: none;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .btn-secondary {
            background: var(--gray-100);
            color: var(--gray-700);
            border: 1px solid var(--gray-200);
        }

        .btn-secondary:hover {
            background: var(--gray-200);
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
            .form-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon">🏨</div>
            <div class="logo-text">Ocean<span>View</span></div>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Management</div>
                <a href="room-management" class="nav-item active">
                    <span style="width: 20px;">🚪</span>
                    Room Management
                </a>
                <a href="dashboard.jsp" class="nav-item">
                    <span style="width: 20px;">📊</span>
                    Dashboard
                </a>
            </div>
        </nav>
        
        <div class="sidebar-footer">
            <div class="user-profile">
                <div class="user-avatar"><%= fullName.charAt(0) %></div>
                <div>
                    <div class="user-name"><%= fullName %></div>
                    <div style="font-size: 12px; color: var(--gray-500);">Administrator</div>
                </div>
                <a href="index.jsp" class="logout-btn">🚪</a>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <header class="top-header">
            <h1 class="page-title"><%= title %></h1>
        </header>

        <div class="dashboard-content">
            
            <% if (errorMessage != null) { %>
            <div class="alert alert-<%= messageType %>">
                <%= errorMessage %>
            </div>
            <% } %>

            <div class="form-container">
                <div class="form-header">
                    <div class="form-title">
                        <%= editMode ? "✏️" : "➕" %>
                        <%= title %>
                    </div>
                </div>

                <form action="room-management" method="post">
                    <input type="hidden" name="action" value="<%= formAction %>">
                    <% if (editMode) { %>
                    <input type="hidden" name="roomId" value="<%= roomId %>">
                    <% } %>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Room Number *</label>
                            <input type="text" name="roomNumber" class="form-input" 
                                   value="<%= roomNumber %>" 
                                   placeholder="e.g., 101" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Floor Number *</label>
                            <input type="number" name="floorNumber" class="form-input" 
                                   value="<%= floorNumber %>" 
                                   min="1" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Room Type *</label>
                            <select name="roomType" class="form-select" required>
                                <option value="Standard" <%= "Standard".equals(roomType) ? "selected" : "" %>>Standard</option>
                                <option value="Deluxe" <%= "Deluxe".equals(roomType) ? "selected" : "" %>>Deluxe</option>
                                <option value="Suite" <%= "Suite".equals(roomType) ? "selected" : "" %>>Suite</option>
                                <option value="Presidential" <%= "Presidential".equals(roomType) ? "selected" : "" %>>Presidential</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Base Price/Night ($) *</label>
                            <input type="number" name="basePrice" class="form-input" 
                                   value="<%= basePrice %>" 
                                   min="0" step="0.01" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Status *</label>
                        <select name="status" class="form-select" required>
                            <option value="VACANT" <%= "VACANT".equals(status) ? "selected" : "" %>>Vacant</option>
                            <option value="OCCUPIED" <%= "OCCUPIED".equals(status) ? "selected" : "" %>>Occupied</option>
                            <option value="MAINTENANCE" <%= "MAINTENANCE".equals(status) ? "selected" : "" %>>Maintenance</option>
                            <option value="CLEANING" <%= "CLEANING".equals(status) ? "selected" : "" %>>Cleaning</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <a href="room-management" class="btn btn-secondary">← Cancel</a>
                        <button type="submit" class="btn btn-primary">
                            <%= submitButton %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

</body>
</html>