-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.AngularMean

@[expose] public section

open CKN.Foundation.Parabolic

set_option autoImplicit false

noncomputable section

namespace CIV

/-- A field is axisymmetric on a set when its non-axisymmetric part `w = u - 𝒫u`
vanishes there (Section `sec:aniso:notation`). -/
def IsAxisymmetricOn (u : ParabolicPoint → Vec3) (S : Set ParabolicPoint) : Prop :=
  ∀ z ∈ S, angularMean u z = u z

end CIV
