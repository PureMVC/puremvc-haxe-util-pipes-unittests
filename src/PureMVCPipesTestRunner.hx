/* 
 PureMVC MultiCore Pipes Utility Unit Tests haXe Port by Marco Secchi <marco.secchi@puremvc.org>
 PureMVC MultiCore Pipes Utility - Copyright(c) 2006-08 Futurescale, Inc., Some rights reserved. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License 
 */
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.MessageTest;
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.PipeTest;
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.PipeListenerTest;
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.TeeMergeTest;
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.TeeSplitTest;
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.QueueTest;
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.FilterTest;
import org.puremvc.haxe.multicore.utilities.pipes.plumbing.JunctionTest;

class PureMVCPipesTestRunner
{
	static function main()
	{
		var tr = new haxe.unit.TestRunner();

		tr.add( new MessageTest() );
		tr.add( new PipeTest() );
		tr.add( new PipeListenerTest() );
		tr.add( new TeeMergeTest() );
		tr.add( new TeeSplitTest() );
		tr.add( new QueueTest() );
		tr.add( new FilterTest() );
		tr.add( new JunctionTest() );

		tr.run();
	}
}