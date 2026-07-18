/// Namespace for the entire BattleTech domain.
///
/// Every Fluent model (``BattleTech/Era``, ``BattleTech/Faction``, `Weapon`,
/// `Ammo`, etc.), pivot/join table, and their migrations are declared as
/// `extension BattleTech { ... }` in sibling files. `BattleTech` itself holds no
/// data or behavior — it exists purely so related types can be written as
/// ``BattleTech/Era``, `BattleTech.Weapon`, and so on, grouped under one
/// dot-prefixed name instead of living loose at the top level.
// Empty struct for the BattleTech parent Module
struct BattleTech {}
