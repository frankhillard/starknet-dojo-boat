use starknet::ContractAddress;
use starknet::testing::{set_contract_address, set_account_contract_address};

fn impersonate(address: ContractAddress) {
    set_contract_address(address);
    set_account_contract_address(address);
}

#[cfg(test)]
mod tests {
    use core::traits::TryInto;
    use core::traits::Into;
    use core::clone::Clone;
    use core::option::OptionTrait;
    use debug::PrintTrait;
    use array::SpanTrait;
    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::test_utils::spawn_test_world;

    // project imports
    use starkboat::components::{position, Position, PositionTrait};
    use starkboat::components::{wind, Wind, WindTrait};
    use starkboat::systems::{spawn, move, turn};
    
    use starkboat::constants::{OFFSET, INITIAL_VX, INITIAL_VY};
    use cubit::f128::FixedTrait;

    #[event]
    use starkboat::events::{Event, Moved, Turn};


    // helper setup function
    // reuse this function for all tests
    fn setup_world() -> IWorldDispatcher {
        // components
        let mut components = array![position::TEST_CLASS_HASH, wind::TEST_CLASS_HASH];

        // systems
        let mut systems = array![spawn::TEST_CLASS_HASH, move::TEST_CLASS_HASH, turn::TEST_CLASS_HASH];

        // deploy executor, world and register components/systems
        spawn_test_world(components, systems)
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_move() {
        let world = setup_world();

        // spawn entity
        world.execute('spawn', array![]);

        // move entity
        world.execute('move', array![]);
    
        
        // it is just the caller
        let caller = starknet::contract_address_const::<0x0>();

        // check position
        let new_position = get!(world, caller, (Position));
        assert(new_position.x == FixedTrait::new(1837019008582407403520_u128, false), 'position x is wrong'); // 99,585
        assert(new_position.y == FixedTrait::from_unscaled_felt(OFFSET + INITIAL_VY), 'position y is wrong');

        //check events
        // unpop world creation events
        let mut events_to_unpop = 1; // WorldSpawned
        events_to_unpop += 2; // 2x ComponentRegistered
        events_to_unpop += 3; // 3x SystemRegistered
        loop {
            if events_to_unpop == 0 {
                break;
            };
            starknet::testing::pop_log_raw(world.contract_address);
            events_to_unpop -= 1;
        };
        
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Position (from spawn)
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Moved(
                    Moved {
                        player: caller, x: OFFSET.try_into().unwrap(), y: OFFSET.try_into().unwrap()
                    }
                ),
            'invalid Moved event 0'
        );

        starknet::testing::pop_log_raw(world.contract_address); // unpop Position
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Moved(
                    Moved {
                        player: caller, x: FixedTrait::new(1837019008582407403520_u128, false).try_into().unwrap(), y: (OFFSET+INITIAL_VY).try_into().unwrap()
                    }
                ),
            'invalid Moved event 1'
        );

        // let evt: Moved = starknet::testing::pop_log(world.contract_address).unwrap();
        // evt.x.print();
        // evt.y.print();
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_turn() {
        let world = setup_world();

        // spawn entity
        world.execute('spawn', array![]);

        // move entity
        world.execute('turn', array![0, 1]);
    
        // it is just the caller
        let caller = starknet::contract_address_const::<0x0>();

        // check final position
        let new_position = get!(world, caller, (Position));
        assert(new_position.x == FixedTrait::from_unscaled_felt(OFFSET), 'position x is wrong');
        assert(new_position.y == FixedTrait::from_unscaled_felt(OFFSET), 'position y is wrong');

        //check events
        // unpop world creation events
        let mut events_to_unpop = 1; // WorldSpawned
        events_to_unpop += 2; // 2x ComponentRegistered
        events_to_unpop += 3; // 3x SystemRegistered
        loop {
            if events_to_unpop == 0 {
                break;
            };
            starknet::testing::pop_log_raw(world.contract_address);
            events_to_unpop -= 1;
        };
        // 'event pop Position'.print();
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Position (from spawn)
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Moved(
                    Moved {
                        player: caller, x: OFFSET.try_into().unwrap(), y: OFFSET.try_into().unwrap()
                    }
                ),
            'invalid Moved event 0'
        );

