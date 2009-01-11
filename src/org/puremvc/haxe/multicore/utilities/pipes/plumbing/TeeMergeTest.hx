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
 * Test the TeeMerge class.
 */
class TeeMergeTest extends haxe.unit.TestCase 
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
	 * Test connecting an output and several input pipes to a merging tee. 
	 */
	public function testConnectingIOPipes(): Void 
	{
		// create input pipe
		var output1: IPipeFitting = new Pipe();

		// create input pipes 1, 2, 3 and 4
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();
		var pipe3: IPipeFitting = new Pipe();
		var pipe4: IPipeFitting = new Pipe();

		// create splitting tee (args are first two input fittings of tee)
		var teeMerge: TeeMerge = new TeeMerge( pipe1, pipe2 );
   			
		// connect 2 extra inputs for a total of 4
		var connectedExtra1: Bool = teeMerge.connectInput( pipe3 );
		var connectedExtra2: Bool = teeMerge.connectInput( pipe4 );

		// connect the single output
		var connected: Bool = output1.connect( teeMerge );
			
		// test assertions
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( Std.is( pipe3, Pipe ) );
		assertTrue( Std.is( pipe4, Pipe ) );
		assertTrue( Std.is( teeMerge, TeeMerge ) );
		assertTrue( connectedExtra1 );
		assertTrue( connectedExtra2 );
	}

	/**
 	 * Test receiving messages from two pipes using a TeeMerge.
	 */
	public function testReceiveMessagesFromTwoPipesViaTeeMerge(): Void 
	{
		// create a message to send on pipe 1
		var pipe1Message: IPipeMessage = new Message( Message.NORMAL, 
												     { testProp: 1 },
													  Xml.parse( "<testMessage testAtt='Pipe 1 Message'/>" ),
												      Message.PRIORITY_LOW );
		// create a message to send on pipe 2
		var pipe2Message: IPipeMessage = new Message( Message.NORMAL, 
												     { testProp: 2  },
													  Xml.parse( "<testMessage testAtt='Pipe 2 Message'/>" ),
												      Message.PRIORITY_HIGH );
		// create pipes 1 and 2
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();
   			
		// create merging tee (args are first two input fittings of tee)
		var teeMerge: TeeMerge = new TeeMerge( pipe1, pipe2 );

		// create listener
		var listener: PipeListener = new PipeListener( this, callBackMethod );
   			
		// connect the listener to the tee and write the messages
		var connected: Bool = teeMerge.connect( listener );
   			
		// write messages to their respective pipes
		var pipe1written: Bool = pipe1.write( pipe1Message );
		var pipe2written: Bool = pipe2.write( pipe2Message );
   			
		// test assertions
		assertTrue( Std.is( pipe1Message, IPipeMessage ) );
		assertTrue( Std.is( pipe2Message, IPipeMessage ) );
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( Std.is( teeMerge, TeeMerge ) );
		assertTrue( Std.is( listener, PipeListener ) );
		assertTrue( connected );
		assertTrue( pipe1written );
		assertTrue( pipe2written );
   			
		// test that both messages were received, then test
		// FIFO order by inspecting the messages themselves
		assertEquals( messagesReceived.length, 2 );
   			
		// test message 1 assertions 
		var message1: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message1, IPipeMessage ) );
		assertTrue( message1 == pipe1Message ); // object equality
		assertEquals( message1.getType(), Message.NORMAL );
		assertEquals( message1.getHeader().testProp, 1);
		assertEquals( cast( message1.getBody(), Xml ).firstElement().get( 'testAtt' ), 'Pipe 1 Message' );
		assertEquals( message1.getPriority(), Message.PRIORITY_LOW);

		// test message 2 assertions
		var message2: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message2, IPipeMessage ) );
		assertTrue( message2 == pipe2Message ); // object equality
		assertEquals( message2.getType(), Message.NORMAL );
		assertEquals( message2.getHeader().testProp, 2);
		assertEquals( cast( message2.getBody(), Xml ).firstElement().get( 'testAtt' ), 'Pipe 2 Message');
		assertEquals( message2.getPriority(), Message.PRIORITY_HIGH);

	}
   		
	/**
	 * Test receiving messages from four pipes using a TeeMerge.
	 */
	public function testReceiveMessagesFromFourPipesViaTeeMerge(): Void 
	{
		// create a message to send on pipe 1
		var pipe1Message: IPipeMessage = new Message( Message.NORMAL, { testProp: 1 } );
		var pipe2Message: IPipeMessage = new Message( Message.NORMAL, { testProp: 2 } );
		var pipe3Message: IPipeMessage = new Message( Message.NORMAL, { testProp: 3 } );
		var pipe4Message: IPipeMessage = new Message( Message.NORMAL, { testProp: 4 } );

		// create pipes 1, 2, 3 and 4
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();
		var pipe3: IPipeFitting = new Pipe();
		var pipe4: IPipeFitting = new Pipe();
   			
		// create merging tee
		var teeMerge: TeeMerge = new TeeMerge( pipe1, pipe2 );
		var connectedExtraInput3: Bool = teeMerge.connectInput( pipe3 );
		var connectedExtraInput4: Bool = teeMerge.connectInput( pipe4 );

		// create listener
		var listener: PipeListener = new PipeListener( this, callBackMethod );
   			
		// connect the listener to the tee and write the messages
		var connected: Bool = teeMerge.connect( listener );
   			
		// write messages to their respective pipes
		var pipe1written: Bool = pipe1.write( pipe1Message );
		var pipe2written: Bool = pipe2.write( pipe2Message );
		var pipe3written: Bool = pipe3.write( pipe3Message );
		var pipe4written: Bool = pipe4.write( pipe4Message );
   			
		// test assertions
		assertTrue( Std.is( pipe1Message, IPipeMessage ) );
		assertTrue( Std.is( pipe2Message, IPipeMessage ) );
		assertTrue( Std.is( pipe3Message, IPipeMessage ) );
		assertTrue( Std.is( pipe4Message, IPipeMessage ) );
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( Std.is( pipe3, Pipe ) );
		assertTrue( Std.is( pipe4, Pipe ) );
		assertTrue( Std.is( teeMerge, TeeMerge ) );
		assertTrue( Std.is( listener, PipeListener ) );
		assertTrue( connected );
		assertTrue( connectedExtraInput3 );
		assertTrue( connectedExtraInput4 );
		assertTrue( pipe1written );
		assertTrue( pipe2written );
		assertTrue( pipe3written );
		assertTrue( pipe4written );
   			
		// test that both messages were received, then test
		// FIFO order by inspecting the messages themselves
		assertEquals( messagesReceived.length, 4 );
   			
		// test message 1 assertions 
		var message1: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message1, IPipeMessage ) );
		assertTrue( message1 == pipe1Message ); // object equality
		assertEquals( message1.getType(), Message.NORMAL );
		assertEquals( message1.getHeader().testProp, 1);

		// test message 2 assertions
		var message2: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message2, IPipeMessage ) );
		assertTrue( message2 == pipe2Message ); // object equality
		assertEquals( message2.getType(), Message.NORMAL );
		assertEquals( message2.getHeader().testProp, 2);

		// test message 3 assertions 
		var message3: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message3, IPipeMessage ) );
		assertTrue( message3 == pipe3Message ); // object equality
		assertEquals( message3.getType(), Message.NORMAL );
		assertEquals( message3.getHeader().testProp, 3);

		// test message 4 assertions
		var message4: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( message2, IPipeMessage ) );
		assertTrue( message4 == pipe4Message ); // object equality
		assertEquals( message4.getType(), Message.NORMAL );
		assertEquals( message4.getHeader().testProp, 4);

	}
   		
	/**
	 * Array of received messages.
 	 *
	 * <p>Used by [callBackMedhod] as a place to store
	 * the received messages.</p>
	 */	
	private var messagesReceived: Array<IPipeMessage>;
   		
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