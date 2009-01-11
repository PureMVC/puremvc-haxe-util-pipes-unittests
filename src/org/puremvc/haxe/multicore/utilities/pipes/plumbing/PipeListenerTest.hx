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
 * Test the PipeListener class.
 */
class PipeListenerTest extends haxe.unit.TestCase 
{
  		
	/**
	 * Test connecting a pipe listener to a pipe. 
	 */
	public function testConnectingToAPipe(): Void 
	{
		// create pipe and listener
		var pipe: IPipeFitting = new Pipe();
		var listener: PipeListener = new PipeListener( this, callBackMethod );
   			
 		// connect the listener to the pipe
		var success: Bool = pipe.connect( listener );
   			
		// test assertions
		assertTrue( Std.is( pipe, Pipe ) );
		assertTrue( success );
	}

	/**
	 * Test receiving a message from a pipe using a PipeListener.
	 */
	public function testReceiveMessageViaPipeListener(): Void 
	{
		// create a message
		var messageToSend: IPipeMessage = new Message( Message.NORMAL, 
												      { testProp: 'testval' },
													  Xml.parse( "<testMessage testAtt='Hello'/>" ),
												      Message.PRIORITY_HIGH );
		// create pipe and listener
		var pipe: IPipeFitting = new Pipe();
		var listener: PipeListener = new PipeListener( this, callBackMethod );
   			
		// connect the listener to the pipe and write the message
		var connected: Bool = pipe.connect( listener );
		var written: Bool = pipe.write( messageToSend );
  			
		// test assertions
		assertTrue( Std.is( pipe, Pipe ) );
		assertTrue( connected );
		assertTrue( written );
		assertTrue( Std.is( messageReceived, Message ) );
		assertEquals( messageReceived.getType(), Message.NORMAL );
		assertEquals( messageReceived.getHeader().testProp, 'testval' );
		assertEquals( cast( messageReceived.getBody(), Xml ).firstElement().get( 'testAtt' ), 'Hello' );
		assertEquals( messageReceived.getPriority(), Message.PRIORITY_HIGH);
	}
   		
	/**
	 * Recipient of message.
	 *
	 * <p>Used by [callBackMedhod] as a place to store
	 * the recieved message.</p>
	 */     		
	private var messageReceived: IPipeMessage;
   		
	/**
	 * Callback given to [PipeListener] for incoming message.
	 *
	 * <p>Used by [testReceiveMessageViaPipeListener] 
	 * to get the output of pipe back into this  test to see 
	 * that a message passes through the pipe.</p>
	 */
	private function callBackMethod( message: IPipeMessage ): Void
	{
		this.messageReceived = message;
	}
   		
}