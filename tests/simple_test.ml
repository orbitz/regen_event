open Core.Std
open Async.Std

type event = string

let handlers_checkin = ref 0

let handler id _ =
  handlers_checkin := !handlers_checkin + 1;
  Deferred.unit

let main () =
  let h1 = handler 0 in
  let h2 = handler 1 in
  let h3 = handler 2 in
  let server = Regen_event.start () in
  Regen_event.add_handler server h1 >>= fun _ ->
  Regen_event.add_handler server h2 >>= fun _ ->
  Regen_event.add_handler server h3 >>= fun _ ->
  Regen_event.publish server None   >>= fun () ->
  Regen_event.sync server           >>= fun () ->
  Regen_event.stop server;
  if !handlers_checkin <> 3 then
    failwith "Not all handlers checked in";
  Deferred.return (shutdown 0)

let () =
  ignore (main ());
  never_returns (Scheduler.go ())

