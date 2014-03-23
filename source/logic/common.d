
module logic.common;

import std.typecons;
version(unittest) {
    import std.stdio : writeln;
}

alias PositionUnit = uint;

alias Position = const Tuple!(
                            PositionUnit, "x"
                          , PositionUnit, "y"
                        );

unittest {
    writeln("logic.common.Position.");

    auto c1 = Position(2, 5);

    assert(c1.x == 2);
    assert(c1.y == 5);

    assert(c1[0] == 2);
    assert(c1[1] == 5);

    writeln("Done.\n");
}
