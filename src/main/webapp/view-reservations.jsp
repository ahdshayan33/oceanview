<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="oceanview.model.Reservation" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String dateFrom = (String) request.getAttribute("dateFrom");
    String dateTo = (String) request.getAttribute("dateTo");
    Integer resultCount = (Integer) request.getAttribute("resultCount");
    
    if (statusFilter == null) statusFilter = "";
    if (searchQuery == null) searchQuery = "";
    if (dateFrom == null) dateFrom = "";
    if (dateTo == null) dateTo = "";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Reservations - OceanView Hotel</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --info: #3b82f6;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-600: #475569;
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
        }

        /* Alert Messages */
        .alert {
            padding: 16px;
            border-radius: 8px;
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

        /* Filter Section */
        .filter-card {
            background: var(--white);
            border-radius: var(--radius);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
        }

        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 16px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-label {
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #64748b;
        }

        .form-input, .form-select {
            padding: 10px 14px;
            border: 2px solid var(--gray-200);
            border-radius: 8px;
            font-size: 14px;
            transition: var(--transition);
            font-family: inherit;
        }

        .form-input:focus, .form-select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .filter-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
        }

        /* Buttons */
        .btn {
            padding: 10px 20px;
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

        .btn-danger {
            background: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background: #dc2626;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
        }

        /* Stats Bar */
        .stats-bar {
            display: flex;
            gap: 24px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .stat-item {
            background: var(--white);
            padding: 16px 24px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .stat-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .stat-icon.confirmed { background: rgba(16, 185, 129, 0.1); }
        .stat-icon.checked-in { background: rgba(59, 130, 246, 0.1); }
        .stat-icon.checked-out { background: rgba(107, 114, 128, 0.1); }
        .stat-icon.cancelled { background: rgba(239, 68, 68, 0.1); }

        .stat-info {
            display: flex;
            flex-direction: column;
        }

        .stat-value {
            font-size: 24px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .stat-label {
            font-size: 12px;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Table */
        .table-card {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            overflow: hidden;
        }

        .table-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .table-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--gray-800);
        }

        .result-count {
            font-size: 14px;
            color: #64748b;
        }

        .table-responsive {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: var(--gray-50);
        }

        th {
            padding: 14px 20px;
            text-align: left;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #64748b;
            border-bottom: 1px solid var(--gray-200);
        }

        td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--gray-200);
            font-size: 14px;
            color: var(--gray-800);
        }

        tr:hover {
            background: var(--gray-50);
        }

        tr:last-child td {
            border-bottom: none;
        }

        /* Status Badges */
        .badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-confirmed {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }

        .badge-checked-in {
            background: rgba(59, 130, 246, 0.1);
            color: var(--info);
        }

        .badge-checked-out {
            background: rgba(107, 114, 128, 0.1);
            color: var(--gray-600);
        }

        .badge-cancelled {
            background: rgba(239, 68, 68, 0.1);
            color: var(--danger);
        }

        .badge-pending {
            background: rgba(245, 158, 11, 0.1);
            color: var(--warning);
        }

        .badge-paid {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }

        /* Guest Info */
        .guest-info {
            display: flex;
            flex-direction: column;
        }

        .guest-name {
            font-weight: 600;
            color: var(--gray-800);
        }

        .guest-phone {
            font-size: 12px;
            color: #64748b;
        }

        /* Room Info */
        .room-info {
            display: flex;
            flex-direction: column;
        }

        .room-number {
            font-weight: 600;
            color: var(--gray-800);
        }

        .room-type {
            font-size: 12px;
            color: #64748b;
        }

        /* Amount */
        .amount {
            font-weight: 700;
            color: var(--gray-800);
        }

        /* Action Buttons */
        .action-btns {
            display: flex;
            gap: 8px;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-icon {
            font-size: 64px;
            margin-bottom: 16px;
        }

        .empty-title {
            font-size: 20px;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .empty-text {
            color: #64748b;
            margin-bottom: 24px;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 100;
            justify-content: center;
            align-items: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: white;
            border-radius: var(--radius);
            padding: 24px;
            max-width: 500px;
            width: 90%;
            max-height: 90vh;
            overflow-y: auto;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .modal-title {
            font-size: 20px;
            font-weight: 700;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #64748b;
        }

        .modal-body {
            margin-bottom: 20px;
        }

        .detail-group {
            margin-bottom: 16px;
        }

        .detail-label-modal {
            font-size: 12px;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }

        .detail-value-modal {
            font-size: 16px;
            font-weight: 600;
            color: var(--gray-800);
        }

        .modal-footer {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
            .filter-grid { grid-template-columns: 1fr; }
            .stats-bar { flex-direction: column; }
            .action-btns { flex-direction: column; }
            th, td { padding: 12px; font-size: 12px; }
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
                <a href="add-reservation" class="nav-item">
                    <span style="width: 20px;">➕</span>
                    Add Reservation
                </a>
                <a href="view-reservations" class="nav-item active">
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
                <a href="room-status" class="nav-item">
                    <span style="width: 20px;">🚪</span>
                    Room Status
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
            <h1 class="page-title">View Reservations</h1>
        </header>

        <div class="dashboard-content">
            
            <% if (message != null) { %>
            <div class="alert alert-<%= messageType %>">
                <%= "success".equals(messageType) ? "✅" : "❌" %> <%= message %>
            </div>
            <% } %>

            <!-- Stats Bar -->
            <div class="stats-bar">
                <div class="stat-item">
                    <div class="stat-icon confirmed">✅</div>
                    <div class="stat-info">
                        <span class="stat-value" id="countConfirmed">0</span>
                        <span class="stat-label">Confirmed</span>
                    </div>
                </div>
                <div class="stat-item">
                    <div class="stat-icon checked-in">🏨</div>
                    <div class="stat-info">
                        <span class="stat-value" id="countCheckedIn">0</span>
                        <span class="stat-label">Checked In</span>
                    </div>
                </div>
                <div class="stat-item">
                    <div class="stat-icon checked-out">👋</div>
                    <div class="stat-info">
                        <span class="stat-value" id="countCheckedOut">0</span>
                        <span class="stat-label">Checked Out</span>
                    </div>
                </div>
                <div class="stat-item">
                    <div class="stat-icon cancelled">❌</div>
                    <div class="stat-info">
                        <span class="stat-value" id="countCancelled">0</span>
                        <span class="stat-label">Cancelled</span>
                    </div>
                </div>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form action="view-reservations" method="GET">
                    <div class="filter-grid">
                        <div class="form-group">
                            <label class="form-label">Search</label>
                            <input type="text" name="search" class="form-input" 
                                   placeholder="Guest name, NIC, Room..." 
                                   value="<%= searchQuery %>">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Status</label>
                            <select name="status" class="form-select">
                                <option value="">All Statuses</option>
                                <option value="CONFIRMED" <%= "CONFIRMED".equals(statusFilter) ? "selected" : "" %>>Confirmed</option>
                                <option value="CHECKED_IN" <%= "CHECKED_IN".equals(statusFilter) ? "selected" : "" %>>Checked In</option>
                                <option value="CHECKED_OUT" <%= "CHECKED_OUT".equals(statusFilter) ? "selected" : "" %>>Checked Out</option>
                                <option value="CANCELLED" <%= "CANCELLED".equals(statusFilter) ? "selected" : "" %>>Cancelled</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Check-in From</label>
                            <input type="date" name="dateFrom" class="form-input" value="<%= dateFrom %>">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Check-in To</label>
                            <input type="date" name="dateTo" class="form-input" value="<%= dateTo %>">
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <a href="view-reservations" class="btn btn-secondary">Clear Filters</a>
                        <button type="submit" class="btn btn-primary">🔍 Search</button>
                    </div>
                </form>
            </div>

            <!-- Reservations Table -->
            <div class="table-card">
                <div class="table-header">
                    <h3 class="table-title">Reservations</h3>
                    <span class="result-count"><%= resultCount != null ? resultCount : 0 %> results found</span>
                </div>
                
                <div class="table-responsive">
                    <% if (reservations != null && !reservations.isEmpty()) { %>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Guest</th>
                                <th>Room</th>
                                <th>Dates</th>
                                <th>Status</th>
                                <th>Payment</th>
                                <th>Amount</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            int confirmed = 0, checkedIn = 0, checkedOut = 0, cancelled = 0;
                            for (Reservation res : reservations) { 
                                String status = res.getStatus();
                                if ("CONFIRMED".equals(status)) confirmed++;
                                else if ("CHECKED_IN".equals(status)) checkedIn++;
                                else if ("CHECKED_OUT".equals(status)) checkedOut++;
                                else if ("CANCELLED".equals(status)) cancelled++;
                            %>
                            <tr data-status="<%= status %>">
                                <td>#<%= res.getReservationId() %></td>
                                <td>
                                    <div class="guest-info">
                                        <span class="guest-name"><%= res.getGuest() != null ? res.getGuest().getFullName() : "N/A" %></span>
                                        <span class="guest-phone"><%= res.getGuest() != null ? res.getGuest().getPhone() : "" %></span>
                                    </div>
                                </td>
                                <td>
                                    <div class="room-info">
                                        <span class="room-number">Room <%= res.getRoom() != null ? res.getRoom().getRoomNumber() : "N/A" %></span>
                                        <span class="room-type"><%= res.getRoom() != null ? res.getRoom().getRoomType() : "" %></span>
                                    </div>
                                </td>
                                <td>
                                    <%= res.getCheckInDate() %> →<br>
                                    <%= res.getCheckOutDate() %><br>
                                    <small style="color: #64748b;"><%= res.getNumNights() %> nights</small>
                                </td>
                                <td>
                                    <span class="badge badge-<%= status.toLowerCase().replace("_", "-") %>">
                                        <%= status.replace("_", " ") %>
                                    </span>
                                </td>
                                <td>
                                    <span class="badge badge-<%= res.getPaymentStatus() != null ? res.getPaymentStatus().toLowerCase() : "pending" %>">
                                        <%= res.getPaymentStatus() != null ? res.getPaymentStatus() : "PENDING" %>
                                    </span>
                                </td>
                                <td class="amount">$<%= String.format("%.2f", res.getTotalAmount()) %></td>
                                <td>
                                    <div class="action-btns">
                                        <button class="btn btn-secondary btn-sm" onclick="viewDetails(<%= res.getReservationId() %>)">👁️</button>
                                        <% if (!"CANCELLED".equals(status) && !"CHECKED_OUT".equals(status)) { %>
                                        <form action="view-reservations" method="POST" style="display: inline;" 
                                              onsubmit="return confirm('Are you sure you want to cancel this reservation?');">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="reservationId" value="<%= res.getReservationId() %>">
                                            <button type="submit" class="btn btn-danger btn-sm">❌</button>
                                        </form>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <script>
                        document.getElementById('countConfirmed').textContent = '<%= confirmed %>';
                        document.getElementById('countCheckedIn').textContent = '<%= checkedIn %>';
                        document.getElementById('countCheckedOut').textContent = '<%= checkedOut %>';
                        document.getElementById('countCancelled').textContent = '<%= cancelled %>';
                    </script>
                    
                    <% } else { %>
                    <div class="empty-state">
                        <div class="empty-icon">📋</div>
                        <h3 class="empty-title">No Reservations Found</h3>
                        <p class="empty-text">Try adjusting your filters or add a new reservation.</p>
                        <a href="add-reservation" class="btn btn-primary">➕ Add Reservation</a>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>

    <!-- View Details Modal -->
    <div id="detailsModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Reservation Details</h3>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body" id="modalBody">
                <!-- Content loaded dynamically -->
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeModal()">Close</button>
                <button class="btn btn-primary" onclick="window.print()">🖨️ Print</button>
            </div>
        </div>
    </div>

    <script>
        function viewDetails(reservationId) {
            // In a real implementation, fetch details via AJAX
            // For now, show placeholder
            document.getElementById('modalBody').innerHTML = `
                <div class="detail-group">
                    <div class="detail-label-modal">Reservation ID</div>
                    <div class="detail-value-modal">#${reservationId}</div>
                </div>
                <p>Loading full details...</p>
            `;
            document.getElementById('detailsModal').classList.add('active');
        }
        
        function closeModal() {
            document.getElementById('detailsModal').classList.remove('active');
        }
        
        // Close modal on outside click
        document.getElementById('detailsModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>

</body>
</html>