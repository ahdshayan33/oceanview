package oceanview.tests;

import oceanview.dao.ReservationDAO;

public class RoomAvailabilityTest {

    public static void main(String[] args) {

        ReservationDAO reservationDAO = new ReservationDAO();

        // Test 1: Room available (future date, assuming room 101 is free)
        boolean available1 = reservationDAO.isRoomAvailable(101, "2026-03-10", "2026-03-12", null);
        System.out.println("TC02a - Room 101 available for 10-12 Mar: " + (available1 ? "PASS" : "FAIL"));

        // Test 2: Room occupied (overlapping with an existing reservation, assuming room 101 booked 2026-03-10 to 2026-03-12)
        boolean available2 = reservationDAO.isRoomAvailable(1, "2026-03-11", "2026-03-13", null);
        System.out.println("TC02b - Room 101 occupied 11-13 Mar: " + (!available2 ? "PASS" : "FAIL"));

        // Test 3: Invalid room ID (room does not exist)
        boolean available3 = reservationDAO.isRoomAvailable(9999, "2026-03-10", "2026-03-12", null);
        System.out.println("TC02c - Invalid room 9999: " + (available3 ? "PASS" : "FAIL"));

    }
}