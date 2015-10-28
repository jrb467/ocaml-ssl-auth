#Protocol Version 1.0

#DISTRIBUTED USER INFORMATION PROTOCOL SPEC

##Overview

Hoping to decentralize user information for use in web services and
applications, this protocol aims to provide a flexible framework for storing
user information on a server of their choice, and explicitly controlling
who has permission to access or modify their data

##Definitions and Abbreviations

CA = Certificate Authority (from SSL jargon)
Host = The server hosting the client's data (not the server being connected to)
Server = The server being connected to (containing other user's information)
Client = The individual connection to the server

##Data Abstraction

From a user perspective, the data they desire to modify/obtain can be treated
as key value pairs on the server. They either send a request to obtain or
modify data (more on that later), by sending a key to the server in question

##Security

Security is established on top of standard SSL protocol, except both the server
and client must present signed certificates.

For the server, certificates are sent normally - signed by a CA

For the client, certificates contain the client's host (Issuer) and username,
along with (obviously) their public key and signed by their host. This is the
first step in a two-certificate chain. The client also sends their host's
certificate (signed by an actual CA), so that both can be verified at once
as part of a chain.

From their, the SSL handshake can proceed, and once a channel is established
communication can begin, as both parties are authenticated.

##Request Format(s)

-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Standard CRUD operations:
  - Create (Makes it so only client + data owner have permissions initially)
  - Read (With querying if permissible)
  - Update (Write or append)
  - Delete


++++++++++++++++++++++++++=

Example json (represents the entirety of a user)

{
    "first_name": "Jacob",
    "last_name": "Bigenwald",
    "age": 19,
    "city": "Rochester",
    "state": "NY",
    //Created for a certain site's data
    //The client is told to create a new category, which initially only they
    //have control over
    "farcebook": {
        //list permission are the same as record permissions
        //Can allow access to certain attributes (as objects inside follow
        //the same signature), so in this instance certain people could see
        //the "username" of all the friends but not the "host"
        "friends": [{"username": "fr1", "host": "XXX.XXX.XXX.XXX"}, ...],
        "messages": [{"msg_id": 1502348, ...}]
        "color": "red"
    }
}

#What NOT to use this for

Multi-user operations.

Sometimes it's nice having a third party act as a hub.

Consider the server is just another friend of yours, there to aid in communication.
Hypothetically, image you're trying to share information and stuff with your friends
without too much trouble. No shouting, no crap. Just casual conversation between
1-2 people at a time.

Want to find out everyone who went to the same restaurant you did? Good luck talking
to everyone individually. But if your server friend happens to know everything about
where everyone's been eating, that simplifies things significantly. Just need to talk
to a single guy.

Simply, multi-user queries are best not used under this protocol. A "feed" just
isn't practical. This is meant for connecting to a single user at a time.

An "active" protocol - you need to actively seek out another user's information.

A conjunction approach can be used - one where actual sites have permission to certain
information, and create a doppleganger on their servers for querying and processing.
Still useful for being a universal profile

#Involved Parties

- Client (requesting data)
- Host server (serving request for data)
- Client's host serving (contains client information, like public key)
- Proxy Server (redirects request to user's computer, if online)

NOTE : USE '5' for public exponent

##Client

###Request types

- Read (just values associated with keys)
- Write (both values and new data to be written)
- Change public key
- Delete data
- Manage permissions
- Manage own data
- Migrate request (?)

##Host Server

###Request types

- Get public key
- Initiate migration request

##Client's Host Server

###Request types

None, in this scenario



+++++++++++++++++++++++++++++++

###GET Response

server_response := **response_type** **response_body**

response_type := D | A | E

response_body := **data_response** | **auth_response** | **encrypted_response**

data_response := (*key* *length* *data*)\*

auth_response := *encrypted_key*

encrypted_response := (*key* *encryption_length* *encrypted_length_and_data*)\*

*key* : A string (ascii/normal characters, no spaces)
*length* : Length of the data being sent (as raw number, not ascii - e.g. '[' instead of '91'). Just 8 bytes
*data* : The raw data being sent (I assume any characters/symbols are valid)
*encrypted_key* : The encrypted chunk of a randomly generated key, using the connecting user's public key
*encryption_length* : Length of the data (in its encrypted format)
*encrypted_length_and_data* : *length* *data*, as above, encrypted using the connecting user's public key

###WRITE Request

Both appending and other stuff

###Retrieve public key request

###

#WRITER'S NOTES: SECURITY AND SETUP

SSL setup:

User generates certificate with public key on it and username + hostname, which is signed by the client's host server

In setting up connection, during SSL handshake server sends it's cert (signed by actual CA) while the client sends their cert (signed by its host server). As a result the server will need to contact the client's host server (also through ssl) and get it's public key

From there the handshake proceeds and at the end a secure, authenticated connection should be established
Server keeps state of username/hostname for permission purposes
Then client can make any requests it wants (read/write/etc), until finished
