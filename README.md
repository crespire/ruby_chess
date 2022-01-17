# ruby_chess
Chess capstone project from the Ruby path of The Odin Project.

### Implementing timeline and notes

**Class pieces?**
I chose to start with the FEN stuff because I figured it would be an easy way to handle saves, exports and also testing.

Handling the FEN stuff was pretty straight forward, and actually gave me the idea about whether or not I actually needed individual Chess piece classes. All the information I required was encoded into the FEN piece notations. The type of piece and its color, plus special rules about Castling or *en passant* are all in the FEN.

This led to the idea that what I should perhaps focus on instead was a class that handles all the piece movement. The idea was that, because I have the information encoded into the tokens, I just pass a given cell with an occupant to this class via a command message, and get back a list of valid cells that the piece can move to. After getting a list, the user can make a choice, and then the board updates the piece’s movement in the data based on input.

**Movement implementation**
So far, I’ve used the `Movement` class to generate a list of valid moves for each given piece, and haven’t yet gotten to the “update the cell occupants” piece yet. That should be easy to implement once I have all the valid moves stuff working. So far, basic piece movement done, as horizontal, vertical and ordinal movement has been done. I’ve also completed Knight movement, and pawn forward movement including the double forward. I have to figure out pawn captures, and then start thinking about how to tie all the basic movements into a `valid_moves` function. 

**King movement and self-checking**
The one thing I have to figure out is how to keep track of what cells are under attack so that we can’t self check when the user has selected the King. I wonder if we can define a method ~~on board~~ that generates a current list of cells under attack, and will remove them from the King’s valid moves. This way, if the king is the selected piece, we can generate a threat map for all opposing pieces, and mark those moves as invalid after generating the King’s normal list of moves. Something like this:

```ruby
def valid_moves(cell) do
  if king
		king_moves(cell, offset)
  end
end

def king_moves(cell, offset) do
  enemy_color = cell.occupant.ord > 91 ? 'b' : 'w'
  threat = threat_map(enemy_color)
  result = # Calculate king moves
  (result - threat).uniq.sort
end
```

This way, we don’t really mess around with keeping track of all of this all the time, as it doesn’t really matter for any piece other than the King. We can place any other piece into harm’s way. We do keep a reference to the board object in `Movement` so we don’t need to make threat mapping a board function, as the threat map is only relevant to Movement anyway. 

Another way we can approach this might be utilizing the concept of Board control. In this case, any opposing piece that moves to a square could be captured by your piece. I think this idea wouldn’t be too bad to implement in terms of adding all valid moves to some `w_sq_ctrl` and `b_sq_ctrl` list. The problem, and expensive part, might be how we update this when pieces move or get captured. I think doing this every turn/move would be pretty computationally expensive. I am leaning more towards the threat map generation function inside `Movement` because it seems a little less complicated.

~~The next challenge after implementing the King’s movement checks will be to figure out how we can do *en passant.* The key is to remember that, more or less, there can only be one *en passant* active at one time. After any given pawn has moved two squares up, the **next played move** must capture it, otherwise, the chance for this capture expires.~~

~~I *think* en passant will be easier than castling.~~ I ended up deciding to tackle check and checkmate first.

**Check and Checkmate**
How should I implement my check and checkmates? I am feeling a bit confused as to what should be responsible. I think my confusion comes from the fact that I have implemented self-check prevention into my `Movement#valid_moves(cell)` function. For example, given this board `2Q3k1/6pp/5r1q/6N1/1P5P/6P1/5P2/6K1 b - - 0 1`, selecting the black Rook correctly indicates the available blocking move. Selecting the black King correctly indicates that there are no moves available.

When I think about it, a check is a condition when a king is under attack. This seems simple enough, but my trouble is where to locate this functionality. If I put it in board, it would have to know a heck of a lot about piece moves to check. It also doesn’t seem to make a whole lot of sense to put it inside the Movement helper. Though I do have a helper that might be helpful there in `can_attack_king`.

