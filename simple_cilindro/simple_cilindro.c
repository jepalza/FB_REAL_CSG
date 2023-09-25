#include    "./include/engine.h"

static  const   uint64_t    flagbit0 = 1;                           // 2^^0                          0000.0000..0000.0001
static  const   uint64_t    flagbit1 = 2;                           // 2^^1                          0000.0000..0000.0010
static  const   uint64_t    flagbit2 = 4;                           // 2^^2                          0000.0000..0000.0100
static  const   uint64_t    flagbit3 = 8;                           // 2^^3                          0000.0000..0000.1000

static  const   uint64_t    flagbit4 = 16;                          // 2^^4                          0000.0000..0001.0000
static  const   uint64_t    flagbit5 = 32;                          // 2^^5                          0000.0000..0010.0000
static  const   uint64_t    flagbit6 = 64;                          // 2^^6                          0000.0000..0100.0000
static  const   uint64_t    flagbit7 = 128;                         // 2^^7                          0000.0000..1000.0000

static  const   uint64_t    flagbit8 = 256;                         // 2^^8                          0000.0001..0000.0000
static  const   uint64_t    flagbit9 = 512;                         // 2^^9                          0000.0010..0000.0000
static  const   uint64_t    flagbit10 = 1024;                       // 2^^10                         0000.0100..0000.0000
static  const   uint64_t    flagbit11 = 2048;                       // 2^^11                         0000.1000..0000.0000

static  const   uint64_t    flagbit12 = 4096;                       // 2^^12                         0001.0000..0000.0000
static  const   uint64_t    flagbit13 = 8192;                       // 2^^13                         0010.0000..0000.0000
static  const   uint64_t    flagbit14 = 16384;                      // 2^^14                         0100.0000..0000.0000
static  const   uint64_t    flagbit15 = 32768;                      // 2^^15                         1000.0000..0000.0000

