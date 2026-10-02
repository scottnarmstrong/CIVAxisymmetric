-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Main.MeridionalSmallness
public import CKN.Statements.SuitableWeakSolution
public import CIV.Statements.AnisotropicBounds
public import CIV.Statements.ForceC2Bounded
public import CIV.Statements.GlobalEnergyClass
public import CIV.Statements.IsAxisymmetricOn
public import CIV.Statements.MeridionalSmallness
public import CIV.Statements.UnitCylinder

@[expose] public section

open MeasureTheory Set
open scoped ENNReal
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Proposition 1.5 (`prop:aniso:small`). -/
theorem meridionalSmallness (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : CKN.IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (henergy : GlobalEnergyClass u Du p)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (haxi : IsAxisymmetricOn u unitCylinder)
    (h : ℝ) (hh : 0 < h ∧ h < 1 / 2) (hMf : ForceC2Bounded f)
    (C : ℝ) (hC : 0 < C) (hbounds : AnisotropicBounds C h u) :
    ∀ ρ ∈ Ioo (0 : ℝ) 1, MeridionalSmallness ρ u :=
by exact CIV.Main.meridionalSmallness q u Du p f hsol henergy hu hp hf haxi h hh hMf C hC hbounds

end CIV
