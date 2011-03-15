package {
    import com.adobe.utils.AGALMiniAssembler;

    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;

    [SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]
    public class MolehillExample extends Sprite {
        private var stage3D:Stage3D;
        private var program3D:Program3D;
        private var vertexBuffer:VertexBuffer3D;
        private var indexBuffer:IndexBuffer3D;
        private var matrix3D:Matrix3D;

        public function MolehillExample () {
            stage3D = stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3dCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
            stage3D.viewPort = new Rectangle(0, 0, 640, 480);

            matrix3D = new Matrix3D();

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onContext3dCreate (e:Event):void {
            var context3D:Context3D = stage3D.context3D;
            context3D.configureBackBuffer(640, 480, 1, false);

            vertexBuffer = context3D.createVertexBuffer(3, 6);
            vertexBuffer.uploadFromVector(
                    Vector.<Number>([-1,-1,0,1,0,0,0,1,0,0.75,0.8,0.3,1,-1,0,0,0.5,0.9]),
                    0, 3);

            indexBuffer = context3D.createIndexBuffer(3);
            indexBuffer.uploadFromVector(Vector.<uint>([0,1,2]), 0, 3);

            var assembler:AGALMiniAssembler = new AGALMiniAssembler();
            assembler.assemble(Context3DProgramType.VERTEX,
                    "m44 op, va0, vc0\n" +
                            "mov v0, va1\n");
            var vertexCode:ByteArray = assembler.agalcode;

            assembler.assemble(Context3DProgramType.FRAGMENT,
                    "mov oc, v0");
            var fragmentCode:ByteArray = assembler.agalcode;

            program3D = context3D.createProgram();
            program3D.upload(vertexCode, fragmentCode);
        }

        private function onEnterFrame (event:Event):void {
            var context3D:Context3D = stage3D.context3D;
            if (context3D == null) {
                return;
            }

            context3D.clear(0, 0, 0, 1);
            context3D.setProgram(program3D);

            context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);

            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix3D, true);

            context3D.drawTriangles(indexBuffer, 0, 1);
            context3D.present();

            matrix3D.appendRotation(1, Vector3D.Z_AXIS);
        }

    }
}
