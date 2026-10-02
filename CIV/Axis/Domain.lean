-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.AxisClosedDomain
public import CIV.Statements.AxisDomain
public import CIV.Statements.AxisParabolicBoundary
public import CIV.Statements.Dr
public import CIV.Statements.DtPast
public import CIV.Statements.Dz

/-!
# The meridional half-disc and its parabolic boundary

This module collects the definitions of `lem:aniso:axis`: the coordinates `((r, z), t)` of the
meridional half-plane and time, the classical partial derivatives `CIV.dr`, `CIV.dz`, the
one-sided time derivative `CIV.dtPast`, and the sets `CIV.axisDomain`, `CIV.axisClosedDomain` and
`CIV.axisParabolicBoundary`, each stated in its own file among the main-result statement files.
-/

@[expose] public section
