--
-- PostgreSQL database dump
--

\restrict bX8RXdt9pcr1hPVHD0RHgqietTCAbhZ7GHMhsStq6TWDzjbVB0n9EWJ0IznS9YQ

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-16 23:46:45

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 279 (class 1255 OID 90464)
-- Name: fn_actividad(character varying, integer, character varying, character varying, character varying, date, double precision, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_actividad(p_accion character varying, p_id_actividad integer, p_tipo character varying DEFAULT NULL::character varying, p_nombre character varying DEFAULT NULL::character varying, p_descripcion character varying DEFAULT NULL::character varying, p_fecha date DEFAULT CURRENT_DATE, p_duracion_horas double precision DEFAULT NULL::double precision, p_id_expositor integer DEFAULT NULL::integer, p_id_lugar integer DEFAULT NULL::integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO actividad(id_actividad, tipo, nombre, descripcion, fecha, 
                             duracion_horas, id_expositor, id_lugar)
        VALUES (p_id_actividad, p_tipo, p_nombre, p_descripcion, p_fecha, 
                p_duracion_horas, p_id_expositor, p_id_lugar);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE actividad
        SET tipo = p_tipo,
            nombre = p_nombre,
            descripcion = p_descripcion,
            fecha = p_fecha,
            duracion_horas = p_duracion_horas,
            id_expositor = p_id_expositor,
            id_lugar = p_id_lugar
        WHERE id_actividad = p_id_actividad;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM actividad
        WHERE id_actividad = p_id_actividad;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_actividad=', id_actividad,
            ', tipo=', tipo,
            ', nombre=', nombre,
            ', descripcion=', descripcion,
            ', fecha=', fecha,
            ', duracion_horas=', duracion_horas,
            ', id_expositor=', id_expositor,
            ', id_lugar=', id_lugar
        )
        INTO v_result
        FROM actividad
        WHERE id_actividad = p_id_actividad;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_actividad(p_accion character varying, p_id_actividad integer, p_tipo character varying, p_nombre character varying, p_descripcion character varying, p_fecha date, p_duracion_horas double precision, p_id_expositor integer, p_id_lugar integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 106629)
-- Name: fn_bitacora_general(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_bitacora_general() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_obs TEXT;
BEGIN
    v_obs := 'En la tabla ' || TG_TABLE_NAME || ' se realizó un ' || TG_OP;

    INSERT INTO bitacora (accion, tabla, observacion, fecha, usuario)
    VALUES (TG_OP, TG_TABLE_NAME, v_obs, NOW(), current_user);

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION public.fn_bitacora_general() OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 90458)
-- Name: fn_carrera(character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_carrera(p_accion character varying, p_id_carrera integer, p_carrera character varying DEFAULT NULL::character varying, p_id_facultad integer DEFAULT NULL::integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO carrera(id_carrera, carrera, id_facultad)
        VALUES (p_id_carrera, p_carrera, p_id_facultad);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE carrera
        SET carrera = p_carrera,
            id_facultad = p_id_facultad
        WHERE id_carrera = p_id_carrera;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM carrera
        WHERE id_carrera = p_id_carrera;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_carrera=', id_carrera,
            ', carrera=', carrera,
            ', id_facultad=', id_facultad
        )
        INTO v_result
        FROM carrera
        WHERE id_carrera = p_id_carrera;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_carrera(p_accion character varying, p_id_carrera integer, p_carrera character varying, p_id_facultad integer) OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 106605)
-- Name: fn_crear_evento_seguro(character varying, character varying, date, double precision, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_crear_evento_seguro(p_nombre character varying, p_descripcion character varying, p_fecha date, p_duracion double precision, p_id_lugar integer, p_id_staff_coordinador integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_new_id_evento INTEGER;
    v_existe_staff BOOLEAN;
    v_existe_lugar BOOLEAN;
BEGIN

    SELECT EXISTS(SELECT 1 FROM staff WHERE id_staff = p_id_staff_coordinador) 
    INTO v_existe_staff;

    IF NOT v_existe_staff THEN
        
        RAISE EXCEPTION 'Error de Negocio: El ID de Staff % no existe.', p_id_staff_coordinador;
    END IF;

    SELECT EXISTS(SELECT 1 FROM lugar WHERE id_lugar = p_id_lugar) 
    INTO v_existe_lugar;

    IF NOT v_existe_lugar THEN
        RAISE EXCEPTION 'Error de Negocio: El ID de Lugar % no existe.', p_id_lugar;
    END IF;


    INSERT INTO evento (nombre, descripcion, fecha, duracion_horas, id_lugar)
    VALUES (p_nombre, p_descripcion, p_fecha, p_duracion, p_id_lugar)
    RETURNING id_evento INTO v_new_id_evento;


    INSERT INTO staff_evento (id_evento, id_staff, tarea, horas_asignadas)
    VALUES (v_new_id_evento, p_id_staff_coordinador, 'Coordinador', p_duracion); 


    RETURN v_new_id_evento;

 
END;
$$;


ALTER FUNCTION public.fn_crear_evento_seguro(p_nombre character varying, p_descripcion character varying, p_fecha date, p_duracion double precision, p_id_lugar integer, p_id_staff_coordinador integer) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 90457)
-- Name: fn_emprendimiento(character varying, integer, character varying, character varying, character varying, character varying, character varying, date, character varying, character varying, character varying, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_emprendimiento(p_accion character varying, p_id_emprendimiento integer, p_nombre character varying, p_sector character varying DEFAULT NULL::character varying, p_ciudad character varying DEFAULT NULL::character varying, p_pagina_web character varying DEFAULT NULL::character varying, p_red_social character varying DEFAULT NULL::character varying, p_fecha_registro date DEFAULT CURRENT_DATE, p_estado character varying DEFAULT NULL::character varying, p_modelo_negocio character varying DEFAULT NULL::character varying, p_etapa character varying DEFAULT NULL::character varying, p_nivel_madurez character varying DEFAULT NULL::character varying, p_presupuesto character varying DEFAULT NULL::character varying, p_ventas character varying DEFAULT NULL::character varying, p_id_estudio integer DEFAULT NULL::integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO emprendimiento(id_emprendimiento, nombre, sector, ciudad, pagina_web, 
                                  red_social, fecha_registro, estado, modelo_negocio, 
                                  etapa, nivel_madurez, presupuesto, ventas, id_estudio)
        VALUES (p_id_emprendimiento, p_nombre, p_sector, p_ciudad, p_pagina_web, 
                p_red_social, p_fecha_registro, p_estado, p_modelo_negocio, 
                p_etapa, p_nivel_madurez, p_presupuesto, p_ventas, p_id_estudio);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE emprendimiento
        SET nombre = p_nombre,
            sector = p_sector,
            ciudad = p_ciudad,
            pagina_web = p_pagina_web,
            red_social = p_red_social,
            fecha_registro = p_fecha_registro,
            estado = p_estado,
            modelo_negocio = p_modelo_negocio,
            etapa = p_etapa,
            nivel_madurez = p_nivel_madurez,
            presupuesto = p_presupuesto,
            ventas = p_ventas,
            id_estudio = p_id_estudio
        WHERE id_emprendimiento = p_id_emprendimiento;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM emprendimiento
        WHERE id_emprendimiento = p_id_emprendimiento;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_emprendimiento=', id_emprendimiento,
            ', nombre=', nombre,
            ', sector=', sector,
            ', ciudad=', ciudad,
            ', pagina_web=', pagina_web,
            ', red_social=', red_social,
            ', fecha_registro=', fecha_registro,
            ', estado=', estado,
            ', modelo_negocio=', modelo_negocio,
            ', etapa=', etapa,
            ', nivel_madurez=', nivel_madurez,
            ', presupuesto=', presupuesto,
            ', ventas=', ventas,
            ', id_estudio=', id_estudio
        )
        INTO v_result
        FROM emprendimiento
        WHERE id_emprendimiento = p_id_emprendimiento;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_emprendimiento(p_accion character varying, p_id_emprendimiento integer, p_nombre character varying, p_sector character varying, p_ciudad character varying, p_pagina_web character varying, p_red_social character varying, p_fecha_registro date, p_estado character varying, p_modelo_negocio character varying, p_etapa character varying, p_nivel_madurez character varying, p_presupuesto character varying, p_ventas character varying, p_id_estudio integer) OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 90467)
-- Name: fn_emprendimiento_actividad(character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_emprendimiento_actividad(p_accion character varying, p_id_emprendimiento integer, p_id_actividad integer, p_observacion character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO emprendimiento_actividad(id_emprendimiento, id_actividad, observacion)
        VALUES (p_id_emprendimiento, p_id_actividad, p_observacion);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE emprendimiento_actividad
        SET observacion = p_observacion
        WHERE id_emprendimiento = p_id_emprendimiento AND id_actividad = p_id_actividad;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM emprendimiento_actividad
        WHERE id_emprendimiento = p_id_emprendimiento AND id_actividad = p_id_actividad;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_emprendimiento=', id_emprendimiento,
            ', id_actividad=', id_actividad,
            ', observacion=', observacion
        )
        INTO v_result
        FROM emprendimiento_actividad
        WHERE id_emprendimiento = p_id_emprendimiento AND id_actividad = p_id_actividad;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_emprendimiento_actividad(p_accion character varying, p_id_emprendimiento integer, p_id_actividad integer, p_observacion character varying) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 90468)
-- Name: fn_emprendimiento_evento(character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_emprendimiento_evento(p_accion character varying, p_id_emprendimiento integer, p_id_evento integer, p_observacion character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO emprendimiento_evento(id_emprendimiento, id_evento, observacion)
        VALUES (p_id_emprendimiento, p_id_evento, p_observacion);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE emprendimiento_evento
        SET observacion = p_observacion
        WHERE id_emprendimiento = p_id_emprendimiento AND id_evento = p_id_evento;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM emprendimiento_evento
        WHERE id_emprendimiento = p_id_emprendimiento AND id_evento = p_id_evento;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_emprendimiento=', id_emprendimiento,
            ', id_evento=', id_evento,
            ', observacion=', observacion
        )
        INTO v_result
        FROM emprendimiento_evento
        WHERE id_emprendimiento = p_id_emprendimiento AND id_evento = p_id_evento;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_emprendimiento_evento(p_accion character varying, p_id_emprendimiento integer, p_id_evento integer, p_observacion character varying) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 90454)
-- Name: fn_estudio_mercado(character varying, integer, boolean, boolean, boolean, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_estudio_mercado(p_accion character varying, p_id_estudio integer, p_estudio_mercado boolean DEFAULT false, p_factible_economicamente boolean DEFAULT false, p_factible_tecnicamente boolean DEFAULT false, p_just_fact_econo character varying DEFAULT 'No se realizo un estudio de mercado'::character varying, p_just_fact_tecni character varying DEFAULT 'No se realizo un estudio de mercado'::character varying, p_publico_objetivo character varying DEFAULT 'No se realizo un estudio de mercado'::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO estudio_mercado(id_estudio, estudio_mercado, factible_economicamente, 
                                   factible_tecnicamente, just_fact_econo, just_fact_tecni, 
                                   publico_objetivo)
        VALUES (p_id_estudio, p_estudio_mercado, p_factible_economicamente, 
                p_factible_tecnicamente, p_just_fact_econo, p_just_fact_tecni, 
                p_publico_objetivo);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE estudio_mercado
        SET estudio_mercado = p_estudio_mercado,
            factible_economicamente = p_factible_economicamente,
            factible_tecnicamente = p_factible_tecnicamente,
            just_fact_econo = p_just_fact_econo,
            just_fact_tecni = p_just_fact_tecni,
            publico_objetivo = p_publico_objetivo
        WHERE id_estudio = p_id_estudio;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM estudio_mercado
        WHERE id_estudio = p_id_estudio;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_estudio=', id_estudio,
            ', estudio_mercado=', estudio_mercado,
            ', factible_economicamente=', factible_economicamente,
            ', factible_tecnicamente=', factible_tecnicamente,
            ', just_fact_econo=', just_fact_econo,
            ', just_fact_tecni=', just_fact_tecni,
            ', publico_objetivo=', publico_objetivo
        )
        INTO v_result
        FROM estudio_mercado
        WHERE id_estudio = p_id_estudio;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_estudio_mercado(p_accion character varying, p_id_estudio integer, p_estudio_mercado boolean, p_factible_economicamente boolean, p_factible_tecnicamente boolean, p_just_fact_econo character varying, p_just_fact_tecni character varying, p_publico_objetivo character varying) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 90465)
-- Name: fn_evento(character varying, integer, character varying, character varying, date, double precision, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_evento(p_accion character varying, p_id_evento integer DEFAULT NULL::integer, p_nombre character varying DEFAULT NULL::character varying, p_descripcion character varying DEFAULT NULL::character varying, p_fecha date DEFAULT CURRENT_DATE, p_duracion_horas double precision DEFAULT 1.0, p_id_lugar integer DEFAULT NULL::integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
    v_id_evento INTEGER;
BEGIN
    IF p_accion = 'I' THEN
        -- Para SERIAL, si no se proporciona ID, usar DEFAULT
        IF p_id_evento IS NULL THEN
            INSERT INTO evento(nombre, descripcion, fecha, duracion_horas, id_lugar)
            VALUES (p_nombre, p_descripcion, p_fecha, p_duracion_horas, p_id_lugar)
            RETURNING id_evento INTO v_id_evento;
            v_result := 'Registro insertado correctamente. ID generado: ' || v_id_evento;
        ELSE
            INSERT INTO evento(id_evento, nombre, descripcion, fecha, duracion_horas, id_lugar)
            VALUES (p_id_evento, p_nombre, p_descripcion, p_fecha, p_duracion_horas, p_id_lugar);
            v_result := 'Registro insertado correctamente.';
        END IF;
    ELSIF p_accion = 'U' THEN
        UPDATE evento
        SET nombre = p_nombre,
            descripcion = p_descripcion,
            fecha = p_fecha,
            duracion_horas = p_duracion_horas,
            id_lugar = p_id_lugar
        WHERE id_evento = p_id_evento;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM evento
        WHERE id_evento = p_id_evento;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_evento=', id_evento,
            ', nombre=', nombre,
            ', descripcion=', descripcion,
            ', fecha=', fecha,
            ', duracion_horas=', duracion_horas,
            ', id_lugar=', id_lugar
        )
        INTO v_result
        FROM evento
        WHERE id_evento = p_id_evento;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_evento(p_accion character varying, p_id_evento integer, p_nombre character varying, p_descripcion character varying, p_fecha date, p_duracion_horas double precision, p_id_lugar integer) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 90460)
-- Name: fn_expositor(character varying, integer, character varying, boolean, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_expositor(p_accion character varying, p_id_expositor integer, p_especialidad character varying DEFAULT NULL::character varying, p_activo boolean DEFAULT NULL::boolean, p_cedula character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO expositor(id_expositor, especialidad, activo, cedula)
        VALUES (p_id_expositor, p_especialidad, p_activo, p_cedula);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE expositor
        SET especialidad = p_especialidad,
            activo = p_activo,
            cedula = p_cedula
        WHERE id_expositor = p_id_expositor;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM expositor
        WHERE id_expositor = p_id_expositor;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_expositor=', id_expositor,
            ', especialidad=', especialidad,
            ', activo=', activo,
            ', cedula=', cedula
        )
        INTO v_result
        FROM expositor
        WHERE id_expositor = p_id_expositor;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_expositor(p_accion character varying, p_id_expositor integer, p_especialidad character varying, p_activo boolean, p_cedula character varying) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 90453)
-- Name: fn_facultad(character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_facultad(p_accion character varying, p_id_facultad integer, p_facultad character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO facultad(id_facultad, facultad)
        VALUES (p_id_facultad, p_facultad);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE facultad
        SET facultad = p_facultad
        WHERE id_facultad = p_id_facultad;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM facultad
        WHERE id_facultad = p_id_facultad;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_facultad=', id_facultad,
            ', facultad=', facultad
        )
        INTO v_result
        FROM facultad
        WHERE id_facultad = p_id_facultad;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_facultad(p_accion character varying, p_id_facultad integer, p_facultad character varying) OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 90456)
-- Name: fn_lugar(character varying, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_lugar(p_accion character varying, p_id_lugar integer, p_nombre character varying DEFAULT NULL::character varying, p_direccion character varying DEFAULT NULL::character varying, p_ciudad character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO lugar(id_lugar, nombre, direccion, ciudad)
        VALUES (p_id_lugar, p_nombre, p_direccion, p_ciudad);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE lugar
        SET nombre = p_nombre,
            direccion = p_direccion,
            ciudad = p_ciudad
        WHERE id_lugar = p_id_lugar;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM lugar
        WHERE id_lugar = p_id_lugar;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_lugar=', id_lugar,
            ', nombre=', nombre,
            ', direccion=', direccion,
            ', ciudad=', ciudad
        )
        INTO v_result
        FROM lugar
        WHERE id_lugar = p_id_lugar;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_lugar(p_accion character varying, p_id_lugar integer, p_nombre character varying, p_direccion character varying, p_ciudad character varying) OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 90459)
-- Name: fn_mentor(character varying, integer, character varying, boolean, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_mentor(p_accion character varying, p_id_mentor integer, p_especialidad character varying DEFAULT NULL::character varying, p_activo boolean DEFAULT NULL::boolean, p_cedula character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO mentor(id_mentor, especialidad, activo, cedula)
        VALUES (p_id_mentor, p_especialidad, p_activo, p_cedula);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE mentor
        SET especialidad = p_especialidad,
            activo = p_activo,
            cedula = p_cedula
        WHERE id_mentor = p_id_mentor;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM mentor
        WHERE id_mentor = p_id_mentor;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_mentor=', id_mentor,
            ', especialidad=', especialidad,
            ', activo=', activo,
            ', cedula=', cedula
        )
        INTO v_result
        FROM mentor
        WHERE id_mentor = p_id_mentor;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_mentor(p_accion character varying, p_id_mentor integer, p_especialidad character varying, p_activo boolean, p_cedula character varying) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 90469)
-- Name: fn_mentoria(character varying, integer, character varying, character varying, character varying, date, double precision, character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_mentoria(p_accion character varying, p_id_mentoria integer, p_tema character varying DEFAULT NULL::character varying, p_contenido character varying DEFAULT NULL::character varying, p_observacion character varying DEFAULT NULL::character varying, p_fecha date DEFAULT CURRENT_DATE, p_duracion_horas double precision DEFAULT 0, p_modalidad character varying DEFAULT NULL::character varying, p_locacion character varying DEFAULT NULL::character varying, p_id_mentor integer DEFAULT NULL::integer, p_id_emprendimiento integer DEFAULT NULL::integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO mentoria(id_mentoria, tema, contenido, observacion, fecha, 
                           duracion_horas, modalidad, locacion, id_mentor, id_emprendimiento)
        VALUES (p_id_mentoria, p_tema, p_contenido, p_observacion, p_fecha, 
                p_duracion_horas, p_modalidad, p_locacion, p_id_mentor, p_id_emprendimiento);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE mentoria
        SET tema = p_tema,
            contenido = p_contenido,
            observacion = p_observacion,
            fecha = p_fecha,
            duracion_horas = p_duracion_horas,
            modalidad = p_modalidad,
            locacion = p_locacion,
            id_mentor = p_id_mentor,
            id_emprendimiento = p_id_emprendimiento
        WHERE id_mentoria = p_id_mentoria;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM mentoria
        WHERE id_mentoria = p_id_mentoria;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_mentoria=', id_mentoria,
            ', tema=', tema,
            ', contenido=', contenido,
            ', observacion=', observacion,
            ', fecha=', fecha,
            ', duracion_horas=', duracion_horas,
            ', modalidad=', modalidad,
            ', locacion=', locacion,
            ', id_mentor=', id_mentor,
            ', id_emprendimiento=', id_emprendimiento
        )
        INTO v_result
        FROM mentoria
        WHERE id_mentoria = p_id_mentoria;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_mentoria(p_accion character varying, p_id_mentoria integer, p_tema character varying, p_contenido character varying, p_observacion character varying, p_fecha date, p_duracion_horas double precision, p_modalidad character varying, p_locacion character varying, p_id_mentor integer, p_id_emprendimiento integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 90462)
-- Name: fn_miembro(character varying, integer, character varying, double precision, date, date, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_miembro(p_accion character varying, p_id_miembro integer, p_rol character varying DEFAULT NULL::character varying, p_horas_semana double precision DEFAULT NULL::double precision, p_fecha_ingreso date DEFAULT CURRENT_DATE, p_fecha_salida date DEFAULT NULL::date, p_id_emprendimiento integer DEFAULT NULL::integer, p_cedula character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO miembro(id_miembro, rol, horas_semana, fecha_ingreso, fecha_salida, 
                           id_emprendimiento, cedula)
        VALUES (p_id_miembro, p_rol, p_horas_semana, p_fecha_ingreso, p_fecha_salida, 
                p_id_emprendimiento, p_cedula);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE miembro
        SET rol = p_rol,
            horas_semana = p_horas_semana,
            fecha_ingreso = p_fecha_ingreso,
            fecha_salida = p_fecha_salida,
            id_emprendimiento = p_id_emprendimiento,
            cedula = p_cedula
        WHERE id_miembro = p_id_miembro;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM miembro
        WHERE id_miembro = p_id_miembro;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_miembro=', id_miembro,
            ', rol=', rol,
            ', horas_semana=', horas_semana,
            ', fecha_ingreso=', fecha_ingreso,
            ', fecha_salida=', fecha_salida,
            ', id_emprendimiento=', id_emprendimiento,
            ', cedula=', cedula
        )
        INTO v_result
        FROM miembro
        WHERE id_miembro = p_id_miembro;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_miembro(p_accion character varying, p_id_miembro integer, p_rol character varying, p_horas_semana double precision, p_fecha_ingreso date, p_fecha_salida date, p_id_emprendimiento integer, p_cedula character varying) OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 90470)
-- Name: fn_participacion_miembro(character varying, integer, integer, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_participacion_miembro(p_accion character varying, p_id_miembro integer, p_id_mentoria integer, p_participacion double precision DEFAULT 70) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO participacion_miembro(id_miembro, id_mentoria, participacion)
        VALUES (p_id_miembro, p_id_mentoria, p_participacion);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE participacion_miembro
        SET participacion = p_participacion
        WHERE id_miembro = p_id_miembro AND id_mentoria = p_id_mentoria;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM participacion_miembro
        WHERE id_miembro = p_id_miembro AND id_mentoria = p_id_mentoria;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_miembro=', id_miembro,
            ', id_mentoria=', id_mentoria,
            ', participacion=', participacion
        )
        INTO v_result
        FROM participacion_miembro
        WHERE id_miembro = p_id_miembro AND id_mentoria = p_id_mentoria;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_participacion_miembro(p_accion character varying, p_id_miembro integer, p_id_mentoria integer, p_participacion double precision) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 90463)
-- Name: fn_perfil_academico(character varying, integer, integer, double precision, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_perfil_academico(p_accion character varying, p_id_miembro integer, p_matricula integer DEFAULT NULL::integer, p_gpa double precision DEFAULT NULL::double precision, p_mat_aprobadas integer DEFAULT 0, p_mat_actuales integer DEFAULT 0, p_id_carrera integer DEFAULT NULL::integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO perfil_academico(id_miembro, matricula, gpa, mat_aprobadas, 
                                    mat_actuales, id_carrera)
        VALUES (p_id_miembro, p_matricula, p_gpa, p_mat_aprobadas, 
                p_mat_actuales, p_id_carrera);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE perfil_academico
        SET matricula = p_matricula,
            gpa = p_gpa,
            mat_aprobadas = p_mat_aprobadas,
            mat_actuales = p_mat_actuales,
            id_carrera = p_id_carrera
        WHERE id_miembro = p_id_miembro;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM perfil_academico
        WHERE id_miembro = p_id_miembro;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_miembro=', id_miembro,
            ', matricula=', matricula,
            ', gpa=', gpa,
            ', mat_aprobadas=', mat_aprobadas,
            ', mat_actuales=', mat_actuales,
            ', id_carrera=', id_carrera
        )
        INTO v_result
        FROM perfil_academico
        WHERE id_miembro = p_id_miembro;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_perfil_academico(p_accion character varying, p_id_miembro integer, p_matricula integer, p_gpa double precision, p_mat_aprobadas integer, p_mat_actuales integer, p_id_carrera integer) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 115145)
-- Name: fn_persona(character varying, character varying, character varying, character varying, date, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_persona(p_accion character varying, p_cedula character varying, p_nombre character varying DEFAULT NULL::character varying, p_apellido character varying DEFAULT NULL::character varying, p_fecha_nacimiento date DEFAULT NULL::date, p_telefono character varying DEFAULT NULL::character varying, p_correo character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    -- INSERTAR
    IF p_accion = 'I' THEN
        INSERT INTO persona(cedula, nombre, apellido, fecha_nacimiento, telefono, correo)
        VALUES (p_cedula, p_nombre, p_apellido, p_fecha_nacimiento, p_telefono, p_correo)
        ON CONFLICT (cedula) DO NOTHING; -- Evita error si ya existe
        
        v_result := 'Persona insertada correctamente.';

    -- ACTUALIZAR
    ELSIF p_accion = 'U' THEN
        UPDATE persona
        SET nombre = p_nombre,
            apellido = p_apellido,
            fecha_nacimiento = p_fecha_nacimiento,
            telefono = p_telefono,
            correo = p_correo
        WHERE cedula = p_cedula;
        
        v_result := 'Persona actualizada correctamente.';

    -- ELIMINAR
    ELSIF p_accion = 'D' THEN
        DELETE FROM persona
        WHERE cedula = p_cedula;
        
        v_result := 'Persona eliminada correctamente.';

    -- SELECCIONAR
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'cedula=', cedula,
            ', nombre=', nombre,
            ', apellido=', apellido,
            ', fecha=', fecha_nacimiento,
            ', telefono=', telefono,
            ', correo=', correo
        )
        INTO v_result
        FROM persona
        WHERE cedula = p_cedula;

        IF v_result IS NULL THEN
            v_result := 'No se encontró la persona.';
        END IF;
    
    ELSE
        v_result := 'Acción no válida.';
    END IF;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN 'Error: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.fn_persona(p_accion character varying, p_cedula character varying, p_nombre character varying, p_apellido character varying, p_fecha_nacimiento date, p_telefono character varying, p_correo character varying) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 123449)
-- Name: fn_reporte1_por_emprendimiento(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_reporte1_por_emprendimiento(p_id_emprendimiento integer) RETURNS TABLE(id_emprendimiento integer, nombre_emprendimiento character varying, sector character varying, nivel_madurez character varying, estudio_mercado boolean, factible_economicamente boolean, just_fact_econo character varying, factible_tecnicamente boolean, just_fact_tecni character varying, ventas character varying, total_eventos bigint, total_actividades bigint, total_mentorias bigint, nombre_lider character varying, apellido_lider character varying, edad_lider integer, matricula character varying, gpa_lider numeric, materias_actuales_lider integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_emprendimiento, r.nombre_emprendimiento, r.sector, r.nivel_madurez,
        r.estudio_mercado, 
        r.factible_economicamente, r.just_fact_econo,
        r.factible_tecnicamente, r.just_fact_tecni,
        r.ventas, r.total_eventos, r.total_actividades, r.total_mentorias,
        r.nombre_lider, r.apellido_lider, 
        r.edad_lider, 
        r.matricula, 
        r.gpa_lider, 
        r.materias_actuales_lider
    FROM mv_reporte_rendimiento_emprendimiento r
    WHERE r.id_emprendimiento = p_id_emprendimiento;
END;
$$;


ALTER FUNCTION public.fn_reporte1_por_emprendimiento(p_id_emprendimiento integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 114814)
-- Name: fn_reporte2_estado_operativo(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_reporte2_estado_operativo(p_id_emprendimiento integer) RETURNS TABLE(id_emprendimiento integer, nombre_emprendimiento character varying, sector character varying, fecha_registro date, estado character varying, fecha_ultima_mentoria date, fecha_ultima_actividad date, fecha_ultimo_evento date, horas_totales_semana_equipo numeric, horas_semana_lider numeric, horas_total_mentorias numeric, horas_total_actividades numeric, horas_total_eventos numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        id_emprendimiento,
        nombre_emprendimiento,
        sector,
        fecha_registro,
        estado,
        fecha_ultima_mentoria,
        fecha_ultima_actividad,
        fecha_ultimo_evento,
        horas_totales_semana_equipo,
        horas_semana_lider,
        horas_total_mentorias,
        horas_total_actividades,
        horas_total_eventos
    FROM mv_reporte_estado_operativo
    WHERE id_emprendimiento = p_id_emprendimiento;
END;
$$;


ALTER FUNCTION public.fn_reporte2_estado_operativo(p_id_emprendimiento integer) OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 122990)
-- Name: fn_reporte2_estado_operativo_por_emprendimiento(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_reporte2_estado_operativo_por_emprendimiento(p_id_emprendimiento integer) RETURNS TABLE(id_emprendimiento integer, nombre_emprendimiento character varying, sector character varying, fecha_registro date, estado character varying, fecha_ultima_mentoria date, fecha_ultima_actividad date, fecha_ultimo_evento date, actividades_perdidas integer, eventos_perdidos integer, horas_totales_semana_equipo double precision, horas_semana_lider double precision, horas_total_mentorias double precision, horas_total_actividades double precision, horas_total_eventos double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        mv.id_emprendimiento,
        mv.nombre_emprendimiento,
        mv.sector,
        mv.fecha_registro,
        mv.estado,

        mv.fecha_ultima_mentoria,
        mv.fecha_ultima_actividad,
        mv.fecha_ultimo_evento,

        mv.actividades_perdidas,
        mv.eventos_perdidos,

        mv.horas_totales_semana_equipo,
        mv.horas_semana_lider,

        mv.horas_total_mentorias,
        mv.horas_total_actividades,
        mv.horas_total_eventos
    FROM mv_reporte_estado_operativo mv
    WHERE mv.id_emprendimiento = p_id_emprendimiento;
END;
$$;


ALTER FUNCTION public.fn_reporte2_estado_operativo_por_emprendimiento(p_id_emprendimiento integer) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 90461)
-- Name: fn_staff(character varying, integer, character varying, boolean, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_staff(p_accion character varying, p_id_staff integer, p_cargo character varying DEFAULT NULL::character varying, p_activo boolean DEFAULT NULL::boolean, p_cedula character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO staff(id_staff, cargo, activo, cedula)
        VALUES (p_id_staff, p_cargo, p_activo, p_cedula);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE staff
        SET cargo = p_cargo,
            activo = p_activo,
            cedula = p_cedula
        WHERE id_staff = p_id_staff;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM staff
        WHERE id_staff = p_id_staff;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_staff=', id_staff,
            ', cargo=', cargo,
            ', activo=', activo,
            ', cedula=', cedula
        )
        INTO v_result
        FROM staff
        WHERE id_staff = p_id_staff;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_staff(p_accion character varying, p_id_staff integer, p_cargo character varying, p_activo boolean, p_cedula character varying) OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 90466)
-- Name: fn_staff_evento(character varying, integer, integer, double precision, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_staff_evento(p_accion character varying, p_id_evento integer, p_id_staff integer, p_horas_asignadas double precision DEFAULT 0, p_tarea character varying DEFAULT NULL::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result TEXT;
BEGIN
    IF p_accion = 'I' THEN
        INSERT INTO staff_evento(id_evento, id_staff, horas_asignadas, tarea)
        VALUES (p_id_evento, p_id_staff, p_horas_asignadas, p_tarea);
        v_result := 'Registro insertado correctamente.';
    ELSIF p_accion = 'U' THEN
        UPDATE staff_evento
        SET horas_asignadas = p_horas_asignadas,
            tarea = p_tarea
        WHERE id_evento = p_id_evento AND id_staff = p_id_staff;
        v_result := 'Registro actualizado correctamente.';
    ELSIF p_accion = 'D' THEN
        DELETE FROM staff_evento
        WHERE id_evento = p_id_evento AND id_staff = p_id_staff;
        v_result := 'Registro eliminado correctamente.';
    ELSIF p_accion = 'S' THEN
        SELECT CONCAT(
            'id_evento=', id_evento,
            ', id_staff=', id_staff,
            ', horas_asignadas=', horas_asignadas,
            ', tarea=', tarea
        )
        INTO v_result
        FROM staff_evento
        WHERE id_evento = p_id_evento AND id_staff = p_id_staff;
        IF v_result IS NULL THEN
            v_result := 'No se encontró el registro solicitado.';
        END IF;
    ELSE
        v_result := 'Acción no válida. Use I, U, D o S.';
    END IF;
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.fn_staff_evento(p_accion character varying, p_id_evento integer, p_id_staff integer, p_horas_asignadas double precision, p_tarea character varying) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 123056)
-- Name: fn_validar_disponibilidad_lugar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_validar_disponibilidad_lugar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM evento
        WHERE id_lugar = NEW.id_lugar
          AND fecha = NEW.fecha
          AND id_evento <> COALESCE(NEW.id_evento, -1)
    ) THEN
        RAISE EXCEPTION 'El lugar ya está ocupado en esa fecha';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_validar_disponibilidad_lugar() OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 123058)
-- Name: fn_validar_edad_miembro(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_validar_edad_miembro() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_fecha DATE;
BEGIN
    SELECT fecha_nacimiento
    INTO v_fecha
    FROM persona
    WHERE cedula = NEW.cedula;

    IF v_fecha IS NULL THEN
        RAISE EXCEPTION 'La persona no tiene fecha de nacimiento registrada';
    END IF;

    IF age(CURRENT_DATE, v_fecha) < INTERVAL '18 years' THEN
        RAISE EXCEPTION 'El miembro debe ser mayor de 18 años';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_validar_edad_miembro() OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 123380)
-- Name: fn_validar_mentoria(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_validar_mentoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.duracion_horas IS NULL OR NEW.duracion_horas <= 0 THEN
        RAISE EXCEPTION 'La duración de la mentoría debe ser mayor a 0';
    END IF;

    IF NEW.modalidad NOT IN ('Virtual', 'Presencial') THEN
        RAISE EXCEPTION 'Modalidad inválida: %', NEW.modalidad;
    END IF;

    IF NEW.modalidad = 'Virtual' AND NEW.locacion IS NOT NULL THEN
        RAISE EXCEPTION 'Una mentoría virtual no debe tener locación';
    END IF;

    IF NEW.modalidad = 'Presencial' AND NEW.locacion IS NULL THEN
        RAISE EXCEPTION 'Una mentoría presencial requiere locación';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_validar_mentoria() OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 114789)
-- Name: fn_verificar_coordinador_evento_defer(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_verificar_coordinador_evento_defer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_coordinadores_count INT;
BEGIN
  
    SELECT COUNT(*) INTO v_coordinadores_count
    FROM staff_evento se
    JOIN staff s ON s.id_staff = se.id_staff
    WHERE se.id_evento = NEW.id_evento
      AND s.cargo ILIKE 'Coordinador'; 

    IF v_coordinadores_count = 0 THEN
        RAISE EXCEPTION 'Error de Negocio: El evento "%" (ID: %) no tiene un COORDINADOR asignado. Asigne uno antes de guardar.', NEW.nombre, NEW.id_evento;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_verificar_coordinador_evento_defer() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 232 (class 1259 OID 123180)
-- Name: actividad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actividad (
    id_actividad integer NOT NULL,
    tipo character varying(30),
    nombre character varying(50),
    descripcion character varying(255),
    fecha date,
    duracion_horas double precision,
    id_expositor integer,
    id_lugar integer
);


ALTER TABLE public.actividad OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 75319)
-- Name: bitacora_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bitacora_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bitacora_id_seq OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 123297)
-- Name: bitacora; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bitacora (
    id_bitacora integer DEFAULT nextval('public.bitacora_id_seq'::regclass) NOT NULL,
    accion character varying(20),
    tabla character varying(50),
    observacion character varying(100),
    fecha timestamp without time zone DEFAULT now(),
    usuario character varying(20)
);


ALTER TABLE public.bitacora OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 123104)
-- Name: carrera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carrera (
    id_carrera integer NOT NULL,
    carrera character varying(50),
    id_facultad integer
);


ALTER TABLE public.carrera OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 123091)
-- Name: emprendimiento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emprendimiento (
    id_emprendimiento integer NOT NULL,
    nombre character varying(50),
    sector character varying(50),
    ciudad character varying(30),
    pagina_web character varying(255),
    red_social character varying(255),
    fecha_registro date,
    estado character varying(20),
    modelo_negocio character varying(30),
    etapa character varying(30),
    nivel_madurez character varying(30),
    presupuesto character varying(150),
    ventas character varying(50),
    id_estudio integer
);


ALTER TABLE public.emprendimiento OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 123226)
-- Name: emprendimiento_actividad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emprendimiento_actividad (
    id_emprendimiento integer NOT NULL,
    id_actividad integer NOT NULL,
    observacion character varying(512)
);


ALTER TABLE public.emprendimiento_actividad OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 123245)
-- Name: emprendimiento_evento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emprendimiento_evento (
    id_emprendimiento integer NOT NULL,
    id_evento integer NOT NULL,
    observacion character varying(512)
);


ALTER TABLE public.emprendimiento_evento OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 123071)
-- Name: estudio_mercado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estudio_mercado (
    id_estudio integer NOT NULL,
    estudio_mercado boolean,
    factible_economicamente boolean,
    factible_tecnicamente boolean,
    just_fact_econo character varying(512),
    just_fact_tecni character varying(512),
    publico_objetivo character varying(100)
);


