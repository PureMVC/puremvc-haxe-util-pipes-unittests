/* 
 PureMVC MultiCore Pipes Utility Unit Tests haXe Port by Marco Secchi <marco.secchi@puremvc.org>
 PureMVC MultiCore Pipes Utility - Copyright(c) 2006-08 Futurescale, Inc., Some rights reserved. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License 
 */
package org.puremvc.haxe.multicore.utilities.pipes.plumbing;
	
import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeFitting;
import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeMessage;
import org.puremvc.haxe.multicore.utilities.pipes.messages.Message;
	
/**
 * Test the TeeSplit class.
 */
class TeeSplitTest extends haxe.unit.TestCase 
{
  	
	/**
	 * Constructor
	 */
	public function new()
	{
		super();
		messagesReceived = new Array();
	}

	/**
	 * Test connecting and disconnecting I/O Pipes.
	 * 
	 * <P>
	 * Connect an input and several output pipes to a splitting tee. 
	 * Then disconnect all outputs in LIFO order by calling disconnect 
	 * repeatedly.</P>
	 */
	public function testConnectingAndDisconnectingIOPipes(): Void 
	{
		// create input pipe
		var input1: IPipeFitting = new Pipe();

		// create output pipes 1, 2, 3 and 4
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();
		var pipe3: IPipeFitting = new Pipe();
		var pipe4: IPipeFitting = new Pipe();

		// create splitting tee (args are first two output fittings of tee)
		var teeSplit: TeeSplit = new TeeSplit( pipe1, pipe2 );
   			
		// connect 2 extra outputs for a total of 4
		var connectedExtra1: Bool = teeSplit.connect( pipe3 );
		var connectedExtra2: Bool = teeSplit.connect( pipe4 );

		// connect the single input
		var inputConnected: Bool = input1.connect( teeSplit );
			
		// test assertions
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( Std.is( pipe3, Pipe ) );
		assertTrue( Std.is( pipe4, Pipe ) );
		assertTrue( Std.is( teeSplit, TeeSplit ) );
		assertTrue( connectedExtra1 );
		assertTrue( connectedExtra2 );
   			
		// test LIFO order of output disconnection
		assertTrue( teeSplit.disconnect() == pipe4 );
		assertTrue( teeSplit.disconnect() == pipe3 );
		assertTrue( teeSplit.disconnect() == pipe2 );
		assertTrue( teeSplit.disconnect() == pipe1 );
	}
  		
	/**
 	 * Test receiving messages from two pipes using a TeeMerge.
	 */
	public function testReceiveMessagesFromTwoTeeSplitOutputs(): Void 
	{
		// create a message to send on pipe 1
		var message: IPipeMessage = new Message( Message.NORMAL, { testProp: 1 } );
		
		// create output pipes 1 and 2
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();

		// create and connect anonymous listeners
		var connected1: Bool = pipe1.connect( new PipeListener( this, callBackMethod ) );
		var connected2: Bool = pipe2.connect( new PipeListener( this, callBackMethod ) );
   		
		// create splitting tee (args are first two output fittings of tee)
		var teeSplit: TeeSplit = new TeeSplit( pipe1, pipe2 );

		// write messages to their respective pipes
		var written: Bool = teeSplit.write( message );
   			
		// test assertions
		assertTrue( Std.is( message, IPipeMessage ) );
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( Std.is( teeSplit, TeeSplit ) );
		assertTrue( connected1 );
		assertTrue( connected2 );
		assertTrue( written );
  			
		// test that both messages were received, then test
		// FIFO order by inspecting the messages themselves
		assertEquals( messagesReceived.length, 2 );
   			
		// test message 1 assertions 
		var message1: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message1, IPipeMessage ) );
		assertTrue( message1 == message ); // object equality

		// test message 2 assertions
		var message2:IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message2, IPipeMessage ) );
		assertTrue( message2 == message ); // object equality

	}
   		
	/**
 	 * Array of received messages.
 	 *
	 * <p>Used by [callBackMedhod] as a place to store
	 * the recieved messages.</p>
	 */     		
	private var messagesReceived:Array<IPipeMessage>;
   		
	/**
	 * Callback given to [PipeListener] for incoming message.
	 *
	 * <p>Used by [testReceiveMessageViaPipeListener] 
	 * to get the output of pipe back into this  test to see 
	 * that a message passes through the pipe.</p>
	 */
	private function callBackMethod( message: IPipeMessage ): Void
	{
		this.messagesReceived.push( message );
	}
   		
}