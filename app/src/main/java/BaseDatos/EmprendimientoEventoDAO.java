package BaseDatos;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmprendimientoEventoDAO {


    public void asignarEmprendimiento(int idEvento, int idEmp, String obs) {
        String sql = "SELECT fn_emprendimiento_evento('I', ?, ?, ?)";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idEmp);
            ps.setInt(2, idEvento);

            ps.setString(3, obs != null ? obs : "Sin observaciones");

            ps.execute();
            System.out.println("✔ Emprendimiento asignado correctamente.");

        } catch (SQLException e) {
            System.err.println("Error asignando emprendimiento: " + e.getMessage());
        }
    }


    public List<String> listarProyectosPorEvento(int idEvento) {
        List<String> proyectos = new ArrayList<>();
        String sql = "SELECT nombre_emprendimiento FROM vista_emp_asignados WHERE id_evento = ?";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idEvento);
            ResultSet rs = ps.executeQuery();

            while(rs.next()){
                proyectos.add(rs.getString("nombre_emprendimiento"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return proyectos;
    }
}