ALTER TABLE public.estudio_mercado OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 123197)
-- Name: evento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evento (
    id_evento integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(255) NOT NULL,
    fecha date NOT NULL,
    duracion_horas double precision,
    id_lugar integer NOT NULL,
    CONSTRAINT chk_duracion_valida CHECK (((duracion_horas >= (1)::double precision) AND (duracion_horas <= (24)::double precision)))
);


ALTER TABLE public.evento OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 123196)
-- Name: evento_id_evento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.evento_id_evento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.evento_id_evento_seq OWNER TO postgres;

--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 233
-- Name: evento_id_evento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.evento_id_evento_seq OWNED BY public.evento.id_evento;


--
-- TOC entry 219 (class 1259 OID 74818)
-- Name: evento_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.evento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.evento_id_seq OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 123126)
-- Name: expositor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expositor (
    id_expositor integer NOT NULL,
    especialidad character varying(50),
    activo boolean,
    cedula character varying(20)
);


ALTER TABLE public.expositor OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 123065)
-- Name: facultad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facultad (
    id_facultad integer NOT NULL,
    facultad character varying(30)
);


ALTER TABLE public.facultad OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 123085)
-- Name: lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lugar (
    id_lugar integer NOT NULL,
    nombre character varying(50),
    direccion character varying(255),
    ciudad character varying(30)
);


ALTER TABLE public.lugar OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 123115)
-- Name: mentor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mentor (
    id_mentor integer NOT NULL,
    especialidad character varying(50),
    activo boolean,
    cedula character varying(20)
);


ALTER TABLE public.mentor OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 123264)
-- Name: mentoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mentoria (
    id_mentoria integer NOT NULL,
    tema character varying(50),
    contenido character varying(100),
    observacion character varying(150),
    fecha date,
    duracion_horas double precision,
    modalidad character varying(10),
    locacion character varying(150),
    id_mentor integer,
    id_emprendimiento integer
);


ALTER TABLE public.mentoria OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 123148)
-- Name: miembro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.miembro (
    id_miembro integer NOT NULL,
    rol character varying(50),
    horas_semana double precision,
    fecha_ingreso date,
    fecha_salida date,
    id_emprendimiento integer,
    cedula character varying(20)
);


ALTER TABLE public.miembro OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 123450)
-- Name: mv_reporte_estado_operativo; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_reporte_estado_operativo AS
 SELECT id_emprendimiento,
    nombre AS nombre_emprendimiento,
    sector,
    fecha_registro,
    estado,
    ( SELECT max(mn.fecha) AS max
           FROM public.mentoria mn
          WHERE (mn.id_emprendimiento = e.id_emprendimiento)) AS fecha_ultima_mentoria,
    ( SELECT max(a.fecha) AS max
           FROM (public.emprendimiento_actividad ea
             JOIN public.actividad a ON ((a.id_actividad = ea.id_actividad)))
          WHERE (ea.id_emprendimiento = e.id_emprendimiento)) AS fecha_ultima_actividad,
    ( SELECT max(ev.fecha) AS max
           FROM (public.emprendimiento_evento ee
             JOIN public.evento ev ON ((ev.id_evento = ee.id_evento)))
          WHERE (ee.id_emprendimiento = e.id_emprendimiento)) AS fecha_ultimo_evento,
    (COALESCE(( SELECT max(actividad.id_actividad) AS max
           FROM public.actividad), 0) - COALESCE(( SELECT max(emprendimiento_actividad.id_actividad) AS max
           FROM public.emprendimiento_actividad
          WHERE (emprendimiento_actividad.id_emprendimiento = e.id_emprendimiento)), 0)) AS actividades_perdidas,
    (COALESCE(( SELECT max(evento.id_evento) AS max
           FROM public.evento), 0) - COALESCE(( SELECT max(emprendimiento_evento.id_evento) AS max
           FROM public.emprendimiento_evento
          WHERE (emprendimiento_evento.id_emprendimiento = e.id_emprendimiento)), 0)) AS eventos_perdidos,
    ( SELECT COALESCE(sum(m.horas_semana), (0)::double precision) AS "coalesce"
           FROM public.miembro m
          WHERE (m.id_emprendimiento = e.id_emprendimiento)) AS horas_totales_semana_equipo,
    ( SELECT m.horas_semana
           FROM public.miembro m
          WHERE ((m.id_emprendimiento = e.id_emprendimiento) AND ((m.rol)::text = 'Lider'::text))
         LIMIT 1) AS horas_semana_lider,
    ( SELECT COALESCE(sum(mn.duracion_horas), (0)::double precision) AS "coalesce"
           FROM public.mentoria mn
          WHERE (mn.id_emprendimiento = e.id_emprendimiento)) AS horas_total_mentorias,
    ( SELECT COALESCE(sum(a.duracion_horas), (0)::double precision) AS "coalesce"
           FROM (public.emprendimiento_actividad ea
             JOIN public.actividad a ON ((a.id_actividad = ea.id_actividad)))
          WHERE (ea.id_emprendimiento = e.id_emprendimiento)) AS horas_total_actividades,
    ( SELECT COALESCE(sum(ev.duracion_horas), (0)::double precision) AS "coalesce"
           FROM (public.emprendimiento_evento ee
             JOIN public.evento ev ON ((ev.id_evento = ee.id_evento)))
          WHERE (ee.id_emprendimiento = e.id_emprendimiento)) AS horas_total_eventos
   FROM public.emprendimiento e
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_reporte_estado_operativo OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 123164)
-- Name: perfil_academico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfil_academico (
    id_miembro integer NOT NULL,
    matricula integer,
    gpa double precision,
    mat_aprobadas integer,
    mat_actuales integer,
    id_carrera integer
);


ALTER TABLE public.perfil_academico OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 123079)
-- Name: persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona (
    cedula character varying(20) NOT NULL,
    nombre character varying(50),
    apellido character varying(50),
    fecha_nacimiento date,
    telefono character varying(20),
    correo character varying(50)
);


ALTER TABLE public.persona OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 123437)
-- Name: mv_reporte_rendimiento_emprendimiento; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_reporte_rendimiento_emprendimiento AS
 SELECT e.id_emprendimiento,
    e.nombre AS nombre_emprendimiento,
    e.sector,
    e.nivel_madurez,
    em.estudio_mercado,
    em.factible_economicamente,
    em.just_fact_econo,
    em.factible_tecnicamente,
    em.just_fact_tecni,
    e.ventas,
    ( SELECT count(*) AS count
           FROM public.emprendimiento_evento ee
          WHERE (ee.id_emprendimiento = e.id_emprendimiento)) AS total_eventos,
    ( SELECT count(*) AS count
           FROM public.emprendimiento_actividad ea
          WHERE (ea.id_emprendimiento = e.id_emprendimiento)) AS total_actividades,
    ( SELECT count(*) AS count
           FROM public.mentoria m
          WHERE (m.id_emprendimiento = e.id_emprendimiento)) AS total_mentorias,
    p.nombre AS nombre_lider,
    p.apellido AS apellido_lider,
    (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (p.fecha_nacimiento)::timestamp with time zone)))::integer AS edad_lider,
    (pa.matricula)::character varying AS matricula,
    (pa.gpa)::numeric AS gpa_lider,
    pa.mat_actuales AS materias_actuales_lider
   FROM ((((public.emprendimiento e
     LEFT JOIN public.estudio_mercado em ON ((em.id_estudio = e.id_estudio)))
     LEFT JOIN public.miembro ml ON (((ml.id_emprendimiento = e.id_emprendimiento) AND ((ml.rol)::text = 'Líder'::text))))
     LEFT JOIN public.persona p ON (((p.cedula)::text = (ml.cedula)::text)))
     LEFT JOIN public.perfil_academico pa ON ((pa.id_miembro = ml.id_miembro)))
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_reporte_rendimiento_emprendimiento OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 123280)
-- Name: participacion_miembro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.participacion_miembro (
    id_miembro integer NOT NULL,
    id_mentoria integer NOT NULL,
    participacion double precision
);


ALTER TABLE public.participacion_miembro OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 123137)
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    id_staff integer NOT NULL,
    cargo character varying(25),
    activo boolean,
    cedula character varying(20)
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 123209)
-- Name: staff_evento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff_evento (
    id_evento integer NOT NULL,
    id_staff integer NOT NULL,
    horas_asignadas double precision,
    tarea character varying(255) NOT NULL
);


ALTER TABLE public.staff_evento OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 123339)
-- Name: vista_emprendimientos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_emprendimientos AS
 SELECT id_emprendimiento,
    nombre,
    sector,
    estado
   FROM public.emprendimiento
  ORDER BY nombre;


ALTER VIEW public.vista_emprendimientos OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 123331)
-- Name: vista_emprendimientos_simple; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_emprendimientos_simple AS
 SELECT id_emprendimiento,
    nombre,
    sector
   FROM public.emprendimiento
  ORDER BY nombre;


ALTER VIEW public.vista_emprendimientos_simple OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 123323)
-- Name: vista_eventos_detalle; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_eventos_detalle AS
 SELECT e.id_evento,
    e.nombre,
    e.descripcion,
    e.fecha,
    e.duracion_horas,
    l.nombre AS nombre_lugar
   FROM (public.evento e
     JOIN public.lugar l ON ((e.id_lugar = l.id_lugar)));


ALTER VIEW public.vista_eventos_detalle OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 123335)
-- Name: vista_lugares; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_lugares AS
 SELECT id_lugar,
    nombre,
    direccion,
    ciudad
   FROM public.lugar
  ORDER BY nombre;


ALTER VIEW public.vista_lugares OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 123327)
-- Name: vista_lugares_combo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_lugares_combo AS
 SELECT id_lugar,
    nombre,
    ciudad
   FROM public.lugar
  ORDER BY nombre;


ALTER VIEW public.vista_lugares_combo OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 123387)
-- Name: vista_reporte_emprendimientos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_reporte_emprendimientos AS
 SELECT id_emprendimiento,
    ((((nombre)::text || ' (Equipo: '::text) || ( SELECT count(*) AS count
           FROM public.miembro
          WHERE (miembro.id_emprendimiento = e.id_emprendimiento))) || ')'::text) AS nombre_equipo,
    ( SELECT max(mentoria.fecha) AS max
           FROM public.mentoria
          WHERE (mentoria.id_emprendimiento = e.id_emprendimiento)) AS ultima_mentoria,
    (( SELECT count(*) AS count
           FROM public.emprendimiento_evento
          WHERE (emprendimiento_evento.id_emprendimiento = e.id_emprendimiento)) + ( SELECT count(*) AS count
           FROM public.emprendimiento_actividad
          WHERE (emprendimiento_actividad.id_emprendimiento = e.id_emprendimiento))) AS total_participaciones
   FROM public.emprendimiento e;


ALTER VIEW public.vista_reporte_emprendimientos OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 123382)
-- Name: vista_reporte_miembros; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_reporte_miembros AS
 SELECT m.id_miembro,
    (COALESCE((((p.nombre)::text || ' '::text) || (p.apellido)::text), 'Sin Nombre'::text) || COALESCE((' - '::text || (c.carrera)::text), ' - Sin Carrera'::text)) AS nombre_carrera,
    COALESCE(pa.gpa, (0)::double precision) AS gpa,
    COALESCE(m.horas_semana, (0)::double precision) AS horas_semana
   FROM (((public.miembro m
     LEFT JOIN public.persona p ON (((m.cedula)::text = (p.cedula)::text)))
     LEFT JOIN public.perfil_academico pa ON ((m.id_miembro = pa.id_miembro)))
     LEFT JOIN public.carrera c ON ((pa.id_carrera = c.id_carrera)));


ALTER VIEW public.vista_reporte_miembros OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 123343)
-- Name: vista_staff_activo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_staff_activo AS
 SELECT s.id_staff,
    p.nombre,
    p.apellido,
    (((p.nombre)::text || ' '::text) || (p.apellido)::text) AS nombre_completo,
    s.cargo
   FROM (public.staff s
     JOIN public.persona p ON (((s.cedula)::text = (p.cedula)::text)))
  WHERE (s.activo = true);


ALTER VIEW public.vista_staff_activo OWNER TO postgres;

--
-- TOC entry 4997 (class 2604 OID 123200)
-- Name: evento id_evento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento ALTER COLUMN id_evento SET DEFAULT nextval('public.evento_id_evento_seq'::regclass);


