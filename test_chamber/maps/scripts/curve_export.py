import bpy
import mathutils
from bpy_extras.io_utils import ExportHelper

def bezier_interpolate(p0, p1, p2, p3, t):
    """Evaluate a Bezier curve at time t (0 <= t <= 1) for a cubic Bezier curve (p0, p1, p2, p3)."""
    p0 = (1 - t) * p0 + t * p1
    p1 = (1 - t) * p1 + t * p2
    p2 = (1 - t) * p2 + t * p3
    p0 = (1 - t) * p0 + t * p1
    p1 = (1 - t) * p1 + t * p2
    return (1 - t) * p0 + t * p1

def get_bezier_points(spline, resolution):
    """Get the interpolated points along the Bezier spline based on its resolution."""
    points = []
    for i in range(len(spline.bezier_points) - 1):
        p0 = spline.bezier_points[i].co
        p1 = spline.bezier_points[i].handle_right
        p2 = spline.bezier_points[i + 1].handle_left
        p3 = spline.bezier_points[i + 1].co
        for j in range(resolution + 1):
            t = j / resolution
            point = bezier_interpolate(p0, p1, p2, p3, t)
            points.append(point)
    return points

def prepare_curve_for_export():
    """Add interpolated points as a temporary custom property to all curve objects."""
    for obj in bpy.context.scene.objects:
        if obj.type == 'CURVE':
            resolution = obj.data.resolution_u
            line_points = []
            for spline in obj.data.splines:
                if spline.type == 'BEZIER':
                    interpolated_points = get_bezier_points(spline, resolution)
                    line_points.extend(interpolated_points)
            serialized_points = [(float(format(p.x, ".3f")), float(format(p.y, ".3f")), float(format(p.z, ".3f"))) for p in line_points]
            obj["interpolated_points"] = serialized_points

def cleanup_curve_export_data():
    """Remove temporary custom properties from all curve objects."""
    for obj in bpy.context.scene.objects:
        if "interpolated_points" in obj:
            del obj["interpolated_points"]

unfold_version = "Unfold GLTF 0.1"

class CustomGLTFExportOperator(bpy.types.Operator, ExportHelper):
    bl_idname = "export_scene.custom_gltf"
    bl_label = unfold_version
    
    filename_ext = ".gltf"
    filter_glob: bpy.props.StringProperty(
        default="*.gltf",
        options={"HIDDEN"},
        maxlen=255
    )


    def execute(self, context):
        if not self.filepath:
            return {'CANCELLED'}

        # Pre-export code
        self.pre_export_operations()

        # Export glTF
        bpy.ops.export_scene.gltf(
            filepath=self.filepath,
            export_format='GLTF_SEPARATE',
            export_extras=True
        )

        # Post-export code
        self.post_export_operations()

        return {'FINISHED'}

    def pre_export_operations(self):
        # Add your pre-export code here
        print("Running pre-export operations...")
        prepare_curve_for_export()

    def post_export_operations(self):
        # Add your post-export code here
        print("Running post-export operations...")
        cleanup_curve_export_data()

def menu_func_export(self, context):
    self.layout.operator(CustomGLTFExportOperator.bl_idname, text=unfold_version)

def register():
    bpy.utils.register_class(CustomGLTFExportOperator)
    bpy.types.TOPBAR_MT_file_export.append(menu_func_export)

def unregister():
    bpy.utils.unregister_class(CustomGLTFExportOperator)
    bpy.types.TOPBAR_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()
