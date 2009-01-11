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
 * Test the Junction class.
 */
class JunctionTest extends haxe.unit.TestCase 
{
  		
	/**
 	 * Constructor.
	 */
	public function new() 
    {
		super();
		messagesReceived = new Array();
	}
  	  		
	/**
	 * Test registering an INPUT pipe to a junction.
	 *
 	 * <p>Tests that the INPUT pipe is successfully registered and
	 * that the hasPipe and hasInputPipe methods work. Then tests
 	 * that the pipe can be retrieved by name.</p>
	 *
 	 * <p>Finally, it removes the registered INPUT pipe and tests
	 * that all the previous assertions about it's registration
	 * and accessability via the Junction are no longer true.</p>
	 */
	public function testRegisterRetrieveAndRemoveInputPipe(): Void 
	{
		// create pipe connected to this test with a pipelistener
		var pipe: IPipeFitting = new Pipe( );
			
		// create junction
		var junction: Junction = new Junction();

		// register the pipe with the junction, giving it a name and direction
		var registered: Bool = junction.registerPipe( 'testInputPipe', Junction.INPUT, pipe );
			
		// test assertions
		assertTrue( Std.is( pipe, Pipe ) );
		assertTrue( Std.is( junction, Junction ) );
		assertTrue( registered );

		// assertions about junction methods once input  pipe is registered
		assertTrue( junction.hasPipe( 'testInputPipe' ) );
		assertTrue( junction.hasInputPipe( 'testInputPipe' ) );
		assertTrue( junction.retrievePipe( 'testInputPipe' ) == pipe ); // object equality

		// now remove the pipe and be sure that it is no longer there (same assertions should be false)
		junction.removePipe( 'testInputPipe' );

		assertFalse( junction.hasPipe( 'testInputPipe' ) );
		assertFalse( junction.hasInputPipe( 'testInputPipe' ) );
		assertFalse( junction.retrievePipe( 'testInputPipe' ) == pipe ); // object equality
	}

	/**
	 * Test registering an OUTPUT pipe to a junction.
 	 *
	 * <p>Tests that the OUTPUT pipe is successfully registered and
	 * that the hasPipe and hasOutputPipe methods work. Then tests
	 * that the pipe can be retrieved by name.</p>
	 *
 	 * <p>Finally, it removes the registered OUTPUT pipe and tests
	 * that all the previous assertions about it's registration
	 * and accessability via the Junction are no longer true.</p>
 	 */
	public function testRegisterRetrieveAndRemoveOutputPipe(): Void 
	{
		// create pipe connected to this test with a pipelistener
		var pipe: IPipeFitting = new Pipe( );
			
		// create junction
		var junction: Junction = new Junction();

		// register the pipe with the junction, giving it a name and direction
		var registered: Bool = junction.registerPipe( 'testOutputPipe', Junction.OUTPUT, pipe );
			
		// test assertions
		assertTrue( Std.is( pipe, Pipe ) );
		assertTrue( Std.is( junction, Junction ) );
		assertTrue( registered );
   			
		// assertions about junction methods once output pipe is registered
		assertTrue( junction.hasPipe( 'testOutputPipe' ) );
		assertTrue( junction.hasOutputPipe( 'testOutputPipe' ) );
		assertTrue( junction.retrievePipe( 'testOutputPipe' ) == pipe ); // object equality

		// now remove the pipe and be sure that it is no longer there (same assertions should be false)
		junction.removePipe( 'testOutputPipe' );

		assertFalse( junction.hasPipe( 'testOutputPipe' ) );
		assertFalse( junction.hasOutputPipe( 'testOutputPipe' ) );
		assertFalse( junction.retrievePipe( 'testOutputPipe' ) == pipe ); 
	}

	/**
 	 * Test adding a PipeListener to an Input Pipe.
 	 *
  	 * <p>Registers an INPUT Pipe with a Junction, then tests
	 * the Junction's addPipeListener method, connecting
	 * the output of the pipe back into to the test. If this
	 * is successful, it sends a message down the pipe and 
 	 * checks to see that it was received.</p>
 	 */
	public function testAddingPipeListenerToAnInputPipe(): Void 
	{
		// create pipe 
		var pipe: IPipeFitting = new Pipe();
			
		// create junction
		var junction: Junction = new Junction();

		// create test message
		var message: IPipeMessage = new Message( Message.NORMAL, { testVal: 1  } );
			
		// register the pipe with the junction, giving it a name and direction
		var registered: Bool = junction.registerPipe( 'testInputPipe', Junction.INPUT, pipe );

		// add the pipelistener using the junction method
		var listenerAdded: Bool = junction.addPipeListener( 'testInputPipe', this, callBackMethod );
						
		// send the message using our reference to the pipe, 
		// it should show up in messageReceived property via the pipeListener
		var sent: Bool = pipe.write( message ); 
			
		// test assertions
		assertTrue( Std.is( pipe, Pipe ) );
		assertTrue( Std.is( junction, Junction ) );
		assertTrue( registered );
		assertTrue( listenerAdded );
		assertTrue( sent );
		assertEquals( messagesReceived.length, 1 ); 
		assertTrue( messagesReceived.pop() == message); //object equality		
	}
   		
	/**
	 * Test using sendMessage on an OUTPUT pipe.
	 *
	 * <p>Creates a Pipe, Junction and Message. 
	 * Adds the PipeListener to the Pipe.
	 * Adds the Pipe to the Junction as an OUTPUT pipe.
	 * uses the Junction's sendMessage method to send
	 * the Message, then checks that it was received.</p>
 	 */
	public function testSendMessageOnAnOutputPipe(): Void 
	{
		// create pipe 
		var pipe: IPipeFitting = new Pipe( );
			
		// add a PipeListener manually 
		var listenerAdded: Bool = pipe.connect( new PipeListener( this, callBackMethod ) );
						
		// create junction
		var junction: Junction = new Junction();

		// create test message
		var message: IPipeMessage = new Message( Message.NORMAL, { testVal: 1 } );
			
		// register the pipe with the junction, giving it a name and direction
		var registered: Bool = junction.registerPipe( 'testOutputPipe', Junction.OUTPUT, pipe );

		// send the message using the Junction's method 
		// it should show up in messageReceived property via the pipeListener
		var sent: Bool = junction.sendMessage( 'testOutputPipe', message );
			
		// test assertions
		assertTrue( Std.is( pipe, Pipe ) );
		assertTrue( Std.is( junction, Junction ) );
		assertTrue( registered );
		assertTrue( listenerAdded );
		assertTrue( sent );
		assertEquals( messagesReceived.length, 1); 
		assertTrue( messagesReceived.pop() == message); //object equality
	}
   		
	/**
	 * Array of received messages.
	 *
	 * <p>Used by [callBackMedhod] as a place to store
	 * the recieved messages.</p>
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