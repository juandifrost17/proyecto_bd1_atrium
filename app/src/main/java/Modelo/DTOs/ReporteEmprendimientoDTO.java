package Modelo.DTOs;

public class ReporteEmprendimientoDTO {
    private int idEmprendimiento;
    private String nombre;
    private String sector;
    private String nivelMadurez;


    private boolean estudioMercado;
    private boolean factibleEconomicamente;
    private String justificacionEconomica;
    private boolean factibleTecnicamente;
    private String justificacionTecnica;


    private String ventas;
    private int totalEventos;
    private int totalActividades;
    private int totalMentorias;


    private String nombreLider;
    private String apellidoLider;
    private int edadLider;
    private String matricula;
    private double gpaLider;


    public int getIdEmprendimiento() { return idEmprendimiento; }
    public void setIdEmprendimiento(int idEmprendimiento) { this.idEmprendimiento = idEmprendimiento; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getSector() { return sector; }
    public void setSector(String sector) { this.sector = sector; }
    public String getNivelMadurez() { return nivelMadurez; }
    public void setNivelMadurez(String nivelMadurez) { this.nivelMadurez = nivelMadurez; }

    public boolean isEstudioMercado() { return estudioMercado; }
    public void setEstudioMercado(boolean estudioMercado) { this.estudioMercado = estudioMercado; }

    public boolean isFactibleEconomicamente() { return factibleEconomicamente; }
    public void setFactibleEconomicamente(boolean factibleEconomicamente) { this.factibleEconomicamente = factibleEconomicamente; }

    public String getJustificacionEconomica() { return justificacionEconomica; }
    public void setJustificacionEconomica(String justificacionEconomica) { this.justificacionEconomica = justificacionEconomica; }

    public boolean isFactibleTecnicamente() { return factibleTecnicamente; }
    public void setFactibleTecnicamente(boolean factibleTecnicamente) { this.factibleTecnicamente = factibleTecnicamente; }

    public String getJustificacionTecnica() { return justificacionTecnica; }
    public void setJustificacionTecnica(String justificacionTecnica) { this.justificacionTecnica = justificacionTecnica; }

    public String getVentas() { return ventas; }
    public void setVentas(String ventas) { this.ventas = ventas; }
    public int getTotalEventos() { return totalEventos; }
    public void setTotalEventos(int totalEventos) { this.totalEventos = totalEventos; }
    public int getTotalActividades() { return totalActividades; }
    public void setTotalActividades(int totalActividades) { this.totalActividades = totalActividades; }
    public int getTotalMentorias() { return totalMentorias; }
    public void setTotalMentorias(int totalMentorias) { this.totalMentorias = totalMentorias; }

    public String getNombreLider() { return nombreLider; }
    public void setNombreLider(String nombreLider) { this.nombreLider = nombreLider; }
    public String getApellidoLider() { return apellidoLider; }
    public void setApellidoLider(String apellidoLider) { this.apellidoLider = apellidoLider; }
    public int getEdadLider() { return edadLider; }
    public void setEdadLider(int edadLider) { this.edadLider = edadLider; }
    public String getMatricula() { return matricula; }
    public void setMatricula(String matricula) { this.matricula = matricula; }
    public double getGpaLider() { return gpaLider; }
    public void setGpaLider(double gpaLider) { this.gpaLider = gpaLider; }

    @Override
    public String toString() {
        return this.nombre;
    }
}