open Lwt_unix
open Lwt_io

(** WHERE EVERYTHING SHOULD GO (as of now) *)
(**
 *  Any types related to protocol standards (like communications chunks),
 *  belongs in the global scope, along with very obvious types (like ip
 *  addresses)
 *
 *  Anything NOT protocol related (AKA up for the implementer to decide)
 *  should go inside of the respective server/manager modules
 *)

type port = int

type key = string
type username = string
type password = string

module type RemoteKeyManager = sig
    type pub_key

    val get_user_key : username -> inet_addr -> pub_key option
    val add_user_key : username -> inet_addr -> pub_key -> bool
    val write_key : output_channel -> pub_key -> unit Lwt.t
end

module type PermissionManager = sig
    type permissions

    val check_permissions : username -> inet_addr -> key list -> bool
    val update_permissions : username -> inet_addr -> (key * permissions) list -> bool
end

module type Server = sig
    type permissions
    type pub_key

    val respond_to_client : username -> inet_addr -> input_channel * output_channel -> unit Lwt.t
end

module type SocketBinding = sig
    val connect : inet_addr -> port -> (input_channel * output_channel) Lwt.t
end
