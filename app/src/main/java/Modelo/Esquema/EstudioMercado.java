package Modelo.Esquema;

public class EstudioMercado {
    private Integer idEstudio;
    private Boolean estudioMercado;
    private Boolean factibEconomica;
    private String justFactEcon;
    private Boolean factibTecnica;
    private String justFactTecr;
    private String publicoObj;

    public Integer getIdEstudio() {
        return this.idEstudio;
    }

    public void setIdEstudio(Integer idEstudio) {
        this.idEstudio = idEstudio;
    }

    public Boolean getEstudioMercado() {
        return this.estudioMercado;
    }

    public void setEstudioMercado(Boolean estudioMercado) {
        this.estudioMercado = estudioMercado;
    }

    public Boolean getFactibEconomica() {
        return this.factibEconomica;
    }

    public void setFactibEconomica(Boolean factibEconomica) {
        this.factibEconomica = factibEconomica;
    }

    public String getJustFactEcon() {
        return this.justFactEcon;
    }

    public void setJustFactEcon(String justFactEcon) {
        this.justFactEcon = justFactEcon;
    }

    public Boolean getFactibTecnica() {
        return this.factibTecnica;
    }

    public void setFactibTecnica(Boolean factibTecnica) {
        this.factibTecnica = factibTecnica;
    }

    public String getJustFactTecr() {
        return this.justFactTecr;
    }

    public void setJustFactTecr(String justFactTecr) {
        this.justFactTecr = justFactTecr;
    }

    public String getPublicoObj() {
        return this.publicoObj;
    }

    public void setPublicoObj(String publicoObj) {
        this.publicoObj = publicoObj;
    }

}