package InterfazGrafica.VistasReportes;

import BaseDatos.ReporteDAO;
import Modelo.DTOs.ReporteEmprendimientoDTO;
import Utils.GeneradorPDF;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.stage.FileChooser;
import java.io.File;

public class VistaReporteIndividual extends BorderPane {


    private ListView<ReporteEmprendimientoDTO> listaEmprendimientos;
    private VBox panelDetalle;


    private Label lblNombre, lblSector;
    private Label lblLider, lblEdad, lblGpa, lblMatricula;
    private Label lblVentas;
    private Label lblStatsEventos, lblStatsAct, lblStatsMent;
    private Label lblNivelMadurez;


    private CheckBox chkMercado, chkFactEcon, chkFactTec;
    private TextArea txtJustifEco, txtJustifTec;

    private Button btnExportarPDF;


    private ReporteDAO dao;
    private ReporteEmprendimientoDTO reporteActual;

    public VistaReporteIndividual() {
        this.dao = new ReporteDAO();
        this.setPadding(new Insets(10));


        VBox panelIzquierdo = new VBox(5);
        Label lblLista = new Label("Seleccione Emprendimiento:");
        lblLista.setStyle("-fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        listaEmprendimientos = new ListView<>();
        listaEmprendimientos.setPrefWidth(280);


        listaEmprendimientos.setCellFactory(param -> new ListCell<ReporteEmprendimientoDTO>() {
            @Override
            protected void updateItem(ReporteEmprendimientoDTO item, boolean empty) {
                super.updateItem(item, empty);

                if (empty || item == null || item.getNombre() == null) {
                    setText(null);
                    setGraphic(null);
                } else {

                    setText(item.getNombre());


                    setStyle("-fx-font-size: 14px; -fx-padding: 5px;");
                }
            }
        });


        listaEmprendimientos.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            if (newVal != null) cargarDetalle(newVal.getIdEmprendimiento());
        });

        panelIzquierdo.getChildren().addAll(lblLista, listaEmprendimientos);
        VBox.setVgrow(listaEmprendimientos, Priority.ALWAYS);


        panelDetalle = crearPanelDetalle();


        SplitPane split = new SplitPane(panelIzquierdo, panelDetalle);
        split.setDividerPositions(0.3);

        this.setCenter(split);


