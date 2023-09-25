'#Include "fbgfx.bi"

' necesario para evitar los mensajes WARNING del STDCALL al "linkar" LD con la DLL
#cmdline "-Wl --enable-stdcall-fixup"

#Include "windows.bi" ' necesario para el MEMCPY nada mas (por ahora)

#Include "engine.bi"



'Screen 18,32

' almacen de modelos que se van creando (aqui 11 maximo, pero solo tres usados)
Dim Shared As Double Ptr VerticesOBJ(10)
Dim Shared As LongInt VerticesTotal(10)
Dim Shared As LongInt Ptr IndicesOBJ(10)
Dim Shared As LongInt IndicesTotal(10)



' matrices para guardar el resultado final
#define MAXSUPERFICIES 1000
#define MAXVERTICES 1000
#define MAXCOORDENADAS 1000
Dim Shared As Integer nvertices(MAXSUPERFICIES,MAXVERTICES) ' superficies y cantidad de vertices en cada una
Dim Shared As single ncoord(MAXCOORDENADAS,2) 'x,y,z 
Dim Shared As Integer superficie,numcoord ' contadores



Type Vector3D
	x As double
	y As double
	z As double
End Type


Type Mat12x12
	f1 As Vector3D
	f2 As Vector3D
	f3 As Vector3D
	f4 As Vector3D
End Type



Type Modelo_t
	as LongInt modelo ' identificador del objeto a crear
	as LongInt instancia ' instancia del objeto creado
	As String tipo ' es la clase del objeto, como Sphere, Box, Cylinder, Torus, Cube, ..... 
	As LongInt rgbcolor
	As LongInt segmentos ' la precision en los elementos curvados, como esferas por ejemplo. 36 es un buen numero
	As Double ancho
	As Double alto
	As Double largo
	As Double radio
	As Vector3D posicion
	As Vector3D rotacion
	As Vector3D escala
End Type

Dim Shared As Modelo_t objeto(10)



Sub CogeVertice( vertexIndex As Integer , VertexBuf As Double Ptr)
   'Print (vertexBuf[0]);",";(vertexBuf[1]);",";(vertexBuf[2]) 
	ncoord(numcoord,0)=VertexBuf[0]
	ncoord(numcoord,1)=VertexBuf[1]
	ncoord(numcoord,2)=VertexBuf[2]
	numcoord+=1
End Sub




Sub CogePoligono(tipo As Byte, indexMap As Integer Ptr , IndexBuf As LongInt Ptr ,noElements As LongInt)
   ' nota: TIPO aun no usado. sirve para indicar si es un poligono interno(1) o externo(0) 
	Dim As Integer a = 0, i = 0
   while (i < noElements)  
      a=indexMap[ CInt(IndexBuf[i]) ]
		'Print a;
		nvertices(superficie,i)=a+1 ' empiezo en "1" en lugar de "0" para evitar confusion con el "0" propio de la matriz limpia
      i+=1  
   Wend
   ' el siguiente vertice del ultimo creado, lo borro. necesario, si la matriz se ha usado anteriormente
   ' por que sino, deja restos de la anterior y se estropea el elemento.
   nvertices(superficie,i)=0 
   superficie+=1
End Sub


' la variable "operacion" indica si es mover=0, escalar=1, o girar=2,3,4 (en x, en y o en z)
' los giros solo se pueden uno a uno, por eso, yy y zz tienen por defecto valor "0" si no se usan
sub transformar(nobj as integer, operacion as integer, xx as double, yy as double=0, zz as double=0)
	dim modelo as longint, instanceModel as LongInt

	' modelo principal y su instancia a propiedades
	modelo=objeto(nobj).modelo
	instanceModel=objeto(nobj).instancia
	
		  ' Clases
        Dim As LongInt classMatrix = GetClassByName(modelo, "Matrix") 
        Dim As LongInt classTransformation = GetClassByName(modelo, "Transformation") 

        ' Object Properties (relations)
        Dim As LongInt propertyMatrix = GetPropertyByName(modelo, "matrix") 
        Dim As LongInt propertyObject = GetPropertyByName(modelo, "object") 
        
        ' Instancias solo desde "clases"
        Dim As LongInt instanceMatrix = CreateInstance(classMatrix, NULL) 
        Dim As LongInt instanceTransformation = CreateInstance(classTransformation, NULL) 
                	        
        ' Datatype Properties (attributes)
        ' matriz (11,22,33=escala)
        Dim As LongInt matrix_11 = GetPropertyByName(modelo, "_11") ' escala X
        Dim As LongInt matrix_12 = GetPropertyByName(modelo, "_12") 
        Dim As LongInt matrix_13 = GetPropertyByName(modelo, "_13") 
        Dim As LongInt matrix_21 = GetPropertyByName(modelo, "_21") 
        Dim As LongInt matrix_22 = GetPropertyByName(modelo, "_22") ' escala Y
        Dim As LongInt matrix_23 = GetPropertyByName(modelo, "_23") 
        Dim As LongInt matrix_31 = GetPropertyByName(modelo, "_31") 
        Dim As LongInt matrix_32 = GetPropertyByName(modelo, "_32") 
        Dim As LongInt matrix_33 = GetPropertyByName(modelo, "_33") ' escala Z
		  ' translacion
        Dim As LongInt matrix_41 = GetPropertyByName(modelo, "_41") ' pos. X
        Dim As LongInt matrix_42 = GetPropertyByName(modelo, "_42") ' pos. Y
        Dim As LongInt matrix_43 = GetPropertyByName(modelo, "_43") ' pos. Z

