package BaseDatos;

import Modelo.Esquema.StaffVista;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO {


    public List<String> obtenerListaNombresStaff() {
        List<String> lista = new ArrayList<>();
        String sql = "SELECT * from vista_staff_activo";

        try (Connection conn = ConexionDB.conectar();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(rs.getString("nombre_completo") + " (ID:" + rs.getInt("id_staff") + ")");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }



    public List<StaffVista> listarStaffCompleto() {
        List<StaffVista> lista = new ArrayList<>();

        String sql = "SELECT * from vista_staff_activo";

        try (Connection conn = ConexionDB.conectar();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {


                StaffVista staff = new StaffVista();
                staff.setIdStaff(rs.getInt("id_staff"));
                staff.setNombreCompleto(rs.getString("nombre") + " " + rs.getString("apellido"));
                staff.setCargo(rs.getString("cargo"));

                lista.add(staff);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }
}