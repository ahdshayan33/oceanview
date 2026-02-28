package oceanview.model;

import java.sql.Timestamp;

public class Reservation {
    private int reservationId;
    private String guestNic;
    private int roomId;
    private String checkInDate;
    private String checkOutDate;
    private int numGuests;
    private double totalAmount;
    private String status;
    private String paymentStatus;
    private String specialRequests;
    private String createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Join fields (populated by DAO)
    private Guest guest;
    private Room room;
    
    // Constructors
    public Reservation() {}
    
    // Getters and Setters
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    
    public String getGuestNic() { return guestNic; }
    public void setGuestNic(String guestNic) { this.guestNic = guestNic; }
    
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    
    public String getCheckInDate() { return checkInDate; }
    public void setCheckInDate(String checkInDate) { this.checkInDate = checkInDate; }
    
    public String getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(String checkOutDate) { this.checkOutDate = checkOutDate; }
    
    public int getNumGuests() { return numGuests; }
    public void setNumGuests(int numGuests) { this.numGuests = numGuests; }
    
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    
    public String getSpecialRequests() { return specialRequests; }
    public void setSpecialRequests(String specialRequests) { this.specialRequests = specialRequests; }
    
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public Guest getGuest() { return guest; }
    public void setGuest(Guest guest) { this.guest = guest; }
    
    public Room getRoom() { return room; }
    public void setRoom(Room room) { this.room = room; }
    
    // Helper methods
    public int getNumNights() {
        if (checkInDate == null || checkOutDate == null) return 0;
        try {
            java.time.LocalDate checkIn = java.time.LocalDate.parse(checkInDate);
            java.time.LocalDate checkOut = java.time.LocalDate.parse(checkOutDate);
            return (int) java.time.temporal.ChronoUnit.DAYS.between(checkIn, checkOut);
        } catch (Exception e) {
            return 0;
        }
    }
    
    public boolean isActive() {
        return "CONFIRMED".equals(status) || "CHECKED_IN".equals(status);
    }
}