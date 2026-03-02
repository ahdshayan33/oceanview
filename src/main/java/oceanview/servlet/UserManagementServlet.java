package oceanview.servlet;

import oceanview.dao.UserDAO;
import oceanview.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/user-management")
public class UserManagementServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin access
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !currentUser.isAdmin()) {
            request.setAttribute("error", "Access denied");
            request.getRequestDispatcher("/access-denied.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            // Show add user form
            request.getRequestDispatcher("/user-form.jsp").forward(request, response);
            
        } else if ("edit".equals(action)) {
            // Show edit form
            String username = request.getParameter("username");
            User user = userDAO.getUserByUsername(username);
            
            if (user == null) {
                request.setAttribute("error", "User not found");
                listUsers(request, response);
                return;
            }
            
            request.setAttribute("editUser", user);
            request.getRequestDispatcher("/user-form.jsp").forward(request, response);
            
        } else if ("delete".equals(action)) {
            // Delete user
            String username = request.getParameter("username");
            
            // Prevent self-deletion
            if (username.equals(currentUser.getUsername())) {
                request.setAttribute("error", "You cannot delete your own account");
            } else {
                boolean success = userDAO.deleteUser(username);
                if (success) {
                    request.setAttribute("message", "User deleted successfully");
                } else {
                    request.setAttribute("error", "Cannot delete user (may be last admin or has dependencies)");
                }
            }
            listUsers(request, response);
            
        } else {
            // Default: list all users
            listUsers(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // Check admin access
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !currentUser.isAdmin()) {
            request.setAttribute("error", "Access denied");
            request.getRequestDispatcher("/access-denied.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addUser(request, response);
        } else if ("update".equals(action)) {
            updateUser(request, response);
        } else {
            listUsers(request, response);
        }
    }
    
    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/user-management.jsp").forward(request, response);
    }
    
    private void addUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        
        // Validation
        if (username == null || username.trim().isEmpty() || 
            password == null || password.isEmpty() ||
            fullName == null || fullName.trim().isEmpty()) {
            
            request.setAttribute("error", "Username, password, and full name are required");
            request.setAttribute("editMode", false);
            request.getRequestDispatcher("/user-form.jsp").forward(request, response);
            return;
        }
        
        // Check if username exists
        if (userDAO.usernameExists(username)) {
            request.setAttribute("error", "Username '" + username + "' already exists");
            request.setAttribute("editMode", false);
            request.getRequestDispatcher("/user-form.jsp").forward(request, response);
            return;
        }
        
        User newUser = new User(username, password, fullName, email, role);
        
        boolean success = userDAO.addUser(newUser);
        
        if (success) {
            request.setAttribute("message", "User created successfully");
            listUsers(request, response);
        } else {
            request.setAttribute("error", "Failed to create user");
            request.setAttribute("editMode", false);
            request.getRequestDispatcher("/user-form.jsp").forward(request, response);
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        
        User user = new User();
        user.setUsername(username);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setRole(role);
        
        // Only update password if provided
        if (password != null && !password.isEmpty()) {
            user.setPassword(password);
        }
        
        boolean success = userDAO.updateUser(user);
        
        if (success) {
            request.setAttribute("message", "User updated successfully");
        } else {
            request.setAttribute("error", "Failed to update user");
        }
        listUsers(request, response);
    }
}