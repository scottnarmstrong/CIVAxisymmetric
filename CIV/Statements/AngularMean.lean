-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.RotField
public import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic

@[expose] public section

open MeasureTheory
open CKN.Foundation.Parabolic

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The angular mean `𝒫u = (2π)⁻¹ ∫₀^{2π} ℛ_φ u dφ` of `eq:interior:average`, the
axisymmetric part of a field. -/
def angularMean (u : ParabolicPoint → Vec3) (z : ParabolicPoint) : Vec3 :=
  (2 * Real.pi)⁻¹ • ∫ φ in (0 : ℝ)..(2 * Real.pi), rotField φ u z

end CIV
