# Certificate authentication

## About

A project I made to test out certificate based authentication in Ocaml. Both the server and the client have their identities signed by a trusted certificate authority (CA) so that when connecting via TLS they can be assured of the other's identity and have a secure communication channel

## Requirements

 - Ocaml: must have the ocaml compiler ```ocamlbuild``` installed
 - Openssl libraries

## How to run

### Building

To build the server, run ```ocamlbuild -use-ocamlfind -I server server/server.ml```

To build the client, run ```ocamlbuild -use-ocamlfind -I client client/client.ml```

Both of these will create native executables (```server.native``` and ```client.native```) in the project root

### Certificate generation (for UNIX)

**NOTE**: although this is built for UNIX systems, the openssl command line utilities are the same. The provided shell script will not, however, work.

Also, I haven't created a CA certificate in a while, so these instructions may not be 100% accurate. Generally, however, they should work (tested on Ubuntu)

------------------

Because authentication relies on TLS certificates, both the server and the client need to have a valid key/certificate pair, with the certificate signed by an accepted certificate authority.

If not going through an external CA (which is assumed), you will need to generate your own CA certificate and key and use it for testing.  To do this on Unix, first a key needs to be created with ```openssl genrsa -out <keyname>.key <bitlength>``` (I use 2048 for bit length, but increasing it is fine). With that key, create a certificate signing request (to be deleted afterwards) with ```openssl req -new -key <keypath> -out <whatever>.csr``` where ```keypath``` is whatever key you just generated. To self-sign a certificate to use as a CA, then run ```openssl x509 -req -days <numDays> -in <CSR> -signkey <key> -out <cert>.pem```.  Number of days is how long you want the signing to be valid, CSR is the CSR path, and key is the keypath. Now you can delete the CSR. Also note - when prompted for the server FQDN you should use ```localhost```

Now that you have your self-CA files, they need to be installed. One way to do this is by adding your CA certificate to ```/etc/ssl/certs```, saving the key to a safe place, and running ```update-ca-certificates``` (a command line utility for updating openssl's CA certificates). You can also modify ```/etc/ca-certificates.conf``` to point to where your CA certificate is saved but I never bothered doing that.

Now, any certificate signed with your CA certificate will be considered validated.

#### Creating the actual certificates

Now that you have a valid CA set up, you can create key/cert pairs for both the client and the server. The included utility ```create-ssl.sh``` when run creates a key in a desired directory, and allows you to sign them with an external key (the CA key you created). Do this for both client and server and you should be set. If you're on a non-unix system, just read through ```create-ssl.sh``` and run the same openssl commands manually

### Finally, actually running the program

For the server just run ```./server.native server.conf```, and for the client run ```./client.native client.conf <serverIP>```, where ```serverIP``` is the address of the server.  Note that the files used for configuration (```*.conf```) can be changed or moved, and probably will need to be to point to the proper key and certificate locations. However, in the provided configurations, none of the given tags should be removed - they are all necessary (if I remember correctly).

It should work. Tell me if it doesn't (but please be verbose).

