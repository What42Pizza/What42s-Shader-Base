use crate::{prelude::*, COMMANDS};



pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'help' does not currently take arguments");
	}
	print_help();
	Ok(())
}



pub fn print_help() {
	println!("Allowed commands:");
	let mut highest_name_size = 0;
	for command in COMMANDS {highest_name_size = highest_name_size.max(command.display_name.len());}
	for command in COMMANDS {
		println!("{:highest_name_size$} | {}", command.display_name, command.description);
	}
	println!();
	println!("If using cargo, run 'cargo run -- [command]' (example: 'cargo run -- help')");
}
