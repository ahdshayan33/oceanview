package oceanview.servlet;

import oceanview.dao.GuestDAO;
import oceanview.model.Guest;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/guest-management")
public class GuestManagementServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private GuestDAO guestDAO;
    
    @Override
    public void init() throws ServletException {
        guestDAO = new GuestDAO();
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
        
        String action = request.getParameter("action");
        
        if ("check".equals(action)) {
            // AJAX check for guest by NIC
            String nic = request.getParameter("nic");
            Guest guest = guestDAO.getGuestByNic(nic);
            
            response.setContentType("application/json");
            if (guest != null) {
                response.getWriter().write("{\"found\":true,\"name\":\"" + guest.getFullName() + "\"}");
            } else {
                response.getWriter().write("{\"found\":false}");
            }
            return;
            
        } else if ("add".equals(action)) {
            // Show add form
            request.setAttribute("editMode", false);
            request.getRequestDispatcher("/guest-form.jsp").forward(request, response);
            
        } else if ("edit".equals(action)) {
            // Show edit form
            String nic = request.getParameter("nic");
            Guest guest = guestDAO.getGuestByNic(nic);
            
            if (guest == null) {
                request.setAttribute("message", "Guest not found");
                request.setAttribute("messageType", "error");
                showGuestList(request, response);
                return;
            }
            
            request.setAttribute("editMode", true);
            request.setAttribute("guest", guest);
            request.getRequestDispatcher("/guest-form.jsp").forward(request, response);
            
        } else if ("delete".equals(action)) {
            // Delete guest
            String nic = request.getParameter("nic");
            boolean success = guestDAO.deleteGuest(nic);
            
            if (success) {
                request.setAttribute("message", "Guest deleted successfully");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Cannot delete guest with active reservations");
                request.setAttribute("messageType", "error");
            }
            showGuestList(request, response);
            
        } else if ("search".equals(action)) {
            // Search guests
            String searchTerm = request.getParameter("searchTerm");
            List<Guest> guests = guestDAO.searchGuests(searchTerm);
            request.setAttribute("guests", guests);
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("searchMode", true);
            request.getRequestDispatcher("/guest-management.jsp").forward(request, response);
            
        } else {
            // Default: show all guests
            showGuestList(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check login
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("fullName") == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        // Get form parameters
        String nic = request.getParameter("nic");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String nationality = request.getParameter("nationality");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String emergencyContactName = request.getParameter("emergencyContactName");
        String emergencyContactPhone = request.getParameter("emergencyContactPhone");
        
        // Validate required fields
        if (nic == null || nic.trim().isEmpty() || 
            fullName == null || fullName.trim().isEmpty()) {
            
            request.setAttribute("message", "NIC and Full Name are required");
            request.setAttribute("messageType", "error");
            request.setAttribute("editMode", "update".equals(action));
            request.getRequestDispatcher("/guest-form.jsp").forward(request, response);
            return;
        }
        
        Guest guest = new Guest();
        guest.setNic(nic.trim().toUpperCase());
        guest.setFullName(fullName.trim());
        guest.setEmail(email != null ? email.trim() : "");
        guest.setPhone(phone != null ? phone.trim() : "");
        guest.setAddress(address != null ? address.trim() : "");
        guest.setNationality(nationality != null ? nationality.trim() : "");
        guest.setDateOfBirth(dateOfBirth);
        guest.setGender(gender);
        guest.setEmergencyContactName(emergencyContactName != null ? emergencyContactName.trim() : "");
        guest.setEmergencyContactPhone(emergencyContactPhone != null ? emergencyContactPhone.trim() : "");
        
        boolean success = false;
        String message = "";
        
        if ("add".equals(action)) {
            // Add new guest
            if (guestDAO.nicExists(nic.trim())) {
                message = "Guest with NIC '" + nic + "' already exists";
                request.setAttribute("messageType", "error");
                request.setAttribute("editMode", false);
                request.setAttribute("guest", guest);
                request.getRequestDispatcher("/guest-form.jsp").forward(request, response);
                return;
            }
            
            success = guestDAO.addGuest(guest);
            message = success ? "Guest registered successfully!" : "Failed to register guest";
            
        } else if ("update".equals(action)) {
            // Update existing guest
            success = guestDAO.updateGuest(guest);
            message = success ? "Guest updated successfully!" : "Failed to update guest";
        }
        
        request.setAttribute("message", message);
        request.setAttribute("messageType", success ? "success" : "error");
        showGuestList(request, response);
    }
    
    private void showGuestList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Guest> guests = guestDAO.getAllGuests();
        request.setAttribute("guests", guests);
        request.getRequestDispatcher("/guest-management.jsp").forward(request, response);
    }
}