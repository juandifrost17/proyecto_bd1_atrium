package Utils;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import Modelo.DTOs.ReporteEmprendimientoDTO;
import Modelo.DTOs.ReporteOperativoDTO;
import com.itextpdf.text.pdf.draw.LineSeparator;

import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class GeneradorPDF {

    private static final BaseColor COLOR_ENCABEZADO = new BaseColor(0, 11, 61);
    private static final Font FONT_HEADER_TABLA = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.WHITE);
    private static final Font FONT_CELDA = FontFactory.getFont(FontFactory.HELVETICA, 11, BaseColor.BLACK);

    public static void generarReporteIndividual(ReporteEmprendimientoDTO datos, String rutaDestino) throws Exception {
        Document document = new Document();
        PdfWriter.getInstance(document, new FileOutputStream(rutaDestino));
        document.open();


        PdfPTable headerTable = new PdfPTable(2);
        headerTable.setWidthPercentage(100);
        headerTable.setWidths(new float[]{1, 4});

        PdfPCell cellLogo = new PdfPCell();
        cellLogo.setBorder(Rectangle.NO_BORDER);
        try {
            Image logo = Image.getInstance(GeneradorPDF.class.getResource("/imagenes/logo_pdf.png"));
            logo.scaleToFit(80, 80);
            cellLogo.addElement(logo);
        } catch (Exception e) { cellLogo.addElement(new Phrase("LOGO")); }
        headerTable.addCell(cellLogo);

        Font fontTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, COLOR_ENCABEZADO);
        Paragraph pTitulo = new Paragraph("REPORTE PARA IDENTIFICAR/\nACTUALIZAR NIVEL DE MADUREZ", fontTitulo);
        pTitulo.setAlignment(Element.ALIGN_RIGHT);
        PdfPCell cellTitulo = new PdfPCell(pTitulo);
        cellTitulo.setBorder(Rectangle.NO_BORDER);
        cellTitulo.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cellTitulo.setHorizontalAlignment(Element.ALIGN_RIGHT);
        headerTable.addCell(cellTitulo);

        document.add(headerTable);
        document.add(Chunk.NEWLINE);


        PdfPTable tablaInfo = new PdfPTable(2);
        tablaInfo.setWidthPercentage(100);
        agregarCeldaHeader(tablaInfo, "Nombre del Emprendimiento");
        agregarCeldaHeader(tablaInfo, "Sector");
        agregarCeldaDato(tablaInfo, datos.getNombre());
        agregarCeldaDato(tablaInfo, datos.getSector());
        document.add(tablaInfo);


        PdfPTable tablaMad = new PdfPTable(2);
        tablaMad.setWidthPercentage(100);
        tablaMad.setSpacingBefore(10);
        agregarCeldaHeader(tablaMad, "Nivel de Madurez Actual");
        agregarCeldaHeader(tablaMad, "Ventas Reportadas");
        agregarCeldaDato(tablaMad, datos.getNivelMadurez());
        agregarCeldaDato(tablaMad, datos.getVentas());
        document.add(tablaMad);
        document.add(Chunk.NEWLINE);


        document.add(new Paragraph("Información del Líder", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, COLOR_ENCABEZADO)));
        PdfPTable tablaLider = new PdfPTable(4);
        tablaLider.setWidthPercentage(100);
        tablaLider.setSpacingBefore(5);
        agregarCeldaHeader(tablaLider, "Nombre Completo");
        agregarCeldaHeader(tablaLider, "Edad");
        agregarCeldaHeader(tablaLider, "Matrícula");
        agregarCeldaHeader(tablaLider, "GPA");
        agregarCeldaDato(tablaLider, datos.getNombreLider() + " " + datos.getApellidoLider());
        agregarCeldaDato(tablaLider, datos.getEdadLider() + " años");
        agregarCeldaDato(tablaLider, datos.getMatricula());
        agregarCeldaDato(tablaLider, String.valueOf(datos.getGpaLider()));
        document.add(tablaLider);
        document.add(Chunk.NEWLINE);


        document.add(new Paragraph("Análisis de Viabilidad Detallado", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, COLOR_ENCABEZADO)));


        PdfPTable tablaEstudio = new PdfPTable(2);
        tablaEstudio.setWidthPercentage(100);
        tablaEstudio.setSpacingBefore(10);
        tablaEstudio.setWidths(new float[]{3, 1});

        agregarCeldaHeader(tablaEstudio, "¿Cuenta con Estudio de Mercado Formal?");


        String estadoMercado = datos.isEstudioMercado() ? "SÍ, REALIZADO" : "NO / PENDIENTE";
        agregarCeldaDato(tablaEstudio, estadoMercado);

        document.add(tablaEstudio);


        PdfPTable tablaEco = new PdfPTable(2);
        tablaEco.setWidthPercentage(100);
        tablaEco.setSpacingBefore(5);
        tablaEco.setWidths(new float[]{1, 3});
        agregarCeldaHeader(tablaEco, "Viabilidad Económica");
        agregarCeldaHeader(tablaEco, "Justificación Financiera");
        agregarCeldaDato(tablaEco, datos.isFactibleEconomicamente() ? "VIABLE" : "NO VIABLE");
        agregarCeldaDatoIzq(tablaEco, datos.getJustificacionEconomica());
        document.add(tablaEco);


        PdfPTable tablaTec = new PdfPTable(2);
        tablaTec.setWidthPercentage(100);
        tablaTec.setSpacingBefore(5);
        tablaTec.setWidths(new float[]{1, 3});
        agregarCeldaHeader(tablaTec, "Viabilidad Técnica");
        agregarCeldaHeader(tablaTec, "Justificación Técnica");
        agregarCeldaDato(tablaTec, datos.isFactibleTecnicamente() ? "VIABLE" : "NO VIABLE");
        agregarCeldaDatoIzq(tablaTec, datos.getJustificacionTecnica());
        document.add(tablaTec);
        document.add(Chunk.NEWLINE);


        document.add(new Paragraph("Participación en el Ecosistema", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, COLOR_ENCABEZADO)));
        PdfPTable tablaPart = new PdfPTable(3);
        tablaPart.setWidthPercentage(100);
        tablaPart.setSpacingBefore(5);
        agregarCeldaHeader(tablaPart, "Eventos");
        agregarCeldaHeader(tablaPart, "Actividades");
        agregarCeldaHeader(tablaPart, "Mentorías");
        agregarCeldaDato(tablaPart, String.valueOf(datos.getTotalEventos()));
        agregarCeldaDato(tablaPart, String.valueOf(datos.getTotalActividades()));
        agregarCeldaDato(tablaPart, String.valueOf(datos.getTotalMentorias()));
        document.add(tablaPart);

        document.close();
    }

    private static void agregarCeldaHeader(PdfPTable tabla, String texto) {
        PdfPCell cell = new PdfPCell(new Phrase(texto, FONT_HEADER_TABLA));
        cell.setBackgroundColor(COLOR_ENCABEZADO);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setPadding(6);
        tabla.addCell(cell);
    }

    private static void agregarCeldaDato(PdfPTable tabla, String texto) {
        PdfPCell cell = new PdfPCell(new Phrase(texto == null ? "-" : texto, FONT_CELDA));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setPadding(6);
        tabla.addCell(cell);
    }

    private static void agregarCeldaDatoIzq(PdfPTable tabla, String texto) {
        PdfPCell cell = new PdfPCell(new Phrase(texto == null ? "Sin observaciones" : texto, FONT_CELDA));
        cell.setHorizontalAlignment(Element.ALIGN_LEFT);
        cell.setPadding(6);
        tabla.addCell(cell);
    }

    public void generarReporteOperativo(ReporteOperativoDTO datos, String rutaDestino) {
        Document document = new Document();

        try {
            PdfWriter.getInstance(document, new FileOutputStream(rutaDestino));
            document.open();


            agregarEncabezadoOperativo(document, datos);


            document.add(new Paragraph("\n"));
            agregarTablaTiempos(document, datos);


            document.add(new Paragraph("\n"));
            agregarSeccionAlertas(document, datos);


            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            Paragraph footer = new Paragraph("\n\nReporte generado el: " + sdf.format(new Date()),
                    FontFactory.getFont(FontFactory.HELVETICA, 10, BaseColor.GRAY));
            footer.setAlignment(Element.ALIGN_RIGHT);
            document.add(footer);

            System.out.println("PDF Operativo generado: " + rutaDestino);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            document.close();
        }
    }



    private void agregarTablaTiempos(Document doc, ReporteOperativoDTO datos) throws DocumentException {
        Font fuenteSub = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BaseColor.BLACK);
        doc.add(new Paragraph("Desglose de Inversión de Tiempo (Horas)", fuenteSub));
        doc.add(new Paragraph(" "));

        PdfPTable tabla = new PdfPTable(2);
        tabla.setWidthPercentage(100);
        tabla.setWidths(new float[]{3, 1});


        PdfPCell h1 = new PdfPCell(new Phrase("Indicador", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.WHITE)));
        PdfPCell h2 = new PdfPCell(new Phrase("Horas", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.WHITE)));


        h1.setBackgroundColor(COLOR_ENCABEZADO);
        h2.setBackgroundColor(COLOR_ENCABEZADO);

        h1.setPadding(8);
        h2.setPadding(8);
        h2.setHorizontalAlignment(Element.ALIGN_CENTER);

        tabla.addCell(h1);
        tabla.addCell(h2);



        agregarFila(tabla, "Horas Semanales del Equipo", datos.getHorasTotalesEquipo());
        agregarFila(tabla, "Horas Semanales del Líder", datos.getHorasSemanaLider());
        agregarFila(tabla, "Total Acumulado en Mentorías", datos.getHorasTotalMentorias());
        agregarFila(tabla, "Total Acumulado en Actividades", datos.getHorasTotalActividades());
        agregarFila(tabla, "Total Acumulado en Eventos", datos.getHorasTotalEventos());

        doc.add(tabla);
    }

    private void agregarSeccionAlertas(Document doc, ReporteOperativoDTO datos) throws DocumentException {
        Font fuenteSub = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BaseColor.BLACK);
        Font fuenteNormal = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.BLACK);
        Font fuenteRojo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.RED);
        Font fuenteVerde = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, new BaseColor(0, 128, 0));

        doc.add(new Paragraph("Recencia y Oportunidades", fuenteSub));


        List lista = new List(List.UNORDERED);
        lista.setListSymbol("\u2022");
        lista.add(new ListItem(" Última Mentoría: " + formatearFecha(datos.getFechaUltimaMentoria()), fuenteNormal));
        lista.add(new ListItem(" Última Actividad: " + formatearFecha(datos.getFechaUltimaActividad()), fuenteNormal));
        lista.add(new ListItem(" Último Evento: " + formatearFecha(datos.getFechaUltimoEvento()), fuenteNormal));
        doc.add(lista);

        doc.add(new Paragraph("\n"));


        Paragraph p = new Paragraph();
        p.add(new Chunk("Estado de Asistencia:\n", fuenteSub));

        if (datos.getActividadesPerdidas() > 0) {
            p.add(new Chunk("⚠ " + datos.getActividadesPerdidas() + " Actividades perdidas\n", fuenteRojo));
        } else {
            p.add(new Chunk("✔ Asistencia a Actividades Perfecta\n", fuenteVerde));
        }

        if (datos.getEventosPerdidos() > 0) {
            p.add(new Chunk("⚠ " + datos.getEventosPerdidos() + " Eventos perdidos", fuenteRojo));
        } else {
            p.add(new Chunk("✔ Asistencia a Eventos Perfecta", fuenteVerde));
        }
        doc.add(p);
    }



    private void agregarEncabezadoOperativo(Document doc, ReporteOperativoDTO datos) throws DocumentException, IOException {

        PdfPTable tablaBanner = new PdfPTable(2);
        tablaBanner.setWidthPercentage(100);
        tablaBanner.setWidths(new float[]{1, 5});
        tablaBanner.getDefaultCell().setBorder(Rectangle.NO_BORDER);


        PdfPCell celdaLogo = new PdfPCell();

        celdaLogo.setBorder(Rectangle.NO_BORDER);
        celdaLogo.setPadding(10);
        celdaLogo.setVerticalAlignment(Element.ALIGN_MIDDLE);
        celdaLogo.setHorizontalAlignment(Element.ALIGN_CENTER);

        try {

            Image logo = Image.getInstance("resources/imagenes/logo_pdf.png");
            logo.scaleToFit(50, 50);
            celdaLogo.addElement(logo);
        } catch (Exception e) {

            Paragraph p = new Paragraph("LOGO", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.WHITE));
            celdaLogo.addElement(p);
        }
        tablaBanner.addCell(celdaLogo);


        PdfPCell celdaTexto = new PdfPCell();

        celdaTexto.setBorder(Rectangle.NO_BORDER);
        celdaTexto.setPadding(10);
        celdaTexto.setVerticalAlignment(Element.ALIGN_MIDDLE);


        Font fuenteTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, COLOR_ENCABEZADO);
        Font fuenteSub = FontFactory.getFont(FontFactory.HELVETICA, 12, COLOR_ENCABEZADO);

        celdaTexto.addElement(new Paragraph("REPORTE OPERATIVO", fuenteTitulo));
        celdaTexto.addElement(new Paragraph("Emprendimiento: " + datos.getNombre().toUpperCase(), fuenteSub));

        tablaBanner.addCell(celdaTexto);


        doc.add(tablaBanner);


        doc.add(new Paragraph("\n"));

        PdfPTable tablaInfo = new PdfPTable(2);
        tablaInfo.setWidthPercentage(100);


        agregarDato(tablaInfo, "Sector:", datos.getSector());
        agregarDato(tablaInfo, "Estado Actual:", datos.getEstado());

        agregarDato(tablaInfo, "Fecha Registro:", formatearFecha(datos.getFechaRegistro()));
        agregarDato(tablaInfo, "Fecha Emisión:", new SimpleDateFormat("dd/MM/yyyy").format(new Date()));

        doc.add(tablaInfo);
        doc.add(new Chunk(new LineSeparator()));
        doc.add(new Paragraph("\n"));
    }

    private void agregarDato(PdfPTable t, String label, String valor) {
        PdfPCell c1 = new PdfPCell(new Phrase(label, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12)));
        PdfPCell c2 = new PdfPCell(new Phrase(valor != null ? valor : "-", FontFactory.getFont(FontFactory.HELVETICA, 12)));
        c1.setBorder(Rectangle.NO_BORDER); c2.setBorder(Rectangle.NO_BORDER);
        t.addCell(c1); t.addCell(c2);
    }

    private void agregarFila(PdfPTable t, String label, double valor) {
        t.addCell(new Phrase(label));
        PdfPCell c = new PdfPCell(new Phrase(String.format("%.1f", valor)));
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        t.addCell(c);
    }

    private String formatearFecha(java.util.Date fecha) {
        if (fecha == null) return "Sin registro";
        return new SimpleDateFormat("dd/MM/yyyy").format(fecha);
    }
}