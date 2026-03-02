package oceanview.servlet;

import oceanview.dao.UserDAO;
import oceanview.model.User;
import oceanview.util.PasswordUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/setup-admin")
public class SetupServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><body>");
        out.println("<h2>Admin Setup</h2>");
        
        UserDAO userDAO = new UserDAO();
        
        // Check if admin exists
        User admin = userDAO.getUserByUsername("admin");
        
        if (admin == null) {
            out.println("<p style='color:red;'>Admin user not found!</p>");
            out.println("<p>Creating new admin user...</p>");
            
            // Create admin
            User newAdmin = new User();
            newAdmin.setUsername("admin");
            newAdmin.setPassword("admin123");  // Will be hashed
            newAdmin.setFullName("System Administrator");
            newAdmin.setEmail("admin@oceanview.lk");
            newAdmin.setRole("ADMIN");
            
            boolean created = userDAO.addUser(newAdmin);
            
            if (created) {
                out.println("<p style='color:green;'>✅ Admin created successfully!</p>");
                out.println("<p>Username: admin</p>");
                out.println("<p>Password: admin123</p>");
            } else {
                out.println("<p style='color:red;'>❌ Failed to create admin</p>");
            }
            
        } else {
            out.println("<p>Found admin: " + admin.getFullName() + "</p>");
            out.println("<p>Current role: " + admin.getRole() + "</p>");
            out.println("<p>Password starts with: " + 
                (admin.getPassword() != null ? admin.getPassword().substring(0, Math.min(10, admin.getPassword().length())) : "NULL") + 
                "</p>");
            
            // Check if password needs hashing
            if (admin.getPassword() == null || !admin.getPassword().startsWith("$2a$")) {
                out.println("<p>Password needs hashing...</p>");
                
                // Get current plain password or use default
                String currentPwd = admin.getPassword();
                if (currentPwd == null || currentPwd.isEmpty()) {
                    currentPwd = "admin123";
                }
                
                String hashed = PasswordUtil.hashPassword(currentPwd);
                
                admin.setPassword(hashed);
                admin.setRole("ADMIN");
                
                boolean updated = userDAO.updateUser(admin);
                
                if (updated) {
                    out.println("<p style='color:green;'>✅ Password hashed successfully!</p>");
                    out.println("<p>New hash: " + hashed.substring(0, 20) + "...</p>");
                } else {
                    out.println("<p style='color:red;'>❌ Failed to update password</p>");
                }
            } else {
                out.println("<p style='color:green;'>✅ Password already hashed</p>");
            }
        }
        
        out.println("<hr><p><a href='index.jsp'>Go to Login</a></p>");
        out.println("</body></html>");
    }
}