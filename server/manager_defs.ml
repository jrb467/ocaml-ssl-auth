open Sig
open Lwt
open Lwt_unix

module BasicPermissionManager : PermissionManager = struct
    type permissions = bool

    let perms = Hashtbl.create 10

    let check_permissions username ip keys =
        if not (Hashtbl.mem perms (username, ip)) then false
        else
            let p_table = Hashtbl.find perms (username, ip) in
            let rec test_perms = function
                | h::t ->   if Hashtbl.mem p_table h then begin
                                if Hashtbl.find p_table h then test_perms t
                                else false
                            end
                            else false
                | [] -> true
            in test_perms keys

    let update_permissions username ip plist =
        if not (Hashtbl.mem perms (username, ip))
            then Hashtbl.add perms (username, ip) (Hashtbl.create 1);
        let p_tab = Hashtbl.find perms (username, ip) in
        let rec updater = function
            | (k, p)::t -> begin
                if not (Hashtbl.mem p_tab k) then Hashtbl.add p_tab k p
                else Hashtbl.replace p_tab k p;
                updater t
            end
            | [] -> true
        in updater plist

end

module BasicSocketBinding : SocketBinding = struct
    let connect addr port =
        let sock_desc = socket PF_INET SOCK_STREAM 0 in
        Lwt_io.open_connection ~fd:sock_desc (ADDR_INET (addr, port))
end
