# ruby_chess
Chess capstone project from the Ruby path of The Odin Project.

# Implementation timeline and notes

### Class pieces?
I chose to start with the FEN stuff because I figured it would be an easy way to handle saves, exports and also testing.

Handling the FEN stuff was pretty straight forward, and actually gave me the idea about whether or not I actually needed individual Chess piece classes. All the information I required was encoded into the FEN piece notations. The type of piece and its color, plus special rules about Castling or *en passant* are all in the FEN.

This led to the idea that what I should perhaps focus on instead was a class that handles all the piece movement. The idea was that, because I have the information encoded into the tokens, I just pass a given cell with an piece to this class via a command message, and get back a list of valid cells that the piece can move to. After getting a list, the user can make a choice, and then the board updates the piece’s movement in the data based on input.

### Movement implementation
So far, I’ve used the `Movement` class to generate a list of valid moves for each given piece, and haven’t yet gotten to the “update the cell pieces” piece yet. That should be easy to implement once I have all the valid moves stuff working. So far, basic piece movement done, as horizontal, vertical and ordinal movement has been done. I’ve also completed Knight movement, and pawn forward movement including the double forward. I have to figure out pawn captures, and then start thinking about how to tie all the basic movements into a `valid_moves` function. 

### King movement and self-checking
The one thing I have to figure out is how to keep track of what cells are under attack so that we can’t self check when the user has selected the King. I wonder if we can define a method ~~on board~~ that generates a current list of cells under attack, and will remove them from the King’s valid moves. This way, if the king is the selected piece, we can generate a threat map for all opposing pieces, and mark those moves as invalid after generating the King’s normal list of moves. Something like this:

```ruby
def valid_moves(cell) do
  if king
    king_moves(cell, offset)
  end
end

def king_moves(cell, offset) do
  enemy_color = cell.piece.ord > 91 ? 'b' : 'w'
  threat = threat_map(enemy_color)
  result = # Calculate king moves
  (result - threat).uniq.sort
end
```

This way, we don’t really mess around with keeping track of all of this all the time, as it doesn’t really matter for any piece other than the King. We can place any other piece into harm’s way. We do keep a reference to the board object in `Movement` so we don’t need to make threat mapping a board function, as the threat map is only relevant to Movement anyway. 

Another way we can approach this might be utilizing the concept of Board control. In this case, any opposing piece that moves to a square could be captured by your piece. I think this idea wouldn’t be too bad to implement in terms of adding all valid moves to some `w_sq_ctrl` and `b_sq_ctrl` list. The problem, and expensive part, might be how we update this when pieces move or get captured. I think doing this every turn/move would be pretty computationally expensive. I am leaning more towards the threat map generation function inside `Movement` because it seems a little less complicated.

~~The next challenge after implementing the King’s movement checks will be to figure out how we can do *en passant.* The key is to remember that, more or less, there can only be one *en passant* active at one time. After any given pawn has moved two squares up, the **next played move** must capture it, otherwise, the chance for this capture expires.~~

~~I *think* en passant will be easier than castling.~~ I ended up deciding to tackle check and checkmate first.

### Check and Checkmate
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

### Valid moves refactor

While working on the Checkmate class, I ran into some issues where my `valid_moves` function was returning illegal moves in a checkmate situation, and since I was relying on that function to derive check and checkmate status, I had to go back and fix my `Movement#valid_moves` method.
Since I’m relying on my valid moves generator to check for check and checkmate, I need to refactor the main function so that it is correctly filtering out illegal moves.

Problems I’m experiencing:

1. Currently, valid moves is providing blocking moves but is not correctly identifying situations where a blocking move would be illegal. As an example `r1b1k2r/ppppqppp/2n5/8/1PP2B2/3n1N2/1P1NPPPP/R2QKB1R w KQkq - 1 9` is showing
    * Bf4 with valid moves to [e3 e5]
    * Nf3 with valid move to [e5]
    * Nd2 with valid move to [e4]

    These moves are all valid in the situation to block a potential threat from the Queen. Except that the King is under direct attack by a knight, so blocking the Queen is a secondary concern. I need to make sure my `valid_moves` is prioritizing handling direct attacks before blocking moves.

2. `valid_moves` is showing pins correctly, but it’s really hacky. I think the code could benefit from a refactor here as well.

#### Potential approach

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

### Valid moves refactor completed
A lot of what I spoke about in the notes, I ended up implementing. Our board is now aware of where any piece is if queried for that information, and will has a special method to query for the locations of the white or black king.

I ended up generating the threats to the king every time, and I do wonder how the game will perform once I have all the pieces together. Everything works as expected, however, so that's a good start.

### GameInformation
Before I move on to working on *en passant* and *castling*, I think I have to extract from Board all the stuff related to game information. The board should strictly know about what cells are where, and updating the location of the pieces in question. It should not really care about what the active color is, castling availabilty, en passant availability, ply number, and the two clocks.

The board really has no business managing that, and should simply send messages to a GameInfo or Chess object that can keep track of these things, including generating and exporting FEN.

### Chess
I have started to implement Chess, which is the game manager class that references board, and holds meta information about the game.

