open Sig
open Unix
open Lwt
open Lwt_unix
open Lwt_io
open Manager_defs
open Server_functors
open Config_parser

let pl str = ignore_result (write_line stdout str)

lwt _ =
    let module KeysImpl = MakeKeyManager(BasicSocketBinding) in
    let module ServerImpl = MakeServer (KeysImpl) (BasicPermissionManager) in
    let ssl_params = parse_params_from_xml Sys.argv.(1) in
    ignore_result (print_params ssl_params);
    let ctx = try setup_ssl ssl_params
                with | _ -> ignore_result (write_line stdout (Ssl.get_error_string ()));
                            failwith "Fatal error when initializing SSL"
    in
    let sbinding fd in_chan out_chan =
        let sock_lwt = Lwt_ssl.embed_socket fd ctx in
        let sock = (match Lwt_ssl.ssl_socket sock_lwt with
                        | Some v -> v
                        | None -> failwith "Fuckin shit")
        in
        let cert = Ssl.get_certificate sock in
        ignore_result (write_line stdout "Got certificate");
        let issuer = Ssl.get_issuer cert in
        let user = Ssl.get_subject cert in
        ignore_result (write_line stdout (issuer^", "^user));
        ServerImpl.respond_to_client user inet_addr_any (in_chan, out_chan)
    in
    Conduit_lwt_unix_ssl.Server.init ~ctx
        ~certfile:ssl_params.certificate_path ~keyfile:ssl_params.private_key_path
        (ADDR_INET (inet_addr_any, 1440)) sbinding
