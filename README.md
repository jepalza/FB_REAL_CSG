# FB_REAL_CSG
FreeBasic CSG Real para creacion de entidades 3D CAD mediante "Constructive solid geometry"

"Constructive solid geometry"="Geometría constructiva de sólidos" (CSG o GCS)
Es una técnica empleada en construcciones de modelos 3D, por ejemplo para sistemas CAD o impresión en 3D.

Partiendo del código original de esta página:
http://www.bons.nl/csg/product_csg.html
Descargamos cualquiera de sus versiones (a fecha actual, empleo al version 32bits "build 1691").
No está probado con ninguna otra version, solo con 32bits windows version 1691 (sept. 23)
Debemos colocar la DLL "engine.dll" contenida en alguna de las carpetas de ejemplos del original, por ejemplo,
la de la carpeta "\engine (build 1691)\bin\32bit\"

Tengo otro ejemplo de CSG en esta ruta:
https://github.com/jepalza/FB_CSG_DEMO

Pero es solo a nivel visual, no son entidades reales, solo generadas en tiempo real en pantalla.

Este otro repositorio SI es REAL, ya que genera entidades mediante comandos que luego se pueden exportar a sistemas CAD.
Dado que existen muchos formatos CAD (el mas universal es el IGS) en un principio, solo exporto las entidades a IGES y ISO-NC
El ISO-NC son tan solo los vértices generados en los polígonos resultantes, sacados secuencialmente y separados por una (P) en el
fichero NC, de modo que los sistemas de CAD (como el TEBIS AG.) lo leen como póligonos (curvas).

En esta ocasión, solo he convertido la cabecera principal de los ejemplos del código original, en concreto el fichero 
"engine.h" de la carpeta "\engine (build 1691)\engine-20230426\include\", por ser el mas indicado para mi prueba.


