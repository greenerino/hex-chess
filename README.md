<h1 align="center">
  <p>Hex Chess</p>
  <img src="https://github.com/greenerino/hex-chess/assets/30224113/6dd6e2ef-0718-428f-8dc2-1292157ea7a0" height="400px" alt="A screenshot of a hex chess game in progress.">
</h1>
<p align="center">A quick implementation of Hex Chess in Godot</p>

Hex Chess is a hexagonal adaptation of standard Chess. I was originally inspired by CGP Grey's video <a href="https://www.youtube.com/watch?v=bgR3yESAEVE">Can Chess, with Hexagons?</a>, but the variant has existed since as early as 1936, <a href="https://en.wikipedia.org/wiki/Hexagonal_chess">according to Wikipedia</a>

Hexagons almost introduce a whole new dimension to the board, since they have 6 adjacent cells and 6 "diagonal" cells, compared to 4 adjacent and 4 diagonal with standard square cells. However, pieces move very similarly to standard chess, just with translations into the hexagon world. Take a look at the above Wikipedia page for descriptions on how the pieces move.

## Features

<img src="https://github.com/greenerino/hex-chess/assets/30224113/9bfc55b0-98d7-4dc2-81ab-d69d2ee0cd27" height="400px" align="right" alt="Hex chess piece movement demo">

This implementation is a very rough version with the bare minimum requirements to get a game going. Currently, you can:
- Play a game over the network
  - Play with two windows on one computer by setting the IP to `127.0.0.1`
  - Play over LAN with local IPs
  - Play over the internet after port forwarding port `29969`.
- Choose any time control from 1+0 to 60+20
- Complete a game via checkmate or timeout
- Click on a piece on your turn to view legal moves
  - This is very useful if you are new to Hex Chess!  
  - Moves that put the player into check will be filtered out
  - Your king will blink red if you are currently in check

## Future

Things yet to be implemented:
- En passant
- Promotion
- Stalemate detection
- Sound effects
- QoL improvements such as:
  - Back buttons, returning to main menu to play again
  - Better colors and contrast (it is really hard to read the board with the 3 colors I've chosen)
  - Network improvements, such as detecting when a player disconnects
