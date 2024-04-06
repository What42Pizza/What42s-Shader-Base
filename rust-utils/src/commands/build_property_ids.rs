use crate::prelude::*;
use std::{fs::{self, File}, io::{BufWriter, Write}};



pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'build_property_ids' does not take any arguments");
	}
	
	for file_name in &["block"] {
		println!("Building property ids for {file_name}.properties...");
		build_ids_for_file(file_name)?;
		println!("Done");
	}
	
	Ok(())
}



pub fn build_ids_for_file(file_name: &str) -> Result<()> {
	let file_path = get_shaders_path()?.push_new(format!("{file_name}.properties"));
	let file_strings = fs::read_to_string(&file_path)?;
	let mut file_lines = file_strings.lines().map(str::trim).collect::<Vec<_>>();
	
	let mut i = 0;
	while file_lines[i] != "# START_IDS" {
		i += 1;
		if i == file_lines.len() {return error!("Could not find line \"# START_IDS\"");}
	}
	
	let mut ids = get_ids(&file_lines, &mut i, "# START_ALIASES")?;
	let aliases = get_aliases(&file_lines, &mut i, "# START_1_12_IDS")?;
	apply_aliases(&mut ids, aliases);
	let entity_mappings = collect_entity_mappings(ids);
	
	let mut old_ids = get_ids(&file_lines, &mut i, "# START_1_12_ALIASES")?;
	let old_aliases = get_aliases(&file_lines, &mut i, "# START_GENERATED_CODE")?;
	apply_aliases(&mut old_ids, old_aliases);
	let old_entity_mappings = collect_entity_mappings(old_ids);
	
	let mut output_data = vec!();
	let mut push_line = |line: &str| {
		for byte in line.bytes() {
			output_data.push(byte);
		}
		output_data.push('\n' as u8);
	};
	
	for line in file_lines.into_iter().take(i + 1) {
		push_line(line);
	}
	push_line("");
	push_line("#if MC_VERSION >= 11300");
	push_line("");
	for (name, values) in entity_mappings {
		let mut output = format!("block.{} =", name);
		for name in values {
			output.push(' ');
			output += &name;
		}
		push_line(&output);
	}
	push_line("");
	push_line("#else");
	push_line("");
	for (name, values) in old_entity_mappings {
		let mut output = format!("block.{} =", name);
		for name in values {
			output.push(' ');
			output += &name;
		}
		push_line(&output);
	}
	push_line("");
	push_line("#endif");
	
	fs::write(file_path, output_data)?;
	
	Ok(())
}



pub fn get_ids(file_lines: &[&str], i: &mut usize, ending_statement: &str) -> Result<HashMap<String, isize>> {
	let mut ids = HashMap::new();
	loop {
		*i += 1;
		if *i == file_lines.len() {return error!("Unexpected end of file");}
		
		let line = file_lines[*i];
		if line.is_empty() {continue;}
		if line == ending_statement {break;}
		if !line.starts_with("# ") {return error!("Unknown statement at line {i}: Must be empty, start with \"# \", or start next segment.");}
		let line = &line[2..];
		
		let line_chars = line.chars().collect::<Vec<_>>();
		let Some((colon_index, _colon)) = line_chars.into_iter().enumerate().rev().find(|(_index, char)| *char == ':') else {
			return error!("Invalid statement at line {i}: no colon found");
		};
		
		let name = line[..colon_index].trim().to_string();
		let id = match line[colon_index + 1 ..].trim().parse::<isize>() {
			StdResult::Ok(v) => v,
			StdResult::Err(err) => return error!("Could not parse id at line {i}: \"{}\"", line[colon_index..].trim()),
		};
		let result = ids.try_insert(name, id);
		if let Err(err) = result {
			println!("Warning: duplicate id entry \"{}\"", err.entry.key());
		}
		
	}
	Ok(ids)
}



pub fn get_aliases(file_lines: &[&str], i: &mut usize, ending_statement: &str) -> Result<HashMap<String, Vec<String>>> {
	let mut aliases = HashMap::new();
	loop {
		*i += 1;
		if *i == file_lines.len() {return error!("Unexpected end of file");}
		
		let line = file_lines[*i];
		if line.is_empty() {continue;}
		if line == ending_statement {break;}
		if !line.starts_with("# ") {return error!("Unknown statement at line {i}: Must be empty, start with \"# \", or start next segment.");}
		let line = &line[2..];
		
		let Some((colon_index, _colon)) = line.chars().enumerate().find(|(_index, char)| *char == ':') else {
			return error!("Invalid statement at line {i}: no colon found");
		};
		let name = line[..colon_index].trim().to_string();
		let values = line[colon_index + 1 ..].trim().split(' ').map(|value| value.trim().to_string()).collect::<Vec<_>>();
		let result = aliases.try_insert(name, values);
		if let Err(err) = result {
			println!("Warning: duplicate alias \"{}\"", err.entry.key());
		}
		
	}
	Ok(aliases)
}



pub fn apply_aliases(ids: &mut HashMap<String, isize>, aliases: HashMap<String, Vec<String>>) {
	for (alias, values) in aliases.into_iter() {
		
		let Some(alias_id) = ids.remove(&alias) else {
			println!("Warning: unused alias \"{alias}\"");
			continue;
		};
		
		for aliased_name in values {
			let result = ids.try_insert(aliased_name, alias_id);
			if let Err(err) = result {
				println!("Warning: aliased name was already used: \"{}\"", err.entry.key());
			}
		}
		
	}
}



pub fn collect_entity_mappings(ids: HashMap<String, isize>) -> HashMap<isize, Vec<String>> {
	let mut output = HashMap::new();
	for (name, value) in ids {
		if !output.contains_key(&value) {
			output.insert(value, vec!());
		}
		output.get_mut(&value).unwrap().push(name);
	}
	output
}
