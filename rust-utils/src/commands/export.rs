use crate::prelude::*;
use std::{fs, io::{self, Write}};
use walkdir::{WalkDir, DirEntry};
use zip::{write::FileOptions, ZipWriter};



pub fn function(args: &[String]) -> Result<()> {
	
	println!("Enter version name:");
	let mut version = String::new();
	io::stdin().read_line(&mut version)?;
	let version = version.trim().to_string();
	
	println!("Exporting shader...");
	
	let options = FileOptions::default()
		.compression_method(zip::CompressionMethod::Deflated)
		.unix_permissions(0o755);
	
	let project_path = get_project_path()?;
	let project_path_len = project_path.as_os_str().len();
	let output_path = project_path.push_new(format!("What42's Shader Base {version}.zip"));
	
	let output_file = std::fs::File::create(output_path)?;
	let mut output_zip = ZipWriter::new(output_file);
	
	for file_data in EXPORT_FILES {
		output_zip.start_file(file_data.get_copy_name(), options)?;
		let file_contents = fs::read(project_path.push_new(file_data.file_name))?;
		output_zip.write_all(&file_contents)?;
	}
	
	for folder in EXPORT_FOLDERS {
		for entry in WalkDir::new(project_path.push_new(folder)) {
			let entry_path = match entry {
				Result::Ok(v) => v.into_path(),
				Result::Err(err) => {
					return Err(Error::msg(format!("Could not copy file: {err}")));
				}
			};
			let Some(entry_string) = entry_path.as_os_str().to_str() else {
				return Err(Error::msg(format!("Could not copy file {entry_path:?} because its path could not be parsed")));
			};
			let entry_zip_path = entry_string[project_path_len + 1 ..].to_string();
			if entry_path.is_dir() {
				output_zip.add_directory(entry_zip_path + "/", options)?;
				continue;
			}
			if entry_path.is_file() {
				output_zip.start_file(entry_zip_path, options)?;
				let file_contents = fs::read(entry_path)?;
				output_zip.write_all(&file_contents)?;
				continue;
			}
			println!("WARNING: Cannot handle unknown file: {entry_path:?}");
		}
	}
	
	output_zip.finish()?;
	println!("Done");
	println!();
	println!("======== WARNING: ========");
	println!("The .zip output of this doesn't seem to work, and you have to unzip then re-zip to make it work with Iris");
	Ok(())
}
