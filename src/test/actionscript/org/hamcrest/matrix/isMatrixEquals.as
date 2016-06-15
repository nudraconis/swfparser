package org.hamcrest.matrix
{
	import flash.geom.Matrix;
	import org.hamcrest.Matcher;

	public function isMatrixEquals(item:Object):Matcher
	{
		return new MatrixMatcher(item);
	}
		
}