class_name Utils
extends Node3D


static func get_first_child_of_type(parent: Node, type: Variant) -> Node:
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
	return null


static func get_all_children_of_type(parent: Node, type: Variant) -> Array[Node]:
	var result: Array[Node] = []

	for child in parent.get_children():
		if is_instance_of(child, type):
			result.append(child)

	return result


static func clear_children(parent: Node) -> void:
	for child in parent.get_children():
		# print("freeing %s" % child.name)
		child.queue_free()


static func load_resources_from_dir(path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir = DirAccess.open(path)
	
	if not dir:
		printerr("Directory access failed: ", path)
		return resources
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			var file_path = path.path_join(file_name)
			
			# Handle exported build file renaming
			file_path = file_path.trim_suffix(".remap")
			
			# Skip .import metadata files
			if file_path.ends_with(".import"):
				file_name = dir.get_next()
				continue
				
			var resource = load(file_path)
			if resource:
				resources.append(resource)
				
		file_name = dir.get_next()
		
	return resources


static func load_resources_to_dict(path: String, key_extractor: Callable) -> Dictionary:
	var dict: Dictionary = {}
	var dir = DirAccess.open(path)
	
	if not dir:
		printerr("Directory access failed: ", path)
		return dict
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			var file_path = path.path_join(file_name)
			file_path = file_path.trim_suffix(".remap")
			
			if file_path.ends_with(".import"):
				file_name = dir.get_next()
				continue
				
			var resource = load(file_path)
			if resource:
				# Execute the lambda to determine the key
				var key = key_extractor.call(resource, file_name)
				if key != null:
					dict[key] = resource
				
		file_name = dir.get_next()
		
	return dict


static func load_resources_to_dict_recursive(path: String, key_extractor: Callable, dict: Dictionary = {}) -> Dictionary:
	var dir = DirAccess.open(path)
	
	if not dir:
		printerr("Directory access failed: ", path)
		return dict
		
	# Process files in current directory
	for file_name in dir.get_files():
		var file_path = path.path_join(file_name).trim_suffix(".remap")
		
		if file_path.ends_with(".import"):
			continue
			
		var resource = load(file_path)
		if resource:
			var key = key_extractor.call(resource, file_name)
			if key != null:
				dict[key] = resource
				
	# Recurse into subdirectories
	for dir_name in dir.get_directories():
		var sub_path = path.path_join(dir_name)
		load_resources_to_dict_recursive(sub_path, key_extractor, dict)
		
	return dict
