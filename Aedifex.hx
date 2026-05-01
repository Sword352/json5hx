package;

import aedifex.build.Project;
import aedifex.build.ProjectSpec;

class Aedifex {
	public static final project:ProjectSpec = Project
		.library("json5hx")
		.source("lib")
		.identity("json5hx", "json5hx")
		.version("1.0.2")
		.done();
}
