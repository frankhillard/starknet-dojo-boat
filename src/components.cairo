use dojo::StorageSize;
use starknet::ContractAddress;
use starkboat::constants::{WIND_CELL_SIZE};
use cubit::f128::types::fixed::{Fixed, FixedTrait};
use cubit::f128::math::trig::PI_u128;
use debug::PrintTrait;

// #[derive(Component, Copy, Drop, Serde, SerdeLen)]
// struct BoatPolar {
//     #[key]
//     wind_speed: u8,
//     #[key]
//     angle: u8,
//     speed: Fixed
// }

trait PolarTrait {
    fn get_boat_speed(wind_spd: Fixed, angle: Fixed) -> Fixed;
}

fn find_interval(values: Span<(Fixed, Fixed)>, angle: Fixed, index: u32) -> (Fixed, Fixed, Fixed, Fixed) {
    if (index + 1 > values.len()) {
        (
            FixedTrait::new_unscaled(0, false),
            FixedTrait::new_unscaled(0, false), 
            FixedTrait::new_unscaled(0, false), 
            FixedTrait::new_unscaled(0, false)
        )
    } else {
        let (min_angle, min_spd): @(Fixed, Fixed) = values.at(index);
        let (max_angle, max_spd): @(Fixed, Fixed) = values.at(index + 1);
        if (angle > min_angle.clone()) && (angle < max_angle.clone()) {
            (min_angle.clone(), min_spd.clone(), max_angle.clone(), max_spd.clone())
        } else {
            find_interval(values, angle, index + 1)
        }
    }
}

