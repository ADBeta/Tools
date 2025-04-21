###############################################################################
# Generates a DXF File, in mm, with a spiral in the center
# Requires ezpdf
# (c) ADBeta    22 Feb 2025
###############################################################################
import ezdxf
import math

# Generates a .DXF File with the given name, with given parameters
def generate_spiral_dxf(filename, inner_radius, outer_radius, spacing):
    # Sanity check that the spacing & radii are valid
    if inner_radius >= outer_radius:
        raise ValueError("Inner Radius cannot be greater than Outer Radius")
    if spacing <= 0:
        raise ValueError("Spacing cannot be 0 or Negative")

    # Create a new document, INSUNITS 4 = Millimeters in AutoCAD Units
    doc = ezdxf.new(setup=True)
    doc.header['$INSUNITS'] = 4
        
    ### Generate the points of the spiral ###
    points_cnt = 0
    spiral_points = []

    # Current Angle in Radians, and Current Radius
    c_theta = 0
    c_radius = inner_radius
    
    while c_radius <= outer_radius:
        point_x = c_radius * math.cos(c_theta)
        point_y = c_radius * math.sin(c_theta)
        spiral_points.append((point_x, point_y))
        
        # Incriment the angle for the next line, Adjust value to change smoothness
        # Lower angle step is smoother
        c_theta += math.radians(5)
        # Incriment the radius
        c_radius = inner_radius + (c_theta / (2 * math.pi)) * spacing

        points_cnt += 1
    

    # Create a modelspace then plot the polyline
    msp = doc.modelspace()
    msp.add_lwpolyline(spiral_points)
    
    # Save DXF file
    doc.saveas(filename)
    print(f"DXF file '{filename}' generated successfully.    {points_cnt - 1} lines")


# Example usage
generate_spiral_dxf("spiral.dxf", inner_radius=15, outer_radius=25, spacing=0.5)
