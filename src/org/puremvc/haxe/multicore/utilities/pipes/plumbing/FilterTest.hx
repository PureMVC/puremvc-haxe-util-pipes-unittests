/* 
 PureMVC MultiCore Pipes Utility Unit Tests haXe Port by Marco Secchi <marco.secchi@puremvc.org>
 PureMVC MultiCore Pipes Utility - Copyright(c) 2006-08 Futurescale, Inc., Some rights reserved. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License 
 */
package org.puremvc.haxe.multicore.utilities.pipes.plumbing;
	
import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeFitting;
import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeMessage;
import org.puremvc.haxe.multicore.utilities.pipes.messages.FilterControlMessage;
import org.puremvc.haxe.multicore.utilities.pipes.messages.Message;
	
/**
 * Test the Filter class.
 */
class FilterTest extends haxe.unit.TestCase
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
	 * Test connecting input and output pipes to a filter as well as disconnecting the output.
	 */
	public function testConnectingAndDisconnectingIOPipes(): Void 
	{

		// create output pipes 1
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();

		// create filter
		var filter: Filter = new Filter( 'TestFilter' );
   			
		// connect input fitting
		var connectedInput: Bool 	= pipe1.connect( filter );
   			
		// connect output fitting
		var connectedOutput: Bool = filter.connect( pipe2 );
   			
		// test assertions
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( Std.is( filter, Filter ) );
		assertTrue( connectedInput );
		assertTrue( connectedOutput );
   			
		// disconnect pipe 2 from filter
		var disconnectedPipe: IPipeFitting = filter.disconnect();
		assertTrue( disconnectedPipe == pipe2 );
	}
  		
  		
	/**
	 * Test applying filter to a normal message.
	 */
	public function testFilteringNormalMessage(): Void 
	{
		// create messages to send to the queue
		var message: IPipeMessage = new Message( Message.NORMAL, { width: 10, height: 2 } );
  			
		// create filter, attach an anonymous listener to the filter output to receive the message,
		// pass in an anonymous function an parameter object
		var filter: Filter = new Filter( 'scale', 
										new PipeListener( this, callBackMethod ),
										function( message: IPipeMessage, params: Dynamic ): Void { message.getHeader().width *= params.factor; message.getHeader().height *= params.factor; },
										{ factor: 10 }
									  );

		// write messages to the filter
		var written: Bool = filter.write( message );
   			
		// test assertions
		assertTrue( Std.is( message, IPipeMessage ) );
		assertTrue( Std.is( filter, Filter ) );
		assertTrue( written );
		assertEquals( messagesReceived.length, 1 );

		// test filtered message assertions 
		var recieved: IPipeMessage = messagesReceived.shift();
		assertTrue( Std.is( recieved, IPipeMessage ) );
		assertTrue( recieved == message ); // object equality
		assertEquals( recieved.getHeader().width, 100 ); 
		assertEquals( recieved.getHeader().height, 20 ); 
	}
   		
	/**
	 * Test setting filter to bypass mode, writing, then setting back to filter mode and writing. 
	 */
	public function testBypassAndFilterModeToggle(): Void 
	{
		// create messages to send to the queue
		var message: IPipeMessage = new Message( Message.NORMAL, { width: 10, height: 2 } );
  			
		// create filter, attach an anonymous listener to the filter output to receive the message,
		// pass in an anonymous function an parameter object
		var filter: Filter = new Filter( 'scale', 
										new PipeListener( this, callBackMethod ),
										function( message: IPipeMessage, params: Dynamic ): Void { message.getHeader().width *= params.factor; message.getHeader().height *= params.factor; },
										{ factor: 10 }
									  );
			
		// create bypass control message	
		var bypassMessage: FilterControlMessage = new FilterControlMessage( FilterControlMessage.BYPASS, 'scale' );

		// write bypass control message to the filter
		var bypassWritten: Bool = filter.write( bypassMessage );
   			
		// write normal message to the filter
		var written1: Bool = filter.write( message );
   			
		// test assertions
		assertTrue( Std.is( message, IPipeMessage ) );
		assertTrue( Std.is( filter, Filter ) );
		assertTrue( bypassWritten );
		assertTrue( written1 );
		assertEquals( messagesReceived.length, 1 );

		// test filtered message assertions (no change to message)
		var recieved1: IPipeMessage = messagesReceived.shift();
		assertTrue( Std.is( recieved1, IPipeMessage ) );
		assertTrue( recieved1 == message ); // object equality
		assertEquals( recieved1.getHeader().width, 10 ); 
		assertEquals( recieved1.getHeader().height, 2 ); 

		// create filter control message
		var filterMessage: FilterControlMessage = new FilterControlMessage( FilterControlMessage.FILTER, 'scale' );

		// write bypass control message to the filter
		var filterWritten: Bool = filter.write( filterMessage );
   			
		// write normal message to the filter again
		var written2: Bool = filter.write( message );

		// test assertions   			
		assertTrue( bypassWritten );
		assertTrue( written1 );
		assertEquals( messagesReceived.length, 1 );

		// test filtered message assertions (message filtered)
		var recieved2: IPipeMessage = messagesReceived.shift();
		assertTrue( Std.is( recieved2, IPipeMessage ) );
		assertTrue( recieved2 == message ); // object equality
		assertEquals( recieved2.getHeader().width, 100 ); 
		assertEquals( recieved2.getHeader().height, 20 );
	}

	/**
	 * Test setting filter parameters by sending control message. 
	 */
	public function testSetParamsByControlMessage(): Void 
	{
		// create messages to send to the queue
		var message: IPipeMessage = new Message( Message.NORMAL, { width: 10, height: 2 } );
  			
		// create filter, attach an anonymous listener to the filter output to receive the message,
		// pass in an anonymous function an parameter object
		var filter: Filter = new Filter( 'scale', 
										new PipeListener( this, callBackMethod ),
										function( message: IPipeMessage, params: Dynamic ): Void { message.getHeader().width *= params.factor; message.getHeader().height *= params.factor; },
										{ factor: 10 }
									  );
			
		// create setParams control message	
		var setParamsMessage: FilterControlMessage = new FilterControlMessage( FilterControlMessage.SET_PARAMS, 'scale', null, { factor: 5 } );

		// write filter control message to the filter
		var setParamsWritten: Bool = filter.write( setParamsMessage );
   			
		// write normal message to the filter
		var written: Bool = filter.write( message );
   			
		// test assertions
		assertTrue( Std.is( message, IPipeMessage ) );
		assertTrue( Std.is( filter, Filter ) );
		assertTrue( setParamsWritten );
		assertTrue( written );
		assertEquals( messagesReceived.length, 1 );

		// test filtered message assertions (message filtered with overridden parameters)
		var recieved: IPipeMessage = messagesReceived.shift();
		assertTrue( Std.is( recieved, IPipeMessage ) );
		assertTrue( recieved == message ); // object equality
		assertEquals( recieved.getHeader().width, 50 ); 
		assertEquals( recieved.getHeader().height, 10 ); 

	}

	/**
	 * Test setting filter function by sending control message. 
	 */
	public function testSetFilterByControlMessage(): Void 
	{
		// create messages to send to the queue
		var message: IPipeMessage = new Message( Message.NORMAL, { width: 10, height: 2 } );
  			
		// create filter, attach an anonymous listener to the filter output to receive the message,
		// pass in an anonymous function and an anonymous parameter object
		var filter: Filter = new Filter( 'scale', 
										new PipeListener( this, callBackMethod ),
										function( message: IPipeMessage, params: Dynamic ): Void { message.getHeader().width *= params.factor; message.getHeader().height *= params.factor; },
										{ factor: 10 }
									  );
			
		// create setFilter control message	
		var setFilterMessage: FilterControlMessage = new FilterControlMessage( FilterControlMessage.SET_FILTER, 'scale', function( message: IPipeMessage, params: Dynamic ): Void { message.getHeader().width /= params.factor; message.getHeader().height /= params.factor; } );

		// write filter control message to the filter
		var setFilterWritten: Bool = filter.write( setFilterMessage );
   			
		// write normal message to the filter
		var written: Bool = filter.write( message );
   			
		// test assertions
		assertTrue( Std.is( message, IPipeMessage ) );
		assertTrue( Std.is( filter, Filter ) );
		assertTrue( setFilterWritten );
		assertTrue( written );
		assertEquals( messagesReceived.length, 1 );

		// test filtered message assertions (message filtered with overridden filter function)
		var recieved: IPipeMessage = messagesReceived.shift();
		assertTrue( Std.is( recieved, IPipeMessage ) );
		assertTrue( recieved == message ); // object equality
		assertEquals( recieved.getHeader().width, 1 ); 
		assertEquals( recieved.getHeader().height, .2 ); 
	}

	/**
	 * Test using a filter function to stop propagation of a message. 
	 *
	 * <p>The way to stop propagation of a message from within a filter
	 * is to throw an error from the filter function. This test creates
	 * two NORMAL messages, each with header objects that contain 
	 * a [bozoLevel] property. One has this property set to 
	 * 10, the other to 3.</p>
	 *
	 * <p>Creates a Filter, named 'bozoFilter' with an anonymous pipe listener
	 * feeding the output back into this test. The filter funciton is an 
	 * anonymous function that throws an error if the message's bozoLevel 
	 * property is greater than the filter parameter [bozoThreshold].
	 * the anonymous filter parameters object has a [bozoThreshold]
	 * value of 5.</p>
	 *
	 * <p>The messages are written to the filter and it is shown that the 
	 * message with the [bozoLevel] of 10 is not written, while
	 * the message with the [bozoLevel] of 3 is.</p> 
	 */
 	public function testUseFilterToStopAMessage(): Void 
	{
		// create messages to send to the queue
		var message1: IPipeMessage = new Message( Message.NORMAL, { bozoLevel: 10, user: 'Dastardly Dan' } );
		var message2: IPipeMessage = new Message( Message.NORMAL, { bozoLevel: 3, user: 'Dudley Doright' } );
  			
		// create filter, attach an anonymous listener to the filter output to receive the message,
		// pass in an anonymous function and an anonymous parameter object
		var filter: Filter = new Filter( 'bozoFilter', 
										new PipeListener( this, callBackMethod ),
										function( message: IPipeMessage, params: Dynamic ): Void { if(message.getHeader().bozoLevel > params.bozoThreshold) throw 'bozoFiltered'; },
										{ bozoThreshold:5 }
									  );
			
		// write normal message to the filter
		var written1: Bool = filter.write( message1 );
		var written2: Bool = filter.write( message2 );
   			
		// test assertions
		assertTrue( Std.is( message1, IPipeMessage ) );
		assertTrue( Std.is( message2, IPipeMessage ) );
		assertTrue( Std.is( filter, Filter ) );
		assertFalse( written1 );
		assertTrue( written2 );
		assertEquals( messagesReceived.length, 1 );

		// test filtered message assertions (message with good auth token passed
		var recieved: IPipeMessage = messagesReceived.shift();
		assertTrue( Std.is( recieved, IPipeMessage ) );
		assertTrue( recieved == message2 ); // object equality

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