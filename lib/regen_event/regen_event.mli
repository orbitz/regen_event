open Async.Std

type 'a t

module Handler : sig
  type 'a t = 'a -> unit Deferred.t
  type id
end

val start             : unit -> 'a t
val add_handler       : 'a t -> 'a Handler.t -> Handler.id Deferred.t
val remove_handler    : 'a t -> Handler.id -> unit
val stop              : 'a t -> unit
val sync              : 'a t -> unit Deferred.t

(*
 * it's up to the implemention if [publish] is implemented
 * interms of publish_block or publish_non_block
 *)
val publish           : 'a t -> 'a -> unit Deferred.t
val publish_block     : 'a t -> 'a -> unit Deferred.t
val publish_non_block : 'a t -> 'a -> unit Deferred.t
