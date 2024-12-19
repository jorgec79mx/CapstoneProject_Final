CREATE PROCEDURE LlenarVentaImporteXEmpresa_Pedimento_IA(
	@Empresa		VARCHAR(10)
	,@FechaInicio	DATETIME
	,@FechaFinal	DATETIME
	,@Reconstruir	BIT = 0
)
AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--DECLARE	@Empresa		VARCHAR(10)
--		,@FechaInicio	DATETIME
--		,@FechaFinal	DATETIME
--		,@Reconstruir	BIT = 0
--SELECT	@Empresa		= 'PLHBS'
--		,@FechaInicio	= '20210501'
--		,@FechaFinal	= '20241130'
--		,@Reconstruir	= 0

CREATE TABLE #tbArticulo(
	Articulo		VARCHAR(10)
	,Descripcion	VARCHAR(100)
	,Modulo			VARCHAR(10)
)

INSERT INTO #tbArticulo(Articulo, Descripcion, Modulo)
SELECT Articulo, Descripcion1, 'COMS' FROM Art WHERE Articulo IN ('DL00003522') --('DL00002467', 'DL00003522', 'DL00005485', 'DL00003413', 'DL00002500')
UNION
SELECT Articulo, Descripcion1, 'PROD' FROM Art WHERE Articulo IN ('DL00003022')--('DL00003018', 'DL00003896', 'DL00000068', 'DL00000679', 'DL00003022')

CREATE TABLE #Empresa(
	Empresa		VARCHAR(20) NOT NULL DEFAULT('')
)

SELECT @Empresa = ISNULL(@Empresa,'')
INSERT INTO #Empresa(Empresa)
SELECT	E.Empresa
FROM	Empresa E
WHERE	Empresa = CASE @Empresa WHEN ''				THEN E.Empresa
								WHEN 'HOTELERIA'	THEN 'PLHBS'
								ELSE @Empresa
				END

IF @Empresa = 'HOTELERIA' BEGIN
	INSERT INTO #Empresa(Empresa)
	SELECT 'HBSMX'
END
IF @Empresa = 'FINMES' BEGIN
	INSERT INTO #Empresa(Empresa)
	SELECT 'HBSMX'
	UNION	SELECT 'PLHBS'
	UNION	SELECT 'RETAI'
	UNION	SELECT 'VELSA'
	UNION	SELECT 'MAQAS'
	UNION	SELECT 'LACAE'
END

/********************************************************************************************************************
 * Eliminando Historico
 ********************************************************************************************************************/
IF @Reconstruir = 1 BEGIN
	DELETE FROM delli.webVentaImporteXEmpresa WHERE FechaEmision BETWEEN @FechaInicio And @FechaFinal and Empresa IN (select Empresa From #Empresa)
	DELETE FROM ia_assistance.dbo.VentaImporteXEmpresa WHERE FechaEmision BETWEEN @FechaInicio And @FechaFinal and Empresa IN (select Empresa From #Empresa)
END

/********************************************************************************************************************
 * Generando el reporte
 ********************************************************************************************************************/
CREATE TABLE #ReporteVenta(
	Numero_Orden					INT NOT NULL DEFAULT(0)
	,Mov							VARCHAR(50) NOT NULL DEFAULT('')
	,MovId							VARCHAR(50) NOT NULL DEFAULT('')
	,Tipo_Orden						VARCHAR(20) NOT NULL DEFAULT('')
	,Empresa						VARCHAR(20) NOT NULL DEFAULT('')
	,Sucursal						INT NOT NULL DEFAULT(0)
	,Nombre_Sucursal				VARCHAR(100) NOT NULL DEFAULT('')
	,FechaEmision					DATETIME NOT NULL
	,FechaRequerida					DATETIME NULL
	,Almacen						VARCHAR(20) NOT NULL DEFAULT('')
	,Desc_Almacen					VARCHAR(100) NOT NULL DEFAULT('')
	,Numero_Cliente					VARCHAR(20) NOT NULL DEFAULT('')
	,Nombre_Cliente					VARCHAR(150) NOT NULL DEFAULT('')
	,RFC_Cliente					VARCHAR(20) NOT NULL DEFAULT('')
	,NombreCorto					VARCHAR(50) NOT NULL DEFAULT('')
	,Sucursal_Venta					VARCHAR(50) NOT NULL DEFAULT('')
	,Familia_Comercial				VARCHAR(50) NOT NULL DEFAULT('')
	,Cadena_Comercial				VARCHAR(50) NOT NULL DEFAULT('')
	,Rama							VARCHAR(20) NOT NULL DEFAULT('')
	,Vendedor						VARCHAR(100) NOT NULL DEFAULT('')
	,Numero_Renglon					INT NOT NULL
	,RenglonTipo					CHAR(1) NOT NULL DEFAULT('')
	,Articulo						VARCHAR(20) NOT NULL DEFAULT('')
	,SKU							VARCHAR(20) NOT NULL DEFAULT('')
	,Desc_Articulo					VARCHAR(100) NOT NULL DEFAULT('')
	,Lote							VARCHAR(50) NOT NULL DEFAULT('')
	,Propiedades					VARCHAR(50) NOT NULL DEFAULT('')
	,FechaPedimento					DATETIME NULL
	,Cantidad						NUMERIC(15,4) NOT NULL
	,UM								VARCHAR(50) NOT NULL DEFAULT('')
	,CantidadSecundaria				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,CantidadInventario				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Factor							NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,UMSecundaria					VARCHAR(20) NOT NULL DEFAULT('')
	,FactorLitros					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Precio							NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Porcentaje_IVA					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Porcentaje_IEPS				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Porcentaje_IEPS_Cuota			NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Costo_Unitario					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Costo_Total					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,SubTotal						NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Impuesto1Total					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Impuesto2Total					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Impuesto3Total					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,ImporteTotal					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,Categoria						VARCHAR(50) NOT NULL DEFAULT('')
	,Familia						VARCHAR(50) NOT NULL DEFAULT('')
	,Grupo							VARCHAR(50) NOT NULL DEFAULT('')
	,Linea							VARCHAR(50) NULL
	,ArticuloRama					VARCHAR(50) NOT NULL DEFAULT('')
	,ContId							INT NOT NULL
	,ContMov						VARCHAR(20) NOT NULL DEFAULT('')
	,ContMovId						VARCHAR(20) NOT NULL DEFAULT('')
	,Estatus						VARCHAR(20) NOT NULL DEFAULT('')
	,Moneda							VARCHAR(20) NOT NULL DEFAULT('')
	,TipoCambio						NUMERIC(15,4) NOT NULL
	,Tipo							VARCHAR(20) NOT NULL DEFAULT('')
	,IdProd							INT NOT NULL
	,Produccion						VARCHAR(20) NOT NULL DEFAULT('')
	,ProduccionId					VARCHAR(20) NOT NULL DEFAULT('')
	,Planta_Produccion				VARCHAR(20) NOT NULL DEFAULT('')
	,CostoProduccionUnitario		NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,CostoProduccion				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,IdCompra						INT NOT NULL
	,Compra							VARCHAR(20) NOT NULL DEFAULT('')
	,CompraId						VARCHAR(20) NOT NULL DEFAULT('')
	,Proveedor						VARCHAR(20) NOT NULL DEFAULT('')
	,NombreProveedor				VARCHAR(100) NOT NULL DEFAULT('')
	,IdCompraInicial				INT NOT NULL
	,CompraInicial					VARCHAR(20) NOT NULL DEFAULT('')
	,CompraInicialId				VARCHAR(20) NOT NULL DEFAULT('')
	,CostoInicialUnitario			NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,CostoInicial					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,CostoReposicionUnitario		NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,CostoReposicion				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,DescuentoLinea					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,DescuentoLineal				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,UltimoCosto					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
	,UUID							VARCHAR(36) NOT NULL DEFAULT('')
	,Condicion_Comercial			VARCHAR(50) NOT NULL DEFAULT('')
	,TipoPoliza						VARCHAR(10) NOT NULL DEFAULT('')
	,NumeroPoliza					VARCHAR(20) NOT NULL DEFAULT('')
	,DescuentoObsequio				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
)

--Ingresos
INSERT INTO #ReporteVenta(Numero_Orden, Mov, MovId, Tipo_Orden, Empresa, Sucursal, Nombre_Sucursal, FechaEmision, FechaRequerida, Almacen
	,Desc_Almacen, Numero_Cliente, Nombre_Cliente, RFC_Cliente, NombreCorto, Sucursal_Venta, Familia_Comercial, Cadena_Comercial, Rama
	,Vendedor, Numero_Renglon, RenglonTipo, Articulo, SKU, Desc_Articulo, Lote, Propiedades, Cantidad, UM, CantidadSecundaria, CantidadInventario
	,Factor, UMSecundaria, FactorLitros, Precio, Porcentaje_IVA, Porcentaje_IEPS, Porcentaje_IEPS_Cuota, Costo_Unitario, Costo_Total, SubTotal
	,Impuesto1Total, Impuesto2Total, Impuesto3Total, ImporteTotal, Categoria, Familia, Grupo, Linea, ArticuloRama, ContId, ContMov, ContMovId, Estatus, Moneda
	,TipoCambio, Tipo, IdProd, Produccion, ProduccionId, Planta_Produccion, CostoProduccionUnitario, CostoProduccion, IdCompra, Compra
	,CompraId, Proveedor, NombreProveedor, IdCompraInicial, CompraInicial, CompraInicialId, CostoInicialUnitario, CostoInicial
	,CostoReposicionUnitario, CostoReposicion, DescuentoLinea, DescuentoLineal, UltimoCosto, Condicion_Comercial, TipoPoliza, NumeroPoliza
	,DescuentoObsequio)