' matrices de transformacion
' https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/SpatialTransformationMatrices.html

		dim as double posX=0
		dim as double posY=0
		dim as double posZ=0

		' la escala siempre "1" por defecto, sino, desaparece el modelo
		dim as double escX=1
		dim as double escY=1
		dim as double escZ=1
		
		dim as double angX=0
		dim as double angY=0
		dim as double angZ=0

		' aqui es donde reparto las tareas solicitadas, segun tipo de operacion
		if operacion=0 then posX=xx:posY=yy:posZ=zz ' mover pieza en XYZ
		if operacion=1 then escX=xx:escY=yy:escZ=zz ' escalar en XYZ
		if operacion=2 then angX=xx ' girar en X
		if operacion=3 then angY=xx ' girar en Y
		if operacion=4 then angZ=xx ' girar en Z

        Dim As Double m_11 ' escala X
        Dim As Double m_12
        Dim As Double m_13
        Dim As Double m_21
        Dim As Double m_22 ' escala Y
        Dim As Double m_23
        Dim As Double m_31
        Dim As Double m_32
        Dim As Double m_33 ' escala Z 
        Dim As Double m_41
        Dim As Double m_42
        Dim As Double m_43

        
	  if posX orelse posY orelse posZ then
        m_11= 1         : m_12= 0         : m_13= 0
        m_21= 0         : m_22= 1         : m_23= 0
        m_31= 0         : m_32= 0         : m_33= 1
        m_41= posX      : m_42= posY      : m_43= posZ  	' desplazamiento 
	  endif

	  if (escX<>1) orelse (escY<>1) orelse (escZ<>1) then
        m_11= escX      : m_12= 0         : m_13= 0
        m_21= 0         : m_22= escY      : m_23= 0
        m_31= 0         : m_32= 0         : m_33= escZ
        m_41= 0         : m_42= 0         : m_43= 0 		' desplazamiento
     endif
                
     if angX then
        m_11= 1         : m_12= 0         : m_13= 0
        m_21= 0         : m_22= cos(angX) : m_23= sin(angX)
        m_31= 0         : m_32=-sin(angX) : m_33= cos(angX)
        m_41= 0         : m_42= 0         : m_43= 0 		' desplazamiento
     endif
      
     if angY then
        m_11= cos(angY) : m_12= 0         : m_13=-sin(angY)
        m_21= 0         : m_22= 1         : m_23= 0
        m_31= sin(angY) : m_32= 0         : m_33= cos(angY)
        m_41= 0         : m_42= 0         : m_43= 0 		' desplazamiento
     endif   
                  
     if angZ then
        m_11= cos(angZ) : m_12=-sin(angZ) : m_13= 0
        m_21= sin(angZ) : m_22= cos(angZ) : m_23= 0
        m_31= 0         : m_32= 0         : m_33= 1
        m_41= 0         : m_42= 0         : m_43= 0 		' desplazamiento
     endif    
                 
        SetDatatypeProperty(instanceMatrix, matrix_11, @m_11, 1) ' escala X
        SetDatatypeProperty(instanceMatrix, matrix_12, @m_12, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_13, @m_13, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_21, @m_21, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_22, @m_22, 1) ' escala Y
        SetDatatypeProperty(instanceMatrix, matrix_23, @m_23, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_31, @m_31, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_32, @m_32, 1)         
        SetDatatypeProperty(instanceMatrix, matrix_33, @m_33, 1) ' escala Z 
        SetDatatypeProperty(instanceMatrix, matrix_41, @m_41, 1) ' pos X
        SetDatatypeProperty(instanceMatrix, matrix_42, @m_42, 1) ' pos Y
        SetDatatypeProperty(instanceMatrix, matrix_43, @m_43, 1) ' pos Z


			' recuperar la matriz
        'Dim As Double ptr mo_11 ' escala X
        'Dim As Double ptr mo_12
        'Dim As Double ptr mo_13
        'Dim As Double ptr mo_21
        'Dim As Double ptr mo_22 ' escala Y
        'Dim As Double ptr mo_23
        'Dim As Double ptr mo_31
        'Dim As Double ptr mo_32
        'Dim As Double ptr mo_33 ' escala Z 
        'Dim As Double ptr mo_41
        'Dim As Double ptr mo_42
        'Dim As Double ptr mo_43
        'dim as longint card                
        'GetDatatypeProperty(instanceMatrix, matrix_11, @mo_11, @card) ' escala X
        'GetDatatypeProperty(instanceMatrix, matrix_12, @mo_12, @card) 
        'GetDatatypeProperty(instanceMatrix, matrix_13, @mo_13, @card) 
        'GetDatatypeProperty(instanceMatrix, matrix_21, @mo_21, @card) 
        'GetDatatypeProperty(instanceMatrix, matrix_22, @mo_22, @card) ' escala Y
        'GetDatatypeProperty(instanceMatrix, matrix_23, @mo_23, @card)
        'GetDatatypeProperty(instanceMatrix, matrix_31, @mo_31, @card) 
        'GetDatatypeProperty(instanceMatrix, matrix_32, @mo_32, @card)         
        'GetDatatypeProperty(instanceMatrix, matrix_33, @mo_33, @card) ' escala Z 
        'GetDatatypeProperty(instanceMatrix, matrix_41, @mo_41, @card) ' pos X
        'GetDatatypeProperty(instanceMatrix, matrix_42, @mo_42, @card) ' pos Y
        'GetDatatypeProperty(instanceMatrix, matrix_43, @mo_43, @card) ' pos Z        
        'print *mo_11,*mo_12,*mo_13
        'print *mo_21,*mo_22,*mo_23
        'print *mo_31,*mo_32,*mo_33
        'print *mo_41,*mo_42,*mo_43   
        
        
        SetObjectProperty(instanceTransformation, propertyObject, @instanceModel, 1) 
        SetObjectProperty(instanceTransformation, propertyMatrix, @instanceMatrix, 1) 
        
        'SaveInstanceTreeW(instanceTransformation, "TR_"+trim(str(instanceModel))+".bin")    

	' al acabar, reasigno la instancia, a la transformacion realizada
	objeto(nobj).instancia=instanceTransformation  
