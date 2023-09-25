#Include "fbgfx.bi"
#Include "windows.bi"

#Inclib "engine"

#Include "engine.bi"


	
	Dim As INT64_N model = OpenModel(NULL) 
	
	if (model) Then 
	  
	    '
	    '  Classes
	    '
	    Dim As INT64_N classCollection = GetClassByName(model, "Collection")
	    Dim As INT64_N classCylinder   = GetClassByName(model, "Cylinder")
	    Dim As INT64_N classLine3D     = GetClassByName(model, "Line3D")
	    Dim As INT64_N classPoint3D    = GetClassByName(model, "Point3D") 
	
	    '
	    '  Object Properties (relations)
	    '
	    Dim As INT64_N propertyObjects = GetPropertyByName(model, "objects") 
	
	    '
	    '  Datatype Properties (attributes)
	    '
	    Dim As INT64_N propertyCoordinates = GetPropertyByName(model, "coordinates")
	    Dim As INT64_N propertyLength = GetPropertyByName(model, "length")
	    Dim As INT64_N propertyPoints = GetPropertyByName(model, "puntos")
	    Dim As INT64_N propertyRadius = GetPropertyByName(model, "radius")
	    Dim As INT64_N propertySegmentationParts = GetPropertyByName(model, "segmentationParts") 
	
	    '
	    '  Instances (creating)
	    '
	    Dim As INT64_N instanceCollection = CreateInstance(classCollection, NULL)
	    Dim As INT64_N instanceCylinder   = CreateInstance(classCylinder, NULL)
	    Dim As INT64_N instanceLine3D     = CreateInstance(classLine3D, NULL)
	    Dim As INT64_N instancePoint3D_I  = CreateInstance(classPoint3D, NULL)
	    Dim As INT64_N instancePoint3D_II = CreateInstance(classPoint3D, NULL) 
	
	    Dim As INT64_N objects(5) = { instancePoint3D_I, instanceLine3D, instanceLine3D, instancePoint3D_II, instanceCylinder, instancePoint3D_I } 
	    SetObjectProperty(instanceCollection, propertyObjects, @objects(0), 6) 
	
	    Dim As DBL64 coordinates_I(2) = { 1., 2., 3. }
	    Dim As DBL64 coordinates_II(2) = { 4., 5., 6. }
	    Dim As DBL64 length = 4.
	    Dim As DBL64 puntos(5) = { 0., 0., -1., 5., 3., 0. }
	    Dim As DBL64 radius = 2. 
	    
	    Dim As INT64_N segmentationParts = 36 
	
	    SetDatatypeProperty(instanceCylinder, propertyLength, @length, 1) 
	    SetDatatypeProperty(instanceCylinder, propertyRadius, @radius, 1) 
	    SetDatatypeProperty(instanceCylinder, propertySegmentationParts, @segmentationParts, 1) 
	    SetDatatypeProperty(instanceLine3D, propertyPoints, @puntos(0), 6) 
	    SetDatatypeProperty(instancePoint3D_I, propertyCoordinates, @coordinates_I(0), 3) 
	    SetDatatypeProperty(instancePoint3D_II, propertyCoordinates, @coordinates_II(0), 3) 
	
	    Dim As INT64_N myInstance = instanceCollection 
	
	    '...
	    '...     //  create, load or edit myInstance, in this case a simple Collection is used as input
	    '...
	
	    '
	    '  Initializing the mask with all possible options
	    '
	    Dim As INT64_N setting = 0
	    Dim As INT64_N mask = GetFormat(0, 0) 
	
	    setting += 0 * flagbit2         '    SINGLE / DBL64 PRECISION (float / DBL64)
	    setting += 0 * flagbit3         '    32 / 64 BIT INDEX ARRAY (int32_t / int64_t)
	
	    setting += 1 * flagbit4         '    OFF / ON VECTORS (x, y, z)
	    setting += 1 * flagbit5         '    OFF / ON NORMALS (Nx, Ny, Nz)
	
	    setting += 1 * flagbit8         '    OFF / ON TRIANGLES
	    setting += 1 * flagbit9         '    OFF / ON LINES
	    setting += 1 * flagbit10        '    OFF / ON POINTS
	
	    setting += 0 * flagbit12        '    OFF / ON WIREFRAME FACES
	    setting += 0 * flagbit13        '    OFF / ON WIREFRAME CONCEPTUAL FACES
	
	    Dim As INT64_N vertexElementSizeInBytes = SetFormat(model, setting, mask) ' la salida deberia ser siempre 24
	    If vertexElementSizeInBytes <> (3 + 3) * sizeof(single) Then Print "Error en SetFormat":Sleep:end
	
	    '...
	
	    Dim As INT64_N vertexBufferSize = 0
	    Dim As INT64_N  indexBufferSize = 0 
	    CalculateInstance(myInstance, @vertexBufferSize, @indexBufferSize, NULL) 
	    'Print myInstance, vertexBufferSize, indexBufferSize
	
	    if (vertexBufferSize AndAlso indexBufferSize) Then 
	  		  Print "correcto,generando modelo..."
	  		  
	        Dim As Single Ptr vertices = Callocate (CInt(vertexBufferSize) * (CInt(vertexElementSizeInBytes) / sizeof(Single)) , sizeof(Single)) 
	        Dim As long   Ptr  indices = Callocate (CInt(indexBufferSize) , SizeOf(long) ) 
	
	        UpdateInstanceVertexBuffer(myInstance, vertices) 
	        UpdateInstanceIndexBuffer (myInstance, indices) 
	
	        Dim As INT64_N triangleCnt = 0, lineCnt = 0, pointCnt = 0
	        Dim As INT64_N conceptualFaceCnt = GetConceptualFaceCnt(myInstance) 
	        for index As INT64_N = 0 To conceptualFaceCnt-1         
	            Dim As INT64_N startIndexTriangles = 0, noIndicesTriangles = 0
	            Dim As INT64_N startIndexLines = 0, noIndicesLines = 0
	            Dim As INT64_N startIndexPoints = 0, noIndicesPoints = 0 
	
					' depurando....
	            'Print GetConceptualFaceEx( _
	            '        myInstance, index, _
	            '        @startIndexTriangles, @noIndicesTriangles, _
	            '        @startIndexLines, @noIndicesLines, _
	            '        @startIndexPoints, @noIndicesPoints, _
	            '        0, 0, _
	            '        0, 0 _
	            '    ) 
	
	            '
	            '  Calculate space required for arrays
	            '
	            triangleCnt += noIndicesTriangles / 3 
	            lineCnt     += noIndicesLines / 2 
	            pointCnt    += noIndicesPoints 
	         Next
	
	        Dim As Long ptr triangleIndices = IIf(triangleCnt , callocate(3 * triangleCnt , SizeOf(Long)) , NULL )
	        Dim As Long ptr lineIndices     = IIf(lineCnt     , Callocate(2 *   lineCnt   , SizeOf(Long)) , NULL )
	        Dim As Long ptr pointIndices    = IIf(pointCnt    , Callocate(     pointCnt   , SizeOf(Long)) , NULL )
	
	        Dim As INT64_N triangleIndicesOffset = 0, lineIndicesOffset = 0, pointIndicesOffset = 0 
	        for index As INT64_N = 0 To conceptualFaceCnt-1         
	            Dim As INT64_N startIndexTriangles = 0, noIndicesTriangles = 0
	            Dim As INT64_N startIndexLines     = 0, noIndicesLines = 0
	            Dim As INT64_N startIndexPoints    = 0, noIndicesPoints = 0 
	
	            GetConceptualFaceEx( _
	                    myInstance, index, _
	                    @startIndexTriangles, @noIndicesTriangles, _
	                    @startIndexLines, @noIndicesLines, _
	                    @startIndexPoints, @noIndicesPoints, _
	                    0, 0, _
	                    0, 0 _
	                ) 
	
	            if (noIndicesTriangles) Then 
	                memcpy(@triangleIndices[triangleIndicesOffset], @indices[startIndexTriangles], noIndicesTriangles * sizeof(Long)) 
	                triangleIndicesOffset += noIndicesTriangles 
	            EndIf
	  
	            if (noIndicesLines) Then 
	                memcpy(@lineIndices[lineIndicesOffset], @indices[startIndexLines], noIndicesLines * sizeof(Long)) 
	                lineIndicesOffset += noIndicesLines 
	            EndIf
	
	            if (noIndicesPoints) Then 
	                memcpy(@pointIndices[pointIndicesOffset], @indices[startIndexPoints], noIndicesPoints * sizeof(Long)) 
	                pointIndicesOffset += noIndicesPoints 
	            EndIf
	         Next
	         
	        Delete indices 
	        'If (triangleIndicesOffset <> triangleCnt * 3) AndAlso _ 
	        '   (lineIndicesOffset <> lineCnt * 2) AndAlso _
	        '   (pointIndicesOffset <> pointCnt) Then  
	        '      Print "Error al crear entidad":Sleep:End
	        'End If
	
	        '
	        '  Now the index arrays for triagles, lines and puntos are ready
	        '      triangleIndices
	        '      lineIndices
	        '      pointIndices
	        '  all three are using the same vertex array
	        '      vertices
	        '
	
	        '
	        '  Based on the Collection we should find
	        '
	        '
	        'If (triangleCnt <> 36 * 2 + 2 * (36 - 2)) Then Print "The collection contained 1 cylinder (with segmentation parts 36)":Sleep:end
	        'If (lineCnt  <> 2) Then Print "The collection contained 2 lineas":Sleep:end
	        'If (pointCnt <> 3) Then Print "The collection contained 3 puntos":Sleep:end
	
	        '...
	        '...     //  use the vertex and index array for visualization, QTO, conversion etc.
	        '...
	        'For f As Integer=0 To 20
	        '	Print vertices[f];
	        'Next
	        'Print
	        'print
	        'For f As Integer=0 To 40
	        '	Print indices[f];
	        'Next
	        	
	        Delete vertices 
	        
	        if (triangleIndices) Then 
	   			Delete triangleIndices  
	        EndIf
	  
	        if (lineIndices) Then 
	   			Delete lineIndices  
	        EndIf
	  
	        if (pointIndices) Then 
	   			Delete pointIndices  
	        EndIf
	        
		    '
		    '  The resulting model can be viewed in 3D-Editor.exe
		    '
		    SaveModel(model, "myFile.bin") 
		    CloseModel(model) 
			beep
	    EndIf
	   
	EndIf
  
  

  sleep
