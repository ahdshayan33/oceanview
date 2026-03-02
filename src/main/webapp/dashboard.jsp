<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="oceanview.model.User" %>
<%
    // Check if user is logged in
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = currentUser.getFullName();
    String role = currentUser.getRole();
    boolean isAdmin = currentUser.isAdmin();
    boolean isReceptionist = currentUser.isReceptionist();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - OceanView Hotel</title>
    <link rel="stylesheet" href="css/dashboardStyle.css">
    <!-- Add Inter font -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Role badge styles */
        .role-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-left: 8px;
        }
        
        .role-admin {
            background: rgba(79, 70, 229, 0.1);
            color: #4f46e5;
        }
        
        .role-receptionist {
            background: rgba(16, 185, 129, 0.1);
            color: #059669;
        }
        
        /* Admin-only indicator */
        .admin-only {
            position: relative;
        }
        
        .admin-only::after {
            content: "ADMIN";
            position: absolute;
            top: -4px;
            right: -4px;
            background: #4f46e5;
            color: white;
            font-size: 8px;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <!-- Mobile Overlay -->
    <div class="overlay" id="overlay" onclick="toggleSidebar()"></div>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon">🏨</div>
            <div class="logo-text">Ocean<span>View</span></div>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href="dashboard.jsp" class="nav-item active">
                    <span class="nav-icon">📊</span>
                    Dashboard
                </a>
                <a href="add-reservation" class="nav-item">
                    <span class="nav-icon">➕</span>
                    Add Reservation
                </a>
                <a href="view-reservations" class="nav-item">
                    <span class="nav-icon">📋</span>
                    View Reservations
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Management</div>
                <a href="guest-management" class="nav-item">
                    <span class="nav-icon">👥</span>
                    Guest Management
                </a>
                <a href="room-status" class="nav-item">
                    <span class="nav-icon">🚪</span>
                    Room Status
                </a>
                
                <%-- ADMIN ONLY: User Management --%>
                <% if (isAdmin) { %>
                <a href="user-management" class="nav-item admin-only">
                    <span class="nav-icon">🔐</span>
                    User Management
                </a>
                <% } %>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Support</div>
                <a href="help.jsp" class="nav-item">
                    <span class="nav-icon">❓</span>
                    Help Center
                </a>
            </div>
        </nav>
        
        <div class="sidebar-footer">
            <div class="user-profile">
                <div class="user-avatar"><%= fullName.charAt(0) %></div>
                <div class="user-info">
                    <div class="user-name">
                        <%= fullName %>
                        <span class="role-badge <%= isAdmin ? "role-admin" : "role-receptionist" %>">
                            <%= role %>
                        </span>
                    </div>
                    <div class="user-role"><%= isAdmin ? "Administrator" : "Receptionist" %></div>
                </div>
                <a href="logout" class="logout-btn" title="Logout">🚪</a>
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
                    Dashboard
                    <span class="welcome-badge">Welcome Back!</span>
                </h1>
            </div>
            <div class="header-right">
                <a href="help.jsp" class="header-icon-btn" title="Help">❓</a>
                <a href="#" class="header-icon-btn" title="Notifications">
                    🔔
                    <span class="notification-badge">3</span>
                </a>
            </div>
        </header>

        <!-- Dashboard Content -->
        <div class="dashboard-content">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <div class="welcome-content">
                    <h2 class="welcome-title">
                        Welcome, <%= fullName %>! 👋
                        <% if (isReceptionist) { %>
                        <span style="font-size: 16px; color: #64748b; font-weight: 400;">(Receptionist Mode)</span>
                        <% } %>
                    </h2>
                    <p class="welcome-subtitle">Here's what's happening at your hotel today</p>
                </div>
            </div>

            <!-- Quick Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-header">
                        <div>
                            <div class="stat-label">Today's Check-ins</div>
                            <div class="stat-value">12</div>
                            <div class="stat-change">↑ 3 from yesterday</div>
                        </div>
                        <div class="stat-icon reservations">📥</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-header">
                        <div>
                            <div class="stat-label">Occupancy Rate</div>
                            <div class="stat-value">85%</div>
                            <div class="stat-change">↑ 5% this week</div>
                        </div>
                        <div class="stat-icon rooms">🏨</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-header">
                        <div>
                            <div class="stat-label">Active Guests</div>
                            <div class="stat-value">48</div>
                            <div class="stat-change">↑ 8 new today</div>
                        </div>
                        <div class="stat-icon guests">👥</div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="menu-section">
                <div class="section-header">
                    <h3 class="section-title">
                        <span class="section-icon">⚡</span>
                        Quick Actions
                    </h3>
                </div>
                
                <div class="menu-grid">
                    <a href="add-reservation" class="menu-card add">
                        <div class="menu-icon-wrapper">➕</div>
                        <h4 class="menu-title">Add Reservation</h4>
                        <p class="menu-description">Create a new booking for walk-in or phone reservations</p>
                    </a>
                    
                    <a href="view-reservations" class="menu-card view">
                        <div class="menu-icon-wrapper">📋</div>
                        <h4 class="menu-title">View Reservations</h4>
                        <p class="menu-description">Manage existing bookings and check reservation details</p>
                    </a>
                    
                    <a href="guest-management" class="menu-card guests">
                        <div class="menu-icon-wrapper">👥</div>
                        <h4 class="menu-title">Guest Management</h4>
                        <p class="menu-description">View guest profiles, preferences, and stay history</p>
                        <span class="menu-badge">New</span>
                    </a>
                    
                    <a href="room-status" class="menu-card rooms">
                        <div class="menu-icon-wrapper">🚪</div>
                        <h4 class="menu-title">Room Status</h4>
                        <p class="menu-description">Check room availability and housekeeping status</p>
                    </a>
                    
                    <%-- ADMIN ONLY: User Management Card --%>
                    <% if (isAdmin) { %>
                    <a href="user-management" class="menu-card" style="background: linear-gradient(135deg, rgba(79, 70, 229, 0.1) 0%, rgba(14, 165, 233, 0.1) 100%); border-color: #4f46e5;">
                        <div class="menu-icon-wrapper" style="background: #4f46e5; color: white;">🔐</div>
                        <h4 class="menu-title">User Management</h4>
                        <p class="menu-description">Create and manage admin & receptionist accounts</p>
                        <span class="menu-badge" style="background: #4f46e5;">Admin Only</span>
                    </a>
                    <% } %>
                    
                    <a href="help.jsp" class="menu-card help">
                        <div class="menu-icon-wrapper">❓</div>
                        <h4 class="menu-title">Help Center</h4>
                        <p class="menu-description">Get assistance with system features and troubleshooting</p>
                    </a>
                    
                    <a href="logout" class="menu-card logout">
                        <div class="menu-icon-wrapper">🚪</div>
                        <h4 class="menu-title">Logout</h4>
                        <p class="menu-description">Securely sign out of the management system</p>
                    </a>
                </div>
            </div>
            
            <%-- Receptionist Notice --%>
            <% if (isReceptionist) { %>
            <div style="margin-top: 24px; padding: 16px; background: rgba(16, 185, 129, 0.1); border-radius: 8px; border-left: 4px solid #10b981;">
                <strong>💡 Receptionist Access</strong><br>
                You have access to reservations, guests, and rooms. For user management and advanced settings, contact an administrator.
            </div>
            <% } %>
        </div>
    </main>

    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('active');
            document.getElementById('overlay').classList.toggle('active');
        }
    </script>
</body>
</html>