End sub

sub posicion(nobj as integer, x as double, y as double, z as double)
	transformar(nobj, 0,x,y,z)
End Sub

sub escala(nobj as integer, x as double, y as double, z as double)
	transformar(nobj, 1,x,y,z)
End Sub

sub girox(nobj as integer, ang as double)
	transformar(nobj, 2,ang)
End Sub

sub giroy(nobj as integer, ang as double)
	transformar(nobj, 3,ang)
End Sub

sub giroz(nobj as integer, ang as double)
	transformar(nobj, 4,ang)
End Sub

sub CreaEntidad(id As Integer)

   Dim tipo  As String=objeto(id).tipo
   Dim ancho As Double=objeto(id).ancho
   Dim alto  As Double=objeto(id).alto
   Dim largo As Double=objeto(id).largo
   Dim radio As Double=objeto(id).radio
   Dim segmentos As LongInt=objeto(id).segmentos
   
   If segmentos=0 Then segmentos=20 ' por defecto en caso de no indicarlos

	Dim As LongInt	modelo = OpenModel(NULL) 
	if (modelo) Then 
	    
		' manejador a la clase solicitada
		Dim As LongInt	entidad_tipo = GetClassByName(modelo, tipo) 

		' crea una instancia al arbol deseado con los minimos valores posibles
		Dim As LongInt instancia = CreateInstance(entidad_tipo, NULL) 

		' y a cada una de las propiedades, segun sea la clase
		Dim As LongInt	entidad_ancho
		Dim As LongInt	entidad_alto
		Dim As LongInt	entidad_largo
		Dim As LongInt	entidad_radio 
		
		' el toroide requiere parametros extras
		If tipo="Torus" Then
			entidad_largo = GetPropertyByName(modelo, "majorRadius")
			entidad_radio = GetPropertyByName(modelo, "minorRadius") 
			SetDataTypeProperty(instancia, entidad_largo, @largo, 1) 
			SetDataTypeProperty(instancia, entidad_radio, @radio, 1)		
			GoTo continuar
		EndIf
		
		If ancho Then entidad_ancho = GetPropertyByName(modelo, "width")
		If alto  Then entidad_alto  = GetPropertyByName(modelo, "height")
		If largo Then entidad_largo = GetPropertyByName(modelo, "length")
		If radio Then entidad_radio = GetPropertyByName(modelo, "radius") 

		' activa las propiedas de medidas deseadas
		If ancho Then SetDataTypeProperty(instancia, entidad_ancho, @ancho, 1) 
		If alto  Then SetDataTypeProperty(instancia, entidad_alto , @alto , 1) 
		If largo Then SetDataTypeProperty(instancia, entidad_largo, @largo, 1) 
		If radio Then SetDataTypeProperty(instancia, entidad_radio, @radio, 1)

		