--
-- TOC entry 5257 (class 0 OID 123180)
-- Dependencies: 232
-- Data for Name: actividad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.actividad (id_actividad, tipo, nombre, descripcion, fecha, duracion_horas, id_expositor, id_lugar) FROM stdin;
1	Taller	Pitch Day	Taller práctico de Marketing Digital	2025-01-17	2	1	1
2	Sesión	Taller financiero	Sesión de trabajo aplicado en Operaciones	2025-01-30	2	2	2
3	Taller	Workshop Marketing	Clínica de dudas y casos en Marketing Digital	2025-02-19	3	3	3
4	Sesión	Taller financiero	Acompañamiento estratégico en Operaciones	2025-03-03	2	4	4
5	Charla	Mentoría Canvas	Workshop de mejora en Marketing Digital	2025-03-15	2	5	5
6	Charla	Workshop Marketing	Sesión de mentoría sobre Operaciones	2025-04-02	3	6	6
7	Charla	Workshop Marketing	Taller práctico de Marketing Digital	2025-04-16	2	1	7
8	Charla	Pitch Day	Sesión de trabajo aplicado en Operaciones	2025-05-05	2	3	8
9	Sesión	Charla validación	Clínica de dudas y casos en Marketing Digital	2025-05-22	3	1	9
10	Sesión	Workshop Marketing	Acompañamiento estratégico en Operaciones	2025-06-08	2	5	2
11	Charla	Mentoría Canvas	Workshop de mejora en Marketing Digital	2025-06-30	2	3	4
12	Taller	Pitch Day	Sesión de mentoría sobre Operaciones	2025-07-15	3	1	5
13	Charla	Pitch e Innovación	Charla sobre cómo presentar e innovar en el modelo de negocio.	2025-07-30	2	2	2
14	Sesión	Mentoría de Finanzas	Sesión de mentoría para revisar proyecciones financieras.	2025-08-14	2	5	9
15	Taller	Taller de Validación	Taller práctico para validar problema, solución y cliente objetivo.	2025-08-29	3	6	7
16	Sesión	Sesión Legal	Asesoría jurídica sobre constitución de empresas y registros comerciales.	2025-09-13	2	4	6
17	Charla	Tendencias Tecnológicas	Charla sobre tecnologías emergentes aplicadas al emprendimiento.	2025-09-28	2	2	8
18	Taller	Branding Estratégico	Taller práctico para construir identidad visual y narrativa de marca.	2025-10-11	3	3	3
\.


--
-- TOC entry 5265 (class 0 OID 123297)
-- Dependencies: 240
-- Data for Name: bitacora; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bitacora (id_bitacora, accion, tabla, observacion, fecha, usuario) FROM stdin;
1710	INSERT	facultad	En la tabla facultad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1711	INSERT	facultad	En la tabla facultad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1712	INSERT	facultad	En la tabla facultad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1713	INSERT	facultad	En la tabla facultad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1714	INSERT	facultad	En la tabla facultad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1715	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1716	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1717	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1718	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1719	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1720	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1721	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1722	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1723	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1724	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1725	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1726	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1727	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1728	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1729	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1730	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1731	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1732	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1733	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1734	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1735	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1736	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1737	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1738	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1739	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1740	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1741	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1742	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1743	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1744	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1745	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1746	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1747	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1748	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1749	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1750	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1751	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1752	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1753	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1754	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1755	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1756	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1757	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1758	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1759	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1760	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1761	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1762	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1763	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1764	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1765	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1766	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1767	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1768	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1769	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1770	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1771	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1772	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1773	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1774	INSERT	estudio_mercado	En la tabla estudio_mercado se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1775	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1776	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1777	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1778	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1779	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1780	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1781	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1782	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1783	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1784	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1785	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1786	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1787	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1788	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1789	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1790	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1791	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1792	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1793	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1794	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1795	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1796	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1797	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1798	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1799	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1800	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1801	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1802	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1803	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1804	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1805	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1806	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1807	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1808	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1809	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1810	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1811	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1812	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1813	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1814	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1815	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1816	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1817	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1818	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1819	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1820	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1821	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1822	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1823	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1824	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1825	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1826	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1827	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1828	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1829	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1830	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1831	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1832	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1833	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1834	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1835	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1836	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1837	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1838	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1839	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1840	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1841	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1842	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1843	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1844	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1845	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1846	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1847	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1848	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1849	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1850	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1851	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1852	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1853	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1854	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1855	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1856	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1857	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1858	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1859	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1860	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1861	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1862	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1863	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1864	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1865	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1866	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1867	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1868	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1869	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1870	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1871	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1872	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1873	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1874	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1875	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1876	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1877	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1878	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1879	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1880	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1881	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1882	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1883	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1884	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1885	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1886	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1887	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1888	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1889	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1890	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1891	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1892	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1893	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1894	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1895	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1896	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1897	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1898	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1899	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1900	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1901	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1902	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1903	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1904	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1905	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1906	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1907	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1908	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1909	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1910	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1911	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1912	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1913	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1914	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1915	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1916	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1917	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1918	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1919	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1920	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1921	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1922	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1923	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1924	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1925	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1926	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1927	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1928	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1929	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1930	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1931	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1932	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1933	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1934	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1935	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1936	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1937	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1938	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1939	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1940	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1941	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1942	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1943	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1944	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1945	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1946	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1947	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1948	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1949	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1950	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1951	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1952	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1953	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1954	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1955	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1956	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1957	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1958	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1959	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1960	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1961	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1962	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1963	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1964	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1965	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1966	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1967	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1968	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1969	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1970	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1971	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1972	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1973	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1974	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1975	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1976	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1977	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1978	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1979	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1980	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1981	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1982	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1983	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1984	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1985	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1986	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1987	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1988	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1989	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1990	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1991	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1992	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1993	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1994	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1995	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1996	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1997	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1998	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
1999	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2000	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2001	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2002	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2003	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2004	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2005	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2006	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2007	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2008	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2009	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2010	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2011	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2012	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2013	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2014	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2015	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2016	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2017	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2018	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2019	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2020	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2021	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2022	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2023	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2024	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2025	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2026	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2027	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2028	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2029	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2030	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2031	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2032	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2033	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2034	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2035	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2036	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2037	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2038	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2039	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2040	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2041	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2042	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2043	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2044	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2045	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2046	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2047	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2048	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2049	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2050	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2051	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2052	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2053	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2054	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2055	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2056	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2057	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2058	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2059	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2060	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2061	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2062	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2063	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2064	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2065	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2066	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2067	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2068	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2069	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2070	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2071	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2072	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2073	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2074	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2075	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2076	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2077	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2078	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2079	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2080	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2081	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2082	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2083	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2084	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2085	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2086	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2087	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2088	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2089	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2090	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2091	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2092	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2093	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2094	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2095	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2096	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2097	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2098	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2099	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2100	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2101	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2102	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2103	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2104	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2105	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2106	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2107	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2108	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2109	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2110	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2111	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2112	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2113	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2114	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2115	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2116	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2117	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2118	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2119	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2120	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2121	INSERT	persona	En la tabla persona se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2122	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2123	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2124	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2125	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2126	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2127	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2128	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2129	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2130	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2131	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2132	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2133	INSERT	lugar	En la tabla lugar se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2134	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2135	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2136	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2137	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2138	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2139	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2140	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2141	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2142	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2143	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2144	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2145	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2146	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2147	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2148	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2149	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2150	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2151	INSERT	carrera	En la tabla carrera se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2152	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2153	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2154	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2155	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2156	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2157	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2158	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2159	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2160	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2161	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2162	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2163	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2164	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2165	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2166	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2167	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2168	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2169	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2170	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2171	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2172	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2173	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2174	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2175	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2176	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2177	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2178	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2179	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2180	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2181	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2182	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2183	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2184	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2185	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2186	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2187	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2188	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2189	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2190	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2191	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2192	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2193	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2194	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2195	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2196	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2197	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2198	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2199	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2200	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2201	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2202	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2203	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2204	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2205	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2206	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2207	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2208	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2209	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2210	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2211	INSERT	emprendimiento	En la tabla emprendimiento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2212	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2213	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2214	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2215	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2216	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2217	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2218	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2219	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2220	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2221	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2222	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2223	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2224	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2225	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2226	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2227	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2228	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2229	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2230	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2231	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2232	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2233	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2234	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2235	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2236	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2237	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2238	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2239	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2240	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2241	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2242	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2243	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2244	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2245	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2246	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2247	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2248	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2249	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2250	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2251	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2252	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2253	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2254	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2255	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2256	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2257	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2258	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2259	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2260	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2261	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2262	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2263	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2264	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2265	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2266	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2267	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2268	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2269	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2270	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2271	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2272	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2273	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2274	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2275	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2276	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2277	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2278	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2279	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2280	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2281	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2282	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2283	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2284	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2285	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2286	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2287	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2288	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2289	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2290	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2291	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2292	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2293	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2294	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2295	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2296	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2297	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2298	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2299	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2300	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2301	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2302	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2303	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2304	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2305	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2306	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2307	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2308	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2309	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2310	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2311	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2312	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2313	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2314	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2315	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2316	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2317	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2318	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2319	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2320	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2321	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2322	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2323	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2324	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2325	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2326	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2327	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2328	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2329	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2330	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2331	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2332	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2333	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2334	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2335	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2336	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2337	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2338	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2339	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2340	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2341	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2342	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2343	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2344	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2345	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2346	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2347	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2348	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2349	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2350	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2351	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2352	INSERT	staff	En la tabla staff se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2353	INSERT	mentor	En la tabla mentor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2354	INSERT	mentor	En la tabla mentor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2355	INSERT	mentor	En la tabla mentor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2356	INSERT	mentor	En la tabla mentor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2357	INSERT	mentor	En la tabla mentor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2358	INSERT	expositor	En la tabla expositor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2359	INSERT	expositor	En la tabla expositor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2360	INSERT	expositor	En la tabla expositor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2361	INSERT	expositor	En la tabla expositor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2362	INSERT	expositor	En la tabla expositor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2363	INSERT	expositor	En la tabla expositor se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2364	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2365	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2366	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2367	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2368	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2369	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2370	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2371	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2372	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2373	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2374	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2375	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2376	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2377	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2378	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2379	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2380	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2381	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2382	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2383	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2384	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2385	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2386	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2387	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2388	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2389	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2390	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2391	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2392	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2393	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2394	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2395	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2396	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2397	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2398	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2399	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2400	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2401	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2402	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2403	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2404	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2405	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2406	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2407	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2408	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2409	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2410	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2411	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2412	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2413	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2414	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2415	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2416	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2417	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2418	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2419	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2420	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2421	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2422	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2423	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2424	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2425	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2426	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2427	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2428	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2429	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2430	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2431	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2432	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2433	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2434	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2435	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2436	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2437	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2438	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2439	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2440	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2441	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2442	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2443	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2444	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2445	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2446	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2447	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2448	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2449	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2450	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2451	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2452	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2453	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2454	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2455	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2456	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2457	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2458	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2459	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2460	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2461	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2462	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2463	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2464	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2465	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2466	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2467	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2468	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2469	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2470	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2471	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2472	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2473	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2474	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2475	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2476	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2477	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2478	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2479	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2480	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2481	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2482	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2483	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2484	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2485	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2486	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2487	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2488	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2489	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2490	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2491	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2492	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2493	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2494	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2495	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2496	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2497	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2498	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2499	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2500	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2501	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2502	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2503	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2504	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2505	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2506	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2507	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2508	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2509	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2510	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2511	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2512	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2513	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2514	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2515	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2516	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2517	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2518	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2519	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2520	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2521	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2522	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2523	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2524	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2525	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2526	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2527	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2528	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2529	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2530	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2531	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2532	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2533	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2534	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2535	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2536	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2537	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2538	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2539	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2540	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2541	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2542	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2543	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2544	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2545	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2546	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2547	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2548	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2549	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2550	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2551	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2552	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2553	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2554	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2555	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2556	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2557	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2558	INSERT	miembro	En la tabla miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2559	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2560	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2561	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2562	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2563	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2564	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2565	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2566	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2567	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2568	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2569	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2570	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2571	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2572	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2573	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2574	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2575	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2576	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2577	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2578	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2579	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2580	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2581	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2582	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2583	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2584	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2585	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2586	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2587	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2588	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2589	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2590	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2591	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2592	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2593	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2594	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2595	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2596	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2597	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2598	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2599	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2600	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2601	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2602	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2603	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2604	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2605	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2606	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2607	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2608	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2609	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2610	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2611	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2612	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2613	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2614	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2615	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2616	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2617	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2618	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2619	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2620	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2621	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2622	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2623	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2624	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2625	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2626	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2627	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2628	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2629	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2630	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2631	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2632	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2633	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2634	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2635	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2636	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2637	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2638	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2639	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2640	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2641	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2642	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2643	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2644	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2645	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2646	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2647	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2648	INSERT	mentoria	En la tabla mentoria se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2649	INSERT	evento	En la tabla evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2650	INSERT	evento	En la tabla evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2651	INSERT	evento	En la tabla evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2652	INSERT	evento	En la tabla evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2653	INSERT	evento	En la tabla evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2654	INSERT	evento	En la tabla evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2655	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2656	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2657	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2658	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2659	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2660	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2661	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2662	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2663	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2664	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2665	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2666	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2667	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2668	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2669	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2670	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2671	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2672	INSERT	actividad	En la tabla actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2673	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2674	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2675	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2676	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2677	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2678	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2679	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2680	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2681	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2682	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2683	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2684	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2685	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2686	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2687	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2688	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2689	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2690	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2691	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2692	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2693	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2694	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2695	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2696	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2697	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2698	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2699	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2700	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2701	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2702	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2703	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2704	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2705	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2706	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2707	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2708	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2709	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2710	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2711	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2712	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2713	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2714	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2715	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2716	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2717	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2718	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2719	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2720	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2721	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2722	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2723	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2724	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2725	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2726	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2727	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2728	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2729	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2730	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2731	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2732	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2733	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2734	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2735	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2736	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2737	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2738	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2739	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2740	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2741	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2742	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2743	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2744	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2745	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2746	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2747	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2748	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2749	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2750	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2751	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2752	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2753	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2754	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2755	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2756	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2757	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2758	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2759	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2760	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2761	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2762	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2763	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2764	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2765	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2766	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2767	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2768	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2769	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2770	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2771	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2772	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2773	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2774	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2775	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2776	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2777	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2778	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2779	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2780	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2781	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2782	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2783	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2784	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2785	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2786	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2787	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2788	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2789	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2790	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2791	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2792	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2793	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2794	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2795	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2796	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2797	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2798	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2799	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2800	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2801	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2802	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2803	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2804	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2805	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2806	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2807	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2808	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2809	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2810	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2811	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2812	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2813	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2814	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2815	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2816	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2817	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2818	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2819	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2820	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2821	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2822	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2823	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2824	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2825	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2826	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2827	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2828	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2829	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2830	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2831	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2832	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2833	INSERT	perfil_academico	En la tabla perfil_academico se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2834	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2835	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2836	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2837	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2838	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2839	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2840	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2841	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2842	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2843	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2844	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2845	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2846	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2847	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2848	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2849	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2850	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2851	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2852	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2853	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2854	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2855	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2856	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2857	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2858	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2859	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2860	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2861	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2862	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2863	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2864	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2865	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2866	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2867	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2868	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2869	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2870	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2871	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2872	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2873	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2874	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2875	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2876	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2877	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2878	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2879	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2880	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2881	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2882	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2883	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2884	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2885	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2886	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2887	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2888	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2889	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2890	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2891	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2892	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2893	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2894	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2895	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2896	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2897	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2898	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2899	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2900	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2901	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2902	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2903	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2904	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2905	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2906	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2907	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2908	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2909	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2910	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2911	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2912	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2913	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2914	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2915	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2916	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2917	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2918	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2919	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2920	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2921	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2922	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2923	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2924	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2925	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2926	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2927	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2928	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2929	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2930	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2931	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2932	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2933	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2934	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2935	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2936	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2937	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2938	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2939	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2940	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2941	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2942	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2943	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2944	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2945	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2946	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2947	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2948	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2949	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2950	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2951	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2952	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2953	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2954	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2955	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2956	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2957	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2958	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2959	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2960	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2961	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2962	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2963	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2964	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2965	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2966	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2967	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2968	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2969	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2970	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2971	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2972	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2973	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2974	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2975	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2976	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2977	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2978	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2979	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2980	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2981	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2982	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2983	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2984	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2985	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2986	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2987	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2988	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2989	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2990	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2991	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2992	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2993	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2994	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2995	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2996	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2997	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2998	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
2999	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3000	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3001	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3002	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3003	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3004	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3005	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3006	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3007	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3008	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3009	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3010	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3011	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3012	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3013	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3014	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3015	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3016	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3017	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3018	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3019	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3020	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3021	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3022	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3023	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3024	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3025	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3026	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3027	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3028	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3029	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3030	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3031	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3032	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3033	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3034	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3035	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3036	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3037	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3038	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3039	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3040	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3041	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3042	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3043	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3044	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3045	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3046	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3047	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3048	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3049	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3050	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3051	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3052	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3053	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3054	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3055	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3056	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3057	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3058	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3059	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3060	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3061	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3062	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3063	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3064	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3065	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3066	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3067	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3068	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3069	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3070	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3071	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3072	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3073	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3074	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3075	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3076	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3077	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3078	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3079	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3080	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3081	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3082	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3083	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3084	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3085	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3086	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3087	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3088	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3089	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3090	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3091	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3092	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3093	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3094	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3095	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3096	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3097	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3098	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3099	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3100	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3101	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3102	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3103	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3104	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3105	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3106	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3107	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3108	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3109	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3110	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3111	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3112	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3113	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3114	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3115	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3116	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3117	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3118	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3119	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3120	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3121	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3122	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3123	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3124	INSERT	staff_evento	En la tabla staff_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3125	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3126	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3127	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3128	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3129	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3130	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3131	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3132	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3133	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3134	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3135	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3136	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3137	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3138	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3139	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3140	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3141	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3142	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3143	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3144	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3145	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3146	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3147	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3148	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3149	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3150	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3151	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3152	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3153	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3154	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3155	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3156	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3157	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3158	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3159	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3160	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3161	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3162	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3163	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3164	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3165	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3166	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3167	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3168	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3169	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3170	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3171	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3172	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3173	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3174	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3175	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3176	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3177	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3178	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3179	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3180	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3181	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3182	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3183	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3184	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3185	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3186	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3187	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3188	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3189	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3190	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3191	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3192	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3193	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3194	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3195	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3196	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3197	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3198	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3199	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3200	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3201	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3202	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3203	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3204	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3205	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3206	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3207	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3208	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3209	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3210	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3211	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3212	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3213	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3214	INSERT	emprendimiento_evento	En la tabla emprendimiento_evento se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3215	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3216	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3217	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3218	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3219	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3220	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3221	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3222	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3223	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3224	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3225	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3226	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3227	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3228	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3229	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3230	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3231	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3232	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3233	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3234	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3235	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3236	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3237	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3238	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3239	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3240	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3241	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3242	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3243	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3244	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3245	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3246	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3247	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3248	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3249	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3250	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3251	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3252	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3253	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3254	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3255	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3256	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3257	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3258	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3259	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3260	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3261	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3262	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3263	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3264	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3265	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3266	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3267	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3268	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3269	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3270	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3271	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3272	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3273	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3274	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3275	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3276	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3277	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3278	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3279	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3280	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3281	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3282	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3283	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3284	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3285	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3286	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3287	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3288	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3289	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3290	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3291	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3292	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3293	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3294	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3295	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3296	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3297	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3298	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3299	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3300	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3301	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3302	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3303	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3304	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3305	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3306	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3307	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3308	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3309	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3310	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3311	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3312	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3313	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3314	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3315	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3316	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3317	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3318	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3319	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3320	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3321	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3322	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3323	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3324	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3325	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3326	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3327	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3328	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3329	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3330	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3331	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3332	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3333	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3334	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3335	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3336	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3337	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3338	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3339	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3340	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3341	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3342	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3343	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3344	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3345	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3346	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3347	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3348	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3349	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3350	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3351	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3352	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3353	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3354	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3355	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3356	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3357	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3358	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3359	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3360	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3361	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3362	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3363	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3364	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3365	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3366	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3367	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3368	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3369	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3370	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3371	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3372	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3373	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3374	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3375	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3376	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3377	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3378	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3379	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3380	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3381	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3382	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3383	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3384	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3385	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3386	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3387	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3388	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3389	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3390	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3391	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3392	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3393	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3394	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3395	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3396	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3397	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3398	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3399	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3400	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3401	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3402	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3403	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3404	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3405	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3406	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3407	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3408	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3409	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3410	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3411	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3412	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3413	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3414	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3415	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3416	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3417	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3418	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3419	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3420	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3421	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3422	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3423	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3424	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3425	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3426	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3427	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3428	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3429	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3430	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3431	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3432	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3433	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3434	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3435	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3436	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3437	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3438	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3439	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3440	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3441	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3442	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3443	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3444	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3445	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3446	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3447	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3448	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3449	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3450	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3451	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3452	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3453	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3454	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3455	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3456	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3457	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3458	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3459	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3460	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3461	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3462	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3463	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3464	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3465	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3466	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3467	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3468	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3469	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3470	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3471	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3472	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3473	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3474	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3475	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3476	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3477	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3478	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3479	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3480	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3481	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3482	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3483	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3484	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3485	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3486	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3487	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3488	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3489	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3490	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3491	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3492	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3493	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3494	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3495	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3496	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3497	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3498	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3499	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3500	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3501	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3502	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3503	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3504	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3505	INSERT	participacion_miembro	En la tabla participacion_miembro se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3506	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3507	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3508	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3509	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3510	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3511	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3512	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3513	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3514	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3515	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3516	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3517	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3518	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3519	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3520	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3521	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3522	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3523	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3524	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3525	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3526	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3527	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3528	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3529	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3530	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3531	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3532	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3533	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3534	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3535	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3536	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3537	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3538	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3539	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3540	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3541	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3542	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3543	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3544	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3545	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3546	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3547	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3548	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3549	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3550	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3551	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3552	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3553	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3554	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3555	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3556	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3557	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3558	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3559	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3560	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3561	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3562	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3563	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3564	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3565	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3566	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3567	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3568	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3569	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3570	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3571	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3572	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3573	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3574	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3575	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3576	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3577	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3578	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3579	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3580	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3581	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3582	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3583	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3584	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3585	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3586	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3587	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3588	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3589	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3590	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3591	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3592	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3593	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3594	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
3595	INSERT	emprendimiento_actividad	En la tabla emprendimiento_actividad se realizó un INSERT	2025-12-16 22:46:39.470854	postgres
\.


--
-- TOC entry 5251 (class 0 OID 123104)
-- Dependencies: 226
-- Data for Name: carrera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carrera (id_carrera, carrera, id_facultad) FROM stdin;
1	Administración de Empresas	1
2	Negocios Internacionales	1
3	Gestión Empresarial	1
4	Marketing	1
5	Finanzas	2
6	Economía	2
7	Contabilidad	2
8	Arquitectura	3
9	Diseño de Interiores	3
10	Diseño Gráfico	3
11	Ingeniería Industrial	4
12	Ingeniería Electrónica	4
13	Ingeniería Mecánica	4
14	Ingeniería en Sistemas	4
15	Ingeniería Civil	4
16	Gestión Agronómica	5
17	Agroindustrias	5
18	Agronegocios	5
\.


