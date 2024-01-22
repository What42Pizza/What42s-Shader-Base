use crate::prelude::*;
use std::{fs, io::{self, Write}, ffi::OsStr, collections::HashMap};
use walkdir::WalkDir;
use zip::{write::FileOptions, ZipWriter};





pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'export' does not take any arguments");
	}
	
	println!("Enter version name:");
	let mut version = String::new();
	io::stdin().read_line(&mut version)?;
	let version = version.trim().to_string();
	
	let project_path = get_project_path()?;
	let export_path = project_path.push_new("export");
	if export_path.exists() {
		fs::remove_dir_all(&export_path)?;
	}
	fs::create_dir(&export_path)?;
	
	let options = FileOptions::default()
		.compression_method(zip::CompressionMethod::Deflated)
		.unix_permissions(0o755);
	
	println!("Exporting For Iris...");
	export_shader(&project_path, &export_path, &version, false, options)?;
	println!("Done");
	println!("Exporting for OptiFine...");
	export_shader(&project_path, &export_path, &version, true, options)?;
	println!("Done");
	
	println!();
	println!("======== WARNING: ========");
	println!("The .zip output of this doesn't seem to work, and you have to unzip then re-zip to make it work with OptiFine / Iris");
	Ok(())
}





pub fn export_shader(project_path: &Path, export_path: &Path, version: &str, is_optifine: bool, zip_options: FileOptions) -> Result<()> {
	
	let output_file_name = format!("What42's Shader Base {version}{}.zip", if is_optifine {" (OptiFine)"} else {""});
	let output_path = export_path.push_new(output_file_name);
	
	let output_file = std::fs::File::create(output_path)?;
	let mut output_zip = ZipWriter::new(output_file);
	
	
	
	for file_data in EXPORT_FILES {
		output_zip.start_file(file_data.get_copy_name(), zip_options)?;
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
			
			let entry_zip_path = entry_path.strip_prefix(&project_path)?;
			let entry_zip_path = entry_zip_path
				.as_os_str()
				.to_str()
				.ok_or_else(|| 
					Error::msg("Could not parse name of file {entry_zip_path:?}")
				)?;
			
			if entry_path.is_dir() {
				output_zip.add_directory(entry_zip_path, zip_options)?;
				continue;
			}
			
			if entry_path.is_file() {
				output_zip.start_file(entry_zip_path, zip_options)?;
				let mut file_contents = fs::read(&entry_path)?;
				
				if is_optifine {
					if let Some(Some(file_name)) = entry_path.file_name().map(OsStr::to_str) {
						match file_name {
							"define_settings.glsl" => {
								file_contents = process_define_settings(&file_contents, &project_path)?;
							}
							"settings.glsl" => {
								file_contents = process_settings(&file_contents)?;
							}
							_ if file_name.starts_with("style_") => continue,
							_ => {}
						}
					}
				}
				
				output_zip.write_all(&file_contents)?;
				continue;
			}
			
			println!("WARNING: Cannot handle unknown file: {entry_path:?}");
			
		}
	}
	
	output_zip.finish()?;
	
	Ok(())
}





pub fn process_define_settings(file_contents: &[u8], project_path: &Path) -> Result<Vec<u8>> {
	
	// get setting values
	let style_file_path = project_path.push_new("shaders").push_new(DEFAULT_STYLE_PATH);
	let default_settings_contents = fs::read_to_string(&style_file_path)?;
	let mut default_settings = HashMap::new();
	for (i, line) in default_settings_contents.lines().enumerate() {
		let line = line.trim();
		if !line.starts_with("#define ") {continue;}
		let line_parts = line.split(" ").collect::<Vec<&str>>();
		if line_parts.len() != 3 {return Err(Error::msg(format!("Invalid line in default style file: file {style_file_path:?} line {}: Expected 3 space-separated-values, but found {}", i + 1, line_parts.len())));}
		let setting_name = line_parts[1].to_string();
		let setting_value = line_parts[2].to_string();
		default_settings.insert(setting_name, setting_value);
	}
	
	// apply setting values
	let mut output = Vec::with_capacity(file_contents.len());
	let file_contents = &*String::from_utf8_lossy(file_contents);
	for (i, line) in file_contents.lines().enumerate() {
		let line_num = i + 1;
		let line = line.trim();
		output.push(b'\n');
		if !line.starts_with("#define ") {continue;}
		
		let line_parts = line.split(" ").filter(|line| !line.is_empty()).collect::<Vec<&str>>();
		if line_parts.len() < 6 {return Err(Error::msg(format!("Invalid line in define_settings line {}: Expected at least 6 space-separated-tokens, but found {}", line_num, line_parts.len())));}
		
		let mut output_line = String::from("#define ");
		let setting_name = line_parts[1];
		output_line += setting_name;
		output_line.push(' ');
		
		if line_parts[2] != "-1" {return Err(Error::msg(format!("Invalid line in define_settings line {}: Expect setting set be -1, but found {}", line_num, line_parts[2])));}
		let Some(setting_value) = default_settings.get(setting_name) else {return Err(Error::msg(format!("Invalid line in define_settings line {}: Could not find default value for setting {}", line_num, setting_name)));};
		output_line += setting_value;
		output_line += " // ";
		
		if line_parts[3] != "//" {return Err(Error::msg(format!("Invalid line in define_settings line {}: Expect comment start (\" // \") after value -1, but found {}", line_num, line_parts[3])));}
		
		let new_setting_values = process_setting_values(&line_parts[4..], line_num)?;
		output_line += &new_setting_values;
		
		output.append(&mut output_line.into_bytes());
	}
	
	Ok(output)
}



pub fn process_setting_values(value_strs: &[&str], line_num: usize) -> Result<String> {
	let mut output = String::new();
	
	if !value_strs[0].starts_with("[") {return Err(Error::msg(format!("Invalid line in define_settings line {}: Expected setting values (starting with '[') after comment start, but found {}", line_num, value_strs[0])));}
	if value_strs.len() < 3 {return Err(Error::msg(format!("Invalid line in define_settings line {}: Expected at least 3 valid values but found {}", line_num, value_strs.len())));}
	if !value_strs.last().unwrap().ends_with("]") {return Err(Error::msg(format!("Invalid line in define_settings line {}: Expected ']' at end of setting values, but found {}", line_num, value_strs.last().unwrap())));}
	
	output.push('[');
	output += value_strs[1];
	for value in value_strs.iter().skip(2) {
		output.push(' ');
		output += value;
	}
	
	Ok(output)
}





pub fn process_settings(file_contents: &[u8]) -> Result<Vec<u8>> {
	let mut output = Vec::with_capacity(file_contents.len());
	let file_contents = &*String::from_utf8_lossy(&file_contents);
	for line in file_contents.lines() {
		output.push(b'\n');
		if line.trim().starts_with(r#"#include "/style_"#) {continue;}
		for &byte in line.as_bytes() {
			output.push(byte);
		}
	}
	Ok(output)
}
