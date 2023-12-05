use crate::prelude::*;
use std::fs;



pub fn create_file_contents(uniform: &UniformData) -> String {
	let raw_output = format!(
		r##"
			#define import_{name}
			#ifdef FIRST_PASS
				{type_str} {name} = {dummy_value_str};
			#endif
		"##,
		name = uniform.name,
		type_str = uniform.type_str,
		dummy_value_str = uniform.dummy_value_str
	);
	let mut output = String::with_capacity(raw_output.len());
	for curr_char in raw_output.chars() {
		if curr_char == '\t' {continue;}
		output.push(curr_char);
	}
	output
}



pub fn create_switchboard_file_contents(uniform: &UniformData) -> String {
	let raw_output = format!(
		r##"
			#ifdef import_{name}
				{input_type_str} {type_str} {name};
			#endif
		"##,
		name = uniform.name,
		type_str = uniform.type_str,
		input_type_str = if uniform.is_attribute {"attribute"} else {"uniform"}
	);
	let mut output = String::with_capacity(raw_output.len());
	for curr_char in raw_output.chars() {
		if curr_char == '\t' {continue;}
		output.push(curr_char);
	}
	output
}



pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'build_uniform_imports' does not take any arguments");
	}
	println!("Building uniform imports...");
	
	let uniform_datas = get_uniform_datas()?;
	
	let project_path = get_project_path()?;
	let uniforms_path = project_path.push_new("shaders/import");
	
	fs_extra::dir::remove(&uniforms_path)?;
	fs::create_dir(&uniforms_path)?;
	
	let mut switchboard_file_contents = String::new();
	for uniform in &uniform_datas {
		let import_file_contents = create_file_contents(uniform);
		let import_file_path = uniforms_path.push_new(format!("{}.glsl", uniform.name));
		fs::write(import_file_path, import_file_contents)?;
		switchboard_file_contents += &create_switchboard_file_contents(uniform);
	}
	let switchboard_file_path = &uniforms_path.push_new("switchboard.glsl");
	fs::write(switchboard_file_path, switchboard_file_contents)?;
	
	
	println!("Done");
	Ok(())
}



pub fn get_uniform_datas() -> Result<Vec<UniformData>> {
	let mut output = Vec::with_capacity(ALL_UNIFORMS_PATH.len() / 29); // estimate final len
	for (i, line) in ALL_UNIFORMS_PATH.lines().enumerate() {
		output.push(str_to_uniform_data(line, i)?);
	}
	Ok(output)
}



pub fn str_to_uniform_data(input: &'static str, line: usize) -> Result<UniformData> {
	let raw_parts = input.split(" ").collect::<Vec<&str>>();
	
	let is_attribute = 'is_attribute: {
		if raw_parts.is_empty() {break 'is_attribute false;}
		raw_parts[0] == "attribute"
	};
	
	let parts = &raw_parts[if is_attribute {1} else {0} ..];
	if parts.len() != 4 {return Err(Error::msg(format!("Invalid uniform at line {} ('{input}'): expected 4 items ('[data type] [uniform name] = [dummy value]') or 5 if item is attribute, but found {}", line + 1, parts.len())));}
	
	Ok(UniformData {
		name: parts[1],
		type_str: parts[0],
		dummy_value_str: parts[3],
		is_attribute,
	})
}
