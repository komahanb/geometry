import pyvista as pv

mesh = pv.read("hub4b.vtk")
print(mesh.point_data.keys())
print(mesh.cell_data.keys())
mesh.plot(cmap="viridis", show_edges=False)
