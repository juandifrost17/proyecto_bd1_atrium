package BaseDatos;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffEventoDAO {


    public void asignarStaff(int idEvento, int idStaff, double horas, String tarea) {
        String sql = "SELECT fn_staff_evento('I', ?, ?, ?, ?)";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idEvento);
            ps.setInt(2, idStaff);
            ps.setDouble(3, horas);
            ps.setString(4, tarea);

            ps.execute();
            System.out.println("✔ Staff asignado correctamente.");

        } catch (SQLException e) {
            System.err.println("Error asignando staff: " + e.getMessage());
        }
    }


    public List<String> listarNombresStaffPorEvento(int idEvento) {
        List<String> nombres = new ArrayList<>();
        String sql = "SELECT nombre_completo, tarea FROM vista_staff_asignados WHERE id_evento = ?";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idEvento);
            ResultSet rs = ps.executeQuery();

            while(rs.next()){

                nombres.add(rs.getString("nombre_completo") + " (" + rs.getString("tarea") + ")");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return nombres;
    }
}