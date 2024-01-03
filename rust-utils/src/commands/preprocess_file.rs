use crate::prelude::*;
use std::fs;



pub fn function(args: &[String]) -> Result<()> {
	if args.len() != 2 {
		return Err(Error::msg("Command 'preprocess_file' must take two args (input_path & output_path)"));
	}
	println!("Preprocessing file...");
	
	let preprocessed_file = preprocess_file(&PathBuf::from(&args[0]))?;
	
	let mut output_bytes = vec!();
	for line in preprocessed_file {
		output_bytes.append(&mut line.into_bytes());
		output_bytes.push(b'\n');
	}
	
	let temp_path = get_temp_path()?;
	let output_path = temp_path.push_new(&args[1]);
	fs::write(output_path, output_bytes)?;
	
	println!("Done");
	Ok(())
}



pub fn preprocess_file(file_path: impl Into<PathBuf>) -> Result<Vec<String>> {
	let mut file_path = file_path.into();
	
	let shaders_path = get_shaders_path()?;
	if !file_path.is_absolute() {
		file_path = shaders_path.push_new(file_path);
	}
	
	let file_contents = fs::read_to_string(&file_path)?;
	let mut file_contents = file_contents.lines().map(str::to_string).collect::<Vec<String>>();
	
	let mut i = 0;
	loop {
		preprocess_line(&mut file_contents, i, &file_path, &shaders_path)?;
		i += 1;
		if i >= file_contents.len() {break;}
	}
	
	Ok(file_contents)
}



pub fn preprocess_line(file_contents: &mut Vec<String>, i: usize, file_path: &Path, shaders_path: &Path) -> Result<()> {
	let line = file_contents[i].trim();
	
	if !line.starts_with("#include ") {return Ok(());}
	
	let include_path_end = &line[10..line.len()-1];
	let include_path = if include_path_end.starts_with("/") {
		shaders_path.push_new(&include_path_end[1..])
	} else {
		file_path.pop_new().push_new(include_path_end)
	};
	
	file_contents.remove(i);
	
	let include_contents =
		fs::read_to_string(include_path)?
		.lines().map(str::to_string).collect::<Vec<String>>();
	
	file_contents.splice(i..i, include_contents);
	
	Ok(())
}
