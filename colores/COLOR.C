

void pp(void)
{
	LongInt model = CreateModel();

	if (model) {
		//
		//  Classes
		//
		LongInt classColor = GetClassByName(model, "Color");
		LongInt classColorComponent = GetClassByName(model, "ColorComponent");
		LongInt classCube = GetClassByName(model, "Cube");
		LongInt classMaterial = GetClassByName(model, "Material");

		//
		//  Object Properties (relations)
		//
		LongInt propertyAmbient = GetPropertyByName(model, "ambient");
		LongInt propertyColor = GetPropertyByName(model, "color");
		LongInt propertyDiffuse = GetPropertyByName(model, "diffuse");
		LongInt propertyEmissive = GetPropertyByName(model, "emissive");
		LongInt propertyMaterial = GetPropertyByName(model, "material");
		LongInt propertySpecular = GetPropertyByName(model, "specular");

		//
		//  Datatype Properties (attributes)
		//
		LongInt propertyB = GetPropertyByName(model, "B");
		LongInt propertyG = GetPropertyByName(model, "G");
		LongInt propertyLength = GetPropertyByName(model, "length");
		LongInt propertyR = GetPropertyByName(model, "R");
		LongInt propertyW = GetPropertyByName(model, "W");

		//
		//  Instances (creating)
		//
		LongInt myInstanceColor = CreateInstance(classColor, nullptr);
		LongInt myInstanceColorComponent = CreateInstance(classColorComponent, nullptr);
		LongInt myInstanceCube = CreateInstance(classCube, nullptr);
		LongInt myInstanceMaterial = CreateInstance(classMaterial, nullptr);

		SetObjectProperty(myInstanceColor, propertyAmbient, &myInstanceColorComponent, 1);
		SetObjectProperty(myInstanceColor, propertyDiffuse, &myInstanceColorComponent, 1);
		SetObjectProperty(myInstanceColor, propertyEmissive, &myInstanceColorComponent, 1);
		SetObjectProperty(myInstanceColor, propertySpecular, &myInstanceColorComponent, 1);

		double R = 0.0, G = 1.0, B = 0.0, W = 0.5;
		SetDatatypeProperty(myInstanceColorComponent, propertyR, &R, 1);
		SetDatatypeProperty(myInstanceColorComponent, propertyG, &G, 1);
		SetDatatypeProperty(myInstanceColorComponent, propertyB, &B, 1);
		SetDatatypeProperty(myInstanceColorComponent, propertyW, &W, 1);

		double length = 1.8;       
		SetDatatypeProperty(myInstanceCube, propertyLength, &length, 1);
		SetObjectProperty(myInstanceCube, propertyMaterial, &myInstanceMaterial, 1);

		SetObjectProperty(myInstanceMaterial, propertyColor, &myInstanceColor, 1);

		//
		//  The resulting model can be viewed in 3D-Editor.exe
		//
		SaveModel(model, "c:\\created\\myColor.bin");
		CloseModel(model);
	}
}