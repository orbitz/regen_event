type 'a t

val create  : unit -> 'a t
val handler : 'a t -> 'a Regen_event.Handler.t
val to_list : 'a t -> 'a list
