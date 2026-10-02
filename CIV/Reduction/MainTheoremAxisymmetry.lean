-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Main.InteriorAnalyticity
public import CIV.Prerequisites.Serrin.ClassicalBridge
public import CIV.Reduction.AnalyticPredicates
public import CIV.Reduction.IteratedDerivBridge
public import CIV.Reduction.AxisymmetryFromCore

/-!
# Axisymmetry on the unit cylinder from analytic forcing and an axisymmetric core

The first half of the proof of `thm:main`: by interior analyticity `thm:analytic:interior`,
spatial analyticity of the force `eq:interior:force:analytic` makes every slice `u(·, t)` real
analytic on `B(1)`, and the identity theorem carries the exact axisymmetry on the core
`eq:interior:core` to all of `Q`, which is `eq:interior:global:symmetry`.
-/

@[expose] public section

open MeasureTheory Set
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- `eq:interior:global:symmetry`: a suitable weak solution on `Q`, smooth there, with a
spatially analytic force and an axisymmetric core at every time, is axisymmetric on `Q`. -/
theorem isAxisymmetricOn_unitCylinder_of_forceSpatiallyAnalytic {q : ℝ}
    {u : ParabolicPoint → Vec3} {Du : ParabolicPoint → Fin 3 → Vec3}
    {p : ParabolicPoint → ℝ} {f : ParabolicPoint → Vec3}
    (hsol : CKN.IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (hfa : ForceSpatiallyAnalytic f)
    (hcore : ∀ t ∈ Ioo (-1 : ℝ) 0, ∃ ρ ∈ Ioo (0 : ℝ) 1,
      IsAxisymmetricOn u (spaceTimeSet (vec3Ball 0 ρ) {t})) :
    IsAxisymmetricOn u unitCylinder := by
  have hcl := isClassicalSolutionOn_of_suitable hsol hu hp hf
  have hua : LocallyUniformlyAnalyticOn u 1 (-1) 0 :=
    CIV.Main.interiorAnalyticity 1 (-1) 0 one_pos (by norm_num) u p f hcl
      ((forceSpatiallyAnalytic_iff_locallyUniformlyAnalyticOn f).1 hfa)
  exact isAxisymmetricOn_unitCylinder_of_analytic_of_core
    (analyticOnNhd_slice_of_locallyUniformlyAnalyticOn hu hua) hcore

end CIV
