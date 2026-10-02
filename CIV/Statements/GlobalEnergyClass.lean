-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.UnitCylinder
public import Mathlib.MeasureTheory.Function.LpSeminorm.Basic

@[expose] public section

open MeasureTheory Set
open scoped ENNReal
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The energy class `eq:interior:energy:class` on all of `Q`, up to the blow-up time:
`u ∈ L^∞_t L²_x(Q) ∩ L²_t H¹_x(Q)` and `π ∈ L^{3/2}_{x,t}(Q)` (design note R6). -/
def GlobalEnergyClass (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) : Prop :=
  essSup (fun s => ∫⁻ x in vec3Ball 0 1, ‖u (x, s)‖ₑ ^ (2 : ℝ)) (volume.restrict (Ioo (-1) 0)) < ⊤ ∧
    (∫⁻ z in unitCylinder, ‖u z‖ₑ ^ (2 : ℝ) + ‖Du z‖ₑ ^ (2 : ℝ)) < ⊤ ∧
    MemLp p (ENNReal.ofReal (3 / 2 : ℝ)) (volume.restrict unitCylinder)

end CIV
