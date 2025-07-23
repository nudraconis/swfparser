package 
{

	public function internal_error(...args:Array):void
	{
		trace("Error:", args);
		printError.apply(null, args);
	}

}