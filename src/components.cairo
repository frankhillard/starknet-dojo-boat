use dojo::StorageSize;
use starknet::ContractAddress;
use starkboat::constants::{WIND_CELL_SIZE};
use cubit::f128::types::fixed::{Fixed, FixedTrait};

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Wind {
    #[key]
    cell_x: u32,
    #[key]
    cell_y: u32,
    wx: Fixed,
    wy: Fixed,
}

trait WindTrait {
    fn get_wind_cell(self: Position) -> (u32, u32);
}
impl WindImpl of WindTrait {
    fn get_wind_cell(self: Position) -> (u32, u32) {
        let cell_size: Fixed = FixedTrait::from_unscaled_felt(WIND_CELL_SIZE);
        let res_x = self.x / cell_size;
        let res_y = self.y / cell_size;
        (res_x.try_into().unwrap(), res_y.try_into().unwrap())
    }
}


#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Moves {
    #[key]
    player: ContractAddress,
    remaining: u8,
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Position {
    #[key]
    player: ContractAddress,
    x: Fixed,
    y: Fixed,
    vx: Fixed,
    vy: Fixed
}

trait PositionTrait {
    fn step(self: Position, wind_vx: Fixed, wind_vy: Fixed) -> Position;
    fn change_direction(self: Position, vx: Fixed, vy: Fixed) -> Position;
    fn is_equal(self: Position, b: Position) -> bool;
}

impl PositionImpl of PositionTrait {
    fn step(self: Position, wind_vx: Fixed, wind_vy: Fixed) -> Position {
        let new_x = self.x + self.vx * wind_vx;
        let new_y = self.y + self.vy * wind_vy;
        Position {
            player: self.player,
            x: new_x,
            y: new_y,
            vx: self.vx,
            vy: self.vy
        }
    }

    fn change_direction(self: Position, vx: Fixed, vy: Fixed) -> Position {
        Position {
            player: self.player,
            x: self.x,
            y: self.y,
            vx: vx,
            vy: vy
        }
    }

    fn is_equal(self: Position, b: Position) -> bool {
        self.x == b.x && self.y == b.y
    }
}

impl StorageSizeFixed of StorageSize::<Fixed>{
    #[inline(always)]
    fn unpacked_size() -> usize {
        2
    }
    fn packed_size() -> usize {
        1
    }

}

// impl SerdeLenFixed of SerdeLen<Fixed> {
//     #[inline(always)]
//     fn len() -> usize {
//         2
//     }
// }

#[cfg(test)]
mod tests {
    use super::{Position, PositionTrait};
    use super::{Wind, WindTrait};
    use debug::PrintTrait;
    use cubit::f128::types::fixed::{Fixed, FixedTrait};

    #[test]
    #[available_gas(100000000)]
    fn test_position_step() {
        let player = starknet::contract_address_const::<0x0>();
        let position = Position { 
            player, 
            x: FixedTrait::new_unscaled(90, false), 
            y: FixedTrait::new_unscaled(90, false), 
            vx: FixedTrait::new_unscaled(1, false), 
            vy: FixedTrait::new_unscaled(3, false) 
        };
        let wind = Wind { cell_x: 0, cell_y: 0, wx: FixedTrait::new_unscaled(1, false), wy: FixedTrait::new_unscaled(1, false) };
        let new_position = PositionTrait::step(position, wind.wx, wind.wy);

        // new_position.x.print();
        assert(new_position.player == player, 'player should not change');
        assert(new_position.x == FixedTrait::new_unscaled(91, false), 'x should be different');
        assert(new_position.y == FixedTrait::new_unscaled(93, false), 'y should be different');
        assert(new_position.vx == FixedTrait::new_unscaled(1, false), 'vx should not change');
        assert(new_position.vy == FixedTrait::new_unscaled(3, false), 'vy should not change');
    }

    #[test]
    #[available_gas(100000)]
    fn test_position_change_direction() {
        let player = starknet::contract_address_const::<0x0>();
        let position = Position { 
            player, 
            x: FixedTrait::new(100, false), 
            y: FixedTrait::new(100, false), 
            vx: FixedTrait::new(1, false), 
            vy: FixedTrait::new(2, false) 
        };

        let new_position = PositionTrait::change_direction(position, FixedTrait::new(7, false), FixedTrait::new(1, false));
        assert(new_position.player == player, 'player should not change');
        assert(new_position.x == FixedTrait::new(100, false), 'x should not change');
        assert(new_position.y == FixedTrait::new(100, false), 'y should not change');
        assert(new_position.vx == FixedTrait::new(7, false), 'vx should be different');
        assert(new_position.vy == FixedTrait::new(1, false), 'vy should be different');
    }
}

