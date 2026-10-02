-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.RotZ
public import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic

@[expose] public section

open MeasureTheory
open CKN.Foundation.Parabolic

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The angular mean of a scalar field, `(2π)⁻¹ ∫₀^{2π} g(Q_φ⁻¹ x, t) dφ`. -/
def angularMeanScalar (g : ParabolicPoint → ℝ) (z : ParabolicPoint) : ℝ :=
  (2 * Real.pi)⁻¹ • ∫ φ in (0 : ℝ)..(2 * Real.pi), g (rotZ (-φ) z.1, z.2)

end CIV
