package oceanview.servlet;

import oceanview.dao.ReservationDAO;
import oceanview.model.Reservation;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/view-reservations")
public class ViewReservationsServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private ReservationDAO reservationDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
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
        
        // Get filter parameters
        String status = request.getParameter("status");
        String search = request.getParameter("search");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        
        List<Reservation> reservations;
        
        // Check if any filter is applied
        boolean hasFilter = (search != null && !search.trim().isEmpty()) || 
                           (status != null && !status.isEmpty()) ||
                           (dateFrom != null && !dateFrom.isEmpty()) ||
                           (dateTo != null && !dateTo.isEmpty());
        
        if (hasFilter) {
            reservations = reservationDAO.searchReservations(search, status, dateFrom, dateTo);
        } else {
            reservations = reservationDAO.getAllReservations();
        }
        
        request.setAttribute("reservations", reservations);
        request.setAttribute("statusFilter", status);
        request.setAttribute("searchQuery", search);
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("resultCount", reservations.size());
        
        request.getRequestDispatcher("/view-reservations.jsp").forward(request, response);
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
        
        if ("cancel".equals(action)) {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success = reservationDAO.cancelReservation(reservationId);
            
            if (success) {
                request.setAttribute("message", "Reservation cancelled successfully");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Failed to cancel reservation");
                request.setAttribute("messageType", "error");
            }
        }
        
        // Refresh the list
        doGet(request, response);
    }
}