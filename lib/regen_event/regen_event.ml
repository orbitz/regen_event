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

type 'a t = 'a Msg.t Gen_server.t

(* Server loop *)
module Server = struct
  module Resp = Gen_server.Response

  type 'a handler = { id : Handler.id
		    ; h  : 'a Handler.t
		    }

  type 'a t       = { last_id  : Handler.id
		    ; handlers : 'a handler list
		    }


  let apply_event e handler = handler.h e

  let init self () =
    Deferred.return
      (Ok { last_id  = Handler.zero
	  ; handlers = []
	  })

  let handle_call _self t = function
    | Msg.Event e ->
      Deferred.List.iter ~f:(apply_event e) t.handlers >>= fun () ->
      Deferred.return (Resp.Ok t)
    | Msg.Add (h, id_var) -> begin
      (* Add a handler *)
      let id = Handler.succ t.last_id in
      let handler = { h; id } in
      let t = { last_id = id; handlers = handler::t.handlers } in
      Ivar.fill id_var id;
      Deferred.return (Resp.Ok t)
    end
    | Msg.Remove id ->
      (* Remove *)
      let handlers =
	List.filter
	  ~f:(fun h -> h.id <> id)
	  t.handlers
      in
      Deferred.return (Resp.Ok {t with handlers = handlers })
    | Msg.Sync ->
      (* Sync *)
      Deferred.return (Resp.Ok t)

  let terminate _reason _t = Deferred.unit
end

let callbacks =
  let module Gss = Gen_server.Server in
  { Gss.init        = Server.init
  ;     handle_call = Server.handle_call
  ;     terminate   = Server.terminate
  }

(* Public API *)
let start () =
  Gen_server.start () callbacks >>= function
    | Ok t    -> Deferred.return t
    | Error _ -> failwith "impossible"

let add_handler t h =
  let id = Ivar.create () in
  let msg = Msg.Add (h, id) in
  Gen_server.send t msg >>=? fun _ ->
  Ivar.read id          >>= fun handler_id ->
  Deferred.return (Ok handler_id)

let remove_handler t id =
  let msg = Msg.Remove id in
  ignore (Gen_server.send t msg)

let stop t =
  Gen_server.stop t

let sync t =
  let msg = Msg.Sync in
  Gen_server.send t msg >>= fun _ ->
  Deferred.unit

let publish_sync t e =
  let msg = Msg.Event e in
  Gen_server.send t msg >>=? fun _ ->
  Deferred.return (Ok ())

let publish_async t e =
  let msg = Msg.Event e in
  ignore (Gen_server.send t msg);
  Deferred.unit

let publish = publish_sync
