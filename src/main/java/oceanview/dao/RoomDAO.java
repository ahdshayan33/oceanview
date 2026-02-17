package oceanview.dao;

import oceanview.DBConnection;
import oceanview.model.Room;
import java.sql.*;
import java.util.*;

public class RoomDAO {
    
    // Get all rooms with reservation details
    public List<Room> getAllRoomsWithReservations() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, res.reservation_id, res.guest_name, " +
                     "res.check_in_date, res.check_out_date " +
                     "FROM rooms r " +
                     "LEFT JOIN reservations res ON r.room_id = res.room_id " +
                     "AND res.status = 'ACTIVE' " +
                     "AND CURDATE() BETWEEN res.check_in_date AND res.check_out_date " +
                     "ORDER BY r.floor_number, r.room_number";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setFloorNumber(rs.getInt("floor_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setBasePrice(rs.getDouble("base_price"));
                room.setStatus(rs.getString("status"));
                
                // Set reservation details if room is occupied
                int resId = rs.getInt("reservation_id");
                if (!rs.wasNull()) {
                    room.setReservationId(resId);
                    room.setGuestName(rs.getString("guest_name"));
                    room.setCheckInDate(rs.getString("check_in_date"));
                    room.setCheckOutDate(rs.getString("check_out_date"));
                }
                
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;  // <-- THIS WAS MISSING
    }
    
    // Get rooms grouped by floor
    public Map<Integer, List<Room>> getRoomsGroupedByFloor() {
        List<Room> allRooms = getAllRoomsWithReservations();
        Map<Integer, List<Room>> floorMap = new TreeMap<>();
        
        for (Room room : allRooms) {
            floorMap.computeIfAbsent(room.getFloorNumber(), k -> new ArrayList<>()).add(room);
        }
        
        return floorMap;  // <-- THIS WAS MISSING
    }
    
    // ========== NEW CRUD METHODS ==========
    
    // Get single room by ID
    public Room getRoomById(int roomId) {
        Room room = null;
        String sql = "SELECT * FROM rooms WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setFloorNumber(rs.getInt("floor_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setBasePrice(rs.getDouble("base_price"));
                room.setStatus(rs.getString("status"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return room;
    }
    
    // Add new room
    public boolean addRoom(Room room) {
        String sql = "INSERT INTO rooms (room_number, floor_number, room_type, base_price, status) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, room.getRoomNumber());
            stmt.setInt(2, room.getFloorNumber());
            stmt.setString(3, room.getRoomType());
            stmt.setDouble(4, room.getBasePrice());
            stmt.setString(5, room.getStatus());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Update room
    public boolean updateRoom(Room room) {
        String sql = "UPDATE rooms SET room_number=?, floor_number=?, room_type=?, base_price=?, status=? WHERE room_id=?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, room.getRoomNumber());
            stmt.setInt(2, room.getFloorNumber());
            stmt.setString(3, room.getRoomType());
            stmt.setDouble(4, room.getBasePrice());
            stmt.setString(5, room.getStatus());
            stmt.setInt(6, room.getRoomId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete room (only if not occupied)
    public boolean deleteRoom(int roomId) {
        // First check if room is occupied
        String checkSql = "SELECT status FROM rooms WHERE room_id = ?";
        String deleteSql = "DELETE FROM rooms WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setInt(1, roomId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                String status = rs.getString("status");
                if ("OCCUPIED".equals(status)) {
                    return false; // Cannot delete occupied room
                }
            }
            
            // Proceed with delete
            try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                deleteStmt.setInt(1, roomId);
                int affectedRows = deleteStmt.executeUpdate();
                return affectedRows > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Check if room number already exists
    public boolean roomNumberExists(String roomNumber, Integer excludeRoomId) {
        String sql = "SELECT room_id FROM rooms WHERE room_number = ?";
        if (excludeRoomId != null) {
            sql += " AND room_id != ?";
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, roomNumber);
            if (excludeRoomId != null) {
                stmt.setInt(2, excludeRoomId);
            }
            
            ResultSet rs = stmt.executeQuery();
            return rs.next();
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}