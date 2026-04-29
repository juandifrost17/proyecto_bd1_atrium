package BaseDatos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {
    private static final String URL = "jdbc:postgresql://localhost:5432/centro_emprendimiento";
    private static final String USER = "postgres";
    private static final String PASS = "1385";

    public static Connection conectar() {
        Connection conn = null;
        try {

            Class.forName("org.postgresql.Driver");


            conn = DriverManager.getConnection(URL, USER, PASS);
            System.out.println(" Conexión exitosa a la BD");

        } catch (ClassNotFoundException e) {
            System.err.println("Error CRÍTICO: No se encontró el Driver de PostgreSQL.");
            System.err.println("Asegúrate de haber agregado el archivo .jar a las librerías del proyecto.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Error de conexión SQL: " + e.getMessage());
        }
        return conn;
    }
}