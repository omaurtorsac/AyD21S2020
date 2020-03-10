echo "testing text"

sqlldr userid= PROYECTO2DIC/201113759 control=media/archivoControl.ctl

sqlplus PROYECTO2DIC/201113759@localhost:1521/xe << EOF >> ./output.log

drop table DetalleFactura;
drop table producto;
drop table factura;
drop table sucursal;
drop table categoria;
drop table cliente;
drop table empleado;
drop table lugar;
drop table tipolugar;

drop sequence seccategoria;
drop sequence seclugar;
drop sequence secproducto;
drop sequence sectipolugar;

CREATE TABLE categoria (
    id_categoria      INTEGER NOT NULL,
    nombrecategoria   VARCHAR2(50)
);

ALTER TABLE categoria ADD CONSTRAINT categoria_pk PRIMARY KEY ( id_categoria );

CREATE TABLE cliente (
    dpi           VARCHAR2(20) NOT NULL,
    pnombre       VARCHAR2(20),
    snombre       VARCHAR2(20),
    papellido     VARCHAR2(20),
    sapellido     VARCHAR2(20),
    nit           VARCHAR2(15),
    genero        VARCHAR2(2),
    estadocivil   VARCHAR2(15),
    telefono      VARCHAR2(10)
);

ALTER TABLE cliente ADD CONSTRAINT empleadov1_pk PRIMARY KEY ( dpi );

CREATE TABLE detallefactura (
    cantidad        INTEGER NOT NULL,
    id_producto     INTEGER NOT NULL,
    numerofactura   INTEGER NOT NULL
);

ALTER TABLE detallefactura ADD CONSTRAINT detallefactura_pk PRIMARY KEY ( numerofactura,
id_producto );

CREATE TABLE empleado (
    dpi           VARCHAR2(20) NOT NULL,
    pnombre       VARCHAR2(20),
    snombre       VARCHAR2(20),
    papellido     VARCHAR2(20),
    sapellido     VARCHAR2(20),
    nit           VARCHAR2(15),
    genero        VARCHAR2(2),
    estadocivil   VARCHAR2(15),
    admin         VARCHAR2(1)
);

ALTER TABLE empleado ADD CONSTRAINT empleado_pk PRIMARY KEY ( dpi );

CREATE TABLE factura (
    numerofactura   INTEGER NOT NULL,
    serie           VARCHAR2(10),
    fecha           DATE,
    id_sucursal     INTEGER NOT NULL,
    empleado_dpi    VARCHAR2(20) NOT NULL,
    cliente_dpi     VARCHAR2(20) NOT NULL
);

ALTER TABLE factura ADD CONSTRAINT factura_pk PRIMARY KEY ( numerofactura );

CREATE TABLE lugar (
    id_lugar         INTEGER NOT NULL,
    nombrelugar      VARCHAR2(50),
    id_tipolugar     INTEGER NOT NULL,
    lugar_id_lugar   INTEGER
);

ALTER TABLE lugar ADD CONSTRAINT lugar_pk PRIMARY KEY ( id_lugar );

CREATE TABLE producto (
    id_producto    INTEGER NOT NULL,
    nombre         VARCHAR2(100),
    talla          VARCHAR2(5),
    color          VARCHAR2(20),
    precio         INTEGER,
    id_categoria   INTEGER NOT NULL
);

ALTER TABLE producto ADD CONSTRAINT producto_pk PRIMARY KEY ( id_producto );

CREATE TABLE sucursal (
    id_sucursal   INTEGER NOT NULL,
    direccion     VARCHAR2(50),
    telefeno      VARCHAR2(10),
    id_lugar      INTEGER NOT NULL
);

ALTER TABLE sucursal ADD CONSTRAINT sucursal_pk PRIMARY KEY ( id_sucursal );

CREATE TABLE tipolugar (
    id_tipolugar   INTEGER NOT NULL,
    nombretipo     VARCHAR2(15)
);

ALTER TABLE tipolugar ADD CONSTRAINT tipolugar_pk PRIMARY KEY ( id_tipolugar );

ALTER TABLE detallefactura
    ADD CONSTRAINT detallefactura_factura_fk FOREIGN KEY ( numerofactura )
        REFERENCES factura ( numerofactura )
            ON DELETE CASCADE;

ALTER TABLE detallefactura
    ADD CONSTRAINT detallefactura_producto_fk FOREIGN KEY ( id_producto )
        REFERENCES producto ( id_producto )
            ON DELETE CASCADE;

ALTER TABLE factura
    ADD CONSTRAINT factura_cliente_fk FOREIGN KEY ( cliente_dpi )
        REFERENCES cliente ( dpi )
            ON DELETE CASCADE;

ALTER TABLE factura
    ADD CONSTRAINT factura_empleado_fk FOREIGN KEY ( empleado_dpi )
        REFERENCES empleado ( dpi )
            ON DELETE CASCADE;

ALTER TABLE factura
    ADD CONSTRAINT factura_sucursal_fk FOREIGN KEY ( id_sucursal )
        REFERENCES sucursal ( id_sucursal )
            ON DELETE CASCADE;

ALTER TABLE lugar
    ADD CONSTRAINT lugar_lugar_fk FOREIGN KEY ( lugar_id_lugar )
        REFERENCES lugar ( id_lugar )
            ON DELETE CASCADE;

