<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Step 1: Guest Lookup - Add Reservation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-800: #1e293b;
            --white: #ffffff;
            --shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
            --radius: 12px;
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
            color: #94a3b8;
            padding: 0 12px;
            margin-bottom: 8px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            border-radius: 8px;
            color: #64748b;
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
            background: linear-gradient(135deg, var(--primary) 0%, #0ea5e9 100%);
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

        .logout-btn {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #94a3b8;
            text-decoration: none;
            border: 1px solid var(--gray-200);
        }

        .logout-btn:hover {
            background: var(--danger);
            color: white;
        }

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

        /* Progress Steps */
        .progress-steps {
            display: flex;
            justify-content: center;
            margin-bottom: 32px;
            gap: 8px;
        }

        .step {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background: var(--gray-200);
            border-radius: 8px;
            color: #64748b;
            font-size: 14px;
            font-weight: 500;
        }

        .step.active {
            background: var(--primary);
            color: white;
        }

        .step.completed {
            background: var(--success);
            color: white;
        }

        /* Form Container */
        .form-container {
            background: var(--white);
            border-radius: var(--radius);
            padding: 32px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
        }

        .form-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .form-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .form-subtitle {
            color: #64748b;
            font-size: 14px;
        }

        .nic-search-box {
            background: linear-gradient(135deg, rgba(79, 70, 229, 0.05) 0%, rgba(14, 165, 233, 0.05) 100%);
            border: 2px dashed var(--primary);
            border-radius: var(--radius);
            padding: 32px;
            text-align: center;
            margin-bottom: 24px;
        }

        .search-icon {
            font-size: 48px;
            margin-bottom: 16px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .form-input {
            width: 100%;
            padding: 16px;
            border: 2px solid var(--gray-200);
            border-radius: 8px;
            font-size: 18px;
            font-family: monospace;
            text-align: center;
            text-transform: uppercase;
            letter-spacing: 2px;
            transition: var(--transition);
        }

        .form-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1);
        }

        .btn {
            padding: 16px 32px;
            border-radius: 8px;
            font-size: 16px;
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
            width: 100%;
            justify-content: center;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
        }

        .btn-secondary {
            background: var(--gray-100);
            color: var(--gray-800);
            border: 1px solid var(--gray-200);
        }

        .btn-secondary:hover {
            background: var(--gray-200);
        }

        /* Guest Result */
        .guest-result {
            display: none;
            margin-top: 24px;
            padding: 24px;
            border-radius: var(--radius);
            text-align: left;
        }

        .guest-result.found {
            display: block;
            background: rgba(16, 185, 129, 0.1);
            border: 2px solid var(--success);
        }

        .guest-result.not-found {
            display: block;
            background: rgba(245, 158, 11, 0.1);
            border: 2px solid var(--warning);
        }

        .guest-name {
            font-size: 20px;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .guest-details {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 16px;
        }

        .action-buttons {
            display: flex;
            gap: 12px;
            margin-top: 16px;
        }

        .action-buttons .btn {
            flex: 1;
        }

        .divider {
            display: flex;
            align-items: center;
            margin: 24px 0;
            color: #94a3b8;
            font-size: 14px;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--gray-200);
        }

        .divider span {
            padding: 0 16px;
        }

        .alert {
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid var(--danger);
            color: var(--danger);
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
            .progress-steps { flex-direction: column; }
            .action-buttons { flex-direction: column; }
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
                <a href="add-reservation" class="nav-item active">
                    <span style="width: 20px;">➕</span>
                    Add Reservation
                </a>
            </div>
        </nav>
        
        <div class="sidebar-footer">
            <div class="user-profile">
                <div class="user-avatar"><%= fullName.charAt(0) %></div>
                <div>
                    <div class="user-name"><%= fullName %></div>
                    <div style="font-size: 12px; color: #64748b;">Administrator</div>
                </div>
                <a href="index.jsp" class="logout-btn">🚪</a>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <header class="top-header">
            <h1 class="page-title">Add New Reservation</h1>
        </header>

        <div class="dashboard-content">
            
            <!-- Progress Steps -->
            <div class="progress-steps">
                <div class="step active">
                    <span>1</span> Guest
                </div>
                <div class="step">
                    <span>2</span> Dates
                </div>
                <div class="step">
                    <span>3</span> Room
                </div>
            </div>

            <% if (error != null) { %>
            <div class="alert">
                ⚠️ <%= error %>
            </div>
            <% } %>

            <div class="form-container">
                <div class="form-header">
                    <div class="form-title">🔍 Find Guest</div>
                    <div class="form-subtitle">Enter guest's NIC number to check if they're already registered</div>
                </div>

                <div class="nic-search-box">
                    <div class="search-icon">🆔</div>
                    
                    <div class="form-group">
                        <label class="form-label">NIC Number</label>
                        <input type="text" id="nicInput" class="form-input" 
                               placeholder="951234567V" maxlength="12" autofocus>
                    </div>
                    
                    <button class="btn btn-primary" onclick="checkGuest()">
                        🔍 Check Guest
                    </button>
                </div>

                <!-- Guest Found Result -->
                <div id="guestFound" class="guest-result found">
                    <div class="guest-name" id="foundName"></div>
                    <div class="guest-details" id="foundDetails"></div>
                    <div class="action-buttons">
                        <a href="guest-form.jsp" class="btn btn-secondary">✏️ Edit Details</a>
                        <a id="proceedLink" href="#" class="btn btn-primary">✅ Proceed to Dates →</a>
                    </div>
                </div>

                <!-- Guest Not Found Result -->
                <div id="guestNotFound" class="guest-result not-found">
                    <div class="guest-name">❌ Guest Not Found</div>
                    <div class="guest-details">This NIC is not registered in our system. Please register the guest first.</div>
                    <div class="action-buttons">
                        <a href="guest-management" class="btn btn-secondary">← Back to Guests</a>
                        <a id="registerLink" href="guest-form.jsp" class="btn btn-primary">➕ Register New Guest</a>
                    </div>
                </div>

                <div class="divider">
                    <span>OR</span>
                </div>

                <div style="text-align: center;">
                    <a href="guest-form.jsp" class="btn btn-secondary">
                        ➕ Register New Guest Directly
                    </a>
                </div>
            </div>
        </div>
    </main>

    <script>
        // Auto-focus and format NIC input
        document.getElementById('nicInput').addEventListener('input', function(e) {
            this.value = this.value.toUpperCase().replace(/[^0-9Vv]/g, '');
        });

        // Allow Enter key to search
        document.getElementById('nicInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                checkGuest();
            }
        });

        function checkGuest() {
            const nic = document.getElementById('nicInput').value.trim();
            
            if (!nic) {
                alert('Please enter a NIC number');
                return;
            }

            // Hide previous results
            document.getElementById('guestFound').style.display = 'none';
            document.getElementById('guestNotFound').style.display = 'none';

            // AJAX call to check guest
            fetch('add-reservation?action=checkGuest&nic=' + encodeURIComponent(nic))
                .then(response => response.json())
                .then(data => {
                    if (data.found) {
                        // Show found result
                        document.getElementById('foundName').textContent = '✅ ' + data.name;
                        document.getElementById('foundDetails').textContent = 'NIC: ' + data.nic + ' | Phone: ' + (data.phone || 'N/A');
                        document.getElementById('proceedLink').href = 'add-reservation?step=2&guestNic=' + encodeURIComponent(data.nic);
                        document.getElementById('guestFound').style.display = 'block';
                    } else {
                        // Show not found result
                        document.getElementById('registerLink').href = 'guest-form.jsp?nic=' + encodeURIComponent(nic);
                        document.getElementById('guestNotFound').style.display = 'block';
                    }
                })
                .catch(error => {
                    alert('Error checking guest. Please try again.');
                    console.error(error);
                });
        }
    </script>
</body>
</html>