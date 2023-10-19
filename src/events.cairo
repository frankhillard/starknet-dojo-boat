use starknet::ContractAddress;
use cubit::f128::types::fixed::{Fixed, FixedTrait};

#[derive(Drop, Clone, Serde, PartialEq, starknet::Event)]
struct Moved {
    player: ContractAddress,
    x: u32,
    y: u32
}

#[derive(Drop, Clone, Serde, PartialEq, starknet::Event)]
struct Turn {
    player: ContractAddress,
    vx: Fixed,
    vy: Fixed
}

#[derive(Drop, Clone, Serde, PartialEq, starknet::Event)]
enum Event {
    Moved: Moved,
    Turn: Turn
}
