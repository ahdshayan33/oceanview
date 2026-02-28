package oceanview.dao;

import oceanview.DBConnection;
import oceanview.model.Reservation;
import oceanview.model.Guest;
import oceanview.model.Room;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {
    
    // Check if room is available for given dates
    public boolean isRoomAvailable(int roomId, String checkInDate, String checkOutDate, Integer excludeReservationId) {
        String sql = "SELECT COUNT(*) FROM reservations_new " +
                     "WHERE room_id = ? AND status IN ('CONFIRMED', 'CHECKED_IN') " +
                     "AND NOT (check_out_date <= ? OR check_in_date >= ?)";
        
        if (excludeReservationId != null) {
            sql += " AND reservation_id != ?";
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roomId);
            stmt.setString(2, checkInDate);
            stmt.setString(3, checkOutDate);
            
            if (excludeReservationId != null) {
                stmt.setInt(4, excludeReservationId);
            }
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) == 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get available rooms for date range
    public List<Room> getAvailableRooms(String checkInDate, String checkOutDate, String roomType) {
        List<Room> rooms = new ArrayList<>();
        
        String sql = "SELECT r.* FROM rooms r " +
                     "WHERE r.room_id NOT IN (" +
                     "    SELECT room_id FROM reservations_new " +
                     "    WHERE status IN ('CONFIRMED', 'CHECKED_IN') " +
                     "    AND NOT (check_out_date <= ? OR check_in_date >= ?)" +
                     ")";
        
        if (roomType != null && !roomType.isEmpty() && !"ALL".equalsIgnoreCase(roomType)) {
            sql += " AND r.room_type = ?";
        }
        
        sql += " AND r.status != 'MAINTENANCE' AND r.status != 'OUT_OF_ORDER'";
        sql += " ORDER BY r.floor_number, r.room_number";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, checkInDate);
            stmt.setString(2, checkOutDate);
            
            if (roomType != null && !roomType.isEmpty() && !"ALL".equalsIgnoreCase(roomType)) {
                stmt.setString(3, roomType);
            }
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setFloorNumber(rs.getInt("floor_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setBasePrice(rs.getDouble("base_price"));
                room.setStatus(rs.getString("status"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }
    
    // Create reservation
    public boolean createReservation(Reservation reservation) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Check room availability again
            if (!isRoomAvailable(reservation.getRoomId(), 
                                reservation.getCheckInDate(), 
                                reservation.getCheckOutDate(), 
                                null)) {
                return false;
            }
            
            // Insert reservation
            String insertSql = "INSERT INTO reservations_new (guest_nic, room_id, check_in_date, " +
                              "check_out_date, num_guests, total_amount, status, payment_status, " +
                              "special_requests, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement stmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, reservation.getGuestNic());
                stmt.setInt(2, reservation.getRoomId());
                stmt.setString(3, reservation.getCheckInDate());
                stmt.setString(4, reservation.getCheckOutDate());
                stmt.setInt(5, reservation.getNumGuests());
                stmt.setDouble(6, reservation.getTotalAmount());
                stmt.setString(7, "CONFIRMED");
                stmt.setString(8, reservation.getPaymentStatus());
                stmt.setString(9, reservation.getSpecialRequests());
                stmt.setString(10, reservation.getCreatedBy());
                
                int affectedRows = stmt.executeUpdate();
                
                if (affectedRows == 0) {
                    conn.rollback();
                    return false;
                }
                
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    reservation.setReservationId(generatedKeys.getInt(1));
                }
            }
            
            // Update room status only if check-in is today
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate checkIn = java.time.LocalDate.parse(reservation.getCheckInDate());
            
            if (!checkIn.isAfter(today)) {
                String updateRoomSql = "UPDATE rooms SET status = 'OCCUPIED' WHERE room_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateRoomSql)) {
                    stmt.setInt(1, reservation.getRoomId());
                    stmt.executeUpdate();
                }
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    // ==================== VIEW RESERVATIONS METHODS ====================
    
    // Get all reservations with guest and room details
    public List<Reservation> getAllReservations() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.full_name, g.phone, g.email, rm.room_number, rm.room_type, rm.floor_number " +
                     "FROM reservations_new r " +
                     "JOIN guests g ON r.guest_nic = g.nic " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "ORDER BY r.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(extractReservationWithDetails(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Search reservations with filters
    public List<Reservation> searchReservations(String search, String status, String dateFrom, String dateTo) {
        List<Reservation> reservations = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, g.full_name, g.phone, g.email, rm.room_number, rm.room_type, rm.floor_number " +
            "FROM reservations_new r " +
            "JOIN guests g ON r.guest_nic = g.nic " +
            "JOIN rooms rm ON r.room_id = rm.room_id WHERE 1=1 "
        );
        
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (g.full_name LIKE ? OR g.nic LIKE ? OR rm.room_number LIKE ? OR r.reservation_id LIKE ?) ");
            String searchPattern = "%" + search + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.status = ? ");
            params.add(status);
        }
        
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append("AND r.check_in_date >= ? ");
            params.add(dateFrom);
        }
        
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append("AND r.check_out_date <= ? ");
            params.add(dateTo);
        }
        
        sql.append("ORDER BY r.created_at DESC");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                reservations.add(extractReservationWithDetails(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get single reservation by ID with full details
    public Reservation getReservationById(int reservationId) {
        String sql = "SELECT r.*, g.full_name, g.phone, g.email, g.address, " +
                     "rm.room_number, rm.room_type, rm.floor_number, rm.base_price " +
                     "FROM reservations_new r " +
                     "JOIN guests g ON r.guest_nic = g.nic " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "WHERE r.reservation_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, reservationId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return extractReservationWithDetails(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Cancel reservation
    public boolean cancelReservation(int reservationId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get room ID
            String getRoomSql = "SELECT room_id FROM reservations_new WHERE reservation_id = ?";
            int roomId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(getRoomSql)) {
                stmt.setInt(1, reservationId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    roomId = rs.getInt("room_id");
                }
            }
            
            // Update reservation status
            String updateResSql = "UPDATE reservations_new SET status = 'CANCELLED' WHERE reservation_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateResSql)) {
                stmt.setInt(1, reservationId);
                stmt.executeUpdate();
            }
            
            // Free up the room
            String updateRoomSql = "UPDATE rooms SET status = 'VACANT' WHERE room_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateRoomSql)) {
                stmt.setInt(1, roomId);
                stmt.executeUpdate();
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    // ==================== EXISTING METHODS ====================
    
    // Get all active reservations (for dashboard)
    public List<Reservation> getActiveReservations() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.full_name, g.phone, rm.room_number, rm.room_type " +
                     "FROM reservations_new r " +
                     "JOIN guests g ON r.guest_nic = g.nic " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "WHERE r.status IN ('CONFIRMED', 'CHECKED_IN') " +
                     "ORDER BY r.check_in_date";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Reservation res = new Reservation();
                res.setReservationId(rs.getInt("reservation_id"));
                res.setGuestNic(rs.getString("guest_nic"));
                res.setRoomId(rs.getInt("room_id"));
                res.setCheckInDate(rs.getString("check_in_date"));
                res.setCheckOutDate(rs.getString("check_out_date"));
                res.setStatus(rs.getString("status"));
                res.setPaymentStatus(rs.getString("payment_status"));
                
                Guest guest = new Guest();
                guest.setNic(res.getGuestNic());
                guest.setFullName(rs.getString("full_name"));
                guest.setPhone(rs.getString("phone"));
                res.setGuest(guest);
                
                Room room = new Room();
                room.setRoomId(res.getRoomId());
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomType(rs.getString("room_type"));
                res.setRoom(room);
                
                reservations.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Check-out guest and update room status
    public boolean checkOut(int reservationId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            String getRoomSql = "SELECT room_id FROM reservations_new WHERE reservation_id = ?";
            int roomId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(getRoomSql)) {
                stmt.setInt(1, reservationId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    roomId = rs.getInt("room_id");
                }
            }
            
            String updateResSql = "UPDATE reservations_new SET status = 'CHECKED_OUT' WHERE reservation_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateResSql)) {
                stmt.setInt(1, reservationId);
                stmt.executeUpdate();
            }
            
            String updateRoomSql = "UPDATE rooms SET status = 'CLEANING' WHERE room_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateRoomSql)) {
                stmt.setInt(1, roomId);
                stmt.executeUpdate();
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    // ==================== HELPER METHODS ====================
    
    // Helper method to extract reservation with guest and room details
    private Reservation extractReservationWithDetails(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setReservationId(rs.getInt("reservation_id"));
        reservation.setGuestNic(rs.getString("guest_nic"));
        reservation.setRoomId(rs.getInt("room_id"));
        reservation.setCheckInDate(rs.getString("check_in_date"));
        reservation.setCheckOutDate(rs.getString("check_out_date"));
        reservation.setNumGuests(rs.getInt("num_guests"));
        reservation.setTotalAmount(rs.getDouble("total_amount"));
        reservation.setStatus(rs.getString("status"));
        reservation.setPaymentStatus(rs.getString("payment_status"));
        reservation.setSpecialRequests(rs.getString("special_requests"));
        reservation.setCreatedBy(rs.getString("created_by"));
        reservation.setCreatedAt(rs.getTimestamp("created_at"));
        reservation.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Populate guest
        Guest guest = new Guest();
        guest.setNic(reservation.getGuestNic());
        guest.setFullName(rs.getString("full_name"));
        guest.setPhone(rs.getString("phone"));
        guest.setEmail(rs.getString("email"));
        try {
            guest.setAddress(rs.getString("address"));
        } catch (SQLException e) {
            // Column might not exist in all queries
        }
        reservation.setGuest(guest);
        
        // Populate room
        Room room = new Room();
        room.setRoomId(reservation.getRoomId());
        room.setRoomNumber(rs.getString("room_number"));
        room.setRoomType(rs.getString("room_type"));
        room.setFloorNumber(rs.getInt("floor_number"));
        try {
            room.setBasePrice(rs.getDouble("base_price"));
        } catch (SQLException e) {
            // Column might not exist in all queries
        }
        reservation.setRoom(room);
        
        return reservation;
    }
}