        // TURN
        starknet::testing::pop_log_raw(world.contract_address); // unpop Position
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Turn(
                    Turn {
                        player: caller, vx: FixedTrait::new_unscaled(0, false), vy: FixedTrait::new_unscaled(1, false)
                    }
                ),
            'invalid Moved event 1'
        );

    }

    #[test]
    #[available_gas(30000000000)]
    fn test_move_turn_move() {
        let world = setup_world();

        // spawn entity
        world.execute('spawn', array![]);

        // move entity
        world.execute('move', array![]);
        world.execute('turn', array![0, 1]);
        world.execute('move', array![]);
    
        // it is just the caller
        let caller = starknet::contract_address_const::<0x0>();

        // check final position
        let new_position = get!(world, caller, (Position));
        assert(new_position.x == FixedTrait::new(1837019008582407403520_u128, false), 'position x is wrong'); //99,585
        assert(new_position.y == FixedTrait::new(1837019008582407403520_u128, false), 'position y is wrong'); //99,585

        //check events
        // unpop world creation events
        let mut events_to_unpop = 1; // WorldSpawned
        events_to_unpop += 2; // 2x ComponentRegistered
        events_to_unpop += 3; // 3x SystemRegistered
        loop {
            if events_to_unpop == 0 {
                break;
            };
            starknet::testing::pop_log_raw(world.contract_address);
            events_to_unpop -= 1;
        };
        // 'event pop Position'.print();
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Wind (from spawn)
        starknet::testing::pop_log_raw(world.contract_address); // unpop Position (from spawn)
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Moved(
                    Moved {
                        player: caller, x: OFFSET.try_into().unwrap(), y: OFFSET.try_into().unwrap()
                    }
                ),
            'invalid Moved event 0'
        );

        // MOVE
        starknet::testing::pop_log_raw(world.contract_address); // unpop Position
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Moved(
                    Moved {
                        player: caller, 
                        x: FixedTrait::new(1837019008582407403520_u128, false).try_into().unwrap(), 
                        y: (OFFSET+INITIAL_VY).try_into().unwrap()
                    }
                ),
            'invalid Moved event 0'
        );

        // TURN
        starknet::testing::pop_log_raw(world.contract_address); // unpop Position
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Turn(
                    Turn {
                        player: caller, vx: FixedTrait::new_unscaled(0, false), vy: FixedTrait::new_unscaled(1, false)
                    }
                ),
            'invalid Turn event 1'
        );

        // MOVE
        starknet::testing::pop_log_raw(world.contract_address); // unpop Position
        assert(
            @starknet::testing::pop_log(world.contract_address)
                .unwrap() == @Event::Moved(
                    Moved {
                        player: caller, 
                        x: FixedTrait::new(1837019008582407403520_u128, false).try_into().unwrap(), 
                        y: FixedTrait::new(1837019008582407403520_u128, false).try_into().unwrap()
                    }
                ),
            'invalid Moved event 2'
        );

        // // MOVE
        // starknet::testing::pop_log_raw(world.contract_address); // unpop Position
        // let evt: Moved = starknet::testing::pop_log(world.contract_address).unwrap();
        // evt.x.print();
        // evt.y.print();
    }


    #[test]
    #[available_gas(30000000000)]
    fn test_move_turn_move_move() {
        let world = setup_world();

        // spawn entity
        world.execute('spawn', array![]);

        // move entity
        world.execute('move', array![]);
        world.execute('turn', array![0, 1]);
        world.execute('move', array![]);
        world.execute('move', array![]);
    
        // it is just the caller
        let caller = starknet::contract_address_const::<0x0>();

        // check final position
        let new_position = get!(world, caller, (Position));
        assert(new_position.x == FixedTrait::new(1837019008582407403520_u128, false), 'position x is wrong'); //99,585
        assert(new_position.y == FixedTrait::new(1921597330162407403520_u128, false), 'position y is wrong'); //104,17
    }


    #[test]
    #[available_gas(30000000000)]
    fn test_backwind() {
        let world = setup_world();

        // spawn entity
        world.execute('spawn', array![]);

        // move entity
        world.execute('turn', array![1, 1]);
        world.execute('move', array![]);
        // world.execute('move', array![]);
    
        // it is just the caller
        let caller = starknet::contract_address_const::<0x0>();

        // check final position
        let new_position = get!(world, caller, (Position));
        assert(new_position.x == FixedTrait::new(1803833329241980462635_u128, false), 'position x is wrong'); //95 + 3,94÷√2 = 97,786000718
        assert(new_position.y == FixedTrait::new(1803833329241980462635_u128, false), 'position y is wrong'); //95 + 3,94÷√2 = 97,786000718
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_frontwind() {
        let world = setup_world();

        // spawn entity
        world.execute('spawn', array![]);

        // move entity
        world.execute('turn', array![-1, -1]);
        world.execute('move', array![]);
        // world.execute('move', array![]);
    
        // it is just the caller
        let caller = starknet::contract_address_const::<0x0>();

        // check final position
        let new_position = get!(world, caller, (Position));
        assert(new_position.x == FixedTrait::from_unscaled_felt(OFFSET), 'position x is wrong'); //95
        assert(new_position.y == FixedTrait::from_unscaled_felt(OFFSET), 'position y is wrong'); //95
    }

}
