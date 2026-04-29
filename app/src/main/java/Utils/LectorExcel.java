package Utils;

import BaseDatos.ConexionDB;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
;

public class LectorExcel {

    public void cargarTodoDesdeExcel(String rutaExcel) throws IOException {
        try (FileInputStream fis = new FileInputStream(rutaExcel);
             XSSFWorkbook workbook = new XSSFWorkbook(fis);
             Connection conn = ConexionDB.conectar()) {

            if (conn == null) {
                System.err.println(" Error: No hay conexión a la BD.");
                return;
            }

            conn.setAutoCommit(false);

            try {
                System.out.println("Iniciando carga masiva...");


                cargarFacultad(workbook, conn);
                cargarEstudioMercado(workbook, conn);
                cargarPersona(workbook, conn);
                cargarLugar(workbook, conn);

                cargarCarrera(workbook, conn);
                cargarEmprendimiento(workbook, conn);

                cargarStaff(workbook, conn);
                cargarMentor(workbook, conn);
                cargarExpositor(workbook, conn);


                cargarMiembro(workbook, conn);
                cargarMentoria(workbook, conn);
                cargarEvento(workbook, conn);
                cargarActividad(workbook, conn);
                cargarPerfilAcademico(workbook, conn);
                cargarStaffEvento(workbook, conn);
                cargarEmprendimientoEvento(workbook, conn);
                cargarParticipacionMiembro(workbook, conn);
                cargarEmprendimientoActividad(workbook, conn);

                conn.commit();
                System.out.println("¡Carga masiva completada con éxito!");

            } catch (Exception e) {
                conn.rollback();
                System.err.println("Error crítico. Se hizo ROLLBACK.");
                e.printStackTrace();
                throw new RuntimeException(e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error SQL de conexión: " + e.getMessage());
        }
    }

    private void cargarFacultad(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Facultad");
        if (hoja == null) return;
        String sql = "SELECT fn_facultad('I', ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Facultades cargadas.");
        }
    }

    private void cargarLugar(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Lugar");
        if (hoja == null) return;

        String sql = "SELECT fn_lugar('I', ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setString(3, getString(fila.getCell(2)));
                ps.setString(4, getString(fila.getCell(3)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Lugares cargados.");
        }
    }

    private void cargarPersona(Workbook workbook, Connection conn) throws SQLException {
        Sheet sheet = getSheetIgnoreCase(workbook, "Persona");
        if (sheet == null) {
            System.out.println(" Hoja 'Persona' no encontrada.");
            return;
        }



        String sql = "SELECT fn_persona(?, ?, ?, ?, ?::DATE, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int count = 0;

            for (Row row : sheet) {
                if (row.getRowNum() == 0) continue;

                String cedula = getString(row.getCell(0));
                if (cedula == null || cedula.isEmpty()) continue;


                ps.setString(1, "I");


                ps.setString(2, cedula);


                ps.setString(3, getString(row.getCell(1)));


                ps.setString(4, getString(row.getCell(2)));


                ps.setDate(5, getDate(row.getCell(3)));


                ps.setString(6, getString(row.getCell(4)));


                ps.setString(7, getString(row.getCell(5)));

                ps.addBatch();
                count++;
            }

            ps.executeBatch();
            System.out.println("✅ Personas cargadas");
        }
    }

