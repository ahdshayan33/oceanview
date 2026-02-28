package oceanview.dao;

import oceanview.DBConnection;
import oceanview.model.Guest;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GuestDAO {
    
    // Check if guest exists by NIC
    public Guest getGuestByNic(String nic) {
        Guest guest = null;
        String sql = "SELECT * FROM guests WHERE nic = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nic);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                guest = extractGuestFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return guest;
    }
    
    // Get all guests
    public List<Guest> getAllGuests() {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                guests.add(extractGuestFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return guests;
    }
    
    // Search guests by name or NIC
    public List<Guest> searchGuests(String searchTerm) {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests WHERE nic LIKE ? OR full_name LIKE ? OR phone LIKE ? ORDER BY full_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + searchTerm + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                guests.add(extractGuestFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return guests;
    }
    
    // Add new guest
    public boolean addGuest(Guest guest) {
        String sql = "INSERT INTO guests (nic, full_name, email, phone, address, nationality, " +
                     "date_of_birth, gender, emergency_contact_name, emergency_contact_phone) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, guest.getNic());
            stmt.setString(2, guest.getFullName());
            stmt.setString(3, guest.getEmail());
            stmt.setString(4, guest.getPhone());
            stmt.setString(5, guest.getAddress());
            stmt.setString(6, guest.getNationality());
            stmt.setString(7, guest.getDateOfBirth());
            stmt.setString(8, guest.getGender());
            stmt.setString(9, guest.getEmergencyContactName());
            stmt.setString(10, guest.getEmergencyContactPhone());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Update guest
    public boolean updateGuest(Guest guest) {
        String sql = "UPDATE guests SET full_name=?, email=?, phone=?, address=?, nationality=?, " +
                     "date_of_birth=?, gender=?, emergency_contact_name=?, emergency_contact_phone=? " +
                     "WHERE nic=?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, guest.getFullName());
            stmt.setString(2, guest.getEmail());
            stmt.setString(3, guest.getPhone());
            stmt.setString(4, guest.getAddress());
            stmt.setString(5, guest.getNationality());
            stmt.setString(6, guest.getDateOfBirth());
            stmt.setString(7, guest.getGender());
            stmt.setString(8, guest.getEmergencyContactName());
            stmt.setString(9, guest.getEmergencyContactPhone());
            stmt.setString(10, guest.getNic());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete guest (only if no active reservations)
    public boolean deleteGuest(String nic) {
        // First check for active reservations
        String checkSql = "SELECT COUNT(*) FROM reservations r JOIN guests g ON r.guest_nic = g.nic " +
                         "WHERE g.nic = ? AND r.status = 'ACTIVE'";
        String deleteSql = "DELETE FROM guests WHERE nic = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setString(1, nic);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                return false; // Has active reservations
            }
            
            // Safe to delete
            try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                deleteStmt.setString(1, nic);
                return deleteStmt.executeUpdate() > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Check if NIC already exists
    public boolean nicExists(String nic) {
        String sql = "SELECT nic FROM guests WHERE nic = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nic);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Helper method to extract Guest from ResultSet
    private Guest extractGuestFromResultSet(ResultSet rs) throws SQLException {
        Guest guest = new Guest();
        guest.setNic(rs.getString("nic"));
        guest.setFullName(rs.getString("full_name"));
        guest.setEmail(rs.getString("email"));
        guest.setPhone(rs.getString("phone"));
        guest.setAddress(rs.getString("address"));
        guest.setNationality(rs.getString("nationality"));
        guest.setDateOfBirth(rs.getString("date_of_birth"));
        guest.setGender(rs.getString("gender"));
        guest.setEmergencyContactName(rs.getString("emergency_contact_name"));
        guest.setEmergencyContactPhone(rs.getString("emergency_contact_phone"));
        guest.setCreatedAt(rs.getTimestamp("created_at"));
        guest.setUpdatedAt(rs.getTimestamp("updated_at"));
        return guest;
    }
}