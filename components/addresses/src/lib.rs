/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#![allow(unknown_lints)]
#![warn(rust_2018_idioms)]

#[macro_use]
mod error;
mod address;

mod db;
mod engine;
pub mod schema;
mod update_plan;
mod util;

mod ffi;

// Mostly exposed for the sync manager.
pub use crate::db::AddressesStore;
pub use crate::engine::*;
pub use crate::error::*;
pub use crate::address::*;