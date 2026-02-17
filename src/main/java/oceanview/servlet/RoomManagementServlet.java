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

@WebServlet("/room-management")
public class RoomManagementServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
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
        
        String action = request.getParameter("action");
        System.out.println("RoomManagementServlet GET action: " + action); // DEBUG
        
        if ("add".equals(action)) {
            // Show ADD form - NEW ROOM (no editMode, room is null)
            System.out.println("Forwarding to room-form.jsp for ADD"); // DEBUG
            request.setAttribute("editMode", false);  // Explicitly set to false
            request.setAttribute("room", null);         // No room data
            request.getRequestDispatcher("/room-form.jsp").forward(request, response);
            
        } else if ("edit".equals(action)) {
            // Show EDIT form
            try {
                int roomId = Integer.parseInt(request.getParameter("id"));
                Room room = roomDAO.getRoomById(roomId);
                
                if (room == null) {
                    request.setAttribute("message", "Room not found");
                    request.setAttribute("messageType", "error");
                    // Back to list
                    Map<Integer, List<Room>> roomsByFloor = roomDAO.getRoomsGroupedByFloor();
                    request.setAttribute("roomsByFloor", roomsByFloor);
                    request.setAttribute("managementMode", true);
                    request.getRequestDispatcher("/room-status.jsp").forward(request, response);
                    return;
                }
                
                request.setAttribute("editMode", true);
                request.setAttribute("room", room);
                request.getRequestDispatcher("/room-form.jsp").forward(request, response);
                
            } catch (NumberFormatException e) {
                request.setAttribute("message", "Invalid room ID");
                request.setAttribute("messageType", "error");
                Map<Integer, List<Room>> roomsByFloor = roomDAO.getRoomsGroupedByFloor();
                request.setAttribute("roomsByFloor", roomsByFloor);
                request.setAttribute("managementMode", true);
                request.getRequestDispatcher("/room-status.jsp").forward(request, response);
            }
            
        } else if ("delete".equals(action)) {
            // Delete room
            try {
                int roomId = Integer.parseInt(request.getParameter("id"));
                boolean success = roomDAO.deleteRoom(roomId);
                
                if (success) {
                    request.setAttribute("message", "Room deleted successfully");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "Cannot delete occupied room");
                    request.setAttribute("messageType", "error");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("message", "Invalid room ID");
                request.setAttribute("messageType", "error");
            }
            
            // Refresh list
            Map<Integer, List<Room>> roomsByFloor = roomDAO.getRoomsGroupedByFloor();
            request.setAttribute("roomsByFloor", roomsByFloor);
            request.setAttribute("managementMode", true);
            request.getRequestDispatcher("/room-status.jsp").forward(request, response);
            
        } else {
            // Default: show room list with management options
            Map<Integer, List<Room>> roomsByFloor = roomDAO.getRoomsGroupedByFloor();
            request.setAttribute("roomsByFloor", roomsByFloor);
            request.setAttribute("managementMode", true);
            request.getRequestDispatcher("/room-status.jsp").forward(request, response);
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
        System.out.println("RoomManagementServlet POST action: " + action); // DEBUG
        
        // Get form parameters
        String roomNumber = request.getParameter("roomNumber");
        String floorNumberStr = request.getParameter("floorNumber");
        String roomType = request.getParameter("roomType");
        String basePriceStr = request.getParameter("basePrice");
        String status = request.getParameter("status");
        
        // Validate inputs
        if (roomNumber == null || roomNumber.trim().isEmpty() ||
            floorNumberStr == null || basePriceStr == null ||
            roomType == null || status == null) {
            
            request.setAttribute("message", "All fields are required");
            request.setAttribute("messageType", "error");
            request.setAttribute("editMode", "update".equals(action));
            request.getRequestDispatcher("/room-form.jsp").forward(request, response);
            return;
        }
        
        try {
            int floorNumber = Integer.parseInt(floorNumberStr);
            double basePrice = Double.parseDouble(basePriceStr);
            
            Room room = new Room();
            room.setRoomNumber(roomNumber.trim());
            room.setFloorNumber(floorNumber);
            room.setRoomType(roomType);
            room.setBasePrice(basePrice);
            room.setStatus(status);
            
            boolean success = false;
            String message = "";
            
            if ("add".equals(action)) {
                // ADD NEW ROOM
                if (roomDAO.roomNumberExists(roomNumber, null)) {
                    message = "Room number '" + roomNumber + "' already exists";
                    request.setAttribute("messageType", "error");
                    request.setAttribute("editMode", false);
                    request.setAttribute("room", room); // Keep form data
                    request.getRequestDispatcher("/room-form.jsp").forward(request, response);
                    return;
                }
                
                success = roomDAO.addRoom(room);
                message = success ? "Room added successfully!" : "Failed to add room";
                request.setAttribute("messageType", success ? "success" : "error");
                
            } else if ("update".equals(action)) {
                // UPDATE EXISTING ROOM
                String roomIdStr = request.getParameter("roomId");
                if (roomIdStr == null) {
                    message = "Room ID is missing";
                    request.setAttribute("messageType", "error");
                    request.setAttribute("editMode", true);
                    request.getRequestDispatcher("/room-form.jsp").forward(request, response);
                    return;
                }
                
                int roomId = Integer.parseInt(roomIdStr);
                room.setRoomId(roomId);
                
                if (roomDAO.roomNumberExists(roomNumber, roomId)) {
                    message = "Room number '" + roomNumber + "' already exists";
                    request.setAttribute("messageType", "error");
                    request.setAttribute("editMode", true);
                    request.setAttribute("room", room);
                    request.getRequestDispatcher("/room-form.jsp").forward(request, response);
                    return;
                }
                
                success = roomDAO.updateRoom(room);
                message = success ? "Room updated successfully!" : "Failed to update room";
                request.setAttribute("messageType", success ? "success" : "error");
            }
            
            // After successful add/update, go back to room list
            request.setAttribute("message", message);
            Map<Integer, List<Room>> roomsByFloor = roomDAO.getRoomsGroupedByFloor();
            request.setAttribute("roomsByFloor", roomsByFloor);
            request.setAttribute("managementMode", true);
            request.getRequestDispatcher("/room-status.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid number format");
            request.setAttribute("messageType", "error");
            request.setAttribute("editMode", "update".equals(action));
            request.getRequestDispatcher("/room-form.jsp").forward(request, response);
        }
    }
}