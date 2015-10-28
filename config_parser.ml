open Conduit_lwt_unix_ssl

type partial_ssl_params = {
    certificate_path : string;
    private_key_path : string;
    ca_certificate_file : string;
    context : Ssl.context_type;
    verify_depth : int;
}

let print_params (params : partial_ssl_params) = Lwt_io.(
    let cert_line = "Certificate: " ^ params.certificate_path in
    let key_line = "Key: " ^ params.private_key_path in
    let file_line = "CA file: " ^ params.ca_certificate_file in
    let cont_line = match params.context with
        | Ssl.Client_context -> "Client context"
        | Ssl.Server_context -> "Server context"
        | Ssl.Both_context -> "Both contex"
    in
    let depth_line = "Verify depth: " ^ (string_of_int params.verify_depth) in
    lwt _ = write_line stdout cert_line in
    lwt _ = write_line stdout key_line in
    lwt _ = write_line stdout file_line in
    lwt _ = write_line stdout cont_line in
    write_line stdout depth_line
    )

let setup_ssl (params : partial_ssl_params ) = Ssl.(
    init ~thread_safe:true ();
    let ctx = create_context TLSv1 params.context in
    use_certificate ctx params.certificate_path params.private_key_path;
    set_verify_depth ctx params.verify_depth;
    set_verify ctx [Verify_peer; Verify_fail_if_no_peer_cert] (Some client_verify_callback);
    set_client_verify_callback_verbose true;
    load_verify_locations ctx params.ca_certificate_file "";
    set_client_verify_callback_verbose false;
    ctx
    )

let parse_params_from_xml filename : partial_ssl_params =
    let open Simplexmlparser in
    let tree = xmlparser_file filename in
    let params = {
        certificate_path = "./cert.pem";
        private_key_path = "./key.key";
        ca_certificate_file = "/etc/ssl/certs/ca-certificates.crt";
        context = Ssl.Both_context;
        verify_depth = 1;
    } in
    let register_kv params key value =
        match key with
            | "certificate" -> {params with certificate_path = value}
            | "private_key" -> {params with private_key_path = value}
            | "ca_certificates" -> {params with ca_certificate_file = value}
            | "context" -> begin match value with
                | "client" -> {params with context = Ssl.Client_context}
                | "server" -> {params with context = Ssl.Server_context}
                | "both" -> {params with context = Ssl.Both_context}
                | s -> failwith ("Invalid context type: "^s)
            end
            | "verify_depth" -> let vnum = int_of_string value in
                {params with verify_depth = vnum}
            | s -> failwith ("Unidentified Configuration element: "^s)
    in
    let rec parse xml params = match xml with
        | (Element (name, _, subnodes))::t -> begin match subnodes with
            | (PCData v)::_ -> parse t (register_kv params name v)
            | _ -> failwith "Improperly formatted configuration"
        end
        | [] -> params
        | _ -> failwith "Improperly formatted configuration"
    in
    parse tree params
