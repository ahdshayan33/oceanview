package oceanview.model;

public class User {
    // private int userId;  // REMOVE THIS - username is PK
    
    private String username;  // This is now the primary key
    private String password;
    private String fullName;
    private String email;
    private String role;
    
    // Constructors
    public User() {}
    
    public User(String username, String password, String fullName, String email, String role) {
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
    }
    
    // Getters and Setters
    // REMOVE: getUserId() and setUserId()
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    // Helper methods
    public boolean isAdmin() {
        return "ADMIN".equals(role);
    }
    
    public boolean isReceptionist() {
        return "RECEPTIONIST".equals(role);
    }
}