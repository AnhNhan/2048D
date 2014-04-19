module logic.grid;

import logic.common;
import utils.grid;
import utils.random;

import std.random : Random;
import std.traits : isIntegral;
version(unittest) {
    import std.stdio : write, writeln;
}

enum MoveDirection {
    Up
  , Down
  , Left
  , Right
};

class Grid(T, uint size_x = 4, uint size_y = 4)
    if (isIntegral!T)
{
public:

    this()
    {
        import std.random : unpredictableSeed;
        this(unpredictableSeed);
    }

    this(uint seed)
    {
        _seed = seed;
        _rng = Random(seed);
        placeNextRandomTile();
    }

    @property auto tiles() const { return _tiles; }

    // Dunno, make this private?
    bool placeNextRandomTile()
    {
        immutable(Position)[] empty_tiles;
        foreach (y, row; _tiles)
        {
            foreach (x, cell; row)
            {
                if (cell == cell.init)
                {
                    empty_tiles ~= Position(x, y);
                }
            }
        }

        if (!empty_tiles.length)
        {
            return false;
        }

        auto rand_pos = _rng.pick_random(empty_tiles);
        _tiles[rand_pos.y][rand_pos.x] = nextRandomTileValue();
        return true;
    }

    auto moveLeft()
    {
        return move!(MoveDirection.Left);
    }

    auto moveRight()
    {
        return move!(MoveDirection.Right);
    }

    auto moveUp()
    {
        return move!(MoveDirection.Up);
    }

    auto moveDown()
    {
        return move!(MoveDirection.Down);
    }

private:

    auto nextRandomTileValue()
    {
        // One in nine is a four
        return _rng.uniform(0, 8) == 0 ? 4 : 2;
    }

    auto move(MoveDirection direction)()
    {
        auto tiles = _tiles;
        static if (direction == MoveDirection.Up)
        {
            tiles = tiles.rotate90CW(2);
        }
        else static if (direction == MoveDirection.Left)
        {
            tiles = tiles.rotate90CW(3);
        }
        else static if (direction == MoveDirection.Right)
        {
            tiles = tiles.rotate90CW;
        }

        // Everything is rotated so we only have to code the move for a single
        // direction, which makes it a lot easier.

        pure @safe nothrow
        GridType move_row_cell(in GridType t, int rr, int cc)
        {
            GridType r = t;
            if (r[rr + 1][cc] == T.init)
            {
                r[rr + 1][cc] += r[rr][cc];
                r[rr][cc] = T.init;
            }
            return r;
        }

        pure @safe nothrow
        GridType merge_row_cell(in GridType t, int rr, int cc)
        {
            GridType r = t;
            if (r[rr + 1][cc] == r[rr][cc])
            {
                r[rr + 1][cc] += r[rr][cc];
                r[rr][cc] = T.init;
            }
            return r;
        }

        pure @safe nothrow
        void loop_grid_iterate(ref GridType tiles, GridType delegate(in GridType, int, int) pure @safe nothrow f)
        {
            for (int rr = size_y - 1; rr >= 0; --rr)
            {
                for (int cc; cc < size_x; ++cc)
                {
                    if (rr == size_y - 1)
                        continue;

                    tiles = f(tiles, rr, cc);
                }
            }
        }

        auto loop_loop_grid_iterate_move = (ref GridType t) { foreach (_; 0.._move_repeat_times) loop_grid_iterate(t, &move_row_cell); };

        loop_loop_grid_iterate_move(tiles);
        loop_grid_iterate(tiles, &merge_row_cell);
        loop_loop_grid_iterate_move(tiles);

        // Rotate the tiles again
        static if (direction == MoveDirection.Up)
        {
            tiles = tiles.rotate90CW(2);
        }
        else static if (direction == MoveDirection.Left)
        {
            tiles = tiles.rotate90CW;
        }
        else static if (direction == MoveDirection.Right)
        {
            tiles = tiles.rotate90CW(3);
        }

        // Ineffective action?
        if (_tiles == tiles)
        {
            debug
            {
                import std.stdio : writeln;
                writeln("That was an ineffective action. Just sayin'.");
            }
            return;
        }

        _tiles = tiles;

        auto new_tile_placed = placeNextRandomTile();
        // Sanity check. placeNextRandomTile() has been fixed, but check that it
        // worked anyway.
        assert(new_tile_placed && _tiles != tiles, "placeNextRandomTile() was ineffective! No random tile was placed.");
    }

    enum _move_repeat_times = 10;

    alias GridType = T[size_y][size_x];

    GridType _tiles;
    Random _rng;
    uint _seed;
}

void print(T : int[][], char spacing_char = ' ', char tween_cell_char = ' ')(T tiles)
{
    import std.algorithm : min, max, reduce;
    import std.array : join, replicate;
    import std.conv : to;
    import std.stdio : write, writeln;

    string[][] stringified_grid;
    static immutable int max_length = 5;

    stringified_grid.length = tiles.length;

    foreach (rr, row; tiles)
    {
        foreach (cell; row)
        {
            stringified_grid[rr] ~= to!string(cell);
        }
    }

    foreach (row; stringified_grid)
    {
        // Line padding
        write("    ");

        foreach (cell; row)
        {
            auto padding_length = max_length - cell.length;
            auto padding = [[spacing_char]].replicate(padding_length).join;
            write(padding ~ cell, tween_cell_char);
        }
        writeln("\n\n");
    }
    writeln("");
}

unittest {
    writeln("logic.grid.Grid.");

    writeln("  Initialization test.");

    alias StdGrid = Grid!(uint, 4, 4);
    auto g1 = new StdGrid(321);
    g1.tiles.print();

    writeln("  Place random tiles three more times.");

    g1.placeNextRandomTile();
    g1.placeNextRandomTile();
    g1.placeNextRandomTile();
    g1.tiles.print();

    void move(MoveDirection d)
    {
        switch (d)
        {
            case MoveDirection.Down:
                writeln("  Moving down.");
                g1.moveDown();
                break;
            case MoveDirection.Left:
                writeln("  Moving left.");
                g1.moveLeft();
                break;
            case MoveDirection.Right:
                writeln("  Moving right.");
                g1.moveRight();
                break;
            case MoveDirection.Up:
                writeln("  Moving up.");
                g1.moveUp();
                break;
            default:
                assert(0, "Unknown case");
                break;
        }

        g1.tiles.print;
    }

    auto left  = MoveDirection.Left;
    auto down  = MoveDirection.Down;
    auto right = MoveDirection.Right;
    auto up    = MoveDirection.Up;

    move(down);
    move(down);
    move(left);
    move(left);
    move(left);
    move(up);
    move(left);
    move(up);
    move(left);
    move(up);
    move(up);
    move(left);
    move(up);
    move(left);
    move(up);
    move(left);
    move(left);
    move(left);
    move(up);
    move(up);
    move(left);
    move(up);

    writeln("Done.\n");
}
