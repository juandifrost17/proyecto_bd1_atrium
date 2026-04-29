package BaseDatos;

import Modelo.Esquema.Emprendimiento;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmprendimientoDAO {

    public List<Emprendimiento> listarTodos() {
        List<Emprendimiento> lista = new ArrayList<>();

        String sql = "SELECT * FROM emprendimiento ORDER BY nombre ASC";

        try (Connection conn = ConexionDB.conectar();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Emprendimiento emp = new Emprendimiento();
                emp.setIdEmprendimiento(rs.getInt("id_emprendimiento"));
                emp.setNombre(rs.getString("nombre"));

                lista.add(emp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}