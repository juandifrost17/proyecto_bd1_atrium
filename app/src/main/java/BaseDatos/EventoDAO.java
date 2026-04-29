package BaseDatos;

import Modelo.Esquema.Emprendimiento;
import Modelo.Esquema.Evento;
import java.sql.*;
import java.util.List;

public class EventoDAO {


    public boolean guardarEventoCompleto(Evento evento, int idCoordinador, List<Emprendimiento> participantes) {
        Connection conn = null;


        String sqlCrear = "SELECT fn_crear_evento_seguro(?, ?, ?, ?, ?, ?)";



        String sqlParticipantes = "SELECT fn_emprendimiento_evento('I', ?, ?, ?)";

        try {
            conn = ConexionDB.conectar();
            conn.setAutoCommit(false);


            int idEventoGenerado = -1;

            try (PreparedStatement ps = conn.prepareStatement(sqlCrear)) {
                ps.setString(1, evento.getNombre());
                ps.setString(2, evento.getDescripcion());
                ps.setDate(3, java.sql.Date.valueOf(evento.getFecha()));
                ps.setDouble(4, evento.getDuracionHoras());
                ps.setInt(5, evento.getIdLugar());
                ps.setInt(6, idCoordinador);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        idEventoGenerado = rs.getInt(1);
                    }
                }
            }


            if (idEventoGenerado <= 0) {
                throw new SQLException("La función fn_crear_evento_seguro retornó error o ID inválido.");
            }


            if (participantes != null && !participantes.isEmpty()) {
                try (PreparedStatement psPart = conn.prepareStatement(sqlParticipantes)) {
                    for (Emprendimiento emp : participantes) {
                        psPart.setInt(1, emp.getIdEmprendimiento());
                        psPart.setInt(2, idEventoGenerado);
                        psPart.setString(3, "Inscrito Inicial");

                        psPart.addBatch();
                    }
                    psPart.executeBatch();
                }
            }


            conn.commit();
            System.out.println(" Evento creado con ID " + idEventoGenerado + " y participantes registrados.");
            return true;

        } catch (SQLException e) {
            System.err.println("Error en la transacción de funciones: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }
}