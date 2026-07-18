/// This file defines the shared ``Importers`` namespace used by every data-import
/// type in `Sources/App/Importers`. Those types parse the CSV/XML data exports
/// sourced from the MegaMek project (equipment/weapon/ammo stat sheets and
/// universe/era/faction data — see the sample files under `Tests/Resources` for
/// their shape) that an admin uploads to the `/import` routes, converting each
/// row/element into a typed struct that controllers and background `Job`s then
/// turn into database models.
//
// Parent structure for Importers to allow namespace
// with similar names with no collusion.
//
// Author: Richard J Hancock
// Date: 2024/02/19

/// Empty namespace type. Every importer (e.g. `Importers.AmmoCSVRow`,
/// `Importers.Era`, `Importers.Faction`) is declared as a nested type in an
/// extension of ``Importers``, purely to avoid name collisions between similarly
/// named CSV/XML row types across ammo, equipment, weapons, eras, and factions.
struct Importers {}
