package Modelo.Esquema;

public class Emprendimiento {
    private Integer idEmprendimiento;
    private String nombre;
    private String sector;
    private String ciudad;
    private String paginaWeb;
    private String redSocial;
    private String fechaRegistro;
    private String estado;
    private String modeloNegocio;
    private String nivelMadurez;
    private String ventas;
    private Double presupuesto;
    private Integer idEstudio;

    public Integer getIdEmprendimiento() {
        return this.idEmprendimiento;
    }
    public void setIdEmprendimiento(Integer idEmprendimiento) {
        this.idEmprendimiento = idEmprendimiento;
    }

    public String getNombre() {
        return this.nombre;
    }
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getSector() {
        return this.sector;
    }
    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getCiudad() {
        return this.ciudad;
    }
    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
    }

    public String getPaginaWeb() {
        return this.paginaWeb;
    }
    public void setPaginaWeb(String paginaWeb) {
        this.paginaWeb = paginaWeb;
    }

    public String getRedSocial() {
        return this.redSocial;
    }
    public void setRedSocial(String redSocial) {
        this.redSocial = redSocial;
    }

    public String getFechaRegistro() {
        return this.fechaRegistro;
    }
    public void setFechaRegistro(String fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getEstado() {
        return this.estado;
    }
    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getModeloNegocio() {
        return this.modeloNegocio;
    }
    public void setModeloNegocio(String modeloNegocio) {
        this.modeloNegocio = modeloNegocio;
    }

    public String getNivelMadurez() {
        return this.nivelMadurez;
    }
    public void setNivelMadurez(String nivelMadurez) {
        this.nivelMadurez = nivelMadurez;
    }

    public String getVentas() {
        return this.ventas;
    }
    public void setVentas(String ventas) {
        this.ventas = ventas;
    }

    public Double getPresupuesto() {
        return this.presupuesto;
    }
    public void setPresupuesto(Double presupuesto) {
        this.presupuesto = presupuesto;
    }

    public Integer getIdEstudio() {
        return this.idEstudio;
    }
    public void setIdEstudio(Integer idEstudio) {
        this.idEstudio = idEstudio;
    }

    @Override
    public String toString() {
        return this.nombre;
    }
}
