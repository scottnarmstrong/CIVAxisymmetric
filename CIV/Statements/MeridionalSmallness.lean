-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.Meridional
public import CIV.Statements.MeridionalQuantity

@[expose] public section

open Set
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- `lim_{t↑0} (-t) G_ρ(t) = 0`, `eq:aniso:small`, unfolded. -/
def MeridionalSmallness (ρ : ℝ) (u : ParabolicPoint → Vec3) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ t₀ ∈ Ioo (-1 : ℝ) 0, ∀ t ∈ Ioo t₀ 0, ∀ x₁ x₃ : ℝ,
    meridional x₁ x₃ ∈ vec3Ball 0 ρ → (-t) * meridionalQuantity u (meridional x₁ x₃, t) ≤ ε

end CIV
