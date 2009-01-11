/* 
 PureMVC MultiCore Pipes Utility Unit Tests haXe Port by Marco Secchi <marco.secchi@puremvc.org>
 PureMVC MultiCore Pipes Utility - Copyright(c) 2006-08 Futurescale, Inc., Some rights reserved. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License 
 */
package org.puremvc.haxe.multicore.utilities.pipes.plumbing;

import org.puremvc.haxe.multicore.utilities.pipes.interfaces.IPipeMessage;
import org.puremvc.haxe.multicore.utilities.pipes.messages.Message;
	
/**
 * Test the Message class.
 */
class MessageTest extends haxe.unit.TestCase 
{
  		
	/**
	 * Tests the constructor parameters and getters.
	 */
	public function testConstructorAndGetters(): Void 
	{
		// create a message with complete constructor args
		var message: IPipeMessage = new Message( Message.NORMAL, 
												{ testProp: 'testval' },
												Xml.parse( "<testMessage testAtt='Hello'/>" ),
												Message.PRIORITY_HIGH);
   			
		// test assertions
		assertTrue( Std.is( message, Message ) );
		assertEquals( message.getType(), Message.NORMAL );
		assertEquals( message.getHeader().testProp, 'testval');
		assertEquals( cast( message.getBody(), Xml ).firstElement().get( 'testAtt' ), 'Hello' );
		assertEquals( message.getPriority(), Message.PRIORITY_HIGH);
	}

	/**
 	 * Tests message default priority.
	 */
	public function testDefaultPriority(): Void 
	{
		// Create a message with minimum constructor args
		var message: IPipeMessage = new Message( Message.NORMAL );
  			
		// test assertions
		assertEquals( message.getPriority(), Message.PRIORITY_MED);
   			
	}

	/**
	 * Tests the setters and getters.
	 */
	public function testSettersAndGetters(): Void 
	{
		// create a message with minimum constructor args
		var message: IPipeMessage = new Message( Message.NORMAL );
   			
		// Set remainder via setters
		message.setHeader( { testProp: 'testval' } );
		message.setBody( Xml.parse( "<testMessage testAtt='Hello'/>" ) );
		message.setPriority( Message.PRIORITY_LOW );
  			
		// test assertions
		assertTrue( Std.is( message, Message ) );
		assertEquals( message.getType(), Message.NORMAL );
		assertEquals( message.getHeader().testProp, 'testval');
		assertEquals( cast( message.getBody(), Xml ).firstElement().get( 'testAtt' ), 'Hello');
		assertEquals( message.getPriority(), Message.PRIORITY_LOW);
   			
	}
}