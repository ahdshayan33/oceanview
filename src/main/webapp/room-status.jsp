<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="oceanview.model.Room" %>
<%@ page import="oceanview.dao.RoomDAO" %>

<%
    // Get data from Servlet
    Object attr = request.getAttribute("roomsByFloor");
    Map<Integer, List<Room>> roomsByFloor = null;
    
    if (attr instanceof Map) {
        roomsByFloor = (Map<Integer, List<Room>>) attr;
    } else {
        RoomDAO dao = new RoomDAO();
        roomsByFloor = dao.getRoomsGroupedByFloor();
    }
    
    // Session check
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    boolean managementMode = request.getAttribute("managementMode") != null;
    
    // Calculate stats
    int totalRooms = 0, occupiedRooms = 0, vacantRooms = 0, maintenanceRooms = 0;
    if (roomsByFloor != null) {
        for (List<Room> rooms : roomsByFloor.values()) {
            totalRooms += rooms.size();
            for (Room room : rooms) {
                switch(room.getStatus()) {
                    case "OCCUPIED": occupiedRooms++; break;
                    case "VACANT": vacantRooms++; break;
                    case "MAINTENANCE": maintenanceRooms++; break;
                }
            }
        }
    }
    double occupancyRate = totalRooms > 0 ? (occupiedRooms * 100.0 / totalRooms) : 0;
    
    // Check for messages
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Status - OceanView Hotel</title>
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
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
            --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1);
            --radius: 12px;
            --radius-sm: 8px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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
            overflow-y: auto;
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
            position: relative;
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

        .header-left { display: flex; align-items: center; gap: 16px; }

        .menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 24px;
            color: var(--gray-600);
            cursor: pointer;
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .header-right { display: flex; align-items: center; gap: 16px; }

        /* Action Buttons */
        .action-bar {
            display: flex;
            gap: 12px;
            margin-bottom: 24px;
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
            background: var(--white);
            color: var(--gray-700);
            border: 1px solid var(--gray-200);
        }

        .btn-secondary:hover {
            background: var(--gray-50);
            border-color: var(--primary);
            color: var(--primary);
        }

        .btn-danger {
            background: var(--danger);
            color: white;
        }

        .btn-danger:hover { background: #dc2626; }

        .btn-sm {
            padding: 8px 16px;
            font-size: 13px;
        }

        /* Alert Messages */
        .alert {
            padding: 16px;
            border-radius: var(--radius-sm);
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease;
        }

        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid var(--success);
            color: var(--success);
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid var(--danger);
            color: var(--danger);
        }

        /* Dashboard Content */
        .dashboard-content {
            flex: 1;
            padding: 32px;
            max-width: 1400px;
            margin: 0 auto;
            width: 100%;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: var(--white);
            border-radius: var(--radius);
            padding: 24px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            transform: scaleY(0);
            transition: var(--transition);
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-xl);
        }

        .stat-card:hover::before { transform: scaleY(1); }

        .stat-card.total::before { background: var(--primary); }
        .stat-card.occupied::before { background: var(--danger); }
        .stat-card.vacant::before { background: var(--success); }
        .stat-card.maintenance::before { background: var(--warning); }

        .stat-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        .stat-card.total .stat-icon { background: rgba(79, 70, 229, 0.1); color: var(--primary); }
        .stat-card.occupied .stat-icon { background: rgba(239, 68, 68, 0.1); color: var(--danger); }
        .stat-card.vacant .stat-icon { background: rgba(16, 185, 129, 0.1); color: var(--success); }
        .stat-card.maintenance .stat-icon { background: rgba(245, 158, 11, 0.1); color: var(--warning); }

        .stat-label {
            font-size: 14px;
            color: var(--gray-500);
            font-weight: 500;
            margin-bottom: 8px;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: var(--gray-800);
            line-height: 1;
        }

        .stat-change {
            font-size: 13px;
            font-weight: 600;
            margin-top: 8px;
        }

        .stat-card.occupied .stat-change { color: var(--danger); }
        .stat-card.vacant .stat-change { color: var(--success); }
        .stat-card.maintenance .stat-change { color: var(--warning); }
        .stat-card.total .stat-change { color: var(--primary); }

        /* Legend */
        .legend-section {
            background: var(--white);
            border-radius: var(--radius);
            padding: 20px 24px;
            margin-bottom: 32px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
        }

        .legend-header {
            font-size: 16px;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 16px;
        }

        .legend-items {
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
            color: var(--gray-600);
        }

        .legend-box {
            width: 24px;
            height: 24px;
            border-radius: 6px;
            border: 2px solid;
        }

        .legend-box.vacant { background: rgba(16, 185, 129, 0.2); border-color: var(--success); }
        .legend-box.occupied { background: rgba(239, 68, 68, 0.2); border-color: var(--danger); }
        .legend-box.maintenance { background: rgba(245, 158, 11, 0.2); border-color: var(--warning); }
        .legend-box.cleaning { background: rgba(14, 165, 233, 0.2); border-color: var(--secondary); }

        /* Floor Sections */
        .floor-section {
            background: var(--white);
            border-radius: var(--radius);
            margin-bottom: 24px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            overflow: hidden;
        }

        .floor-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 24px;
            background: linear-gradient(135deg, var(--gray-50) 0%, var(--white) 100%);
            border-bottom: 1px solid var(--gray-200);
        }

        .floor-title {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .floor-number {
            font-size: 20px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .floor-badge {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }

        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 20px;
            padding: 24px;
        }

        .room-box {
            position: relative;
            border-radius: var(--radius-sm);
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            box-shadow: var(--shadow-sm);
            border: 2px solid transparent;
            overflow: hidden;
            background: var(--white);
        }

        .room-box:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
            z-index: 10;
        }

        .room-box.vacant { border-color: var(--success); }
        .room-box.vacant .room-header { background: rgba(16, 185, 129, 0.1); color: var(--success); }
        
        .room-box.occupied { border-color: var(--danger); }
        .room-box.occupied .room-header { background: rgba(239, 68, 68, 0.1); color: var(--danger); }
        
        .room-box.maintenance { border-color: var(--warning); }
        .room-box.maintenance .room-header { background: rgba(245, 158, 11, 0.1); color: var(--warning); }
        
        .room-box.cleaning { border-color: var(--secondary); }
        .room-box.cleaning .room-header { background: rgba(14, 165, 233, 0.1); color: var(--secondary); }

        .room-header {
            padding: 16px;
            text-align: center;
            border-bottom: 1px solid var(--gray-100);
        }

        .room-number {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .room-type {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            opacity: 0.8;
        }

        .room-body {
            padding: 16px;
            flex: 1;
        }

        .room-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
            font-size: 13px;
            color: var(--gray-600);
        }

        .room-price {
            font-weight: 700;
            color: var(--gray-800);
        }

        .room-status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .room-box.vacant .room-status-badge { background: rgba(16, 185, 129, 0.1); color: var(--success); }
        .room-box.occupied .room-status-badge { background: rgba(239, 68, 68, 0.1); color: var(--danger); }
        .room-box.maintenance .room-status-badge { background: rgba(245, 158, 11, 0.1); color: var(--warning); }
        .room-box.cleaning .room-status-badge { background: rgba(14, 165, 233, 0.1); color: var(--secondary); }

        /* Management Actions */
        .room-actions {
            display: flex;
            gap: 8px;
            padding: 12px 16px;
            background: var(--gray-50);
            border-top: 1px solid var(--gray-100);
        }

        .action-btn {
            flex: 1;
            padding: 8px;
            border-radius: var(--radius-sm);
            border: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: var(--transition);
            text-align: center;
            text-decoration: none;
        }

        .action-btn.edit {
            background: var(--primary);
            color: white;
        }

        .action-btn.edit:hover { background: var(--primary-dark); }

        .action-btn.delete {
            background: var(--white);
            color: var(--danger);
            border: 1px solid var(--gray-200);
        }

        .action-btn.delete:hover {
            background: var(--danger);
            color: white;
            border-color: var(--danger);
        }

        .action-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* Tooltip */
        .tooltip {
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            background: var(--dark);
            color: white;
            padding: 16px;
            border-radius: var(--radius-sm);
            width: 220px;
            opacity: 0;
            visibility: hidden;
            transition: var(--transition);
            margin-bottom: 12px;
            box-shadow: var(--shadow-xl);
            z-index: 100;
            font-size: 13px;
        }

        .tooltip::after {
            content: '';
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            border: 8px solid transparent;
            border-top-color: var(--dark);
        }

        .room-box:hover .tooltip {
            opacity: 1;
            visibility: visible;
        }

        .tooltip-header {
            font-size: 14px;
            font-weight: 700;
            margin-bottom: 12px;
            color: var(--primary-light);
            border-bottom: 1px solid var(--gray-600);
            padding-bottom: 8px;
        }

        .tooltip-row {
            display: flex;
            justify-content: space-between;
            margin: 6px 0;
        }

        .tooltip-label { color: var(--gray-400); }
        .tooltip-value { font-weight: 600; color: var(--white); }

        /* No Data */
        .no-data {
            text-align: center;
            padding: 60px;
            color: var(--gray-500);
        }

        .no-data-icon {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.5;
        }

        /* Modal */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }

        .modal-overlay.active { display: flex; }

        .modal {
            background: var(--white);
            border-radius: var(--radius);
            padding: 32px;
            max-width: 400px;
            width: 90%;
            box-shadow: var(--shadow-xl);
        }

        .modal-title {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 16px;
            color: var(--gray-800);
        }

        .modal-text {
            color: var(--gray-600);
            margin-bottom: 24px;
        }

        .modal-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
        }

        @media (max-width: 1024px) {
            .sidebar { transform: translateX(-100%); }
            .sidebar.active { transform: translateX(0); }
            .main-content { margin-left: 0; }
            .menu-toggle { display: block; }
        }

        @media (max-width: 768px) {
            .dashboard-content { padding: 20px; }
            .rooms-grid { grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); }
            .action-bar { flex-direction: column; }
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon">🏨</div>
            <div class="logo-text">Ocean<span>View</span></div>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href="dashboard.jsp" class="nav-item">
                    <span style="width: 20px;">📊</span>
                    Dashboard
                </a>
                <a href="addReservation.jsp" class="nav-item">
                    <span style="width: 20px;">➕</span>
                    Add Reservation
                </a>
                <a href="viewReservation.jsp" class="nav-item">
                    <span style="width: 20px;">📋</span>
                    View Reservations
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Management</div>
                <a href="guest-management.jsp" class="nav-item">
                    <span style="width: 20px;">👥</span>
                    Guest Management
                </a>
                <a href="room-management" class="nav-item <%= managementMode ? "active" : "" %>">
                    <span style="width: 20px;">🚪</span>
                    Room Management
                </a>
                <a href="room-status" class="nav-item <%= !managementMode ? "active" : "" %>">
                    <span style="width: 20px;">👁</span>
                    View Room Status
                </a>
            </div>
        </nav>
        
        <div class="sidebar-footer">
            <div class="user-profile">
                <div class="user-avatar"><%= fullName.charAt(0) %></div>
                <div class="user-info">
                    <div class="user-name"><%= fullName %></div>
                    <div class="user-role">Administrator</div>
                </div>
                <a href="index.jsp" class="logout-btn" title="Logout">🚪</a>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <div class="header-left">
                <button class="menu-toggle" onclick="toggleSidebar()">☰</button>
                <h1 class="page-title">
                    <%= managementMode ? "Room Management" : "Room Status" %>
                </h1>
            </div>
            <div class="header-right">
                <a href="help.jsp" class="btn btn-secondary btn-sm">❓ Help</a>
            </div>
        </header>

        <!-- Dashboard Content -->
        <div class="dashboard-content">
            
            <% if (message != null) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
            <% } %>

            <!-- Action Bar -->
            <div class="action-bar">
                <a href="room-management?action=add" class="btn btn-primary">
                    ➕ Add New Room
                </a>
                <a href="room-status" class="btn btn-secondary <%= !managementMode ? "active" : "" %>">
                    👁 View Only Mode
                </a>
                <a href="room-management" class="btn btn-secondary <%= managementMode ? "active" : "" %>">
                    ⚙️ Management Mode
                </a>
            </div>

            <!-- Stats Overview -->
            <div class="stats-grid">
                <div class="stat-card total">
                    <div class="stat-header">
                        <div>
                            <div class="stat-label">Total Rooms</div>
                            <div class="stat-value"><%= totalRooms %></div>
                            <div class="stat-change">All Floors</div>
                        </div>
                        <div class="stat-icon">🏨</div>
                    </div>
                </div>
                <div class="stat-card occupied">
                    <div class="stat-header">
                        <div>
                            <div class="stat-label">Occupied</div>
                            <div class="stat-value"><%= occupiedRooms %></div>
                            <div class="stat-change"><%= String.format("%.0f", occupancyRate) %>% Rate</div>
                        </div>
                        <div class="stat-icon">🔴</div>
                    </div>
                </div>
                <div class="stat-card vacant">
                    <div class="stat-header">
                        <div>
                            <div class="stat-label">Vacant</div>
                            <div class="stat-value"><%= vacantRooms %></div>
                            <div class="stat-change">Available Now</div>
                        </div>
                        <div class="stat-icon">🟢</div>
                    </div>
                </div>
                <div class="stat-card maintenance">
                    <div class="stat-header">
                        <div>
                            <div class="stat-label">Maintenance</div>
                            <div class="stat-value"><%= maintenanceRooms %></div>
                            <div class="stat-change">Not Available</div>
                        </div>
                        <div class="stat-icon">🔧</div>
                    </div>
                </div>
            </div>

            <!-- Legend -->
            <div class="legend-section">
                <div class="legend-header">📋 Room Status Legend</div>
                <div class="legend-items">
                    <div class="legend-item">
                        <div class="legend-box vacant"></div>
                        <span>Vacant (Available for booking)</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box occupied"></div>
                        <span>Occupied (Has guest)</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box maintenance"></div>
                        <span>Maintenance (Not available)</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box cleaning"></div>
                        <span>Cleaning (Preparing)</span>
                    </div>
                </div>
            </div>

            <!-- Room Status by Floor -->
            <%
                if (roomsByFloor == null || roomsByFloor.isEmpty()) {
            %>
                <div class="floor-section">
                    <div class="no-data">
                        <div class="no-data-icon">📭</div>
                        <p>No rooms found in database</p>
                        <a href="room-management?action=add" class="btn btn-primary" style="margin-top: 16px;">
                            Add Your First Room
                        </a>
                    </div>
                </div>
            <%
                } else {
                    for (Map.Entry<Integer, List<Room>> entry : roomsByFloor.entrySet()) {
                        int floorNumber = entry.getKey();
                        List<Room> rooms = entry.getValue();
            %>
            
            <div class="floor-section">
                <div class="floor-header">
                    <div class="floor-title">
                        <span class="floor-number">Floor <%= floorNumber %></span>
                        <span class="floor-badge"><%= rooms.size() %> Rooms</span>
                    </div>
                </div>
                
                <div class="rooms-grid">
                    <% for (Room room : rooms) { 
                        String statusClass = room.getStatus().toLowerCase();
                        boolean isOccupied = room.isOccupied();
                    %>
                    <div class="room-box <%= statusClass %>">
                        <div class="room-header">
                            <div class="room-number"><%= room.getRoomNumber() %></div>
                            <div class="room-type"><%= room.getRoomType() %></div>
                        </div>
                        
                        <div class="room-body">
                            <div class="room-info">
                                <span>Price/Night</span>
                                <span class="room-price">$<%= String.format("%.0f", room.getBasePrice()) %></span>
                            </div>
                            <span class="room-status-badge"><%= room.getStatus() %></span>
                        </div>

                        <% if (isOccupied && room.getGuestName() != null) { %>
                        <div class="tooltip">
                            <div class="tooltip-header">👤 <%= room.getGuestName() %></div>
                            <div class="tooltip-row">
                                <span class="tooltip-label">Reservation:</span>
                                <span class="tooltip-value">#<%= room.getReservationId() %></span>
                            </div>
                            <div class="tooltip-row">
                                <span class="tooltip-label">Check In:</span>
                                <span class="tooltip-value"><%= room.getCheckInDate() %></span>
                            </div>
                            <div class="tooltip-row">
                                <span class="tooltip-label">Check Out:</span>
                                <span class="tooltip-value"><%= room.getCheckOutDate() %></span>
                            </div>
                        </div>
                        <% } %>

                        <% if (managementMode) { %>
                        <div class="room-actions">
                            <a href="room-management?action=edit&id=<%= room.getRoomId() %>" class="action-btn edit">
                                ✏️ Edit
                            </a>
                            <button class="action-btn delete" 
                                    onclick="confirmDelete('<%= room.getRoomNumber() %>', <%= room.getRoomId() %>, <%= isOccupied %>)"
                                    <%= isOccupied ? "disabled title='Cannot delete occupied room'" : "" %>>
                                🗑️ Delete
                            </button>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>
            
            <% 
                    }
                }
            %>
        </div>
    </main>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteModal">
        <div class="modal">
            <div class="modal-title">🗑️ Confirm Delete</div>
            <div class="modal-text">
                Are you sure you want to delete Room <span id="deleteRoomNumber"></span>?
                <br><br>
                <strong style="color: var(--danger);">This action cannot be undone!</strong>
            </div>
            <div class="modal-actions">
                <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                <a href="#" id="confirmDeleteBtn" class="btn btn-danger">Delete Room</a>
            </div>
        </div>
    </main>

    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('active');
        }

        function confirmDelete(roomNumber, roomId, isOccupied) {
            if (isOccupied) {
                alert('Cannot delete room ' + roomNumber + ' because it is currently occupied.');
                return;
            }
            document.getElementById('deleteRoomNumber').textContent = roomNumber;
            document.getElementById('confirmDeleteBtn').href = 'room-management?action=delete&id=' + roomId;
            document.getElementById('deleteModal').classList.add('active');
        }

        function closeModal() {
            document.getElementById('deleteModal').classList.remove('active');
        }

        // Close modal on overlay click
        document.getElementById('deleteModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>
</body>
</html>