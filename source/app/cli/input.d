
module app.cli.input;

import logic.grid : MoveDirection;

MoveDirection read_direction()
{
    import std.stdio : stdin, writeln;

    // TODO: Get something going to have single-character input going without
    // having to wait on buffer break
    char c;
    stdin.flush;
    stdin.readf("%c", &c);
    stdin.flush;

    if (c == 'a')
        return MoveDirection.Left;
    if (c == 'd')
        return MoveDirection.Right;
    if (c == 'w')
        return MoveDirection.Up;
    if (c == 's')
        return MoveDirection.Down;

    writeln("Invalid input! Use 'w', 'a', 's' or 'd'.");
    return read_direction;
}
