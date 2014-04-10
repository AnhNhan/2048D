
import app.cli.input;
import logic.grid;

int main(string[] args) {
    alias StdGrid = Grid!uint;
    auto grid = new StdGrid;

    for (;;)
    {
        grid.tiles.print;
        switch (read_direction())
        {
            case MoveDirection.Left:
                grid.moveLeft();
                break;
            case MoveDirection.Right:
                grid.moveRight();
                break;
            case MoveDirection.Up:
                grid.moveUp();
                break;
            case MoveDirection.Down:
                grid.moveDown();
                break;
            default:
                assert(0);
                break;
        }
    }

    return 0;
}