        cargarListaInicial();
    }

    private void cargarListaInicial() {
        listaEmprendimientos.getItems().setAll(dao.listarEmprendimientosResumen());
    }

    private void cargarDetalle(int id) {
        this.reporteActual = dao.obtenerReportePorId(id);

        if (reporteActual != null) {

            lblNombre.setText(reporteActual.getNombre());
            lblSector.setText("Sector: " + reporteActual.getSector());


            lblLider.setText("Líder: " + reporteActual.getNombreLider() + " " + reporteActual.getApellidoLider());
            lblEdad.setText("Edad: " + reporteActual.getEdadLider() + " años");
            lblMatricula.setText("Matrícula: " + reporteActual.getMatricula());
            lblGpa.setText("GPA: " + reporteActual.getGpaLider());


            chkMercado.setSelected(reporteActual.isEstudioMercado());
            chkFactEcon.setSelected(reporteActual.isFactibleEconomicamente());
            chkFactTec.setSelected(reporteActual.isFactibleTecnicamente());

            txtJustifEco.setText(reporteActual.getJustificacionEconomica());
            txtJustifTec.setText(reporteActual.getJustificacionTecnica());


            lblVentas.setText(reporteActual.getVentas());
            lblStatsEventos.setText(String.valueOf(reporteActual.getTotalEventos()));
            lblStatsAct.setText(String.valueOf(reporteActual.getTotalActividades()));
            lblStatsMent.setText(String.valueOf(reporteActual.getTotalMentorias()));


            lblNivelMadurez.setText(reporteActual.getNivelMadurez());
            estilizarMadurez(reporteActual.getNivelMadurez());


            btnExportarPDF.setDisable(false);
            panelDetalle.setVisible(true);
        }
    }

    private VBox crearPanelDetalle() {
        VBox layout = new VBox(15);
        layout.setPadding(new Insets(20));
        layout.setVisible(false);


        HBox header = new HBox();
        header.setAlignment(Pos.CENTER_LEFT);

        VBox titles = new VBox(lblNombre = new Label("Nombre"), lblSector = new Label("-"));
        lblNombre.setFont(Font.font("Arial", FontWeight.BOLD, 24));
        lblNombre.setStyle("-fx-text-fill: #000b3d;");
        lblSector.setStyle("-fx-font-style: italic; -fx-text-fill: #7f8c8d;");

        Region spacer = new Region(); HBox.setHgrow(spacer, Priority.ALWAYS);

        btnExportarPDF = new Button("Descargar PDF");
        btnExportarPDF.setStyle("-fx-background-color: #000b3d; -fx-text-fill: white; -fx-font-weight: bold; -fx-cursor: hand; -fx-padding: 8 15 8 15;");
        btnExportarPDF.setDisable(true);
        btnExportarPDF.setOnAction(e -> accionPDF());

        header.getChildren().addAll(titles, spacer, btnExportarPDF);


        VBox boxLider = new VBox(8);
        boxLider.setStyle("-fx-background-color: #f4f6f7; -fx-padding: 15; -fx-background-radius: 8;");

        Label tituloLider = new Label("Datos del Líder Académico");
        tituloLider.setStyle("-fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        HBox datosLiderRow = new HBox(20);
        lblLider = new Label("-"); lblLider.setStyle("-fx-font-weight: bold;");
        lblEdad = new Label("-");
        lblMatricula = new Label("-");
        lblGpa = new Label("-"); lblGpa.setStyle("-fx-text-fill: #d35400; -fx-font-weight: bold;");

        datosLiderRow.getChildren().addAll(lblLider, lblEdad, lblMatricula, lblGpa);
        boxLider.getChildren().addAll(tituloLider, datosLiderRow);


        VBox boxViab = new VBox(10);


        HBox boxChecks = new HBox(20,
                chkMercado = new CheckBox("Estudio Mercado Realizado"),
                chkFactEcon = new CheckBox("Viabilidad Económica"),
                chkFactTec = new CheckBox("Viabilidad Técnica")
        );
        chkMercado.setDisable(true); chkFactEcon.setDisable(true); chkFactTec.setDisable(true);
        chkMercado.setStyle("-fx-opacity: 1; -fx-font-weight: bold;");
        chkFactEcon.setStyle("-fx-opacity: 1;"); chkFactTec.setStyle("-fx-opacity: 1;");


        GridPane gridJust = new GridPane();
        gridJust.setHgap(15); gridJust.setVgap(5);

        Label lEco = new Label("Justificación Económica:"); lEco.setStyle("-fx-font-weight: bold;");
        Label lTec = new Label("Justificación Técnica:"); lTec.setStyle("-fx-font-weight: bold;");

        txtJustifEco = new TextArea(); txtJustifEco.setPrefSize(350, 80); txtJustifEco.setEditable(false); txtJustifEco.setWrapText(true);
        txtJustifTec = new TextArea(); txtJustifTec.setPrefSize(350, 80); txtJustifTec.setEditable(false); txtJustifTec.setWrapText(true);

        gridJust.add(lEco, 0, 0); gridJust.add(txtJustifEco, 0, 1);
        gridJust.add(lTec, 1, 0); gridJust.add(txtJustifTec, 1, 1);

        boxViab.getChildren().addAll(new Separator(), new Label("Análisis de Viabilidad:"), boxChecks, gridJust);


        GridPane gridStats = new GridPane();
        gridStats.setHgap(20); gridStats.setVgap(10);
        gridStats.setPadding(new Insets(10, 0, 0, 0));

        gridStats.addRow(0, new Label("Eventos Asistidos:"), lblStatsEventos = new Label("0"));
        gridStats.addRow(1, new Label("Actividades Realizadas:"), lblStatsAct = new Label("0"));
        gridStats.addRow(2, new Label("Mentorías Recibidas:"), lblStatsMent = new Label("0"));
        gridStats.addRow(3, new Label("Ventas:"), lblVentas = new Label("-"));

        lblStatsEventos.setStyle("-fx-font-weight: bold;"); lblStatsAct.setStyle("-fx-font-weight: bold;");
        lblStatsMent.setStyle("-fx-font-weight: bold;"); lblVentas.setStyle("-fx-font-weight: bold;");


        HBox boxMad = new HBox(10, new Label("Nivel de Madurez Actual:"), lblNivelMadurez = new Label("-"));
        boxMad.setAlignment(Pos.CENTER_LEFT);
        lblNivelMadurez.setStyle("-fx-font-weight: bold; -fx-font-size: 16px;");


        layout.getChildren().addAll(header, boxLider, boxViab, new Separator(), gridStats, new Separator(), boxMad);
        return layout;
    }

    private void accionPDF() {
        FileChooser fc = new FileChooser();
        fc.setTitle("Guardar Reporte en PDF");
        fc.setInitialFileName("Reporte_" + reporteActual.getNombre().replace(" ", "_") + ".pdf");
        fc.getExtensionFilters().add(new FileChooser.ExtensionFilter("Archivos PDF", "*.pdf"));

        File f = fc.showSaveDialog(getScene().getWindow());
        if(f != null) {
            try {
                GeneradorPDF.generarReporteIndividual(reporteActual, f.getAbsolutePath());

                Alert alerta = new Alert(Alert.AlertType.INFORMATION);
                alerta.setTitle("Éxito");
                alerta.setHeaderText(null);
                alerta.setContentText("El PDF se ha guardado correctamente.");
                alerta.showAndWait();
            } catch(Exception e) {
                e.printStackTrace();
                Alert error = new Alert(Alert.AlertType.ERROR);
                error.setTitle("Error");
                error.setContentText("No se pudo crear el PDF: " + e.getMessage());
                error.showAndWait();
            }
        }
    }

    private void estilizarMadurez(String nivel) {
        String color = "black";
        if (nivel != null) {
            switch (nivel) {
                case "Prometedor": color = "#2980b9"; break;
                case "Desarrollo": color = "#27ae60"; break;
                case "Unico":      color = "#f39c12"; break;
                case "Basico":     color = "#7f8c8d"; break;
            }
        }
        lblNivelMadurez.setStyle("-fx-font-weight: bold; -fx-font-size: 18px; -fx-text-fill: " + color + ";");
    }
}