ALTER TABLE lugar
    ADD CONSTRAINT lugar_tipolugar_fk FOREIGN KEY ( id_tipolugar )
        REFERENCES tipolugar ( id_tipolugar )
            ON DELETE CASCADE;

ALTER TABLE producto
    ADD CONSTRAINT producto_categoria_fk FOREIGN KEY ( id_categoria )
        REFERENCES categoria ( id_categoria )
            ON DELETE CASCADE;

ALTER TABLE sucursal
    ADD CONSTRAINT sucursal_lugar_fk FOREIGN KEY ( id_lugar )
        REFERENCES lugar ( id_lugar );

CREATE SEQUENCE seccategoria START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER triggercategoria BEFORE
    INSERT ON categoria
    FOR EACH ROW
    WHEN ( new.id_categoria IS NULL )
BEGIN
    :new.id_categoria := seccategoria.nextval;
END;
/

CREATE SEQUENCE seclugar START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER triggerlugar BEFORE
    INSERT ON lugar
    FOR EACH ROW
    WHEN ( new.id_lugar IS NULL )
BEGIN
    :new.id_lugar := seclugar.nextval;
END;
/

CREATE SEQUENCE secproducto START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER triggerproducto BEFORE
    INSERT ON producto
    FOR EACH ROW
    WHEN ( new.id_producto IS NULL )
BEGIN
    :new.id_producto := secproducto.nextval;
END;
/

CREATE SEQUENCE sectipolugar START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER triggertipolugar BEFORE
    INSERT ON tipolugar
    FOR EACH ROW
    WHEN ( new.id_tipolugar IS NULL )
BEGIN
    :new.id_tipolugar := sectipolugar.nextval;
END;
/

INSERT INTO CATEGORIA(NombreCategoria)
    select distinct CATEGORIA from DATOSTODOS
    where CATEGORIA not like '%Jerseis y Chaquetas%';

INSERT INTO TipoLugar(nombretipo) values('DEPARTAMENTO');
INSERT INTO TipoLugar(nombretipo) values('MUNICIPIO');

INSERT INTO LUGAR(NombreLugar, id_TipoLugar)
    select distinct d.DEPARTAMENTO, tp.id_TipoLugar
    from DATOSTODOS d, TipoLugar tp
    where tp.nombretipo = 'DEPARTAMENTO';

INSERT INTO LUGAR(NombreLugar, id_TipoLugar, LUGAR_id_Lugar)
    select distinct d.MUNICIPIO, tp.id_TipoLugar, l.id_Lugar
    from DATOSTODOS d, TipoLugar tp, Lugar l
    where tp.nombretipo = 'MUNICIPIO' and
    d.DEPARTAMENTO = l.NombreLugar;

INSERT INTO SUCURSAL(id_Sucursal, Direccion, Telefeno, id_Lugar)
    select distinct d.SUCURSAL, d.DIR_SUCURSAL, d.TEL_SUCURSAL, l.id_Lugar
    from DATOSTODOS d, LUGAR l, LUGAR c
    where d.DEPARTAMENTO = c.NombreLugar
    and c.id_Lugar = l.LUGAR_id_Lugar and
    d.MUNICIPIO = l.NombreLugar;

INSERT INTO CLIENTE(DPI, PNombre, SNombre, PApellido, SApellido, NIT, EstadoCivil, Genero)
    select distinct d.DPI_C, d.POMBRE_C, d.SNOMBRE_C, d.PAPELLIDO_C, d.SAPELLIDO_C, d.NIT_C, d.ESTADO_CIVIL_C, d.GENERO_C
    from DATOSTODOS d;

INSERT INTO EMPLEADO(DPI, PNombre, SNombre, PApellido, SApellido, NIT, EstadoCivil, Genero, Admin)
    select distinct d.DPI_V, d.PNOMBRE_V, d.SNOMBRE_V, d.PAPELLIDO_V, d.SAPELLIDO_V, d.NIT_V, d.ESTADO_CIVIL_V, d.GENERO_V, 'N'
    from DATOSTODOS d;

INSERT INTO PRODUCTO(Nombre, Talla, Color, Precio, id_Categoria)
    SELECT distinct d.NOMBRE_PRODUCTO, d.TALLA, d.COLOR, d.PRECIO_PRODUCTO, c.ID_CATEGORIA from datostodos d, categoria c 
    where d.CATEGORIA = c.NOMBRECATEGORIA and d.CATEGORIA NOT LIKE '%Jerseis y%'
    union
    SELECT distinct d.NOMBRE_PRODUCTO, d.TALLA, d.COLOR, d.PRECIO_PRODUCTO, 8 from datostodos d, categoria c 
    where d.CATEGORIA LIKE '%Jerseis y%';

INSERT INTO FACTURA(NumeroFactura, Serie, Fecha, id_Sucursal, EMPLEADO_DPI, CLIENTE_DPI)
    select distinct d.FACTURA, d.SERIE, d.FECHA_FACTURA, d.SUCURSAL, d.DPI_V, d.DPI_C
    from datostodos d;

INSERT INTO DETALLEFACTURA(cantidad, id_Producto, NumeroFactura)
    select distinct d.cantidad, p.id_Producto, f.NumeroFactura
    from datostodos d, PRODUCTO p, FACTURA f
    where p.Nombre = d.NOMBRE_PRODUCTO and p.Talla = d.TALLA
    and p.Color = d.COLOR and p.Precio = d.PRECIO_PRODUCTO
    and f.NUMEROFACTURA = d.FACTURA;

EOF
