# Client

This is the Haxxornet client. At present it's mostly just a wrapper around raw sockets, although it tells the remote server the size of your terminal to allow properly centering and spacing items.

The client code should be completely independent of the rest of Haxxornet. That is, players of the game should only need this folder and Ruby modules it depends on to play the game.
