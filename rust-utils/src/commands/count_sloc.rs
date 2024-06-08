use crate::prelude::*;
use std::ffi::OsStr;
use walkdir::WalkDir;



pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'count_sloc' does not currently take arguments");
	}
	let mut total = 0;
	for entry in WalkDir::new(get_shaders_path()?) {
		let entry = entry?;
		total += get_file_sloc(entry.path())?;
	}
	println!("Total sloc: {total}");
	Ok(())
}





pub fn get_file_sloc(path: &Path) -> Result<usize> {
	
	// must be .glsl, not in /import, and not a style define
	if path.components().find(|s| s.as_os_str().to_string_lossy() == "import").is_some() {return Ok(0);}
	if let Some(Some(name)) = path.file_name().map(OsStr::to_str) && name.starts_with("style_") {return Ok(0);}
	let Some(extension) = path.extension() else {return Ok(0);};
	let Some(extension) = extension.to_str() else {return Ok(0);};
	if extension != "glsl" {return Ok(0);}
	
	
	
	let mut in_block_comment = false;
	let count =
		std::fs::read_to_string(path)?
		.lines()
		.filter(|line| {
			let mut line = *line;
			
			if in_block_comment {
				if let Some(index) = find_within_loc(line, "*/", 0) {
					in_block_comment = false;
					line = line[index+2..].trim();
				} else {
					return false;
				}
			}
			
			if let Some(index) = find_within_loc(line, "//", 0) {
				line = line[..index].trim();
			}
			
			if let Some(mut start_index) = find_within_loc(line, "/*", 0) {
				// TODO: fix lines like `/*  /**/`
				in_block_comment = true;
				let mut has_non_whitespace = !line[..start_index].trim().is_empty();
				'continued: loop {
					let Some(end_index) = find_within_loc(line, "*/", start_index + 2) else {break 'continued};
					in_block_comment = false;
					let Some(new_start_index) = find_within_loc(line, "/*", end_index + 2) else {break 'continued};
					in_block_comment = true;
					start_index = new_start_index;
					has_non_whitespace = has_non_whitespace || !line[end_index+2..start_index].trim().is_empty();
				}
				return has_non_whitespace;
			}
			
			!line.trim().is_empty()
		})
		.count();
	
	
	
	if in_block_comment {
		println!("WARNING: detected un-closed block comment in {path:?}");
	}
	
	Ok(count)
}





// NOTE: does not always work, depending on pattern (for example, "ABABC" will not be found within "ABABABC")
pub fn find_within_loc(line: &str, pattern: &str, start_i: usize) -> Option<usize> {
	let pattern = pattern.chars().collect::<Vec<_>>();
	let mut chars = line.chars().enumerate().skip(start_i);
	loop {
		let Some((char_i, c)) = chars.next() else {break};
		
		// skip char literals
		if c == '\'' {
			let Some((_, next)) = chars.next() else {break};
			if next == '\\' {
				chars.next();
			}
			chars.next();
			continue;
		}
		
		// skip string literals
		if c == '"' {
			'skip_string: loop {
				let Some((_, mut next)) = chars.next() else {break};
				if next == '\\' {
					chars.next();
					continue 'skip_string;
				}
				if next == '"' {
					break 'skip_string;
				}
			}
		}
		
		// match pattern
		let mut c = c;
		let mut pattern_i = 0;
		'match_pattern: loop {
			if c != pattern[pattern_i] {break 'match_pattern}
			pattern_i += 1;
			if pattern_i == pattern.len() {
				return Some(char_i);
			}
			let Some((line_i, next_c)) = chars.next() else {break 'match_pattern};
			c = next_c;
		}
		
	}
	None
}
