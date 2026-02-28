<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    oceanview.model.Reservation reservation = (oceanview.model.Reservation) request.getAttribute("reservation");
    
    // Calculate number of nights
    int numNights = 0;
    double nightlyRate = 0.0;
    if (reservation != null) {
        try {
            java.time.LocalDate checkIn = java.time.LocalDate.parse(reservation.getCheckInDate());
            java.time.LocalDate checkOut = java.time.LocalDate.parse(reservation.getCheckOutDate());
            numNights = (int) java.time.temporal.ChronoUnit.DAYS.between(checkIn, checkOut);
            nightlyRate = numNights > 0 ? reservation.getTotalAmount() / numNights : 0;
        } catch (Exception e) {
            numNights = 0;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Confirmed - OceanView Hotel</title>
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

        .success-card {
            background: var(--white);
            border-radius: var(--radius);
            padding: 48px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            text-align: center;
        }

        .success-icon {
            width: 80px;
            height: 80px;
            background: rgba(16, 185, 129, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            font-size: 40px;
        }

        .success-title {
            font-size: 28px;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .success-message {
            color: #64748b;
            font-size: 16px;
            margin-bottom: 32px;
        }

        .reservation-details {
            background: var(--gray-50);
            border-radius: var(--radius);
            padding: 24px;
            margin-bottom: 32px;
            text-align: left;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid var(--gray-200);
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-weight: 600;
            color: #64748b;
        }

        .detail-value {
            font-weight: 500;
            color: var(--gray-800);
        }

        .action-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 24px;
            border-radius: 8px;
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
        }

        .btn-secondary {
            background: var(--gray-100);
            color: var(--gray-800);
            border: 1px solid var(--gray-200);
        }

        .btn-secondary:hover {
            background: var(--gray-200);
        }

        .btn-success {
            background: var(--success);
            color: white;
        }

        .btn-success:hover {
            background: #059669;
        }

        /* Print Styles */
        @media print {
            .sidebar, .top-header, .action-buttons, .success-icon, .success-title, .success-message {
                display: none !important;
            }
            
            .main-content {
                margin-left: 0 !important;
            }
            
            .dashboard-content {
                padding: 0 !important;
                max-width: 100% !important;
            }
            
            .success-card {
                box-shadow: none !important;
                border: 1px solid #000 !important;
                padding: 20px !important;
            }
            
            .reservation-details {
                background: #fff !important;
                border: 1px solid #000 !important;
            }
            
            body {
                background: white !important;
            }
            
            .print-only {
                display: block !important;
            }
        }

        .print-only {
            display: none;
        }

        .print-header {
            text-align: center;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--gray-800);
        }

        .print-header h1 {
            font-size: 24px;
            margin-bottom: 8px;
        }

        .print-header p {
            color: #64748b;
            font-size: 14px;
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
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
            <h1 class="page-title">Reservation Confirmed</h1>
        </header>

        <div class="dashboard-content">
            <div class="success-card">
                
                <!-- Print Header (hidden on screen, shown when printing) -->
                <div class="print-only print-header">
                    <h1>🏨 OceanView Hotel</h1>
                    <p>123 Beach Road, Colombo, Sri Lanka<br>
                    Tel: +94 11 234 5678 | Email: info@oceanview.lk</p>
                    <h2 style="margin-top: 15px; font-size: 18px;">GUEST BILL / INVOICE</h2>
                </div>

                <div class="success-icon">✅</div>
                <h2 class="success-title">Reservation Created Successfully!</h2>
                <p class="success-message"><%= message != null ? message : "The reservation has been saved to the system." %></p>
                
                <% if (reservation != null) { %>
                <div class="reservation-details">
                    
                    <!-- Print-only reservation ID header -->
                    <div class="print-only" style="margin-bottom: 15px; text-align: center; font-size: 16px; font-weight: bold;">
                        Reservation #: <%= reservation.getReservationId() %> | Date: <%= new java.util.Date() %>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">Reservation ID:</span>
                        <span class="detail-value">#<%= reservation.getReservationId() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Guest NIC:</span>
                        <span class="detail-value"><%= reservation.getGuestNic() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Room ID:</span>
                        <span class="detail-value"><%= reservation.getRoomId() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Check-in Date:</span>
                        <span class="detail-value"><%= reservation.getCheckInDate() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Check-out Date:</span>
                        <span class="detail-value"><%= reservation.getCheckOutDate() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Number of Nights:</span>
                        <span class="detail-value"><%= numNights %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Guests:</span>
                        <span class="detail-value"><%= reservation.getNumGuests() %></span>
                    </div>
                    
                    <!-- Print-only breakdown -->
                    <div class="print-only" style="margin-top: 15px; border-top: 2px solid #000; padding-top: 15px;">
                        <div class="detail-row">
                            <span class="detail-label">Rate per Night:</span>
                            <span class="detail-value">$<%= String.format("%.2f", nightlyRate) %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Subtotal (<%= numNights %> nights):</span>
                            <span class="detail-value">$<%= String.format("%.2f", reservation.getTotalAmount()) %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Taxes & Fees:</span>
                            <span class="detail-value">Included</span>
                        </div>
                    </div>

                    <div class="detail-row" style="background: var(--primary); color: white; margin: 0 -24px -24px -24px; padding: 16px 24px; border-radius: 0 0 12px 12px;">
                        <span class="detail-label" style="color: white; font-size: 18px;">TOTAL AMOUNT:</span>
                        <span class="detail-value" style="color: white; font-size: 24px; font-weight: 700;">$<%= String.format("%.2f", reservation.getTotalAmount()) %></span>
                    </div>
                    
                    <div class="detail-row" style="margin-top: 12px;">
                        <span class="detail-label">Payment Status:</span>
                        <span class="detail-value" style="text-transform: uppercase; font-weight: 700; color: <%= "PAID".equals(reservation.getPaymentStatus()) ? "var(--success)" : "var(--warning)" %>;"><%= reservation.getPaymentStatus() %></span>
                    </div>
                    
                    <% if (reservation.getSpecialRequests() != null && !reservation.getSpecialRequests().isEmpty()) { %>
                    <div class="detail-row" style="flex-direction: column; align-items: flex-start; gap: 8px;">
                        <span class="detail-label">Special Requests:</span>
                        <span class="detail-value" style="font-style: italic;"><%= reservation.getSpecialRequests() %></span>
                    </div>
                    <% } %>

                    <!-- Print-only footer -->
                    <div class="print-only" style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #000; text-align: center; font-size: 12px; color: #666;">
                        <p>Thank you for choosing OceanView Hotel!</p>
                        <p style="margin-top: 10px;">___________________________<br>Guest Signature</p>
                        <p style="margin-top: 10px;">___________________________<br>Authorized By</p>
                    </div>
                </div>
                <% } %>
                
                <div class="action-buttons">
                    <button onclick="window.print()" class="btn btn-success">🖨️ Print Bill</button>
                    <a href="add-reservation" class="btn btn-primary">➕ New Reservation</a>
                    <a href="dashboard.jsp" class="btn btn-secondary">🏠 Dashboard</a>
                </div>
            </div>
        </div>
    </main>

</body>
</html>