-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Setting.Cylinder
public import CIV.Setting.Derivatives
public import CKN.Statements.SuitableWeakSolution
public import CIV.Statements.AnisotropicBounds
public import CIV.Statements.BoundedNearOrigin
public import CIV.Statements.ForceC2Bounded
public import CIV.Statements.ForceSpatiallyAnalytic
public import CIV.Statements.GlobalEnergyClass

/-!
# The standing hypotheses of the anisotropic theorems

This module collects the hypothesis predicates `CIV.AnisotropicBounds`,
`CIV.ForceC2Bounded`, `CIV.ForceSpatiallyAnalytic`, `CIV.GlobalEnergyClass` and
`CIV.BoundedNearOrigin` of `eq:aniso:bounds`, `eq:interior:force:c-two`,
`eq:interior:force:analytic`, `eq:interior:energy:class` and `eq:interior:regular`,
each of which is stated once in its own file under `CIV.Statements`.
-/

@[expose] public section
