
module utils.random;

import std.random : Random;

/// So you can call `rng.uniform(start, end)`.
auto uniform(V1, V2)(ref Random rng, V1 start, V2 end)
{
    import std.random : std_uniform = uniform;
    return std_uniform(start, end, rng);
}

// TODO: Support random access ranges.
/// Picks a random entry from an array.
auto pick_random(T)(ref Random rng, T[] array)
{
    return array[rng.uniform(0, array.length)];
}
