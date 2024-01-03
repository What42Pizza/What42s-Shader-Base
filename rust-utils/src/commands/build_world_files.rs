use crate::prelude::*;
use std::fs;



pub fn create_file_contents(world_name: &str, shader_name: &str, shader_type: &str) -> String {
	let shader_name_uppercase = shader_name.to_uppercase();
	let raw_output = format!(r##"
		#version 130
		
		#define SHADER_{shader_name_uppercase}
		#define {world_name}
		#define {shader_type}
		
		#include "/settings.glsl"
		#include "/common.glsl"
		
		
		
		#define FIRST_PASS
		#define ARGS_IN , false
		#define ARGS_OUT , bool dummy
		#define ARG_IN false
		#define ARG_OUT bool dummy
		#define main dummy_main
		#include "/main_files/{shader_name}.glsl"
		#undef main
		#undef FIRST_PASS
		#undef ARGS_IN
		#undef ARGS_OUT
		#undef ARG_IN
		#undef ARG_OUT
		
		#include "/import/switchboard.glsl"
		
		#define SECOND_PASS
		#define ARGS_IN
		#define ARGS_OUT
		#define ARG_IN
		#define ARG_OUT
		#include "/main_files/{shader_name}.glsl"
	"##);
	let mut output = String::with_capacity(raw_output.len());
	for curr_char in raw_output.trim().chars() {
		if curr_char == '\t' {continue;}
		output.push(curr_char);
	}
	output.push('\n');
	output
}





pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'build_world_files' does not take any arguments");
	}
	println!("Building world files...");
	
	let shaders_path = get_shaders_path()?;
	for (world_folder_name, world_name) in WORLDS_LIST {
		let world_path = shaders_path.push_new(world_folder_name);
		if world_path.exists() {
			fs::remove_dir_all(&world_path)?;
		}
		fs::create_dir(&world_path)?;
		for shader_name in SHADERS_LIST {
			build_shader_files(*world_name, *shader_name, &world_path)?;
		}
	}
	
	println!("Done");
	Ok(())
}



pub fn build_shader_files(world_name: &str, shader_name: &str, world_path: &PathBuf) -> Result<()> {
	let fsh_contents = create_file_contents(world_name, shader_name, "FSH");
	fs::write(world_path.push_new(format!("{shader_name}.fsh")), fsh_contents)?;
	let vsh_contents = create_file_contents(world_name, shader_name, "VSH");
	fs::write(world_path.push_new(format!("{shader_name}.vsh")), vsh_contents)?;
	Ok(())
}