continuar:
		' los segmentos los activo siempre, aunque algunas entidades, como la caja, no lo usan
		' si no se indica numero de segmentes, coge por defecto 24
		Dim As LongInt	entidad_segmentos = GetPropertyByName(modelo, "segmentationParts") 
		SetDataTypeProperty(instancia, entidad_segmentos, @segmentos, 1) 



		' para recuperar las propiedades, usar este sistema
		'Dim As double Ptr aa=0 ' necesario puntero, por que la rutina requiere doble puntero
		'Dim As LongInt bb=0
		'GetDataTypeProperty(instancia, entidad_ancho, @aa, @bb):Print *aa,bb


    
		' activamos la representacion, exportar X,Y,Z y usar doble precision 64bits
		ConfiguraSalidaDatos(modelo) 

		' crea geometria interna, para esta minima configuracion dada hasta ahora
		Dim As LongInt	TotalVertices = 0, TotalIndices = 0 
		CalculateInstance(instancia, @TotalVertices, @TotalIndices, NULL) 


		' convertimos el modelo recien creado, en vertices y vectores, para guardar en una matriz
		' este se hace, por que al hacer operaciones booleanas se pierde el tipo de entidad de partida
		' esto es: hacemos una esfera, pero la cortamos con un cubo, con lo cual, ya no es entidad pura
		' de todos modos, se guarda tambien la entidad real, para tener ambos metodos de trabajo
		if (TotalVertices AndAlso TotalIndices) Then 
         print "Hemos creado una entidad:";tipo

			' con SetFormat(..) pedimos doble precision en vertices y 3 componentes (X, Y, Z) por vertice
			Dim As Double Ptr VertexBuf = Callocate(3 * CInt(TotalVertices),SizeOf(Double)) 
			UpdateInstanceVertexBuffer(instancia, VertexBuf) 
						
			' ahora, otra vez con SetFormat(..),solicitamos 64 bits LongInt 
			Dim As LongInt Ptr IndexBuf = Callocate(CInt(TotalIndices),SizeOf(LongInt))
			UpdateInstanceIndexBuffer(instancia, IndexBuf) 

			' una vez preparados los vertices, vamos a por los poligonos
			Dim As LongInt	conceptualFaceCnt = GetConceptualFaceCnt(instancia), cnt = 0 
			for i As LongInt = 0 To conceptualFaceCnt-1         
				Dim As LongInt	startIndexFacePolygons = 0, noIndicesFacePolygons = 0 
				GetConceptualFaceEx( _
						instancia, i, _
						NULL, NULL, _
						NULL, NULL, _
						NULL, NULL, _
						@startIndexFacePolygons, @noIndicesFacePolygons, _
						NULL, NULL ) 
				cnt += noIndicesFacePolygons 
         Next

			' se asignan los resultados a la matrices
			VerticesOBJ( id ) = VertexBuf 
			VerticesTotal( id ) = TotalVertices 
			IndicesOBJ( id ) = Callocate (CInt(cnt),SizeOf(LongInt)) 

			conceptualFaceCnt = GetConceptualFaceCnt(instancia) 
			for i As LongInt = 0 To conceptualFaceCnt -1        
				Dim As LongInt	startIndexFacePolygons = 0, noIndicesFacePolygons = 0 
				GetConceptualFaceEx( _
						instancia, i, _
						NULL, NULL, _
						NULL, NULL, _
						NULL, NULL, _
						@startIndexFacePolygons, @noIndicesFacePolygons, _
						NULL, NULL ) 
				memcpy(  @IndicesOBJ( id )[CInt(IndicesTotal( id ))]  ,  @IndexBuf[CInt(startIndexFacePolygons)]  ,  CInt(noIndicesFacePolygons) * sizeof(LongInt)  ) 
				IndicesTotal( id ) += noIndicesFacePolygons 
         Next

			'delete  VertexBuf
			'delete  IndexBuf 

			' guardo el modelo creado por independiente
			'SaveModel(modelo,tipo+".bin")
			objeto(id).instancia=instancia ' instancia a las propiedades, por ejemplo para transformaciones 
			objeto(id).modelo=modelo ' identificador principal, para luego cerrarlo si ya no se usa
  	   
		else
         Print "Error mientras se creaba entidad: ";tipo
		EndIf
  	   
		'CloseModel(modelo) ' no podemos cerrarlo aqui, por que hace falta mas tarde, al hacer operaciones

	else
      Print "Error al tratar de crear nueva entidad: ";tipo
	EndIf


