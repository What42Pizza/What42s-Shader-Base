use crate::prelude::*;
use std::fs;



pub fn get_program_path() -> PathBuf {
	let mut output = std::env::current_exe()
		.expect("Could not retrieve the path for the current exe.");
	output.pop();
	output
}



pub fn get_project_path() -> Result<PathBuf> {
	let mut curr_path = get_program_path();
	loop {
		let shaders_path = curr_path.push_new("shaders");
		if shaders_path.exists() {
			return Ok(curr_path);
		}
		let did_pop = curr_path.pop();
		if !did_pop {return Err(Error::msg("Could not find 'shaders' folder"));}
	}
}

pub fn get_shaders_path() -> Result<PathBuf> {
	let mut dir = get_project_path()?;
	dir.push("shaders");
	Ok(dir)
}

pub fn get_temp_path() -> Result<PathBuf> {
	let mut dir = get_project_path()?;
	dir.push("temp");
	if !dir.exists() {fs::create_dir(&dir)?;}
	Ok(dir)
}
