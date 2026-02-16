<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String fullName = (String) session.getAttribute("fullName");
    if(fullName == null) fullName = "Guest";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <link rel="stylesheet" href="css/dashboardStyle.css">
    <!-- Add Inter font -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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
                <a href="addReservation.jsp" class="nav-item">
                    <span class="nav-icon">➕</span>
                    Add Reservation
                </a>
                <a href="viewReservation.jsp" class="nav-item">
                    <span class="nav-icon">📋</span>
                    View Reservations
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Management</div>
                <a href="guestManagement.jsp" class="nav-item">
                    <span class="nav-icon">👥</span>
                    Guest Management
                </a>
                <a href="roomStatus.jsp" class="nav-item">
                    <span class="nav-icon">🚪</span>
                    Room Status
                </a>
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
                    <h2 class="welcome-title">Welcome, <%= fullName %>! 👋</h2>
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
                    <a href="addReservation.jsp" class="menu-card add">
                        <div class="menu-icon-wrapper">➕</div>
                        <h4 class="menu-title">Add Reservation</h4>
                        <p class="menu-description">Create a new booking for walk-in or phone reservations</p>
                    </a>
                    
                    <a href="viewReservation.jsp" class="menu-card view">
                        <div class="menu-icon-wrapper">📋</div>
                        <h4 class="menu-title">View Reservations</h4>
                        <p class="menu-description">Manage existing bookings and check reservation details</p>
                    </a>
                    
                    <a href="guestManagement.jsp" class="menu-card guests">
                        <div class="menu-icon-wrapper">👥</div>
                        <h4 class="menu-title">Guest Management</h4>
                        <p class="menu-description">View guest profiles, preferences, and stay history</p>
                        <span class="menu-badge">New</span>
                    </a>
                    
                    <a href="roomStatus.jsp" class="menu-card rooms">
                        <div class="menu-icon-wrapper">🚪</div>
                        <h4 class="menu-title">Room Status</h4>
                        <p class="menu-description">Check room availability and housekeeping status</p>
                    </a>
                    
                    <a href="help.jsp" class="menu-card help">
                        <div class="menu-icon-wrapper">❓</div>
                        <h4 class="menu-title">Help Center</h4>
                        <p class="menu-description">Get assistance with system features and troubleshooting</p>
                    </a>
                    
                    <a href="index.jsp" class="menu-card logout">
                        <div class="menu-icon-wrapper">🚪</div>
                        <h4 class="menu-title">Logout</h4>
                        <p class="menu-description">Securely sign out of the management system</p>
                    </a>
                </div>
            </div>
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