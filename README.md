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
    from prophet import Prophet

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
    - Predicción de ventas para los próximos tres meses.

6. **Visualización de Resultados:**
    - Gráficos comparativos entre predicciones y datos históricos.

[images/Estructura_Tablas.png]("images/Estructura_Tablas.png")
:

#### Results


#### Next steps
What suggestions do you have for next steps?

#### Outline of project

- [Link to notebook 1]()
- [Link to notebook 2]()
- [Link to notebook 3]()


##### Contact and Further Information