End sub



Sub CreaSolido(id As Integer, objeto1 As Integer, objeto2 As Integer, tipo As Integer)
	
	' las variables donde guardo el resultado para luego sacar ISO NC XYZ, a cero...
	numcoord=0
	superficie=0

	'
	'	Here we will create a Box within the Geometry Kernel and fill the buffers
	'
	'		Boolean Operation (2D and 3D) supports the following types:
	'			 0 - Union
	'			 1 - Difference (first object  - second object)
	'			 2 - Difference (second object - first object ) (correccion Jepalza)
	'			 3 - Intersection
	'
	'			 4 - like 0, but only with geometry inherited from second object
	'			 5 - like 1, but only with geometry inherited from second object
	'			 6 - like 2, but only with geometry inherited from second object
	'			 7 - like 3, but only with geometry inherited from second object
	'
	'			 8 - like 0, but only with geometry inherited from first object
	'			 9 - like 1, but only with geometry inherited from first object
	'			10 - like 2, but only with geometry inherited from first object
	'			11 - like 3, but only with geometry inherited from first object
	'
	Dim As LongInt	booleanOperationType = tipo
	
	Dim As LongInt	modelo = OpenModel(NULL) 
	if (modelo) Then 
	     
		' manejadores a la clase solicitada
		Dim As LongInt	classBoundaryRepresentation = GetClassByName(modelo, "BoundaryRepresentation") 
		Dim As LongInt	propertyIndices  = GetPropertyByName(modelo, "indices") 
		Dim As LongInt	propertyVertices = GetPropertyByName(modelo, "vertices") 
		'
		Dim As LongInt	classBooleanOperation = GetClassByName(modelo, "BooleanOperation") 
		Dim As LongInt	propertyFirstObject   = GetPropertyByName(modelo, "firstObject") 
		Dim As LongInt	propertySecondObject  = GetPropertyByName(modelo, "secondObject") 
		Dim As LongInt	propertyType          = GetPropertyByName(modelo, "type") 

		' crea una instancia al arbol deseado con los minimos valores posibles
		Dim As LongInt instanceBooleanOperation = CreateInstance(classBooleanOperation, NULL) 
		Dim As LongInt	instanceBoundaryRepresentationI  = CreateInstance(classBoundaryRepresentation, NULL) 
		Dim As LongInt	instanceBoundaryRepresentationII = CreateInstance(classBoundaryRepresentation, NULL) 


		'===================================================
		' recupera las transformaciones del modelo numero 2 (siempre coge del 2)
		dim as Mat12x12 m1 ' matriz de transformacion
		'dim as Vector3d v1 ' vector de inicio, siempre es cero, no lo uso
		'dim as Vector3d v2 ' vector final, idem, cero

		dim as longint instancia_objeto2=objeto(objeto2).instancia

        Dim As ubyte resultado = GetBoundingBox(instancia_objeto2, cast(double ptr,@m1), null, null) ' salida "0"= correcto
        'Dim As ubyte resultado = GetBoundingBox(instancia_objeto2, @m1, @v1, @v2) ' si vamos a usar v1 y v2
        'print p1.f1.x,p1.f1.y,p1.f1.z
        'print p1.f2.x,p1.f2.y,p1.f2.z
        'print p1.f3.x,p1.f3.y,p1.f3.z
        'print p1.f4.x,p1.f4.y,p1.f4.z
        '''print v1.x,v1.y,v1.z
        '''print v2.x,v2.y,v2.z
        
        ' clases a matriz de transformacion (del modelo nuevo a crear, o sea, de la fusion)
        Dim As LongInt classMatrix = GetClassByName(modelo, "Matrix") 
        Dim As LongInt classTransformation = GetClassByName(modelo, "Transformation") 

        '  Objetos Propiedades (relaciones)
        Dim As LongInt propertyMatrix = GetPropertyByName(modelo, "matrix") 
        Dim As LongInt propertyObject = GetPropertyByName(modelo, "object") 
     
        '  Instancias solo desde "clases"
        Dim As LongInt instanceMatrix = CreateInstance(classMatrix, NULL) 
        Dim As LongInt instanceTransformation = CreateInstance(classTransformation, NULL) 


        Dim As Double m_11=m1.f1.x ' escala X
        Dim As Double m_12=m1.f1.y
        Dim As Double m_13=m1.f1.z
        Dim As Double m_21=m1.f2.x
        Dim As Double m_22=m1.f2.y ' escala Y
        Dim As Double m_23=m1.f2.z
        Dim As Double m_31=m1.f3.x
        Dim As Double m_32=m1.f3.y
        Dim As Double m_33=m1.f3.z ' escala Z 
        Dim As Double m_41=m1.f4.x
        Dim As Double m_42=m1.f4.y
        Dim As Double m_43=m1.f4.z
            	        

        ' matriz (11,22,33=escala)
        Dim As LongInt matrix_11 = GetPropertyByName(modelo, "_11") ' escala X
        Dim As LongInt matrix_12 = GetPropertyByName(modelo, "_12") 
        Dim As LongInt matrix_13 = GetPropertyByName(modelo, "_13") 
        Dim As LongInt matrix_21 = GetPropertyByName(modelo, "_21") 
        Dim As LongInt matrix_22 = GetPropertyByName(modelo, "_22") ' escala Y
        Dim As LongInt matrix_23 = GetPropertyByName(modelo, "_23") 
        Dim As LongInt matrix_31 = GetPropertyByName(modelo, "_31") 
        Dim As LongInt matrix_32 = GetPropertyByName(modelo, "_32") 
        Dim As LongInt matrix_33 = GetPropertyByName(modelo, "_33") ' escala Z
		  ' traslacion
        Dim As LongInt matrix_41 = GetPropertyByName(modelo, "_41") ' pos. X
        Dim As LongInt matrix_42 = GetPropertyByName(modelo, "_42") ' pos. Y
        Dim As LongInt matrix_43 = GetPropertyByName(modelo, "_43") ' pos. Z

		  ' aplica la matriz recuperada del modelo "2" en una instancia generica (luego se asocia a su modelo)
        SetDatatypeProperty(instanceMatrix, matrix_11, @m_11, 1) ' escala X
        SetDatatypeProperty(instanceMatrix, matrix_12, @m_12, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_13, @m_13, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_21, @m_21, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_22, @m_22, 1) ' escala Y
        SetDatatypeProperty(instanceMatrix, matrix_23, @m_23, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_31, @m_31, 1) 
        SetDatatypeProperty(instanceMatrix, matrix_32, @m_32, 1)         
        SetDatatypeProperty(instanceMatrix, matrix_33, @m_33, 1) ' escala Z 
        SetDatatypeProperty(instanceMatrix, matrix_41, @m_41, 1) ' pos X
        SetDatatypeProperty(instanceMatrix, matrix_42, @m_42, 1) ' pos Y
        SetDatatypeProperty(instanceMatrix, matrix_43, @m_43, 1) ' pos Z