    private void cargarEstudioMercado(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Estudio_Mercado");
        if (hoja == null) return;
        String sql = "SELECT fn_estudio_mercado('I', ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setObject(2, getBoolean(fila.getCell(1)), java.sql.Types.BOOLEAN);
                ps.setObject(3, getBoolean(fila.getCell(2)), java.sql.Types.BOOLEAN);
                ps.setObject(4, getBoolean(fila.getCell(3)), java.sql.Types.BOOLEAN);
                ps.setString(5, getString(fila.getCell(4)));
                ps.setString(6, getString(fila.getCell(5)));
                ps.setString(7, getString(fila.getCell(6)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Estudios Mercado cargados.");
        }
    }

    private void cargarCarrera(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Carrera");
        if (hoja == null) return;

        String sql = "SELECT fn_carrera('I', ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setInt(3, getInt(fila.getCell(2)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Carreras cargadas.");
        }
    }

    private void cargarEmprendimiento(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Emprendimiento");
        if (hoja == null) return;



        String sql = "SELECT fn_emprendimiento('I', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setString(3, getString(fila.getCell(2)));
                ps.setString(4, getString(fila.getCell(3)));
                ps.setString(5, getString(fila.getCell(4)));
                ps.setString(6, getString(fila.getCell(5)));
                ps.setDate(7, getSqlDate(fila.getCell(6)));
                ps.setString(8, getString(fila.getCell(7)));
                ps.setString(9, getString(fila.getCell(8)));
                ps.setString(10, getString(fila.getCell(9)));
                ps.setString(11, getString(fila.getCell(10)));

                ps.setString(12, getString(fila.getCell(11)));

                ps.setString(13, getString(fila.getCell(12)));

                ps.setObject(14, getInt(fila.getCell(13)), java.sql.Types.INTEGER);

                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Emprendimientos cargados.");
        }
    }

    private void cargarStaff(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Staff");
        if (hoja == null) return;



        String sql = "SELECT fn_staff('I', ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setObject(3, getBoolean(fila.getCell(2)), java.sql.Types.BOOLEAN);
                ps.setString(4, getString(fila.getCell(3)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Staff cargado.");
        }
    }

    private void cargarMentor(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Mentor");
        if (hoja == null) return;


        String sql = "SELECT fn_mentor('I', ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setObject(3, getBoolean(fila.getCell(2)), java.sql.Types.BOOLEAN);
                ps.setString(4, getString(fila.getCell(3)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Mentores cargados.");
        }
    }

    private void cargarExpositor(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Expositor");
        if (hoja == null) return;


        String sql = "SELECT fn_expositor('I', ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setObject(3, getBoolean(fila.getCell(2)), java.sql.Types.BOOLEAN);
                ps.setString(4, getString(fila.getCell(3)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Expositores cargados.");
        }
    }

    private void cargarMiembro(Workbook workbook, Connection conn) throws SQLException {
        Sheet sheet = getSheetIgnoreCase(workbook, "Miembro");
        if (sheet == null) {
            System.out.println("⚠️ Hoja 'Miembro' no encontrada.");
            return;
        }



        String sql = "SELECT fn_miembro(?, ?, ?, ?, ?::DATE, ?::DATE, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int count = 0;

            for (Row row : sheet) {
                if (row.getRowNum() == 0) continue;


                Integer idMiembro = getInt(row.getCell(0));
                if (idMiembro == null || idMiembro == 0) continue;




                ps.setString(1, "I");


                ps.setInt(2, idMiembro);


                ps.setString(3, getString(row.getCell(1)));



                Double horas = getDouble(row.getCell(2));
                ps.setDouble(4, (horas != null) ? horas : 0.0);


                ps.setDate(5, getDate(row.getCell(3)));


                ps.setDate(6, getDate(row.getCell(4)));



                Integer idEmprendimiento = getInt(row.getCell(5));
                if (idEmprendimiento != null) {
                    ps.setInt(7, idEmprendimiento);
                } else {
                    ps.setNull(7, java.sql.Types.INTEGER);
                }


                ps.setString(8, getString(row.getCell(6)));

                ps.addBatch();
                count++;
            }

            ps.executeBatch();
            System.out.println("✅ Miembros cargados: " + count);
        }
    }

    private void cargarMentoria(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Mentoria");
        if (hoja == null) return;

        String sql = "SELECT fn_mentoria('I', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setString(3, getString(fila.getCell(2)));
                ps.setString(4, getString(fila.getCell(3)));
                ps.setDate(5, getSqlDate(fila.getCell(4)));
                ps.setObject(6, getDouble(fila.getCell(5)), java.sql.Types.DOUBLE);
                ps.setString(7, getString(fila.getCell(6)));
                ps.setString(8, getString(fila.getCell(7)));
                ps.setObject(9, getInt(fila.getCell(8)), java.sql.Types.INTEGER);
                ps.setObject(10, getInt(fila.getCell(9)), java.sql.Types.INTEGER);
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Mentorías cargadas.");
        }
    }

    private void cargarPerfilAcademico(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Perfil_Academico");
        if (hoja == null) return;

        String sql = "SELECT fn_perfil_academico('I', ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; }
                if (filaEsVacia(fila)) continue;


                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setInt(2, getInt(fila.getCell(1)));
                ps.setDouble(3, getDouble(fila.getCell(2)));
                ps.setInt(4, getInt(fila.getCell(3)));
                ps.setInt(5, getInt(fila.getCell(4)));
                ps.setInt(6, getInt(fila.getCell(5)));

                ps.addBatch();
            }
            ps.executeBatch();
            System.out.println("✔ Perfiles Académicos cargados.");
        }
    }

    private void cargarEvento(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Evento");
        if (hoja == null) return;

        String sql = "SELECT fn_evento('I', ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setString(3, getString(fila.getCell(2)));
                ps.setDate(4, getSqlDate(fila.getCell(3)));
                ps.setDouble(5, getDouble(fila.getCell(4)));
                ps.setInt(6, getInt(fila.getCell(5)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Eventos cargados.");
        }
    }

    private void cargarActividad(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Actividad");
        if (hoja == null) return;

        String sql = "SELECT fn_actividad('I', ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setString(2, getString(fila.getCell(1)));
                ps.setString(3, getString(fila.getCell(2)));
                ps.setString(4, getString(fila.getCell(3)));
                ps.setDate(5, getSqlDate(fila.getCell(4)));
                ps.setDouble(6, getDouble(fila.getCell(5)));
                ps.setInt(7, getInt(fila.getCell(6)));
                ps.setInt(8, getInt(fila.getCell(7)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Actividades cargadas.");
        }
    }

    private void cargarStaffEvento(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Staff_Evento");
        if (hoja == null) return;

        String sql = "SELECT fn_staff_evento('I', ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setInt(2, getInt(fila.getCell(1)));
                ps.setDouble(3, getDouble(fila.getCell(2)));
                ps.setString(4, getString(fila.getCell(3)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Staff-Evento cargado.");
        }
    }

    private void cargarEmprendimientoEvento(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Emprendimiento_Evento");
        if (hoja == null) return;

        String sql = "SELECT fn_emprendimiento_evento('I', ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setInt(2, getInt(fila.getCell(1)));
                ps.setString(3, getString(fila.getCell(2)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Emprendimiento-Evento cargado.");
        }
    }

    private void cargarEmprendimientoActividad(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Emprendimiento_Actividad");
        if (hoja == null) return;


        String sql = "SELECT fn_emprendimiento_actividad('I', ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setInt(2, getInt(fila.getCell(1)));
                ps.setString(3, getString(fila.getCell(2)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Emprendimiento-Actividad cargado.");
        }
    }

    private void cargarParticipacionMiembro(Workbook workbook, Connection conn) throws SQLException {
        Sheet hoja = getSheetIgnoreCase(workbook, "Participacion_Miembro");
        if (hoja == null) return;

        String sql = "SELECT fn_participacion_miembro('I', ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            boolean primera = true;
            for (Row fila : hoja) {
                if (primera) { primera = false; continue; } if (filaEsVacia(fila)) continue;
                ps.setInt(1, getInt(fila.getCell(0)));
                ps.setInt(2, getInt(fila.getCell(1)));
                ps.setDouble(3, getDouble(fila.getCell(2)));
                ps.addBatch();
            }
            ps.executeBatch(); System.out.println("✔ Participación Miembro cargada.");
        }
    }


    private boolean filaEsVacia(Row fila) {
        if (fila == null) return true;
        for (int i = 0; i < fila.getLastCellNum(); i++) {
            Cell cell = fila.getCell(i);
            if (cell != null && cell.getCellType() != CellType.BLANK) {
                String v = cell.toString();
                if (v != null && !v.trim().isEmpty()) return false;
            }
        }
        return true;
    }

    private java.sql.Date getSqlDate(Cell cell) {
        if (cell == null) return null;
        try {
            if (cell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(cell)) {
                return new java.sql.Date(cell.getDateCellValue().getTime());
            }
            if (cell.getCellType() == CellType.STRING) {
                String s = cell.getStringCellValue().trim();
                if (s.isEmpty()) return null;
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                return new java.sql.Date(sdf.parse(s).getTime());
            }
        } catch (Exception e) {}
        return null;
    }

    private String getString(Cell cell) {
        if (cell == null) return null;
        String resultado = switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue();
            case NUMERIC -> {
                double d = cell.getNumericCellValue();
                long l = (long) d;
                yield (Math.abs(d - l) < 0.000001) ? String.valueOf(l) : String.valueOf(d);
            }
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            default -> null;
        };

        if (resultado != null) {
            resultado = resultado.trim();

            resultado = resultado.replace("\"", "");
            if (resultado.isEmpty()) return null;
        }
        return resultado;
    }

    private Integer getInt(Cell cell) {
        if (cell == null) return null;
        try {
            return switch (cell.getCellType()) {
                case NUMERIC -> (int) cell.getNumericCellValue();
                case STRING -> {
                    String s = cell.getStringCellValue().trim();
                    yield s.isEmpty() ? null : Integer.parseInt(s);
                }
                default -> null;
            };
        } catch (Exception e) { return null; }
    }

    private Double getDouble(Cell cell) {
        if (cell == null) return null;
        try {
            return switch (cell.getCellType()) {
                case NUMERIC -> cell.getNumericCellValue();
                case STRING -> {
                    String s = cell.getStringCellValue().trim();
                    yield s.isEmpty() ? null : Double.parseDouble(s);
                }
                default -> null;
            };
        } catch (Exception e) { return null; }
    }

    private Boolean getBoolean(Cell cell) {
        if (cell == null) return null;
        return switch (cell.getCellType()) {
            case BOOLEAN -> cell.getBooleanCellValue();
            case STRING -> {
                String s = cell.getStringCellValue().trim().toLowerCase();
                yield (s.equals("true") || s.equals("si") || s.equals("1"));
            }
            case NUMERIC -> cell.getNumericCellValue() != 0;
            default -> null;
        };
    }

    private Sheet getSheetIgnoreCase(Workbook workbook, String nombreBuscado) {

        String target = nombreBuscado.replace("_", "").replace(" ", "").toLowerCase();

        for (int i = 0; i < workbook.getNumberOfSheets(); i++) {
            String real = workbook.getSheetName(i);
            String normalizado = real.replace("_", "").replace(" ", "").toLowerCase();

            if (normalizado.equals(target)) {
                return workbook.getSheetAt(i);
            }
        }
        return null;
    }

    private java.sql.Date getDate(Cell cell) {
        if (cell == null) return null;

        try {

            if (cell.getCellType() == CellType.NUMERIC) {
                if (DateUtil.isCellDateFormatted(cell)) {
                    java.util.Date date = cell.getDateCellValue();
                    return new java.sql.Date(date.getTime());
                }
            }


            if (cell.getCellType() == CellType.STRING) {
                String text = cell.getStringCellValue().trim();
                if (text.isEmpty()) return null;


                try {
                    return java.sql.Date.valueOf(text);
                } catch (IllegalArgumentException e) {

                }


                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                    sdf.setLenient(false);
                    java.util.Date parsed = sdf.parse(text);
                    return new java.sql.Date(parsed.getTime());
                } catch (ParseException e) {

                }


                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
                    sdf.setLenient(false);
                    java.util.Date parsed = sdf.parse(text);
                    return new java.sql.Date(parsed.getTime());
                } catch (ParseException e) {

                }

                System.out.println("No se pudo interpretar la fecha (Texto): [" + text + "]");
            }

        } catch (Exception e) {
            System.err.println(" Error crítico leyendo fecha en celda: " + cell.getAddress());
        }
        return null;
    }
}