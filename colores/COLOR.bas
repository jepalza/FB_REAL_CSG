'#Include "fbgfx.bi"

' necesario para evitar los mensajes WARNING del STDCALL al "linkar" LD con la DLL
#cmdline "-Wl --enable-stdcall-fixup"

#Include "windows.bi" ' necesario para el MEMCPY nada mas (por ahora)

#Include "engine.bi"


Sub pp()

	Dim As LongInt model = CreateModel() 

	if (model) Then 
  
		''
		''  Classes
		''
		Dim As LongInt classColor = GetClassByName(model, "Color") 
		Dim As LongInt classColorComponent = GetClassByName(model, "ColorComponent") 
		Dim As LongInt classCube = GetClassByName(model, "Cube") 
		Dim As LongInt classMaterial = GetClassByName(model, "Material") 

		''
		''  Object Properties (relations)
		''
		Dim As LongInt propertyAmbient = GetPropertyByName(model, "ambient") 
		Dim As LongInt propertyColor = GetPropertyByName(model, "color") 
		Dim As LongInt propertyDiffuse = GetPropertyByName(model, "diffuse") 
		Dim As LongInt propertyEmissive = GetPropertyByName(model, "emissive") 
		Dim As LongInt propertyMaterial = GetPropertyByName(model, "material") 
		Dim As LongInt propertySpecular = GetPropertyByName(model, "specular") 

		''
		''  Datatype Properties (attributes)
		''
		Dim As LongInt propertyB = GetPropertyByName(model, "B") 
		Dim As LongInt propertyG = GetPropertyByName(model, "G") 
		Dim As LongInt propertyLength = GetPropertyByName(model, "length") 
		Dim As LongInt propertyR = GetPropertyByName(model, "R") 
		Dim As LongInt propertyW = GetPropertyByName(model, "W") 

		''
		''  Instances (creating)
		''
		Dim As LongInt myInstanceColor = CreateInstance(classColor, NULL) 
		Dim As LongInt myInstanceColorComponent = CreateInstance(classColorComponent, NULL) 
		Dim As LongInt myInstanceCube = CreateInstance(classCube, NULL) 
		Dim As LongInt myInstanceMaterial = CreateInstance(classMaterial, NULL) 

		SetObjectProperty(myInstanceColor, propertyAmbient, @myInstanceColorComponent, 1) 
		SetObjectProperty(myInstanceColor, propertyDiffuse, @myInstanceColorComponent, 1) 
		SetObjectProperty(myInstanceColor, propertyEmissive, @myInstanceColorComponent, 1) 
		SetObjectProperty(myInstanceColor, propertySpecular, @myInstanceColorComponent, 1) 

		Dim As Double R = 0.0, G = 1.0, B = 0.0, W = 0.5 
		SetDatatypeProperty(myInstanceColorComponent, propertyR, @R, 1) 
		SetDatatypeProperty(myInstanceColorComponent, propertyG, @G, 1) 
		SetDatatypeProperty(myInstanceColorComponent, propertyB, @B, 1) 
		SetDatatypeProperty(myInstanceColorComponent, propertyW, @W, 1) 

		Dim As Double length = 1.8 
		SetDatatypeProperty(myInstanceCube, propertyLength, @length, 1) 
		SetObjectProperty(myInstanceCube, propertyMaterial, @myInstanceMaterial, 1) 

		SetObjectProperty(myInstanceMaterial, propertyColor, @myInstanceColor, 1) 

		''
		''  The resulting model can be viewed in 3D-Editor.exe
		''
		SaveModel(model, "myColor.bin") 
		CloseModel(model) 
	
EndIf
  
End Sub


pp()

