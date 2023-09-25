
// pepe

int a;

void pp(void)
{  
	int64_t model = CreateModel();

    if (model) {
        //
        //  Classes
        //
        int64_t classBooleanOperation = GetClassByName(model, "BooleanOperation"),
                classCube = GetClassByName(model, "Cube"),
                classCylinder = GetClassByName(model, "Cylinder"),
                classMatrix = GetClassByName(model, "Matrix"),
                classTransformation = GetClassByName(model, "Transformation");

        //
        //  Object Properties (relations)
        //
        int64_t propertyFirstObject = GetPropertyByName(model, "firstObject"),
                propertyMatrix = GetPropertyByName(model, "matrix"),
                propertyObject = GetPropertyByName(model, "object"),
                propertySecondObject = GetPropertyByName(model, "secondObject");

        //
        //  Datatype Properties (attributes)
        //
        int64_t property_41 = GetPropertyByName(model, "_41"),
                propertyLength = GetPropertyByName(model, "length"),
                propertyRadius = GetPropertyByName(model, "radius"),
                propertySegmentationParts = GetPropertyByName(model, "segmentationParts"),
                propertyType = GetPropertyByName(model, "type");

        //
        //  Instances
        //
        int64_t instanceBooleanOperation = CreateInstance(classBooleanOperation, nullptr),
                instanceCube = CreateInstance(classCube, nullptr),
                instanceCylinder = CreateInstance(classCylinder, nullptr),
                instanceMatrix = CreateInstance(classMatrix, nullptr),
                instanceTransformation = CreateInstance(classTransformation, nullptr);

        SetObjectProperty(instanceTransformation, propertyObject, &instanceCylinder, 1);
        SetObjectProperty(instanceTransformation, propertyMatrix, &instanceMatrix, 1);

        double  length = 1.8,
                radius = 1.3,
                offsetX = 4.2;
        int64_t segmentationParts = 36;
        
        SetDatatypeProperty(instanceCylinder, propertyLength, &length, 1);
        SetDatatypeProperty(instanceCylinder, propertyRadius, &radius, 1);
        SetDatatypeProperty(instanceCylinder, propertyFirstObject, &segmentationParts, 1);
        SetDatatypeProperty(instanceMatrix, property_41, &offsetX, 1);

        //
        //  Saves only the Transformation and (indirectly) related instances
        //
        SaveInstanceTreeW(instanceTransformation, L"c:\\created\\TranformedCylinder.bin");

        SetObjectProperty(instanceBooleanOperation, propertyFirstObject, &instanceCube, 1);
        SetObjectProperty(instanceBooleanOperation, propertySecondObject, &instanceCylinder, 1);

        length = 2.1;
        int64_t type = 1;

        SetDatatypeProperty(instanceCube, propertyLength, &length, 1);
        SetDatatypeProperty(instanceBooleanOperation, propertyType, &type, 1);

        //
        //  Saves all instances
        //
        SaveModelW(model, L"c:\\created\\TranformedCylinderAndCubeWithSubtractedCylinder.bin");

        //
        //  Saves only the Boolean Operation and (indirectly) related instances
        //
        SaveInstanceTreeW(instanceBooleanOperation, L"c:\\created\\CubeWithSubtractedCylinder.bin");

        CloseModel(model);
	}
}