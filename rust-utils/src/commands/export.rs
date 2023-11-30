use crate::prelude::*;
use std::fs;



pub fn function(args: &[String]) -> Result<()> {
	println!("Exporting shader...");
	
	let project_path = get_project_path()?;
	
	let shader_path = project_path.push_new("shaders");
	let output_path = project_path.push_new("export");
	
	if output_path.exists() {
		fs::remove_dir_all(&output_path)?;
	}
	fs::create_dir(&output_path)?;
	
	for folder_data in EXPORT_FOLDERS {
		copy_dir(project_path.push_new(folder_data.file_name), &output_path, &EMPTY_DIR_COPY_OPTIONS)?;
		if let Some(copy_name) = folder_data.copy_name {
			fs::rename(output_path.push_new(folder_data.file_name), output_path.push_new(copy_name))?;
		}
	}
	for file_data in EXPORT_FILES {
		copy_file(project_path.push_new(file_data.file_name), output_path.push_new(file_data.get_copy_name()), &EMPTY_FILE_COPY_OPTIONS)?;
	}
	
	println!("Done");
	Ok(())
}



pub const EMPTY_FILE_COPY_OPTIONS: FileCopyOptions = FileCopyOptions {
	overwrite: false,
	skip_exist: false,
	buffer_size: 64000, //64kb
};

pub const EMPTY_DIR_COPY_OPTIONS: DirCopyOptions = DirCopyOptions {
	overwrite: false,
	skip_exist: false,
	buffer_size: 64000, // 64kb
	copy_inside: false,
	content_only: false,
	depth: 0,
};
