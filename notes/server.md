# Server Spec

## How the client interacts with the server

The client connects to the server and sends its auth token along with screen dimensions.

The server then connects to central and validates the auth token is legitimate, killing the TCP connection otherwise.

At this point we know the connection belongs to a real player, and we can look up what programs the user is allowed to run (given by Central).

The client now interacts with the server as if a normal telnet connection, allowing back and forth communication.

Normal communication stops if a special interrupt sequence is sent, such as:

    #!!:nkjdsfndkjs

In this instance "nkjdsfndkjs" is the token indicating some password cracking program. The server has already downloaded a list of allowed programs from central, so it verifies that the command is allowed and runs it, or kills the TCP command with an error message if the user tries an illegal command.

## How the server interacts with Central

The server connects to central on a special 'server-port', and can then send server commands. Server commands consist of the following:

* validate:<user token>

Returns 'invalid' if user does not exist, otherwise returns a list of every program the user is allowed to run, by token.

* sendAssets:<amount>:<username>

Transfers currency to the specified username. Returns 'invalid' if user does not exist or currency amount does not make sense. Otherwise returns "okay"

* sendMessage:<base64 encoded from>:<base64 encoded subject>:<base64 encoded message>:<username>

Sends specified message to the specified user as mail. Returns 'invalid' if any part of base64 decoding fails or the user does not exist. Otherwise returns "okay"

* sendData:dataHash:username

Sends a "data file" to the specified user. Returns 'invalid' if dataHash is not correct size or contains more than alphanumerics, or if the user does not exist. Otherwise returns "okay"
