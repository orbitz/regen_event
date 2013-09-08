open Async.Std

type 'a t = 'a list ref

let create ()   = ref []
let handler t e = t := e::!t; Deferred.unit
let to_list t   = !t