Currently, Board and its spec has been re-written to rely on this Chess object, as Chess now handles the board's state and making boards from FEN, rather than the board. Chess creates new Board objects when passed in a FEN.

This change has also impacted `Movement` as I use an empty board to determine some moves, which in turn means `Checkmate` will need some work as well. *C'est la vie*, as they say. This change is for the better, so once I am done testing all the game info incrementing/tracking in `Chess`, I'll fix these two in order.

### Chess object completed
Having finished the Chess class and all the refactoring to get the other classes ready, I've turned my thoughts to how I might implement *en passant*.

I already tried to implement it directly into `Movement` and `Chess` but I got rid of that work because I felt like it was getting too complicated and I was having to really entagle a lot of objects together in order to make it happen.

Looking over my code, I actually think I can fit *en passant* movement inside the `Chess` metadata class, as I think I have all the information I'd need to implement it there without a helper class. Just to think it through a little:
```ruby
def move_piece(origin, destination)
  # already existing code

  # this can probably all go into a few helper methods.
  # Chess should have all the information we need to make the determination about an en passant
  if piece is a pawn
    if destination is last rank
      can we promote?
    else
      is start rank the home rank?
      is destination rank the double move rank?
      If both are true, check the destination rank neighbours
      any valid neighbors?
      if valid neighbors and we did a double forward then set passant
    end
  end

  # we can probably do castling here too via helper methods.
  # it makes it super easy to unit test these two special moves and doesn't go all over the place

  # rest of code  
end
```

I think we'll start with this approach and see how it goes. I've added an offset retrieval feature to the `Board#cell` (and consequently the `Chess#cell`) function that should make retrieving neighbouring cells a little easier.

### *en passant* completed
I have implemented *en passant* entirely inside the `Chess` class, which I think makes it easy to manage. My previous attempt had code split across `Chess` and `Movement` which was not only a disaster conceptually, but also mucked up my tests a lot. That is what prompted me to think about doing the *en passant* in this way.

I think there's room for improvement, but it would involve a refactor of the entire `Movement` class using my new offset query approach and some new abstractions. While I think it would be worthwhile to pursue in the future, my goal is to finish the program and move on to Rails, so I think I'm going to leave it for now.

Up next, I was going initally tackle castling, but I think I'll work on fleshing out the UI a little more in order to get pawn promotion up and running. After that, likely castling, and then UI/save and load. So we are getting quite close.

### Issues with legal move generation
I came across some performance test boards that allow me to verify how many legal moves my program *should* come up with for any given FEN for the next move.

Given how I've implemented `Movement` at the moment, it is badly failing some of these more complicated situations, and I am heavily considering re-wrtiting the whole class.

After working on trying to address a number of edge cases introduced by using the Perft boards, I realize that I think it would be much more productive to re-write the `Movement` class.

I have many functions that break single responsiblity and are extremely brittle. The result is that trying to fix an edge case in one function introduces many problems in other areas of the code. This seems to me to signal that a refactor is in order.

### Movement Re-write
I have decided to commit to a rewrite of my Movement generation class, as I think I need to take more care in how I am setting it up so that it is easier for me to work with the results.

I think my approach will focus on initially generating psuedo-legal moves and then filter them later.

Psuedo-legal moves are all the locations a piece can go to either by sliding/moving or capturing.

* Knights have 8 options around them with no obstructions, either empty or capture.
* Kings, have 8 options around them unless obstructed, either empty or capture.
* Rooks and Bishops have 2 axis until there is an obstruction. If friendly, can't go there. If enemy, can capture.
* Queen combines the rook and bishop.
* Pawns are a little more complicated.
  * Pawns have 4 options. Two forward and 1 on each forward diagonal.
  * We can call the foward moves moves and the diagonals captures.
  * Pawn can move forward unless obstructed.
  * Pawn can capture if target square has a hostile, otherwise not eligible.
  * Pawn can only move two forward if not obstructed and on starting rank.

Given a piece, we generate a Move object that has all the base movements. This allows us to ask a bunch of questions about the Moves.

Firstly, what are they? What moves have we come up with? We can use an array to hold move objects, based on the piece.

For a knight at d4 with all moves: The knight would hold `Move` 8 move objects: `[<Cell e6>]` etc.
For a rook at d4 with all moves: `Move` would  = [[d5, d6, d7, d8], [e4, f4, g4, h4], [d3, d2, d1], [c4 b4 a4]]`
Move should start from the cell and go outward. I think the array should hold a reference to the cell so we can query the cell for information.

Each move should contain a list of all the cells we can move to, regardless of if they're occupied or empty. The only limit is that the destination must be on the board.

Secondly, once we have the raw information, we can ask questions about the move itself by asking the cells questions.

Move.obstructed? - Are there any friendlies on the move?
Move.capture? - Are there any captures on the move?
Move.valid_moves - Return a list of Cells that piece can actually traverse to in a psuedo-legal way. We don't care, at this point, about legal moves, just moves we can actually make.

// Move.restricted? - Does this move have a capture and a friendly?
I don't think asking if a single move is restricted is helpful.

I think I'll need an object to both hold the Move objects and to generate them. So maybe I will need to implement a "Piece" object, and perhaps have inheritance for all the piece types.

If I take this approach I can work with pieces, as well as their moves, via queries. Would be helpful for situations like pins.

### Piece.moves
So, let's think about how we make the moves. Each piece should have the corresponding number of moves. Let's look at the knight.

A Knight has 8 possible moves.
```ruby
# Inside Knight
def valid_paths(board, origin)
  moves = []
  offsets = [[2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2], [1, 2]] #[file, rank] offset pairs

  offsets.each do |offset|
    moves << Move.new(board, origin, offset) # board, origin, offset values, steps (defaults to 1)
  end

  moves
