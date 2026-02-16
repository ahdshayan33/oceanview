package oceanview;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM users WHERE username=? AND password=?"
            );
            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String fullName = rs.getString("full_name");
                HttpSession session = request.getSession();
                session.setAttribute("fullName", fullName);
                response.sendRedirect("dashboard.jsp");
            } else {
            	response.setContentType("text/html"); // Tell browser it’s HTML
            	response.getWriter().println("<html><body style='font-family: Arial, sans-serif; text-align: center; padding-top: 50px;'>");
            	response.getWriter().println("<h3 style='color:red;'>Invalid Username or Password</h3>");
            	response.getWriter().println("<a href='index.jsp' style='color:blue; text-decoration:underline;'>Try Again</a>");
            	response.getWriter().println("</body></html>");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}