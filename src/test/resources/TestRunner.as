package 
{
	import flash.display.Sprite;
	import org.flexunit.internals.TraceListener;
	import org.flexunit.runner.FlexUnitCore;
	import swfDataExporter.SwfDataExporterTestSuite;
	
	public class TestRunner extends Sprite
	{
		private var core:FlexUnitCore;
		
		public function TestRunner() 
		{
			core = new FlexUnitCore();
			
			//core.addListener( new CIListener());
			core.addListener( new TraceListener() );
			
			core.run(SwfDataExporterTestSuite);
		}
		
	}

}