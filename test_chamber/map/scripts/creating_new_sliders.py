import bpy

# NEEDS NOT ALLOWING SAME NAME PROPERTIES

# Function to create the properties on the Scene
def create_slider_property(name, min_val, max_val, step, precision):
    """
    This function creates a new FloatProperty for a slider and adds it to the Scene.
    
    Args:
        name (str): The name of the slider.
        min_val (float): Minimum value for the slider.
        max_val (float): Maximum value for the slider.
        step (int): Step size for the slider increments.
        precision (int): The number of decimal places the slider will have.
    """
    # Create a new FloatProperty dynamically based on the provided parameters
    prop = bpy.props.FloatProperty(
        name=name,  # Set the slider name
        description=f"Slider {name}",  # Description for the slider
        default=(min_val + max_val) / 2,  # Default set to the middle of the range
        min=min_val,  # Minimum value for the slider
        max=max_val,  # Maximum value for the slider
        step=step,  # Step size for the slider
        precision=precision,  # Precision (number of decimal places)
    )
    
    # Add the created property to the Scene, using a unique name for each slider
    setattr(bpy.types.Scene, f"slider_{name}", prop)


# Panel for creating new sliders in the UI
class SliderCreationPanel(bpy.types.Panel):
    """
    Panel for creating new sliders in the 3D View. It contains input fields to specify the properties
    of the slider, such as name, minimum, maximum, step, and precision, and a button to create it.
    """
    bl_label = "Create Slider"  # Title of the panel
    bl_idname = "SCENE_PT_slider_creation"  # Unique ID for the panel
    bl_space_type = 'VIEW_3D'  # Space where the panel will appear (in the 3D View)
    bl_region_type = 'UI'  # Region where the panel will appear (UI region)
    bl_category = "Slider Tools"  # Name of the custom tab for creating sliders

    def draw(self, context):
        """
        Builds the UI layout for the Slider Creation panel.
        This panel allows the user to input slider properties and create a new slider.
        """
        layout = self.layout
        scene = context.scene
        
        # Input fields for slider parameters
        layout.prop(scene, "new_slider_name")  # Name input field
        layout.prop(scene, "new_slider_min")  # Min value input field
        layout.prop(scene, "new_slider_max")  # Max value input field
        layout.prop(scene, "new_slider_step")  # Step size input field
        layout.prop(scene, "new_slider_precision")  # Precision input field
        
        # Button to create the slider
        layout.operator("scene.create_slider", text="Create Slider")


# Operator to create the slider dynamically
class CreateSliderOperator(bpy.types.Operator):
    """
    Operator that is called when the user clicks the 'Create Slider' button.
    It takes the values from the properties (name, min, max, step, precision),
    creates the new slider, and adds it to the list of created sliders.
    """
    bl_idname = "scene.create_slider"  # Unique ID for the operator
    bl_label = "Create Slider"  # Label for the operator

    def execute(self, context):
        """
        Executes the creation of a new slider based on the input values from the user.
        It adds the slider to the Scene and records its name in the created sliders list.
        
        Args:
            context: The context in which the operator is executed (used to access the Scene properties).
        
        Returns:
            {'FINISHED'}: Indicates the operation was successful.
        """
        scene = context.scene
        
        # Retrieve the values for the slider from the input properties
        name = scene.new_slider_name
        min_val = scene.new_slider_min
        max_val = scene.new_slider_max
        step = scene.new_slider_step
        precision = scene.new_slider_precision
        
        # Create the new slider property on the Scene
        create_slider_property(name, min_val, max_val, step, precision)
        
        # Add the name of the new slider to the list of created sliders
        new_slider = scene.created_sliders.add()  # Add a new item to the collection
        new_slider.name = name  # Store the name of the created slider

        return {'FINISHED'}  # Return success


# Panel to display the created sliders in the UI
class CreatedSlidersPanel(bpy.types.Panel):
    """
    Panel that displays all the created sliders. Each slider will be shown with its name, and
    the user can interact with the slider value directly.
    """
    bl_label = "Created Sliders"  # Title of the panel
    bl_idname = "SCENE_PT_created_sliders"  # Unique ID for the panel
    bl_space_type = 'VIEW_3D'  # Space where the panel will appear
    bl_region_type = 'UI'  # Region where the panel will appear
    bl_category = "Slider Tools"  # The tab where the panel will appear

    def draw(self, context):
        """
        Builds the UI layout for the Created Sliders panel. It shows all created sliders 
        and allows the user to interact with each of them.
        
        Args:
            context: The context in which the panel is drawn.
        """
        layout = self.layout
        scene = context.scene
        
        # Loop through all created sliders and display them
        for slider in scene.created_sliders:
            layout.label(text=f"Slider: {slider.name}")  # Display slider's name
            layout.prop(scene, f"slider_{slider.name}")  # Display slider control


# Register properties and classes
def register():
    """
    Registers the properties and UI panels with Blender.
    It also registers the operator that creates new sliders.
    """
    # Register the properties for slider creation
    bpy.types.Scene.new_slider_name = bpy.props.StringProperty(name="Slider Name", default="NewSlider")
    bpy.types.Scene.new_slider_min = bpy.props.FloatProperty(name="Min Value", default=0.0)
    bpy.types.Scene.new_slider_max = bpy.props.FloatProperty(name="Max Value", default=1.0)
    bpy.types.Scene.new_slider_step = bpy.props.IntProperty(name="Step", default=1)
    bpy.types.Scene.new_slider_precision = bpy.props.IntProperty(name="Precision", default=2)
    
    # Collection property to store created sliders' names
    bpy.types.Scene.created_sliders = bpy.props.CollectionProperty(type=bpy.types.PropertyGroup)
    
    # Register the panel classes
    bpy.utils.register_class(SliderCreationPanel)
    bpy.utils.register_class(CreateSliderOperator)
    bpy.utils.register_class(CreatedSlidersPanel)


def unregister():
    """
    Unregisters the properties and panels when the script is disabled or removed.
    """
    # Unregister the panel classes
    bpy.utils.unregister_class(SliderCreationPanel)
    bpy.utils.unregister_class(CreateSliderOperator)
    bpy.utils.unregister_class(CreatedSlidersPanel)

    # Unregister the properties
    del bpy.types.Scene.new_slider_name
    del bpy.types.Scene.new_slider_min
    del bpy.types.Scene.new_slider_max
    del bpy.types.Scene.new_slider_step
    del bpy.types.Scene.new_slider_precision
    del bpy.types.Scene.created_sliders


# Execute the register function when the script is run
if __name__ == "__main__":
    register()