--
-- TOC entry 5250 (class 0 OID 123091)
-- Dependencies: 225
-- Data for Name: emprendimiento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.emprendimiento (id_emprendimiento, nombre, sector, ciudad, pagina_web, red_social, fecha_registro, estado, modelo_negocio, etapa, nivel_madurez, presupuesto, ventas, id_estudio) FROM stdin;
1	HoyoTech	EdTech	Manta	https://hoyotech.com	LinkedIn	2025-01-01	Inactivo	Marketplace	Ventas	Único	1-500	1-500	1
2	AgroSmart	AgroTech	Loja	https://agrosmart.net	Facebook	2025-01-04	Activo	Marketplace	Ventas	Único	2000-5000	1000-2000	2
3	GastroGo	Gastronomía	Samborondón	https://gastrogo.com	Instagram	2025-01-09	Finalizado	B2C	Ventas	Único	5000-10000	1000-2000	3
4	BilleGo	FinTech	Samborondón	https://billego.com	Instagram	2025-01-11	Inactivo	Marketplace	Prototipo	Desarrollo	1-500	\N	4
5	DataStudio	Tecnología	Guayaquil	https://datastudio.io	TikTok	2025-01-14	Finalizado	B2C	Idea	Básico	1000-2000	\N	5
6	EduGo	EdTech	Cuenca	https://edugo.ec	TikTok	2025-01-17	Inactivo	B2B	Ventas	Único	10000-20000	1-500	6
7	UrbanSmart	Moda	Loja	https://urbansmart.ec	TikTok	2025-01-20	Inactivo	B2B	Idea	Básico	1-500	\N	7
8	EstiloNow	Moda	Guayaquil	https://estilonow.com	Instagram	2025-01-22	Activo	Marketplace	MVP	Prometedor	1000-2000	\N	8
9	ModaApp	Moda	Guayaquil	https://modaapp.io	Instagram	2025-01-24	Finalizado	B2B	Idea	Básico	1-500	\N	9
10	CashGo	FinTech	Quito	https://cashgo.io	Instagram	2025-01-27	Inactivo	Marketplace	MVP	Prometedor	10000-20000	\N	10
11	GreenLink	Sostenibilidad	Samborondón	https://greenlink.net	LinkedIn	2025-01-30	Finalizado	B2C	Idea	Básico	10000-20000	\N	11
12	CareSmart	Salud	Loja	https://caresmart.io	Instagram	2025-02-02	Finalizado	Marketplace	Idea	Básico	5000-10000	\N	12
13	ByteHub	EdTech	Guayaquil	https://bytehub.ec	LinkedIn	2025-02-08	Inactivo	B2B	Idea	Básico	2000-5000	\N	13
14	FarmApp	AgroTech	Manta	https://farmapp.net	TikTok	2025-02-11	Activo	B2C	Idea	Básico	2000-5000	\N	14
15	BilleNow	FinTech	Quito	https://billenow.ec	LinkedIn	2025-02-17	Activo	B2B	Ventas	Único	2000-5000	1-500	15
16	MediWorks	Salud	Loja	https://mediworks.ec	Instagram	2025-02-19	Finalizado	Marketplace	Idea	Básico	1000-2000	\N	16
17	AgroApp	AgroTech	Samborondón	https://agroapp.io	LinkedIn	2025-02-21	Finalizado	B2C	Idea	Básico	5000-10000	\N	17
18	CreditoLab	FinTech	Cuenca	https://creditolab.com	TikTok	2025-02-23	Inactivo	B2C	Prototipo	Desarrollo	10000-20000	\N	18
19	TrendNow	Moda	Manta	https://trendnow.com	Instagram	2025-02-26	Activo	Marketplace	Idea	Básico	500-1000	\N	19
20	VitalHub	Salud	Samborondón	https://vitalhub.ec	TikTok	2025-02-28	Inactivo	Marketplace	Ventas	Único	2000-5000	5000-10000	20
21	CampusHub	EdTech	Guayaquil	https://campushub.ec	Instagram	2025-03-03	Activo	B2B	Idea	Básico	10000-20000	\N	21
22	ChicLab	Moda	Guayaquil	https://chiclab.com	Instagram	2025-03-05	Inactivo	Marketplace	Idea	Básico	1-500	\N	22
23	VitalLab	Salud	Cuenca	https://vitallab.ec	Instagram	2025-03-07	Finalizado	B2B	Idea	Básico	5000-10000	\N	23
24	MediPlus	Salud	Cuenca	https://mediplus.net	Instagram	2025-03-09	Finalizado	B2C	Idea	Básico	5000-10000	\N	24
25	ProfeNow	EdTech	Loja	https://profenow.net	Instagram	2025-03-11	Inactivo	B2B	Idea	Básico	10000-20000	\N	25
26	NanoNow	Tecnología	Manta	https://nanonow.ec	Instagram	2025-03-15	Inactivo	B2B	Idea	Básico	1-500	\N	26
27	BitPlus	Tecnología	Guayaquil	https://bitplus.com	Facebook	2025-03-21	Activo	Marketplace	Mejoramiento	Potencial	500-1000	\N	27
28	DataStudio	Tecnología	Cuenca	https://datastudio.com	Facebook	2025-03-24	Inactivo	B2B	Idea	Básico	10000-20000	\N	28
29	TrendGo	Moda	Quito	https://trendgo.ec	TikTok	2025-03-27	Finalizado	B2B	Ventas	Único	2000-5000	1000-2000	29
30	BitLink	Tecnología	Quito	https://bitlink.ec	LinkedIn	2025-03-30	Inactivo	B2B	Ventas	Único	500-1000	500-1000	30
31	ReusaStudio	Sostenibilidad	Samborondón	https://reusastudio.ec	Instagram	2025-04-02	Inactivo	Marketplace	MVP	Prometedor	5000-10000	\N	31
32	MediNow	Salud	Guayaquil	https://medinow.net	Instagram	2025-04-06	Finalizado	B2B	Idea	Básico	1000-2000	\N	32
33	GreenPlus	Sostenibilidad	Guayaquil	https://greenplus.ec	LinkedIn	2025-04-08	Activo	B2B	MVP	Prometedor	1000-2000	\N	33
34	TrendPlus	Moda	Quito	https://trendplus.ec	LinkedIn	2025-04-10	Finalizado	Marketplace	Idea	Básico	1000-2000	\N	34
35	EstiloStudio	Moda	Guayaquil	https://estilostudio.com	LinkedIn	2025-04-13	Activo	B2C	Ventas	Único	1000-2000	10000-20000	35
36	VerdeHub	AgroTech	Quito	https://verdehub.ec	Facebook	2025-04-16	Finalizado	B2B	MVP	Prometedor	2000-5000	\N	36
37	PlatoApp	Gastronomía	Manta	https://platoapp.net	LinkedIn	2025-04-20	Inactivo	B2C	Idea	Básico	2000-5000	\N	37
38	CloudStudio	Tecnología	Guayaquil	https://cloudstudio.ec	Instagram	2025-04-22	Finalizado	B2B	Idea	Básico	500-1000	\N	38
39	ChicApp	Moda	Loja	https://chicapp.io	Instagram	2025-04-27	Activo	B2C	Idea	Básico	2000-5000	\N	39
40	TasteApp	Gastronomía	Guayaquil	https://tasteapp.net	Instagram	2025-05-01	Activo	Marketplace	Mejoramiento	Potencial	1-500	\N	40
41	WellLab	Salud	Loja	https://welllab.ec	Facebook	2025-05-05	Inactivo	B2B	Idea	Básico	1-500	\N	41
42	EstiloStudio	Moda	Guayaquil	https://estilostudio.ec	TikTok	2025-05-08	Activo	B2B	Ventas	Único	2000-5000	10000-20000	42
43	ModaSmart	Moda	Loja	https://modasmart.net	LinkedIn	2025-05-11	Activo	B2B	Ventas	Único	5000-10000	1000-2000	43
44	CareLab	Salud	Cuenca	https://carelab.io	Facebook	2025-05-15	Activo	B2B	Ventas	Único	2000-5000	5000-10000	44
45	Mappa	Moda	Guayaquil	https://mappa.ec	Instagram	2025-05-19	Inactivo	Marketplace	Prototipo	Desarrollo	1-500	\N	45
46	FinLab	FinTech	Cuenca	https://finlab.com	TikTok	2025-05-22	Activo	B2C	Ventas	Único	2000-5000	500-1000	46
47	ProfeApp	EdTech	Cuenca	https://profeapp.ec	LinkedIn	2025-05-25	Activo	B2C	Prototipo	Desarrollo	500-1000	\N	47
48	EduLab	EdTech	Quito	https://edulab.net	TikTok	2025-05-29	Finalizado	B2B	Prototipo	Desarrollo	1000-2000	\N	48
49	WellWorks	Salud	Guayaquil	https://wellworks.io	TikTok	2025-06-02	Finalizado	B2B	Mejoramiento	Potencial	1000-2000	\N	49
50	QuinGo	FinTech	Cuenca	https://quingo.net	TikTok	2025-06-05	Activo	B2C	Ventas	Único	5000-10000	500-1000	50
51	FarmHub	AgroTech	Quito	https://farmhub.com	Instagram	2025-06-08	Inactivo	B2B	MVP	Prometedor	1-500	\N	51
52	PlatoWorks	Gastronomía	Quito	https://platoworks.net	Facebook	2025-06-11	Activo	B2C	Idea	Básico	1000-2000	\N	52
53	CocinaStudio	Gastronomía	Cuenca	https://cocinastudio.com	Instagram	2025-06-16	Inactivo	B2B	Mejoramiento	Potencial	2000-5000	\N	53
54	ClaseStudio	EdTech	Cuenca	https://clasestudio.ec	Facebook	2025-06-21	Inactivo	Marketplace	Mejoramiento	Potencial	1000-2000	\N	54
55	UnderBurger	Gastronomía	Loja	https://underburger.net	LinkedIn	2025-06-27	Inactivo	B2B	Idea	Básico	500-1000	\N	55
56	EduWorks	EdTech	Manta	https://eduworks.com	TikTok	2025-06-30	Inactivo	B2B	Idea	Básico	1-500	\N	56
57	ByteGo	EdTech	Quito	https://bytego.ec	LinkedIn	2025-07-02	Inactivo	B2C	Mejoramiento	Potencial	500-1000	\N	57
58	ChefLink	Gastronomía	Quito	https://cheflink.io	Facebook	2025-07-07	Inactivo	B2C	Mejoramiento	Potencial	1000-2000	\N	58
59	VerdeApp	AgroTech	Samborondón	https://verdeapp.ec	Instagram	2025-07-10	Finalizado	Marketplace	Idea	Básico	1-500	\N	59
60	CreditoNow	FinTech	Loja	https://creditonow.ec	LinkedIn	2025-07-12	Inactivo	B2B	Prototipo	Desarrollo	5000-10000	\N	60
\.


--
-- TOC entry 5261 (class 0 OID 123226)
-- Dependencies: 236
-- Data for Name: emprendimiento_actividad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.emprendimiento_actividad (id_emprendimiento, id_actividad, observacion) FROM stdin;
1	1	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
2	1	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
3	1	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
4	1	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
5	1	La actividad se desarrolló según la agenda propuesta.
6	2	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
7	2	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
8	2	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
9	2	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
10	2	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
11	3	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
12	3	La actividad se desarrolló según la agenda propuesta.
13	3	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
14	3	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
15	3	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
16	4	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
17	4	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
18	4	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
19	4	La actividad se desarrolló según la agenda propuesta.
20	4	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
21	5	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
22	5	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
23	5	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
24	5	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
25	5	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
26	6	La actividad se desarrolló según la agenda propuesta.
27	6	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
28	6	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
29	6	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
30	6	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
31	7	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
32	7	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
33	7	La actividad se desarrolló según la agenda propuesta.
34	7	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
35	7	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
36	8	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
37	8	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
38	8	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
39	8	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
40	8	La actividad se desarrolló según la agenda propuesta.
41	9	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
42	9	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
43	9	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
44	9	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
45	9	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
46	10	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
47	10	La actividad se desarrolló según la agenda propuesta.
48	10	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
49	10	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
50	10	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
51	11	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
52	11	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
53	11	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
54	11	La actividad se desarrolló según la agenda propuesta.
55	11	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
56	12	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
57	12	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
58	12	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
59	12	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
60	12	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
56	13	La actividad se desarrolló según la agenda propuesta.
55	13	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
48	13	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
53	13	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
33	13	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
13	14	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
47	14	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
38	14	La actividad se desarrolló según la agenda propuesta.
37	14	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
45	14	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
40	15	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
52	15	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
32	15	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
50	15	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
43	15	La actividad se desarrolló según la agenda propuesta.
38	16	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
1	16	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
53	16	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
21	16	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
3	16	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
4	17	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
58	17	La actividad se desarrolló según la agenda propuesta.
5	17	El enfoque comercial fue sólido, aunque las métricas de medición de resultados no se encuentran definidas.
45	17	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
6	17	El emprendimiento participó activamente durante toda la sesión, demostrando interés en aplicar los conceptos revisados.
41	18	Se identificó una adecuada comprensión del contenido, aunque aún existen oportunidades de mejora en la estructura del modelo de negocio.
7	18	Se evidenció trabajo colaborativo entre los integrantes, pero faltó asignación clara de responsabilidades.
8	18	El prototipo presentado refleja avance, sin embargo, requiere mayor validación con clientes reales antes de su lanzamiento.
34	18	La actividad se desarrolló según la agenda propuesta.
55	18	El equipo mostró creatividad en la propuesta, pero no sustentó adecuadamente los costos asociados a su implementación.
\.


--
-- TOC entry 5262 (class 0 OID 123245)
-- Dependencies: 237
-- Data for Name: emprendimiento_evento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.emprendimiento_evento (id_emprendimiento, id_evento, observacion) FROM stdin;
1	1	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
2	1	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
3	1	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
4	1	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
5	1	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
6	1	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
7	1	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
8	1	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
9	1	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
10	1	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
11	1	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
12	1	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
13	1	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
14	1	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
15	1	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
16	2	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
17	2	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
18	2	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
19	2	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
20	2	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
21	2	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
22	2	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
23	2	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
24	2	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
25	2	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
26	2	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
27	2	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
28	2	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
29	2	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
30	2	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
31	3	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
32	3	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
33	3	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
34	3	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
35	3	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
36	3	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
37	3	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
38	3	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
39	3	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
40	3	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
41	3	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
42	3	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
43	3	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
44	3	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
45	3	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
46	4	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
47	4	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
48	4	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
49	4	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
50	4	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
51	4	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
52	4	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
53	4	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
54	4	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
55	4	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
56	4	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
57	4	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
58	4	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
59	4	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
60	4	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
56	5	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
55	5	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
48	5	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
53	5	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
33	5	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
13	5	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
47	5	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
38	5	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
37	5	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
45	5	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
40	5	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
52	5	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
32	5	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
50	5	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
43	5	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
38	6	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
1	6	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
53	6	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
21	6	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
3	6	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
4	6	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
58	6	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
5	6	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
45	6	La interacción con los asistentes fue adecuada, sin embargo, el discurso comercial careció de una propuesta de valor contundente.
6	6	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
41	6	Se notó buen manejo del tiempo asignado, aunque la demostración técnica no estuvo completamente funcional.
7	6	El equipo respondió con seguridad a las preguntas, pero careció de datos cuantitativos para respaldar su propuesta.
8	6	El material visual fue atractivo, pero no incluía suficiente información sobre precios o diferenciadores competitivos.
34	6	Se evidenció interés por parte de potenciales clientes, aunque no se registraron estrategias de seguimiento posteriores.
55	6	La exposición del emprendimiento captó la atención del público, pero el mensaje central pudo ser más claro y directo.
\.


--
-- TOC entry 5247 (class 0 OID 123071)
-- Dependencies: 222
-- Data for Name: estudio_mercado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estudio_mercado (id_estudio, estudio_mercado, factible_economicamente, factible_tecnicamente, just_fact_econo, just_fact_tecni, publico_objetivo) FROM stdin;
1	t	t	t	Margen unitario preliminar positivo en pruebas.	Plataforma funcional en piloto con estudiantes.	Consumidores finales
2	t	t	t	Costos controlados y primeras señales de demanda.	Prueba de campo exitosa en pequeña parcela.	Estudiantes
3	t	t	t	Solo estimación de costos, no se considera factible todavía.	Recetas estandarizadas y capacidad instalada suficiente.	Tiendas locales
4	t	f	t	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	Integraciones con pasarelas listas y operativas.	Tiendas locales
5	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
6	t	t	t	Solo estimación de costos, no se considera factible todavía.	Plataforma funcional en piloto con estudiantes.	Productores
7	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
8	t	t	f	Costos controlados y primeras señales de demanda.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Consumidores finales
9	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
10	t	t	f	Margen unitario preliminar positivo en pruebas.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Productores
11	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
12	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
13	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
14	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
15	t	t	t	Crecimiento sostenido y proyecciones sólidas.	Integraciones con pasarelas listas y operativas.	Tiendas locales
16	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
17	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
18	t	f	t	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	Integraciones con pasarelas listas y operativas.	Estudiantes
19	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
20	t	t	t	Crecimiento sostenido y proyecciones sólidas.	Prototipo funcional bajo supervisión profesional.	Consumidores finales
21	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
22	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
23	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
24	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
25	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
26	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
27	t	f	f	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Tiendas locales
28	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
29	t	t	t	Costos controlados y primeras señales de demanda.	Proveedores y producción validados a baja escala.	Consumidores finales
30	t	t	t	Crecimiento sostenido y proyecciones sólidas.	Prototipo estable probado con usuarios reales.	Tiendas locales
31	t	t	f	Costos controlados y primeras señales de demanda.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Tiendas locales
32	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
33	t	t	f	Flujo de caja positivo y ventas recurrentes.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Pymes
34	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
35	t	t	t	Flujo de caja positivo y ventas recurrentes.	Proveedores y producción validados a baja escala.	Productores
36	t	t	f	Costos controlados y primeras señales de demanda.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Estudiantes
37	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
38	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
39	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
40	t	f	f	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Tiendas locales
41	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
42	t	t	t	Unit economics casi positivos con clientes piloto.	Proveedores y producción validados a baja escala.	Consumidores finales
43	t	t	t	Solo estimación de costos, no se considera factible todavía.	Proveedores y producción validados a baja escala.	Estudiantes
44	t	t	t	Unit economics casi positivos con clientes piloto.	Prototipo funcional bajo supervisión profesional.	Productores
45	t	f	t	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	Proveedores y producción validados a baja escala.	Pymes
46	t	t	t	Crecimiento sostenido y proyecciones sólidas.	Integraciones con pasarelas listas y operativas.	Tiendas locales
47	t	f	t	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	Plataforma funcional en piloto con estudiantes.	Consumidores finales
48	t	f	t	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	Plataforma funcional en piloto con estudiantes.	Consumidores finales
49	t	f	f	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Estudiantes
50	t	t	t	Flujo de caja positivo y ventas recurrentes.	Integraciones con pasarelas listas y operativas.	Consumidores finales
51	t	t	f	Solo estimación de costos, no se considera factible todavía.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Pymes
52	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
53	t	f	f	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Tiendas locales
54	t	f	f	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Consumidores finales
55	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
56	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
57	t	f	f	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Tiendas locales
58	t	f	f	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	La infraestructura o recursos técnicos disponibles no cumplen los requisitos operativos.	Consumidores finales
59	f	f	f	No se realizó estudio de mercado; por ello no es factible económicamente.	No se realizó estudio de mercado; por ello no es factible técnicamente.	\N
60	t	f	t	El análisis financiero muestra márgenes insuficientes a pesar del estudio de mercado.	Integraciones con pasarelas listas y operativas.	Tiendas locales
\.


--
-- TOC entry 5259 (class 0 OID 123197)
-- Dependencies: 234
-- Data for Name: evento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evento (id_evento, nombre, descripcion, fecha, duracion_horas, id_lugar) FROM stdin;
1	Taller de Innovación	Feria de innovación y tecnología	2025-09-11	3	10
2	Charla de Emprendimiento	Rueda de negocios universitarios	2025-09-25	4	11
3	Foro de Desarrollo Local	Demo Day de emprendimientos	2025-10-09	5	12
4	Seminario de Marketing Digital	Expo de soluciones digitales	2025-10-23	4	10
5	Encuentro de Startups	Cierre de ciclo de mentorías	2025-11-06	3	11
6	Festival de Innovación Universitaria	Presentación de proyectos y networking	2025-12-05	4	12
\.


--
-- TOC entry 5253 (class 0 OID 123126)
-- Dependencies: 228
-- Data for Name: expositor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expositor (id_expositor, especialidad, activo, cedula) FROM stdin;
1	Innovación y emprendimiento	t	0967116845
2	Marketing y ventas	f	0977590175
3	Finanzas para startups	t	0918636374
4	Modelo de negocio	t	0954589297
5	Pitch y storytelling	t	0950017012
6	Transformación digital	t	0977063242
\.


--
-- TOC entry 5246 (class 0 OID 123065)
-- Dependencies: 221
-- Data for Name: facultad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.facultad (id_facultad, facultad) FROM stdin;
1	Administración
2	Finanzas
3	Diseño
4	Ingeniería
5	Agronomía
\.


--
-- TOC entry 5249 (class 0 OID 123085)
-- Dependencies: 224
-- Data for Name: lugar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lugar (id_lugar, nombre, direccion, ciudad) FROM stdin;
1	Auditorio A	Campus UEES - Edificio A	Samborondón
2	Sala de Conferencias	Campus UEES - Edificio P	Samborondón
3	The Hub	Campus UEES - Edificio The Hub	Samborondón
4	Coworking La Floresta	Av. Principal 123 - La Floresta	Guayaquil
5	Centro de Innovación	Malecón 2000 - Edificio Empresarial	Guayaquil
6	Biblioteca Municipal de Guayaquil	Av. 9 de Octubre y Chile	Guayaquil
7	Laboratorio I	Campus UEES - Edificio G	Samborondón
8	Aula 101	Campus UEES - Edificio A	Samborondón
9	Sala B	Campus UEES - Edificio B	Samborondón
10	Concha Acústica	Parque Samanes	Guayaquil
11	Auditorio Honoris Causa	Campus UEES - Edificio A	Samborondón
12	Centro de Convenciones	Campus UEES - Edificio P	Samborondón
\.


--
-- TOC entry 5252 (class 0 OID 123115)
-- Dependencies: 227
-- Data for Name: mentor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mentor (id_mentor, especialidad, activo, cedula) FROM stdin;
1	Finanzas y costos	f	0941541520
2	Validación de mercado	t	0964361103
3	Marketing digital	t	0971293870
4	Unit economics	t	0905162713
5	Tecnología y producto	t	0961115542
\.


