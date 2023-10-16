#[system]
mod spawn {
    use dojo::world::Context;

    use starkboat::components::{Position, Wind};
    use starkboat::constants::{OFFSET,INITIAL_VX,INITIAL_VY,WIND_CELL_SIZE};
    use cubit::f128::types::fixed::{Fixed, FixedTrait};

    #[event]
    use starkboat::events::{Event, Moved};


    // so we don't go negative

    fn execute(ctx: Context) {
        // cast the offset to a u32
        let offset: u32 = OFFSET.try_into().unwrap();
        let init_vx: u32 = INITIAL_VX.try_into().unwrap();
        let init_vy: u32 = INITIAL_VY.try_into().unwrap();
        
        set!(
            ctx.world,
            (
                Wind { cell_x: 0, cell_y: 0, wx: FixedTrait::new_unscaled(1, false), wy:FixedTrait::new_unscaled(1, false) },
                Wind { cell_x: 0, cell_y: 1, wx: FixedTrait::new_unscaled(1, false), wy:FixedTrait::new_unscaled(1, true) },
                Wind { cell_x: 1, cell_y: 1, wx: FixedTrait::new_unscaled(0, false), wy:FixedTrait::new_unscaled(0, false) },
                Wind { cell_x: 1, cell_y: 0, wx: FixedTrait::new_unscaled(0, false), wy:FixedTrait::new_unscaled(0, false) },
                Position { 
                    player: ctx.origin, 
                    x: FixedTrait::new_unscaled(offset.into(), false), 
                    y: FixedTrait::new_unscaled(offset.into(), false), 
                    vx: FixedTrait::new_unscaled(init_vx.into(), false), 
                    vy: FixedTrait::new_unscaled(init_vy.into(), false)
                },
            )
        );

        emit!(ctx.world, Moved { player: ctx.origin, x: offset, y: offset, });

        return ();
    }
}

#[system]
mod move {
    use dojo::world::Context;
    use debug::PrintTrait;
    use starknet::ContractAddress;
    use starkboat::components::{Position, PositionTrait };
    use starkboat::components::{Wind, WindTrait};
    use cubit::f128::types::fixed::{Fixed, FixedTrait};

    #[event]
    use starkboat::events::{Event, Moved, Turn};

    fn execute(ctx: Context) {
        let mut position = get!(ctx.world, ctx.origin, Position);
        let cur_wind_cell: (u32, u32) = WindTrait::get_wind_cell(position);
        let mut cur_wind = get!(ctx.world, cur_wind_cell, Wind);
        let wx : Fixed = cur_wind.wx;
        let wy : Fixed = cur_wind.wy;
        let next = PositionTrait::step(position, wx, wy); 
        // next.x.print();
        // next.y.print();
        // '[move] after step'.print();
        set!(ctx.world, (next));
        emit!(ctx.world, Moved { player: ctx.origin, x: next.x.try_into().unwrap(), y: next.y.try_into().unwrap(), });

        return ();
    }

}


#[system]
mod turn {
    use dojo::world::Context;
    use debug::PrintTrait;
    use starknet::ContractAddress;
    use starkboat::components::{Position, PositionTrait };
    use starkboat::components::{Wind, WindTrait};
    use cubit::f128::types::fixed::{Fixed, FixedTrait};

    #[event]
    use starkboat::events::{Event, Moved, Turn};

    fn execute(ctx: Context, new_vx: felt252, new_vy: felt252) {
        let tx = FixedTrait::from_unscaled_felt(new_vx);
        let ty = FixedTrait::from_unscaled_felt(new_vy);
        let mut position = get!(ctx.world, ctx.origin, Position);
        let next = PositionTrait::change_direction(position, tx, ty); 
        // next.x.print();
        // next.y.print();
        // '[move] after step'.print();
        set!(ctx.world, (next));
        emit!(ctx.world, Turn { player: ctx.origin, vx: next.vx.try_into().unwrap(), vy: next.vy.try_into().unwrap(), });

        return ();
    }
}