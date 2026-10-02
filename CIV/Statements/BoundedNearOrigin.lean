-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Foundation.Parabolic.Basic

@[expose] public section

open Set
open CKN.Foundation.Parabolic

set_option autoImplicit false

noncomputable section

namespace CIV

/-- `(0,0)` is a regular point in the sense of `eq:interior:regular`: the velocity is
bounded on a backward cylinder `B(r) × (-δ, 0)` (design note R3). -/
def BoundedNearOrigin (u : ParabolicPoint → Vec3) : Prop :=
  ∃ r δ M : ℝ, 0 < r ∧ 0 < δ ∧
    ∀ x ∈ vec3Ball 0 r, ∀ t ∈ Ioo (-δ) 0, vec3EuclideanNorm (u (x, t)) ≤ M

end CIV