--
-- TOC entry 5263 (class 0 OID 123264)
-- Dependencies: 238
-- Data for Name: mentoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mentoria (id_mentoria, tema, contenido, observacion, fecha, duracion_horas, modalidad, locacion, id_mentor, id_emprendimiento) FROM stdin;
1	Marketing Digital	Revisión de estrategia.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-01-19	5	Virtual	Teams	1	1
2	Finanzas para Emprendedores	Evaluación de producto.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-01-21	1	Virtual	Teams	2	2
3	Modelo de Negocio	Optimización operativa.	La sesión se centró en resolver dudas técnicas del equipo.	2025-01-23	2	Virtual	Teams	3	3
4	Validación de Idea	Evaluación de producto.	Buena participación; se acordó seguimiento puntual.	2025-01-25	5	Presencial	Sala de reuniones 3 en La Puntilla	4	4
5	Branding	Optimización operativa.	Se profundizó en la validación del modelo de negocio.	2025-01-27	2	Virtual	Zoom	5	5
6	Operaciones	Revisión de estrategia.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-02-01	3	Presencial	Coworking 1 en Samborondón	3	6
7	Gestión de Clientes	Optimización operativa.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-02-03	2	Virtual	Teams	4	7
8	Innovación	Evaluación de producto.	La sesión se centró en resolver dudas técnicas del equipo.	2025-02-05	4	Presencial	Coworking 36 en Samborondón	2	8
9	Prototipado	Análisis financiero.	Buena participación; se acordó seguimiento puntual.	2025-02-07	1	Virtual	Teams	3	9
10	Estrategia Comercial	Análisis financiero.	Se profundizó en la validación del modelo de negocio.	2025-02-09	1	Presencial	Aula empresarial 47 en Puerto Santa Ana	5	10
11	Marketing Digital	Plan comercial.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-02-21	2	Presencial	Sala de reuniones 44 en Urdesa	4	11
12	Finanzas para Emprendedores	Evaluación de producto.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-02-23	4	Presencial	Aula empresarial 45 en Samborondón	3	12
13	Modelo de Negocio	Evaluación de producto.	La sesión se centró en resolver dudas técnicas del equipo.	2025-02-25	2	Virtual	Teams	2	13
14	Validación de Idea	Análisis financiero.	Buena participación; se acordó seguimiento puntual.	2025-02-27	4	Virtual	Zoom	5	14
15	Branding	Evaluación de producto.	Se profundizó en la validación del modelo de negocio.	2025-03-01	5	Virtual	Zoom	4	15
16	Operaciones	Evaluación de producto.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-03-05	3	Virtual	Zoom	2	16
17	Gestión de Clientes	Optimización operativa.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-03-07	5	Virtual	Zoom	1	17
18	Innovación	Revisión de estrategia.	La sesión se centró en resolver dudas técnicas del equipo.	2025-03-09	1	Presencial	Aula empresarial 10 en Ciudad del Río	5	18
19	Prototipado	Plan comercial.	Buena participación; se acordó seguimiento puntual.	2025-03-11	2	Virtual	Teams	3	19
20	Estrategia Comercial	Revisión de estrategia.	Se profundizó en la validación del modelo de negocio.	2025-03-13	1	Presencial	Aula empresarial 38 en La Puntilla	4	20
21	Marketing Digital	Plan comercial.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-03-17	5	Virtual	Teams	1	21
22	Finanzas para Emprendedores	Plan comercial.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-03-19	1	Presencial	Aula empresarial 36 en Parque Empresarial Colón	4	22
23	Modelo de Negocio	Evaluación de producto.	La sesión se centró en resolver dudas técnicas del equipo.	2025-03-21	4	Presencial	Oficina 13 en Las Peñas	5	23
24	Validación de Idea	Evaluación de producto.	Buena participación; se acordó seguimiento puntual.	2025-03-23	4	Presencial	Sala de reuniones 21 en Parque Empresarial Colón	4	24
25	Branding	Evaluación de producto.	Se profundizó en la validación del modelo de negocio.	2025-03-25	5	Virtual	Teams	2	25
26	Operaciones	Plan comercial.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-04-04	2	Presencial	Coworking 6 en Parque Empresarial Colón	1	26
27	Gestión de Clientes	Análisis financiero.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-04-06	3	Virtual	Teams	2	27
28	Innovación	Análisis financiero.	La sesión se centró en resolver dudas técnicas del equipo.	2025-04-08	2	Virtual	Zoom	3	28
29	Prototipado	Plan comercial.	Buena participación; se acordó seguimiento puntual.	2025-04-10	3	Presencial	Aula empresarial 20 en Urdesa	4	29
30	Estrategia Comercial	Optimización operativa.	Se profundizó en la validación del modelo de negocio.	2025-04-12	4	Virtual	Teams	5	30
31	Marketing Digital	Análisis financiero.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-04-18	1	Presencial	Centro de capacitación 10 en Samborondón	3	31
32	Finanzas para Emprendedores	Plan comercial.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-04-20	5	Virtual	Zoom	1	32
33	Modelo de Negocio	Optimización operativa.	La sesión se centró en resolver dudas técnicas del equipo.	2025-04-22	3	Presencial	Centro de capacitación 48 en La Puntilla	3	33
34	Validación de Idea	Evaluación de producto.	Buena participación; se acordó seguimiento puntual.	2025-04-24	3	Virtual	Teams	4	34
35	Branding	Evaluación de producto.	Se profundizó en la validación del modelo de negocio.	2025-04-26	5	Virtual	Zoom	3	35
36	Operaciones	Análisis financiero.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-05-07	5	Presencial	Oficina 6 en Puerto Santa Ana	2	36
37	Gestión de Clientes	Evaluación de producto.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-05-09	4	Presencial	Centro de capacitación 21 en Ciudad del Río	5	37
38	Innovación	Revisión de estrategia.	La sesión se centró en resolver dudas técnicas del equipo.	2025-05-11	1	Virtual	Zoom	4	38
39	Prototipado	Revisión de estrategia.	Buena participación; se acordó seguimiento puntual.	2025-05-13	2	Presencial	Aula empresarial 22 en Samborondón	2	39
40	Estrategia Comercial	Optimización operativa.	Se profundizó en la validación del modelo de negocio.	2025-05-15	1	Presencial	Centro de capacitación 28 en Puerto Santa Ana	5	40
41	Marketing Digital	Plan comercial.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-05-24	4	Virtual	Teams	1	41
42	Finanzas para Emprendedores	Evaluación de producto.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-05-26	5	Presencial	Sala de reuniones 25 en Parque Empresarial Colón	3	42
43	Modelo de Negocio	Revisión de estrategia.	La sesión se centró en resolver dudas técnicas del equipo.	2025-05-28	5	Virtual	Zoom	2	43
44	Validación de Idea	Optimización operativa.	Buena participación; se acordó seguimiento puntual.	2025-05-30	3	Presencial	Oficina 10 en Las Peñas	4	44
45	Branding	Revisión de estrategia.	Se profundizó en la validación del modelo de negocio.	2025-06-01	2	Virtual	Teams	3	45
46	Operaciones	Revisión de estrategia.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-06-10	5	Virtual	Teams	5	46
47	Gestión de Clientes	Plan comercial.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-06-12	4	Presencial	Coworking 36 en Parque Empresarial Colón	1	47
48	Innovación	Análisis financiero.	La sesión se centró en resolver dudas técnicas del equipo.	2025-06-14	3	Virtual	Teams	3	48
49	Prototipado	Optimización operativa.	Buena participación; se acordó seguimiento puntual.	2025-06-16	1	Virtual	Zoom	4	49
50	Estrategia Comercial	Revisión de estrategia.	Se profundizó en la validación del modelo de negocio.	2025-06-18	3	Presencial	Aula empresarial 37 en Puerto Santa Ana	3	50
51	Marketing Digital	Optimización operativa.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-07-02	3	Presencial	Centro de capacitación 6 en Mall del Sol	1	51
52	Finanzas para Emprendedores	Optimización operativa.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-07-04	2	Presencial	Sala de reuniones 16 en Ciudad del Río	2	52
53	Modelo de Negocio	Plan comercial.	La sesión se centró en resolver dudas técnicas del equipo.	2025-07-06	5	Presencial	Centro de capacitación 13 en Mall del Sol	1	53
54	Validación de Idea	Evaluación de producto.	Buena participación; se acordó seguimiento puntual.	2025-07-08	2	Virtual	Teams	2	54
55	Branding	Evaluación de producto.	Se profundizó en la validación del modelo de negocio.	2025-07-10	3	Presencial	Coworking 20 en La Puntilla	4	55
56	Operaciones	Evaluación de producto.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-07-17	5	Virtual	Zoom	5	56
57	Gestión de Clientes	Optimización operativa.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-07-19	3	Presencial	Centro de capacitación 27 en Parque Empresarial Colón	4	57
58	Innovación	Revisión de estrategia.	La sesión se centró en resolver dudas técnicas del equipo.	2025-07-21	3	Presencial	Centro de capacitación 9 en Samborondón	1	58
59	Prototipado	Plan comercial.	Buena participación; se acordó seguimiento puntual.	2025-07-23	2	Presencial	Sala de reuniones 15 en Las Peñas	3	59
60	Estrategia Comercial	Optimización operativa.	Se profundizó en la validación del modelo de negocio.	2025-07-25	5	Virtual	Zoom	2	60
61	Marketing Digital	Revisión de estrategia.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-08-01	5	Virtual	Teams	5	56
62	Finanzas para Emprendedores	Evaluación de producto.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-08-03	1	Virtual	Teams	1	55
63	Modelo de Negocio	Optimización operativa.	La sesión se centró en resolver dudas técnicas del equipo.	2025-08-05	1	Presencial	Sala de reuniones 14 en La Puntilla	5	48
64	Validación de Idea	Evaluación de producto.	Buena participación; se acordó seguimiento puntual.	2025-08-07	5	Virtual	Teams	3	53
65	Branding	Optimización operativa.	Se profundizó en la validación del modelo de negocio.	2025-08-09	2	Virtual	Zoom	5	33
66	Operaciones	Revisión de estrategia.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-08-16	2	Virtual	Zoom	4	13
67	Gestión de Clientes	Optimización operativa.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-08-18	5	Presencial	Oficina 45 en Samborondón	5	47
68	Innovación	Evaluación de producto.	La sesión se centró en resolver dudas técnicas del equipo.	2025-08-20	4	Virtual	Teams	1	38
69	Prototipado	Análisis financiero.	Buena participación; se acordó seguimiento puntual.	2025-08-22	5	Presencial	Coworking 20 en Puerto Santa Ana	1	37
70	Estrategia Comercial	Análisis financiero.	Se profundizó en la validación del modelo de negocio.	2025-08-24	2	Virtual	Zoom	4	45
71	Marketing Digital	Plan comercial.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-08-31	4	Virtual	Zoom	5	40
72	Finanzas para Emprendedores	Evaluación de producto.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-09-02	2	Presencial	Oficina 34 en Mall del Sol	2	52
73	Modelo de Negocio	Evaluación de producto.	La sesión se centró en resolver dudas técnicas del equipo.	2025-09-04	2	Virtual	Zoom	1	32
74	Validación de Idea	Análisis financiero.	Buena participación; se acordó seguimiento puntual.	2025-09-06	3	Presencial	Sala de reuniones 14 en Mall del Sol	4	50
75	Branding	Evaluación de producto.	Se profundizó en la validación del modelo de negocio.	2025-09-08	2	Presencial	Coworking 22 en Mall del Sol	3	43
76	Operaciones	Optimización operativa.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-11-23	3	Presencial	Sala de reuniones 19 en Urdesa	1	38
77	Gestión de Clientes	Plan comercial.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-11-24	2	Virtual	Zoom	4	1
78	Innovación	Optimización operativa.	La sesión se centró en resolver dudas técnicas del equipo.	2025-11-25	4	Virtual	Teams	3	53
79	Prototipado	Revisión de estrategia.	Buena participación; se acordó seguimiento puntual.	2025-11-26	1	Presencial	Aula empresarial 11 en La Puntilla	2	21
80	Estrategia Comercial	Revisión de estrategia.	Se profundizó en la validación del modelo de negocio.	2025-11-27	3	Virtual	Zoom	1	3
81	Marketing Digital	Evaluación de producto.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-11-30	5	Presencial	Coworking 5 en Samborondón	5	4
82	Finanzas para Emprendedores	Análisis financiero.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-12-01	2	Virtual	Teams	3	58
83	Modelo de Negocio	Plan comercial.	La sesión se centró en resolver dudas técnicas del equipo.	2025-12-02	4	Presencial	Aula empresarial 23 en Ciudad del Río	2	5
84	Validación de Idea	Revisión de estrategia.	Buena participación; se acordó seguimiento puntual.	2025-12-03	1	Virtual	Teams	4	45
85	Branding	Optimización operativa.	Se profundizó en la validación del modelo de negocio.	2025-12-04	5	Presencial	Sala de reuniones 7 en Puerto Santa Ana	4	6
86	Operaciones	Revisión de estrategia.	La mentoría avanzó favorablemente y se establecieron próximos pasos.	2025-12-07	2	Virtual	Zoom	1	41
87	Gestión de Clientes	Optimización operativa.	Se revisó el progreso del emprendimiento y se definieron nuevas metas.	2025-12-08	3	Presencial	Aula empresarial 4 en Las Peñas	2	7
88	Innovación	Plan comercial.	La sesión se centró en resolver dudas técnicas del equipo.	2025-12-09	1	Presencial	Coworking 41 en Samborondón	5	8
89	Prototipado	Análisis financiero.	Buena participación; se acordó seguimiento puntual.	2025-12-10	4	Virtual	Teams	2	34
90	Estrategia Comercial	Evaluación de producto.	Se profundizó en la validación del modelo de negocio.	2025-12-11	5	Virtual	Zoom	3	55
\.


--
-- TOC entry 5255 (class 0 OID 123148)
-- Dependencies: 230
-- Data for Name: miembro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.miembro (id_miembro, rol, horas_semana, fecha_ingreso, fecha_salida, id_emprendimiento, cedula) FROM stdin;
1	Líder	2	2025-01-01	\N	1	0951073613
2	Marketing	12	2025-01-02	\N	1	0916185068
3	Miembro	5	2025-01-03	\N	1	0995386762
4	Líder	5	2025-01-04	\N	2	0953880564
5	Ventas	12	2025-01-05	\N	2	0986782778
6	Finanzas	8	2025-01-06	\N	2	0941900462
7	Miembro	4	2025-01-07	\N	2	0951432235
8	Finanzas	7	2025-01-08	\N	2	0996964250
9	Líder	5	2025-01-09	\N	3	0916871182
10	Técnico	5	2025-01-10	\N	3	0909191142
11	Líder	12	2025-01-11	\N	4	0976277845
12	Miembro	6	2025-01-12	\N	4	0980888873
13	Marketing	13	2025-01-13	\N	4	0977665969
14	Ventas	6	2025-01-15	\N	5	0990095702
15	Marketing	6	2025-01-16	\N	5	0948062820
16	Líder	2	2025-01-14	\N	5	0923808230
17	Líder	9	2025-01-17	\N	6	0920277717
18	Miembro	10	2025-01-18	\N	6	0907258272
19	Ventas	5	2025-01-19	\N	6	0926838375
20	Miembro	5	2025-01-21	\N	7	0902245069
21	Líder	13	2025-01-20	\N	7	0917168413
22	Líder	6	2025-01-22	\N	8	0962129225
23	Ventas	5	2025-01-23	\N	8	0925614637
24	Técnico	9	2025-01-25	\N	9	0994859736
25	Líder	12	2025-01-24	\N	9	0959401469
26	Miembro	14	2025-01-26	\N	9	0993909712
27	Líder	11	2025-01-27	\N	10	0981214580
28	Miembro	10	2025-01-28	\N	10	0928591762
29	Finanzas	14	2025-01-29	\N	10	0907713593
30	Líder	7	2025-01-30	\N	11	0998336577
31	Ventas	12	2025-01-31	\N	11	0937995052
32	Ventas	12	2025-02-01	\N	11	0986587807
33	Finanzas	14	2025-02-03	\N	12	0931826720
34	Ventas	14	2025-02-04	\N	12	0937528676
35	Líder	5	2025-02-02	\N	12	0992970821
36	Técnico	10	2025-02-05	\N	12	0984902721
37	Ventas	11	2025-02-06	\N	12	0925511931
38	Miembro	7	2025-02-07	\N	12	0957426891
39	Líder	7	2025-02-08	\N	13	0914581973
40	Marketing	5	2025-02-09	\N	13	0994755999
41	Miembro	4	2025-02-10	\N	13	0953979798
42	Líder	11	2025-02-11	\N	14	0949093830
43	Marketing	12	2025-02-12	\N	14	0913729347
44	Ventas	3	2025-02-13	\N	14	0958763526
45	Finanzas	9	2025-02-14	\N	14	0962025986
46	Miembro	12	2025-02-15	\N	14	0955342011
47	Finanzas	4	2025-02-16	\N	14	0927328722
48	Líder	6	2025-02-17	\N	15	0966595363
49	Finanzas	7	2025-02-18	\N	15	0909374087
50	Marketing	7	2025-02-20	\N	16	0909382975
51	Líder	5	2025-02-19	\N	16	0916349210
52	Líder	3	2025-02-21	\N	17	0953820472
53	Ventas	5	2025-02-22	\N	17	0993728345
54	Miembro	2	2025-02-24	\N	18	0965455400
55	Técnico	3	2025-02-25	\N	18	0955031611
56	Líder	4	2025-02-23	\N	18	0978015177
57	Líder	13	2025-02-26	\N	19	0900917409
58	Miembro	13	2025-02-27	\N	19	0994746689
59	Líder	10	2025-02-28	\N	20	0955221095
60	Miembro	2	2025-03-01	\N	20	0964009085
61	Ventas	10	2025-03-02	\N	20	0987258988
62	Líder	10	2025-03-03	\N	21	0966821376
63	Marketing	11	2025-03-04	\N	21	0934790780
64	Líder	7	2025-03-05	\N	22	0982283189
65	Miembro	13	2025-03-06	\N	22	0929885036
66	Líder	5	2025-03-07	\N	23	0999681119
67	Ventas	12	2025-03-08	\N	23	0914832746
68	Líder	2	2025-03-09	\N	24	0918895000
69	Ventas	8	2025-03-10	\N	24	0990323241
70	Ventas	7	2025-03-12	\N	25	0926068211
71	Miembro	12	2025-03-13	\N	25	0998279632
72	Ventas	3	2025-03-14	\N	25	0965304154
73	Líder	10	2025-03-11	\N	25	0922120853
74	Líder	8	2025-03-15	\N	26	0920910992
75	Miembro	3	2025-03-16	\N	26	0980289669
76	Ventas	5	2025-03-17	\N	26	0906253375
77	Técnico	3	2025-03-18	\N	26	0940648822
78	Ventas	11	2025-03-19	\N	26	0954812339
79	Finanzas	14	2025-03-20	\N	26	0929095212
80	Líder	9	2025-03-21	\N	27	0966502877
81	Marketing	9	2025-03-22	\N	27	0919894039
82	Miembro	13	2025-03-23	\N	27	0986377705
83	Ventas	13	2025-03-24	\N	28	0999002736
84	Ventas	6	2025-03-25	\N	28	0981779709
85	Miembro	14	2025-03-26	\N	28	0901536276
86	Líder	5	2025-03-27	\N	29	0976660666
87	Técnico	12	2025-03-28	\N	29	0914300832
88	Miembro	6	2025-03-29	\N	29	0919496717
89	Líder	2	2025-03-30	\N	30	0908147925
90	Miembro	4	2025-03-31	\N	30	0952202436
91	Marketing	2	2025-04-01	\N	30	0916694545
92	Marketing	7	2025-04-03	\N	31	0904509577
93	Líder	2	2025-04-02	\N	31	0938818751
94	Miembro	6	2025-04-04	\N	31	0951968403
95	Técnico	12	2025-04-05	\N	31	0908241759
96	Líder	8	2025-04-06	\N	32	0956156028
97	Técnico	11	2025-04-07	\N	32	0966289569
98	Líder	5	2025-04-08	\N	33	0987701546
99	Miembro	13	2025-04-09	\N	33	0955990519
100	Líder	13	2025-04-10	\N	34	0952146553
101	Marketing	2	2025-04-11	\N	34	0935304546
102	Miembro	6	2025-04-12	\N	34	0941346553
103	Finanzas	8	2025-04-14	\N	35	0987459753
104	Líder	5	2025-04-13	\N	35	0934427710
105	Técnico	5	2025-04-15	\N	35	0994644360
106	Líder	2	2025-04-16	\N	36	0957746980
107	Técnico	8	2025-04-17	\N	36	0937582246
108	Miembro	3	2025-04-18	\N	36	0953089660
109	Técnico	5	2025-04-19	\N	36	0998200257
110	Finanzas	11	2025-04-21	\N	37	0929611055
111	Líder	14	2025-04-20	\N	37	0907334644
112	Líder	13	2025-04-22	\N	38	0908583254
113	Marketing	7	2025-04-23	\N	38	0974686581
114	Finanzas	6	2025-04-24	\N	38	0949897417
115	Miembro	9	2025-04-25	\N	38	0908505417
116	Ventas	5	2025-04-26	\N	38	0970764162
117	Líder	3	2025-04-27	\N	39	0925627029
118	Miembro	12	2025-04-28	\N	39	0993113163
119	Técnico	11	2025-04-29	\N	39	0933813705
120	Ventas	9	2025-04-30	\N	39	0977070224
121	Líder	8	2025-05-01	\N	40	0996703618
122	Ventas	10	2025-05-02	\N	40	0924405602
123	Miembro	5	2025-05-03	\N	40	0901758658
124	Técnico	14	2025-05-04	\N	40	0953991454
125	Líder	9	2025-05-05	\N	41	0942426826
126	Miembro	7	2025-05-06	\N	41	0926690980
127	Finanzas	12	2025-05-07	\N	41	0991181790
128	Técnico	11	2025-05-08	\N	42	0946206661
129	Miembro	9	2025-05-09	\N	42	0952603155
130	Miembro	2	2025-05-10	\N	42	0970653245
131	Líder	3	2025-05-11	\N	43	0917212261
132	Finanzas	7	2025-05-12	\N	43	0931505852
133	Miembro	4	2025-05-13	\N	43	0911749235
134	Finanzas	14	2025-05-14	\N	43	0957645009
135	Marketing	7	2025-05-16	\N	44	0993051520
136	Líder	9	2025-05-15	\N	44	0992053497
137	Ventas	3	2025-05-17	\N	44	0921460873
138	Miembro	4	2025-05-18	\N	44	0982006132
139	Líder	11	2025-05-19	\N	45	0989844525
140	Ventas	14	2025-05-20	\N	45	0933284819
141	Miembro	9	2025-05-21	\N	45	0918153534
142	Ventas	4	2025-05-23	\N	46	0915194917
143	Líder	6	2025-05-22	\N	46	0964402794
144	Miembro	14	2025-05-24	\N	46	0955526928
145	Líder	3	2025-05-25	\N	47	0998116422
146	Miembro	2	2025-05-26	\N	47	0969804155
147	Miembro	5	2025-05-27	\N	47	0938485936
148	Miembro	6	2025-05-28	\N	47	0924028934
149	Líder	10	2025-05-29	\N	48	0999525745
150	Técnico	2	2025-05-30	\N	48	0975386189
151	Finanzas	11	2025-05-31	\N	48	0994025883
152	Ventas	4	2025-06-01	\N	48	0919992869
153	Líder	10	2025-06-02	\N	49	0973109644
154	Miembro	6	2025-06-03	\N	49	0981416075
155	Ventas	4	2025-06-04	\N	49	0930266649
156	Marketing	5	2025-06-06	\N	50	0919532359
157	Líder	4	2025-06-05	\N	50	0939911727
158	Marketing	11	2025-06-07	\N	50	0938082511
159	Líder	6	2025-06-08	\N	51	0955381615
160	Marketing	7	2025-06-09	\N	51	0972474628
161	Miembro	14	2025-06-10	\N	51	0961383481
162	Líder	9	2025-06-11	\N	52	0997442276
163	Técnico	5	2025-06-12	\N	52	0968854174
164	Ventas	8	2025-06-13	\N	52	0944754823
165	Miembro	8	2025-06-14	\N	52	0975356798
166	Marketing	11	2025-06-15	\N	52	0991877480
167	Finanzas	10	2025-06-17	\N	53	0910810892
168	Líder	2	2025-06-16	\N	53	0962134277
169	Miembro	3	2025-06-18	\N	53	0943678557
170	Miembro	5	2025-06-19	\N	53	0909527898
171	Finanzas	12	2025-06-20	\N	53	0979105341
172	Miembro	10	2025-06-22	\N	54	0975505884
173	Ventas	14	2025-06-23	\N	54	0918624939
174	Líder	8	2025-06-21	\N	54	0952256922
175	Finanzas	13	2025-06-24	\N	54	0951026818
176	Técnico	12	2025-06-25	\N	54	0963588267
177	Ventas	10	2025-06-26	\N	54	0985504006
178	Técnico	4	2025-06-28	\N	55	0941221160
179	Líder	11	2025-06-27	\N	55	0987480954
180	Técnico	4	2025-06-29	\N	55	0970662959
181	Líder	12	2025-06-30	\N	56	0993373481
182	Técnico	9	2025-07-01	\N	56	0933074444
183	Líder	7	2025-07-02	\N	57	0916244854
184	Técnico	2	2025-07-03	\N	57	0908985309
185	Marketing	12	2025-07-04	\N	57	0990901759
186	Miembro	5	2025-07-05	\N	57	0940849578
187	Finanzas	8	2025-07-06	\N	57	0959030960
188	Técnico	9	2025-07-08	\N	58	0931029687
189	Miembro	8	2025-07-09	\N	58	0987617563
190	Líder	8	2025-07-07	\N	58	0939413784
191	Miembro	2	2025-07-11	\N	59	0996845799
192	Líder	2	2025-07-10	\N	59	0933089317
193	Finanzas	10	2025-07-13	\N	60	0957290227
194	Líder	12	2025-07-12	\N	60	0921770634
195	Miembro	7	2025-07-14	\N	60	0909596291
\.


--
-- TOC entry 5264 (class 0 OID 123280)
-- Dependencies: 239
-- Data for Name: participacion_miembro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.participacion_miembro (id_miembro, id_mentoria, participacion) FROM stdin;
1	1	83
2	1	91
3	1	73
4	2	74
5	2	86
6	2	74
7	2	70
8	2	84
9	3	91
10	3	86
11	4	97
12	4	78
13	4	83
14	5	75
15	5	77
16	5	85
17	6	88
18	6	90
19	6	78
20	7	77
21	7	82
22	8	76
23	8	77
24	9	99
25	9	80
26	9	92
27	10	79
28	10	71
29	10	71
30	11	100
31	11	81
32	11	70
33	12	81
34	12	78
35	12	93
36	12	98
37	12	97
38	12	72
39	13	70
40	13	96
41	13	75
42	14	74
43	14	99
44	14	75
45	14	96
46	14	94
47	14	76
48	15	97
49	15	89
50	16	84
51	16	85
52	17	71
53	17	96
54	18	79
55	18	78
56	18	70
57	19	88
58	19	80
59	20	71
60	20	90
61	20	74
62	21	78
63	21	84
64	22	90
65	22	75
66	23	98
67	23	86
68	24	84
69	24	93
70	25	76
71	25	78
72	25	98
73	25	91
74	26	99
75	26	89
76	26	74
77	26	93
78	26	97
79	26	87
80	27	79
81	27	94
82	27	73
83	28	100
84	28	90
85	28	70
86	29	91
87	29	70
88	29	72
89	30	90
90	30	93
91	30	97
92	31	77
93	31	95
94	31	82
95	31	93
96	32	74
97	32	92
98	33	90
99	33	83
100	34	84
101	34	75
102	34	82
103	35	88
104	35	94
105	35	88
106	36	84
107	36	92
108	36	91
109	36	99
110	37	94
111	37	72
112	38	89
113	38	92
114	38	99
115	38	100
116	38	87
117	39	71
118	39	76
119	39	93
120	39	86
121	40	91
122	40	77
123	40	94
124	40	72
125	41	100
126	41	93
127	41	91
128	42	78
129	42	94
130	42	79
131	43	96
132	43	100
133	43	96
134	43	82
135	44	98
136	44	83
137	44	95
138	44	98
139	45	81
140	45	94
141	45	100
142	46	96
143	46	76
144	46	84
145	47	83
146	47	76
147	47	76
148	47	72
149	48	91
150	48	72
151	48	73
152	48	74
153	49	86
154	49	78
155	49	84
156	50	94
157	50	81
158	50	77
159	51	72
160	51	83
161	51	95
162	52	84
163	52	78
164	52	79
165	52	70
166	52	75
167	53	73
168	53	78
169	53	99
170	53	96
171	53	93
172	54	100
173	54	79
174	54	81
175	54	71
176	54	84
177	54	85
178	55	80
179	55	90
180	55	81
181	56	83
182	56	91
183	57	91
184	57	92
185	57	91
186	57	79
187	57	77
188	58	74
189	58	80
190	58	91
191	59	96
192	59	83
193	60	72
194	60	68
195	60	95
181	61	82
182	61	89
178	62	70
179	62	82
180	62	92
149	63	93
150	63	100
151	63	85
152	63	84
167	64	86
168	64	99
169	64	73
170	64	75
171	64	94
98	65	76
99	65	89
39	66	80
40	66	93
41	66	82
145	67	75
146	67	97
147	67	70
148	67	100
112	68	71
113	68	85
114	68	98
115	68	91
116	68	76
110	69	89
111	69	76
139	70	96
140	70	72
141	70	73
121	71	91
122	71	87
123	71	93
124	71	95
162	72	72
163	72	89
164	72	81
165	72	93
166	72	76
96	73	100
97	73	84
156	74	70
157	74	92
158	74	73
131	75	88
132	75	74
133	75	76
134	75	88
112	76	90
113	76	90
114	76	100
115	76	87
116	76	80
1	77	68
2	77	90
3	77	78
167	78	98
168	78	88
169	78	90
170	78	100
171	78	89
62	79	78
63	79	88
9	80	100
10	80	95
11	81	86
12	81	89
13	81	100
188	82	98
189	82	87
190	82	90
14	83	100
15	83	93
16	83	70
139	84	90
140	84	89
141	84	40
17	85	80
18	85	99
19	85	100
125	86	80
126	86	76
127	86	90
20	87	99
21	87	77
22	88	100
23	88	92
100	88	83
101	89	78
102	89	70
178	90	100
179	90	96
180	90	85
\.


