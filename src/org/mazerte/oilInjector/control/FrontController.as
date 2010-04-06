/*

Copyright (c) 2006. Adobe Systems Incorporated.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of Adobe Systems Incorporated nor the names of its
    contributors may be used to endorse or promote products derived from this
    software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

@ignore
*/
package org.mazerte.oilInjector.control
{
   import org.mazerte.oilInjector.OilInjectorError;
   import org.mazerte.oilInjector.OilInjectorMessageCodes;
   import org.mazerte.oilInjector.actions.IAction;

   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;

   /**
    * A base class for an application specific front controller,
    * that is able to dispatch control following particular user gestures to appropriate
    * command classes.
    *
    * <p>
    * The Front Controller is the centralised request handling class in a
    * Cairngorm application.  Throughout the application architecture are
    * scattered a number of CairngormEventDispatcher.getInstance().dispatchEvent( event )
    * method calls, that signal to the listening controller that a user gesture
    * has occured.
    * </p>
    *
    * <p>
    * The role of the Front Controller is to first register all the different
    * events that it is capable of handling against worker classes, called
    * command classes.  On hearing an application event, the Front Controller
    * will look up its table of registered events, find the appropriate
    * command for handling of the event, before dispatching control to the
    * command by calling its execute() method.
    * </p>
    *
    * <p>
    * Commands are added to the front controller with a weak reference,
    * meaning that when the command is garbage collected, the reference in
    * the controller is also garbage collected.
    * </p>
    *
    * <p>
    * The Front Controller is a base-class that  listen for events
    * dispatched by CairngormEventDispatcher.  In a
    * Cairngorm application, the developer should create a class that
    * extends the FrontController, and in the constructor of their
    * application specific controller, they should make numerous calls to
    * addCommand() to register all the expected events with application
    * specific command classes.
    * </p>
    *
    * <p>
    * Consider a LoginController, that is the main controller for a Login
    * application that has 2 user gestures - Login and Logout.  The application
    * will have 2 buttons, "Login" and "Logout" and in the click handler for
    * each button, one of the following methods is executed:
    * </p>
    *
    * <pre>
    * public function doLogin() : void
    * {
    *    var event : LoginEvent = new LoginEvent( username.text, password.text );
    *    CairngormEventDispatcher.getInstance.dispatchEvent( event );
    * }
    *
    * public function doLogout() : void
    * {
    *    var event : LogoutEvent = new LogoutEvent();
    *    CairngormEventDispatcher.getInstance.dispatchEvent( event );
    * }
    * </pre>
    *
    * <p>
    * We would create LoginController as follows:
    * </p>
    *
    * <pre>
    * class LoginController extends org.mazerte.oilInjector.control.FrontController
    * {
    *    public function LoginController()
    *    {
    *       initialiseCommands();
    *    }
    *
    *    public function initialiseCommands() : void
    *    {
    *       addCommand( LoginEvent.EVENT_LOGIN, LoginCommand );
    *       addCommand( LogoutEvent.EVENT_LOGOUT, LogoutCommand );
    *    }
    *
    * }
    * </pre>
    *
    * <p>
    * In our concrete implementation of a FrontController, LoginController, we
    * register the 2 events that are expected for broadcast - login and logout -
    * using the addCommand() method of the parent FrontController class, to
    * assign a command class to each event.
    * </p>
    *
    * <p>
    * Adding a new use-case to a Cairngorm application is as simple as
    * registering the event against a command in the application Front Controller,
    * and then creating the concrete command class.
    * </p>
    *
    * <p>
    * The concrete implementation of the FrontController, LoginController,
    * should be created once and once only (as we only want a single controller
    * in our application architecture).  Typically, in our main application, we
    * would declare our FrontController child class as a tag, which should be placed
    * above any tags which have a dependency on the FrontController
    * </p>
    *
    * <pre>
    * &lt;mx:Application  xmlns:control="com.domain.project.control.LoginController"   ... &gt;
    *
    *   &lt;control:LoginController id="controller" /&gt;
    *
    *  ...
    *
    * </pre>
    *
    * @see org.mazerte.oilInjector.commands.ICommand
    */
   public class FrontController implements IFrontController
   {
     /**
      * Dictionary of event name to command class mappings
      */
      protected var actions : Dictionary = new Dictionary();

     /**
      * Registers a ICommand class with the Front Controller, against an event name
      * and listens for events with that name.
      *
      * <p>When an event is broadcast that matches commandName,
      * the ICommand class referred to by commandRef receives control of the
      * application, by having its execute() method invoked.</p>
      *
      * @param commandName The name of the event that will be broadcast by the
      * when a particular user gesture occurs, eg "login"
      *
      * @param commandRef An ICommand Class reference upon which execute()
      * can be called when the Front Controller hears an event broadcast with
      * commandName. Typically, this argument is passed as "LoginCommand"
      * or similar.
      *
      * @param useWeakReference A Boolean indicating whether the controller
      * should added as a weak reference to the CairngormEventDispatcher,
      * meaning it will eligibile for garbage collection if it is unloaded from
      * the main application. Defaults to true.
      */
      public function addAction( actionName : String, actionRef : Class, useWeakReference : Boolean = true ) : void
      {
         if ( actionName == null )
            throw new OilInjectorError( OilInjectorMessageCodes.ACTION_NAME_NULL );

         if ( actionRef == null )
            throw new OilInjectorError( OilInjectorMessageCodes.ACTION_REF_NULL );

         if( actions[ actionName ] != null )
            throw new OilInjectorError( OilInjectorMessageCodes.ACTION_ALREADY_REGISTERED, actionName );

         if ( implementsIAction( actionRef ) == false )
         	throw new OilInjectorError( OilInjectorMessageCodes.ACTION_SHOULD_IMPLEMENT_ICOMMAND, actionRef );

         actions[ actionName ] = actionRef;
         OilInjectorEventDispatcher.getInstance().addEventListener( actionName, executeAction, false, 0, useWeakReference );
      }

     /**
      * Deregisters an ICommand class with the given event name from the Front Controller
      *
      * @param commandName The name of the event that will be broadcast by the
      * when a particular user gesture occurs, eg "login"
      *
      */
      public function removeAction( actionName : String ) : void
      {
         if ( actionName === null )
            throw new OilInjectorError( OilInjectorMessageCodes.ACTION_NAME_NULL, actionName);

         if ( actions[ actionName ] === undefined )
            throw new OilInjectorError( OilInjectorMessageCodes.ACTION_NOT_REGISTERED, actionName);

         OilInjectorEventDispatcher.getInstance().removeEventListener( actionName, executeAction );

         actions[ actionName ] = undefined;
         delete actions[ actionName ];
      }

      /**
      * Executes the command
      */
      protected function executeAction( event : OilInjectorEvent ) : void
      {
         var actionToInitialise : Class = getAction( event.type );
         var actionToExecute : IAction = new actionToInitialise();

         actionToExecute.execute( event );
      }

     /**
      * Returns the command class registered with the command name.
      */
      protected function getAction( actionName : String ) : Class
      {
         var action : Class = actions[ actionName ];

         if ( action == null )
            throw new OilInjectorError( OilInjectorMessageCodes.ACTION_NOT_FOUND, actionName );

         return action;
      }

      /**
       * Returns true or false to indicate whether the commandRef implements
       * the ICommand interface
       */
      private function implementsIAction( actionRef : Class ) : Boolean
      {
         var classDescription : XML = describeType( actionRef ) as XML;

         return classDescription.factory.implementsInterface.( @type == getQualifiedClassName( IAction ) ).length() != 0;
      }
   }
}