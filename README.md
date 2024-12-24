### Pronostico de ventas HBS-Delli 

**Author**
Jorge Carrillo Rodriguez

#### Executive summary
HBS-Delli, una empresa especializada en la producción y distribución de artículos, busca optimizar la planificación y gestión de sus recursos mediante la implementación de un modelo de predicción de ventas. Este proyecto tiene como objetivo principal proporcionar herramientas analíticas para anticipar la demanda futura de artículos producidos y comprados, mejorando la toma de decisiones estratégicas.
En base a las ventas HBS-Delli buscara tener inventario suficiente tanto de productos comercializados así como materia prima suficiente para los articulos producidos

Este proyecto utiliza los modelos Prophet y TimeSeries para analizar y predecir las ventas de los principales productos comercializados por la empresa **HBS-Delli**. Los datos abarcan desde el año **2021** hasta el **2024** y se utiliza esta información para generar predicciones de las ventas para los próximos **tres meses**.


## Objetivo
Desarrollar un sistema de predicción de ventas confiable que pueda:
1. Analizar patrones históricos de ventas.
2. Predecir con alta precisión las ventas futuras para los próximos tres meses.
3. Ayudar a la toma de decisiones basada en datos, para la planificación de la compra de las materias primas

## Estructura del Proyecto
El proyecto está organizado de la siguiente manera:

HBS-Delli-Predicciones/
│
├── data/                   # Información obtenida de la base de datos MSSQL de HBS-Delli
├── images/                 # Imagenes para la documentación del proyecto
├── notebooks/              # Jupyter Notebooks con análisis y visualizaciones
├── models/                 # Modelos entrenados y scripts relacionados
├── scripts/                # Scripts auxiliares para procesamiento y predicción
├── results/                # Resultados y reportes generados
├── README.md               # Documentación del proyecto


#### Data Sources
La fuente de información son las ventas de la compañia HBS-Delli del 01/01/2020 al 31/10/2024
[Diagrama de BD](images/Estructura_Tablas.png)

La información devuelta por la consulta es el siguiente dataframe
RangeIndex: 110094 entries, 0 to 110093
Data columns (total 21 columns):
 #   Columna         Contador Null    Dtype             Descripción
---  ------          --------------   -----             ---------------------------------------------------------------------------------------------------         
 0   Numero_Orden    110094 non-null  int64             Id del movimiento de la venta la cual puede ser: Factura, Devolucion Venta o Bonificacion Venta 
 1   FechaEmision    110094 non-null  datetime64[ns]    Fecha del movimiento
 2   Empresa         110094 non-null  object            Empresa la cual pertenece el movimiento
 3   Numero_Cliente  110094 non-null  int64             Clave del cliente
 4   Nombre_Cliente  110094 non-null  object            Razón social del cliente
 5   Rama            110094 non-null  object            Rama del Cliente la cual indica si es Nacional, Extranjero ó Intercompañia
 6   Tipo            110094 non-null  object            Indica si es Cliente, deudor, exportacion
 7   Articulo        110094 non-null  object            Clave del artículo
 8   Desc_Articulo   110094 non-null  object            Descripción del artículo
 9   Cantidad        110094 non-null  float64           Cantidad vendida
 10  Precio          110094 non-null  float64           Precio unitario de venta
 11  SubTotal        110094 non-null  float64           SubTotal de la venta: Precio * Cantidad
 12  IVA             110094 non-null  float64           IVA del artículo
 13  IEPS            110094 non-null  float64           IEPS del artículo Porcentaje %
 14  IEPS_Cuota      110094 non-null  int64             IEPS del artículo Cuota
 15  ImporteTotal    110094 non-null  float64           Importe total de la venta: ((Precio * Cantidad)*(1 +(IEPS/100.00))) * (1 + (IVA/100.00))
 16  Costo_Unitario  110094 non-null  float64           Costo unitario del artículo
 17  Costo_Total     110094 non-null  float64           Costo total de la venta: Costo unitario * Cantidad
 18  Almacen         110094 non-null  object            Almacén donde se realizó la venta
 19  Linea           110094 non-null  object            Línea de la artículo
 20  Modulo          110094 non-null  object            Módulo origen del artículo. PROD: Produccion, COMS: Compras

#### Methodology 

1. **Carga y Preprocesamiento de Datos:**
    - Recopilación de Datos
    - Limpieza de datos.
    - Verificación de valores faltantes y atípicos.
    - Exploración inicial de tendencias y estacionalidades.

2. **Análisis Exploratorio de Datos (EDA):**
    - Visualización de patrones históricos de ventas.
    - Identificación de tendencias y estacionalidades.

3. **Modelado Predictivo:**
    - **Modelo Prophet**


    Prophet es una biblioteca desarrollada por el equipo de investigación de Facebook para modelar y predecir series temporales de manera intuitiva y eficiente. Está diseñada para manejar datos con patrones de tendencia, estacionalidades múltiples y anomalías, siendo particularmente útil en escenarios donde la estacionalidad juega un papel importante.

    El modelo Prophet está basado en una suma de componentes que representan diferentes comportamientos de una serie temporal:
    ##Tendencia (Trend):
    Describe el crecimiento subyacente de largo plazo.
    Utiliza modelos lineales o logísticos para capturar la tendencia.

    ##Estacionalidad (Seasonality):
    Captura patrones recurrentes en diferentes ciclos, como mensuales o anuales.
    Implementada mediante transformadas de Fourier.

    ##Días festivos y eventos especiales:
    Permite incluir eventos específicos que puedan afectar los datos (ej. campañas de marketing, días festivos).
    
    ##Ruido (Residual):
    Representa las fluctuaciones aleatorias no capturadas por los componentes anteriores.

    La fórmula es: y(t)=g(t)+s(t)+h(t)+ε

    - **TimeSeries:**
    El modelo TimeSeries es un enfoque general para analizar y predecir datos ordenados temporalmente. Los modelos de series temporales buscan capturar patrones subyacentes en los datos, como tendencias, estacionalidades y correlaciones temporales, para realizar predicciones futuras. Dentro de esta categoría, hay varios enfoques y técnicas ampliamente utilizadas.

    Estos modelos están basados en ecuaciones matemáticas que describen cómo los valores pasados y las relaciones temporales afectan los valores futuros.
    * AR (Autoregressive): Predice el valor actual como una combinación líneal de valores pasados.
    * MA (Moving Average): Modela el valor actual como una función de errores pasados.
    * ARIMA (Autoregressive Integrated Moving Average): Combina AR, MA y un componente de diferenciación para manejar datos no estacionarios.
    * SARIMA (Seasonal ARIMA): Extiende ARIMA para incluir estacionalidades (mensuales, trimestrales, etc.).

4. **Evaluación del Modelo:**
    - Comparación de métricas como MAE, RMSE y MAPE entre ambos modelos.
cc
5. **Predicción:**
    - Predicción de ventas del 2024, utilizando información del 2023 para el entrenamiento.

6. **Visualización de Resultados:**
    - Gráficos comparativos entre predicciones y datos históricos.


#### Resultados


#### Links

- [Ventas Dataframe](data/Ventas_CapstoneProject_Agrupado.xlsx)

