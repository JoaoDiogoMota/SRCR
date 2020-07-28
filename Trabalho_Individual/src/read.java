import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
//import org.apache.poi.openxml4j.exceptions.InvalidFormatException;

public class read {


    public static void main(String[] args) throws IOException {

        String teste = "TesTe";
         teste = teste.toLowerCase();
         System.out.println(teste);


        List<Paragem> paragens = readParagens("/Users/joaomota/Desktop/Trabalho_Individual/paragens.csv");

        writeFicheiro(paragens);



        File dir = new File("/Users/joaomota/Desktop/Trabalho_Individual/Adjacencias");
        File[] directoryListing = dir.listFiles();
        int i=0;
        if (directoryListing != null) {
            for (File child : directoryListing) {
                //System.out.println("NOMEEEEEEEEEEEEEEEEEEE" + child.getName());
                List<Adjacencia> adjacencias = readAdjacencias(child.getName());
                writeFicheiroAdjacencias(adjacencias);
            }
        }


    }

    public static List<Paragem> readParagens(String file) {
        List<Paragem> paragens = new ArrayList<Paragem>();
        Path pathToFile = Paths.get(file);
        try (BufferedReader br = Files.newBufferedReader(pathToFile, Charset.forName("UTF-8"))) {
            String line = br.readLine();
            line = br.readLine();
            while (line != null) {
                String[] attributes = line.split(";");
                Paragem paragem = createParagem(attributes);
                paragens.add(paragem);
                line = br.readLine();
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
        return paragens;
    }

    private static Paragem createParagem(String[] metadata) {
        int gid = Integer.parseInt(metadata[0]);
        Double latitude = Double.parseDouble(metadata[1]);
        Double longitude = Double.parseDouble(metadata[2]);
        String estado = metadata[3].toLowerCase();
        String tipo = metadata[4].toLowerCase();
        String publicidade = metadata[5].toLowerCase();
        String operador = metadata[6].toLowerCase();
        String[] c = metadata[7].split(",");
        List<Integer> carreiras = new ArrayList<Integer>();
        for (String carreira : c)
            carreiras.add(Integer.parseInt(carreira));
        int codigo = Integer.parseInt(metadata[8]);
        String rua = metadata[9].toLowerCase();
        String freguesia = metadata[10].toLowerCase();

        return new Paragem(gid, latitude, longitude, estado, tipo, publicidade, operador, carreiras, codigo, rua, freguesia);
    }

    public static void writeFicheiro(List<Paragem> paragens) {
        //Abrir o ficheiro
        try {
            File myObj = new File("/Users/joaomota/Desktop/Trabalho_Individual/projetoIndividual.prolog.BB.pl");
            if (myObj.createNewFile()) {
                System.out.println("File created: " + myObj.getName());
            } else {
                System.out.println("File already exists.");
            }
        } catch (IOException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }

        // Escrever para o ficheiro
        try {
            FileWriter myWriter = new FileWriter("/Users/joaomota/Desktop/Trabalho_Individual/projetoIndividual.prolog.BB.pl", true);
            for (Paragem p : paragens) {

                myWriter.write(p.toString() + '\n');
                //myWriter.flush();
            }
            myWriter.close();
        } catch (IOException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }


    }


    public static List<Adjacencia> readAdjacencias(String file){
        List<Adjacencia> adjacencias = new ArrayList<Adjacencia>();
        Path pathToFile = Paths.get("Adjacencias/"+file);
        //File in = new File(pathToFile);
        try (BufferedReader br = Files.newBufferedReader(pathToFile, Charset.forName("UTF-8"))) {
            String line = br.readLine();

            line = br.readLine();
            int res=0;
           /* String[] attributes;
            while(line!=null) {
                attributes = line.split(";");
                res++;
            }*/
            int i=0;
            while (line != null) {
               // System.out.println("Teste passagem");
                String[] attributes = line.split(",");
                line = br.readLine();
              //  System.out.println(line);
                if(line==null) break;
                String[] attributes2 = line.split(",");
                Adjacencia adjacencia = createAdjacencia(attributes,attributes2);
                if(adjacencia!=null)adjacencias.add(adjacencia);
                //line = br.readLine();
                //if(line==null) break;
               // System.out.println(line);
                //attributes = line.split(",");
                i++;
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
        return adjacencias;
    }


    public static Adjacencia createAdjacencia(String[] metadata,String[] metadata2){
        int carreira = Integer.parseInt(metadata[7]);
        int origem = Integer.parseInt(metadata[0]);
        int destino = Integer.parseInt(metadata2[0]);
       // System.out.println("Adjacencia : " +carreira + origem + " | "+destino);
        if(origem!=destino)
        return new Adjacencia(carreira,origem,destino);
        else return null;
    }


    public static void writeFicheiroAdjacencias(List<Adjacencia> adjacencias){
        //Abrir o ficheiro
        try {
            File myObj = new File("/Users/joaomota/Desktop/Trabalho_Individual/projetoIndividual.prolog.BB.pl");
            if (myObj.createNewFile()) {
                System.out.println("File created: " + myObj.getName());
            } else {
                System.out.println("File already exists.");
            }
        } catch (IOException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }

        // Escrever para o ficheiro
        try {
            FileWriter myWriter = new FileWriter("/Users/joaomota/Desktop/Trabalho_Individual/projetoIndividual.prolog.BB.pl", true);
            for (Adjacencia a : adjacencias) {

                myWriter.write(a.toString() + '\n');
                //myWriter.flush();
            }
            myWriter.close();
        } catch (IOException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }


    }
    }




               /* String sFinal = "(" + Integer.toString(p.getGid()) + "," + Double.toString(p.getLatitude()) + "," + Double.toString(p.getLongitude()) + "," + p.getEstado() + "," + p.getTipo() + "," + p.getPublicidade() + "," + p.getOperador() + ",[";
                for (Integer c : p.getCarreiras()) {
                    int size = p.getCarreiras().size();
                    int i = 1;
                    if (i < size) {
                        sFinal = sFinal + Integer.toString(c) + ",";
                    } else sFinal = sFinal + Integer.toString(c);
                    i++;
                }
                sFinal = "," + sFinal + Integer.toString(p.getCodigo()) + "," + p.getRua() + "," + p.getFreguesia() + ").";*/

/*Ler de xlsx
        File excel = new File("/Users/joaomota/Desktop/Trabalho_Individual/paragem_autocarros_oeiras_processado_4.xlsx");
        FileInputStream fIS;
        fIS = new FileInputStream(excel);

        XSSFWorkbook wb = new XSSFWorkbook(fIS);
        XSSFSheet sheet = wb.getSheetAt(0);

        Iterator<Row> rowIterator = sheet.iterator();

        while(rowIterator.hasNext()){
            Row row  = rowIterator.next();

            Iterator<Cell> cellIterator = row.cellIterator();

            while(cellIterator.hasNext()){
                Cell cell = cellIterator.next();
                System.out.println(cell.toString() + ";");
            }
        }
        wb.close();
        fIS.close();
    }

 */



    /*public static void echoAsCSV(Sheet sheet) {
        Row row = null;
        for (int i = 0; i < sheet.getLastRowNum(); i++) {
            row = sheet.getRow(i);
            for (int j = 0; j < row.getLastCellNum(); j++) {
                System.out.print("\"" + row.getCell(j) + "\";");
            }
            System.out.println();
        }
    }

    /**
     * @param args the command line arguments
     *
     *

    public static void main(String[] args) {
        InputStream inp = null;
        try {
            inp = new FileInputStream("/Users/joaomota/Desktop/Trabalho_Individual/paragem_autocarros_oeiras_processado_4.");
            Workbook wb = WorkbookFactory.create(inp);

            for(int i=0;i<wb.getNumberOfSheets();i++) {
                System.out.println(wb.getSheetAt(i).getSheetName());
                echoAsCSV(wb.getSheetAt(i));
            }
        } catch (FileNotFoundException ex) {
            Logger.getLogger(ExcelReading.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(ExcelReading.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                inp.close();
            } catch (IOException ex) {
                Logger.getLogger(ExcelReading.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

}*/