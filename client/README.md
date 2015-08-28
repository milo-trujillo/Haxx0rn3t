# Client

This is the Haxxornet client. It stores information about the game like the list of hosts you've connected to, and handles the initial handshake with any servers you connect to.

This client is technically unnecessary, you could easily write your own or play the game over telnet / netcat directly. However, the client has no disadvantages and may make it easier to keep track of gameplay information.

The client code should be completely independent of the rest of Haxxornet. That is, players of the game should only need this folder and Ruby modules it depends on to play the game.