'===================================================


		' aqui, aplicamos la transformacion sobre "propertyObject" que representa al "Modelo 2"
      SetObjectProperty(instanceTransformation, propertyObject, @instanceBoundaryRepresentationII, 1) 
      SetObjectProperty(instanceTransformation, propertyMatrix, @instanceMatrix, 1) 


		' asigna las propiedades a los elementos
		SetObjectProperty(instanceBooleanOperation, propertyFirstObject,  @instanceBoundaryRepresentationI , 1) 
		SetObjectProperty(instanceBooleanOperation, propertySecondObject, @instanceTransformation, 1) 	

		' elementos del modelo UNO
		SetDataTypeProperty(instanceBoundaryRepresentationI , propertyVertices, @VerticesOBJ( objeto1 )[0], VerticesTotal( objeto1 ) * 3) 
		SetDataTypeProperty(instanceBoundaryRepresentationI , propertyIndices,   @IndicesOBJ( objeto1 )[0],  IndicesTotal( objeto1 )) 

		' elementos del modelo DOS
		SetDataTypeProperty(instanceBoundaryRepresentationII, propertyVertices, @VerticesOBJ( objeto2 )[0], VerticesTotal( objeto2 ) * 3) 
		SetDataTypeProperty(instanceBoundaryRepresentationII, propertyIndices,   @IndicesOBJ( objeto2 )[0],  IndicesTotal( objeto2 )) 

		' activamos solo representacion, solo exportar X,Y,Z y usar doble precision 64bits
		ConfiguraSalidaDatos(modelo) 

		' y realiza la operacion booleana indicada
		SetDataTypeProperty(instanceBooleanOperation, propertyType, @booleanOperationType, 1) 

		' podemos salvar aqui el resultado de la operacion booleana, y salir seguido
		'SaveModel(modelo,"salida_booleana.bin"):exit sub

		' solo nos interesan las operaciones BOOLEANAS
		Dim As LongInt	selectedInstance = instanceBooleanOperation 

		' crea geometria interna, para esta minima configuracion dada hasta ahora
		Dim As LongInt	TotalVertices = 0, TotalIndices = 0 
		CalculateInstance(selectedInstance, @TotalVertices, @TotalIndices, NULL) 

		' las operaciones booleanas es mejor hacerlas sobre modelos a los que hemos recuperado sus
		' vertices y vectores, por que una vez hecha la operacion, se convierte en un elemento abstracto
		' ademas, aprovecho para realizar una serie de pasos extra que rescatan a su vez los vertices 
		' y vectores del resultado final, para guardarlo como fichero mio de texto, tipo ISO-NC XYZ
		if (TotalVertices AndAlso TotalIndices) Then 
         Print "Correcta operacion Booleana!!"
         
			' ==== paso UNO para obtener vertices creados en una matriz para hacer un NC ISO XYZ====
         Dim As Integer Ptr vertexElementUsed = Callocate(Cint(TotalVertices), SizeOf(Integer))

			' con SetFormat(..) pedimos doble precision en vertices y 3 componentes (X, Y, Z) por vertice
			Dim As Double Ptr VertexBuf = callocate(3 * cint(TotalVertices), SizeOf(Double) )
			UpdateInstanceVertexBuffer(selectedInstance, VertexBuf) 

			' ahora, otra vez con SetFormat(..),solicitamos 64 bits LongInt 
			Dim As LongInt Ptr IndexBuf = callocate(CInt(TotalIndices), SizeOf(LongInt) )
			UpdateInstanceIndexBuffer(selectedInstance, IndexBuf) 

			' una vez preparados los vertices, vamos a por los poligonos
			Dim As LongInt	conceptualFaceCnt = GetConceptualFaceCnt(selectedInstance), cnt = 0 
			for i As LongInt = 0 To conceptualFaceCnt -1        
				Dim As LongInt	startIndexFacePolygons = 0, noIndicesFacePolygons = 0 
				GetConceptualFaceEx( _
						selectedInstance, i, _
						NULL, NULL, _
						NULL, NULL, _
						NULL, NULL, _
						@startIndexFacePolygons, @noIndicesFacePolygons, _
						NULL, NULL ) 
				cnt += noIndicesFacePolygons 
					
					' ==== paso DOS de la creacion de vertices en matriz para hacer un NC ISO XYZ ====
               For j As Integer = 0 To noIndicesFacePolygons -1        
                  if IndexBuf[startIndexFacePolygons + j] >= 0 Then 
                     vertexElementUsed[ IndexBuf[startIndexFacePolygons + j] ]+=1  
                  EndIf
               Next
         Next


         ' ==== paso TRES de creacion de vertices para hacer un NC ISO XYZ ====
         Dim As Integer currentIndex = 0 
         for k As Integer = 0 To TotalVertices-1         
            if vertexElementUsed[k] Then 
               vertexElementUsed[k] = currentIndex 
               currentIndex+=1  
            Else
               vertexElementUsed[k] = -1 
            EndIf
         Next

			' asignamos los valores
			VerticesOBJ( id ) = VertexBuf 
			VerticesTotal( id ) = TotalVertices 
			IndicesOBJ( id ) = Callocate (CInt(cnt)*SizeOf(LongInt))  

			conceptualFaceCnt = GetConceptualFaceCnt(selectedInstance) 
			for i As LongInt = 0 To conceptualFaceCnt -1         
				Dim As LongInt	startIndexFacePolygons = 0, noIndicesFacePolygons = 0 
				GetConceptualFaceEx( _
						selectedInstance, i, _
						NULL, NULL, _
						NULL, NULL, _
						NULL, NULL, _
						@startIndexFacePolygons, @noIndicesFacePolygons, _
						NULL, NULL ) 

				memcpy(  @IndicesOBJ( id )[CInt(IndicesTotal( id ))] , @IndexBuf[CInt(startIndexFacePolygons)]  ,  CInt(noIndicesFacePolygons) * sizeof(LongInt)  ) 
				IndicesTotal( id ) += noIndicesFacePolygons 


				  ' ==== paso CUATRO de creacion de poligonos para hacer un NC ISO XYZ ====
              Dim As Integer k = 0, startIndicesPolygon = 0 
               while (k < noIndicesFacePolygons)  
                  if IndexBuf[startIndexFacePolygons + k] < 0 Then 

                     if IndexBuf[startIndexFacePolygons + k] = -1 Then 
                        ' encontrado poligo externo
                        CogePoligono(0,vertexElementUsed, @IndexBuf[startIndexFacePolygons + startIndicesPolygon], k - startIndicesPolygon) 
                     Else
                        ' encontrado poligono interno
                        CogePoligono(1,vertexElementUsed, @IndexBuf[startIndexFacePolygons + startIndicesPolygon], k - startIndicesPolygon) 
                     EndIf
  
                     startIndicesPolygon = k + 1 
                  EndIf
                  k+=1  
               Wend
			
         Next

         ' ==== paso CINCO y ultimo, ya tenemos vertices para hacer un NC ISO XYZ ====
         for i As Integer= 0 To TotalVertices-1         
            if (vertexElementUsed[i] >= 0) Then 
               CogeVertice(i, @VertexBuf[3 * i]) 
            EndIf
         Next

         'Delete vertexBuf 
			'Delete indexBuf 

		' ================================================
			SaveModel(modelo,"salida_booleana.bin") ' salida como BIN
			'SaveInstanceTreeW(instanceBooleanOperation,"salida_booleana.xml") ' salida como XML
			objeto(id).instancia=instanceBooleanOperation ' instancia a las propiedades, por ejemplo para transformaciones 
			objeto(id).modelo=modelo ' identificador principal, para luego cerrarlo si ya no se usa
		' ================================================
				 
		Else
			
         Print "Error al hacer la operacion BOOLEANA"
		
		EndIf

		'CloseModel(modelo) ' es mejor no borralo aqui, para poder seguir haciendo operaciones
	
	EndIf
  
