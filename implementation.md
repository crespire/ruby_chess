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

I already tried to implement it directly into `Movement` and `Chess` but I got rid of that work because I felt like it was getting too complicated and I was having to really entangle a lot of objects together in order to make it happen.

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

Given how I've implemented `Movement` at the moment, it is badly failing some of these more complicated situations, and I am heavily considering re-writing the whole class.

After working on trying to address a number of edge cases introduced by using the Perft boards, I realize that I think it would be much more productive to re-write the `Movement` class.

I have many functions that break single responsibility and are extremely brittle. The result is that trying to fix an edge case in one function introduces many problems in other areas of the code. This seems to me to signal that a refactor is in order.

### Movement Re-write
I have decided to commit to a rewrite of my Movement generation class, as I think I need to take more care in how I am setting it up so that it is easier for me to work with the results.

I think my approach will focus on initially generating pseudo-legal moves and then filter them later.

Pseudo-legal moves are all the locations a piece can go to either by sliding/moving or capturing.

* Knights have 8 options around them with no obstructions, either empty or capture.
* Kings, have 8 options around them unless obstructed, either empty or capture.
* Rooks and Bishops have 2 axis until there is an obstruction. If friendly, can't go there. If enemy, can capture.
* Queen combines the rook and bishop.
* Pawns are a little more complicated.
  * Pawns have 4 options. Two forward and 1 on each forward diagonal.
  * We can call the forward moves moves and the diagonals captures.
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
  
  offsets.each do |offset|
    moves << Move.new(board, origin, offset, 7) # board, origin, offset values, steps
  end

  moves
end
```

The interesting case is the Pawn. Because we're generating pseudo-legal moves, the pawn should always generate 3 moves with 4 squares (2 forward, and 1 each forward diagonal). As far as the pawn is concerned, these are all moves it can make. `#valid_moves` should filter out captures if the cells are empty, so it wouldn't be a valid move.

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
* Move.valid_moves - Return a list of Cells that piece can actually traverse to in a pseudo-legal way. We don't care, at this point, about legal moves, just moves we can actually make.

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

The idea behind Move is to report all pseudo-legal moves. We will rely on Movement to do the final filtering to legal moves. The same would be true for a King's moves. We would report all pseudo-legal moves, then filter out moves that would result in a self-check.

### Piece structure update
So, we've updated the structure of Piece and the subclasses to better get all the information we need.

Each piece now has three move generation functions: all_paths, valid_paths, and moves.

### Movement rewrite
Thinking about how to get from pseudo-legal to legal moves, it actually isn't that complicated.

For the following pieces, pseudo-legal moves are also legal moves when there is no check: rook, knight, bishop and queen.

legal_moves

1. Grab the active King and build a threat board.
    * Take all enemies, and mark their pseudo-legal moves.

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
    * Pseudo-legal moves for rook, knight, bishop and queen.
4. In the case of a Pawn, we remove forward diagonals if there is no capture or en passant.
5. In the case of the King, we remove any cells that are on an enemy path.

I added a `captures` method to Piece in order to progress on `Movement`, but I should add unit tests to each piece to confirm it is working as expected. I don't see why it wouldn't be, but better to check than not.

### In-check situations
I think I have in-check situations completed, as all of my in-check tests are passing. The big one is perft board position 4, which shows the correct 6 legal moves.

### Non-check situations
Now I have to think about movement in a non-check situation. What do I have to consider and how can I be efficient about it? A king can't move into a check, this is already solved.

**Brute force approach**

Check every pseudo-legal move and run it through `move_legal?`. If a move is not legal, we can query as to why with a `discovered_check` method that returns the attacker. Once we have the attacker, we can find the attacker move that includes our king, and intersection that with pseudo-legal moves from the piece we're moving.

This approach seems solid, but not all together too smart. We are potentially filtering out a ton of moves this way (ie, with a pinned queen).

**Utilzing valid_xray**

Another approach might be to utilize the `valid_xray` method we built into `Move`.

We generate the pseudo-legal moves for our piece in question, then query every enemy, and if it slides, grab pieces with a valid_xray that includes our king.

If we have any sliding xrays, valid moves would be the intersections of pseudo-legal and the valid travel squares on the xray path that include king.

