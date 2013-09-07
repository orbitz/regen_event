# regen_event

A really generic event handler for Core/Async.  As of this version event
handlers are defined as:

* A single function which takes an event and returns a unit Deferred.t
* Cannot throw an exception
* Must always be in a valid state even on failure

Some of these restrictions might go away in the future.

Regen_event allows for pushbuck, such that when you publish messages you do not
return from the publish call until the server has pulled it off the queue, this
allows for not overloading the system.

See tests for examples.

# Usage

## Start

    let server = Regen_event.start () in

## Add Handler

    Regen_event.add_handler server handler >>= fun id ->
    ...

## Remove handler

    Regen_event.remove_handler server id >>= fun () ->
    ...

## Publish an event in an implementation defined way

This can block or not, it's up to the implementation

    Regen_event.publish server event >>= fun () ->
    ...

## Publish an event non blockingly

    Regen_event.publish_non_block server event >>= fun () ->
    ...

## Publish always blocking

    Regen_event.publish_block server event >>= fun () ->
    ...

## Sync

This is useful if you want don't want to continue until you know that the evnets you have
sent have been handled

    Regen_event.sync server >>= fun () ->
    ...

## Stop

    Regen_event.stop server

