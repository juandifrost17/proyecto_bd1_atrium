package Modelo.Esquema;



import java.time.LocalDate;

public class Evento {
    private Integer idEvento;
    private String nombre;
    private String descripcion;


    private LocalDate fecha;

    private Double duracionHoras;
    private Integer idLugar;


    public Evento() {}


    public Evento(Integer idEvento, String nombre, String descripcion, LocalDate fecha, Double duracionHoras, Integer idLugar) {
        this.idEvento = idEvento;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.fecha = fecha;
        this.duracionHoras = duracionHoras;
        this.idLugar = idLugar;
    }



    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }


    public Integer getIdEvento() { return idEvento; }
    public void setIdEvento(Integer idEvento) { this.idEvento = idEvento; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Double getDuracionHoras() { return duracionHoras; }
    public void setDuracionHoras(Double duracionHoras) { this.duracionHoras = duracionHoras; }

    public Integer getIdLugar() { return idLugar; }
    public void setIdLugar(Integer idLugar) { this.idLugar = idLugar; }
}