So we do something like:
```
piece.moves
no check
  @board.data.each |rank|
    rank.each do |check_cell|
      next if check_cell.empty? || cell.friendly?(check_cell)
      next unless check_cell.piece.slides?

      enemy_slides = check_cell.piece.valid_paths(@board, check_cell)
      candidates = enemy_slides.select { |move| move.valid_xray.include?(active_king) && move.valid.include?(cell) }

      once we have the selection, we want to get the valid moves, not xrays and union with psuedo for legal moves.
    end
  end
```

I ended up going with the valid_xray approach, as it seemed to make a little bit more sense to me, as far as pins were concerned. I ended up having to add checks to only include moves with exactly 2 enemies, plus king and cell.

### Finishing movement
We're so close to finishing movement, I have the bulk of tests passing. Currently, position 2 is failing due to an issue with pawns and enemies right in front of them. I have a test in pawn_spec to capture this bug so we can make sure we don't regress.

One skipped test has castle moves available, which I haven't yet implemented, so that will be the next step.

Once we are done with castling, the plan is to work on UI and all the user interaction portions of the game. Then all that's left is to work on serialization and loading the game from a FEN/file.

### Legal moves, sans castling completed
I ended up moving the pawn forward move checks out of `Pawn` into `Movement` because the Moves should reflect all moves. I also didn't want to fuck around with Move specifically for Pawn movement, as valid was (incorrectly) reporting a forward move as an eligible space. While this is generally true of pieces, it isn't true for the pawn. Long story short, we filter out the forward moves in Movement#pawn_helper so all the pawn movement modification is in one place. I also moved the pawn_spec test I had added into the Movement_spec tests.