I think I’m leaning towards using a `Checkmate` manager type situation. After every move, we can call `Checkmate#any_check?` which can then return the King in check, or nil. Then using `Movement` we can check the total amount of moves available to that King’s pieces. If it is 0, we are in a Checkmate. Otherwise, there are some valid moves we can make, and it’ll be up to the user to make them.

So, we’d probably go something like this:

```ruby
def any_check?(last_move)
	# Given the cell that was just updated with the last move
	# Get enemy king
	atkrs = Movement.check(king)
	!atkrs.empty?
end
```

I think we might also keep track of the King locations on the board, rather than in Movement. So first, I should do this. Currently, we are keeping track of the king’s locations in instance variables inside Movement, but I think we can do better.

If board has an attribute that is constantly updated after any updates, then we can just reference that attribute on the board.

After work on `Checkmate` is completed, I should work to ensure the move counters are working properly.

- The half move clock is changed after every play. If a capture is made, or a pawn is moved, the counter resets to 0, otherwise the value is incremented by 1.
- The full move is clock is incremented after a white and black play, constituting a full “round” of play.

**Valid moves refactor**

While working on the Checkmate class, I ran into some issues where my `valid_moves` function was returning illegal moves in a checkmate situation, and since I was relying on that function to derive check and checkmate status, I had to go back and fix my `Movement#valid_moves` method.
Since I’m relying on my valid moves generator to check for check and checkmate, I need to refactor the main function so that it is correctly filtering out illegal moves.

Problems I’m experiencing:

1. Currently, valid moves is providing blocking moves but is not correctly identifying situations where a blocking move would be illegal. As an example `r1b1k2r/ppppqppp/2n5/8/1PP2B2/3n1N2/1P1NPPPP/R2QKB1R w KQkq - 1 9` is showing
    * Bf4 with valid moves to [e3 e5]
    * Nf3 with valid move to [e5]
    * Nd2 with valid move to [e4]

    These moves are all valid in the situation to block a potential threat from the Queen. Except that the King is under direct attack by a knight, so blocking the Queen is a secondary concern. I need to make sure my `valid_moves` is prioritizing handling direct attacks before blocking moves.

2. `valid_moves` is showing pins correctly, but it’s really hacky. I think the code could benefit from a refactor here as well.

**Potential approach**

Keep in mind, `valid_moves` returns a list of valid moves for a given cell. It is completely fine for the method it return an empty list. I think I was forgetting this before.

```ruby
get a list of those pieces attacking the friendly king
get a list of threats to the friendly king
If there are any pieces attacking the king	
	For each enemy piece in the direct attack list
		check if the current piece has any moves that can block or capture the enemy piece?
			return moves that intersect attack axis of enemy piece
		If not, then
			return no legal moves
If there are no direct attacks but there are threats
	for each enemy piece in threats
		check if the current piece is pinned (ie, blocking a direct attack)
		if pinned
			return moves along the attacking axis that are also in the moves list
		else
			return all moves
else there are no direct and threats
	return all moves
```

So, the next challenge is, how do we determine if a piece is pinned? The problem here is rooted in the way I implemented move calculation. I ended up putting in some hacky code because I think my abstractions were not the most helpful. While I was already refactoring `valid_moves`, I feel that changing my move generation approach would result in a significantly larger refactoring investment that would touch back to how I generate moves in the first place. I wasn't up for this at this moment, as I am eager to move on in the course. So, I managed to get everything working based on the tests I've written which included the previous failing test with the pawn blocking a queen in a checkmate situation, and I decided it was good enough.

**Valid moves refactor completed.**
A lot of what I spoke about in the notes, I ended up implementing. Our board is now aware of where any piece is if queried for that information, and will has a special method to query for the locations of the white or black king.

I ended up generating the threats to the king every time, and I do wonder how the game will perform once I have all the pieces together. Everything works as expected, however, so that's a good start.

**GameInformation**
Before I move on to working on *en passant* and *castling*, I think I have to extract from Board all the stuff related to game information. The board should strictly know about what cells are where, and updating the location of the pieces in question. It should not really care about what the active color is, castling availabilty, en passant availability, ply number, and the two clocks.

The board really has no business manging that, and should simply send messages to a GameInfo or Chess object that can keep track of these things, including generating and exporting FEN.