impl PolarImpl of PolarTrait {
    fn get_boat_speed(wind_spd: Fixed, angle: Fixed) -> Fixed {
        // assert(wind_spd == 6_u8);
        // WIND_SPEED = 6 KnT
        let mut values: Array<(Fixed, Fixed)> = ArrayTrait::new();
        values.append((FixedTrait::from_unscaled_felt(41), FixedTrait::new(110495997000000000000_u128, false))); // 5.99
        values.append((FixedTrait::from_unscaled_felt(52), FixedTrait::new(124884457400000000000_u128, false))); // 6.77
        values.append((FixedTrait::from_unscaled_felt(60), FixedTrait::new(130787415500000000000_u128, false))); // 7.09 
        values.append((FixedTrait::from_unscaled_felt(70), FixedTrait::new(134107829400000000000_u128, false))); // 7.27 
        values.append((FixedTrait::from_unscaled_felt(75), FixedTrait::new(134661231700000000000_u128, false))); // 7.30 
        values.append((FixedTrait::from_unscaled_felt(80), FixedTrait::new(134476764300000000000_u128, false))); // 7.29 
        values.append((FixedTrait::from_unscaled_felt(90), FixedTrait::new(132816557300000000000_u128, false))); // 7.20 
        values.append((FixedTrait::from_unscaled_felt(110), FixedTrait::new(119165966700000000000_u128, false))); // 6.46 
        values.append((FixedTrait::from_unscaled_felt(120), FixedTrait::new(108282387700000000000_u128, false))); // 5.87 
        values.append((FixedTrait::from_unscaled_felt(135), FixedTrait::new(89466708760000000000_u128, false))); // 4.85 
        values.append((FixedTrait::from_unscaled_felt(150), FixedTrait::new(79689934400000000000_u128, false))); // 4.32 
        values.append((FixedTrait::from_unscaled_felt(165), FixedTrait::new(74893780940000000000_u128, false))); // 4.06 
        values.append((FixedTrait::from_unscaled_felt(174), FixedTrait::new(73418041410000000000_u128, false))); // 3.98 
        values.append((FixedTrait::from_unscaled_felt(180), FixedTrait::new(72680171650000000000_u128, false))); // 3.94 

        // values.append((FixedTrait::from_unscaled_felt(41), FixedTrait::from_unscaled_felt(6)));
        // values.append((FixedTrait::from_unscaled_felt(52), FixedTrait::from_unscaled_felt(7)));
        // values.append((FixedTrait::from_unscaled_felt(60), FixedTrait::from_unscaled_felt(7)));
        // values.append((FixedTrait::from_unscaled_felt(70), FixedTrait::from_unscaled_felt(7)));
        // values.append((FixedTrait::from_unscaled_felt(75), FixedTrait::from_unscaled_felt(7)));
        // values.append((FixedTrait::from_unscaled_felt(80), FixedTrait::from_unscaled_felt(7)));
        // values.append((FixedTrait::from_unscaled_felt(90), FixedTrait::from_unscaled_felt(8)));
        // values.append((FixedTrait::from_unscaled_felt(110), FixedTrait::from_unscaled_felt(6)));
        // values.append((FixedTrait::from_unscaled_felt(120), FixedTrait::from_unscaled_felt(6)));
        // values.append((FixedTrait::from_unscaled_felt(135), FixedTrait::from_unscaled_felt(5)));
        // values.append((FixedTrait::from_unscaled_felt(150), FixedTrait::from_unscaled_felt(4)));
        // values.append((FixedTrait::from_unscaled_felt(165), FixedTrait::from_unscaled_felt(4)));
        // values.append((FixedTrait::from_unscaled_felt(174), FixedTrait::from_unscaled_felt(4)));
        // values.append((FixedTrait::from_unscaled_felt(180), FixedTrait::from_unscaled_felt(3)));

        let (first_angle, first_speed): (Fixed, Fixed) = values.at(0).clone();
        if angle < first_angle {
            FixedTrait::from_unscaled_felt(0)
        } else {
            let (min_angle, min_spd, max_angle, max_spd) = find_interval(values.span(), angle, 0_u32);
            let result: Fixed = (min_spd + max_spd) / FixedTrait::from_unscaled_felt(2);
            result
        }
    }
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Wind {
    #[key]
    cell_x: u32,
    #[key]
    cell_y: u32,
    wx: Fixed,
    wy: Fixed,
    speed: Fixed
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
    fn step(self: Position, wind_vx: Fixed, wind_vy: Fixed, wind_speed: Fixed) -> Position;
    fn change_direction(self: Position, vx: Fixed, vy: Fixed) -> Position;
    fn is_equal(self: Position, b: Position) -> bool;
}

fn compute_angle(v1_x: Fixed, v1_y: Fixed, v2_x: Fixed, v2_y: Fixed) -> Fixed {
    let v1 = FixedTrait::sqrt(v1_x * v1_x + v1_y * v1_y);
    let v2 = FixedTrait::sqrt(v2_x * v2_x + v2_y * v2_y);
    let dot = v1_x * v2_x + v1_y * v2_y;
    let cos = dot / (v1 * v2);
    let angle = FixedTrait::acos(cos);
    angle
}

impl PositionImpl of PositionTrait {
    fn step(self: Position, wind_vx: Fixed, wind_vy: Fixed, wind_speed: Fixed) -> Position {
        //inverse wind vector
        let wind_vx_inversed = -wind_vx;
        let wind_vy_inversed = -wind_vy;
        let angle = compute_angle(self.vx, self.vy, wind_vx_inversed, wind_vy_inversed);
        let angle_deg = angle * FixedTrait::new_unscaled(180, false) / FixedTrait::new(PI_u128, false);
        let angle_abs = FixedTrait::abs(angle_deg);
        let boat_speed = PolarTrait::get_boat_speed(wind_speed, angle_abs);
        let boat_direction_norm = FixedTrait::sqrt(self.vx * self.vx + self.vy * self.vy);
        let delta_x = boat_speed * self.vx / boat_direction_norm;
        let delta_y = boat_speed * self.vy / boat_direction_norm;
        let new_x = self.x + delta_x;
        let new_y = self.y + delta_y;
        // new_x.print();
        // new_y.print();
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
        let wind = Wind { cell_x: 0, cell_y: 0, 
            wx: FixedTrait::new_unscaled(1, false), 
            wy: FixedTrait::new_unscaled(1, false),
            speed: FixedTrait::new_unscaled(6, false) 
        };
        let new_position = PositionTrait::step(position, wind.wx, wind.wy, wind.speed);

        // new_position.x.print();
        assert(new_position.player == player, 'player should not change');
        assert(new_position.x == FixedTrait::new(1684648798116665289347_u128, false), 'x should be different'); //91,32499434 or 0x5b5332d43c3896ea83 
        assert(new_position.y == FixedTrait::new(1733532461082276577163_u128, false), 'y should be different'); //93,974983019 or 0x5df9987cb4a9c4bf8b
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

