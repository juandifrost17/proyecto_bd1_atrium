package BaseDatos;

import Modelo.DTOs.ReporteEmprendimientoDTO;
import Modelo.DTOs.ReporteOperativoDTO;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReporteDAO {


    public List<ReporteEmprendimientoDTO> listarEmprendimientosResumen() {
        List<ReporteEmprendimientoDTO> lista = new ArrayList<>();

        String sql = "SELECT id_emprendimiento, nombre FROM emprendimiento ORDER BY nombre";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ReporteEmprendimientoDTO dto = new ReporteEmprendimientoDTO();
                dto.setIdEmprendimiento(rs.getInt("id_emprendimiento"));
                dto.setNombre(rs.getString("nombre"));
                lista.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }


    public ReporteEmprendimientoDTO obtenerReportePorId(int idEmprendimiento) {
        ReporteEmprendimientoDTO dto = null;
        String sql = "SELECT * FROM fn_reporte1_por_emprendimiento(?)";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idEmprendimiento);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                dto = new ReporteEmprendimientoDTO();
                dto.setIdEmprendimiento(rs.getInt("id_emprendimiento"));
                dto.setNombre(rs.getString("nombre_emprendimiento"));
                dto.setSector(rs.getString("sector"));
                dto.setNivelMadurez(rs.getString("nivel_madurez"));

                dto.setEstudioMercado(rs.getBoolean("estudio_mercado"));
                dto.setFactibleEconomicamente(rs.getBoolean("factible_economicamente"));
                dto.setFactibleTecnicamente(rs.getBoolean("factible_tecnicamente"));

                dto.setJustificacionEconomica(rs.getString("just_fact_econo"));
                dto.setJustificacionTecnica(rs.getString("just_fact_tecni"));

                dto.setVentas(rs.getString("ventas"));

                dto.setTotalEventos(rs.getInt("total_eventos"));
                dto.setTotalActividades(rs.getInt("total_actividades"));
                dto.setTotalMentorias(rs.getInt("total_mentorias"));

                dto.setNombreLider(rs.getString("nombre_lider"));
                dto.setApellidoLider(rs.getString("apellido_lider"));
                dto.setEdadLider(rs.getInt("edad_lider"));
                dto.setMatricula(rs.getString("matricula"));
                dto.setGpaLider(rs.getDouble("gpa_lider"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dto;
    }




    public ReporteOperativoDTO obtenerReporteOperativo(int idEmprendimiento) {
        ReporteOperativoDTO reporte = null;
        String sql = "SELECT * FROM fn_reporte2_estado_operativo_por_emprendimiento(?)";

        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idEmprendimiento);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                reporte = new ReporteOperativoDTO();
                reporte.setIdEmprendimiento(rs.getInt("id_emprendimiento"));
                reporte.setNombre(rs.getString("nombre_emprendimiento"));
                reporte.setSector(rs.getString("sector"));
                reporte.setFechaRegistro(rs.getDate("fecha_registro"));
                reporte.setEstado(rs.getString("estado"));


                reporte.setFechaUltimaMentoria(rs.getDate("fecha_ultima_mentoria"));
                reporte.setFechaUltimaActividad(rs.getDate("fecha_ultima_actividad"));
                reporte.setFechaUltimoEvento(rs.getDate("fecha_ultimo_evento"));


                reporte.setActividadesPerdidas(rs.getInt("actividades_perdidas"));
                reporte.setEventosPerdidos(rs.getInt("eventos_perdidos"));


                reporte.setHorasTotalesEquipo(rs.getDouble("horas_totales_semana_equipo"));
                reporte.setHorasSemanaLider(rs.getDouble("horas_semana_lider"));
                reporte.setHorasTotalMentorias(rs.getDouble("horas_total_mentorias"));
                reporte.setHorasTotalActividades(rs.getDouble("horas_total_actividades"));
                reporte.setHorasTotalEventos(rs.getDouble("horas_total_eventos"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Error obteniendo reporte operativo: " + e.getMessage());
        }
        return reporte;
    }
}