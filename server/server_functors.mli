open Sig

module MakeKeyManager (S : SocketBinding) : RemoteKeyManager

module MakeServer (K : RemoteKeyManager) (P : PermissionManager)
    : Server with type permissions = P.permissions
                and type pub_key = K.pub_key
