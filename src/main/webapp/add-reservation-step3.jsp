<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="oceanview.model.Guest" %>
<%@ page import="oceanview.model.Room" %>
<%@ page import="java.util.List" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    Guest guest = (Guest) request.getAttribute("guest");
    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
    
    String checkIn = (String) request.getAttribute("checkIn");
    String checkOut = (String) request.getAttribute("checkOut");
    String roomType = (String) request.getAttribute("roomType");
    Integer numNights = (Integer) request.getAttribute("numNights");
    
    if (guest == null || availableRooms == null) {
        response.sendRedirect("add-reservation?step=2&guestNic=" + (guest != null ? guest.getNic() : ""));
        return;
    }
    
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Step 3: Select Room - Add Reservation</title>
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
                <div class="step completed">
                    <span>✓</span> Dates
                </div>
                <div class="step active">
                    <span>3</span> Room
                </div>
            </div>

            <!-- Booking Summary -->
            <div class="booking-summary">
                <div class="summary-item">
                    <div class="summary-label">Guest</div>
                    <div class="summary-value"><%= guest.getFullName() %></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Check-In</div>
                    <div class="summary-value"><%= checkIn %></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Check-Out</div>
                    <div class="summary-value"><%= checkOut %></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Nights</div>
                    <div class="summary-value"><%= numNights %> night<%= numNights > 1 ? "s" : "" %></div>
                </div>
                <a href="add-reservation?step=2&guestNic=<%= guest.getNic() %>" class="btn btn-sm btn-secondary">Change</a>
            </div>

            <% if (error != null) { %>
            <div class="alert alert-error">
                ⚠️ <%= error %>
            </div>
            <% } %>

            <!-- Room Selection -->
            <div class="rooms-container">
                <div class="rooms-header">
                    <div class="rooms-title">🏨 Available Rooms</div>
                    <div class="rooms-count"><%= availableRooms.size() %> room<%= availableRooms.size() != 1 ? "s" : "" %> found</div>
                </div>

                <% if (availableRooms.isEmpty()) { %>
                <div class="no-rooms">
                    <div class="no-rooms-icon">😞</div>
                    <div class="no-rooms-title">No Rooms Available</div>
                    <div class="no-rooms-text">No rooms are available for the selected dates<%= roomType != null && !roomType.isEmpty() ? " and room type" : "" %>.</div>
                    <a href="add-reservation?step=2&guestNic=<%= guest.getNic() %>" class="btn btn-primary" style="margin-top: 16px;">
                        ← Try Different Dates
                    </a>
                </div>
                <% } else { %>
                <div class="rooms-grid">
                    <% for (Room room : availableRooms) { 
                        double totalPrice = room.getBasePrice() * numNights;
                    %>
                    <div class="room-card" onclick="selectRoom('<%= room.getRoomId() %>', '<%= room.getRoomNumber() %>', <%= room.getBasePrice() %>, <%= totalPrice %>)">
                        <div class="room-header">
                            <div class="room-number"><%= room.getRoomNumber() %></div>
                            <div class="room-type"><%= room.getRoomType() %></div>
                        </div>
                        
                        <div class="room-details">
                            <div class="detail-item">
                                <span class="detail-label">Floor</span>
                                <span class="detail-value"><%= room.getFloorNumber() %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Price/Night</span>
                                <span class="detail-value price">$<%= String.format("%.2f", room.getBasePrice()) %></span>
                            </div>
                        </div>
                        
                        <div class="room-total">
                            <div class="total-label">Total for <%= numNights %> night<%= numNights > 1 ? "s" : "" %></div>
                            <div class="total-price">$<%= String.format("%.2f", totalPrice) %></div>
                        </div>
                        
                        <div class="room-select-btn">
                            Select This Room
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>

            <!-- Reservation Form (Hidden initially) -->
            <div id="reservationForm" class="reservation-form-container" style="display: none;">
                <div class="form-header">
                    <div class="form-title">✅ Confirm Reservation</div>
                    <div class="form-subtitle">Review and confirm the booking details</div>
                </div>

                <form action="add-reservation" method="post" id="finalForm">
                    <input type="hidden" name="action" value="createReservation">
                    <input type="hidden" name="guestNic" value="<%= guest.getNic() %>">
                    <input type="hidden" name="roomId" id="selectedRoomId">
                    <input type="hidden" name="checkIn" value="<%= checkIn %>">
                    <input type="hidden" name="checkOut" value="<%= checkOut %>">
                    <input type="hidden" name="numGuests" value="1">
                    <input type="hidden" name="totalAmount" id="totalAmount">

                    <div class="selected-room-summary" id="selectedRoomSummary">
                        <!-- Populated by JavaScript -->
                    </div>

                    <div class="form-group">
                        <label class="form-label">Number of Guests</label>
                        <input type="number" name="numGuestsInput" id="numGuestsInput" class="form-input" 
                               value="1" min="1" max="4" onchange="updateGuests(this.value)">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Payment Status</label>
                        <select name="paymentStatus" class="form-select">
                            <option value="PENDING">Pending Payment</option>
                            <option value="PARTIAL">Partial Payment</option>
                            <option value="PAID">Fully Paid</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Special Requests (Optional)</label>
                        <textarea name="specialRequests" class="form-textarea" 
                                  placeholder="Any special requirements for the guest..."></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="cancelSelection()">← Back to Rooms</button>
                        <button type="submit" class="btn btn-primary">✅ Create Reservation</button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script>
        let selectedRoom = null;

        function selectRoom(roomId, roomNumber, pricePerNight, totalPrice) {
            selectedRoom = { roomId, roomNumber, pricePerNight, totalPrice };
            
            document.getElementById('selectedRoomId').value = roomId;
            document.getElementById('totalAmount').value = totalPrice;
            
            document.getElementById('selectedRoomSummary').innerHTML = `
                <div class="summary-card">
                    <div class="summary-room">Room ${roomNumber}</div>
                    <div class="summary-price">$${pricePerNight.toFixed(2)} × ${document.getElementById('numGuestsInput').value} guest(s) × <%= numNights %> nights</div>
                    <div class="summary-total">Total: $${totalPrice.toFixed(2)}</div>
                </div>
            `;
            
            document.querySelector('.rooms-container').style.display = 'none';
            document.getElementById('reservationForm').style.display = 'block';
            window.scrollTo(0, 0);
        }

        function cancelSelection() {
            document.getElementById('reservationForm').style.display = 'none';
            document.querySelector('.rooms-container').style.display = 'block';
            selectedRoom = null;
        }

        function updateGuests(num) {
            if (selectedRoom) {
                const newTotal = selectedRoom.pricePerNight * num * <%= numNights %>;
                document.getElementById('totalAmount').value = newTotal;
                document.querySelector('.summary-total').textContent = 'Total: $' + newTotal.toFixed(2);
            }
        }

        document.getElementById('finalForm').addEventListener('submit', function(e) {
            if (!document.getElementById('selectedRoomId').value) {
                e.preventDefault();
                alert('Please select a room first');
                return false;
            }
            return confirm('Are you sure you want to create this reservation?');
        });
    </script>
</body>
</html>