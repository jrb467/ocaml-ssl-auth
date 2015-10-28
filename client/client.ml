open Sig
open Lwt
open Lwt_unix
open Lwt_io
open Config_parser

let print_exc sect ex =
    ignore_result (write_line stdout sect);
    ignore_result (write_line stdout (Ssl.get_error_string ()));
    failwith "Ssl error"

let start () =
    let cfg = Sys.argv.(1) in
    let addr = Unix.inet_addr_of_string (Sys.argv.(2)) in
    let sock_addr = ADDR_INET (addr, 1440) in
    let params = parse_params_from_xml cfg in
    ignore_result (print_params params);
    let ctx = try setup_ssl params
                with | _ -> ignore_result (write_line stdout (Ssl.get_error_string ()));
                            failwith "Error initializing SSL"
    in
    let connect_thunk () = Conduit_lwt_unix_ssl.Client.connect ~ctx sock_addr in
    lwt (conn_desc, in_chan, out_chan) = catch connect_thunk (print_exc "connect") in
    Interface.process in_chan out_chan stdin stdout

lwt _ =
    catch start (print_exc "main")