SELECT	V.Id													as 'Numero_Orden'
		,LTRIM(RTRIM(V.Mov))									as 'Mov'
		,LTRIM(RTRIM(V.MovId))									as 'MovId'
		,MT.Clave												as 'Tipo_Orden'
		,V.Empresa												as 'Empresa'
		,S.Sucursal												as 'Sucursal'
		,S.Nombre												as 'Nombre_Sucursal'
		,V.FechaEmision											as 'FechaEmision'
		,V.FechaRequerida										as 'FechaRequerida'
		,Alm.Almacen											as 'Almacen'
		,Alm.Nombre												as 'Desc_Almacen'
		,C.Cliente												as 'Numero_Cliente'
		,C.Nombre												as 'Nombre_Cliente'
		,C.RFC													as 'RFC_Cliente'
		,ISNULL(C.NombreCorto, '')								as 'NombreCorto'
		,S.Estado												as 'Sucursal_Venta'
		,ISNULL(C.Familia,'')									as 'Familia_Comercial'
		,ISNULL(C.Grupo, '')									as 'Cadena_Comercial'
		,ISNULL(C.Rama, '')										as 'Rama'
		,ISNULL(V.Agente, '')									as 'Vendedor'
		,V.RenglonId											as 'Numero_Renglon'
		,V.RenglonTipo											as 'RenglonTipo'
		,V.Articulo												as 'Articulo'
		,V.Articulo												as 'SKU'
		,A.Descripcion1											as 'Desc_Articulo'
		,ISNULL(SLM.SerieLote,'---')							as 'Lote'
		,ISNULL(SLM.Propiedades,'---')							as 'Propiedades'
		,ISNULL(SLM.Cantidad,V.Cantidad)						as 'Cantidad'
		,V.Unidad												as 'UM'
		,V.Cantidad												as 'CantidadSecundaria'
		,ISNULL(V.CantidadInventario, V.Cantidad)				as 'CantidadInventario'
		,ISNULL(V.Factor,1)										as 'Factor'
		,V.Unidad												as 'UMSecundaria'
		,1000.0000												as 'FactorLitros'
		,ISNULL(V.Precio*ISNULL(V.TipoCambio,1.00),0.00)		as 'Precio'
		,ISNULL(V.Impuesto1, 0)									as 'Porcentaje_IVA'
		,ISNULL(V.Impuesto2, 0)									as 'Porcentaje_IEPS'
		,ISNULL(V.Impuesto3, 0)									as 'Porcentaje_IEPS_Cuota'
		,CASE A.MonedaCosto
			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00)) 
		 END																as 'Costo_Unitario'
		,CASE A.MonedaCosto
			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
		 END*ISNULL(SLM.Cantidad,V.Cantidad)							 as 'Costo_Total'
		,(ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))	as 'SubTotal'
		,SUM(
			(
				(ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad)),0.00))	--*ISNULL(V.TipoCambio,1.00)
				+ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad)*(ISNULL(V.Impuesto2,0)/100.00)),0.00)
			)*((ISNULL(V.Impuesto1,0)/100.00))
		)*ISNULL(V.TipoCambio,1.00)											as 'Impuesto1Total'
		,SUM(ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad)*(ISNULL(V.Impuesto2,0)/100.00))*ISNULL(V.TipoCambio,1.00),0.00))		as 'Impuesto2Total'
		,0.00																as 'Impuesto3Total'
		,SUM(ISNULL(V.ImporteTotal*ISNULL(V.TipoCambio,1.00),0.00))			as 'ImporteTotal'
		,ISNULL(A.Categoria, '')											as 'Categoria'
		,ISNULL(A.Familia, '')												as 'Familia'
		,ISNULL(A.Grupo, '')												as 'Grupo'
		,A.Linea															as 'Linea'
		,ISNULL(A.Rama, '')													as 'ArticuloRama'
		,999999																as 'ContId'
		,REPLICATE('',20)													as 'ContMov'
		,REPLICATE('',20)													as 'ContMovId'
		,REPLICATE('',20)													as 'Estatus'
		,V.Moneda															as 'Moneda'
		,V.TipoCambio														as 'TipoCambio'
		,C.Tipo																as 'Tipo'
		,999999																as 'IdProd'
		,REPLICATE('',20)													as 'Produccion'
		,REPLICATE('',20)													as 'ProduccionId'
		,REPLICATE('',20)													as 'Planta_Produccion'
		,99999999.999999													as 'CostoProduccionUnitario'
		,99999999.999999													as 'CostoProduccion'
		,999999																as 'IdCompra'
		,REPLICATE('',20)													as 'Compra'
		,REPLICATE('',20)													as 'CompraId'
		,REPLICATE('',20)													as 'Proveedor'
		,REPLICATE('',100)													as 'NombreProveedor'
		,99999999.99999														as 'IdCompraInicial'
		,REPLICATE('',20)													as 'CompraInicial'
		,REPLICATE('',20)													as 'CompraInicialId'
		,99999999.99999														as 'CostoInicialUnitario'
		,99999999.99999														as 'CostoInicial'
		,99999999.99999														as 'CostoReposicionUnitario'
		,99999999.99999														as 'CostoReposicion'
		,ISNULL(V.DescuentoLinea,0.00)										as 'DescuentoLinea'
		,ISNULL(V.DescuentoLineal,0.00)										as 'DescuentoLineal'
		,ISNULL((Select ACC.UltimoCosto FROM ArtConCosto ACC WHERE ACC.Empresa = V.Empresa And ACC.Articulo = A.Articulo), 0.00)	as 'UltimoCosto'
		,ISNULL(V.Condicion,'')												as 'Condicion_Comercial'
		,''																	as 'TipoPoliza'
		,''																	as 'NumeroPoliza'
		,ISNULL(D.CantidadObsequio ,0.00)*D.Precio							as 'CantidadObsequio'
