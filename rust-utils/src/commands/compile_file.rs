use crate::prelude::*;
use std::{fs, ffi::OsStr};



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
		output_bytes.append(&mut String::from("Stderr Output:\n").into_bytes());
		output_bytes.append(&mut output.stderr);
	} else {
		output_bytes.append(&mut String::from("[no stderr output]\n").into_bytes());
	}
	
	output_bytes.push(b'\n');
	output_bytes.push(b'\n');
	output_bytes.push(b'\n');
	if !output.stdout.is_empty() {
		output_bytes.append(&mut String::from("Stdout Output:\n").into_bytes());
		output_bytes.append(&mut output.stdout);
	} else {
		output_bytes.append(&mut String::from("[no stdout output]\n").into_bytes());
	}
	
	let temp_path = get_temp_path()?;
	let output_path = temp_path.push_new(&args[1]);
	fs::write(output_path, output_bytes)?;
	
	println!("Done, see '/temp/output.txt' for output");
	Ok(())
}



pub fn compile_file(file_path: impl Into<PathBuf>) -> Result<ProcessOutput> {
	let mut file_path = file_path.into();
	
	let project_path = get_project_path()?;
	let temp_path = get_temp_path()?;
	let validator_path = project_path.push_new("glslangValidator.exe");
	if !validator_path.exists() {
		return Err(Error::msg("glslangValidator.exe was not found. Please download it and put it in the main folder\n(download link: https://github.com/KhronosGroup/glslang/releases/tag/main-tot)"));
	}
	
	let Some(extension) = file_path.extension() else {return Err(Error::msg("Could not get extension of input file path"));};
	let Some(extension) = extension.to_str() else {return Err(Error::msg("Could not decode extension of input file path"));};
	let compile_ready_extension = match extension {
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
	let compile_ready_file_path = temp_path.push_new(format!("compile_ready.{compile_ready_extension}"));
	fs::write(&compile_ready_file_path, preprocessed_file_bytes)?;
	
	let mut cmd = std::process::Command::new(validator_path);
	let path_arg = format!("temp/compile_ready.{compile_ready_extension}");
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
	file_contents.insert(2, String::from("#extension GL_ARB_enhanced_layouts : enable"));
	let mut curr_uniform_binding = 0;
	let mut curr_inout_location = 0;
	for line in file_contents {
		let trimmed_line = line.trim();
		
		if trimmed_line.starts_with("uniform sampler2D") {
			*line = format!("layout(binding = {curr_uniform_binding}) {line}");
			curr_uniform_binding += 1;
			continue;
		}
		
		if trimmed_line.starts_with("varying") {
			*line = format!("layout(location = {curr_inout_location}) {trimmed_line}");
			curr_inout_location += 1;
			continue;
		}
		
	}
	Ok(())
}