--
-- TOC entry 5256 (class 0 OID 123164)
-- Dependencies: 231
-- Data for Name: perfil_academico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.perfil_academico (id_miembro, matricula, gpa, mat_aprobadas, mat_actuales, id_carrera) FROM stdin;
1	249105678	75	19	4	6
2	251185612	97	27	6	4
3	299419369	94	7	4	5
5	284954085	92	34	3	6
6	272929855	83	3	3	18
8	200530485	78	23	1	1
9	224665998	71	17	2	10
11	206752044	77	23	2	7
12	252821037	70	25	2	1
13	212886054	94	0	3	6
14	204106227	99	32	5	2
16	222592963	91	33	1	18
17	202135977	96	17	5	4
19	294745235	96	31	5	15
20	222567181	71	0	4	8
21	255169745	80	9	5	6
22	295049107	94	10	6	4
23	270999615	70	4	6	6
24	209729469	82	20	5	5
25	249815999	75	24	3	16
27	215189965	73	32	2	6
31	220121957	79	1	6	5
32	263332397	82	21	3	8
34	275154025	94	10	1	17
36	234457640	78	18	1	17
37	222601680	91	28	3	1
38	262802721	90	24	1	18
40	271156147	97	21	3	7
42	203387883	81	17	6	10
43	268045041	86	1	6	4
44	258774501	88	7	4	7
45	299002717	89	15	5	10
46	220853558	75	25	5	10
47	298604775	90	2	5	14
48	207839740	78	18	3	2
49	201180555	70	8	2	2
50	237016086	94	3	2	4
51	259390123	79	1	1	9
52	236746861	98	34	3	6
53	248194611	94	17	4	13
54	236056014	72	15	4	5
55	227231863	89	7	5	12
56	286359622	80	6	5	2
57	266520556	96	26	5	5
58	282596726	85	17	2	17
59	247229397	98	2	1	4
60	239188509	73	11	5	5
61	226169829	84	34	3	2
62	299851558	81	29	1	6
63	221352118	92	14	5	18
64	257770930	96	22	5	3
65	287856084	79	34	5	17
66	267230693	75	3	4	5
67	275805144	89	5	6	8
68	201385373	93	16	4	4
69	252731800	76	31	4	3
70	290567475	91	17	4	4
71	262351804	93	7	5	4
73	273742550	81	33	5	2
74	235302755	90	24	6	15
75	248071105	77	21	4	10
76	223859031	71	17	2	6
78	218515729	78	33	2	15
79	232027948	74	11	2	2
80	264054388	100	26	2	4
81	254268585	97	14	6	9
82	223447178	86	16	6	8
84	248815339	73	0	2	16
85	204612716	82	19	6	8
87	213671600	82	9	6	17
88	259501080	88	29	4	17
89	290900940	92	30	6	9
90	269514862	79	13	3	5
91	291690946	81	29	3	6
92	292504606	88	14	5	16
95	225135835	89	10	4	18
96	205596682	71	14	4	2
97	240843572	77	18	6	2
98	288520721	74	20	1	17
100	279707997	74	9	6	10
101	232499544	91	20	5	9
102	276535323	99	11	2	2
104	230174021	89	25	4	10
105	224338778	98	0	3	2
106	280989212	76	3	3	6
107	228654811	80	4	6	9
108	267080397	76	11	3	18
109	268936792	94	21	2	18
111	236526660	90	33	2	18
112	281484875	90	27	6	6
113	290137713	71	16	4	17
114	297223002	99	15	2	13
115	213545138	90	15	2	16
116	232692205	79	9	1	2
117	295693371	92	31	2	8
118	227627076	98	20	3	17
119	232159067	73	12	3	13
120	204590338	92	11	3	5
121	209809770	91	34	6	5
122	274361448	72	8	5	2
124	284190633	74	24	6	4
125	253016010	83	0	5	7
126	287378278	94	0	3	13
127	227360397	84	3	2	15
128	221336936	97	34	5	2
129	282807470	88	26	5	1
131	267839837	81	28	6	8
133	209668578	70	10	6	3
134	299892799	86	0	3	10
135	287973325	93	4	6	18
136	298718103	85	20	4	3
137	224562561	88	0	1	2
138	248888287	74	17	4	13
139	235872724	93	25	2	15
140	278676695	87	16	1	18
141	255550655	71	14	1	18
142	299789598	78	16	5	16
143	262859255	78	33	5	1
144	281412767	78	17	4	10
145	204284060	98	22	5	13
147	295018325	74	0	5	4
148	264413320	91	15	4	6
149	298199512	85	4	2	3
150	263877965	90	9	4	2
151	246604413	79	22	6	11
152	233789736	74	17	6	16
153	233301846	85	8	2	5
155	208024876	99	11	4	2
156	200871395	79	25	6	16
157	242686676	74	2	1	18
158	273961446	70	13	6	6
159	238529593	96	26	4	8
160	245947297	85	30	3	8
161	246562173	80	22	1	6
162	203708456	70	14	4	2
164	234558304	82	11	2	1
165	282084710	96	11	3	8
166	284597001	74	23	5	9
167	261394585	91	6	4	5
168	248645437	77	25	6	8
172	272256000	87	23	3	4
173	282920336	91	4	5	8
174	273672345	83	34	2	6
175	289407468	89	1	4	17
176	276512998	73	25	6	1
177	283142702	88	3	1	5
179	256948239	79	23	4	7
180	222291912	80	30	2	1
181	295425370	89	33	6	16
182	213014026	88	7	3	17
183	245562391	95	2	6	15
184	233709240	96	29	5	17
185	264711773	84	33	2	14
186	274297641	87	10	6	16
187	273709790	94	32	4	9
188	227781721	90	3	1	10
189	270618091	99	11	5	1
191	216644200	79	22	1	11
192	222910399	90	18	1	3
194	225702485	86	23	3	6
195	200937986	94	31	3	7
\.


