// started: 23/11/30



#![allow(unused)]
#![warn(unused_must_use)]



use crate::prelude::*;
use std::{env, process::Command, fs::File};





// ======== SETTINGS ========



pub const SHADERS_LIST: &[&str] = &[
	"composite",
	"composite1",
	"composite2",
	"composite3",
	"composite4",
	"composite5",
	"deferred",
	"gbuffers_basic",
	"gbuffers_beaconbeam",
	"gbuffers_clouds",
	"gbuffers_damagedblock",
	"gbuffers_entities",
	"gbuffers_hand",
	"gbuffers_skybasic",
	"gbuffers_skytextured",
	"gbuffers_terrain",
	"gbuffers_textured",
	"gbuffers_water",
	"gbuffers_weather",
	"shadow",
];



pub const WORLDS_LIST: &[(&str, &str)] = &[
	("world-1", "NETHER"),
	("world0", "OVERWORLD"),
	("world1", "END"),
];



pub const EXPORT_FOLDERS: &[&str] = &[
	"shaders",
];

pub const EXPORT_FILES: &[FileCopyData] = &[
	FileCopyData::new("LICENSE", None),
	FileCopyData::new("changelog.md", None),
	FileCopyData::new("shader readme.md", Some("readme.md")),
];



pub const ALL_UNIFORMS: &str = include_str!("../../all_uniforms.txt");



// ======== END SETTINGS ========





const COMMANDS: &[data::Command] = &[
	data::Command::new("help", "Shows the help screen", commands::help::function),
	data::Command::new("build_world_files", "Generates the '/world_' files using hard-coded data", commands::build_world_files::function),
	data::Command::new("build_uniform_imports", "Generates the '/import' files using hard-coded data", commands::build_uniform_imports::function),
	data::Command::new("export", "Exports the shader with only shader files included", commands::export::function),
];





pub mod prelude {
	pub use crate::{*, data::*, utils::*, custom_impls::*};
	pub use std::path::{PathBuf, Path};
	pub use anyhow::*;
}



pub mod commands;

pub mod data;
pub mod utils;
pub mod custom_impls;



fn main() -> Result<()> {
	print!("\n\n\n");
	let mut args = env::args();
	
	args.next().expect("could not get program");
	
	let Some(first_arg) = args.next() else {
		return Err(Error::msg("At least one argument is expected. Run with 'cargo run -- help' for all commands"));
	};
	let command_args = args.collect::<Vec<String>>();
	
	for command in COMMANDS {
		if command.name == first_arg {
			command.run(&command_args)?;
			print!("\n\n\n");
			return Ok(())
		}
	}
	
	eprintln!("Unknown command: '{first_arg}'");
	println!();
	commands::help::print_help();
	print!("\n\n\n");
	Err(Error::msg("Unknown command"))
}