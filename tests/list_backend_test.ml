open Core.Std
open Async.Std

let main () =
  let backend = Regen_event_list_backend.create () in
  let handler = Regen_event_list_backend.handler backend in
  let server = Regen_event.start () in
  Regen_event.add_handler server handler >>= fun _ ->
  Regen_event.publish server "blah"      >>= fun () ->
  Regen_event.sync server                >>= fun () ->
  Regen_event.stop server;
  if Regen_event_list_backend.to_list backend <> ["blah"] then
    failwith "Failed!";
  Deferred.return (shutdown 0)

let () =
  ignore (main ());
  never_returns (Scheduler.go ())

