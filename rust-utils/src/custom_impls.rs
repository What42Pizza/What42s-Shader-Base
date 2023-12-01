use crate::prelude::*;



pub trait PathTraits {
	fn contains_file(&self, dir_name: &str) -> bool;
	fn push_new(&self, path: impl AsRef<Path>) -> PathBuf;
	fn pop_new(&self) -> PathBuf;
	fn as_str(&self) -> Option<&str>;
}

impl PathTraits for Path {
	fn contains_file(&self, dir_name: &str) -> bool {
		for path in self.read_dir().expect("Could not read dir entries") {
			if path.expect("Could not process dir entry").file_name() == dir_name {return true;}
		}
		false
	}
	fn push_new(&self, path: impl AsRef<Path>) -> PathBuf {
		let mut output = self.to_path_buf();
		output.push(path);
		output
	}
	fn pop_new(&self) -> PathBuf {
		let mut output = self.to_path_buf();
		output.pop();
		output
	}
	fn as_str(&self) -> Option<&str> {
		self.as_os_str().to_str()
	}
}