--
-- TOC entry 5248 (class 0 OID 123079)
-- Dependencies: 223
-- Data for Name: persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.persona (cedula, nombre, apellido, fecha_nacimiento, telefono, correo) FROM stdin;
0951073613	Alejandra	Leon	2006-05-08	593965070110	alejandra.leon@uees.edu.ec
0916185068	Ana	Santos	2006-03-25	593908149814	ana.santos@uees.edu.ec
0995386762	Ricardo	Zuniga	2005-05-12	593979623749	ricardo.zuniga@uees.edu.ec
0953880564	Andres	Mejia	2004-02-20	593960289106	andres.mejia@gmail.com
0986782778	Diego	Guzman	2004-10-18	593967813226	diego.guzman@uees.edu.ec
0941900462	Irene	Santos	2000-03-25	593935306229	irene.santos@uees.edu.ec
0951432235	Pablo	Viteri	2002-04-24	593963067251	pablo.viteri@gmail.com
0996964250	Valeria	Delgado	2007-10-20	593949621401	valeria.delgado@uees.edu.ec
0916871182	Nicolas	Martinez	2007-02-20	593976675421	nicolas.martinez@uees.edu.ec
0909191142	Rafael	Zambrano	2003-07-19	593986563191	rafael.zambrano@gmail.com
0976277845	Belen	Zamora	2003-10-18	593951852692	belen.zamora@uees.edu.ec
0980888873	Diana	Benitez	2001-02-07	593996313595	diana.benitez@uees.edu.ec
0977665969	Gonzalo	Ponce	2001-08-30	593972624551	gonzalo.ponce@uees.edu.ec
0990095702	Elena	Ramirez	2000-10-11	593947711930	elena.ramirez@uees.edu.ec
0948062820	Felicia	Reyes	2000-10-09	593972234511	felicia.reyes@gmail.com
0923808230	Ximena	Zuniga	2007-03-27	593946405848	ximena.zuniga@uees.edu.ec
0920277717	Maria	Rios	2001-05-31	593962153027	maria.rios@uees.edu.ec
0907258272	Pablo	Rios	2004-01-21	593965782184	pablo.rios@gmail.com
0926838375	Rocio	Palacios	2007-11-02	593922969342	rocio.palacios@uees.edu.ec
0902245069	Fernando	Caicedo	2005-07-19	593963048124	fernando.caicedo@uees.edu.ec
0917168413	Pablo	Serrano	2007-10-30	593966622339	pablo.serrano@uees.edu.ec
0962129225	Gonzalo	Morales	2003-12-29	593947309311	gonzalo.morales@uees.edu.ec
0925614637	Pablo	Valle	2006-12-31	593996738008	pablo.valle@uees.edu.ec
0994859736	Lucia	Arboleda	2000-07-13	593918761384	lucia.arboleda@uees.edu.ec
0959401469	Pedro	Carvajal	2001-06-11	593985048042	pedro.carvajal@uees.edu.ec
0993909712	Santiago	Vega	2002-01-07	593944817728	santiago.vega@gmail.com
0981214580	Daniela	Hurtado	2001-04-23	593938569671	daniela.hurtado@uees.edu.ec
0928591762	Hector	Zuniga	1999-07-03	593940611466	hector.zuniga@gmail.com
0907713593	Romina	Herrera	2000-05-17	593906610477	romina.herrera@gmail.com
0998336577	Noelia	Martinez	2002-04-27	593949817712	noelia.martinez@gmail.com
0937995052	Patricia	Mejia	2002-02-22	593980056227	patricia.mejia@uees.edu.ec
0986587807	Romina	Lema	2003-05-17	593940818973	romina.lema@uees.edu.ec
0931826720	Angela	Jimenez	2006-04-06	593918508430	angela.jimenez@gmail.com
0937528676	Angela	Mejia	2004-05-15	593982618867	angela.mejia@uees.edu.ec
0992970821	Monica	Paredes	2001-11-25	593942508909	monica.paredes@gmail.com
0984902721	Nicolas	Cardenas	2006-11-13	593996423399	nicolas.cardenas@uees.edu.ec
0925511931	Romina	Rios	2000-04-29	593932791108	romina.rios@uees.edu.ec
0957426891	Sofia	Garcia	2002-03-16	593977814614	sofia.garcia@uees.edu.ec
0914581973	Diego	Jimenez	2007-08-25	593920796414	diego.jimenez@gmail.com
0994755999	Isabel	Martinez	2002-07-07	593936899964	isabel.martinez@uees.edu.ec
0953979798	Pablo	Salas	2005-05-23	593946511692	pablo.salas@gmail.com
0949093830	Carmen	Mendez	2005-07-15	593903901174	carmen.mendez@uees.edu.ec
0913729347	Fernando	Zamora	2004-10-17	593936455636	fernando.zamora@uees.edu.ec
0958763526	Gabriela	Arboleda	2007-07-25	593959063798	gabriela.arboleda@uees.edu.ec
0962025986	Jorge	Lema	2005-04-27	593962904209	jorge.lema@uees.edu.ec
0955342011	Miguel	Morales	2004-01-09	593986252912	miguel.morales@uees.edu.ec
0927328722	Santiago	Valle	2007-08-27	593906750045	santiago.valle@uees.edu.ec
0966595363	Ricardo	Morales	2007-12-17	593926415746	ricardo.morales@uees.edu.ec
0909374087	Romina	Herrera	2004-01-03	593997456528	romina.herrera2@uees.edu.ec
0909382975	Diana	Ramirez	2002-03-17	593905664396	diana.ramirez@uees.edu.ec
0916349210	Lucia	Zambrano	1999-07-12	593997271158	lucia.zambrano@uees.edu.ec
0953820472	Isabel	Cedenio	2004-07-18	593958704524	isabel.cedenio@uees.edu.ec
0993728345	Maria	Aguirre	2003-02-07	593972283833	maria.aguirre@uees.edu.ec
0965455400	Bruno	Salas	2002-04-05	593983328117	bruno.salas@uees.edu.ec
0955031611	Tatiana	Vega	2005-12-08	593947405011	tatiana.vega@uees.edu.ec
0978015177	Tatiana	Ortega	2002-10-11	593925102613	tatiana.ortega@uees.edu.ec
0900917409	Isabel	Castro	2003-03-07	593985370177	isabel.castro@uees.edu.ec
0994746689	Sofia	Penafiel	1999-08-08	593913870230	sofia.penafiel@uees.edu.ec
0955221095	Daniela	Suarez	2007-05-14	593946637374	daniela.suarez@uees.edu.ec
0964009085	Patricia	Santos	2001-07-03	593999377780	patricia.santos@uees.edu.ec
0987258988	Rafael	Ortega	1999-10-30	593995050715	rafael.ortega@uees.edu.ec
0966821376	Felicia	Narvaez	2006-05-30	593907486389	felicia.narvaez@uees.edu.ec
0934790780	Sebastian	Benitez	2001-11-26	593932078168	sebastian.benitez@uees.edu.ec
0982283189	Irene	Ramirez	2003-12-02	593910172287	irene.ramirez@uees.edu.ec
0929885036	Lucia	Mejia	1999-07-10	593947712257	lucia.mejia@uees.edu.ec
0999681119	Andrea	Cornejo	2004-02-02	593916317170	andrea.cornejo@uees.edu.ec
0914832746	Jorge	Caicedo	2000-03-26	593927822496	jorge.caicedo@uees.edu.ec
0918895000	Elena	Rios	2006-11-01	593937566712	elena.rios@uees.edu.ec
0990323241	Nicolas	Ponce	2004-01-12	593944830497	nicolas.ponce@uees.edu.ec
0926068211	Angela	Rios	2003-04-14	593976980861	angela.rios@uees.edu.ec
0998279632	Sebastian	Rios	2000-08-30	593999462473	sebastian.rios@uees.edu.ec
0965304154	Vicente	Hurtado	2001-08-14	593935840843	vicente.hurtado@gmail.com
0922120853	Vicente	Vega	2000-08-27	593987717775	vicente.vega@uees.edu.ec
0920910992	Alberto	Serrano	2003-10-21	593942931550	alberto.serrano@uees.edu.ec
0980289669	Belen	Aguirre	2000-08-02	593935751487	belen.aguirre@uees.edu.ec
0906253375	Daniela	Zambrano	2006-03-31	593963342249	daniela.zambrano@uees.edu.ec
0940648822	Jorge	Cardenas	2004-03-28	593918008821	jorge.cardenas@gmail.com
0954812339	Mauricio	Garcia	2007-08-02	593901623634	mauricio.garcia@uees.edu.ec
0929095212	Nicolas	Lopez	2001-10-14	593968419985	nicolas.lopez@uees.edu.ec
0966502877	Lucia	Mejia	2000-09-05	593902547645	lucia.mejia2@uees.edu.ec
0919894039	Maria	Bravo	2003-11-20	593988397787	maria.bravo@uees.edu.ec
0986377705	Mauricio	Morales	2001-08-15	593903710652	mauricio.morales@uees.edu.ec
0999002736	Diego	Martinez	2007-11-14	593998389567	diego.martinez@gmail.com
0981779709	Patricia	Rios	2000-12-27	593902930574	patricia.rios@uees.edu.ec
0901536276	Rafael	Cornejo	2002-06-02	593950205593	rafael.cornejo@uees.edu.ec
0976660666	Alberto	Aguirre	2005-03-30	593950446692	alberto.aguirre@gmail.com
0914300832	Jorge	Palacios	2006-11-01	593937272587	jorge.palacios@uees.edu.ec
0919496717	Ximena	Arboleda	2001-01-24	593980052128	ximena.arboleda@uees.edu.ec
0908147925	Alberto	Herrera	2001-11-04	593906405788	alberto.herrera@uees.edu.ec
0952202436	Esteban	Barreto	2007-02-27	593919234030	esteban.barreto@uees.edu.ec
0916694545	Ricardo	Carvajal	2007-08-25	593954056825	ricardo.carvajal@uees.edu.ec
0904509577	Elena	Barreto	2007-07-15	593938733946	elena.barreto@uees.edu.ec
0938818751	Matias	Zambrano	2002-07-08	593970155696	matias.zambrano@gmail.com
0951968403	Pedro	Acosta	2007-04-09	593907124941	pedro.acosta@gmail.com
0908241759	Ricardo	Ponce	2007-10-28	593965967881	ricardo.ponce@uees.edu.ec
0956156028	Marco	Acosta	2000-05-10	593903580456	marco.acosta@uees.edu.ec
0966289569	Valeria	Bravo	2003-08-31	593924901103	valeria.bravo@uees.edu.ec
0987701546	Ana	Aguirre	2006-12-03	593980327956	ana.aguirre@uees.edu.ec
0955990519	Camila	Reyes	2002-08-24	593941732272	camila.reyes@gmail.com
0952146553	Alberto	Zamora	1999-05-19	593992984272	alberto.zamora@uees.edu.ec
0935304546	Patricia	Castro	2005-07-25	593950829339	patricia.castro@uees.edu.ec
0941346553	Tatiana	Arboleda	2007-07-31	593978518472	tatiana.arboleda@uees.edu.ec
0987459753	Ana	Rios	1999-02-23	593943085424	ana.rios@gmail.com
0934427710	Andres	Caicedo	2005-10-23	593970481541	andres.caicedo@uees.edu.ec
0994644360	Angela	Caicedo	2003-10-31	593908654659	angela.caicedo@uees.edu.ec
0957746980	Belen	Herrera	1999-06-04	593974224576	belen.herrera@uees.edu.ec
0937582246	Daniela	Aguirre	2001-04-26	593973510136	daniela.aguirre@uees.edu.ec
0953089660	Ricardo	Vargas	2005-02-12	593950875910	ricardo.vargas@uees.edu.ec
0998200257	Santiago	Penafiel	1999-12-18	593929131750	santiago.penafiel@uees.edu.ec
0929611055	Esteban	Mendez	1999-01-06	593994522161	esteban.mendez@gmail.com
0907334644	Gabriela	Arboleda	2005-08-23	593959274555	gabriela.arboleda2@uees.edu.ec
0908583254	Andrea	Mora	2000-10-30	593925872947	andrea.mora@uees.edu.ec
0974686581	Claudia	Zambrano	2005-03-22	593959767800	claudia.zambrano@uees.edu.ec
0949897417	Gonzalo	Zamora	2003-05-14	593925601278	gonzalo.zamora@uees.edu.ec
0908505417	Nicolas	Cardenas	2000-12-02	593962097131	nicolas.cardenas2@uees.edu.ec
0970764162	Ximena	Torres	2001-06-25	593991622524	ximena.torres@uees.edu.ec
0925627029	Carolina	Andrade	2003-09-07	593952538637	carolina.andrade@uees.edu.ec
0993113163	Gonzalo	Herrera	2003-05-18	593909006416	gonzalo.herrera@uees.edu.ec
0933813705	Ximena	Valle	2004-10-28	593967121959	ximena.valle@uees.edu.ec
0977070224	Ximena	Torres	1999-04-25	593947235272	ximena.torres2@uees.edu.ec
0996703618	Carlos	Alvarez	2006-11-05	593954909294	carlos.alvarez@uees.edu.ec
0924405602	Monica	Cardenas	2001-06-26	593963203407	monica.cardenas@uees.edu.ec
0901758658	Noelia	Cornejo	2003-05-07	593915498267	noelia.cornejo@gmail.com
0953991454	Ximena	Ortega	2004-07-23	593973689914	ximena.ortega@uees.edu.ec
0942426826	Alberto	Cornejo	2002-07-31	593929845822	alberto.cornejo@uees.edu.ec
0926690980	Angela	Mora	2003-12-17	593959690392	angela.mora@uees.edu.ec
0991181790	Bruno	Narvaez	2004-10-30	593979073813	bruno.narvaez@uees.edu.ec
0946206661	Carmen	Hurtado	2003-01-10	593990427074	carmen.hurtado@uees.edu.ec
0952603155	Carolina	Sanchez	1999-04-14	593964346566	carolina.sanchez@uees.edu.ec
0970653245	Mauricio	Narvaez	2001-10-10	593973057302	mauricio.narvaez@gmail.com
0917212261	Diego	Benitez	2002-10-27	593934265477	diego.benitez@uees.edu.ec
0931505852	Elena	Cornejo	1999-02-28	593958616911	elena.cornejo@gmail.com
0911749235	Fernando	Ramirez	2002-03-10	593950017113	fernando.ramirez@uees.edu.ec
0957645009	Rocio	Cornejo	1999-05-30	593957621366	rocio.cornejo@uees.edu.ec
0993051520	Belen	Palacios	2005-02-07	593993779544	belen.palacios@uees.edu.ec
0992053497	Carlos	Jimenez	2006-12-18	593933077752	carlos.jimenez@uees.edu.ec
0921460873	Maria	Zuniga	2002-03-05	593952566198	maria.zuniga@uees.edu.ec
0982006132	Valeria	Mejia	2000-01-10	593998736828	valeria.mejia@uees.edu.ec
0989844525	Bruno	Lopez	2006-07-05	593992231990	bruno.lopez@uees.edu.ec
0933284819	Pedro	Caicedo	2006-04-25	593935218550	pedro.caicedo@uees.edu.ec
0918153534	Rafael	Vega	2004-12-22	593971090419	rafael.vega@uees.edu.ec
0915194917	Felipe	Lopez	2002-02-07	593901662965	felipe.lopez@uees.edu.ec
0964402794	Gonzalo	Lopez	2005-12-10	593999945869	gonzalo.lopez@uees.edu.ec
0955526928	Rafael	Ponce	2007-05-04	593943934258	rafael.ponce@uees.edu.ec
0998116422	Andres	Cardenas	2005-07-09	593957604286	andres.cardenas@uees.edu.ec
0969804155	Diego	Lopez	2005-07-10	593910248386	diego.lopez@gmail.com
0938485936	Luis	Martinez	2003-06-04	593918771181	luis.martinez@uees.edu.ec
0924028934	Miguel	Aguirre	2004-02-02	593995826104	miguel.aguirre@uees.edu.ec
0999525745	Bruno	Bravo	2005-03-10	593940528175	bruno.bravo@uees.edu.ec
0975386189	Isabel	Vargas	2000-12-13	593995334831	isabel.vargas@uees.edu.ec
0994025883	Maria	Acosta	2004-08-15	593906370298	maria.acosta@uees.edu.ec
0919992869	Valeria	Lopez	2000-06-26	593979616381	valeria.lopez@uees.edu.ec
0973109644	Esteban	Mendoza	2002-04-30	593902697117	esteban.mendoza@uees.edu.ec
0981416075	Hector	Garcia	2003-07-21	593962024818	hector.garcia@gmail.com
0930266649	Tatiana	Suarez	2003-08-31	593917179611	tatiana.suarez@uees.edu.ec
0919532359	Carmen	Morales	2004-09-02	593988899739	carmen.morales@uees.edu.ec
0939911727	Mauricio	Leon	2000-06-03	593935295229	mauricio.leon@uees.edu.ec
0938082511	Pablo	Ramirez	2005-09-22	593950799296	pablo.ramirez@uees.edu.ec
0955381615	Gabriela	Lopez	1999-06-12	593984154397	gabriela.lopez@uees.edu.ec
0972474628	Juan	Caicedo	2004-03-03	593905776864	juan.caicedo@uees.edu.ec
0961383481	Miguel	Santos	1999-08-14	593978522882	miguel.santos@uees.edu.ec
0997442276	Ana	Jimenez	2007-03-02	593998879445	ana.jimenez@uees.edu.ec
0968854174	Andrea	Zambrano	2006-02-09	593977067448	andrea.zambrano@gmail.com
0944754823	Bruno	Ponce	2002-06-26	593937532454	bruno.ponce@uees.edu.ec
0975356798	Hector	Cedenio	1999-06-21	593953472973	hector.cedenio@uees.edu.ec
0991877480	Renata	Valle	2005-06-16	593907520256	renata.valle@uees.edu.ec
0910810892	Carlos	Bravo	2003-10-07	593985158489	carlos.bravo@uees.edu.ec
0962134277	Diana	Zuniga	2001-11-12	593988298384	diana.zuniga@uees.edu.ec
0943678557	Gabriela	Alvarez	2002-12-07	593995677273	gabriela.alvarez@gmail.com
0909527898	Juan	Arboleda	2000-06-29	593964880451	juan.arboleda@gmail.com
0979105341	Romina	Alvarez	2001-10-12	593958107441	romina.alvarez@gmail.com
0975505884	Alberto	Barreto	2004-03-27	593947154999	alberto.barreto@uees.edu.ec
0918624939	Daniela	Morales	2000-10-14	593906246335	daniela.morales@uees.edu.ec
0952256922	Diana	Lopez	2004-12-05	593948233583	diana.lopez@uees.edu.ec
0951026818	Esteban	Morales	1999-08-20	593946493932	esteban.morales@uees.edu.ec
0963588267	Lucia	Carvajal	2002-11-18	593978303011	lucia.carvajal@uees.edu.ec
0985504006	Sofia	Acosta	2001-01-22	593922220666	sofia.acosta@uees.edu.ec
0941221160	Elena	Valle	2004-11-28	593953004287	elena.valle@gmail.com
0987480954	Lucia	Zuniga	2007-12-17	593975883292	lucia.zuniga@uees.edu.ec
0970662959	Renata	Bravo	1999-09-27	593934136182	renata.bravo@uees.edu.ec
0993373481	Pedro	Alvarez	2001-03-30	593965531643	pedro.alvarez@uees.edu.ec
0933074444	Rocio	Cornejo	2007-08-02	593941132651	rocio.cornejo2@uees.edu.ec
0916244854	Andrea	Zambrano	2001-06-17	593940888222	andrea.zambrano2@uees.edu.ec
0908985309	Felicia	Jimenez	1999-02-03	593912165155	felicia.jimenez@uees.edu.ec
0990901759	Nicolas	Cedenio	2000-05-26	593975387867	nicolas.cedenio@uees.edu.ec
0940849578	Patricia	Jimenez	2007-05-10	593919545950	patricia.jimenez@uees.edu.ec
0959030960	Romina	Arboleda	2005-10-03	593969373630	romina.arboleda@uees.edu.ec
0931029687	Diana	Valle	2003-04-22	593947413364	diana.valle@uees.edu.ec
0987617563	Rocio	Valle	2007-12-06	593972634841	rocio.valle@uees.edu.ec
0939413784	Sofia	Zambrano	2005-07-08	593928156330	sofia.zambrano@gmail.com
0996845799	Claudia	Martinez	1999-07-21	593966793948	claudia.martinez@uees.edu.ec
0933089317	Santiago	Zuniga	2004-11-06	593930818550	santiago.zuniga@uees.edu.ec
0957290227	Camila	Vega	2005-08-22	593912321745	camila.vega@gmail.com
0921770634	Camila	Morales	2005-07-22	593979040098	camila.morales@uees.edu.ec
0909596291	Claudia	Bravo	2002-04-23	593998742814	claudia.bravo@uees.edu.ec
0967116845	Laura	Paredes	1986-11-11	593963000000	laura.paredes@expositores.ec
0977590175	Andrés	Cedeño	1985-01-31	593974000000	andres.cedeno@expositores.ec
0918636374	Valentina	Lozano	1995-09-30	593973000000	valentina.lozano@expositores.ec
0954589297	Diego	Camacho	1989-08-16	593966000000	diego.camacho@expositores.ec
0950017012	Sofía	Mora	1987-08-04	593989000000	sofia.mora@expositores.ec
0977063242	Miguel	Almeida	1987-08-18	593950000000	miguel.almeida@expositores.ec
0941541520	Ricardo	Torres	1976-05-07	593955000003	ricardo.torres@mentoria.ec
0964361103	María	Vega	1974-05-19	593954000000	maria.vega@mentoria.ec
0971293870	Daniela	Ríos	1983-12-06	593955000000	daniela.rios@mentoria.ec
0905162713	Jorge	Salas	1965-02-05	593956000000	jorge.salas@mentoria.ec
0961115542	Carlos	Méndez	1972-09-05	593988000000	carlos.mendez@mentoria.ec
0987064734	Ana	Garci­a	2007-04-13	593941241182	ana.garci­a@staffevento.com
0961031911	Jorge	Rami­rez	2002-06-10	593901128059	jorge.rami­rez@staffevento.com
0920831834	Ana	Cruz	2006-08-27	593960883561	ana.cruz@staffevento.com
0965821624	Carlos	Marti­nez	2003-10-31	593941395376	carlos.marti­nez@staffevento.com
0968605307	Daniela	Garci­a	2005-05-20	593934624751	daniela.garci­a@staffevento.com
0961751437	Paula	Morales	2006-03-21	593981219136	paula.morales@staffevento.com
0929138457	Jorge	Garci­a	2003-12-03	593980957015	jorge.garci­a@staffevento.com
0976911109	Jorge	Gonzalez	2002-12-22	593910310518	jorge.gonzalez@staffevento.com
0933907700	Juan	Mendoza	2004-02-15	593900978820	juan.mendoza@staffevento.com
0925814815	Daniela	Torres	2007-04-13	593936541458	daniela.torres@staffevento.com
0974099735	Ana	Mendoza	2007-05-09	593910433218	ana.mendoza@staffevento.com
0964546220	Daniela	Castro	2004-02-02	593980957015	daniela.castro@staffevento.com
0998068575	Juan	Rodri­guez	1999-11-30	593948932528	juan.rodri­guez@staffevento.com
0926045235	Juan	Rami­rez	2005-07-15	593996965328	juan.rami­rez@staffevento.com
0904925262	Fernando	Castro	2003-10-26	593973763116	fernando.castro@staffevento.com
0941616571	Pedro	Torres	2007-06-07	593923226025	pedro.torres@staffevento.com
0937236382	Sofi­a	Cruz	2000-03-04	593919399091	sofi­a.cruz@staffevento.com
0961510776	Fernando	Mendoza	2005-09-10	593969985435	fernando.mendoza@staffevento.com
0961841030	Diego	Rodri­guez	2006-09-10	593984251354	diego.rodri­guez@staffevento.com
0929675596	Andres	Torres	2006-08-27	593943039117	andres.torres@staffevento.com
0995202443	Diego	Sanchez	2000-07-31	593951333872	diego.sanchez@staffevento.com
0972547262	Fernando	Gonzalez	2000-07-27	593956670106	fernando.gonzalez@staffevento.com
0919265634	Paula	Cruz	2000-10-23	593956670106	paula.cruz@staffevento.com
0933015640	Andres	Castro	2004-08-16	593941241182	andres.castro@staffevento.com
0933834645	Gabriela	Marti­nez	2005-04-06	593996965328	gabriela.marti­nez@staffevento.com
0914806172	Sofi­a	Morales	2000-06-01	593977360260	sofi­a.morales@staffevento.com
0986491861	Andres	Ortega	2000-07-26	593962473178	andres.ortega@staffevento.com
0910868808	Carlos	Lopez	2005-02-01	593923226025	carlos.lopez@staffevento.com
0918347625	Carlos	Mendoza	2001-05-04	593960883561	carlos.mendoza@staffevento.com
0934582187	Fernando	Garci­a	2000-06-04	593923226025	fernando.garci­a@staffevento.com
0985289940	Sofi­a	Suarez	2004-10-21	593901128059	sofi­a.suarez@staffevento.com
0959200802	Ricardo	Ortega	2003-06-14	593983503056	ricardo.ortega@staffevento.com
0974027745	Isabela	Paz	2005-10-02	593927849808	isabela.paz@staffevento.com
0997163727	Diego	Navarro	2007-07-16	593959407816	diego.navarro@staffevento.com
0949859035	Elena	Rami­rez	1999-11-10	593948932528	elena.rami­rez@staffevento.com
0941343503	Juan	Marti­nez	2000-05-28	593977360260	juan.marti­nez@staffevento.com
0962911690	Paula	Gonzalez	2006-06-09	593927849808	paula.gonzalez@staffevento.com
0905862333	Sofi­a	Torres	2001-08-13	593907991183	sofi­a.torres@staffevento.com
0992758001	Paula	Sanchez	2006-08-24	593934624751	paula.sanchez@staffevento.com
0956516167	Valentina	Rojas	2006-05-01	593918227824	valentina.rojas@staffevento.com
0967554036	Luci­a	Rami­rez	2000-05-15	593959407816	luci­a.rami­rez@staffevento.com
0953900793	Santiago	Cruz	2004-07-06	593933754330	santiago.cruz@staffevento.com
0906637391	Nicole	Garci­a	2005-11-04	593982620450	nicole.garcia@staffevento.com
0970971644	Diego	Marti­nez	1999-12-01	593916697848	diego.marti­nez@staffevento.com
0928270383	Gabriela	Sanchez	2004-04-24	593941241182	gabriela.sanchez@staffevento.com
0988520813	Santiago	Herrera	1999-01-16	593980957015	santiago.herrera@staffevento.com
0938048771	Camila	Sanchez	2005-05-20	593971012269	camila.sanchez@staffevento.com
0981528996	Camila	Castro	2000-10-12	593963421607	camila.castro@staffevento.com
0962363112	Mari­a	Lopez	2005-06-28	593972423884	mari­a.lopez@staffevento.com
0924511695	Diego	Lopez	2005-01-13	593992832764	diego.lopez@staffevento.com
0922291378	Pedro	Sanchez	2007-01-01	593919600133	pedro.sanchez@staffevento.com
0966113208	Camila	Perez	2002-08-15	593989083863	camila.perez@staffevento.com
0907252912	Juan	Rojas	2005-07-03	593916697848	juan.rojas@staffevento.com
0995077841	Paula	Garci­a	1999-01-05	593962473178	paula.garci­a@staffevento.com
0961350110	Camila	Navarro	2000-10-12	593934624751	camila.navarro@staffevento.com
0923055040	Mari­a	Perez	2007-04-08	593968501429	mari­a.perez@staffevento.com
0981118772	Jorge	Rojas	2003-05-27	593953315869	jorge.rojas@staffevento.com
0973151017	Paula	Navarro	2002-12-09	593923511615	paula.navarro@staffevento.com
0920154638	Pedro	Rodri­guez	2005-01-28	593951333872	pedro.rodri­guez@staffevento.com
0981702251	Mari­a	Vargas	2000-10-29	593934738299	mari­a.vargas@staffevento.com
0999010684	Gabriela	Suarez	2002-11-19	593998169340	gabriela.suarez@staffevento.com
0906507969	Ricardo	Marti­nez	2005-12-25	593907991183	ricardo.marti­nez@staffevento.com
0901399208	Javier	Medina	2007-12-21	593981219136	javier.medina@staffevento.com
0924826466	Luci­a	Herrera	2007-10-26	593972423884	luci­a.herrera@staffevento.com
0992472653	Juan	Morales	2001-11-19	593974016400	juan.morales@staffevento.com
0991461218	Ricardo	Vargas	2006-11-22	593944935348	ricardo.vargas@staffevento.com
0911085588	Diego	Rami­rez	2002-10-20	593950983930	diego.rami­rez@staffevento.com
0979228516	Elena	Rojas	2004-12-05	593910801326	elena.rojas@staffevento.com
0939560029	Fernando	Ortega	2003-02-13	593910310518	fernando.ortega@staffevento.com
0996583234	Javier	Herrera	2005-12-01	593916697848	javier.herrera@staffevento.com
0962987660	Valentina	Marti­nez	2007-12-12	593992832764	valentina.marti­nez@staffevento.com
0910765189	Sofi­a	Rojas	2003-10-27	593984251354	sofi­a.rojas@staffevento.com
0986271689	Daniela	Suarez	2004-03-09	593944935348	daniela.suarez@staffevento.com
0943996641	Elena	Lopez	2004-08-05	593910433218	elena.lopez@staffevento.com
0963349910	Lucas	Mendoza	2003-02-25	593960883561	lucas.mendoza@staffevento.com
0929668357	Daniela	Sanchez	2006-06-28	593982620450	daniela.sanchez@staffevento.com
0978266061	Jorge	Suarez	2002-10-15	593940196556	jorge.suarez@staffevento.com
0958338123	Gabriel	Suarez	2002-08-04	593953315869	gabriel.suarez@staffevento.com
0919433528	Diego	Gonzalez	2001-02-28	593998169340	diego.gonzalez@staffevento.com
0980301007	Fernando	Cruz	1999-02-08	593918495931	fernando.cruz@staffevento.com
0902821311	Benjami­n	Salinas	2002-09-08	593953315869	benjamin.salinas@staffevento.com
0942571242	Paula	Rodri­guez	2002-12-20	593973763116	paula.rodri­guez@staffevento.com
0961222577	Luis	Morales	2004-09-18	593971012269	luis.morales@staffevento.com
0912550576	Valentina	Rodri­guez	1999-02-27	593941395376	valentina.rodri­guez@staffevento.com
0903630740	Luci­a	Lopez	2004-05-02	593963421607	luci­a.lopez@staffevento.com
0972237149	Daniela	Gonzalez	2001-07-24	593944935348	daniela.gonzalez@staffevento.com
0982264518	Camila	Garci­a	1999-08-22	593964746872	camila.garci­a@staffevento.com
0975090127	Camila	Rami­rez	1999-11-12	593951333872	camila.rami­rez@staffevento.com
0929824354	Sofi­a	Paredes	2006-08-01	593979402654	sofia.paredes@staffevento.com
0930096037	Pedro	Rojas	2003-05-27	593900978820	pedro.rojas@staffevento.com
0933815067	Luci­a	Garci­a	2003-03-12	593916697848	luci­a.garci­a@staffevento.com
0960211460	Diego	Torres	2006-10-22	593959514846	diego.torres@staffevento.com
0914692527	Jorge	Castro	2002-05-07	593968501429	jorge.castro@staffevento.com
0965780537	Paula	Vargas	2004-08-24	593903413164	paula.vargas@staffevento.com
0967721666	Sofi­a	Herrera	2004-01-03	593951333872	sofi­a.herrera@staffevento.com
0988081023	Daniela	Morales	2000-05-23	593975255341	daniela.morales@staffevento.com
0928833030	Bruno	Beni­tez	2006-08-29	593963421607	bruno.benitez@staffevento.com
0931076825	Camila	Romero	2000-08-08	593951333872	camila.romero@staffevento.com
0915757727	Ricardo	Cruz	1999-05-06	593927849808	ricardo.cruz@staffevento.com
0930468521	Camila	Marti­nez	2002-03-12	593964746872	camila.marti­nez@staffevento.com
0927465183	Andrea	Villaci­s	2003-12-09	593900978820	andrea.villacis@staffevento.com
0941688864	Elena	Morales	1999-01-05	593969985435	elena.morales@staffevento.com
0959869868	Elena	Cruz	2001-01-29	593943039117	elena.cruz@staffevento.com
0967863188	Andres	Perez	2007-04-05	593982620450	andres.perez@staffevento.com
0955083781	Bruno	Torres	2005-06-10	593960883561	bruno.torres@staffevento.com
0978490552	Camila	Herrera	2005-02-09	593956670106	camila.herrera@staffevento.com
0997606170	Fernando	Rojas	2005-08-01	593934624751	fernando.rojas@staffevento.com
0966055642	Gabriela	Perez	2007-08-10	593933754330	gabriela.perez@staffevento.com
0950750241	Emilio	Paz	2001-01-23	593952427868	emilio.paz@staffevento.com
0986577283	Nicole	Rami­rez	2000-12-01	593960883561	nicole.ramirez@staffevento.com
0900515346	Mari­a	Rami­rez	1999-09-07	593977360260	mari­a.rami­rez@staffevento.com
0932786703	Sofi­a	Beni­tez	2004-04-19	593973763116	sofia.benitez@staffevento.com
0959914337	Andres	Rami­rez	2000-01-30	593936541458	andres.rami­rez@staffevento.com
0901693050	Sebastian	Paz	2002-02-20	593959514846	sebastian.paz@staffevento.com
0953954576	Paula	Rami­rez	2006-07-03	593900978820	paula.rami­rez@staffevento.com
0910384242	Fernando	Suarez	2005-04-19	593956670106	fernando.suarez@staffevento.com
0996404405	Monica	Medina	2002-10-11	593960883561	monica.medina@staffevento.com
0947606686	Gabriela	Rojas	2002-09-21	593983503056	gabriela.rojas@staffevento.com
0958272596	Santiago	Castillo	2003-04-06	593901128059	santiago.castillo@staffevento.com
0957832268	Fernando	Marti­nez	2002-06-12	593940196556	fernando.marti­nez@staffevento.com
0977168038	Jorge	Vargas	1999-08-15	593962473178	jorge.vargas@staffevento.com
0989972631	Luis	Rami­rez	2002-06-08	593956670106	luis.rami­rez@staffevento.com
0923078171	Pedro	Marti­nez	2004-04-27	593901845146	pedro.marti­nez@staffevento.com
0915364298	Paula	Rojas	1999-12-08	593982620450	paula.rojas@staffevento.com
0965183899	Camila	Mendoza	2004-10-16	593916697848	camila.mendoza@staffevento.com
0971999707	Andres	Navarro	2003-04-18	593936541458	andres.navarro@staffevento.com
0901440051	Andres	Morales	2002-06-03	593907991183	andres.morales@staffevento.com
0986275095	Luci­a	Torres	2004-06-16	593927048281	luci­a.torres@staffevento.com
0920311442	Andres	Vargas	2003-12-05	593953315869	andres.vargas@staffevento.com
0948996298	Sebastian	Castillo	2007-06-07	593953315869	sebastian.castillo@staffevento.com
0941801478	Sebastian	Medina	1999-12-01	593964746872	sebastian.medina@staffevento.com
0926853440	Camila	Gonzalez	2006-04-05	593910801326	camila.gonzalez@staffevento.com
0990814668	Jorge	Mendoza	1999-10-09	593907991183	jorge.mendoza@staffevento.com
0931050468	Diego	Vargas	2006-11-04	593916697848	diego.vargas@staffevento.com
0999623931	Jorge	Marti­nez	2007-06-28	593927048281	jorge.marti­nez@staffevento.com
0929870973	Veronica	Rami­rez	2007-08-07	593956670106	veronica.ramirez@staffevento.com
0959533477	Thiago	Navarro	2000-08-19	593923511615	thiago.navarro@staffevento.com
0917942095	Carlos	Ortega	2006-08-26	593974016400	carlos.ortega@staffevento.com
0952770697	Gabriela	Lopez	1999-01-11	593948932528	gabriela.lopez@staffevento.com
0903587513	Carolina	Romero	2001-04-21	593916697848	carolina.romero@staffevento.com
0969037005	Paula	Mendoza	2004-11-21	593927048281	paula.mendoza@staffevento.com
\.


--
-- TOC entry 5254 (class 0 OID 123137)
-- Dependencies: 229
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff (id_staff, cargo, activo, cedula) FROM stdin;
1	Coordinador	t	0987064734
2	Audiovisual	f	0961031911
3	Logí­stica	t	0920831834
4	Audiovisual	t	0965821624
5	Apoyo general	t	0968605307
6	Audiovisual	t	0961751437
7	Audiovisual	f	0929138457
8	Audiovisual	t	0976911109
9	Logí­stica	t	0933907700
10	Logí­stica	t	0925814815
11	Logí­stica	t	0974099735
12	Apoyo general	t	0964546220
13	Relaciones públicas	t	0998068575
14	Logí­stica	t	0926045235
15	Audiovisual	f	0904925262
16	Relaciones públicas	t	0941616571
17	Relaciones públicas	t	0937236382
18	Registro	t	0961510776
19	Audiovisual	t	0961841030
20	Logí­stica	t	0929675596
21	Relaciones públicas	t	0995202443
22	Registro	t	0972547262
23	Registro	t	0919265634
24	Audiovisual	t	0933015640
25	Logí­stica	t	0933834645
26	Apoyo general	t	0914806172
27	Moderador	f	0986491861
28	Relaciones públicas	t	0910868808
29	Registro	f	0918347625
30	Relaciones públicas	f	0934582187
31	Logí­stica	t	0985289940
32	Audiovisual	t	0959200802
33	Apoyo general	t	0974027745
34	Logí­stica	t	0997163727
35	Logí­stica	t	0949859035
36	Relaciones públicas	t	0941343503
37	Audiovisual	t	0962911690
38	Apoyo general	t	0905862333
39	Relaciones públicas	f	0992758001
40	Apoyo general	t	0956516167
41	Logí­stica	t	0967554036
42	Audiovisual	f	0953900793
43	Audiovisual	t	0906637391
44	Apoyo general	t	0970971644
45	Apoyo general	t	0928270383
46	Moderador	t	0988520813
47	Logí­stica	t	0938048771
48	Moderador	t	0981528996
49	Logí­stica	t	0962363112
50	Coordinador	t	0924511695
51	Apoyo general	t	0922291378
52	Registro	t	0966113208
53	Apoyo general	t	0907252912
54	Logí­stica	t	0995077841
55	Moderador	t	0961350110
56	Moderador	t	0923055040
57	Registro	t	0981118772
58	Audiovisual	t	0973151017
59	Apoyo general	t	0920154638
60	Logí­stica	f	0981702251
61	Apoyo general	t	0999010684
62	Audiovisual	f	0906507969
63	Moderador	t	0901399208
64	Apoyo general	f	0924826466
65	Relaciones públicas	f	0992472653
66	Registro	t	0991461218
67	Registro	f	0911085588
68	Registro	t	0979228516
69	Apoyo general	f	0939560029
70	Apoyo general	t	0996583234
71	Audiovisual	t	0962987660
72	Apoyo general	t	0910765189
73	Logí­stica	f	0986271689
74	Audiovisual	f	0943996641
75	Audiovisual	t	0963349910
76	Relaciones públicas	t	0929668357
77	Moderador	t	0978266061
78	Registro	t	0958338123
79	Relaciones públicas	t	0919433528
80	Relaciones públicas	f	0980301007
81	Logí­stica	f	0902821311
82	Registro	t	0942571242
83	Audiovisual	t	0961222577
84	Registro	f	0912550576
85	Registro	t	0903630740
86	Audiovisual	t	0972237149
87	Audiovisual	t	0982264518
88	Registro	t	0975090127
89	Logí­stica	t	0929824354
90	Registro	t	0930096037
91	Relaciones públicas	t	0933815067
92	Coordinador	t	0960211460
93	Relaciones públicas	f	0914692527
94	Logí­stica	t	0965780537
95	Registro	t	0967721666
96	Registro	t	0988081023
97	Logí­stica	t	0928833030
98	Logí­stica	t	0931076825
99	Relaciones públicas	t	0915757727
100	Relaciones públicas	t	0930468521
101	Relaciones públicas	t	0927465183
102	Registro	t	0941688864
103	Audiovisual	t	0959869868
104	Apoyo general	t	0967863188
105	Registro	t	0955083781
106	Apoyo general	t	0978490552
107	Relaciones públicas	t	0997606170
108	Relaciones públicas	t	0966055642
109	Registro	t	0950750241
110	Audiovisual	t	0986577283
111	Moderador	t	0900515346
112	Audiovisual	t	0932786703
113	Audiovisual	t	0959914337
114	Audiovisual	t	0901693050
115	Logí­stica	f	0953954576
116	Apoyo general	t	0910384242
117	Moderador	t	0996404405
118	Registro	t	0947606686
119	Moderador	f	0958272596
120	Relaciones públicas	t	0957832268
121	Registro	t	0977168038
122	Moderador	t	0989972631
123	Moderador	t	0923078171
124	Moderador	f	0915364298
125	Apoyo general	t	0965183899
126	Logí­stica	t	0971999707
127	Apoyo general	t	0901440051
128	Moderador	f	0986275095
129	Relaciones públicas	t	0920311442
130	Audiovisual	t	0948996298
131	Relaciones públicas	t	0941801478
132	Moderador	f	0926853440
133	Registro	t	0990814668
134	Moderador	t	0931050468
135	Moderador	f	0999623931
136	Registro	f	0929870973
137	Logí­stica	t	0959533477
138	Audiovisual	t	0917942095
139	Apoyo general	t	0952770697
140	Audiovisual	t	0903587513
141	Apoyo general	t	0969037005
\.


