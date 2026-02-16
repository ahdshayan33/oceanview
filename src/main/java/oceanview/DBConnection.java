package oceanview;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    // This method must exist exactly as below
    public static Connection getConnection() {
        Connection con = null;
        try {
            // Load MySQL driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Connect to your database
            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hotel_db", // your DB name
                "root",       // MySQL username
                "Hisillicon5#"     // MySQL password
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
        return con;
    }
}