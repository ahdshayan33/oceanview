package oceanview.tests;

import oceanview.dao.UserDAO;
import oceanview.model.User;

public class LoginTest {

    public static void main(String[] args) {

        UserDAO userDAO = new UserDAO();

        // Test 1: Valid credentials
        User validUser = userDAO.authenticate("admin", "admin123");
        if(validUser != null){
            System.out.println("TC01a - Valid Login Test: PASS");
        } else {
            System.out.println("TC01a - Valid Login Test: FAIL");
        }

        // Test 2: Invalid credentials
        User invalidUser = userDAO.authenticate("admin", "wrongpass");
        if(invalidUser == null){
            System.out.println("TC01b - Invalid Login Test: PASS");
        } else {
            System.out.println("TC01b - Invalid Login Test: FAIL");
        }

        // Test 3: Non-existing user
        User nonExistUser = userDAO.authenticate("nonuser", "anyPass");
        if(nonExistUser == null){
            System.out.println("TC01c - Non-existing User Test: PASS");
        } else {
            System.out.println("TC01c - Non-existing User Test: FAIL");
        }
    }
}