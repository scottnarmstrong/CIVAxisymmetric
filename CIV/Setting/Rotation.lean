-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Setting.Cylinder
public import CIV.Statements.AngularMean
public import CIV.Statements.AngularMeanScalar
public import CIV.Statements.IsAxisymmetricOn
public import CIV.Statements.RotField
public import CIV.Statements.RotZ

/-!
# Rotations about the axis and the angular mean

This module collects the definitions `CIV.rotZ`, `CIV.rotField`, `CIV.angularMean`,
`CIV.angularMeanScalar` and `CIV.IsAxisymmetricOn` of `eq:interior:average` and
`sec:aniso:notation`, each stated in its own file among the main-result statement files.
-/

@[expose] public section
