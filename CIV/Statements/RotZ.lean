-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Foundation.Parabolic.Basic
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

@[expose] public section

open CKN.Foundation.Parabolic

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The rotation `Q_φ` through the angle `φ` about the `z`-axis. -/
def rotZ (φ : ℝ) (x : Vec3) : Vec3 :=
  ![Real.cos φ * x 0 - Real.sin φ * x 1, Real.sin φ * x 0 + Real.cos φ * x 1, x 2]

end CIV
