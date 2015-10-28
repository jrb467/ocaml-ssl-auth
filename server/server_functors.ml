open Sig
open Lwt
open Lwt_io

module MakeKeyManager (S : SocketBinding) = struct
    type pub_key = int * int

    let map = Hashtbl.create 10

    let get_user_key username ip =
        if Hashtbl.mem map (username, ip) then
            Some (Hashtbl.find map (username, ip))
        else None

    let add_user_key user addr pubkey =
        if Hashtbl.mem map (user, addr) then false
        else begin
            Hashtbl.add map (user, addr) pubkey;
            true
        end

    let write_key cout (p1, p2) = let soi = string_of_int in
        write cout ("("^(soi p1)^", "^(soi p2)^")\n")
end

module MakeServer (K : RemoteKeyManager) (P : PermissionManager)
    : Server with type permissions = P.permissions
            and type pub_key = K.pub_key = struct

    type permissions = P.permissions
    type pub_key = K.pub_key

    type error_type =
        | Unknown_operation

    let xc cout str = write_line cout str
    let oc cin () = read_line cin

    let error (etype : error_type) (cin,cout) =
        let resp = begin match etype with
            | Unknown_operation -> "ERROR\nUnknown or invalid operation supplied"
        end
        in write_line cout resp

    let query_response (cin,cout) =
        let x = xc cout in
        let o = oc cin in
        lwt key = o () in
        x key

    let modify_response (cin,cout) =
        let x = xc cout in
        let o = oc cin in
        x "FAGGIT"

    let append_response (cin,cout) =
        let x = xc cout in
        let o = oc cin in
        write_line cout "Ballsack"

    let delete_response (cin,cout) =
        let x = xc cout in
        let o = oc cin in
        write_line cout "Ballsack"

    let create_response (cin,cout) =
        let x = xc cout in
        let o = oc cin in
        write_line cout "Ballsack"

    let permissions_response (cin,cout) =
        let x = xc cout in
        let o = oc cin in
        write_line cout "Ballsack"

    (* TODO add credentials in *)

    let rec respond_to_client user addr (cin, cout) =
        lwt () = xc stdout "Waiting for input..." in
        read_line cin >>= (fun s ->
            let rfun = begin match s with
                | "QUERY" -> query_response
                | "MODIFY" -> modify_response
                | "APPEND" -> append_response
                | "DELETE" -> delete_response
                | "CREATE" -> create_response
                | "PERMISSIONS" -> permissions_response
                | _ -> error Unknown_operation
            end
            in
            lwt () = rfun (cin,cout) in
            respond_to_client user addr (cin,cout)
        )


end
