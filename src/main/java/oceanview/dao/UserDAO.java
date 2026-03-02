package oceanview.dao;

import oceanview.DBConnection;
import oceanview.model.User;
import oceanview.util.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    
    // Authenticate user with hashed password
    public User authenticate(String username, String plainPassword) {
        User user = getUserByUsername(username);
        
        if (user != null) {
            String storedHash = user.getPassword();
            
            // Check if password is hashed (starts with $2a$)
            if (storedHash != null && storedHash.startsWith("$2a$")) {
                // Hashed password - use BCrypt
                if (PasswordUtil.checkPassword(plainPassword, storedHash)) {
                    return user;
                }
            } else {
                // Plain text password (temporary support)
                if (plainPassword.equals(storedHash)) {
                    return user;
                }
            }
        }
        return null;
    }
    
    // Get user by username (username is PK)
    public User getUserByUsername(String username) {
        // Use specific columns, no user_id
        String sql = "SELECT username, password, full_name, email, role " +
                     "FROM users WHERE username = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                // No userId to set
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                return user;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get all users
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        // No user_id in query
        String sql = "SELECT username, password, full_name, email, role " +
                     "FROM users ORDER BY role, full_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                User user = new User();
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                users.add(user);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Add new user (username is PK, no auto-increment)
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, password, full_name, email, role) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String hashedPassword = PasswordUtil.hashPassword(user.getPassword());
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, hashedPassword);
            stmt.setString(3, user.getFullName());
            stmt.setString(4, user.getEmail());
            stmt.setString(5, user.getRole());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Update user (username cannot change - it's PK)
    public boolean updateUser(User user) {
        String sql;
        boolean updatePassword = user.getPassword() != null && !user.getPassword().isEmpty();
        
        if (updatePassword) {
            sql = "UPDATE users SET full_name=?, email=?, role=?, password=? WHERE username=?";
        } else {
            sql = "UPDATE users SET full_name=?, email=?, role=? WHERE username=?";
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getRole());
            
            if (updatePassword) {
                // Check if already hashed
                String pwd = user.getPassword();
                if (!pwd.startsWith("$2a$")) {
                    pwd = PasswordUtil.hashPassword(pwd);
                }
                stmt.setString(4, pwd);
                stmt.setString(5, user.getUsername());
            } else {
                stmt.setString(4, user.getUsername());
            }
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete user
    public boolean deleteUser(String username) {
        // Prevent deleting last admin
        if (isLastAdmin(username)) {
            return false;
        }
        
        String sql = "DELETE FROM users WHERE username = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Check if username exists
    public boolean usernameExists(String username) {
        return getUserByUsername(username) != null;
    }
    
    // Check if this is the last admin
    private boolean isLastAdmin(String username) {
        String sql = "SELECT COUNT(*) as count FROM users WHERE role = 'ADMIN' AND username != ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") == 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}