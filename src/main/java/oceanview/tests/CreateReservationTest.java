package oceanview.tests;

import oceanview.dao.ReservationDAO;
import oceanview.model.Reservation;

public class CreateReservationTest {

    public static void main(String[] args) {

        ReservationDAO reservationDAO = new ReservationDAO();

        // Create reservation object
        Reservation reservation = new Reservation();
        reservation.setGuestNic("200400514306"); // Existing guest NIC
        reservation.setRoomId(1);                // Existing room ID
        reservation.setCheckInDate("2026-04-13");
        reservation.setCheckOutDate("2026-04-15");
        reservation.setNumGuests(2);
        reservation.setTotalAmount(300.0);       // Example total amount
        reservation.setPaymentStatus("PAID");
        reservation.setSpecialRequests("None");
        reservation.setCreatedBy("admin");

        // Attempt to create reservation
        boolean result = reservationDAO.createReservation(reservation);

        // Print result
        System.out.println("TC03 - Create Reservation: " + (result ? "PASS" : "FAIL"));


        if (result) {
            System.out.println("Generated Reservation ID: " + reservation.getReservationId());
        }
    }
}