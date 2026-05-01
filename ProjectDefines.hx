package;

abstract AppFeatureDefines(String) from String to String {
	// public static inline final TELEMETRY:AppFeatureDefines = "telemetry";

	public static inline function custom(name:String):AppFeatureDefines {
		return cast name;
	}
}

@:build(aedifex.build.macros.DefineCatalogMacro.compose([
	aedifex.build.Defines,
	AppFeatureDefines
]))
abstract ProjectDefines(String) from String to String {}
