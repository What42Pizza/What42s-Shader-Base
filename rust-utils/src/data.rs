use crate::prelude::*;





pub struct Command {
	pub name: &'static str,
	pub display_name: &'static str,
	pub description: &'static str,
	pub function: CommandFunction,
}

impl Command {
	pub const fn new(name: &'static str, display_name: &'static str, description: &'static str, function: CommandFunction) -> Self {
		Self {
			name,
			display_name,
			description,
			function,
		}
	}
	pub fn run(&self, args: &[String]) -> Result<()> {
		(self.function)(args)
	}
}

type CommandFunction = fn(args: &[String]) -> Result<()>;





pub struct FileCopyData {
	pub file_name: &'static str,
	pub copy_name: Option<&'static str>,
}

impl FileCopyData {
	pub const fn new(file_name: &'static str, copy_name: Option<&'static str>) -> Self {
		Self {
			file_name,
			copy_name,
		}
	}
	pub fn get_copy_name(&self) -> &'static str {
		self.copy_name.unwrap_or(self.file_name)
	}
}





pub struct UniformData {
	pub name: &'static str,
	pub type_str: &'static str,
	pub dummy_value_str: &'static str,
	pub is_attribute: bool,
}
