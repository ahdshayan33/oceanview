package oceanview.servlet;

import oceanview.dao.ReservationDAO;
import oceanview.dao.GuestDAO;
import oceanview.dao.RoomDAO;
import oceanview.model.Reservation;
import oceanview.model.Guest;
import oceanview.model.Room;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/add-reservation")
public class AddReservationServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private ReservationDAO reservationDAO;
    private GuestDAO guestDAO;
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
        guestDAO = new GuestDAO();
        roomDAO = new RoomDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check login
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("fullName") == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        // FIX: Check for action parameter first (for AJAX calls)
        String action = request.getParameter("action");
        if ("checkGuest".equals(action)) {
            handleGuestCheck(request, response);
            return;
        }
        
        String step = request.getParameter("step");
        if (step == null) step = "1";
        
        System.out.println("AddReservationServlet Step: " + step);
        
        switch (step) {
            case "1":
                // Step 1: Guest Lookup/Registration
                showGuestLookup(request, response);
                break;
                
            case "2":
                // Step 2: Select Dates and Find Available Rooms
                showDateSelection(request, response);
                break;
                
            case "3":
                // Step 3: Select Room and Confirm
                showRoomSelection(request, response);
                break;
                
            default:
                showGuestLookup(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("fullName") == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        System.out.println("AddReservationServlet POST action: " + action);
        
        if ("checkGuest".equals(action)) {
            // AJAX: Check guest by NIC
            handleGuestCheck(request, response);
            
        } else if ("findRooms".equals(action)) {
            // Find available rooms for dates
            handleFindRooms(request, response);
            
        } else if ("createReservation".equals(action)) {
            // Final: Create the reservation
            handleCreateReservation(request, response, session);
        }
    }
    
    // Step 1: Show guest lookup
    private void showGuestLookup(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/add-reservation-step1.jsp").forward(request, response);
    }
    
    // Step 2: Show date selection (after guest is selected)
    private void showDateSelection(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String guestNic = request.getParameter("guestNic");
        Guest guest = guestDAO.getGuestByNic(guestNic);
        
        if (guest == null) {
            request.setAttribute("error", "Guest not found. Please register first.");
            showGuestLookup(request, response);
            return;
        }
        
        request.setAttribute("guest", guest);
        request.getRequestDispatcher("/add-reservation-step2.jsp").forward(request, response);
    }
    
    // Step 3: Show available rooms
    private void showRoomSelection(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String guestNic = request.getParameter("guestNic");
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        String roomType = request.getParameter("roomType");
        
        Guest guest = guestDAO.getGuestByNic(guestNic);
        List<Room> availableRooms = reservationDAO.getAvailableRooms(checkIn, checkOut, roomType);
        
        request.setAttribute("guest", guest);
        request.setAttribute("checkIn", checkIn);
        request.setAttribute("checkOut", checkOut);
        request.setAttribute("roomType", roomType);
        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("numNights", calculateNights(checkIn, checkOut));
        
        request.getRequestDispatcher("/add-reservation-step3.jsp").forward(request, response);
    }
    
    // AJAX: Check guest
    private void handleGuestCheck(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String nic = request.getParameter("nic");
        Guest guest = guestDAO.getGuestByNic(nic);
        
        response.setContentType("application/json");
        if (guest != null) {
            response.getWriter().write(String.format(
                "{\"found\":true,\"nic\":\"%s\",\"name\":\"%s\",\"phone\":\"%s\"}",
                guest.getNic(), guest.getFullName(), guest.getPhone()
            ));
        } else {
            response.getWriter().write("{\"found\":false}");
        }
    }
    
    // AJAX: Find rooms
    private void handleFindRooms(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        String roomType = request.getParameter("roomType");
        String guestNic = request.getParameter("guestNic");
        
        // Validate dates
        if (!isValidDateRange(checkIn, checkOut)) {
            request.setAttribute("error", "Check-out date must be after check-in date");
            showDateSelection(request, response);
            return;
        }
        
        // Forward to step 3
        showRoomSelection(request, response);
    }
    
    // Create final reservation
    private void handleCreateReservation(HttpServletRequest request, HttpServletResponse response, HttpSession session) 
            throws ServletException, IOException {
        
        String guestNic = request.getParameter("guestNic");
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        int numGuests = Integer.parseInt(request.getParameter("numGuests"));
        double totalAmount = Double.parseDouble(request.getParameter("totalAmount"));
        String paymentStatus = request.getParameter("paymentStatus");
        String specialRequests = request.getParameter("specialRequests");
        
        // Double-check availability
        if (!reservationDAO.isRoomAvailable(roomId, checkIn, checkOut, null)) {
            request.setAttribute("error", "Room is no longer available for these dates. Please select another room.");
            showRoomSelection(request, response);
            return;
        }
        
        // Create reservation
        Reservation reservation = new Reservation();
        reservation.setGuestNic(guestNic);
        reservation.setRoomId(roomId);
        reservation.setCheckInDate(checkIn);
        reservation.setCheckOutDate(checkOut);
        reservation.setNumGuests(numGuests);
        reservation.setTotalAmount(totalAmount);
        reservation.setPaymentStatus(paymentStatus);
        reservation.setSpecialRequests(specialRequests);
        reservation.setCreatedBy((String) session.getAttribute("fullName"));
        
        boolean success = reservationDAO.createReservation(reservation);
        
        if (success) {
            request.setAttribute("message", "Reservation created successfully! Reservation ID: " + reservation.getReservationId());
            request.setAttribute("messageType", "success");
            request.setAttribute("reservation", reservation);
            
            // Get full details for confirmation page
            Reservation fullRes = reservationDAO.getReservationById(reservation.getReservationId());
            request.setAttribute("reservation", fullRes);
            
            request.getRequestDispatcher("/reservation-confirmation.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to create reservation. Room may have been booked by another user.");
            showRoomSelection(request, response);
        }
    }
    
    private int calculateNights(String checkIn, String checkOut) {
        try {
            java.time.LocalDate start = java.time.LocalDate.parse(checkIn);
            java.time.LocalDate end = java.time.LocalDate.parse(checkOut);
            return (int) java.time.temporal.ChronoUnit.DAYS.between(start, end);
        } catch (Exception e) {
            return 0;
        }
    }
    
    private boolean isValidDateRange(String checkIn, String checkOut) {
        try {
            java.time.LocalDate start = java.time.LocalDate.parse(checkIn);
            java.time.LocalDate end = java.time.LocalDate.parse(checkOut);
            return end.isAfter(start);
        } catch (Exception e) {
            return false;
        }
    }
}