End sub


   ' -----------------------------------------------------------------------------------------------------

'shell "del *.bin"	

	
	' ================================================================
	' las transformaciones pueden hacerse directas con "transformar()"
	' o con los "atajos" "girox","giroy","giroz","posicion","escala"
	'
	'transformar(2,0, 1.5,0,0) ' posiciono en X1.5 de esta manera
	'posicion(2, 1.5,0,0) ' o de esta, mas corta
	'
	'transformar(2,3, 45) ' giro en X45 de esta manera
	'girox(2, 45) ' o de esta, mas corta
	' ================================================================
	
	
	' creo un cubo-rectangulo
	objeto(1).tipo="Box"
	objeto(1).ancho=10
	objeto(1).alto=10
	objeto(1).largo=20.7
	CreaEntidad(1)
	
	
	' ahora un cilindro
	'objeto(2).tipo="Cylinder" ' importante mantener la primera Mayúscula
	'objeto(2).radio=1.5
	'objeto(2).largo=1.5
	'objeto(2).segmentos=20 ' ojo con poner muchos, que casca
	'CreaEntidad(2)

		
	' y un cono
	objeto(3).tipo="Cone"
	objeto(3).radio=3.3
	objeto(3).alto=17.8
	CreaEntidad(3)
	posicion(3,5,0,0) ' muevo en X
	'giroy(3,45)

	' la clasica esfera
	objeto(4).tipo="Sphere"
	objeto(4).radio=10
	objeto(4).segmentos=40
	CreaEntidad(4)
	posicion(4,20.7,4.94,4.94)

	' toroide (o sea, "Donut")
	'objeto(5).tipo="Torus"
	'objeto(5).radio=0.5
	'objeto(5).largo=2.0
	'objeto(5).segmentos=20 ' ojo con poner muchos, que casca
	'CreaEntidad(5)

	' hacemos la fusion, division, resta o lo que queramos
	' parametros: salida, primer objeto, segundo objeto, operacion
	'			 0 - Union
	'			 1 - Diferencia (primero con segundo)
	'			 2 - Diferencia (segundo con primero)
	'			 3 - Interseccion
	CreaSolido(0,1,3, 1) ' crea solido n0 mediante resta entre el n1(cubo) y el n3(cono)
	CreaSolido(6,0,4, 1) ' ahora, un solido n6, con la resta del anterior n0 resultante y n4(esfera) 
	'CreaSolido(7,6,4, 1)
	
	
	
	Print
	
	Print "Guardando 'SALIDA.NC'"
	Open "salida.nc" For Output As 2
	For f As Integer=0 To superficie-1
		For g As Integer=0 To 1000
			If nvertices(f,g)=0 Then Exit For ' si es "0" salimos, ya no hay mas vertices
			Print #2,"X";Using "#####.### ";ncoord(nvertices(f,g)-1,0);
			Print #2,"Y";Using "#####.### ";ncoord(nvertices(f,g)-1,1);
			Print #2,"Z";Using "#####.### ";ncoord(nvertices(f,g)-1,2)
		Next
		Print #2,"(P)"	' poniendo este aqui salen poligonos cerrados al leer el ISO como curvas 
	Next
			
	Close 2
	
	Print "FIN...":sleep