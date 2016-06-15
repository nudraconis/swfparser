package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import org.flexunit.internals.TraceListener;
	import org.flexunit.listeners.CIListener;
	import org.flexunit.runner.FlexUnitCore;
	import org.gradlefx.flexunitexample.TestSuite;
	import swfDataExporter.SwfDataExporterTestSuite;
	
<% fullyQualifiedNames.each { %>
	import $it;
<% } %>
	
	public class FlexUnitRunner extends Sprite
	{
		private var core:FlexUnitCore;
		
		public function FlexUnitRunner() 
		{
			core = new FlexUnitCore();
			
			if (stage)
				startUp();
			else
				addEventListener(Event.ADDED_TO_STAGE, startUp);
		}
		
		private function startUp(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, startUp);
			
			core.addListener(new CIListener());
			core.addListener(new TraceListener());
			
			core.run(currentRunTestSuite());
		}
		
		public function currentRunTestSuite():Array {
            var testsToRun:Array = new Array();
			
            <% testClasses.each { %>
            testsToRun.push($it);
            <% } %>
			
            return testsToRun;
        }
	}
}