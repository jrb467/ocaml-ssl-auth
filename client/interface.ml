open Sig
open Lwt
open Lwt_io

let process server_in server_out cmd_in cmd_out =
    let rec pipe pin pout =
        read_line pin >>= (fun str ->
            write_line pout str >>= (fun () ->
                pipe pin pout
            )
        )
    in
    (pipe server_in cmd_out) <&> (pipe cmd_in server_out)
