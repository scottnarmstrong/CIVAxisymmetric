-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.IsBoundedNear

@[expose] public section

open CKN.Foundation.Parabolic

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The singular slice of the blow-up time `t = 0`: the points near which `u` is
unbounded on every backward parabolic neighbourhood, `S₀` of design note R12. -/
def singularSlice (u : ParabolicPoint → Vec3) : Set Vec3 := {x | ¬ IsBoundedNear u x}

end CIV
