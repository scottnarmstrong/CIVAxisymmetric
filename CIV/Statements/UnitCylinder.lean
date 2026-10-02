-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Statements.SpaceTimeSet

@[expose] public section

open Set
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The unit parabolic cylinder `Q = B(1) × (-1, 0)` on which the solutions of
arXiv:2609.20803 live; its upper time endpoint `t = 0` is the blow-up time. -/
def unitCylinder : Set ParabolicPoint := spaceTimeSet (vec3Ball 0 1) (Ioo (-1) 0)

end CIV
