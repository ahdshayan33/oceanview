package oceanview.tests;

import oceanview.dao.ReservationDAO;

public class CancelReservationTest {

    public static void main(String[] args) {

        ReservationDAO reservationDAO = new ReservationDAO();

        int reservationId = 8; // Reservation to cancel

        // Attempt to cancel reservation
        boolean result = reservationDAO.cancelReservation(reservationId);

        // Print result
        System.out.println("TC04 - Cancel Reservation: " + (result ? "PASS" : "FAIL"));
    }
}