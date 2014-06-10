open Async.Std

type 'a t

module Handler : sig
  type 'a t = 'a -> unit Deferred.t
  type id
end

val start          : unit -> 'a t Deferred.t
val add_handler    : 'a t -> 'a Handler.t -> (Handler.id, [> `Closed ]) Deferred.Result.t
val remove_handler : 'a t -> Handler.id -> unit
val stop           : 'a t -> (unit, [> `Closed ]) Deferred.Result.t
val sync           : 'a t -> unit Deferred.t

(*
 * it's up to the implemention if [publish] is implemented
 * interms of publish_sync or publish_async
 *)
val publish       : 'a t -> 'a -> (unit, [> `Closed ]) Deferred.Result.t
val publish_sync  : 'a t -> 'a -> (unit, [> `Closed ]) Deferred.Result.t
val publish_async : 'a t -> 'a -> unit Deferred.t
