
module utils.grid;

import std.traits : isArray, isStaticArray;
import std.range : ElementType;

version(unittest) {
    import std.stdio : writeln;
}

/// This function eagerly rotates a square matrix by 90 degrees clockwise.
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

    writeln("  Performance check.");

    void check_perf(void delegate() f, string name)
    {
        import std.datetime : StopWatch;

        StopWatch w;

        w.start();
        for (int ii = 0; ii < 1000000; ++ii)
        {
            f();
        }
        w.stop();
        writeln("    ", name, " took ", w.peek.msecs, "ms");
    }

    check_perf({ g1.rotate90CW; }, "rotate90CW()");
    check_perf({ g1.rotate90CW(4); }, "rotate90CW(4)");
    check_perf({ g1.rotate90CW.rotate90CW.rotate90CW.rotate90CW; }, "g1.rotate90CW.rotate90CW.rotate90CW.rotate90CW");

    writeln("Done.\n");
}
