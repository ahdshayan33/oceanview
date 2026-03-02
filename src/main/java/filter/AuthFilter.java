package filter;

import oceanview.model.User;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {
    
    // Pages that don't require login
	private static final String[] PUBLIC_PATHS = {
		    "/index.jsp", "/login", "/css/", "/js/", "/images/", "/assets/",
		    "/setup-admin",  // <-- ADD THIS (temporary)
		    "/setup-admin.jsp" // <-- ADD THIS if using JSP version
		};
    
    // Pages that require ADMIN role
    private static final String[] ADMIN_PATHS = {
        "/user-management", "/admin-", "/create-user", "/delete-user"
    };
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        
        // ADD THIS DEBUG
        System.out.println("=== AUTH FILTER ===");
        System.out.println("Path: " + path);
        System.out.println("Method: " + httpRequest.getMethod());
        System.out.println("Is public: " + isPublicPath(path));
        
        // Allow public paths
        if (isPublicPath(path)) {
            System.out.println("ALLOWING public path");
            chain.doFilter(request, response);
            return;
        }
        
        // Check session
        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            // Not logged in, redirect to login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
            return;
        }
        
        // Check admin-only paths
        if (isAdminPath(path) && !user.isAdmin()) {
            // Receptionist trying to access admin page
            httpRequest.setAttribute("error", "Access denied. Admin privileges required.");
            httpRequest.getRequestDispatcher("/access-denied.jsp").forward(request, response);
            return;
        }
        
        // User is authenticated and authorized
        chain.doFilter(request, response);
    }
    
    private boolean isPublicPath(String path) {
        for (String publicPath : PUBLIC_PATHS) {
            if (path.startsWith(publicPath)) {
                return true;
            }
        }
        return false;
    }
    
    private boolean isAdminPath(String path) {
        for (String adminPath : ADMIN_PATHS) {
            if (path.contains(adminPath)) {
                return true;
            }
        }
        return false;
    }
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}
    
    @Override
    public void destroy() {}
}