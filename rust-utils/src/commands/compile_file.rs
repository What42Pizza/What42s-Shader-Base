use crate::prelude::*;
use std::{fs, ffi::OsStr, process::Output};



pub fn function(args: &[String]) -> Result<()> {
	if args.len() != 2 {
		return Err(Error::msg("Command 'compile_file' must take two args (input_path & output_path)"));
	}
	println!("Compiling file...");
	
	let mut output = compile_file(&PathBuf::from(&args[0]))?;
	
	let mut output_bytes = vec!();
	output_bytes.append(&mut format!("Output Status: {}\n", output.status).into_bytes());
	
	output_bytes.push(b'\n');
	output_bytes.push(b'\n');
	output_bytes.push(b'\n');
	if !output.stderr.is_empty() {
		output_bytes.append(&mut String::from("Error Output:\n").into_bytes());
		output_bytes.append(&mut output.stderr);
	} else {
		output_bytes.append(&mut String::from("[no error output]\n").into_bytes());
	}
	
	output_bytes.push(b'\n');
	output_bytes.push(b'\n');
	output_bytes.push(b'\n');
	if !output.stdout.is_empty() {
		output_bytes.append(&mut String::from("Working Output:\n").into_bytes());
		output_bytes.append(&mut output.stdout);
	} else {
		output_bytes.append(&mut String::from("[no working output]\n").into_bytes());
	}
	
	fs::write(PathBuf::from(&args[1]), output_bytes)?;
	
	println!("Done");
	Ok(())
}



pub fn compile_file(file_path: impl Into<PathBuf>) -> Result<Output> {
	let mut file_path = file_path.into();
	
	let project_path = get_project_path()?;
	let validator_path = project_path.push_new("glslangValidator.exe");
	if !validator_path.exists() {
		return Err(Error::msg("glslangValidator.exe was not found. Please download it and put it in the main folder\n(download link: https://github.com/KhronosGroup/glslang/releases/tag/main-tot)"));
	}
	
	let Some(extension) = file_path.extension() else {return Err(Error::msg("Could not get extension of input file path"));};
	let Some(extension) = extension.to_str() else {return Err(Error::msg("Could not decode extension of input file path"));};
	let temp_extension = match extension {
		"fsh" => "frag",
		"vsh" => "vert",
		_ => return Err(Error::msg(format!("Cannot compile file of type '{extension}' (only .fsh and .vsh are allowed)"))),
	};
	
	let mut preprocessed_file = super::preprocess_file::preprocess_file(&file_path)?;
	fix_preprocessed_file(&mut preprocessed_file)?;
	
	let mut preprocessed_file_bytes = vec!();
	for line in preprocessed_file {
		preprocessed_file_bytes.append(&mut line.into_bytes());
		preprocessed_file_bytes.push(b'\n');
	}
	fs::write(project_path.push_new(format!("temp.{temp_extension}")), preprocessed_file_bytes)?;
	
	let mut cmd = std::process::Command::new(validator_path);
	let path_arg = format!("temp.{temp_extension}");
	cmd.args(&["-H", &path_arg]);
	cmd.current_dir(&project_path);
	
	let output = cmd.output();
	match output {
		StdResult::Ok(v) => Ok(v),
		StdResult::Err(err) => Err(err.into()),
	}
}



pub fn fix_preprocessed_file(file_contents: &mut Vec<String>) -> Result<()> {
	while file_contents[0].is_empty() {file_contents.remove(0);}
	file_contents.insert(1, String::from("#extension GL_ARB_shading_language_420pack : require"));
	let mut curr_binding = 0;
	for line in file_contents {
		
		if line.trim().starts_with("uniform sampler2D") {
			*line = format!("layout(binding = {curr_binding}) {line}");
			curr_binding += 1;
			continue;
		}
		
	}
	Ok(())
}
