package Modelo.DTOs;

import java.sql.Date;

public class ReporteOperativoDTO {

    private int idEmprendimiento;
    private String nombre;
    private String sector;
    private Date fechaRegistro;
    private String estado;


    private Date fechaUltimaMentoria;
    private Date fechaUltimaActividad;
    private Date fechaUltimoEvento;


    private int actividadesPerdidas;
    private int eventosPerdidos;


    private double horasTotalesEquipo;
    private double horasSemanaLider;
    private double horasTotalMentorias;
    private double horasTotalActividades;
    private double horasTotalEventos;

    public ReporteOperativoDTO() {}


    public int getIdEmprendimiento() { return idEmprendimiento; }
    public void setIdEmprendimiento(int idEmprendimiento) { this.idEmprendimiento = idEmprendimiento; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getSector() { return sector; }
    public void setSector(String sector) { this.sector = sector; }

    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Date getFechaUltimaMentoria() { return fechaUltimaMentoria; }
    public void setFechaUltimaMentoria(Date fechaUltimaMentoria) { this.fechaUltimaMentoria = fechaUltimaMentoria; }

    public Date getFechaUltimaActividad() { return fechaUltimaActividad; }
    public void setFechaUltimaActividad(Date fechaUltimaActividad) { this.fechaUltimaActividad = fechaUltimaActividad; }

    public Date getFechaUltimoEvento() { return fechaUltimoEvento; }
    public void setFechaUltimoEvento(Date fechaUltimoEvento) { this.fechaUltimoEvento = fechaUltimoEvento; }

    public int getActividadesPerdidas() { return actividadesPerdidas; }
    public void setActividadesPerdidas(int actividadesPerdidas) { this.actividadesPerdidas = actividadesPerdidas; }

    public int getEventosPerdidos() { return eventosPerdidos; }
    public void setEventosPerdidos(int eventosPerdidos) { this.eventosPerdidos = eventosPerdidos; }

    public double getHorasTotalesEquipo() { return horasTotalesEquipo; }
    public void setHorasTotalesEquipo(double horasTotalesEquipo) { this.horasTotalesEquipo = horasTotalesEquipo; }

    public double getHorasSemanaLider() { return horasSemanaLider; }
    public void setHorasSemanaLider(double horasSemanaLider) { this.horasSemanaLider = horasSemanaLider; }

    public double getHorasTotalMentorias() { return horasTotalMentorias; }
    public void setHorasTotalMentorias(double horasTotalMentorias) { this.horasTotalMentorias = horasTotalMentorias; }

    public double getHorasTotalActividades() { return horasTotalActividades; }
    public void setHorasTotalActividades(double horasTotalActividades) { this.horasTotalActividades = horasTotalActividades; }

    public double getHorasTotalEventos() { return horasTotalEventos; }
    public void setHorasTotalEventos(double horasTotalEventos) { this.horasTotalEventos = horasTotalEventos; }


    @Override
    public String toString() {
        return nombre;
    }
}