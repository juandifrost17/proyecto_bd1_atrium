package InterfazGrafica;


import InterfazGrafica.Modulos.ModuloCargaExcel;
import InterfazGrafica.Modulos.ModuloEventos;
import InterfazGrafica.Modulos.ModuloReportes;
import InterfazGrafica.VistasFormulario.VistaBienvenida;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Cursor;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ContentDisplay;
import javafx.scene.control.Separator;
import javafx.scene.control.Tooltip;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.Priority;
import javafx.scene.layout.Region;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

import java.io.InputStream;

public class AtriumApp extends Application {

    private BorderPane rootLayout;

    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Atrium - Sistema de Gestión");

        rootLayout = new BorderPane();


        VBox sidebar = crearSidebar();
        rootLayout.setLeft(sidebar);


        cargarBienvenida();

        Scene scene = new Scene(rootLayout, 1100, 750);
        scene.getStylesheets().add(getClass().getResource("/estilos.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    private VBox crearSidebar() {
        VBox sidebar = new VBox(25);
        sidebar.setPadding(new Insets(30, 15, 30, 15));


        sidebar.setStyle("-fx-background-color: #000b3d;");
        sidebar.setPrefWidth(260);
        sidebar.setAlignment(Pos.TOP_CENTER);


        ImageView logoView = cargarImagen("logo_atrium.png", 150);
        if (logoView != null) {
            logoView.setCursor(Cursor.HAND);
            logoView.setOnMouseClicked(e -> cargarBienvenida());
        }

        Separator sep = new Separator();
        sep.setOpacity(0.2);
        sep.setPadding(new Insets(10, 20, 10, 20));




        Button btnEventos = crearBotonMenu("Gestión Eventos", "icono_evento.png");
        btnEventos.setOnAction(e -> cargarModuloEventos());


        Button btnReportes = crearBotonMenu("Reportes", "icono_reporte.png");
        btnReportes.setOnAction(e -> cargarModuloReportes());


        Button btnExcel = crearBotonMenu("Carga CSV", "icono_csv.png");
        btnExcel.setOnAction(e -> cargarModuloExcel());


        Region spacer = new Region();
        VBox.setVgrow(spacer, Priority.ALWAYS);


        Button btnSalir = crearBotonMenu("Salir", "icono_salir.png");
        btnSalir.setStyle("-fx-background-color: transparent; -fx-text-fill: #ff6b6b; -fx-font-weight: bold; -fx-font-size: 14px; -fx-cursor: hand;");
        btnSalir.setOnAction(e -> System.exit(0));



        if (logoView != null) {
            sidebar.getChildren().add(logoView);
        }
        sidebar.getChildren().addAll(sep, btnEventos, btnReportes, btnExcel, spacer, btnSalir);

        return sidebar;
    }



    private void cargarBienvenida() {
        VistaBienvenida vista = new VistaBienvenida();
        rootLayout.setCenter(vista);
    }

    private void cargarModuloEventos() {
        ModuloEventos modulo = new ModuloEventos();
        rootLayout.setCenter(modulo);
    }

    private void cargarModuloReportes() {
        ModuloReportes modulo = new ModuloReportes();
        rootLayout.setCenter(modulo);
    }

    private void cargarModuloExcel() {
        ModuloCargaExcel modulo = new ModuloCargaExcel();
        rootLayout.setCenter(modulo);
    }



    private Button crearBotonMenu(String texto, String nombreIcono) {
        Button btn = new Button(texto);
        btn.setPrefWidth(220);
        btn.setPrefHeight(50);
        btn.setAlignment(Pos.CENTER_LEFT);


        ImageView iconView = cargarImagen(nombreIcono, 24);
        if (iconView != null) {
            btn.setGraphic(iconView);
            btn.setGraphicTextGap(15);
        }


        String estiloBase = "-fx-background-color: transparent; " +
                "-fx-text-fill: white; " +
                "-fx-font-size: 15px; " +
                "-fx-cursor: hand; " +
                "-fx-border-color: transparent; " +
                "-fx-border-width: 0 0 0 4; " +
                "-fx-padding: 0 0 0 20;";


        String estiloHover = "-fx-background-color: #0f1c50; " +
                "-fx-text-fill: white; " +
                "-fx-font-size: 15px; " +
                "-fx-font-weight: bold; " +
                "-fx-cursor: hand; " +
                "-fx-border-color: #00d2d3; " +
                "-fx-border-width: 0 0 0 4; " +
                "-fx-padding: 0 0 0 20;";

        btn.setStyle(estiloBase);

        btn.setOnMouseEntered(e -> btn.setStyle(estiloHover));
        btn.setOnMouseExited(e -> {

            if (texto.equals("Salir")) {
                btn.setStyle("-fx-background-color: transparent; -fx-text-fill: #ff6b6b; -fx-font-weight: bold; -fx-font-size: 14px; -fx-cursor: hand;");
            } else {
                btn.setStyle(estiloBase);
            }
        });

        return btn;
    }


    private ImageView cargarImagen(String nombreArchivo, double ancho) {
        try {

            InputStream is = getClass().getResourceAsStream("/imagenes/" + nombreArchivo);
            if (is != null) {
                ImageView iv = new ImageView(new Image(is));
                iv.setFitWidth(ancho);
                iv.setPreserveRatio(true);
                return iv;
            } else {
                System.out.println("⚠️ Imagen no encontrada: /imagenes/" + nombreArchivo);
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void main(String[] args) {
        launch(args);
    }
}