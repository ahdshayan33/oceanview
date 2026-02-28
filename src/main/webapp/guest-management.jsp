<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="oceanview.model.Guest" %>

<%
    // Session check
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    List<Guest> guests = (List<Guest>) request.getAttribute("guests");
    String searchTerm = (String) request.getAttribute("searchTerm");
    boolean searchMode = request.getAttribute("searchMode") != null;
    
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Management - OceanView Hotel</title>
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
            --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1);
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

        /* Sidebar - Same as dashboard */
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
            max-width: 1200px;
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

        /* Action Bar */
        .action-bar {
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .search-box {
            flex: 1;
            min-width: 300px;
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 12px 16px 12px 48px;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 14px;
            transition: var(--transition);
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .search-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
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

        /* NIC Check Section */
        .nic-check-section {
            background: var(--white);
            border-radius: var(--radius);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
        }

        .nic-check-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 16px;
        }

        .nic-check-form {
            display: flex;
            gap: 12px;
            align-items: flex-end;
        }

        .form-group {
            flex: 1;
        }

        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--gray-600);
            margin-bottom: 6px;
        }

        .form-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 14px;
            transition: var(--transition);
            text-transform: uppercase;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--primary);
        }

        .nic-result {
            margin-top: 16px;
            padding: 16px;
            border-radius: var(--radius-sm);
            display: none;
        }

        .nic-result.found {
            display: block;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid var(--success);
            color: var(--success);
        }

        .nic-result.not-found {
            display: block;
            background: rgba(245, 158, 11, 0.1);
            border: 1px solid var(--warning);
            color: var(--warning);
        }

        /* Guest Table */
        .guest-table-container {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            overflow: hidden;
        }

        .table-header {
            padding: 20px 24px;
            background: linear-gradient(135deg, var(--gray-50) 0%, var(--white) 100%);
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .table-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--gray-800);
        }

        .guest-table {
            width: 100%;
            border-collapse: collapse;
        }

        .guest-table th {
            background: var(--gray-50);
            padding: 14px 20px;
            text-align: left;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--gray-500);
            border-bottom: 1px solid var(--gray-200);
        }

        .guest-table td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--gray-100);
            font-size: 14px;
            color: var(--gray-700);
        }

        .guest-table tr:hover {
            background: var(--gray-50);
        }

        .guest-nic {
            font-family: monospace;
            font-weight: 600;
            color: var(--primary);
            background: rgba(79, 70, 229, 0.1);
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 13px;
        }

        .guest-name {
            font-weight: 600;
            color: var(--gray-800);
        }

        .guest-contact {
            color: var(--gray-500);
            font-size: 13px;
        }

        .action-btns {
            display: flex;
            gap: 8px;
        }

        .action-btn {
            padding: 8px 12px;
            border-radius: var(--radius-sm);
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            border: none;
            text-decoration: none;
        }

        .action-btn.edit {
            background: var(--primary);
            color: white;
        }

        .action-btn.edit:hover {
            background: var(--primary-dark);
        }

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

        .no-data {
            text-align: center;
            padding: 60px;
            color: var(--gray-500);
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
            .action-bar { flex-direction: column; }
            .search-box { min-width: 100%; }
            .nic-check-form { flex-direction: column; }
            .guest-table { font-size: 12px; }
            .guest-table th, .guest-table td { padding: 12px; }
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
                <div class="nav-section-title">Main Menu</div>
                <a href="dashboard.jsp" class="nav-item">
                    <span style="width: 20px;">📊</span>
                    Dashboard
                </a>
                <a href="addReservation.jsp" class="nav-item">
                    <span style="width: 20px;">➕</span>
                    Add Reservation
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Management</div>
                <a href="guest-management" class="nav-item active">
                    <span style="width: 20px;">👥</span>
                    Guest Management
                </a>
                <a href="room-management" class="nav-item">
                    <span style="width: 20px;">🚪</span>
                    Room Management
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
            <h1 class="page-title">Guest Management</h1>
        </header>

        <div class="dashboard-content">
            
            <% if (message != null) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
            <% } %>

            <!-- NIC Check Section -->
            <div class="nic-check-section">
                <div class="nic-check-title">🔍 Quick Guest Lookup (By NIC)</div>
                <div class="nic-check-form">
                    <div class="form-group" style="flex: 2;">
                        <label class="form-label">Enter NIC Number</label>
                        <input type="text" id="nicInput" class="form-input" 
                               placeholder="e.g., 951234567V" maxlength="12">
                    </div>
                    <button class="btn btn-primary" onclick="checkGuest()">
                        🔍 Check Guest
                    </button>
                    <a href="guest-management?action=add" class="btn btn-secondary">
                        ➕ Register New Guest
                    </a>
                </div>
                <div id="nicResult" class="nic-result"></div>
            </div>

            <!-- Search & Actions -->
            <div class="action-bar">
                <form action="guest-management" method="get" class="search-box">
                    <span class="search-icon">🔍</span>
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="searchTerm" class="search-input" 
                           value="<%= searchTerm != null ? searchTerm : "" %>"
                           placeholder="Search by name, NIC, or phone...">
                </form>
                <a href="guest-management" class="btn btn-secondary">
                    📋 All Guests
                </a>
            </div>

            <!-- Guest Table -->
            <div class="guest-table-container">
                <div class="table-header">
                    <span class="table-title">
                        <%= searchMode ? "🔍 Search Results" : "👥 All Registered Guests" %>
                        (<%= guests != null ? guests.size() : 0 %>)
                    </span>
                </div>
                
                <% if (guests == null || guests.isEmpty()) { %>
                <div class="no-data">
                    <div style="font-size: 48px; margin-bottom: 16px;">📭</div>
                    <p>No guests found</p>
                    <% if (searchMode) { %>
                    <a href="guest-management" class="btn btn-secondary" style="margin-top: 16px;">
                        ← Back to All Guests
                    </a>
                    <% } else { %>
                    <a href="guest-management?action=add" class="btn btn-primary" style="margin-top: 16px;">
                        Register First Guest
                    </a>
                    <% } %>
                </div>
                <% } else { %>
                <table class="guest-table">
                    <thead>
                        <tr>
                            <th>NIC Number</th>
                            <th>Guest Name</th>
                            <th>Contact</th>
                            <th>Nationality</th>
                            <th>Registered</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Guest guest : guests) { %>
                        <tr>
                            <td>
                                <span class="guest-nic"><%= guest.getNic() %></span>
                            </td>
                            <td>
                                <div class="guest-name"><%= guest.getFullName() %></div>
                                <div class="guest-contact"><%= guest.getGender() != null ? guest.getGender() : "" %></div>
                            </td>
                            <td>
                                <div><%= guest.getPhone() != null ? guest.getPhone() : "N/A" %></div>
                                <div class="guest-contact"><%= guest.getEmail() != null ? guest.getEmail() : "" %></div>
                            </td>
                            <td><%= guest.getNationality() != null ? guest.getNationality() : "N/A" %></td>
                            <td class="guest-contact">
                                <%= guest.getCreatedAt() != null ? guest.getCreatedAt().toString().substring(0, 10) : "N/A" %>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <a href="guest-management?action=edit&nic=<%= guest.getNic() %>" 
                                       class="action-btn edit">✏️ Edit</a>
                                    <button class="action-btn delete" 
                                            onclick="confirmDelete('<%= guest.getFullName() %>', '<%= guest.getNic() %>')">
                                        🗑️ Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
    </main>

    <script>
        function checkGuest() {
            const nic = document.getElementById('nicInput').value.trim().toUpperCase();
            const resultDiv = document.getElementById('nicResult');
            
            if (!nic) {
                resultDiv.className = 'nic-result not-found';
                resultDiv.innerHTML = '⚠️ Please enter a NIC number';
                return;
            }
            
            // AJAX call to check guest
            fetch('guest-management?action=check&nic=' + encodeURIComponent(nic))
                .then(response => response.json())
                .then(data => {
                    if (data.found) {
                        resultDiv.className = 'nic-result found';
                        resultDiv.innerHTML = '✅ Guest found: <strong>' + data.name + '</strong><br>' +
                            '<a href="addReservation.jsp?nic=' + nic + '" class="btn btn-primary" style="margin-top: 12px;">📋 Make Reservation</a>';
                    } else {
                        resultDiv.className = 'nic-result not-found';
                        resultDiv.innerHTML = '❌ Guest not found. <a href="guest-management?action=add&nic=' + nic + '" style="color: var(--primary); font-weight: 600;">Register now →</a>';
                    }
                })
                .catch(error => {
                    resultDiv.className = 'nic-result not-found';
                    resultDiv.innerHTML = '⚠️ Error checking guest. Please try again.';
                });
        }
        
        // Allow Enter key to trigger search
        document.getElementById('nicInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                checkGuest();
            }
        });
        
        function confirmDelete(name, nic) {
            if (confirm('Are you sure you want to delete guest: ' + name + ' (' + nic + ')?\n\nThis cannot be undone if they have no active reservations.')) {
                window.location.href = 'guest-management?action=delete&nic=' + nic;
            }
        }
    </script>
</body>
</html>