end
```

This allows us to generate 8 moves for the Knight. Let's look at the Rook, which has 4 possible moves.

```ruby
# Inside Rook
def valid_paths(board, origin)
  moves = []
  offsets = [[1, 0], [0, -1], [-1, 0], [0, 1]]
  
  offsets.each do |offest|
    moves << Move.new(board, origin, offset, 7) # board, origin, offset values, steps
  end

  moves
end
```

The interesting case is the Pawn. Because we're generating psuedo-legal moves, the pawn should always generate 3 moves with 4 squares (2 forward, and 1 each forward diagonal). As far as the pawn is concerned, these are all moves it can make. `#valid_moves` should filter out captures if the cells are empty, so it wouldn't be a valid move.

```ruby
# Inside Pawn
def valid_paths(board, origin)
  moves = []
  rank_dir = white? ? 1 : -1
  offsets = [[0, rank_dir], [1, rank_dir], [-1, rank_dir]]

  offsets.each_with_index do |offset, i|
    moves << Move.new(board, origin, offset, (i == 0 ? 2 : 1))  # board, origin, offset values, steps
  end
end
```

So, if these are the requirements for `Move`, then what does Move look like internally? Recall, we want to be able to ask each move some questions: 

* Move.obstructed? - Are there any friendlies on the move?
* Move.capture? - Are there any captures on the move?
* Move.valid_moves - Return a list of Cells that piece can actually traverse to in a psuedo-legal way. We don't care, at this point, about legal moves, just moves we can actually make.

So, the `Move` should contain all reachable cells on the board, then we can use these predicates and `possible_moves` to filter out squares that are blocked, not eligible etc.

So we are passed in the board, origin, an offset and if we should repeat.

```ruby
class Move
  def initialize(board, origin, offset, steps = 1)
    @board = board
    @origin = origin
    @offset = offset
    @repeats = repeats
    @all_cells = []

    build_move
  end

  def possible_moves
    build_moves if @all_cells.empty?

    # Do stuff to figure out what moves are possible. 
    # ie, can a pawn capture forward diagonal? If so, then it's a possible move. If not, then it's not possible.
  end

  private

  def build_move
    @repeat.times do
      @cells << @board.cell(origin, @offset[0], @offset[1])
    end
  end
end
```

I think this is a good start to Move. I thought about adding some enumerable methods to Move. Might be helpful to work with them similar to arrays.

Move builds all move vectors for a given piece offset, however, we classify Move objects with an empty @cells array as dead. We also classify a Move object with 0 valid destinations as dead.

As an example, given this board: https://i.vgy.me/6qp2Ol.png

The d3 Bishop has one path obstructed, but the Move object in the south east direction actually is not empty, and includes cell e2 and f1, but we mark it as dead as there is no valid move to make.

These move objects have a `valid` method, but this method only returns valid destinations with respect to their basic movement rules. For example, a pawn will return a forward diagonal as a valid if it is not an obstructed square, even if there is no valid capture there.

The idea behind Move is to report all psuedo-legal moves. We will rely on Movement to do the final filtering to legal moves. The same would be true for a King's moves. We would report all psuedo-legal moves, then filter out moves that would result in a self-check.

### Piece structure update
So, we've updated the structure of Piece and the subclasses to better get all the information we need.

Each piece now has three move generation functions: all_paths, valid_paths, and moves.

### Movement rewrite
Thinking about how to get from psudeo-legal to legal moves, it actually isn't that complicated.

For the following pieces, psuedo-legal moves are also legal moves when there is no check: rook, knight, bishop and queen.

legal_moves

1. Grab the active King and build a threat board.
    * Take all enemies, and mark their psuedo-legal moves.

If threat board includes the active King's cell:
1. How many attackers?
2. GUARD: If more than 1 attacker, only the king has valid moves. If this piece isn't a king, then return empty list.
3. Generate moves for the current piece.
4. Are there any valid moves?
5. Can this piece capture the attacking piece?
6. Can this piece block the check?

If there are no direct attackers
1. Get this piece's moves
2. GUARD: If king, remove all attacks from the threat_board and return
3. Are there any pins to the king by the enemy sliders?
2. If there are pins, find the pieces that are pinned.
  * Pinned pieces are preventing a check, so their legal moves are restricted.
3. If there are no pins, then
  * Psuedo-legal moves for rook, knight, bishop and queen.

4. In the case of a Pawn, we remove forward diagonals if there is no capture or en passant.
5. In the case of the King, we remove any cells that are on an enemy path.