import java.util.List;

public class Paragem {
    private int gid;
    private double latitude;
    private double longitude;
    private String estado;
    private String tipo;
    private String publicidade;
    private String operador;
    private List<Integer> carreiras;
    private int codigo;
    private String rua;
    private String freguesia;

    public Paragem(int gid, double latitude, double longitude, String estado, String tipo, String publicidade, String operador, List<Integer> carreiras, int codigo, String rua, String freguesia) {
        this.gid = gid;
        this.latitude = latitude;
        this.longitude = longitude;
        this.estado = estado;
        this.tipo = tipo;
        this.publicidade = publicidade;
        this.operador = operador;
        this.carreiras = carreiras;
        this.codigo = codigo;
        this.rua = rua;
        this.freguesia = freguesia;
    }

    public void setGid(int gid) {
        this.gid = gid;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public void setPublicidade(String publicidade) {
        this.publicidade = publicidade;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public void setOperador(String operador) {
        this.operador = operador;
    }

    public void setCarreiras(List<Integer> carreiras) {
        this.carreiras = carreiras;
    }

    public void setCodigo(int codigo) {
        this.codigo = codigo;
    }

    public void setRua(String rua) {
        this.rua = rua;
    }

    public void setFreguesia(String freguesia) {
        this.freguesia = freguesia;
    }

    public int getGid() {
        return gid;
    }

    public double getLatitude() {
        return latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public String getEstado() {
        return estado;
    }

    public String getTipo() {
        return tipo;
    }

    public String getPublicidade() {
        return publicidade;
    }

    public String getOperador() {
        return operador;
    }

    public List<Integer> getCarreiras() {
        return carreiras;
    }

    public int getCodigo() {
        return codigo;
    }

    public String getRua() {
        return rua;
    }

    public String getFreguesia() {
        return freguesia;
    }

    @Override
    public String toString() {
        return "paragem(" +
                 gid +
                "," + latitude +
                "," + longitude +
                "," + estado  +
                "," + '"' + tipo  + '"'+
                "," + publicidade +
                "," + operador  +
                "," + carreiras +
                "," + codigo +
                "," + '"' + rua + '"' +
                "," + '"'+ freguesia + '"' +
                ").";
    }
}
