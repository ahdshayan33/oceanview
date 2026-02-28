<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="oceanview.model.Guest" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    
    Boolean editModeObj = (Boolean) request.getAttribute("editMode");
    boolean editMode = editModeObj != null && editModeObj.booleanValue();
    
    Guest guest = (Guest) request.getAttribute("guest");
    
    // Default values
    String nic = "";
    String guestName = "";
    String email = "";
    String phone = "";
    String address = "";
    String nationality = "";
    String dateOfBirth = "";
    String gender = "";
    String emergencyName = "";
    String emergencyPhone = "";
    
    // If edit mode, populate with guest data
    if (editMode && guest != null) {
        nic = guest.getNic();
        guestName = guest.getFullName();
        email = guest.getEmail() != null ? guest.getEmail() : "";
        phone = guest.getPhone() != null ? guest.getPhone() : "";
        address = guest.getAddress() != null ? guest.getAddress() : "";
        nationality = guest.getNationality() != null ? guest.getNationality() : "";
        dateOfBirth = guest.getDateOfBirth() != null ? guest.getDateOfBirth() : "";
        gender = guest.getGender() != null ? guest.getGender() : "";
        emergencyName = guest.getEmergencyContactName() != null ? guest.getEmergencyContactName() : "";
        emergencyPhone = guest.getEmergencyContactPhone() != null ? guest.getEmergencyContactPhone() : "";
    }
    
    // If NIC passed from check (new guest), use it
    String prefillNic = request.getParameter("nic");
    if (prefillNic != null && !editMode) {
        nic = prefillNic;
    }
    
    String title = editMode ? "Edit Guest" : "Register New Guest";
    String formAction = editMode ? "update" : "add";
    String submitButton = editMode ? "💾 Save Changes" : "➕ Register Guest";
    
    String errorMessage = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
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

        /* Sidebar - Same as other pages */
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
            max-width: 800px;
            margin: 0 auto;
            width: 100%;
        }

        /* Alert */
        .alert {
            padding: 16px;
            border-radius: var(--radius-sm);
            margin-bottom: 24px;
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid var(--danger);
            color: var(--danger);
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

        .form-section {
            margin-bottom: 32px;
        }

        .section-title {
            font-size: 14px;
            font-weight: 600;
            color: var(--gray-700);
            margin-bottom: 16px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
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

        .form-input, .form-select, .form-textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-family: inherit;
            transition: var(--transition);
        }

        .form-input:focus, .form-select:focus, .form-textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .form-textarea {
            min-height: 80px;
            resize: vertical;
        }

        .nic-input {
            text-transform: uppercase;
            font-family: monospace;
            letter-spacing: 1px;
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
                <a href="guest-management" class="nav-item active">
                    <span style="width: 20px;">👥</span>
                    Guest Management
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

                <form action="guest-management" method="post">
                    <input type="hidden" name="action" value="<%= formAction %>">

                    <!-- Personal Information -->
                    <div class="form-section">
                        <div class="section-title">👤 Personal Information</div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">NIC Number *</label>
                                <input type="text" name="nic" class="form-input nic-input" 
                                       value="<%= nic %>" 
                                       <%= editMode ? "readonly style='background: var(--gray-100);'" : "" %>
                                       placeholder="e.g., 951234567V" 
                                       maxlength="12" required>
                                <% if (!editMode) { %>
                                <small style="color: var(--gray-500); font-size: 12px;">This will be the guest's unique ID</small>
                                <% } %>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Full Name *</label>
                                <input type="text" name="fullName" class="form-input" 
                                       value="<%= guestName %>" 
                                       placeholder="Enter full name" required>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Date of Birth</label>
                                <input type="date" name="dateOfBirth" class="form-input" 
                                       value="<%= dateOfBirth %>">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Gender</label>
                                <select name="gender" class="form-select">
                                    <option value="">Select Gender</option>
                                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                                    <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Nationality</label>
                            <input type="text" name="nationality" class="form-input" 
                                   value="<%= nationality %>" 
                                   placeholder="e.g., Sri Lankan">
                        </div>
                    </div>

                    <!-- Contact Information -->
                    <div class="form-section">
                        <div class="section-title">📞 Contact Information</div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Phone Number</label>
                                <input type="tel" name="phone" class="form-input" 
                                       value="<%= phone %>" 
                                       placeholder="e.g., 0771234567">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" class="form-input" 
                                       value="<%= email %>" 
                                       placeholder="e.g., guest@email.com">
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Address</label>
                            <textarea name="address" class="form-textarea" 
                                      placeholder="Enter full address"><%= address %></textarea>
                        </div>
                    </div>

                    <!-- Emergency Contact -->
                    <div class="form-section">
                        <div class="section-title">🚨 Emergency Contact (Optional)</div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Contact Name</label>
                                <input type="text" name="emergencyContactName" class="form-input" 
                                       value="<%= emergencyName %>" 
                                       placeholder="Emergency contact name">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Contact Phone</label>
                                <input type="tel" name="emergencyContactPhone" class="form-input" 
                                       value="<%= emergencyPhone %>" 
                                       placeholder="Emergency contact phone">
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="guest-management" class="btn btn-secondary">← Cancel</a>
                        <button type="submit" class="btn btn-primary">
                            <%= submitButton %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script>
        // Auto-format NIC input
        document.querySelector('.nic-input').addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^0-9Vv]/g, '');
        });
    </script>
</body>
</html>