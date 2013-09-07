open Core.Std
open Async.Std

module Handler = struct
  type 'a t = 'a -> unit Deferred.t
  type id   = int

  let zero    = 0
  let succ id = id + 1
end

module Msg = struct
  type 'a t =
    | Event  of 'a
    | Add    of ('a Handler.t * Handler.id Ivar.t)
    | Remove of Handler.id
    | Sync
end

type 'a t = 'a Msg.t Pipe.Writer.t

(* Server loop *)
module Server = struct
  type 'a handler = { id : Handler.id
		    ; h  : 'a Handler.t
		    }

  type 'a t       = { last_id  : Handler.id
		    ; handlers : 'a handler list
		    ; r        : 'a Msg.t Pipe.Reader.t
		    }

  let apply_event e handler = handler.h e

  let rec loop t =
    let open Deferred.Monad_infix in
    Pipe.read t.r >>= function
      | `Eof ->
	Deferred.unit

      (* Publish an event *)
      | `Ok (Msg.Event e) ->
	Deferred.List.iter ~f:(apply_event e) t.handlers >>= fun () ->
	loop t

      (* Add a handler *)
      | `Ok (Msg.Add (h, id_var)) ->
	let id = Handler.succ t.last_id in
	let handler = { h; id } in
	let t = { t with last_id = id; handlers = handler::t.handlers } in
	Ivar.fill id_var id;
	loop t

      (* Remove *)
      | `Ok (Msg.Remove id) ->
	let handlers =
	  List.filter
	    ~f:(fun h -> h.id <> id)
	    t.handlers
	in
	loop {t with handlers = handlers }

      (* Sync *)
      | `Ok Msg.Sync ->
	loop t

  let start reader =
    let t = { r        = reader
	    ; last_id  = Handler.zero
	    ; handlers = []
	    }
    in
    loop t

end

let send_block     = Pipe.write
let send_non_block = Pipe.write_without_pushback

(* Public API *)
let start () =
  let (r, w) = Pipe.create () in
  ignore (Server.start r);
  w

let add_handler t h =
  let id = Ivar.create () in
  let msg = Msg.Add (h, id) in
  send_non_block t msg;
  Ivar.read id

let remove_handler t id =
  let msg = Msg.Remove id in
  send_non_block t msg

let stop t =
  Pipe.close t

let sync t =
  let msg = Msg.Sync in
  send_block t msg

let publish_block t e =
  let msg = Msg.Event e in
  send_block t msg

let publish_non_block t e =
  let msg = Msg.Event e in
  send_non_block t msg;
  Deferred.unit

let publish = publish_block
