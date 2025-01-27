import bpy
import json
from bpy_extras.io_utils import ExportHelper
from bpy.props import StringProperty, BoolProperty, EnumProperty
from bpy.types import Operator

# Custom export operator for exporting a scene in a custom format (GLTF-like structure).
class ExportSceneOperator(Operator, ExportHelper):
    # The operator ID and label that will be displayed in Blender's UI.
    bl_idname = "export_scene.custom_gltf"  # Operator identifier
    bl_label = "Export Scene with Nodes"  # The label for the operator button in the UI
    filename_ext = ".gltf"  # Default file extension for the export.

    # A property that controls the file filter in the file browser. Only .gltf files are allowed.
    filter_glob: StringProperty(
        default="*.gltf",  # Set the default filter to .gltf files
        options={'HIDDEN'},  # The property is hidden in the UI
        maxlen=255,  # Maximum length for the file name.
    )

    # A boolean property for any settings the operator might use. In this case, an example boolean.
    use_setting: BoolProperty(
        name="Example Boolean",  # Name to display in the UI
        description="Example Tooltip",  # Tooltip to explain the property
        default=True,  # Default value for this property
    )

    # Enum property to allow the user to select from predefined options.
    type: EnumProperty(
        name="Example Enum",  # The name displayed in the UI
        description="Choose between two items",  # Tooltip for the enum property
        items=(  # Define the available options for this enum property
            ('OPT_A', "First Option", "Description one"),  # First option
            ('OPT_B', "Second Option", "Description two"),  # Second option
        ),
        default='OPT_A',  # Set the default value for the enum
    )

    def execute(self, context):
        # Initialize the scene data as a dictionary, which will be exported.
        scene_data = {
            "asset": {
                "generator": "Khronos glTF Blender I/O v4.3.47",  # Generator version information
                "version": "2.0"  # glTF version
            },
            "scene": 0,  # Index for the default scene
            "scenes": [],  # List of scenes (we'll add our scene to this)
            "nodes": []  # List of nodes (objects in the scene)
        }

        # Get the current scene and initialize an empty node_data dictionary.
        scene = bpy.context.scene
        node_data = {}

        # Iterate through all objects in the scene and add mesh/empty objects as nodes.
        for obj in bpy.context.view_layer.objects:
            if obj.type == 'MESH' or obj.type == 'EMPTY':  # Only add mesh and empty objects.
                # Create a node dictionary for each object with its name, translation (position),
                # rotation (orientation), and scale.
                node = {
                    "name": obj.name,  # Object's name
                    "translation": list(obj.location),  # Object's location as a list
                    "rotation": list(obj.rotation_euler),  # Object's rotation as Euler angles
                    "scale": list(obj.scale)  # Object's scale
                }

                # Add the node to the node_data dictionary, using the node name as the key.
                node_data[node["name"]] = node
                scene_data["nodes"].append(node)  # Append the node to the scene data.

        # Set up parent-child relationships between nodes.
        for idx, obj in enumerate(bpy.context.view_layer.objects):
            if obj.type == 'MESH' or obj.type == 'EMPTY':  # Only for mesh/empty objects.
                if obj.parent:  # Check if the object has a parent.
                    # Find the index of the parent node in the scene data.
                    parent_idx = next((i for i, n in enumerate(scene_data["nodes"]) if n["name"] == obj.parent.name), None)
                    if parent_idx is not None:  # Ensure the parent node was found.
                        if not "children" in scene_data["nodes"][parent_idx]:
                            scene_data["nodes"][parent_idx]["children"] = list()  # Create the children list if it doesn't exist.
                        # Add the current object index to the parent's children list.
                        scene_data["nodes"][parent_idx]["children"].append(idx)

        # Define the scene and link it to the root node (root node is assumed to be the first node).
        scene_data["scenes"].append({
            "name": scene.name,  # Use the scene's name
            "nodes": [0]  # The first node is the root node
        })

        # Write the scene data to a JSON file.
        with open(self.filepath, 'w', encoding='utf-8') as f:
            f.write(json.dumps(scene_data, indent=4))  # Convert the dictionary to a JSON string and write to the file.

        # Display a message in Blender's info panel that the export is complete.
        self.report({'INFO'}, f"Exported scene to {self.filepath}")
        return {'FINISHED'}  # Return 'FINISHED' to indicate the operator has completed.

# Register the operator so it can be used in the UI.
def menu_func(self, context):
    self.layout.operator(ExportSceneOperator.bl_idname, text="Export Scene with Nodes")

# Register the custom operator and add it to the export menu.
def register():
    bpy.utils.register_class(ExportSceneOperator)
    bpy.types.TOPBAR_MT_file_export.append(menu_func)

# Unregister the operator and remove it from the export menu when the script is disabled or unregistered.
def unregister():
    bpy.utils.unregister_class(ExportSceneOperator)
    bpy.types.TOPBAR_MT_file_export.remove(menu_func)

# Register the operator when the script is run directly.
if __name__ == "__main__":
    register()
