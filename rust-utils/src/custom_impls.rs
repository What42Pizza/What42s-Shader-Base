use crate::prelude::*;



pub trait PathBufTraits {
	fn contains_file(&self, dir_name: &str) -> bool;
	fn push_new(&self, path: impl AsRef<Path>) -> PathBuf;
	fn pop_new(&self) -> PathBuf;
}

impl PathBufTraits for PathBuf {
	fn contains_file(&self, dir_name: &str) -> bool {
		for path in self.read_dir().expect("Could not read dir entries") {
			if path.expect("Could not process dir entry").file_name() == dir_name {return true;}
		}
		false
	}
	fn push_new(&self, path: impl AsRef<Path>) -> PathBuf {
		let mut output = self.clone();
		output.push(path);
		output
	}
	fn pop_new(&self) -> PathBuf {
		let mut output = self.clone();
		output.pop();
		output
	}
}
