package oceanview.servlet;

import oceanview.dao.RoomDAO;
import oceanview.model.Room;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/room-status")
public class RoomStatusServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        roomDAO = new RoomDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check login - uses "fullName" to match your LoginServlet
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("fullName") == null) {
            // FIXED: Redirect to index.jsp (your login page)
            response.sendRedirect("index.jsp");
            return;
        }
        
        // Fetch data from database
        Map<Integer, List<Room>> roomsByFloor = roomDAO.getRoomsGroupedByFloor();
        
        // Set attribute for JSP
        request.setAttribute("roomsByFloor", roomsByFloor);
        
        // Forward to JSP (must use forward, not redirect)
        request.getRequestDispatcher("/room-status.jsp").forward(request, response);
    }
}