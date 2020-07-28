public class Adjacencia {

    private int carreira;
    private int origem;
    private int destino;

    public Adjacencia(int carreira, int origem, int destino) {
        this.carreira = carreira;
        this.origem = origem;
        this.destino = destino;
    }

    public int getCarreira() {
        return carreira;
    }

    public int getOrigem() {
        return origem;
    }

    public int getDestino() {
        return destino;
    }

    public void setCarreira(int carreira) {
        this.carreira = carreira;
    }

    public void setOrigem(int origem) {
        this.origem = origem;
    }

    public void setDestino(int destino) {
        this.destino = destino;
    }

    @Override
    public String toString() {
        return "adjacencia(" +
                carreira +
                "," + origem +
                "," + destino +
                ").";
    }
}
