/* 
 PureMVC MultiCore Pipes Utility Unit Tests haXe Port by Marco Secchi <marco.secchi@puremvc.org>
 PureMVC MultiCore Pipes Utility - Copyright(c) 2006-08 Futurescale, Inc., Some rights reserved. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License 
 */
package org.puremvc.haxe.multicore.utilities.pipes.plumbing;

import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeFitting;
	
/**
 * Test the Pipe class.
 */
class PipeTest extends haxe.unit.TestCase 
{
  		
	/**
	 * Test the constructor.
	 */
	public function testConstructor(): Void 
	{
		var pipe: IPipeFitting = new Pipe();
   			
		// test assertions
		assertTrue( Std.is( pipe, Pipe ) );
	}

	/**
	 * Test connecting and disconnecting two pipes. 
	 */
	public function testConnectingAndDisconnectingTwoPipes(): Void 
	{
		// create two pipes
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();
		// connect them
		var success: Bool = pipe1.connect( pipe2 );
   			
		// test assertions
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( success );
   			
		// disconnect pipe 2 from pipe 1
		var disconnectedPipe: IPipeFitting = pipe1.disconnect();
		assertTrue( disconnectedPipe == pipe2 );
		
	}
   		
	/**
	 * Test attempting to connect a pipe to a pipe with an output already connected. 
 	 */
	public function testConnectingToAConnectedPipe(): Void 
	{
		// create three pipes
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();
		var pipe3: IPipeFitting = new Pipe();

		// connect them
		var success: Bool = pipe1.connect( pipe2 );
   			
		// test assertions
		assertTrue( success );
		assertFalse( pipe1.connect( pipe3 ) );   			
	}
   		
}