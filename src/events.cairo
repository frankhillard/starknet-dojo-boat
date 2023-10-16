use starknet::ContractAddress;

#[derive(Drop, Clone, Serde, PartialEq, starknet::Event)]
struct Moved {
    player: ContractAddress,
    x: u32,
    y: u32
}

#[derive(Drop, Clone, Serde, PartialEq, starknet::Event)]
struct Turn {
    player: ContractAddress,
    vx: u16,
    vy: u16
}

#[derive(Drop, Clone, Serde, PartialEq, starknet::Event)]
enum Event {
    Moved: Moved,
    Turn: Turn
}
