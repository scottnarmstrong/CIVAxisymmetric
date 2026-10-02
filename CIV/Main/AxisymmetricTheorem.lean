-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Setting.Hypotheses
public import CIV.Main.MeridionalSmallness
public import CIV.Reduction.AveragedSuitableSolution

/-!
# The public statement `CIV.Main.axisymmetricTheorem`

This module proves the statement `CIV.axisymmetricTheorem` (`thm:aniso:main`). The proof is the
printed one: `prop:aniso:small` at `ρ = 1/2` (`CIV.Main.meridionalSmallness`) gives
`eq:aniso:closure:small` with `ρ₀ = 1/2`, and the closure lemma `lem:aniso:closure`, applied to the
rotation-averaged triple `(u, π̄, 𝒫 f)` whose force is axisymmetric
(`CIV.boundedNearOrigin_of_meridionalSmallness_averaged`), makes `(0,0)` a regular point.
-/

@[expose] public section

open MeasureTheory Set
open scoped ENNReal
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV
namespace Main

/-- The public statement of `thm:aniso:main`: an axisymmetric suitable weak solution on the unit
cylinder, smooth there, with a force satisfying `eq:interior:force:c-two` and the anisotropic
bounds `eq:aniso:bounds`, is regular at the origin. -/
theorem axisymmetricTheorem (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : CKN.IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (henergy : GlobalEnergyClass u Du p)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (haxi : IsAxisymmetricOn u unitCylinder)
    (h : ℝ) (hh : 0 < h ∧ h < 1 / 2)
    (hMf : ForceC2Bounded f)
    (C : ℝ) (hC : 0 < C) (hbounds : AnisotropicBounds C h u) :
    BoundedNearOrigin u :=
  boundedNearOrigin_of_meridionalSmallness_averaged q u Du p f hsol henergy hu hp hf haxi hMf
    (1 / 2) ⟨by norm_num, by norm_num⟩
    (meridionalSmallness q u Du p f hsol henergy hu hp hf haxi h hh hMf C hC hbounds
      (1 / 2) ⟨by norm_num, by norm_num⟩)

end Main
end CIV
