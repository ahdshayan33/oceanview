<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="oceanview.model.Guest" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    Guest guest = (Guest) request.getAttribute("guest");
    
    if (guest == null) {
        response.sendRedirect("add-reservation?step=1");
        return;
    }
    
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Step 2: Select Dates - Add Reservation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/reservation.css">
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
                    <span class="nav-icon">📊</span>
                    Dashboard
                </a>
                <a href="add-reservation" class="nav-item active">
                    <span class="nav-icon">➕</span>
                    Add Reservation
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
        <header class="top-header">
            <div class="header-left">
                <h1 class="page-title">Add New Reservation</h1>
            </div>
        </header>

        <div class="dashboard-content">
            
            <!-- Progress Steps -->
            <div class="progress-steps">
                <div class="step completed">
                    <span>✓</span> Guest
                </div>
                <div class="step active">
                    <span>2</span> Dates
                </div>
                <div class="step">
                    <span>3</span> Room
                </div>
            </div>

            <% if (error != null) { %>
            <div class="alert alert-error">
                ⚠️ <%= error %>
            </div>
            <% } %>

            <!-- Guest Info Card -->
            <div class="guest-info-card">
                <div class="guest-avatar-large"><%= guest.getFullName().charAt(0) %></div>
                <div class="guest-details">
                    <div class="guest-name-large"><%= guest.getFullName() %></div>
                    <div class="guest-meta">
                        <span class="meta-item"><strong>NIC:</strong> <%= guest.getNic() %></span>
                        <span class="meta-item"><strong>Phone:</strong> <%= guest.getPhone() != null ? guest.getPhone() : "N/A" %></span>
                        <span class="meta-item"><strong>Email:</strong> <%= guest.getEmail() != null ? guest.getEmail() : "N/A" %></span>
                    </div>
                </div>
                <a href="add-reservation?step=1" class="btn btn-sm btn-secondary">Change Guest</a>
            </div>

            <!-- Date Selection Form -->
            <div class="form-container">
                <div class="form-header">
                    <div class="form-title">📅 Select Stay Dates</div>
                    <div class="form-subtitle">Choose check-in and check-out dates to find available rooms</div>
                </div>

                <form action="add-reservation" method="post" id="dateForm">
                    <input type="hidden" name="action" value="findRooms">
                    <input type="hidden" name="guestNic" value="<%= guest.getNic() %>">

                    <div class="date-selection-grid">
                        <div class="date-box">
                            <label class="date-label">Check-In Date *</label>
                            <input type="date" name="checkIn" id="checkIn" class="date-input" required 
                                   min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                            <div class="date-hint">Guest arrives</div>
                        </div>

                        <div class="date-divider">
                            <div class="nights-indicator" id="nightsCount">0 nights</div>
                            <div class="arrow">→</div>
                        </div>

                        <div class="date-box">
                            <label class="date-label">Check-Out Date *</label>
                            <input type="date" name="checkOut" id="checkOut" class="date-input" required disabled>
                            <div class="date-hint">Guest departs</div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Room Type Preference (Optional)</label>
                        <select name="roomType" class="form-select">
                            <option value="">Any Room Type</option>
                            <option value="Standard">Standard</option>
                            <option value="Deluxe">Deluxe</option>
                            <option value="Suite">Suite</option>
                            <option value="Presidential">Presidential</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <a href="add-reservation?step=1" class="btn btn-secondary">← Back</a>
                        <button type="submit" class="btn btn-primary" id="findRoomsBtn" disabled>
                            🔍 Find Available Rooms
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script>
        const checkIn = document.getElementById('checkIn');
        const checkOut = document.getElementById('checkOut');
        const nightsCount = document.getElementById('nightsCount');
        const findRoomsBtn = document.getElementById('findRoomsBtn');
        const dateForm = document.getElementById('dateForm');

        checkIn.addEventListener('change', function() {
            if (this.value) {
                checkOut.min = this.value;
                checkOut.disabled = false;
                checkOut.focus();
            }
            updateNights();
        });

        checkOut.addEventListener('change', function() {
            updateNights();
        });

        function updateNights() {
            if (checkIn.value && checkOut.value) {
                const start = new Date(checkIn.value);
                const end = new Date(checkOut.value);
                const diffTime = end - start;
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                
                if (diffDays > 0) {
                    nightsCount.textContent = diffDays + ' night' + (diffDays > 1 ? 's' : '');
                    nightsCount.classList.add('active');
                    findRoomsBtn.disabled = false;
                } else {
                    nightsCount.textContent = 'Invalid dates';
                    nightsCount.classList.remove('active');
                    findRoomsBtn.disabled = true;
                }
            } else {
                nightsCount.textContent = '0 nights';
                nightsCount.classList.remove('active');
                findRoomsBtn.disabled = true;
            }
        }

        dateForm.addEventListener('submit', function(e) {
            const start = new Date(checkIn.value);
            const end = new Date(checkOut.value);
            
            if (end <= start) {
                e.preventDefault();
                alert('Check-out date must be after check-in date');
                return false;
            }
        });
    </script>
</body>
</html>