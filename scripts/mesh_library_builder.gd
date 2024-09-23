@tool
extends EditorScript

# Function to generate MeshLibrary from the objects in the terrain folder
func _run():
	# Path to the folder containing terrain objects
	var terrain_folder = "res://assets/models/terrain/"

	# Load the MeshLibrary resource
	var mesh_library = MeshLibrary.new()

	# Get the list of all resources (files) in the terrain folder
	var dir = DirAccess.open(terrain_folder)
	if dir != null:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Filter only .mesh or compatible resources
			if file_name.ends_with(".obj"):
				var mesh_path = terrain_folder + file_name
				var mesh = load(mesh_path)
				
				# Add mesh to the MeshLibrary
				if mesh != null and mesh is ArrayMesh:
					var mesh_id = mesh_library.get_last_unused_item_id() + 1
					mesh_library.create_item(mesh_id)
					mesh_library.set_item_mesh(mesh_id, mesh)
					print("Added mesh: ", mesh_path, " to library with ID: ", mesh_id)
				
			file_name = dir.get_next()

		dir.list_dir_end()
		
		# Save the mesh library to a file (optional)
		var library_path = "res://terrain_mesh_library.tres"
		ResourceSaver.save(library_path, mesh_library)
		print("MeshLibrary saved to: ", library_path)

	else:
		print("Failed to open directory: ", terrain_folder)