void pp()
{

int64_t model = CreateModel();

if (model) {
    //
    //  Classes
    //
    int64_t classCollection = GetClassByName(model, "Collection"),
            classCylinder = GetClassByName(model, "Cylinder"),
            classLine3D = GetClassByName(model, "Line3D"),
            classPoint3D = GetClassByName(model, "Point3D");

    //
    //  Object Properties (relations)
    //
    int64_t propertyObjects = GetPropertyByName(model, "objects");

    //
    //  Datatype Properties (attributes)
    //
    int64_t propertyCoordinates = GetPropertyByName(model, "coordinates"),
            propertyLength = GetPropertyByName(model, "length"),
            propertyPoints = GetPropertyByName(model, "points"),
            propertyRadius = GetPropertyByName(model, "radius"),
            propertySegmentationParts = GetPropertyByName(model, "segmentationParts");

    //
    //  Instances (creating)
    //
    int64_t instanceCollection = CreateInstance(classCollection, nullptr),
            instanceCylinder = CreateInstance(classCylinder, nullptr),
            instanceLine3D = CreateInstance(classLine3D, nullptr),
            instancePoint3D_I = CreateInstance(classPoint3D, nullptr),
            instancePoint3D_II = CreateInstance(classPoint3D, nullptr);

    int64_t objects[6] = { instancePoint3D_I, instanceLine3D, instanceLine3D, instancePoint3D_II, instanceCylinder, instancePoint3D_I };
    SetObjectProperty(instanceCollection, propertyObjects, objects, 6);

    double  coordinates_I[3] = { 1., 2., 3. },
            coordinates_II[3] = { 4., 5., 6. },
            length = 4.,
            points[6] = { 0., 0., -1., 5., 3., 0. },
            radius = 2.;
    int64_t segmentationParts = 36;

    SetDatatypeProperty(instanceCylinder, propertyLength, &length, 1);
    SetDatatypeProperty(instanceCylinder, propertyRadius, &radius, 1);
    SetDatatypeProperty(instanceCylinder, propertySegmentationParts, &segmentationParts, 1);
    SetDatatypeProperty(instanceLine3D, propertyPoints, points, 6);
    SetDatatypeProperty(instancePoint3D_I, propertyCoordinates, coordinates_I, 3);
    SetDatatypeProperty(instancePoint3D_II, propertyCoordinates, coordinates_II, 3);

    int64_t myInstance = instanceCollection;

    //...
    //...     //  create, load or edit myInstance, in this case a simple Collection is used as input
    //...

    //
    //  Initializing the mask with all possible options
    //
    int64_t setting = 0,
            mask = GetFormat(0, 0);

    setting += 0 * flagbit2;        //    SINGLE / DOUBLE PRECISION (float / double)
    setting += 0 * flagbit3;        //    32 / 63 BIT INDEX ARRAY (int32_t / int64_t)

    setting += 1 * flagbit4;        //    OFF / ON VECTORS (x, y, z) 
    setting += 1 * flagbit5;        //    OFF / ON NORMALS (Nx, Ny, Nz)

    setting += 1 * flagbit8;        //    OFF / ON TRIANGLES
    setting += 1 * flagbit9;        //    OFF / ON LINES
    setting += 1 * flagbit10;       //    OFF / ON POINTS

    setting += 0 * flagbit12;       //    OFF / ON WIREFRAME FACES
    setting += 0 * flagbit13;       //    OFF / ON WIREFRAME CONCEPTUAL FACES

    int64_t vertexElementSizeInBytes = SetFormat(model, setting, mask);
    assert(vertexElementSizeInBytes == (3 + 3) * sizeof(float));

    //...

    int64_t vertexBufferSize = 0, indexBufferSize = 0;
    CalculateInstance(myInstance, &vertexBufferSize, &indexBufferSize, nullptr);

    if (vertexBufferSize && indexBufferSize) {
        float   * vertices = new float[(int_t) vertexBufferSize * ((int_t) vertexElementSizeInBytes / sizeof(float))];
        int32_t * indices = new int32_t[(int_t) indexBufferSize];

        UpdateInstanceVertexBuffer(myInstance, vertices);
        UpdateInstanceIndexBuffer(myInstance, indices);

        int64_t triangleCnt = 0, lineCnt = 0, pointCnt = 0,
                conceptualFaceCnt = GetConceptualFaceCnt(myInstance);
        for (int64_t index = 0; index < conceptualFaceCnt; index++) {
            int64_t startIndexTriangles = 0, noIndicesTriangles = 0,
                    startIndexLines = 0, noIndicesLines = 0,
                    startIndexPoints = 0, noIndicesPoints = 0;

            GetConceptualFace(
                    myInstance, index,
                    &startIndexTriangles, &noIndicesTriangles,
                    &startIndexLines, &noIndicesLines,
                    &startIndexPoints, &noIndicesPoints,
                    0, 0,
                    0, 0
                );

            //  
            //  Calculate space required for arrays
            //
            triangleCnt += noIndicesTriangles / 3;
            lineCnt += noIndicesLines / 2;
            pointCnt += noIndicesPoints;
        }

        int32_t * triangleIndices = triangleCnt ? new int32_t[(int_t) 3 * triangleCnt] : nullptr,
                * lineIndices = lineCnt ? new int32_t[(int_t) 2 * lineCnt] : nullptr,
                * pointIndices = pointCnt ? new int32_t[(int_t) pointCnt] : nullptr;

        int64_t triangleIndicesOffset = 0, lineIndicesOffset = 0, pointIndicesOffset = 0;
        for (int64_t index = 0; index < conceptualFaceCnt; index++) {
            int64_t startIndexTriangles = 0, noIndicesTriangles = 0,
                    startIndexLines = 0, noIndicesLines = 0,
                    startIndexPoints = 0, noIndicesPoints = 0;

            GetConceptualFace(
                    myInstance, index,
                    &startIndexTriangles, &noIndicesTriangles,
                    &startIndexLines, &noIndicesLines,
                    &startIndexPoints, &noIndicesPoints,
                    0, 0,
                    0, 0
                );

            if (noIndicesTriangles) {
                memcpy(&triangleIndices[triangleIndicesOffset], &indices[startIndexTriangles], noIndicesTriangles * sizeof(int32_t));
                triangleIndicesOffset += noIndicesTriangles;
            }

            if (noIndicesLines) {
                memcpy(&lineIndices[lineIndicesOffset], &indices[startIndexLines], noIndicesLines * sizeof(int32_t));
                lineIndicesOffset += noIndicesLines;
            }

            if (noIndicesPoints) {
                memcpy(&pointIndices[pointIndicesOffset], &indices[startIndexPoints], noIndicesPoints * sizeof(int32_t));
                pointIndicesOffset += noIndicesPoints;
            }
        }
        delete[] indices;
        assert(triangleIndicesOffset == triangleCnt * 3 && lineIndicesOffset == lineCnt * 2 && pointIndicesOffset == pointCnt);

        //
        //  Now the index arrays for triagles, lines and points are ready
        //      triangleIndices
        //      lineIndices
        //      pointIndices
        //  all three are using the same vertex array
        //      vertices
        //

        //
        //  Based on the Collection we should find
        //      
        //
        assert(triangleCnt == 36 * 2 + 2 * (36 - 2));   //  The collection contained 1 cylinder (with segmentation parts 36)
        assert(lineCnt == 2);                           //  The collection contained 2 lines
        assert(pointCnt == 3);                          //  The collection contained 3 points

        //...
        //...     //  use the vertex and index array for visualization, QTO, conversion etc.
        //...

        delete[] vertices;
        if (triangleIndices) { delete[] triangleIndices; }
        if (lineIndices) { delete[] lineIndices; }
        if (pointIndices) { delete[] pointIndices; }
    }

    //
    //  The resulting model can be viewed in 3D-Editor.exe
    //
    SaveModel(model, "c:\\created\\myFile.bin");
    CloseModel(model);
}

}