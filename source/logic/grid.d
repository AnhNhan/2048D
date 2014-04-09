module logic.grid;

import logic.common;

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
        foreach (x, row; _tiles)
        {
            foreach (y, cell; row)
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
        // Hopefully 25% for a 4
        return _rng.uniform(0, 4) == 0 ? 4 : 2;
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

        // Everything is rotated so we only have to move the tiles down
        foreach (_; 0.._move_repeat_times) // Repeat _move_repeat_times times to make sure we can merge stuff that gets opened by this loop
        for (int rr = size_y - 1; rr >= 0; --rr)
        {
            for (int cc; cc < size_x; ++cc)
            {
                if (rr == size_y - 1)
                    continue;

                if (tiles[rr + 1][cc] == tiles[rr][cc] || tiles[rr + 1][cc] == T.init)
                {
                    tiles[rr + 1][cc] += tiles[rr][cc];
                    tiles[rr][cc] = T.init;
                }
            }
        }

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
        _tiles = tiles;

        placeNextRandomTile();
    }

    enum _move_repeat_times = 20;

    T[size_y][size_x] _tiles;
    Random _rng;
    uint _seed;
}

version(unittest) {
    void print(T : int[][])(T tiles)
    {
        string[][] stringified_grid;
        int max_length;

        stringified_grid.length = tiles.length;

        foreach (rr, row; tiles)
        {
            import std.algorithm : max, reduce;
            import std.conv : to;

            foreach (cell; row)
            {
                stringified_grid[rr] ~= to!string(cell);
            }

            max_length = max(max_length, reduce!((a, b) { return max(a, b.length); })(0, stringified_grid[rr]));
        }

        foreach (row; stringified_grid)
        {
            // Line padding
            write("    ");

            foreach (cell; row)
            {
                import std.array : join, replicate;
                auto padding_length = max_length - cell.length;
                auto padding = [" "].replicate(padding_length).join;
                write(padding ~ cell, " ");
            }
            writeln("");
        }
        writeln("");
    }
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

// Rotation function for grid

import std.traits : isArray, isStaticArray;
import std.range : ElementType;

G rotate90CW(G)(G grid)
    if (isArray!G && isArray!(ElementType!G))
in
{
    assert(grid.length);
    assert(grid[0].length);
    foreach (r; grid)
        assert(grid.length == r.length, "We only support quadratic grids.");
}
body
{
    G target;

    auto len = grid.length;

    static if (!isStaticArray!G)
    {
        target.length = len;
        foreach (ref r; target)
            r.length = len;
    }

    foreach (ii; 0..len)
    {
        foreach (jj; 0..len)
        {
            target[ii][jj] = grid[(len - 1) - jj][ii];
        }
    }

    return target;
}

G rotate90CW(G)(G grid, uint times)
    if (isArray!G && isArray!(ElementType!G))
{
    if (times == 1)
    {
        return grid.rotate90CW;
    }
    else
    {
        return grid.rotate90CW.rotate90CW(times - 1);
    }
}

unittest {
    writeln("logic.grid.rotate90CW.");

    auto g1 = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
    ];

    assert(g1.rotate90CW == [
            [7, 4, 1],
            [8, 5, 2],
            [9, 6, 3],
        ]);

    assert(g1.rotate90CW.rotate90CW.rotate90CW.rotate90CW == g1);
    assert(g1.rotate90CW.rotate90CW.rotate90CW.rotate90CW == g1.rotate90CW(4));

    writeln("Done.\n");
}

// RNG helper functions

private auto uniform(V1, V2)(ref Random rng, V1 start, V2 end)
{
    import std.random : std_uniform = uniform;
    return std_uniform(start, end, rng);
}

private auto pick_random(T)(ref Random rng, T[] array)
{
    return array[rng.uniform(0, array.length)];
}
