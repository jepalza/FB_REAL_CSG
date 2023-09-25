#Include "fbgfx.bi"

#Include "windows.bi"

#Inclib "engine"

#Include "engine.bi"

Dim Shared As Integer a 

Sub pp()

	Dim As LongInt model = CreateModel() 

    if (model) Then 
  
        ''
        ''  Classes
        ''
        Dim As LongInt classBooleanOperation = GetClassByName(model, "BooleanOperation"), _
                classCube = GetClassByName(model, "Cube"),_
                classCylinder = GetClassByName(model, "Cylinder"),_
                classMatrix = GetClassByName(model, "Matrix"),_
                classTransformation = GetClassByName(model, "Transformation") 

        ''
        ''  Object Properties (relations)
        ''
        Dim As LongInt propertyFirstObject = GetPropertyByName(model, "firstObject"),_
                propertyMatrix = GetPropertyByName(model, "matrix"),_
                propertyObject = GetPropertyByName(model, "object"),_
                propertySecondObject = GetPropertyByName(model, "secondObject") 

        ''
        ''  Datatype Properties (attributes)
        ''
        Dim As LongInt property_41 = GetPropertyByName(model, "_41"),_
                propertyLength = GetPropertyByName(model, "length"),_
                propertyRadius = GetPropertyByName(model, "radius"),_
                propertySegmentationParts = GetPropertyByName(model, "segmentationParts"),_
                propertyType = GetPropertyByName(model, "type") 

        ''
        ''  Instances
        ''
        Dim As LongInt instanceBooleanOperation = CreateInstance(classBooleanOperation, NULL),_
                instanceCube = CreateInstance(classCube, NULL),_
                instanceCylinder = CreateInstance(classCylinder, NULL),_
                instanceMatrix = CreateInstance(classMatrix, NULL),_
                instanceTransformation = CreateInstance(classTransformation, NULL) 

        SetObjectProperty(instanceTransformation, propertyObject, @instanceCylinder, 1) 
        SetObjectProperty(instanceTransformation, propertyMatrix, @instanceMatrix, 1) 

        Dim As Double  length = 1.8,_
                radius = 1.3,_
                offsetX = 4.2 
        Dim As LongInt segmentationParts = 36 

        SetDatatypeProperty(instanceCylinder, propertyLength, @length, 1) 
        SetDatatypeProperty(instanceCylinder, propertyRadius, @radius, 1) 
        SetDatatypeProperty(instanceCylinder, propertyFirstObject, @segmentationParts, 1) 
        SetDatatypeProperty(instanceMatrix, property_41, @offsetX, 1) 

        ''
        ''  Saves only the Transformation and (indirectly) related instances
        ''
        SaveInstanceTreeW(instanceTransformation, "TranformedCylinder.bin") 

        SetObjectProperty(instanceBooleanOperation, propertyFirstObject, @instanceCube, 1) 
        SetObjectProperty(instanceBooleanOperation, propertySecondObject, @instanceCylinder, 1) 

        length = 2.1 
        Dim As LongInt types = 1 

        SetDatatypeProperty(instanceCube, propertyLength, @length, 1) 
        SetDatatypeProperty(instanceBooleanOperation, propertyType, @types, 1) 

        ''
        ''  Saves all instances
        ''
        SaveModelW(model, "TranformedCylinderAndCubeWithSubtractedCylinder.bin") 

        ''
        ''  Saves only the Boolean Operation and (indirectly) related instances
        ''
        SaveInstanceTreeW(instanceBooleanOperation, "CubeWithSubtractedCylinder.bin") 

        CloseModel(model) 
	
EndIf
  
End Sub


pp()