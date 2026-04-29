package BaseDatos;

import Modelo.Esquema.Lugar;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LugarDAO {

    
    public List<Lugar> listarLugares() {
        List<Lugar> lista = new ArrayList<>();



        String sql = "SELECT id_lugar, nombre, direccion, ciudad FROM lugar ORDER BY nombre ASC";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Lugar lugar = new Lugar();


                lugar.setIdLugar(rs.getInt("id_lugar"));
                lugar.setNombre(rs.getString("nombre"));
                lugar.setDireccion(rs.getString("direccion"));
                lugar.setCiudad(rs.getString("ciudad"));

                lista.add(lugar);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar lugares: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }
}