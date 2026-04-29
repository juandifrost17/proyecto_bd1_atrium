package InterfazGrafica.Modulos;

import Utils.LectorExcel;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.Separator;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.scene.text.TextAlignment;
import javafx.stage.FileChooser;

import java.io.File;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ModuloCargaExcel extends BorderPane {


    private VBox zonaBase;
    private Button btnBase;
    private VBox contenedorIconoBase;
    private Label lblInstruccionBase;
    private Label lblTituloBase;

    private VBox zonaExtra;
    private Button btnExtra;

    public ModuloCargaExcel() {
        this.setPadding(new Insets(30));


        Label lblTitulo = new Label("Centro de Carga de Datos");
        lblTitulo.setStyle("-fx-font-size: 24px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");
        Label lblSub = new Label("Gestiona la importación masiva de información a la base de datos.");
        lblSub.setStyle("-fx-font-size: 14px; -fx-text-fill: #7f8c8d;");

        VBox topContainer = new VBox(10, lblTitulo, lblSub, new Separator());
        topContainer.setPadding(new Insets(0, 0, 20, 0));
        this.setTop(topContainer);


        HBox contenedorCentral = new HBox(30);
        contenedorCentral.setAlignment(Pos.CENTER);


        zonaBase = crearZonaUI("Carga Inicial", "logo_base.png", "Importa Facultades, Lugares y Configuración Base.", "#3498db");
        lblTituloBase = (Label) zonaBase.getChildren().get(0);
        contenedorIconoBase = (VBox) zonaBase.getChildren().get(1);
        lblInstruccionBase = (Label) zonaBase.getChildren().get(2);
        btnBase = (Button) zonaBase.getChildren().get(3);

        btnBase.setOnAction(e -> abrirSelectorArchivo(true));


        zonaExtra = crearZonaUI("Agregar Más Datos", "logo_mas.png", "Sube nuevos Miembros, Staff o Eventos sin borrar lo anterior.", "#e67e22");
        btnExtra = (Button) zonaExtra.getChildren().get(3);

        btnExtra.setOnAction(e -> abrirSelectorArchivo(false));

        HBox.setHgrow(zonaBase, Priority.ALWAYS);
        HBox.setHgrow(zonaExtra, Priority.ALWAYS);
        contenedorCentral.getChildren().addAll(zonaBase, zonaExtra);

        this.setCenter(contenedorCentral);


        verificarEstadoInicial();
    }

    private VBox crearZonaUI(String titulo, String contenidoIcono, String descripcion, String colorHex) {
        VBox zona = new VBox(15);
        zona.setAlignment(Pos.CENTER);
        zona.setPadding(new Insets(30));
        zona.setUserData(colorHex);

        zona.setStyle("-fx-background-color: #fcfcfc; -fx-border-color: " + colorHex + "; -fx-border-width: 2px; -fx-border-style: dashed; -fx-border-radius: 15; -fx-background-radius: 15;");
        zona.setPrefHeight(350);
        zona.setMaxWidth(500);

        Label lblT = new Label(titulo);
        lblT.setStyle("-fx-font-size: 18px; -fx-font-weight: bold; -fx-text-fill: " + colorHex + ";");

        VBox iconContainer = new VBox();
        iconContainer.setAlignment(Pos.CENTER);
        iconContainer.setPrefHeight(80);

        colocarImagenOTexto(iconContainer, contenidoIcono);

        Label lblD = new Label(descripcion);
        lblD.setWrapText(true);
        lblD.setMaxWidth(300);
        lblD.setAlignment(Pos.CENTER);
        lblD.setTextAlignment(TextAlignment.CENTER);
        lblD.setStyle("-fx-font-size: 13px; -fx-text-fill: #7f8c8d;");

        Button btn = new Button("Subir Excel");
        btn.setStyle("-fx-background-color: " + colorHex + "; -fx-text-fill: white; -fx-font-weight: bold; -fx-cursor: hand; -fx-padding: 10 30; -fx-font-size: 14px;");

        zona.getChildren().addAll(lblT, iconContainer, lblD, btn);
        return zona;
    }


    private void colocarImagenOTexto(VBox container, String nombreRecurso) {
        container.getChildren().clear();
        try {
            InputStream stream = getClass().getResourceAsStream("/imagenes/" + nombreRecurso);
            if (stream != null) {
                Image img = new Image(stream);
                ImageView imgView = new ImageView(img);
                imgView.setFitHeight(80);
                imgView.setPreserveRatio(true);
                container.getChildren().add(imgView);
            } else {
                Label lbl = new Label(nombreRecurso.contains(".") ? "📷" : nombreRecurso);
                lbl.setStyle("-fx-font-size: 50px;");
                container.getChildren().add(lbl);
            }
        } catch (Exception e) {
            Label lbl = new Label("❓");
            lbl.setStyle("-fx-font-size: 50px;");
            container.getChildren().add(lbl);
        }
    }

    private void abrirSelectorArchivo(boolean esCargaBase) {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle(esCargaBase ? "Seleccionar Excel BASE" : "Seleccionar Excel ADICIONAL");
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("Archivos Excel", "*.xlsx"));

        File file = fileChooser.showOpenDialog(this.getScene().getWindow());

        if (file != null) {
            try {
                LectorExcel lector = new LectorExcel();
                lector.cargarTodoDesdeExcel(file.getAbsolutePath());

                mostrarAlerta(Alert.AlertType.INFORMATION, "Carga Exitosa",
                        "Los datos se han agregado correctamente.");

                if (esCargaBase) {
                    bloquearZonaBase();
                    desbloquearZonaExtra();
                }

            } catch (Exception e) {
                e.printStackTrace();
                mostrarAlerta(Alert.AlertType.ERROR, "Error de Carga",
                        "Falló la lectura del Excel.\nDetalle: " + e.getMessage());
            }
        }
    }

    private void bloquearZonaBase() {
        btnBase.setDisable(true);
        btnBase.setText("✔ Base Configurada");


        btnBase.setStyle("-fx-background-color: #27ae60; -fx-text-fill: white; -fx-font-weight: bold; -fx-opacity: 1.0;");


        colocarImagenOTexto(contenedorIconoBase, "logo_visto.png");

        lblInstruccionBase.setText("La estructura base ya existe. Usa el panel derecho en caso de que desees agregar más datos.");
        lblTituloBase.setStyle("-fx-font-size: 18px; -fx-font-weight: bold; -fx-text-fill: #27ae60;");


        zonaBase.setStyle("-fx-background-color: #eafaf1; -fx-border-color: #27ae60; -fx-border-width: 2px; -fx-border-radius: 15; -fx-background-radius: 15;");
    }

    private void bloquearZonaExtra() {
        btnExtra.setDisable(true);
        zonaExtra.setOpacity(0.5);
        zonaExtra.setStyle("-fx-background-color: #f0f0f0; -fx-border-color: #bdc3c7; -fx-border-width: 2px; -fx-border-style: dashed; -fx-border-radius: 15;");
    }

    private void desbloquearZonaExtra() {
        btnExtra.setDisable(false);
        zonaExtra.setOpacity(1.0);
        String colorOriginal = (String) zonaExtra.getUserData();
        zonaExtra.setStyle("-fx-background-color: #fcfcfc; -fx-border-color: " + colorOriginal + "; -fx-border-width: 2px; -fx-border-style: dashed; -fx-border-radius: 15;");
    }

    private void verificarEstadoInicial() {
        boolean hayDatos = false;

        String sql = "SELECT COUNT(*) FROM facultad";

        try (Connection conn = BaseDatos.ConexionDB.conectar()) {

            if (conn == null) {
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    if (rs.getInt(1) > 0) {
                        hayDatos = true;
                    }
                }

            } catch (Exception e) {

                try {
                    String sql2 = "SELECT COUNT(*) FROM \"Facultad\"";
                    PreparedStatement ps2 = conn.prepareStatement(sql2);
                    ResultSet rs2 = ps2.executeQuery();
                    if (rs2.next() && rs2.getInt(1) > 0) {
                        hayDatos = true;
                    }
                } catch (Exception ignored) { }
            }

        } catch (Exception ignored) { }


        if (hayDatos) {
            bloquearZonaBase();
            desbloquearZonaExtra();
        } else {
            bloquearZonaExtra();
        }
    }


    private void mostrarAlerta(Alert.AlertType tipo, String titulo, String msj) {
        Alert a = new Alert(tipo);
        a.setTitle(titulo);
        a.setHeaderText(null);
        a.setContentText(msj);
        a.showAndWait();
    }
}