--
-- TOC entry 5260 (class 0 OID 123209)
-- Dependencies: 235
-- Data for Name: staff_evento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff_evento (id_evento, id_staff, horas_asignadas, tarea) FROM stdin;
1	1	3	Supervisar el desarrollo integral del evento y garantizar el cumplimiento del cronograma.
1	2	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
1	3	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
1	4	1	Supervisar presentaciones digitales, videos y transmision del evento.
1	5	1	Asistir en actividades operativas segun requerimientos del evento.
1	6	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
1	7	2	Operar y configurar equipos de sonido, iluminacion y proyeccion.
1	8	2	Supervisar presentaciones digitales, videos y transmision del evento.
1	9	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
1	10	2	Supervisar proveedores, transporte y abastecimiento de recursos.
1	11	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
1	12	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
1	13	1	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
1	14	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
1	15	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
1	16	1	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
1	17	1	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
1	18	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
1	19	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
1	20	1	Supervisar proveedores, transporte y abastecimiento de recursos.
1	21	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
1	22	1	Entregar credenciales, listas de control y materiales informativos.
1	23	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
1	24	1	Supervisar presentaciones digitales, videos y transmision del evento.
1	25	1	Gestionar el montaje, distribucion y control del mobiliario y materiales.
1	26	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
1	27	2	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
1	28	2	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
1	29	2	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
1	30	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
1	31	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
1	32	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
1	33	1	Asistir en actividades operativas segun requerimientos del evento.
1	34	1	Supervisar proveedores, transporte y abastecimiento de recursos.
1	35	1	Gestionar el montaje, distribucion y control del mobiliario y materiales.
1	36	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
1	37	2	Operar y configurar equipos de sonido, iluminacion y proyeccion.
1	38	2	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
1	39	2	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
1	40	2	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
1	41	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
1	42	1	Supervisar presentaciones digitales, videos y transmision del evento.
1	43	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
1	44	1	Asistir en actividades operativas segun requerimientos del evento.
1	45	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
1	46	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
1	47	1	Supervisar proveedores, transporte y abastecimiento de recursos.
1	48	2	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
1	49	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
2	50	4	Asignar funciones al personal y resolver imprevistos en tiempo real.
2	51	2	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
2	52	2	Entregar credenciales, listas de control y materiales informativos.
2	53	1	Asistir en actividades operativas segun requerimientos del evento.
2	54	1	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
2	55	1	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
2	56	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
2	57	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
2	58	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
2	59	3	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
2	60	1	Supervisar proveedores, transporte y abastecimiento de recursos.
2	61	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
2	62	1	Supervisar presentaciones digitales, videos y transmision del evento.
2	63	1	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
2	64	1	Asistir en actividades operativas segun requerimientos del evento.
2	65	3	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
2	66	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
2	67	2	Entregar credenciales, listas de control y materiales informativos.
2	68	1	Digitalizar datos, controlar aforo y generar reportes de asistencia.
2	69	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
2	70	2	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
2	71	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
2	72	3	Asistir en actividades operativas segun requerimientos del evento.
2	73	3	Gestionar el montaje, distribucion y control del mobiliario y materiales.
2	74	2	Operar y configurar equipos de sonido, iluminacion y proyeccion.
2	75	2	Supervisar presentaciones digitales, videos y transmision del evento.
2	76	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
2	77	2	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
2	78	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
2	79	2	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
2	80	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
2	81	3	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
2	82	3	Entregar credenciales, listas de control y materiales informativos.
2	83	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
2	84	1	Digitalizar datos, controlar aforo y generar reportes de asistencia.
2	85	3	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
2	86	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
2	87	3	Supervisar presentaciones digitales, videos y transmision del evento.
2	88	1	Entregar credenciales, listas de control y materiales informativos.
2	89	2	Supervisar proveedores, transporte y abastecimiento de recursos.
2	90	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
2	91	1	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
3	92	5	Coordinar la comunicacion con organizadores, expositores y proveedores.
3	93	4	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
3	94	1	Gestionar el montaje, distribucion y control del mobiliario y materiales.
3	95	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
3	96	3	Entregar credenciales, listas de control y materiales informativos.
3	97	4	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
3	98	4	Supervisar proveedores, transporte y abastecimiento de recursos.
3	99	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
3	100	3	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
3	101	3	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
3	102	4	Digitalizar datos, controlar aforo y generar reportes de asistencia.
3	103	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
3	104	3	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
3	105	3	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
3	106	3	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
3	107	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
3	108	1	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
3	109	1	Entregar credenciales, listas de control y materiales informativos.
3	110	2	Operar y configurar equipos de sonido, iluminacion y proyeccion.
3	111	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
3	112	4	Supervisar presentaciones digitales, videos y transmision del evento.
3	113	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
3	114	4	Operar y configurar equipos de sonido, iluminacion y proyeccion.
3	115	4	Gestionar el montaje, distribucion y control del mobiliario y materiales.
3	116	3	Asistir en actividades operativas segun requerimientos del evento.
3	117	4	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
3	118	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
3	119	2	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
3	120	3	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
3	121	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
3	122	2	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
3	123	4	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
3	124	1	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
3	125	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
3	126	3	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
3	127	2	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
3	128	4	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
3	129	4	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
3	130	1	Supervisar presentaciones digitales, videos y transmision del evento.
3	131	1	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
3	132	2	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
3	133	2	Entregar credenciales, listas de control y materiales informativos.
3	134	3	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
3	135	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
3	136	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
3	137	2	Supervisar proveedores, transporte y abastecimiento de recursos.
3	138	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
3	139	2	Asistir en actividades operativas segun requerimientos del evento.
3	140	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
3	141	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
4	1	4	Supervisar el desarrollo integral del evento y garantizar el cumplimiento del cronograma.
4	26	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
4	4	1	Supervisar presentaciones digitales, videos y transmision del evento.
4	91	1	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
4	52	2	Entregar credenciales, listas de control y materiales informativos.
4	66	1	Digitalizar datos, controlar aforo y generar reportes de asistencia.
4	12	1	Asistir en actividades operativas segun requerimientos del evento.
4	53	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
4	2	1	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
4	51	2	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
4	118	2	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
4	106	4	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
4	100	3	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
4	128	4	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
4	102	4	Entregar credenciales, listas de control y materiales informativos.
4	3	1	Asistir en actividades operativas segun requerimientos del evento.
4	122	2	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
4	93	4	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
4	14	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
4	13	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
4	24	1	Supervisar presentaciones digitales, videos y transmision del evento.
4	5	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
4	103	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
4	72	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
4	40	2	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
4	90	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
4	86	1	Supervisar presentaciones digitales, videos y transmision del evento.
4	107	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
4	17	1	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
4	73	3	Supervisar proveedores, transporte y abastecimiento de recursos.
4	6	1	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
4	7	4	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
4	8	4	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
4	64	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
4	65	3	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
4	48	2	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
4	23	2	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
4	9	2	Asistir en actividades operativas segun requerimientos del evento.
4	21	2	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
4	32	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
4	121	1	Entregar credenciales, listas de control y materiales informativos.
4	10	2	Operar y configurar equipos de sonido, iluminacion y proyeccion.
4	11	1	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
4	61	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
4	39	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
4	94	1	Gestionar el montaje, distribucion y control del mobiliario y materiales.
4	15	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
4	16	1	Supervisar presentaciones digitales, videos y transmision del evento.
4	18	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
4	19	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
4	20	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
4	22	2	Entregar credenciales, listas de control y materiales informativos.
4	25	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
4	28	2	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
5	50	3	Asignar funciones al personal y resolver imprevistos en tiempo real.
5	84	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
5	47	1	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
5	62	1	Supervisar presentaciones digitales, videos y transmision del evento.
5	94	1	Supervisar proveedores, transporte y abastecimiento de recursos.
5	13	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
5	2	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
5	30	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
5	132	2	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
5	124	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
5	135	1	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
5	113	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
5	3	2	Supervisar presentaciones digitales, videos y transmision del evento.
5	86	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
5	4	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
5	49	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
5	66	1	Entregar credenciales, listas de control y materiales informativos.
5	134	3	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
5	5	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
5	80	2	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
5	6	1	Digitalizar datos, controlar aforo y generar reportes de asistencia.
5	7	1	Supervisar presentaciones digitales, videos y transmision del evento.
5	60	1	Supervisar proveedores, transporte y abastecimiento de recursos.
5	127	2	Asistir en actividades operativas segun requerimientos del evento.
5	68	1	Digitalizar datos, controlar aforo y generar reportes de asistencia.
5	46	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
5	58	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
5	99	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
5	59	3	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
5	45	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
5	12	1	Asistir en actividades operativas segun requerimientos del evento.
5	37	2	Operar y configurar equipos de sonido, iluminacion y proyeccion.
5	15	2	Supervisar presentaciones digitales, videos y transmision del evento.
5	8	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
5	61	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
5	17	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
5	77	2	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
5	39	2	Asistir en actividades operativas segun requerimientos del evento.
5	67	2	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
5	82	3	Entregar credenciales, listas de control y materiales informativos.
5	11	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
5	27	2	Presentar a ponentes, manejar tiempos y guiar el desarrollo del programa.
5	22	1	Digitalizar datos, controlar aforo y generar reportes de asistencia.
5	104	3	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
5	138	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
5	65	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
5	64	1	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
5	88	1	Entregar credenciales, listas de control y materiales informativos.
5	9	1	Asistir en actividades operativas segun requerimientos del evento.
5	53	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
5	51	2	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
6	92	4	Coordinar la comunicacion con organizadores, expositores y proveedores.
6	135	1	Mantener la dinamica del evento evitando retrasos y gestionando la participacion.
6	113	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
6	3	2	Supervisar presentaciones digitales, videos y transmision del evento.
6	86	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
6	36	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
6	2	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
6	4	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
6	127	2	Asistir en actividades operativas segun requerimientos del evento.
6	124	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
6	46	1	Facilitar espacios de preguntas, interaccion con el publico y cierre de intervenciones.
6	58	1	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
6	99	2	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
6	30	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
6	49	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
6	9	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
6	10	2	Supervisar proveedores, transporte y abastecimiento de recursos.
6	11	2	Gestionar el montaje, distribucion y control del mobiliario y materiales.
6	12	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
6	13	1	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
6	118	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
6	5	1	Supervisar presentaciones digitales, videos y transmision del evento.
6	66	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
6	14	2	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
6	15	2	Realizar pruebas tecnicas previas y asistencia durante ponencias y actividades.
6	16	1	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
6	139	2	Asistir en actividades operativas segun requerimientos del evento.
6	93	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
6	74	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
6	17	1	Supervisar difusion, mensajes oficiales y acompañamiento de figuras clave.
6	18	1	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
6	19	1	Operar y configurar equipos de sonido, iluminacion y proyeccion.
6	125	1	Proveer soporte a los demas equipos para agilizar tareas cri­ticas.
6	126	3	Coordinar ingreso, desplazamiento y ubicacion de asistentes y participantes.
6	6	2	Ayudar en control de acceso, entrega de materiales y gui­a a los asistentes.
6	20	1	Supervisar proveedores, transporte y abastecimiento de recursos.
6	21	2	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
6	22	1	Entregar credenciales, listas de control y materiales informativos.
6	23	2	Digitalizar datos, controlar aforo y generar reportes de asistencia.
6	100	3	Gestionar comunicacion institucional con invitados, patrocinadores y medios.
6	50	3	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
6	102	4	Digitalizar datos, controlar aforo y generar reportes de asistencia.
6	7	2	Verificar y organizar la inscripcion de asistentes antes y durante el evento.
6	40	2	Asistir en actividades operativas segun requerimientos del evento.
6	8	2	Representar a la organizacion manteniendo buena imagen y atencion protocolar.
\.


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 220
-- Name: bitacora_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bitacora_id_seq', 3595, true);


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 233
-- Name: evento_id_evento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.evento_id_evento_seq', 1, true);


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 219
-- Name: evento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.evento_id_seq', 5, true);


--
-- TOC entry 5024 (class 2606 OID 123185)
-- Name: actividad actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividad
    ADD CONSTRAINT actividad_pkey PRIMARY KEY (id_actividad);


--
-- TOC entry 5041 (class 2606 OID 123303)
-- Name: bitacora bitacora_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bitacora
    ADD CONSTRAINT bitacora_pkey PRIMARY KEY (id_bitacora);


--
-- TOC entry 5012 (class 2606 OID 123109)
-- Name: carrera carrera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carrera
    ADD CONSTRAINT carrera_pkey PRIMARY KEY (id_carrera);


--
-- TOC entry 5033 (class 2606 OID 123234)
-- Name: emprendimiento_actividad emprendimiento_actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento_actividad
    ADD CONSTRAINT emprendimiento_actividad_pkey PRIMARY KEY (id_emprendimiento, id_actividad);


--
-- TOC entry 5035 (class 2606 OID 123253)
-- Name: emprendimiento_evento emprendimiento_evento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento_evento
    ADD CONSTRAINT emprendimiento_evento_pkey PRIMARY KEY (id_emprendimiento, id_evento);


--
-- TOC entry 5010 (class 2606 OID 123098)
-- Name: emprendimiento emprendimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento
    ADD CONSTRAINT emprendimiento_pkey PRIMARY KEY (id_emprendimiento);


--
-- TOC entry 5004 (class 2606 OID 123078)
-- Name: estudio_mercado estudio_mercado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudio_mercado
    ADD CONSTRAINT estudio_mercado_pkey PRIMARY KEY (id_estudio);


--
-- TOC entry 5026 (class 2606 OID 123203)
-- Name: evento evento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento
    ADD CONSTRAINT evento_pkey PRIMARY KEY (id_evento);


--
-- TOC entry 5016 (class 2606 OID 123131)
-- Name: expositor expositor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expositor
    ADD CONSTRAINT expositor_pkey PRIMARY KEY (id_expositor);


--
-- TOC entry 5002 (class 2606 OID 123070)
-- Name: facultad facultad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facultad
    ADD CONSTRAINT facultad_pkey PRIMARY KEY (id_facultad);


--
-- TOC entry 5008 (class 2606 OID 123090)
-- Name: lugar lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lugar
    ADD CONSTRAINT lugar_pkey PRIMARY KEY (id_lugar);


--
-- TOC entry 5014 (class 2606 OID 123120)
-- Name: mentor mentor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentor
    ADD CONSTRAINT mentor_pkey PRIMARY KEY (id_mentor);


--
-- TOC entry 5037 (class 2606 OID 123269)
-- Name: mentoria mentoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentoria
    ADD CONSTRAINT mentoria_pkey PRIMARY KEY (id_mentoria);


--
-- TOC entry 5020 (class 2606 OID 123153)
-- Name: miembro miembro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.miembro
    ADD CONSTRAINT miembro_pkey PRIMARY KEY (id_miembro);


--
-- TOC entry 5039 (class 2606 OID 123286)
-- Name: participacion_miembro participacion_miembro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_miembro
    ADD CONSTRAINT participacion_miembro_pkey PRIMARY KEY (id_miembro, id_mentoria);


--
-- TOC entry 5022 (class 2606 OID 123169)
-- Name: perfil_academico perfil_academico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil_academico
    ADD CONSTRAINT perfil_academico_pkey PRIMARY KEY (id_miembro);


--
-- TOC entry 5006 (class 2606 OID 123084)
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (cedula);


--
-- TOC entry 5031 (class 2606 OID 123215)
-- Name: staff_evento staff_evento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_evento
    ADD CONSTRAINT staff_evento_pkey PRIMARY KEY (id_evento, id_staff);


--
-- TOC entry 5018 (class 2606 OID 123142)
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id_staff);


--
-- TOC entry 5029 (class 2606 OID 123394)
-- Name: evento uq_nombre_evento_unico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento
    ADD CONSTRAINT uq_nombre_evento_unico UNIQUE (nombre);


--
-- TOC entry 5027 (class 1259 OID 123375)
-- Name: idx_bloqueo_lugar_dia; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_bloqueo_lugar_dia ON public.evento USING btree (id_lugar, fecha);


--
-- TOC entry 5042 (class 1259 OID 123458)
-- Name: ux_mv_reporte_estado_operativo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_mv_reporte_estado_operativo ON public.mv_reporte_estado_operativo USING btree (id_emprendimiento);


--
-- TOC entry 5078 (class 2620 OID 123373)
-- Name: evento tg_chequear_coordinador_evento; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE CONSTRAINT TRIGGER tg_chequear_coordinador_evento AFTER INSERT ON public.evento DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.fn_verificar_coordinador_evento_defer();


--
-- TOC entry 5077 (class 2620 OID 123316)
-- Name: actividad trg_actividad_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_actividad_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.actividad FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5070 (class 2620 OID 123310)
-- Name: carrera trg_carrera_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_carrera_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.carrera FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5082 (class 2620 OID 123319)
-- Name: emprendimiento_actividad trg_emprendimiento_actividad_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_emprendimiento_actividad_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.emprendimiento_actividad FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5069 (class 2620 OID 123309)
-- Name: emprendimiento trg_emprendimiento_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_emprendimiento_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.emprendimiento FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5083 (class 2620 OID 123320)
-- Name: emprendimiento_evento trg_emprendimiento_evento_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_emprendimiento_evento_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.emprendimiento_evento FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5066 (class 2620 OID 123306)
-- Name: estudio_mercado trg_estudio_mercado_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_estudio_mercado_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.estudio_mercado FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5079 (class 2620 OID 123317)
-- Name: evento trg_evento_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_evento_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.evento FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5072 (class 2620 OID 123312)
-- Name: expositor trg_expositor_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_expositor_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.expositor FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5065 (class 2620 OID 123305)
-- Name: facultad trg_facultad_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_facultad_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.facultad FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5068 (class 2620 OID 123308)
-- Name: lugar trg_lugar_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_lugar_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.lugar FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5071 (class 2620 OID 123311)
-- Name: mentor trg_mentor_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_mentor_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.mentor FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5084 (class 2620 OID 123321)
-- Name: mentoria trg_mentoria_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_mentoria_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.mentoria FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5074 (class 2620 OID 123314)
-- Name: miembro trg_miembro_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_miembro_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.miembro FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5086 (class 2620 OID 123322)
-- Name: participacion_miembro trg_participacion_miembro_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_participacion_miembro_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.participacion_miembro FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5076 (class 2620 OID 123315)
-- Name: perfil_academico trg_perfil_academico_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_perfil_academico_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.perfil_academico FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5067 (class 2620 OID 123307)
-- Name: persona trg_persona_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_persona_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.persona FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5073 (class 2620 OID 123313)
-- Name: staff trg_staff_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_staff_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.staff FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5081 (class 2620 OID 123318)
-- Name: staff_evento trg_staff_evento_bitacora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_staff_evento_bitacora AFTER INSERT OR DELETE OR UPDATE ON public.staff_evento FOR EACH ROW EXECUTE FUNCTION public.fn_bitacora_general();


--
-- TOC entry 5075 (class 2620 OID 123348)
-- Name: miembro trg_validar_edad_miembro; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_edad_miembro BEFORE INSERT ON public.miembro FOR EACH ROW EXECUTE FUNCTION public.fn_validar_edad_miembro();


--
-- TOC entry 5080 (class 2620 OID 123347)
-- Name: evento trg_validar_lugar_evento; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_lugar_evento BEFORE INSERT OR UPDATE ON public.evento FOR EACH ROW EXECUTE FUNCTION public.fn_validar_disponibilidad_lugar();


--
-- TOC entry 5085 (class 2620 OID 123381)
-- Name: mentoria trg_validar_mentoria; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_mentoria BEFORE INSERT OR UPDATE ON public.mentoria FOR EACH ROW EXECUTE FUNCTION public.fn_validar_mentoria();


--
-- TOC entry 5052 (class 2606 OID 123186)
-- Name: actividad fk_actividad_expositor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividad
    ADD CONSTRAINT fk_actividad_expositor FOREIGN KEY (id_expositor) REFERENCES public.expositor(id_expositor);


--
-- TOC entry 5053 (class 2606 OID 123191)
-- Name: actividad fk_actividad_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividad
    ADD CONSTRAINT fk_actividad_lugar FOREIGN KEY (id_lugar) REFERENCES public.lugar(id_lugar);


--
-- TOC entry 5044 (class 2606 OID 123110)
-- Name: carrera fk_carrera_facultad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carrera
    ADD CONSTRAINT fk_carrera_facultad FOREIGN KEY (id_facultad) REFERENCES public.facultad(id_facultad);


--
-- TOC entry 5057 (class 2606 OID 123240)
-- Name: emprendimiento_actividad fk_emp_act_actividad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento_actividad
    ADD CONSTRAINT fk_emp_act_actividad FOREIGN KEY (id_actividad) REFERENCES public.actividad(id_actividad);


--
-- TOC entry 5058 (class 2606 OID 123235)
-- Name: emprendimiento_actividad fk_emp_act_emprendimiento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento_actividad
    ADD CONSTRAINT fk_emp_act_emprendimiento FOREIGN KEY (id_emprendimiento) REFERENCES public.emprendimiento(id_emprendimiento);


--
-- TOC entry 5059 (class 2606 OID 123254)
-- Name: emprendimiento_evento fk_emp_ev_emprendimiento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento_evento
    ADD CONSTRAINT fk_emp_ev_emprendimiento FOREIGN KEY (id_emprendimiento) REFERENCES public.emprendimiento(id_emprendimiento);


--
-- TOC entry 5060 (class 2606 OID 123259)
-- Name: emprendimiento_evento fk_emp_ev_evento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento_evento
    ADD CONSTRAINT fk_emp_ev_evento FOREIGN KEY (id_evento) REFERENCES public.evento(id_evento);


--
-- TOC entry 5043 (class 2606 OID 123099)
-- Name: emprendimiento fk_emprendimiento_estudio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emprendimiento
    ADD CONSTRAINT fk_emprendimiento_estudio FOREIGN KEY (id_estudio) REFERENCES public.estudio_mercado(id_estudio);


--
-- TOC entry 5054 (class 2606 OID 123204)
-- Name: evento fk_evento_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento
    ADD CONSTRAINT fk_evento_lugar FOREIGN KEY (id_lugar) REFERENCES public.lugar(id_lugar);


--
-- TOC entry 5046 (class 2606 OID 123132)
-- Name: expositor fk_expositor_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expositor
    ADD CONSTRAINT fk_expositor_persona FOREIGN KEY (cedula) REFERENCES public.persona(cedula);


--
-- TOC entry 5045 (class 2606 OID 123121)
-- Name: mentor fk_mentor_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentor
    ADD CONSTRAINT fk_mentor_persona FOREIGN KEY (cedula) REFERENCES public.persona(cedula);


--
-- TOC entry 5061 (class 2606 OID 123275)
-- Name: mentoria fk_mentoria_emprendimiento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentoria
    ADD CONSTRAINT fk_mentoria_emprendimiento FOREIGN KEY (id_emprendimiento) REFERENCES public.emprendimiento(id_emprendimiento);


--
-- TOC entry 5062 (class 2606 OID 123270)
-- Name: mentoria fk_mentoria_mentor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentoria
    ADD CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor) REFERENCES public.mentor(id_mentor);


--
-- TOC entry 5048 (class 2606 OID 123154)
-- Name: miembro fk_miembro_emprendimiento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.miembro
    ADD CONSTRAINT fk_miembro_emprendimiento FOREIGN KEY (id_emprendimiento) REFERENCES public.emprendimiento(id_emprendimiento);


--
-- TOC entry 5049 (class 2606 OID 123159)
-- Name: miembro fk_miembro_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.miembro
    ADD CONSTRAINT fk_miembro_persona FOREIGN KEY (cedula) REFERENCES public.persona(cedula);


--
-- TOC entry 5063 (class 2606 OID 123292)
-- Name: participacion_miembro fk_part_miembro_mentoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_miembro
    ADD CONSTRAINT fk_part_miembro_mentoria FOREIGN KEY (id_mentoria) REFERENCES public.mentoria(id_mentoria);


--
-- TOC entry 5064 (class 2606 OID 123287)
-- Name: participacion_miembro fk_part_miembro_miembro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_miembro
    ADD CONSTRAINT fk_part_miembro_miembro FOREIGN KEY (id_miembro) REFERENCES public.miembro(id_miembro);


--
-- TOC entry 5050 (class 2606 OID 123175)
-- Name: perfil_academico fk_perfil_carrera; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil_academico
    ADD CONSTRAINT fk_perfil_carrera FOREIGN KEY (id_carrera) REFERENCES public.carrera(id_carrera);


--
-- TOC entry 5051 (class 2606 OID 123170)
-- Name: perfil_academico fk_perfil_miembro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil_academico
    ADD CONSTRAINT fk_perfil_miembro FOREIGN KEY (id_miembro) REFERENCES public.miembro(id_miembro);


--
-- TOC entry 5055 (class 2606 OID 123216)
-- Name: staff_evento fk_staff_evento_evento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_evento
    ADD CONSTRAINT fk_staff_evento_evento FOREIGN KEY (id_evento) REFERENCES public.evento(id_evento);


--
-- TOC entry 5056 (class 2606 OID 123221)
-- Name: staff_evento fk_staff_evento_staff; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_evento
    ADD CONSTRAINT fk_staff_evento_staff FOREIGN KEY (id_staff) REFERENCES public.staff(id_staff);


--
-- TOC entry 5047 (class 2606 OID 123143)
-- Name: staff fk_staff_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_persona FOREIGN KEY (cedula) REFERENCES public.persona(cedula);


--
-- TOC entry 5267 (class 0 OID 123450)
-- Dependencies: 250 5269
-- Name: mv_reporte_estado_operativo; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_reporte_estado_operativo;


--
-- TOC entry 5266 (class 0 OID 123437)
-- Dependencies: 249 5269
-- Name: mv_reporte_rendimiento_emprendimiento; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_reporte_rendimiento_emprendimiento;


-- Completed on 2025-12-16 23:46:45

--
-- PostgreSQL database dump complete
--

\unrestrict bX8RXdt9pcr1hPVHD0RHgqietTCAbhZ7GHMhsStq6TWDzjbVB0n9EWJ0IznS9YQ

