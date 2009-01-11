/* 
 PureMVC MultiCore Pipes Utility Unit Tests haXe Port by Marco Secchi <marco.secchi@puremvc.org>
 PureMVC MultiCore Pipes Utility - Copyright(c) 2006-08 Futurescale, Inc., Some rights reserved. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License 
 */
package org.puremvc.haxe.multicore.utilities.pipes.plumbing;
	
import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeFitting;
import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeMessage;
import org.puremvc.haxe.multicore.utilities.pipes.messages.Message;
import org.puremvc.haxe.multicore.utilities.pipes.messages.QueueControlMessage;
	
/**
 * Test the Queue class.
 */
class QueueTest extends haxe.unit.TestCase 
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
	 * Test connecting input and output pipes to a queue. 
	 */
	public function testConnectingIOPipes(): Void 
	{

		// create output pipes 1
		var pipe1: IPipeFitting = new Pipe();
		var pipe2: IPipeFitting = new Pipe();

		// create queue
		var queue: Queue= new Queue();
   			
		// connect input fitting
		var connectedInput: Bool = pipe1.connect( queue );
   			
		// connect output fitting
		var connectedOutput: Bool = queue.connect( pipe2 );
   			
		// test assertions
		assertTrue( Std.is( pipe1, Pipe ) );
		assertTrue( Std.is( pipe2, Pipe ) );
		assertTrue( Std.is( queue, Queue ) );
		assertTrue( connectedInput );
		assertTrue( connectedOutput );
	}
  		
  		
	/**
 	 * Test writing multiple messages to the Queue followed by a Flush message.
	 *
 	 * <p>Creates messages to send to the queue. 
	 * Creates queue, attaching an anonymous listener to its output.
	 * Writes messages to the queue. Tests that no messages have been
	 * received yet (they've been enqueued). Sends FLUSH message. Tests
	 * that messages were receieved, and in the order sent (FIFO).<p>
 	 */
	public function testWritingMultipleMessagesAndFlush(): Void 
	{
		// create messages to send to the queue
		var message1: IPipeMessage = new Message( Message.NORMAL, { testProp: 1 } );
		var message2: IPipeMessage = new Message( Message.NORMAL, { testProp: 2 } );
		var message3: IPipeMessage = new Message( Message.NORMAL, { testProp: 3 } );
  			
		// create queue control flush message
		var flush: IPipeMessage = new QueueControlMessage( QueueControlMessage.FLUSH );

		// create queue, attaching an anonymous listener to its output
		var queue: Queue= new Queue( new PipeListener( this, callBackMethod ) );

		// write messages to the queue
		var message1written: Bool = queue.write( message1 );
		var message2written: Bool = queue.write( message2 );
		var message3written: Bool = queue.write( message3 );
   			
		// test assertions
		assertTrue( Std.is( message1, IPipeMessage ) );
		assertTrue( Std.is( message2, IPipeMessage ) );
		assertTrue( Std.is( message3, IPipeMessage ) );
		assertTrue( Std.is( flush, IPipeMessage ) );
		assertTrue( Std.is( queue, Queue ) );

		assertTrue( message1written );
		assertTrue( message2written );
		assertTrue( message3written );

		// test that no messages were received (they've been enqueued)
		assertEquals( messagesReceived.length, 0 );

		// write flush control message to the queue
		var flushWritten: Bool = queue.write( flush );
   			
		// test that all messages were received, then test
		// FIFO order by inspecting the messages themselves
		assertEquals( messagesReceived.length, 3 );
   			
		// test message 1 assertions 
		var recieved1: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( recieved1, IPipeMessage ) );
		assertTrue( recieved1 == message1 ); // object equality

		// test message 2 assertions
		var recieved2: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( recieved2, IPipeMessage ) );
		assertTrue( recieved2 == message2 ); // object equality

		// test message 3 assertions
		var recieved3: IPipeMessage = messagesReceived.shift();

		assertTrue( Std.is( recieved3, IPipeMessage ) );
		assertTrue( recieved3 == message3 ); // object equality
	}
   		
	/**
 	 * Test the Sort-by-Priority and FIFO modes.
	 *
 	 * <p>Creates messages to send to the queue, priorities unsorted. 
	 * Creates queue, attaching an anonymous listener to its output.
	 * Sends SORT message to start sort-by-priority order mode.
	 * Writes messages to the queue. Sends FLUSH message, tests
	 * that messages were receieved in order of priority, not how
	 * they were sent.<p>
	 *
	 * <p>Then sends a FIFO message to switch the queue back to
	 * default FIFO behavior, sends messages again, flushes again,
	 * tests that the messages were recieved and in the order they
	 * were originally sent.</p>
	 */
	public function testSortByPriorityAndFIFO(): Void 
	{
		// create messages to send to the queue
		var message1: IPipeMessage = new Message( Message.NORMAL, null, null, Message.PRIORITY_MED );
		var message2: IPipeMessage = new Message( Message.NORMAL, null, null, Message.PRIORITY_LOW );
		var message3: IPipeMessage = new Message( Message.NORMAL, null, null, Message.PRIORITY_HIGH );
  			
		// create queue, attaching an anonymous listener to its output
		var queue: Queue= new Queue( new PipeListener( this, callBackMethod ) );
   			
		// begin sort-by-priority order mode
		var sortWritten: Bool = queue.write( new QueueControlMessage( QueueControlMessage.SORT ) );
			
		// write messages to the queue
		var message1written: Bool = queue.write( message1 );
		var message2written: Bool = queue.write( message2 );
		var message3written: Bool = queue.write( message3 );
			
		// flush the queue
		var flushWritten: Bool = queue.write( new QueueControlMessage( QueueControlMessage.FLUSH ) );
			   			
		// test assertions
		assertTrue( sortWritten);
		assertTrue( message1written );
		assertTrue( message2written );
		assertTrue( message3written );
		assertTrue( flushWritten);

		// test that 3 messages were received
		assertEquals( messagesReceived.length, 3 );

		// get the messages
		var recieved1: IPipeMessage = messagesReceived.shift();
		var recieved2: IPipeMessage = messagesReceived.shift();
		var recieved3: IPipeMessage = messagesReceived.shift();

		// test that the message order is sorted 
		assertTrue( recieved1.getPriority() < recieved2.getPriority() ); 
		assertTrue( recieved2.getPriority() < recieved3.getPriority() ); 
		assertTrue( recieved1 == message3 ); // object equality
		assertTrue( recieved2 == message1 ); // object equality
		assertTrue( recieved3 == message2 ); // object equality

		// begin FIFO order mode
		var fifoWritten: Bool = queue.write( new QueueControlMessage( QueueControlMessage.FIFO ) );

		// write messages to the queue
		var message1writtenAgain: Bool = queue.write( message1 );
		var message2writtenAgain: Bool = queue.write( message2 );
		var message3writtenAgain: Bool = queue.write( message3 );
			
		// flush the queue
		var flushWrittenAgain: Bool = queue.write( new QueueControlMessage( QueueControlMessage.FLUSH ) );
			   			
		// test assertions
		assertTrue( fifoWritten);
		assertTrue( message1writtenAgain );
		assertTrue( message2writtenAgain );
		assertTrue( message3writtenAgain );
		assertTrue( flushWrittenAgain);

		// test that 3 messages were received 
		assertEquals( messagesReceived.length, 3 );

		// get the messages
		var recieved1Again: IPipeMessage = messagesReceived.shift();
		var recieved2Again: IPipeMessage = messagesReceived.shift();
		var recieved3Again: IPipeMessage = messagesReceived.shift();

		// test message order is FIFO
		assertTrue( recieved1Again == message1 ); // object equality
		assertTrue( recieved2Again == message2 ); // object equality
		assertTrue( recieved3Again == message3 ); // object equality
		assertEquals( recieved1Again.getPriority(), Message.PRIORITY_MED ); 
		assertEquals( recieved2Again.getPriority(), Message.PRIORITY_LOW ); 
		assertEquals( recieved3Again.getPriority(), Message.PRIORITY_HIGH ); 

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