FROM	VentaTCalc V
INNER JOIN VentaD D ON D.Id = V.Id And D.RenglonId = V.RenglonId AND D.Articulo = v.Articulo
	And D.Articulo IN (Select Articulo From #tbArticulo)
INNER JOIN Sucursal S ON S.Sucursal = V.Sucursal
INNER JOIN Alm ON Alm.Almacen = V.Almacen
INNER JOIN Cte C ON c.Cliente = V.Cliente
INNER JOIN MovTipo MT ON MT.Mov = V.Mov And MT.Modulo = 'VTAS' And MT.Clave IN ( 'VTAS.F', 'VTAS.D', 'VTAS.B')
INNER JOIN Art A ON A.Articulo = V.Articulo 
LEFT OUTER JOIN SerieLoteMov SLM ON SLM.Empresa = V.Empresa And SLM.Modulo = 'VTAS' And SLM.Id = V.Id And SLM.RenglonId = V.RenglonId And SLM.Articulo = V.Articulo
LEFT OUTER JOIN Prov P ON P.Proveedor = A.Proveedor
WHERE	--V.Empresa = 'PLHBS'
	V.Empresa				IN (Select Empresa From #Empresa)
	And V.Mov				!= 'Factura JD'
	And V.FechaEmision		BETWEEN @FechaInicio and @FechaFinal
	And V.Estatus			IN ( 'CONCLUIDO', 'PENDIENTE')
	And ISNULL(V.Unidad,'')	IN ('LT', 'KG', 'PZA', 'SR', 'M3' ,'MILL')
GROUP BY V.Id
		,V.RenglonId
		,LTRIM(RTRIM(V.Mov))
		,LTRIM(RTRIM(V.MovId))
		,MT.Clave
		,V.Empresa
		,S.Sucursal
		,S.Nombre
		,V.FechaEmision
		,V.FechaRequerida
		,Alm.Almacen
		,Alm.Nombre
		,C.Cliente
		,C.Nombre
		,C.RFC
		,ISNULL(C.NombreCorto, '')
		,S.Estado
		,ISNULL(C.Familia,'')
		,ISNULL(C.Grupo, '')
		,ISNULL(C.Rama, '')
		,ISNULL(V.Agente, '')
		,V.RenglonId
		,V.RenglonTipo
		,V.Articulo
		,A.Descripcion1
		,(ISNULL(V.Cantidad,0.00))
		,SLM.SerieLote
		,SLM.Propiedades
		,ISNULL(SLM.Cantidad,V.Cantidad)
		,V.Unidad
		,V.Cantidad
		,ISNULL(V.CantidadInventario, V.Cantidad)
		,ISNULL(V.Factor,1)
		,V.Unidad
		--,ISNULL(V.Precio*ISNULL(V.TipoCambio,1.00),0.00)
		,V.Precio
		,ISNULL(V.TipoCambio,1.00)
		,ISNULL(V.Impuesto1, 0)
		,ISNULL(V.Impuesto2, 0)
		,ISNULL(V.Impuesto3, 0)
		,A.MonedaCosto
		,ISNULL(A.Categoria, '')
		,ISNULL(A.Familia, '')
		,ISNULL(A.Grupo, '')
		,A.Linea
		,ISNULL(A.Rama, '')
		,V.Moneda
		,V.TipoCambio
		,C.Tipo
		,ISNULL(V.DescuentoLinea,0.00)
		,ISNULL(V.DescuentoLineal,0.00)
		,A.Articulo
		,ISNULL(V.Condicion,'')
		,ISNULL(D.CantidadObsequio ,0.00)*D.Precio
ORDER BY V.Empresa, V.Id, V.RenglonID

/*Cancelaciones 
	KLEVAY 20230301 solicito no aparezcan
*/
--Ingresos
--INSERT INTO #ReporteVenta(Numero_Orden, Mov, MovId, Tipo_Orden, Empresa, Sucursal, Nombre_Sucursal, FechaEmision, FechaRequerida, Almacen
--	,Desc_Almacen, Numero_Cliente, Nombre_Cliente, RFC_Cliente, NombreCorto, Sucursal_Venta, Familia_Comercial, Cadena_Comercial, Rama
--	,Vendedor, Numero_Renglon, RenglonTipo, Articulo, SKU, Desc_Articulo, Lote, Propiedades, Cantidad, UM, CantidadSecundaria, CantidadInventario
--	,Factor, UMSecundaria, FactorLitros, Precio, Porcentaje_IVA, Porcentaje_IEPS, Porcentaje_IEPS_Cuota, Costo_Unitario, Costo_Total, SubTotal
--	,Impuesto1Total, Impuesto2Total, Impuesto3Total, ImporteTotal, Categoria, Familia, Grupo, Linea, ArticuloRama, ContId, ContMov, ContMovId, Estatus, Moneda
--	,TipoCambio, Tipo, IdProd, Produccion, ProduccionId, Planta_Produccion, CostoProduccionUnitario, CostoProduccion, IdCompra, Compra
--	,CompraId, Proveedor, NombreProveedor, IdCompraInicial, CompraInicial, CompraInicialId, CostoInicialUnitario, CostoInicial
--	,CostoReposicionUnitario, CostoReposicion, DescuentoLinea, DescuentoLineal, UltimoCosto)
--SELECT	V.Id													as 'Numero_Orden'
--		,LTRIM(RTRIM(V.Mov))									as 'Mov'
--		,LTRIM(RTRIM(V.MovId))									as 'MovId'
--		,MT.Clave												as 'Tipo_Orden'
--		,V.Empresa												as 'Empresa'
--		,S.Sucursal												as 'Sucursal'
--		,S.Nombre												as 'Nombre_Sucursal'
--		,V.FechaEmision											as 'FechaEmision'
--		,V.FechaRequerida										as 'FechaRequerida'
--		,Alm.Almacen											as 'Almacen'
--		,Alm.Nombre												as 'Desc_Almacen'
--		,C.Cliente												as 'Numero_Cliente'
--		,C.Nombre												as 'Nombre_Cliente'
--		,C.RFC													as 'RFC_Cliente'
--		,ISNULL(C.NombreCorto, '')								as 'NombreCorto'
--		,S.Estado												as 'Sucursal_Venta'
--		,ISNULL(C.Familia,'')									as 'Familia_Comercial'
--		,ISNULL(C.Grupo, '')									as 'Cadena_Comercial'
--		,ISNULL(C.Rama, '')										as 'Rama'
--		,ISNULL(V.Agente, '')									as 'Vendedor'
--		,V.RenglonId											as 'Numero_Renglon'
--		,V.RenglonTipo											as 'RenglonTipo'
--		,V.Articulo												as 'Articulo'
--		,V.Articulo												as 'SKU'
--		,A.Descripcion1											as 'Desc_Articulo'
--		,ISNULL(SLM.SerieLote,'---')							as 'Lote'
--		,ISNULL(SLM.Propiedades,'---')							as 'Propiedades'
--		,ISNULL(SLM.Cantidad,V.Cantidad)*-1.000					as 'Cantidad'
--		,V.Unidad												as 'UM'
--		,V.Cantidad*-1.000										as 'CantidadSecundaria'
--		,ISNULL(V.CantidadInventario, V.Cantidad)*-1.000		as 'CantidadInventario'
--		,V.Factor												as 'Factor'
--		,V.Unidad												as 'UMSecundaria'
--		,1000.0000												as 'FactorLitros'
--		,ISNULL(V.Precio*ISNULL(V.TipoCambio,1.00),0.00)		as 'Precio'
--		,ISNULL(V.Impuesto1, 0)									as 'Porcentaje_IVA'
--		,ISNULL(V.Impuesto2, 0)									as 'Porcentaje_IEPS'
--		,ISNULL(V.Impuesto3, 0)									as 'Porcentaje_IEPS_Cuota'
--		,CASE A.MonedaCosto
--			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
--			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00)) 
--		 END												as 'Costo_Unitario'
--		,CASE A.MonedaCosto
--			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
--			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
--		 END*ISNULL(SLM.Cantidad,V.Cantidad)*-1.000				 as 'Costo_Total'
--		,(ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))*-1.000	as 'SubTotal'
--		,SUM(
--			(
--				(ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad)),0.00))	--*ISNULL(V.TipoCambio,1.00)
--				+ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad)*(ISNULL(V.Impuesto2,0)/100.00)),0.00)
--			)*((ISNULL(V.Impuesto1,0)/100.00))
--		)*ISNULL(V.TipoCambio,1.00)*-1.000									as 'Impuesto1Total'
--		,SUM(ISNULL((V.Precio*ISNULL(SLM.Cantidad,V.Cantidad)*(ISNULL(V.Impuesto2,0)/100.00))*ISNULL(V.TipoCambio,1.00),0.00))*-1.000		as 'Impuesto2Total'
--		,0.00																as 'Impuesto3Total'
--		,SUM(ISNULL(V.ImporteTotal*ISNULL(V.TipoCambio,1.00),0.00))*-1.000	as 'ImporteTotal'
--		,ISNULL(A.Categoria, '')											as 'Categoria'
--		,ISNULL(A.Familia, '')												as 'Familia'
--		,ISNULL(A.Grupo, '')												as 'Grupo'
--		,A.Linea															as 'Linea'
--		,ISNULL(A.Rama, '')													as 'ArticuloRama'
--		,999999																as 'ContId'
--		,REPLICATE('',20)													as 'ContMov'
--		,REPLICATE('',20)													as 'ContMovId'
--		,REPLICATE('',20)													as 'Estatus'
--		,V.Moneda															as 'Moneda'
--		,V.TipoCambio														as 'TipoCambio'
--		,C.Tipo																as 'Tipo'
--		,999999																as 'IdProd'
--		,REPLICATE('',20)													as 'Produccion'
--		,REPLICATE('',20)													as 'ProduccionId'
--		,REPLICATE('',20)													as 'Planta_Produccion'
--		,99999999.999999													as 'CostoProduccionUnitario'
--		,99999999.999999													as 'CostoProduccion'
--		,999999																as 'IdCompra'
--		,REPLICATE('',20)													as 'Compra'
--		,REPLICATE('',20)													as 'CompraId'
--		,REPLICATE('',20)													as 'Proveedor'
--		,REPLICATE('',100)													as 'NombreProveedor'
--		,99999999.99999														as 'IdCompraInicial'
--		,REPLICATE('',20)													as 'CompraInicial'
--		,REPLICATE('',20)													as 'CompraInicialId'
--		,99999999.99999														as 'CostoInicialUnitario'
--		,99999999.99999														as 'CostoInicial'
--		,99999999.99999														as 'CostoReposicionUnitario'
--		,99999999.99999														as 'CostoReposicion'
--		,ISNULL(V.DescuentoLinea,0.00)										as 'DescuentoLinea'
--		,ISNULL(V.DescuentoLineal,0.00)										as 'DescuentoLineal'
--		,ISNULL((Select ACC.UltimoCosto FROM ArtConCosto ACC WHERE ACC.Empresa = V.Empresa And ACC.Articulo = A.Articulo), 0.00)	as 'UltimoCosto'
--FROM	VentaTCalc V
--INNER JOIN Venta V2 ON V2.Id = V.Id
--INNER JOIN Sucursal S ON S.Sucursal = V.Sucursal
--INNER JOIN Alm ON Alm.Almacen = V.Almacen
--INNER JOIN Cte C ON c.Cliente = V.Cliente
--INNER JOIN MovTipo MT ON MT.Mov = V.Mov And MT.Modulo = 'VTAS' And MT.Clave IN ( 'VTAS.F', 'VTAS.D', 'VTAS.B')
--INNER JOIN Art A ON A.Articulo = V.Articulo 
--LEFT OUTER JOIN SerieLoteMov SLM ON SLM.Empresa = V.Empresa And SLM.Modulo = 'VTAS' And SLM.Id = V.Id And SLM.RenglonId = V.RenglonId And SLM.Articulo = V.Articulo
--LEFT OUTER JOIN Prov P ON P.Proveedor = A.Proveedor
--WHERE	--V.Empresa = 'PLHBS'
--	V.Empresa				IN (Select Empresa From #Empresa)
--	And V.Mov				!= 'Factura JD'
--	And V.FechaEmision		BETWEEN @FechaInicio and @FechaFinal
--	And ISNULL(V.Unidad,'')	IN ('LT', 'KG', 'PZA', 'SR', 'M3' ,'MILL')
--	And V.Estatus			= 'CANCELADO'
--	And DATEDIFF(MONTH,V.FechaEmision,V2.FechaCancelacion) > 0
--GROUP BY V.Id
--		,V.RenglonId
--		,LTRIM(RTRIM(V.Mov))
--		,LTRIM(RTRIM(V.MovId))
--		,MT.Clave
--		,V.Empresa
--		,S.Sucursal
--		,S.Nombre
--		,V.FechaEmision
--		,V.FechaRequerida
--		,Alm.Almacen
--		,Alm.Nombre
--		,C.Cliente
--		,C.Nombre
--		,C.RFC
--		,ISNULL(C.NombreCorto, '')
--		,S.Estado
--		,ISNULL(C.Familia,'')
--		,ISNULL(C.Grupo, '')
--		,ISNULL(C.Rama, '')
--		,ISNULL(V.Agente, '')
--		,V.RenglonId
--		,V.RenglonTipo
--		,V.Articulo
--		,A.Descripcion1
--		,(ISNULL(V.Cantidad,0.00))
--		,SLM.SerieLote
--		,SLM.Propiedades
--		,ISNULL(SLM.Cantidad,V.Cantidad)
--		,V.Unidad
--		,V.Cantidad
--		,ISNULL(V.CantidadInventario, V.Cantidad)
--		,V.Factor
--		,V.Unidad
--		--,ISNULL(V.Precio*ISNULL(V.TipoCambio,1.00),0.00)
--		,V.Precio
--		,ISNULL(V.TipoCambio,1.00)
--		,ISNULL(V.Impuesto1, 0)
--		,ISNULL(V.Impuesto2, 0)
--		,A.MonedaCosto
--		,ISNULL(A.Categoria, '')
--		,ISNULL(A.Familia, '')
--		,ISNULL(A.Grupo, '')
--		,A.Linea
--		,ISNULL(A.Rama, '')
--		,V.Moneda
--		,V.TipoCambio
--		,C.Tipo
--		,ISNULL(V.DescuentoLinea,0.00)
--		,ISNULL(V.DescuentoLineal,0.00)
--		,A.Articulo
--ORDER BY V.Empresa, V.Id, V.RenglonID

--Diferentes de Pieza
INSERT INTO #ReporteVenta
SELECT	V.Id																as 'Numero_Orden'
		,LTRIM(RTRIM(V.Mov))												as 'Mov'
		,LTRIM(RTRIM(V.MovId))												as 'MovId'
		,MT.Clave															as 'Tipo_Orden'
		,V.Empresa															as 'Empresa'
		,S.Sucursal															as 'Sucursal'
		,S.Nombre															as 'Nombre_Sucursal'
		,V.FechaEmision														as 'FechaEmision'
		,V.FechaRequerida													as 'FechaRequerida'
		,Alm.Almacen														as 'Almacen'
		,Alm.Nombre															as 'Desc_Almacen'
		,C.Cliente															as 'Numero_Cliente'
		,C.Nombre															as 'Nombre_Cliente'
		,C.RFC																as 'RFC_Cliente'
		,ISNULL(C.NombreCorto, '')											as 'NombreCorto'
		,S.Estado															as 'Sucursal_Venta'
		,ISNULL(C.Familia,'')												as 'Familia_Comercial'
		,ISNULL(C.Grupo, '')												as 'Cadena_Comercial'
		,ISNULL(C.Rama, '')													as 'Rama'
		,ISNULL(V.Agente, '')												as 'Vendedor'
		,V.RenglonId														as 'Numero_Renglon'
		,V.RenglonTipo														as 'RenglonTipo'
		,V.Articulo															as 'Articulo'
		,V.Articulo															as 'SKU'
		,A.Descripcion1														as 'Desc_Articulo'
		--,SLM.SerieLote														as 'Lote'
		,(Select	ISNULL(MIN(SLM.SerieLote),'')
			From	SerieLoteMov SLM
			Where	SLM.Empresa = V.Empresa 
				And SLM.Modulo = 'VTAS' 
				And SLM.Id = V.Id 
				And SLM.RenglonId = V.RenglonId
				And SLM.Articulo = V.Articulo )								as 'Lote'
		,(Select	ISNULL(MIN(SLM.Propiedades),'')
			From	SerieLoteMov SLM
			Where	SLM.Empresa = V.Empresa 
				And SLM.Modulo = 'VTAS' 
				And SLM.Id = V.Id 
				And SLM.RenglonId = V.RenglonId
				And SLM.Articulo = V.Articulo
				And ISNULL(SLM.Propiedades, '')!='')						as 'Propiedades'
		,NULL																as 'FechaPedimento'
		,ISNULL((	Select	SUM(SLM.Cantidad)
			From	SerieLoteMov SLM
			Where	SLM.Empresa = V.Empresa 
				And SLM.Modulo = 'VTAS' 
				And SLM.Id = V.Id 
				And SLM.RenglonId = V.RenglonId 
				And SLM.Articulo = V.Articulo ), V.Cantidad)				as 'Cantidad'----
		,V.Unidad															as 'UM'
		,V.Cantidad															as 'CantidadSecundaria'
		,ISNULL(V.CantidadInventario, V.Cantidad)							as 'CantidadInventario'
		,ISNULL(V.Factor,1)													as 'Factor'
		,V.Unidad															as 'UMSecundaria'
		,100.0000															as 'FactorLitros'
		,ISNULL(V.Precio*ISNULL(V.TipoCambio,1.00),0.00)					as 'Precio'
		,ISNULL(V.Impuesto1, 0)												as 'Porcentaje_IVA'
		,ISNULL(V.Impuesto2, 0)												as 'Porcentaje_IEPS'
		,ISNULL(V.Impuesto3, 0)												as 'Porcentaje_IEPS_Cuota'
		,CASE A.MonedaCosto
			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
		 END																as 'Costo_Unitario'
		,CASE A.MonedaCosto
			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
		 END*V.Cantidad													as 'Costo_Total'
		,(ISNULL((V.Precio*V.Cantidad)*ISNULL(V.TipoCambio,1.00),0.00))	as 'SubTotal'
		,SUM(
			(
				(ISNULL((V.Precio*V.Cantidad),0.00))	--*ISNULL(V.TipoCambio,1.00)
				+ISNULL((V.Precio*V.Cantidad*(ISNULL(V.Impuesto2,0)/100.00)),0.00)
			)*((ISNULL(V.Impuesto1,0)/100.00))
		)*ISNULL(V.TipoCambio,1.00)											as 'Impuesto1Total'
		,SUM(ISNULL((V.Precio*V.Cantidad*(ISNULL(V.Impuesto2,0)/100.00))*ISNULL(V.TipoCambio,1.00),0.00))		as 'Impuesto2Total'
		,0.00																as 'Impuesto3Total'
		,SUM(ISNULL(V.ImporteTotal*ISNULL(V.TipoCambio,1.00),0.00))			as 'ImporteTotal'
		,ISNULL(A.Categoria, '')
		,ISNULL(A.Familia, '')
		,ISNULL(A.Grupo, '')
		,A.Linea
		,ISNULL(A.Rama, '')													as 'ArticuloRama'
		,999999																as 'ContId'
		,REPLICATE('',20)													as 'ContMov'
		,REPLICATE('',20)													as 'ContMovId'
		,REPLICATE('',20)													as 'Estatus'
		,V.Moneda															as 'Moneda'
		,V.TipoCambio														as 'TipoCambio'
		,C.Tipo																as 'Tipo'
		,999999																as 'IdProd'
		,REPLICATE('',20)													as 'Produccion'
		,REPLICATE('',20)													as 'ProduccionId'
		,REPLICATE('',20)													as 'Planta_Produccion'
		,999999.9999														as 'CostoProduccionUnitario'
		,999999.9999														as 'CostoProduccion'
		,999999																as 'IdCompra'
		,REPLICATE('',20)													as 'Compra'
		,REPLICATE('',20)													as 'CompraId'
		,REPLICATE('',20)													as 'Proveedor'
		,REPLICATE('',100)													as 'NombreProveedor'
		,999999.9999														as 'IdCompraInicial'
		,REPLICATE('',20)													as 'CompraInicial'
		,REPLICATE('',20)													as 'CompraInicialId'
		,999999.9999														as 'CostoInicialUnitario'
		,999999.9999														as 'CostoInicial'
		,999999.9999														as 'CostoReposicionUnitario'
		,999999.9999														as 'CostoReposicion'
		,ISNULL(V.DescuentoLinea,0.00)										as 'DescuentoLinea'
		,ISNULL(V.DescuentoLineal,0.00)										as 'DescuentoLineal'
		,ISNULL((Select ACC.UltimoCosto FROM ArtConCosto ACC WHERE ACC.Empresa = V.Empresa And ACC.Articulo = A.Articulo), 0.00)	as 'UltimoCosto'
		,''
		,ISNULL(V.Condicion,'')												as 'Condicion_Comercial'
		,''																	as 'TipoPoliza'
		,''																	as 'NumeroPoliza'
		,ISNULL(D.CantidadObsequio ,0.00)*D.Precio							as 'CantidadObsequio'
FROM	VentaTCalc V
INNER JOIN VentaD D ON D.Id = V.Id And D.RenglonId = V.RenglonId AND D.Articulo = v.Articulo
	And D.Articulo IN (Select Articulo From #tbArticulo)
INNER JOIN Sucursal S ON S.Sucursal = V.Sucursal
INNER JOIN Alm ON Alm.Almacen = V.Almacen
INNER JOIN Cte C ON c.Cliente = V.Cliente
INNER JOIN MovTipo MT ON MT.Mov = V.Mov And MT.Modulo = 'VTAS' And MT.Clave IN ( 'VTAS.F', 'VTAS.D', 'VTAS.B', 'VTAS.VC_', 'VTAS.DC_')
INNER JOIN Art A ON A.Articulo = V.Articulo 
LEFT OUTER JOIN Prov P ON P.Proveedor = A.Proveedor
LEFT OUTER JOIN ArtUnidad AU ON AU.Articulo = A.Articulo And AU.Unidad = 'PZA'
WHERE	V.Empresa				IN (Select Empresa From #Empresa)
	And V.Mov				!= 'Factura JD'
	And V.FechaEmision		BETWEEN @FechaInicio and @FechaFinal
	And V.Estatus			IN ( 'CONCLUIDO', 'PENDIENTE')
	And ISNULL(V.Unidad,'')	NOT IN ('LT', 'KG', 'PZA', 'SR', 'M3' ,'MILL')
GROUP BY V.Id
		,V.RenglonId
		,LTRIM(RTRIM(V.Mov))
		,LTRIM(RTRIM(V.MovId))
		,MT.Clave
		,V.Empresa
		,S.Sucursal
		,S.Nombre
		,V.FechaEmision
		,V.FechaRequerida
		,Alm.Almacen
		,Alm.Nombre
		,C.Cliente
		,C.Nombre
		,C.RFC
		,ISNULL(C.NombreCorto, '')
		,S.Estado
		,ISNULL(C.Familia,'')
		,ISNULL(C.Grupo, '')
		,ISNULL(C.Rama, '')
		,ISNULL(V.Agente, '')
		,V.RenglonId
		,V.RenglonTipo
		,V.Articulo
		,A.Descripcion1
		,(ISNULL(V.Cantidad,0.00))
		,V.Unidad
		,V.Cantidad
		,ISNULL(V.CantidadInventario, V.Cantidad)
		,ISNULL(V.Factor,1)
		,V.Unidad
		,V.Precio
		,ISNULL(V.TipoCambio,1.00)
		,ISNULL(V.Impuesto1, 0)
		,ISNULL(V.Impuesto2, 0)
		,ISNULL(V.Impuesto3, 0)
		,A.MonedaCosto
		,ISNULL(A.Categoria, '')
		,ISNULL(A.Familia, '')
		,ISNULL(A.Grupo, '')
		,A.Linea
		,ISNULL(A.Rama, '')
		,V.Moneda
		,V.TipoCambio
		,C.Tipo
		,ISNULL(V.DescuentoLinea,0.00)
		,ISNULL(V.DescuentoLineal,0.00)
		,A.Articulo
		,ISNULL(V.Condicion,'')
		,ISNULL(D.CantidadObsequio ,0.00)*D.Precio
ORDER BY V.Empresa, V.Id, V.RenglonID

/* Cancelacion 
	KLEYVA Solicita el 20230301 no aparezca
*/
--INSERT INTO #ReporteVenta
--SELECT	V.Id																as 'Numero_Orden'
--		,LTRIM(RTRIM(V.Mov))												as 'Mov'
--		,LTRIM(RTRIM(V.MovId))												as 'MovId'
--		,MT.Clave															as 'Tipo_Orden'
--		,V.Empresa															as 'Empresa'
--		,S.Sucursal															as 'Sucursal'
--		,S.Nombre															as 'Nombre_Sucursal'
--		,V.FechaEmision														as 'FechaEmision'
--		,V.FechaRequerida													as 'FechaRequerida'
--		,Alm.Almacen														as 'Almacen'
--		,Alm.Nombre															as 'Desc_Almacen'
--		,C.Cliente															as 'Numero_Cliente'
--		,C.Nombre															as 'Nombre_Cliente'
--		,C.RFC																as 'RFC_Cliente'
--		,ISNULL(C.NombreCorto, '')											as 'NombreCorto'
--		,S.Estado															as 'Sucursal_Venta'
--		,ISNULL(C.Familia,'')												as 'Familia_Comercial'
--		,ISNULL(C.Grupo, '')												as 'Cadena_Comercial'
--		,ISNULL(C.Rama, '')													as 'Rama'
--		,ISNULL(V.Agente, '')												as 'Vendedor'
--		,V.RenglonId														as 'Numero_Renglon'
--		,V.RenglonTipo														as 'RenglonTipo'
--		,V.Articulo															as 'Articulo'
--		,V.Articulo															as 'SKU'
--		,A.Descripcion1														as 'Desc_Articulo'
--		--,SLM.SerieLote														as 'Lote'
--		,(Select	ISNULL(MIN(SLM.SerieLote),'')
--			From	SerieLoteMov SLM
--			Where	SLM.Empresa = V.Empresa 
--				And SLM.Modulo = 'VTAS' 
--				And SLM.Id = V.Id 
--				And SLM.RenglonId = V.RenglonId
--				And SLM.Articulo = V.Articulo )								as 'Lote'
--		,(Select	ISNULL(MIN(SLM.Propiedades),'')
--			From	SerieLoteMov SLM
--			Where	SLM.Empresa = V.Empresa 
--				And SLM.Modulo = 'VTAS' 
--				And SLM.Id = V.Id 
--				And SLM.RenglonId = V.RenglonId
--				And SLM.Articulo = V.Articulo 
--				And ISNULL(SLM.Propiedades, '')!='')						as 'Propiedades'
--		,ISNULL((	Select	SUM(SLM.Cantidad)
--			From	SerieLoteMov SLM
--			Where	SLM.Empresa = V.Empresa 
--				And SLM.Modulo = 'VTAS' 
--				And SLM.Id = V.Id 
--				And SLM.RenglonId = V.RenglonId 
--				And SLM.Articulo = V.Articulo ), V.Cantidad)*-1.000			as 'Cantidad'----
--		,V.Unidad															as 'UM'
--		,V.Cantidad*-1.000													as 'CantidadSecundaria'
--		,ISNULL(V.CantidadInventario, V.Cantidad)*-1.000					as 'CantidadInventario'
--		,V.Factor															as 'Factor'
--		,V.Unidad															as 'UMSecundaria'
--		,100.0000															as 'FactorLitros'
--		,ISNULL(V.Precio*ISNULL(V.TipoCambio,1.00),0.00)					as 'Precio'
--		,ISNULL(V.Impuesto1, 0)												as 'Porcentaje_IVA'
--		,ISNULL(V.Impuesto2, 0)												as 'Porcentaje_IEPS'
--		,ISNULL(V.Impuesto3, 0)												as 'Porcentaje_IEPS_Cuota'
--		,CASE A.MonedaCosto
--			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
--			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
--		 END															as 'Costo_Unitario'
--		,CASE A.MonedaCosto
--			WHEN 'PESOS' THEN SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
--			ELSE SUM(ISNULL(((V.CostoTotal/V.Cantidad))*ISNULL(V.TipoCambio,1.00),0.00))
--		 END*V.Cantidad*-1.000												as 'Costo_Total'
--		,(ISNULL((V.Precio*V.Cantidad)*ISNULL(V.TipoCambio,1.00),0.00))	as 'SubTotal'
--		,SUM(
--			(
--				(ISNULL((V.Precio*V.Cantidad),0.00))	--*ISNULL(V.TipoCambio,1.00)
--				+ISNULL((V.Precio*V.Cantidad*(ISNULL(V.Impuesto2,0)/100.00)),0.00)
--			)*((ISNULL(V.Impuesto1,0)/100.00))
--		)*ISNULL(V.TipoCambio,1.00)*-1.000										as 'Impuesto1Total'
--		,SUM(ISNULL((V.Precio*V.Cantidad*(ISNULL(V.Impuesto2,0)/100.00))*ISNULL(V.TipoCambio,1.00),0.00))*-1.000		as 'Impuesto2Total'
--		,0.00																	as 'Impuesto3Total'
--		,SUM(ISNULL(V.ImporteTotal*ISNULL(V.TipoCambio,1.00),0.00))*-1.000	as 'ImporteTotal'
--		,ISNULL(A.Categoria, '')
--		,ISNULL(A.Familia, '')
--		,ISNULL(A.Grupo, '')
--		,A.Linea
--		,ISNULL(A.Rama, '')													as 'ArticuloRama'
--		,999999																as 'ContId'
--		,REPLICATE('',20)													as 'ContMov'
--		,REPLICATE('',20)													as 'ContMovId'
--		,REPLICATE('',20)													as 'Estatus'
--		,V.Moneda															as 'Moneda'
--		,V.TipoCambio														as 'TipoCambio'
--		,C.Tipo																as 'Tipo'
--		,999999																as 'IdProd'
--		,REPLICATE('',20)													as 'Produccion'
--		,REPLICATE('',20)													as 'ProduccionId'
--		,REPLICATE('',20)													as 'Planta_Produccion'
--		,999999.9999														as 'CostoProduccionUnitario'
--		,999999.9999														as 'CostoProduccion'
--		,999999																as 'IdCompra'
--		,REPLICATE('',20)													as 'Compra'
--		,REPLICATE('',20)													as 'CompraId'
--		,REPLICATE('',20)													as 'Proveedor'
--		,REPLICATE('',100)													as 'NombreProveedor'
--		,999999.9999														as 'IdCompraInicial'
--		,REPLICATE('',20)													as 'CompraInicial'
--		,REPLICATE('',20)													as 'CompraInicialId'
--		,999999.9999														as 'CostoInicialUnitario'
--		,999999.9999														as 'CostoInicial'
--		,999999.9999														as 'CostoReposicionUnitario'
--		,999999.9999														as 'CostoReposicion'
--		,ISNULL(V.DescuentoLinea,0.00)										as 'DescuentoLinea'
--		,ISNULL(V.DescuentoLineal,0.00)										as 'DescuentoLineal'
--		,ISNULL((Select ACC.UltimoCosto FROM ArtConCosto ACC WHERE ACC.Empresa = V.Empresa And ACC.Articulo = A.Articulo), 0.00)	as 'UltimoCosto'
--		,''
--FROM	VentaTCalc V
--INNER JOIN Venta V2 ON V2.Id = V.Id
--INNER JOIN Sucursal S ON S.Sucursal = V.Sucursal
--INNER JOIN Alm ON Alm.Almacen = V.Almacen
--INNER JOIN Cte C ON c.Cliente = V.Cliente
--INNER JOIN MovTipo MT ON MT.Mov = V.Mov And MT.Modulo = 'VTAS' And MT.Clave IN ( 'VTAS.F', 'VTAS.D', 'VTAS.B', 'VTAS.VC_', 'VTAS.DC_')
--INNER JOIN Art A ON A.Articulo = V.Articulo 
--LEFT OUTER JOIN Prov P ON P.Proveedor = A.Proveedor
--LEFT OUTER JOIN ArtUnidad AU ON AU.Articulo = A.Articulo And AU.Unidad = 'PZA'
--WHERE	V.Empresa				IN (Select Empresa From #Empresa)
--	And V.Mov				!= 'Factura JD'
--	And V.FechaEmision		BETWEEN @FechaInicio and @FechaFinal
--	And V.Estatus = 'CANCELADO'
--	And DATEDIFF(MONTH,V.FechaEmision,V2.FechaCancelacion) > 0
--	And ISNULL(V.Unidad,'')	NOT IN ('LT', 'KG', 'PZA', 'SR', 'M3' ,'MILL')
--GROUP BY V.Id
--		,V.RenglonId
--		,LTRIM(RTRIM(V.Mov))
--		,LTRIM(RTRIM(V.MovId))
--		,MT.Clave
--		,V.Empresa
--		,S.Sucursal
--		,S.Nombre
--		,V.FechaEmision
--		,V.FechaRequerida
--		,Alm.Almacen
--		,Alm.Nombre
--		,C.Cliente
--		,C.Nombre
--		,C.RFC
--		,ISNULL(C.NombreCorto, '')
--		,S.Estado
--		,ISNULL(C.Familia,'')
--		,ISNULL(C.Grupo, '')
--		,ISNULL(C.Rama, '')
--		,ISNULL(V.Agente, '')
--		,V.RenglonId
--		,V.RenglonTipo
--		,V.Articulo
--		,A.Descripcion1
--		,(ISNULL(V.Cantidad,0.00))
--		,V.Unidad
--		,V.Cantidad
--		,ISNULL(V.CantidadInventario, V.Cantidad)
--		,V.Factor
--		,V.Unidad
--		,V.Precio
--		,ISNULL(V.TipoCambio,1.00)
--		,ISNULL(V.Impuesto1, 0)
--		,ISNULL(V.Impuesto2, 0)
--		,ISNULL(V.Impuesto3, 0)
--		,A.MonedaCosto
--		,ISNULL(A.Categoria, '')
--		,ISNULL(A.Familia, '')
--		,ISNULL(A.Grupo, '')
--		,A.Linea
--		,ISNULL(A.Rama, '')
--		,V.Moneda
--		,V.TipoCambio
--		,C.Tipo
--		,ISNULL(V.DescuentoLinea,0.00)sele
--		,ISNULL(V.DescuentoLineal,0.00)
--		,A.Articulo
--ORDER BY V.Empresa, V.Id, V.RenglonID

/******AQUI***************/


/************************************************************************************************************/
--select * from #ReporteVenta WHERE articulo IN('DL00200068','dl00200069','dl00200889')

UPDATE	R
SET		R.Costo_Total		=	CASE R.UM	WHEN 'M3' THEN R.Costo_Total
											--WHEN 'MILL' THEN R.Costo_Total
											ELSE (R.Costo_Unitario*R.Cantidad/R.Factor) 
								END
		,R.Precio			=	CASE R.UM	WHEN 'MILL' THEN ISNULL((R.Precio/R.Factor), 0.00)
											ELSE ISNULL(R.Precio, 0.00)
								END
		,R.Costo_Unitario	=	CASE R.UM	WHEN 'MILL' THEN ISNULL((R.Costo_Unitario/R.Factor), 0.00)
											ELSE ISNULL(R.Costo_Unitario, 0.00)
								END
		,R.SubTotal			=	CASE R.UM	WHEN 'M3' THEN ISNULL(R.SubTotal, 0.00)
											--WHEN 'MILL' THEN ISNULL(R.SubTotal, 0.00)
											--WHEN 'MILL' THEN ISNULL((R.Precio*(R.Cantidad/R.Factor)), 0.00)
											ELSE ISNULL((R.Precio*(R.Cantidad/R.Factor)), 0.00)
								END
		,R.Impuesto1Total	=	CASE R.UM	WHEN 'M3' THEN ISNULL(R.Impuesto1Total, 0.00)
										--WHEN 'MILL' THEN ISNULL(R.Impuesto1Total, 0.00)
										WHEN 'MILL' THEN ISNULL(R.Impuesto1Total/R.Factor, 0.00)
										ELSE R.Impuesto1Total
								END
		,R.Impuesto2Total	=	CASE R.UM	WHEN 'M3' THEN ISNULL(R.Impuesto2Total, 0.00)
										--WHEN 'MILL' THEN ISNULL(R.Impuesto2Total, 0.00)
										WHEN 'MILL' THEN ISNULL(R.Impuesto2Total/R.Factor, 0.00)
										ELSE R.Impuesto2Total
								END
		,R.Impuesto3Total		= R.CantidadInventario*R.Porcentaje_IEPS_Cuota
FROM	#ReporteVenta R


UPDATE	#ReporteVenta
SET		CostoProduccion				= 0.00
		,CostoProduccionUnitario	= 0.00
		,CostoInicial				= 0.00
		,CostoInicialUnitario		= 0.00
		,IdCompraInicial			= 0.00
		,CostoReposicionUnitario	= 0.00
		,CostoReposicion			= 0.00

UPDATE #ReporteVenta SET ImporteTotal = SubTotal + Impuesto1Total + Impuesto2Total
--Etapa2

--Descuento Lineal
UPDATE	#ReporteVenta
SET		DescuentoLineal = (Cantidad*Precio) * ((DescuentoLinea/100.00))
		,Impuesto2Total	= ((Cantidad*Precio) * (1-(DescuentoLinea/100.00))) * (Porcentaje_IEPS/100.00)
		,Impuesto1Total	= (((Cantidad*Precio) * (1-(DescuentoLinea/100.00))) * (1.00 + (Porcentaje_IEPS/100.00))) * (Porcentaje_IVA/100.00)
		,ImporteTotal	= (Cantidad*Precio) * ((DescuentoLinea/100.00))
					+ ((Cantidad*Precio) * (1-(DescuentoLinea/100.00))) * (Porcentaje_IEPS/100.00)
					+ (((Cantidad*Precio) * (1-(DescuentoLinea/100.00))) * (1.00 + (Porcentaje_IEPS/100.00))) * (Porcentaje_IVA/100.00)
WHERE	DescuentoLinea != 0.00

--validando cantidad y unidad de medida
UPDATE	RV
SET		RV.UM				= 'PZA'
		,RV.Precio			= (RV.Precio / AU.Factor)
		,RV.SubTotal		= ISNULL((RV.Cantidad)*(RV.Precio / AU.Factor), 0.00)
		
		,RV.DescuentoLineal	= (ISNULL((RV.Cantidad)*(RV.Precio / AU.Factor), 0.00)) * ((DescuentoLinea/100.00))
		,RV.Costo_Unitario	= (RV.Costo_Unitario / AU.Factor)
		,RV.Costo_Total		= (RV.Costo_Unitario / AU.Factor) * (RV.Cantidad)
		,RV.Impuesto2Total	= (((RV.Cantidad)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (Porcentaje_IEPS/100.00)
		,RV.Impuesto1Total	= ((((RV.Cantidad)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (1.00 + (Porcentaje_IEPS/100.00))) * (Porcentaje_IVA/100.00)
		,RV.ImporteTotal	= (RV.Cantidad)*(RV.Precio / AU.Factor)
								+ (((RV.Cantidad)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (Porcentaje_IEPS/100.00)
								+ ((((RV.Cantidad)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (1.00 + (Porcentaje_IEPS/100.00))) * (Porcentaje_IVA/100.00)
FROM	#ReporteVenta RV
INNER JOIN ArtUnidad AU ON AU.Articulo = RV.Articulo And AU.Unidad = RV.UM And AU.Unidad = 'CJ'


--validando cantidad y unidad de medida TAR ( Se queda en tarima'
UPDATE	RV
SET		RV.UM				= 'PZA'
		,RV.Precio			= (RV.Precio / AU.Factor)
		,RV.SubTotal		= ISNULL((RV.CantidadInventario)*(RV.Precio / AU.Factor), 0.00)
		
		,RV.DescuentoLineal	= (ISNULL((RV.Cantidad)*(RV.Precio / AU.Factor), 0.00)) * ((DescuentoLinea/100.00))
		,RV.Costo_Unitario	= (RV.Costo_Unitario / AU.Factor)
		,RV.Costo_Total		= (RV.Costo_Unitario / AU.Factor) * (RV.Cantidad)
		,RV.Impuesto2Total	= (((RV.CantidadInventario)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (Porcentaje_IEPS/100.00)
		,RV.Impuesto1Total	= ((((RV.CantidadInventario)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (1.00 + (Porcentaje_IEPS/100.00))) * (Porcentaje_IVA/100.00)
		,RV.ImporteTotal	= (RV.CantidadInventario)*(RV.Precio / AU.Factor)
								+ (((RV.CantidadInventario)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (Porcentaje_IEPS/100.00)
								+ ((((RV.CantidadInventario)*(RV.Precio / AU.Factor))*(1-(RV.DescuentoLinea/100.00))) * (1.00 + (Porcentaje_IEPS/100.00))) * (Porcentaje_IVA/100.00)
FROM	#ReporteVenta RV
INNER JOIN ArtUnidad AU ON AU.Articulo = RV.Articulo And AU.Unidad = RV.UM And AU.Unidad = 'TAR'

UPDATE	RV
SET		RV.ContId			= ISNULL(V.ContId, 0)
		,RV.ImporteTotal	= RV.SubTotal - RV.DescuentoLineal + RV.Impuesto1Total + RV.Impuesto2Total
		,RV.IdProd			= 0
		,RV.IdCompra		= 0
FROM	#ReporteVenta RV
INNER JOIN Venta V ON V.Id = RV.Numero_Orden

UPDATE	R
SET		R.TipoPoliza = C.Mov
		,R.NumeroPoliza	= C.MovId
FROM	#ReporteVenta R
INNER JOIN Cont C ON C.Empresa = R.Empresa And C.OrigenTipo = 'VTAS' And C.Origen = R.Mov And C.OrigenID = R.MovId AND ISNULL(C.MovID,'') <> ''

/***************************************************************************
 * Calculo Impuesto3
 ***************************************************************************/
UPDATE	#ReporteVenta
SET		Impuesto1Total	= (SubTotal + Impuesto3Total)*(Porcentaje_IVA/100.00)
		,ImporteTotal	= SubTotal + ((SubTotal + Impuesto3Total)*(Porcentaje_IVA/100.00)) + Impuesto3Total
WHERE ISNULL(Porcentaje_IEPS_Cuota, 0) != 0


INSERT INTO #ReporteVenta(Numero_Orden, Mov, MovId, Tipo_Orden, Empresa, Sucursal, Nombre_Sucursal, FechaEmision, FechaRequerida, Almacen, Desc_Almacen
		,Numero_Cliente, Nombre_Cliente, RFC_Cliente, NombreCorto, Sucursal_Venta, Familia_Comercial, Cadena_Comercial, Rama
		, Vendedor, Numero_Renglon, RenglonTipo, Articulo, SKU, Desc_Articulo
		,Lote, Propiedades, Cantidad, UM, CantidadSecundaria, CantidadInventario, UMSecundaria, FactorLitros, Precio, Porcentaje_IVA, Porcentaje_IEPS
		,Costo_Unitario, Costo_Total, SubTotal, Impuesto1Total, Impuesto2Total, ImporteTotal, Categoria, Familia, Grupo, Linea, ArticuloRama, ContId
		,ContMov, ContMovId, Estatus, Moneda, TipoCambio, Tipo, IdProd, Produccion, ProduccionId, Planta_Produccion, CostoProduccion
		,CostoProduccionUnitario, IdCompra, Compra, CompraId, Proveedor, NombreProveedor
		,CostoInicial, CostoInicialUnitario, IdCompraInicial, CompraInicial, CompraInicialId
		,CostoReposicion, CostoReposicionUnitario, DescuentoLinea, DescuentoLineal, UltimoCosto,Condicion_Comercial, DescuentoObsequio)
SELECT	C.Id, C.Mov, C.MovId, MT.Clave, C.Empresa, S.Sucursal, S.Nombre as 'Nombre_Sucursal', C.FechaEmision, C.FechaEmision, '' as 'Almacen', '' as 'Desc_Almacen'
		,Cte.Cliente, Cte.Nombre, Cte.RFC, ISNULL(Cte.NombreCorto,''), S.Estado, Cte.Familia, Cte.Grupo, Cte.Rama, '' as 'Vendedor', D.Renglon, 'S' as 'RenglonTipo'
		, 'BONIFICACION' as 'Articulo', 'BONIFICACION' as 'SKU', 'BONIFICACION POR NOTA DE CREDITO' as 'Desc_Articulo'
		, D.AplicaId as 'Lote','' as 'Propiedades', 1 as 'Cantidad', '' as 'UM', 1 as 'CantidadSecundaria', 1 as 'CantidadInventario', '' as 'UMSecundaria', 1 as 'FactorLitros'
		, 0.00 as 'Precio', MI.Impuesto1, MI.Impuesto2, 0.00 as 'Costo_Unitario', 0.00 as 'Costo_Total', ISNULL(MI.SubTotal,0.00)*C.TipoCambio, MI.Importe1, MI.Importe2
		, (ISNULL(MI.Subtotal,0.00) + ISNULL(MI.Importe1,0.00) + ISNULL(MI.Importe2, 0.00))*C.TipoCambio, 'BONIFICACION', 'BONIFICACION', 'BONIFICACION', 'BONIFICACION', 'BONIFICACION'
		, ISNULL(C.ContId,0), '', '', '', C.Moneda, C.TipoCambio, Cte.Tipo, 0, '', '', '', 0.000
		, 0.00, 0, '', '', '', ''
		, 0.00, 0.00, 0, '', ''
		, 0.00, 0.00, 0.00, 0.00, 0.00,ISNULL(C.Condicion,'') as 'Condicion_Venta', 0.00
FROM	CXC C
INNER JOIN CXCD D ON D.Id = C.Id
INNER JOIN CXC CO ON CO.Empresa = C.Empresa And CO.Mov = D.Aplica And CO.MovId = D.AplicaId And CO.OrigenTipo = 'VTAS'
INNER JOIN Venta V ON V.Empresa = C.Empresa And V.Mov = CO.Origen And V.MovId = CO.OrigenId
INNER JOIN MovImpuesto MI ON MI.Modulo = 'CXC' and MI.ModuloId = D.Id And MI.OrigenModulo = 'VTAS' and MI.OrigenModuloId = V.ID
INNER JOIN MovTipo MT ON MT.Modulo = 'CXC' And MT.Mov = C.Mov and MT.Clave LIKE 'CXC.NC' --And V.Mov != 'Factura JD'
INNER JOIN Sucursal S ON S.Sucursal = C.Sucursal
INNER JOIN Cte ON Cte.Cliente = C.Cliente
WHERE	C.Empresa				IN (Select Empresa From #Empresa)
	And C.FechaEmision BETWEEN @FechaInicio and @FechaFinal
	And C.Estatus IN ('PENDIENTE', 'CONCLUIDO')
	And 1 = 2
ORDER BY C.FechaEmision

UPDATE	R
SET		R.TipoPoliza = C.Mov
		,R.NumeroPoliza	= C.MovId
FROM	#ReporteVenta R
INNER JOIN Cont C ON C.Empresa = R.Empresa And C.OrigenTipo = 'CXC' And C.Origen = R.Mov And C.OrigenID = R.MovId AND ISNULL(C.MovID,'') <> ''
WHERE	R.TipoPoliza != ''

UPDATE	#ReporteVenta
SET		Cantidad			= Cantidad * -1.0000
		,CantidadInventario	= ISNULL(CantidadInventario, Cantidad) * -1.0000
		,CantidadSecundaria	= CantidadSecundaria * -1.0000
		,Costo_Unitario		= Costo_Unitario * -1.0000
		,Costo_Total		= Costo_Total * -1.0000
		,SubTotal			= SubTotal * -1.0000
		,Impuesto1Total		= Impuesto1Total * -1.0000
		,Impuesto2Total		= Impuesto2Total * -1.0000
		,Impuesto3Total		= Impuesto3Total * -1.0000
		,ImporteTotal		= ImporteTotal * -1.0000
		,DescuentoLineal	= DescuentoLineal * -1.0000
WHERE	Tipo_Orden IN ('VTAS.D', 'CXC.NC')

UPDATE	#ReporteVenta
SET		Cantidad			= 0.0000
		,CantidadInventario	= 0.0000
		,CantidadSecundaria	= 0.0000
		,Costo_Unitario		= 0.0000
		,Costo_Total		= 0.0000
		,SubTotal			= SubTotal * -1.0000
		,Impuesto1Total		= Impuesto1Total * -1.0000
		,Impuesto2Total		= Impuesto2Total * -1.0000
		,Impuesto3Total		= Impuesto3Total * -1.0000
		,ImporteTotal		= ImporteTotal * -1.0000
		,DescuentoLineal	= DescuentoLineal * -1.0000
WHERE	Tipo_Orden = 'VTAS.B'

UPDATE #ReporteVenta 
SET CantidadSecundaria = 0.0000
	,UMSecundaria = ''
	,FactorLitros = 0.0000 

/*Corrigiendo UMSecundaria de Kg*/
UPDATE	#ReporteVenta
SET		UMSecundaria		= UM
		,CantidadSecundaria	= Cantidad
WHERE	UM = 'KG'

--Conversion de Millares a Piezas
UPDATE	P
SET		CantidadSecundaria	= Cantidad
		,UMSecundaria		= 'MILL'
		,UM					= 'PZA'
		,Cantidad			= Cantidad*1000.000
FROM	#ReporteVenta P
WHERE	P.UM = 'MILL'
	And P.Empresa = 'REMSA'

UPDATE	P
SET		CantidadSecundaria	= Cantidad/1000.00
		,UMSecundaria		= 'MILL'
		,UM					= 'PZA'
		,Cantidad			= Cantidad
FROM	#ReporteVenta P
WHERE	P.UM = 'MILL'
	And P.Empresa != 'REMSA'

--Conversion de M3
UPDATE	P
SET		CantidadSecundaria	= CantidadInventario
		,FactorLitros		= 1000
		,UMSecundaria		= 'LT'
FROM	#ReporteVenta P
WHERE	P.UM = 'M3'


--Conversion de PZA a Litros
UPDATE	#ReporteVenta
SET		FactorLitros		= 1.0000
		,CantidadSecundaria	= Cantidad
		,UMSecundaria		= UM
WHERE UM = 'LT'

UPDATE	P
SET		CantidadSecundaria	= Cantidad * ISNULL(ROUND(1.000/AU.Factor,2), 0.0000)
		,UMSecundaria		= 'LT'
		,FactorLitros		= ISNULL(ROUND(1.000/AU.Factor,2), 0.0000)
FROM	#ReporteVenta P
INNER JOIN ArtUnidad AU ON AU.Articulo = P.Articulo And AU.Unidad = 'LT'
WHERE	P.UM = 'PZA'

--Conversion de CJ a Litros
UPDATE	P
SET		CantidadSecundaria	= CantidadInventario * ISNULL(ROUND(1.000/AU.Factor,2), 0.0000)
		,UMSecundaria		= 'LT'
		,FactorLitros		= ISNULL(ROUND(1.000/AU.Factor,2), 0.0000)
FROM	#ReporteVenta P
INNER JOIN ArtUnidad AU ON AU.Articulo = P.Articulo And AU.Unidad = 'LT'
WHERE	P.UM = 'CJ'

UPDATE	RV
SET		RV.ContMov		= ISNULL(C.Mov, '')
		,RV.ContMovId	= ISNULL(C.MovId, '')
		,RV.Estatus		= ISNULL(C.Estatus, 'SINAFECTAR')
FROM	#ReporteVenta RV
LEFT OUTER JOIN Cont C ON C.Id = RV.ContId

--Produccion
--SELECT DISTINCT RV.Numero_Orden, RV.Numero_Renglon, RV.Lote, PO.Id, PO.Mov, PO.MovId, PO.Almacen, RV.Articulo, PPM.AlmacenOrigen
SELECT	DISTINCT RV.Numero_Orden, RV.Numero_Renglon, RV.Lote, RV.Propiedades, P.Id, P.Mov, P.MovId, P.Almacen, RV.Articulo, PPM.AlmacenOrigen
	,CASE ISNULL(PPM.AlmacenOrigen, '') WHEN 'UMAN01'	THEN 'PLANTA DELLI'
										WHEN 'UMAN02'	THEN 'PLANTA DELSOL'
										WHEN 'UMAN04'	THEN 'PLANTA DELLI'
										WHEN 'UMAN05'	THEN 'PLANTA DELSOL'
										WHEN 'H2O01'	THEN 'PLANTA H2O'
										WHEN 'H2O02'	THEN 'PLANTA H2O'
										WHEN 'H2O09'	THEN 'PLANTA H2O'
										WHEN 'H2O10'	THEN 'PLANTA H2O'
										WHEN 'IZA01'	THEN 'PLANTA IZAMAL'
										WHEN 'IZA02'	THEN 'PLANTA IZAMAL'
										WHEN 'IZA03'	THEN 'PLANTA IZAMAL'
										WHEN 'IZA09'	THEN 'PLANTA IZAMAL'
										WHEN 'MAQ01'	THEN 'PLANTA MASE'
										WHEN 'MAQ02'	THEN 'PLANTA MASE'
										WHEN 'MGNPRO'	THEN 'PLANTA MORGAN'
										WHEN 'MGNMP'	THEN 'PLANTA MORGAN'
										WHEN 'MGNPT'	THEN 'PLANTA MORGAN'
										WHEN 'MAQ_DESP'	THEN 'MAQUILA'
										WHEN 'MAQ_MP'	THEN 'MAQUILA'
										WHEN 'MAQ_PRO'	THEN 'MAQUILA'
										WHEN 'MAQ_PT'	THEN 'MAQUILA'
										WHEN 'LAT_PT'	THEN 'LATITUD'
										WHEN 'LATPRO'		THEN 'LATITUD'
										WHEN 'LATPOSTPRO'	THEN 'LATITUD'
										WHEN 'LATMP'		THEN 'LATITUD'
										WHEN 'LATGAUSA'		THEN 'LATITUD'
										WHEN 'LATAGUAPOT'	THEN 'LATITUD'
										WHEN 'LATAGUAPUR'	THEN 'LATITUD'
										WHEN 'LATAGUASAL'	THEN 'LATITUD'
										WHEN 'MAQ_PT'		THEN 'MAQUILA'
									END as 'Planta_Produccion'
	,(Select Alm.Nombre From Alm where Alm.Almacen = PPM.AlmacenOrigen) as 'Almacen_Nombre'
INTO	#Planta_Produccion
FROM	#ReporteVenta RV
LEFT OUTER JOIN SerieLoteMov SLM ON SLM.Modulo = 'PROD' and SLM.Articulo = RV.Articulo And SLM.SerieLote = RV.Lote
INNER JOIN Prod P ON P.Id = SLM.Id and P.Mov = 'Entrada Produccion' And P.Estatus IN ('PENDIENTE', 'CONCLUIDO') And P.OrigenTipo = 'PROD'
INNER JOIN Prod PO ON PO.Empresa = P.Empresa And PO.Mov = P.Origen And PO.MovId = P.OrigenId and PO.Estatus IN ('PENDIENTE', 'CONCLUIDO')
INNER JOIN ProdProgramaMaterial PPM ON PPM.Id = PO.Id

UPDATE	RV
SET		RV.IdProd				= PP.Id
		,RV.Produccion			= PP.Mov
		,RV.ProduccionId		= PP.MovId
		,RV.Planta_Produccion	= ISNULL(PP.Planta_Produccion, '')
FROM	#ReporteVenta RV
INNER JOIN #Planta_Produccion PP ON PP.Numero_Orden = RV.Numero_Orden And PP.Numero_Renglon = RV.Numero_Renglon And PP.Articulo = RV.Articulo

--Identificar compra si no ha tenido produccion
SELECT	RV.Empresa, RV.Numero_Orden, RV.Numero_Renglon, RV.Lote, RV.Articulo, MIN(C.Id) as 'IdCompra'
INTO	#Compra_Articulo
FROM	#ReporteVenta RV
INNER JOIN SerieLoteMov SLM ON SLM.Modulo = 'COMS' and SLM.Articulo = RV.Articulo And SLM.SerieLote = RV.Lote
INNER JOIN Compra C ON C.Id = SLM.Id And C.Estatus IN ('PENDIENTE', 'CONCLUIDO') 
INNER JOIN MovTipo MT ON MT.Modulo = 'COMS' And MT.Mov = C.Mov and MT.Clave IN ('COMS.F', 'COMS.EG', 'COMS.EI')
WHERE	RV.IdProd = 0
GROUP BY RV.Empresa, RV.Numero_Orden, RV.Numero_Renglon, RV.Lote, RV.Articulo

UPDATE	RV
SET		RV.IdCompra			= CA.IdCompra
		,RV.Compra			= C.Mov
		,RV.CompraId		= C.MovId
		,RV.Proveedor		= P.Proveedor
		,RV.NombreProveedor	= P.Nombre
		--,RV.NombreCorto		= P.NombreCorto
FROM	#ReporteVenta RV
INNER JOIN #Compra_Articulo CA ON CA.Empresa = RV.Empresa And CA.Numero_Orden = RV.Numero_Orden And CA.Numero_Renglon = RV.Numero_Renglon
	And CA.Articulo = RV.Articulo
INNER JOIN Compra C ON C.Id = CA.IdCompra
INNER JOIN Prov P ON P.Proveedor = C.Proveedor

--Actualizacion Costos
UPDATE	RV
SET		CostoProduccionUnitario = ISNULL(D.Costo, 0.0)
		,CostoProduccion		= ISNULL(D.Costo,0.00) * RV.Cantidad
FROM	#ReporteVenta RV
INNER JOIN Prod P ON P.Id = RV.IdProd
INNER JOIN ProdD D ON D.Id = P.Id And D.Articulo = RV.Articulo
WHERE	IdProd > 0

--Actualizacion Compra
--UPDATE	RV
--SET		RV.CostoProduccionUnitario	= CONVERT(NUMERIC(15,4),D.Costo)
--		,RV.CostoProduccion			= CONVERT(NUMERIC(15,4),D.Costo * RV.Cantidad)
--FROM	#ReporteVenta RV
--INNER JOIN CompraD D ON D.Id = RV.IdCompra And D.Articulo = RV.Articulo
--WHERE RV.IdCompra > 0

--Compra Inicial
UPDATE	RV
SET		RV.IdCompraInicial			= C.Id
		,RV.CompraInicial			= C.Mov
		,RV.CompraInicialId			= C.MovId
		,RV.CostoInicialUnitario	= D.Costo
		,RV.CostoInicial			= D.Costo * RV.Cantidad
FROM	#ReporteVenta RV
INNER JOIN Compra C ON C.Empresa = RV.Empresa and C.Mov = 'Entrada Compra' And C.Usuario IN ('JCARRILLO', 'CONSULTOR', '_CONSULTOR') And RV.Sucursal = C.Sucursal
	And C.FechaEmision BETWEEN '20200720' and '20201001' And C.Estatus = 'CONCLUIDO'
INNER JOIN CompraD D ON D.Id = C.Id And D.Articulo = RV.Articulo

UPDATE	RV
SET		RV.IdCompraInicial			= C.Id
		,RV.CompraInicial			= C.Mov
		,RV.CompraInicialId			= C.MovId
		,RV.CostoInicialUnitario	= D.Costo
		,RV.CostoInicial			= D.Costo * RV.Cantidad
FROM	#ReporteVenta RV
INNER JOIN Compra C ON C.Empresa = RV.Empresa and C.Mov = 'Entrada Compra' And C.Usuario IN ('JCARRILLO', 'CONSULTOR', '_CONSULTOR') And RV.Sucursal != C.Sucursal
	And C.FechaEmision BETWEEN '20200720' and '20201001' And C.Estatus = 'CONCLUIDO' 
INNER JOIN CompraD D ON D.Id = C.Id And D.Articulo = RV.Articulo
WHERE ISNULL(RV.CostoInicial,0.00) = 0.00

UPDATE #ReporteVenta SET CostoReposicionUnitario = CostoProduccionUnitario, CostoReposicion = CostoProduccion	WHERE ISNULL(CostoProduccionUnitario,0)!=0 And ISNULL(CostoReposicionUnitario, 0) = 0.00
UPDATE #ReporteVenta SET CostoReposicionUnitario = CostoInicialUnitario, CostoReposicion = CostoInicial			WHERE ISNULL(CostoInicialUnitario,0)!=0 And ISNULL(CostoReposicionUnitario, 0) = 0.00
UPDATE #ReporteVenta SET CostoReposicionUnitario = Costo_Unitario, CostoReposicion = ISNULL(Costo_Total,0.00)	WHERE ISNULL(Costo_Unitario,0)!=0 And ISNULL(CostoReposicionUnitario, 0) = 0.00

/********************************************************************************************************
 Fase 2 Identificar compra si no ha tenido produccion (Saldo inicial)
 *******************************************************************************************************/
SELECT	RV.Empresa, RV.Numero_Orden, RV.Numero_Renglon, RV.Lote, RV.Articulo, MIN(C.Id) as 'IdInventario', MT.Clave
INTO	#Inventario_Articulo
FROM	#ReporteVenta RV
INNER JOIN SerieLoteMov SLM ON SLM.Modulo = 'INV' and SLM.Articulo = RV.Articulo And SLM.SerieLote = RV.Lote
INNER JOIN Inv C ON C.Id = SLM.Id And C.Estatus IN ('CONCLUIDO') 
INNER JOIN MovTipo MT ON MT.Modulo = 'INV' And MT.Mov = C.Mov and MT.Clave IN ('INV.E')
WHERE	RV.IdProd = 0 And RV.CostoProduccionUnitario = 0
GROUP BY RV.Empresa, RV.Numero_Orden, RV.Numero_Renglon, RV.Lote, RV.Articulo, MT.Clave

UPDATE #ReporteVenta SET IdCompraInicial = 0, CompraInicial = '', CompraInicialId = '', CostoInicialUnitario = 000.0000, CostoInicial = 0.0000

UPDATE	RV
SET		RV.IdCompraInicial		= CA.IdInventario
		,RV.CompraInicial		= C.Mov
		,RV.CompraInicialId		= C.MovId
FROM	#ReporteVenta RV
INNER JOIN #Inventario_Articulo CA ON CA.Empresa = RV.Empresa And CA.Numero_Orden = RV.Numero_Orden And CA.Numero_Renglon = RV.Numero_Renglon
	And CA.Articulo = RV.Articulo
INNER JOIN Inv C ON C.Id = CA.IdInventario
WHERE	RV.IdProd = 0

UPDATE	RV
SET		RV.CostoProduccionUnitario = D.Costo
		,RV.CostoProduccion			= CONVERT(NUMERIC(15,4),D.Costo*RV.Cantidad)
FROM	#ReporteVenta RV
INNER JOIN Inv C ON C.Id = RV.IdCompraInicial
INNER JOIN InvD D ON D.Id = C.Id And D.Articulo = RV.Articulo
WHERE ISNULL(RV.CostoProduccionUnitario,0.00) = 0.00
	And IdCompraInicial != 0

UPDATE #ReporteVenta SET CostoReposicionUnitario = CostoProduccionUnitario, CostoReposicion = ISNULL(CostoProduccion,0.00)	WHERE ISNULL(Costo_Unitario,0)!=0 And ISNULL(CostoProduccionUnitario, 0) = 0.00
UPDATE #ReporteVenta SET FechaRequerida = FechaEmision WHERE FechaRequerida IS NULL
UPDATE #ReporteVenta SET SKU = REPLACE(REPLACE(REPLACE(REPLACE(SKU, 'DLS',''), 'RM', ''), 'MG', ''), 'DL', '')
UPDATE #ReporteVenta SET SKU = CONVERT(VARCHAR,CONVERT(INT,SKU)) WHERE ISNUMERIC(SKU)=1

UPDATE	#ReporteVenta
SET		Cantidad			= 0
		,CantidadSecundaria = 0
		,CantidadInventario	= 0
WHERE	RenglonTipo = 'J'

UPDATE	#ReporteVenta
SET		CantidadSecundaria	= Cantidad
		,UMSecundaria		= UM
WHERE	Articulo = 'DL00003158'

UPDATE	#ReporteVenta
SET		CantidadSecundaria	= Cantidad
		,UMSecundaria		= UM
WHERE	Empresa = 'VELSA'

/********************************************************************************************************************
 * Llenando delli.webVentaImporteXEmpresa
 ********************************************************************************************************************/
--------INSERT INTO delli.webVentaImporteXEmpresa(Numero_Orden, Numero_Renglon
--------		,Partida
--------		,RenglonTipo,Articulo, SKU, Desc_Articulo, Mov, MovId, Tipo_Orden, Empresa, Sucursal, Nombre_Sucursal
--------		,FechaEmision, Almacen, Desc_Almacen, Numero_Cliente, Nombre_Cliente, RFC_Cliente, NombreCorto, Sucursal_Venta, Familia_Comercial, Cadena_Comercial
--------		,Vendedor, Lote, Cantidad, UM, CantidadSecundaria, CantidadInventario, Factor, UMSecundaria, FactorLitros, Precio, Porcentaje_IVA, Porcentaje_IEPS
--------		,Costo_Unitario, Costo_Total, SubTotal, Impuesto1Total, Impuesto2Total, ImporteTotal, Categoria, Familia, Grupo, Linea, ContId, ContMov, ContMovId
--------		,Estatus, Moneda, TipoCambio, Tipo, IdProd, Produccion, ProduccionId, Planta_Produccion, DescuentoLinea, DescuentoLineal)
--------SELECT	Numero_Orden, Numero_Renglon
--------		,ROW_NUMBER() OVER(PARTITION BY Numero_Orden ORDER BY Numero_Orden, Numero_Renglon)
--------		, RenglonTipo, Articulo, SKU, Desc_Articulo, Mov, MovId, Tipo_Orden, Empresa, Sucursal, Nombre_Sucursal
--------		,FechaEmision, Almacen, Desc_Almacen, Numero_Cliente, Nombre_Cliente, RFC_Cliente, NombreCorto, Sucursal_Venta, Familia_Comercial, Cadena_Comercial
--------		,Vendedor, Lote, Cantidad, UM, CantidadSecundaria, ISNULL(CantidadInventario, Cantidad), Factor, UMSecundaria, FactorLitros, Precio, Porcentaje_IVA, Porcentaje_IEPS
--------		,Costo_Unitario, Costo_Total, SubTotal, Impuesto1Total, Impuesto2Total, ImporteTotal, Categoria, Familia, Grupo, ISNULL(Linea, 'SIN_LINEA'), ContId, ContMov, ContMovId
--------		,Estatus, Moneda, TipoCambio, Tipo, IdProd, Produccion, ProduccionId, Planta_Produccion, DescuentoLinea, DescuentoLineal
--------FROM	#ReporteVenta
--------ORDER BY Numero_Orden, Numero_Renglon

/********************************************************************************************************************
 * Actualizando Costo Produccion
 ********************************************************************************************************************/
UPDATE	#ReporteVenta
SET		CostoProduccionUnitario		= UltimoCosto
		,CostoProduccion			= UltimoCosto * Cantidad
WHERE	ISNULL(UltimoCosto, 0.00) > 0.00
	And ISNULL(CostoProduccionUnitario, 0.00) = 0.00

/********************************************************************************************************************
 * Desplegando reporte
 ********************************************************************************************************************/

--SELECT	Numero_Orden, Mov, MovId, FechaEmision, Articulo, Cantidad, UM, CantidadInventario, Factor, Precio, SubTotal, Costo_Total, Impuesto1Total
--FROM	#ReporteVenta
--WHERE	Mov = 'Factura PUE' and MovId = 'PREM109' and Articulo = 'RM00010290'
---SELECT 8319 - 8319
UPDATE	RV
SET		RV.UUID = ISNULL(CONVERT(VARCHAR(36),CFD.UUID), '')
FROM	#ReporteVenta RV
INNER JOIN CFD ON CFD.Empresa = RV.Empresa And CFD.Modulo = 'VTAS' And CFD.ModuloId = RV.Numero_Orden
WHERE	RV.Tipo_Orden LIKE 'VTAS.%'

UPDATE	RV
SET		RV.UUID = ISNULL(CONVERT(VARCHAR(36),CFD.UUID), '')
FROM	#ReporteVenta RV
INNER JOIN CFD ON CFD.Empresa = RV.Empresa And CFD.Modulo = 'CXC' And CFD.ModuloId = RV.Numero_Orden
WHERE	RV.Tipo_Orden LIKE 'CXC.%'

/********************************************************************************************************************
 * Polizas Manual
 *******************************************************************************************************************/
INSERT INTO #ReporteVenta(Numero_Orden, Mov, MovId, Tipo_Orden, Empresa, Sucursal, Nombre_Sucursal, FechaEmision, FechaRequerida, Almacen, Desc_Almacen
		,Numero_Cliente, Nombre_Cliente, RFC_Cliente, NombreCorto, Sucursal_Venta, Familia_Comercial, Cadena_Comercial, Rama
		,Vendedor, Numero_Renglon, RenglonTipo, Articulo, SKU, Desc_Articulo
		,Lote, Propiedades, Cantidad, UM, CantidadSecundaria, CantidadInventario, UMSecundaria,FactorLitros, Precio, Porcentaje_IVA, Porcentaje_IEPS
		,Costo_Unitario, Costo_Total, SubTotal, Impuesto1Total, Impuesto2Total, ImporteTotal, Categoria, Familia, Grupo, Linea, ArticuloRama, ContId
		,ContMov, ContMovId, Estatus, Moneda, TipoCambio, Tipo, IdProd, Produccion, ProduccionId, Planta_Produccion, CostoProduccion
		,CostoProduccionUnitario, IdCompra, Compra, CompraId, Proveedor, NombreProveedor
		,CostoReposicion, CostoReposicionUnitario, DescuentoLinea, DescuentoLineal, UltimoCosto,Condicion_Comercial
		,IdCompraInicial, DescuentoObsequio
		)
SELECT	C.ID, C.Mov, C.MovID, MT.Clave, C.Empresa, S.Sucursal, S.Nombre, C.FechaEmision, C.FechaEmision, '', ''
		,E.Empresa, E.Empresa, E.Empresa, E.Empresa, C.Sucursal, 'OTROS','OTROS', 'CLNA'
		,'', MIN(D.Renglon), 'L', D.Cuenta, D.Cuenta, D.Cuenta
		,D.Cuenta, '', 1, 'SR', 1, 1, 'SR', 1, 0.00, 0.00, 0.00
		,SUM(Debe), SUM(Debe), 0.00, 0.00, 0.00, 0.00, 'OTROS', 'OTROS', 'OTROS', 'OTROS', 'PT', C.ID
		,C.Mov, C.MovID, C.Estatus, C.Moneda, 1.000, 'Cliente', 0, '', '', '', SUM(Debe)
		,SUM(Debe), 0, '', '', '',''
		,SUM(Debe), SUM(Debe), 0.00, 0.00, SUM(Debe), ''
		,0
		,0.00
FROM	Cont C
INNER JOIN #Empresa E ON E.Empresa = C.Empresa
INNER JOIN MovTipo MT ON MT.Modulo = 'CONT' and MT.Mov = C.Mov
INNER JOIN Sucursal S ON S.Sucursal = C.Sucursal
INNER JOIN ContD D ON D.Id = C.Id And D.Cuenta LIKE '5__-___-___' And ISNULL(Debe, 0.00)!=0.00
WHERE	C.FechaEmision BETWEEN @FechaInicio And @FechaFinal
--WHERE	C.FechaEmision BETWEEN '20230401' And '20230430'
	And C.Mov = 'Diario Manual'
	And C.Estatus = 'CONCLUIDO'
GROUP BY C.ID, C.Mov, C.MovID, MT.Clave, C.Empresa, S.Sucursal, S.Nombre, C.FechaEmision, C.FechaEmision
	,E.Empresa, E.Empresa, E.Empresa, E.Empresa, C.Sucursal
	,D.Cuenta, D.Cuenta, D.Cuenta, C.Estatus, C.Moneda

UPDATE	RV
SET		RV.DescuentoObsequio = ISNULL(DO.DescuentoUnitario, 0.00) * ISNULL(DO.CantidadObsequio, 0.00)
FROM	#ReporteVenta RV
INNER JOIN (
			SELECT	Numero_Orden, Mov, MovId, Numero_Renglon
					, SUM(R.Cantidad)								as 'Cantidad'
					, AVG(R.DescuentoObsequio)						as 'DescuentoObsequio'
					, AVG(R.DescuentoObsequio)/D.CantidadObsequio	as 'DescuentoUnitario'
					, (D.CantidadObsequio/COUNT(R.Numero_Renglon))	as 'CantidadObsequio'
			FROM	#ReporteVenta R
			INNER JOIN VentaD D ON D.Id = R.Numero_Orden AND R.Articulo = D.Articulo AND D.RenglonID = R.Numero_Renglon
			--WHERE	MovID = 'FHUA3132'
			WHERE	ISNULL(DescuentoObsequio, 0.00) != 0.00
			GROUP BY Numero_Orden, Mov, MovId, Numero_Renglon,D.CantidadObsequio
			) DO ON DO.Numero_Orden = RV.Numero_Orden and DO.Numero_Renglon = RV.Numero_Renglon

UPDATE	#ReporteVenta
SET		DescuentoLineal		= DescuentoLineal + DescuentoObsequio
WHERE DescuentoObsequio > 0

UPDATE	RV
SET		RV.Impuesto2Total	= (SubTotal-DescuentoLineal)* (ISNULL(A.Impuesto2,0.00)/100.00)
		,RV.Impuesto1Total	= ((SubTotal-DescuentoLineal)* (1-00+(ISNULL(A.Impuesto2,0.00)/100.00)))*(ISNULL(A.Impuesto1,0.00)/100.00)
FROM	#ReporteVenta RV
INNER JOIN Art A ON A.Articulo = RV.Articulo
WHERE RV.DescuentoObsequio != 0.00

UPDATE	RV
SET		RV.ImporteTotal	= (SubTotal-DescuentoLineal)+Impuesto1Total+Impuesto2Total
FROM	#ReporteVenta RV
INNER JOIN Art A ON A.Articulo = RV.Articulo
WHERE RV.DescuentoObsequio != 0.00

UPDATE	RV
SET		RV.FechaPedimento = C.FechaEmision
FROM	#ReporteVenta RV
INNER JOIN SerieLoteMov SLM ON SLM.Empresa = RV.Empresa And SLM.Modulo = 'COMS' and SLM.Articulo = RV.Articulo and SLM.Propiedades = RV.Propiedades
INNER JOIN Compra C ON C.Id = SLM.Id And C.Estatus IN ('CONCLUIDO')
INNER JOIN MovTipo MT ON MT.Modulo = 'COMS' and MT.Mov = C.Mov and MT.Clave IN ('COMS.EI')--, 'COMS.F', 'COMS.EG'

IF @Reconstruir = 0 BEGIN
	CREATE TABLE #tbVentasAgrupadas(
		Numero_Orden			INT  NOT NULL DEFAULT(0)
		,FechaEmision			DATETIME NOT NULL
		,Empresa				VARCHAR(5) NOT NULL DEFAULT('')
		,Numero_Cliente			VARCHAR(20) NOT NULL DEFAULT('')
		,Nombre_Cliente			VARCHAR(100) NOT NULL DEFAULT('')
		,Rama					VARCHAR(50) NOT NULL DEFAULT('')
		,Tipo					VARCHAR(50) NOT NULL DEFAULT('')
		,Articulo				VARCHAR(20) NOT NULL DEFAULT('')
		,Desc_Articulo			VARCHAR(100) NOT NULL DEFAULT('')
		,Cantidad				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,Precio					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,SubTotal				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,IVA					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,IEPS					NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,IEPS_Cuota				NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,Importe_Total			NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,Costo_Unitario			NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,Costo_Total			NUMERIC(15,4) NOT NULL DEFAULT(0.00)
		,Linea					VARCHAR(50) NOT NULL DEFAULT('')
		,Modulo					VARCHAR(50) NOT NULL DEFAULT('')
	)

	INSERT INTO #tbVentasAgrupadas(Numero_Orden, FechaEmision, Empresa, Numero_Cliente, Nombre_Cliente, Rama, Tipo, Articulo, Desc_Articulo, Cantidad
									,Precio, SubTotal, IVA, IEPS, IEPS_Cuota, Importe_Total, Costo_Unitario, Costo_Total
									, Linea, Modulo)
	SELECT	MIN(RV.Numero_Orden)															as 'Numero_Orden'
			,CONVERT(DATETIME,(SUBSTRING(CONVERT(VARCHAR,RV.FechaEmision,112),1,6)+'01'))	as 'FechaEmision'
			,RV.Empresa																		as 'Empresa'
			,RV.Numero_Cliente																as 'Numero_Cliente'
			,REPLACE(REPLACE(RV.Nombre_Cliente, '"', ''), '''', '')							as 'Nombre_Cliente'
			,RV.Rama
			,RV.Tipo
			,RV.Articulo
			,RV.Desc_Articulo
			,SUM(RV.Cantidad)																as 'Cantidad'
			,SUM(RV.Precio)																	as 'Precio'
			,SUM(RV.SubTotal)																as 'SubTotal'
			,RV.Impuesto1Total																as 'IVA'
			,RV.Impuesto2Total																as 'IEPS'
			,RV.Impuesto3Total																as 'IEPS_Cuota'
			,SUM(RV.ImporteTotal)															as 'ImporteTotal'
			,AVG(RV.Costo_Unitario)															as 'Costo_Unitario'
			,SUM(RV.Costo_Total)															as 'Costo_Total'
			,RV.Linea																		as 'Linea'
			,A.Modulo																		as 'Modulo'
	FROM	#ReporteVenta RV
	INNER JOIN Cte C ON C.Cliente = RV.Numero_Cliente
	INNER JOIN #tbArticulo A ON A.Articulo = RV.Articulo
	GROUP BY CONVERT(DATETIME,(SUBSTRING(CONVERT(VARCHAR,RV.FechaEmision,112),1,6)+'01')), Empresa
			,RV.Numero_Cliente
			,REPLACE(REPLACE(RV.Nombre_Cliente, '"', ''), '''', '')
			,RV.Rama
			,RV.Tipo
			,RV.Articulo
			,RV.Desc_Articulo
			,RV.Impuesto1Total
			,RV.Impuesto2Total
			,RV.Impuesto3Total
			,RV.Linea
			,A.Modulo
	ORDER BY MIN(RV.Numero_Orden)

	SELECT	*
	FROM	#tbVentasAgrupadas
	--where	Articulo = 'DL000068'
	--ORDER BY FechaEmision
	--select * from Art where Articulo = 'DL00000068'

	--SELECT	FechaEmision, Articulo, SUM(Cantidad) as 'Cantidad', SUM(Costo_Total) as 'Costo'
	--FROM	#tbVentasAgrupadas
	--WHERE	Articulo = 'DL00003022'
	--	And DATEPART(YEAR,FechaEmision)=2024
	--GROUP BY FechaEmision, Articulo
	--ORDER BY FechaEmision


	DROP TABLE #tbVentasAgrupadas
END
ELSE BEGIN
	INSERT INTO ia_assistance.dbo.VentaImporteXEmpresa(Empresa, Numero_Cliente, Nombre_Cliente, NombreCorto, Familia_Comercial, Cadena_Comercial, Cliente_Rama, Cliente_Tipo
														, Mov, MovId, SKU, Lote, Pedimento, Articulo, Desc_Articulo, Cantidad, UM, CantidadSecundaria, UMSecundaria, FactorLitros
														, Precio, SubTotal, DescuentoLineal, Impuesto1Total, Impuesto2Total, Impuesto3Total, ImporteTotal, Costo_Unitario, Costo_Total, CostoProduccionUnitario, CostoProduccion, Planta_Produccion
														, Proveedor, NombreProveedor, Sucursal, Nombre_Sucursal, FechaEmision, FechaRequerida, Almacen
														, Art_Familia, Art_Grupo, Art_Categoria, Art_Linea, Art_Rama, ArticuloRama, UltimoCosto
				)

	SELECT	RV.Empresa
			,RV.Numero_Cliente
			,REPLACE(REPLACE(RV.Nombre_Cliente, '"', ''), '''', '')				as 'Nombre_Cliente'
			,ISNULL(NULLIF(RV.NombreCorto, ''), RV.Nombre_Cliente)				as 'NombreCorto'
			,RV.Familia_Comercial
			,ISNULL(NULLIF(RV.Cadena_Comercial, ''), 'Sin_Cadena_Comercial')	as 'Cadena_Comercial'
			,RV.Rama
			,RV.Tipo
			,RV.Mov
			,RV.MovId
			,RV.SKU
			,RV.Lote
			,RV.Propiedades														as 'Pedimento'
			,RV.Articulo
			,RV.Desc_Articulo
			,RV.Cantidad
			,RV.UM
			,RV.CantidadSecundaria
			,RV.UMSecundaria
			,RV.FactorLitros
			,RV.Precio
			,RV.SubTotal														as 'SubTotal'
			,RV.DescuentoLineal													as 'DescuentoLineal'
			,RV.Impuesto1Total													as 'IVA'
			,RV.Impuesto2Total													as 'IEPS'
			,RV.Impuesto3Total													as 'IEPS_Cuota'
			,RV.ImporteTotal													as 'ImporteTotal'
			,RV.Costo_Unitario
			,RV.Costo_Total
			,RV.CostoProduccionUnitario
			,RV.CostoProduccion
			,RV.Planta_Produccion
			,RV.Proveedor
			,RV.NombreProveedor
			,RV.Sucursal
			,RV.Nombre_Sucursal
			,RV.FechaEmision
			,RV.FechaRequerida
			,RV.Almacen
			,RV.Familia
			,RV.Grupo
			,RV.Categoria
			,RV.Linea
			,RV.Rama
			,RV.ArticuloRama
			,RV.UltimoCosto
			----,C.DireccionNumero
			--,C.DireccionNumeroInt
			--,C.Direccion
			--,C.EntreCalles
			--,C.Pais
			--,C.Estado
			--,C.Delegacion														as 'Municipio'
			--,C.Poblacion														as 'Ciudad'
			--,C.Colonia
			--,ISNULL(C.IEPS, '')													as 'Contribuyente_IEPS'
			--,ISNULL(UUID, '')													as 'UUID'
			--,ISNULL(RV.Condicion_Comercial,'')									as 'Condicion_Comercial'
			--,RV.TipoPoliza														as 'TipoPoliza'
			--,RV.NumeroPoliza														as 'NumeroPoliza'
	FROM	#ReporteVenta RV
	INNER JOIN Cte C ON C.Cliente = RV.Numero_Cliente
	--WHERE	RV.MovID = 'FHUA3132'
	--WHERE ISNULL(RV.DescuentoObsequio,0.00) != 0.00
	--WHERE	1=1
		--And MovId = 	'FLAT8038'
	ORDER BY RV.Empresa, RV.FechaEmision
END
	
DROP TABLE #Planta_Produccion
DROP TABLE #ReporteVenta
DROP TABLE #Compra_Articulo
DROP TABLE #Inventario_Articulo
DROP TABLE #Empresa