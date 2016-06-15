package org.hamcrest.matrix
{
	import flash.geom.Matrix;
	import org.hamcrest.BaseMatcher;
	import org.hamcrest.Description;
	import org.hamcrest.Matcher;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MatrixMatcher extends BaseMatcher 
	{
		
		//при записи/чтении чисел происходит ошибка например было 0.123 стало 0.1229999999 поэтому сравнение идет ту с учетом ошибки
		private static const EPS:Number = 0.01;
		private var eqTo:Object;
		
        public function MatrixMatcher(matrixMatchesTo:Object)
        {
			this.eqTo = matrixMatchesTo;
        }
		
		override public function matches(item:Object):Boolean 
		{
			var matrix:Object = item as Object;
			
			return !(Math.abs(eqTo.a - matrix.a) > EPS || Math.abs(matrix.b - matrix.b) > EPS ||
								  Math.abs(eqTo.c - matrix.c) > EPS || Math.abs(matrix.d - matrix.d) > EPS ||
								 Math.abs(eqTo.tx - matrix.tx) > EPS || Math.abs(matrix.ty - matrix.ty) > EPS);
		}
		
		override public function describeTo(description:Description):void 
		{
			description.appendText("Expected matrix: " + eqTo.toString());
		}
		
		override public function describeMismatch(item:Object, mismatchDescription:Description):void 
		{
			super.describeMismatch(item.toString(), mismatchDescription);
		}
	}

}