I will note that my approach to move generation in general owes a lot to some folks from The Odin Project discord, as well as the time I spent with the [lichess.org Chess engine](https://lichess.org/editor). My basic approach on the abstractions side was heavily inspired by my conversations on the TOP discord, and the basic pseudo-legal to legal move filtering was inspired by the lichess board editor implementation as I was able to see that it generated all basic moves, then removed them in a second pass if they were not valid.

### Castling
Now, we move to castling. I do think that some of castling will end up being implemented inside `Movement` but I think it will be a simple call to a `CastleManager` class, which then spits out the additional moves that we can make.

I wonder how I will implement the actual move once validating that it is available, but we can cross that bridge when we get there. The first step is to think about how we can validate that castling is available.

Here are the elements involved in validating whether or not a castling move is available:
* Neither the king, nor the target rook has previously moved. If the King moves, castle rights on both sides are given up. If a rook moves, the K/Q side right is given up respectively.
* The path between the king and the rook must not be obstructed by a friendly or enemy (ie, all cells should be empty)
* The king is not currently in check. Castling is not a valid move to get out of a check.
* The king's path does not cross a square under attack.

A king _can_ castle again if it was previously under check, provided it and the target rook did not move in order to resolve that check.

We should add a `moved` attribute to `King` and `Rook` that initalizes to false. Then we can set up an accessor, and change it inside game in the `move_piece` method. We can also have a call to the CastleManager to update castling rights by passing in the Rook's cell. If the file is less than e, it's queen side, greater than e, king side.

Something like:
```ruby
# Inside Game#move_piece
if piece.is_a?(King) || piece.is_a?(Rook)
  piece.moved = true
  CastleManager.update_rights(piece, cell)
end

# Inside CastleManager
def update_rights(game, piece, cell)
  return unless piece.is_a?(King) || piece.is_a?(Rook)

  rights = game.castle.dup
  delete_rights = 'KQ'
  delete_rights.downcase if piece.black?
  if piece.is_a?(Rook)
    king_side = piece.white? ? cell.name > 'e' : cell.name < 'e'
    king_side ? rights.delete!(delete_rights[0]) : rights.delete!(delete_rights[1])
  else
    rights.delete!(delete_rights)
  end
  rights = '-' if rights.empty?
  game.castle = rights
end
```

I think this is a good start and we'll see how it goes as we implement this.

In my excitement to be finished most of legal movement, I totally forgot I had to refactor Checkmate. It's done and passing all tests!

### Castling pt2
Implemented `update_rights` and its spec tests, so it is working as expected.

The next step is to figure out how to spit out available castle moves. Castle should only be initiated by the King, so we can start there.

Because castling relies on the fact that all involved pieces haven't moved yet, we should be able to hard code the destination values in.

We assume, inside this `castle_moves` method, that the rights from the game manager are correct. We could do a check as well on `piece.moved?` just to be safe.

I think the approach here should be to copy the current rights, and do a check to see if it's actually a legal move (similar to how we filter moves). So if a path to a rook is blocked or the path is under attack, that right is "removed" temporarily. After these legality checks, if a right still exists in our copy, then we can return those related moves as legal.

```ruby
def castle_moves(game, cell)
  # Return castle move cells if available so we can add them to the list of moves.

  # Get a copy of the castle rights from game
  # Filter the rights for the active side.
  # If no rights, return []
  # Is the king under attack? Return [] if so.
  # Check if the path to the Rooks is clear, if not, remove right from the respective side.
  # Check if home rank is under attack, get those cells.
  # If there are any cells, remove the right from the respective side.
  # If there is still a right left, then we populate the move and return it.
  # For each right left, add the moves to result []. Then we flatten and return.
  {'q' => ['g8', 'f8'], 'k' => ['b8'], 'Q' => ['b1', 'c1'], 'K' => ['g1'] }
end
```

Something like that would be a good approach. The hard coded values are in additional to valid king moves we would get back from `Movement#legal_moves` so we can just tack them on to the King helper in Movement.

Finally, once we have these moves done, we can have the game call Castle manager to actually execute the Rook move as well. So we can rely on `Chess#move_piece` to move the King, but once we identify a castling move, we have to move the Rook as well.

How do we identify a castle move inside `Chess#move_piece?` that isn't too expensive. Maybe we can generate a range based on the file letters? Problem is range can't be generated backwards, so we'd have to check which side, then make the range based on that. Something like this:
```ruby
cell1_file = cell1.name.chars[0]
cell2_file = cell2.name.chars[0]

range = cell1_file < cell2_file ? (cell1_file...cell2_file) : (cell2_file...cell1_file)

castling_move = range.to_a.length > 1
```

### Castling complete?
I have the spec passing tests, but now I have to integrate it into Movement.

I am having troubles with that, as what I'd like to do is have everything initialized inside Chess, and have everything else utliize those managers via Chess.

I think it would make integrating my pieces easier, but I am having trouble with that right now.

### Movement integration fixes
I think I figured out the problem with my integration. Everywhere I had board as a separate instance variable, I removed it and accessed the board via Chess.board, which seemed to solve my issue of having different instances of the board being referenced.

The challenge now is to add castling moves to Movement legal moves, and validate it there.

### Movement integration completed
Movement spec is now passing all tests.

### Core logic completed!
All current RSpec tests are passing! This means we have a reasonably solid base to build the rest of the program on. First, let's add draw functionality to the Checkmate class for half-clock to 50 and only two kings left.

### Home stretch
How we have to flesh out the game saving and UI, so that we can pull it all together and get a running program. I think it makes the most sense to work on the UI, and then work on actually getting a game going in the command line.

Once that is done, we can add serialization and saving, as it should be relatively easy to drop that in once the game is working as we want.

### UI mostly complete
I have to test pawn promotion to see if it works (remember to put unit tests for that inside the chess_spec), and then finish the UI for that.

After that, we should work on serialization and saving games.

### Final Integration Testing
The Chess game is more or less complete, with file loading and saving working. I've created a number of integration tests that I think would be nice to confirm that all the rules are working once we have put all the pieces together. All the units are passing, so this should be pretty simple.

### Post Project Review
With the benefit of 6 months of hindsight (while polishing things up for a job search), I have come to realize that my initial implementation problems with my movement manager and moves in general was actually a code smell: primitive obsession. I was so jazzed about making FEN serialization and deserialization work, that I thought I could just use strings to represent the pieces. This then led to representing moves as simple arrays of strings, which compounded my problems as I was trying to solve the harder problems in this domain. I think I was so hooked on the "progress" I was making to solving the problem, I didn't think about the bigger picture. The solution (unsurprisingly) was to replace these primitive data types with classes that represented the abstractions.