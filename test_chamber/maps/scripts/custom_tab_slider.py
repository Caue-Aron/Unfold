import bpy

# Define a custom property for the slider
def create_slider_property():
    bpy.types.Scene.my_slider = bpy.props.FloatProperty(
        name="My Slider", 
        description="A custom slider", 
        default=0.5, 
        min=0.0, 
        max=10.0, 
        step=0.2, 
        precision=2,
        update=update_objects_property  # This is the update function
    )

# Function to update the custom property for all objects
def update_objects_property(self, context):
    slider_value = self.my_slider
    # Set the custom property 'my_slider_value' for all objects (including EMPTY)
    for obj in bpy.context.scene.objects:
        if obj.type in {'MESH', 'EMPTY'}:  # Include both MESH and EMPTY types
            obj["my_slider_value"] = slider_value

# Function to ensure the custom property is set for newly created objects
def add_custom_property_on_creation(scene, depsgraph):
    for obj in depsgraph.objects:
        if obj.is_updated or obj.is_new:  # Check if the object is newly created or updated
            if obj.type in {'MESH', 'EMPTY'}:  # Only add custom property for MESH or EMPTY
                if "my_slider_value" not in obj:
                    obj["my_slider_value"] = scene.my_slider

# Define a custom panel for the tab with the slider
class MyCustomPanel(bpy.types.Panel):
    bl_label = "My Custom Tab"
    bl_idname = "SCENE_PT_custom_tab"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "My Tab"  # This is the name of the custom tab

    def draw(self, context):
        layout = self.layout
        scene = context.scene
        
        # Add the slider to the panel
        layout.prop(scene, "my_slider")  # This shows the slider

# Register the classes and properties
def register():
    create_slider_property()  # Register the custom property
    bpy.utils.register_class(MyCustomPanel)
    
    # Add handler to automatically add custom property when a new object is created
    bpy.app.handlers.depsgraph_update_post.append(add_custom_property_on_creation)

def unregister():
    bpy.utils.unregister_class(MyCustomPanel)
    del bpy.types.Scene.my_slider
    
    # Remove the handler when the script is unregistered
    bpy.app.handlers.depsgraph_update_post.remove(add_custom_property_on_creation)

if __name__ == "__main__":
    register()
