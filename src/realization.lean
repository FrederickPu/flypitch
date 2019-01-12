import .fol tactic.tidy tactic.linarith

open fol

-- local attribute [instance, priority 0] classical.prop_decidable
--local attribute [instance] classical.prop_decidable

local notation h :: t  := dvector.cons h t
local notation `[]` := dvector.nil
local notation `[` l:(foldr `, ` (h t, dvector.cons h t) dvector.nil `]`) := l


namespace realization

@[simp]lemma func_subst_irrel {L : Language} {n n' l} {f : L.functions l} {t : bounded_term L n'} :
  subst_bounded_term (bd_func f : bounded_preterm L (n + n' + 1) l) t = (bd_func f) := by refl

@[simp]lemma func_subst0_irrel {L : Language} {n l} {f : L.functions l} {t : bounded_term L n} : (bd_func f)[t /0] = (bd_func f) := by refl
-- i wonder why this is by refl while rel_subst0_irrel isn't...

@[simp]lemma subst_bounded_term_bd_apps {L} {n n' l} (f : bounded_preterm L (n + n' + 1) l) {t : bounded_term L n'} {ts : dvector (bounded_term L (n + n' + 1)) l} :
  (bd_apps f ts)[t /// _] = bd_apps (f[t /// _]) (ts.map $ λ t', subst_bounded_term (t') t) := by {induction ts generalizing f, refl, simp[bd_apps, ts_ih (bd_app f ts_x)]}

@[simp]lemma subst0_bounded_term_bd_apps {L} {n l} (f : bounded_preterm L (n+1) l) {t : closed_term L} {ts : dvector (bounded_term L (n+1)) l} :
  (bd_apps f ts)[(t.cast0 n) /0] = bd_apps (f[(t.cast0 n) /0]) (ts.map $ λ t', t'[(t.cast0 n) /0]) := by {induction ts generalizing f, refl, simp[bd_apps, ts_ih (bd_app f ts_x)], refl}

-- TODO write a version of this lemma for subst0_bounded_term

lemma realize_func_irrel {L} {S : Structure L} {n n' l : ℕ} {t : bounded_term L n'} {f : L.functions l} {xs : dvector ↥S l} {v : dvector ↥S (n + n' + 1)} : realize_bounded_term v (bd_func f) xs = S.fun_map f xs := by refl

@[simp]lemma subst_falsum {L} {n n' n''} {h : n + n' + 1 = n''} {t : bounded_term L n'} : bd_falsum[t // n // h] = bd_falsum :=
  by ext; simp

@[simp]lemma subst0_falsum {L} {n} {t : bounded_term L n} : bd_falsum[t /0] = bd_falsum :=
  by ext; simp

@[simp]lemma subst_eq {L} {n n' n''} {h : n + n' + 1 = n''} {t₁ t₂ : bounded_term L n''} {t : bounded_term L n'} : (t₁ ≃ t₂)[t // n // h] = subst_bounded_term (t₁.cast_eq h.symm) t ≃ subst_bounded_term (t₂.cast_eq h.symm) t := by ext; simp

@[simp]lemma subst0_eq {L} {n} {t : bounded_term L n} {t₁ t₂ : bounded_term L (n+1)} : (t₁ ≃ t₂)[t /0] = (t₁[t /0] ≃ t₂[t /0]) :=
  by {unfold subst0_bounded_formula, simpa only [subst_eq]}

@[simp]lemma subst_imp {L} {n n' n''} {h : n + n' + 1 = n''} {t : bounded_term L n'} {f₁ f₂ : bounded_formula L (n'')} : (f₁ ⟹ f₂)[t // n // h] = (f₁[t // n // h] ⟹ f₂[t // n // h]) := by {ext1, induction h, refl}

@[simp]lemma subst0_imp {L} {n} {t : bounded_term L n} {f₁ f₂ : bounded_formula L (n+1)} : (f₁ ⟹ f₂)[t /0] = f₁[t /0] ⟹ f₂[t /0] :=
  by {unfold subst0_bounded_formula, simpa only [subst_imp]}

@[simp]lemma subst_all' {L} {n n' n''} {h : n + n' + 1 = n''} {t : bounded_term L n'} {f : bounded_formula L (n'' + 1)} :
  (∀'f)[t  // n // (by {simp[h]})]
  = ∀'(f[(t : bounded_term L n') // (n+1) // (by {subst h; simp})]).cast_eq (by simp) := by ext; simp

@[simp]lemma subst_all {L} {n n' n''} {h : n + n' + 1 = n''} {t : closed_term L} {f : bounded_formula L (n'' + 1)} :
  (∀'f)[t.cast0 n' // n // (by {simp[h]})]
  = ∀'(f[(t.cast0 n' : bounded_term L n') // (n+1) // (by subst h; simp)]).cast_eq (by simp) :=
  by {apply subst_all'}

@[simp]lemma subst0_all {L} {n} {t : closed_term L} {f : bounded_formula L (n+2)} :
  ((∀'f)[t.cast (by simp) /0] : bounded_formula L n) = ∀'((f[t.cast0 n // 1 // (by {simp} : 1 + n + 1 = n + 2)]).cast_eq (by simp)) :=
  by ext; simp

@[simp]lemma subst0_all_base {L} {t : closed_term L} {f : bounded_formula L 2} : (∀' f)[t /0] = ∀'(f[t // 1 // (by simp)]) :=
  by ext; simp

@[simp]lemma rel_subst_irrel {L : Language} {n n' l} {R : L.relations l} {t : bounded_term L n'} : (bd_rel R)[t // n // (by refl)] = (bd_rel R) := by ext; simp

@[simp]lemma rel_subst_irrel1 {L : Language} {n n' n'' l} {h : n + n' + 1 = n''} {R : L.relations l} {t : bounded_term L n'} : (@bd_rel L (n + n' + 1 + 1) _ R)[t // (n+1) // (by subst h; simp)] = (bd_rel R) := by ext; simp

@[simp]lemma rel_subst_irrel' {L : Language} {n n' n'' l} {h : n + n' + 1 = n''} {R : L.relations l} {t : bounded_term L n'} : (bd_rel R)[t // n // h] = (bd_rel R) := by subst h; apply rel_subst_irrel

@[simp]lemma rel_subst0_irrel {L : Language} {n l} {R : L.relations l} {t : bounded_term L n} : (bd_rel R)[t /0] = (bd_rel R) := by ext; simp

lemma realize_rel_irrel {L} {S : Structure L} {n n' l : ℕ} {t : bounded_term L n'} {R : L.relations l} {xs : dvector ↥S l} {v : dvector ↥S (n + n' + 1)} : realize_bounded_formula v (bounded_preformula.cast_eq (by refl) (bd_rel R)) xs = S.rel_map R xs := by refl

@[simp]lemma subst_bounded_formula_bd_apps_rel {L} {n n' n'' l} {h : n + n' + 1 = n''} (f : bounded_preformula L (n''+1) l)
  {t : bounded_term L n'} {ts : dvector (bounded_term L (n'' + 1)) l } :
    (bd_apps_rel f ts)[t // (n+1) // (by {subst h, simp})] = bd_apps_rel (f[t // (n+1) // by {subst h, simp}]) (ts.map $ λ t', subst_bounded_term (t'.cast_eq (by subst h; simp)) t) :=
  by {induction ts generalizing f, refl, simp[bd_apps_rel, ts_ih (bd_apprel f ts_x)], congr, ext, simp}

@[simp]lemma subst0_bounded_formula_bd_apps_rel {L} {n l} (f : bounded_preformula L (n+1) l) 
  (t : closed_term L) (ts : dvector (bounded_term L (n+1)) l) :
  subst0_bounded_formula (bd_apps_rel f ts) (t.cast (by simp)) = 
  bd_apps_rel (subst0_bounded_formula f (t.cast (by simp))) (ts.map $ λt', subst0_bounded_term t' (t.cast (by simp))) :=
by {induction ts generalizing f, refl, simp[bd_apps_rel, ts_ih (bd_apprel f ts_x)], congr, ext, simp}

lemma zero_of_lt_one (n : nat) (h : n < 1) : n = 0 :=
  by {cases h, refl, cases nat.lt_of_succ_le h_a}

lemma asjh'_term {L} {S : Structure L} {n n'} {s : bounded_term L (n + n' + 1 + 1)} {t : bounded_term L n'} {v : dvector S (n + n' + 1)} :
S[(@subst_bounded_term _ (n+1) n' 0 (s.cast_eq (by simp)) t).cast_eq (by simp) ;;; v] = S[s ;;; (v.insert (S[t.cast (by linarith) ;;; v]) (n+1))]
 :=
begin
  revert s, refine bounded_term.rec1 _ _; intros,
  {sorry},
  {sorry}
end

set_option pp.implicit false

lemma asjh' {L} {S : Structure L} {n n' n''} {h : n + n' + 1 = n''} {t : bounded_term L (n')} {f : bounded_formula L (n''+1)} (v : dvector S n'') : (S[(f[t  // (n+1) // (by {induction h, simp})]).cast_eq (by induction h; simp) ;; v])
= (S[f ;; (v.insert (S[t.cast (by {induction h, linarith}) ;;; v]) (n+1))]) :=
begin 
  revert n'' f v, refine bounded_formula.rec1 _ _ _ _ _; intros,
  {ext, subst h, simp[subst_falsum], intros a, exact a},
  {ext, -- simp[realize_subst_preterm, asjh'_term],
    conv {to_lhs, rw[realize_bounded_formula_cast_eq_irrel]},
    simp[realize_subst_preterm], induction v, simp,
    sorry, simp*, repeat{sorry}

  --  tidy, 
  --       sorry
  -- -- conv {to_lhs, congr, skip, congr, congr, rw[asjh'_term],},
    },
  {sorry},
  {sorry},
  {have : n + 1 + n' + 1 = n_1 + 1, by subst h; simp, conv {to_lhs, congr, skip, congr, rw[subst_all'], skip, rw[this]}, rw[bounded_preformula.cast_eq_all], dsimp, ext, apply forall_congr, intro x, repeat{rw[realize_bounded_formula_cast_eq_irrel]}, rw[dvector.cast_trans], have := ih (x::v), simp at *, 
  },
end

set_option pp.implicit false

lemma dvector_cast_lemma {α : Type*} {n : ℕ} {m} {h : n = m} {h' : n+1 = m+1} {x : α} {v : dvector α n} :
(x::v).cast h' = x::(v.cast h) := by subst h; refl

lemma dvector_cast_pull_out {α : Type*} {n : ℕ} {m} {h : n = m} {h' : n+1 = m+1} {x : α} {v : dvector α n} : (x :: (v.cast h)) = (x::v).cast (h') := by subst h; refl

set_option pp.implicit false

lemma asjh''0_term {L : Language} {S : Structure L}  (n n' n'' : ℕ) {l f_n : ℕ} (s : bounded_term L f_n) (t : closed_term L) (v : dvector ↥S n'') {h : n + n' + 1 = n''} {h' : n'' + 1 = f_n}  (xs : dvector ↥S 0) : realize_bounded_term (dvector.cast (by substs h h'; simp : n'' = n + 1 + n') v)
      (subst_bounded_term (bounded_preterm.cast_eq (by {subst h; rw[<-h'],simp}) s) (bounded_preterm.cast (zero_le n') t))
      xs =
    realize_bounded_term (dvector.cast (h') (dvector.insert (realize_closed_term S t) (n + 1) v)) s xs :=
begin
  revert s, refine bounded_term.rec _ _; intros,
  {sorry},
  {sorry}
end

lemma asjh''0 {L} {S : Structure L}  : ∀ {n n' n'' : ℕ} {n'''} {l} {h : n + n' + 1 = n''} {h' : n'' + 1 = n'''} (f : bounded_preformula L (n''') l) (t : closed_term L) (v : dvector S n'') (xs : dvector S l), (S[(f[t.cast0 n' // (n+1) // (by {substs h h', simp})]).cast_eq (by {subst h, simp}) ;; v ;; xs]) ↔ (S[f.cast_eq (by substs h h'; simp) ;; (v.insert (S[t.cast (by {substs h h', linarith}) ;;; v]) (n+1)) ;; xs])
:=
begin
  intros,
  induction f generalizing n n' n'' v,
    {intros, simp},
    {simp, apply iff_of_eq, congr' 1; apply asjh''0_term n n' n'' _ t v xs, all_goals{try{exact 0}, try{exact h}}},
    {simp},
    {sorry},
    {have this_f := f_ih_f₁ xs v, have this_g := f_ih_f₂ xs v, simp, simp at this_f this_g, rw[<-this_f,<-this_g]},
    {substs h h', conv{to_lhs, congr, skip, congr,
    rw[@subst_all' L (n+1) n' (n + n' + 1 + 1) (by {simp}) (t.cast0 n') f_f]}, rw[cast_eq_all], dsimp, apply forall_congr, intro x,
    have := @f_ih xs (n+1) n' ((n+1) + n' + 1) (x::(v.cast (by simp))) (by simp) (by simp),
    rw[dvector_cast_pull_out] at this, swap, simp,
    repeat{rw[realize_bounded_formula_cast_eq_irrel]},
    rw[realize_bounded_formula_cast_eq_irrel] at this, rw[dvector.cast_trans] at *,
    rw[this], clear this, clear f_ih, rw[dvector.insert_cons], apply iff_of_eq,
    congr' 1, simp, simp [realize_bounded_term_irrel, -dvector.cast],
    rw[dvector.insert_cons], congr' 1, simp, apply dvector.cast_hrfl,
    simp[bounded_preformula.cast_eq_rfl], apply bounded_preformula.cast_eq_hrfl
}


-- simp[this], let k, swap, change realize_bounded_formula v (bounded_preformula.cast_eq k _) _ ↔ _,
-- let j, swap, change realize_bounded_formula v (bounded_preformula.cast_eq k (∀' j)) _ ↔ _,
-- rw[cast_eq_all], dsimp[k,j], clear k j, apply forall_congr, intro x,
--      have := @f_ih xs (n+1) n' ((n+1) + n' + 1) (x::(v.cast (by simp))) (by simp) (by simp) t,
--      rw[cast_eq_trans], rw[dvector_cast_pull_out] at this, swap, simp, swap, simp, simp,
--      rw[realize_bounded_formula_cast_eq_irrel], rw[realize_bounded_formula_cast_eq_irrel] at this, rw[dvector.cast_trans] at this, rw[this], clear this, clear this f_ih,
--      rw[dvector.insert_cons], apply iff_of_eq, congr' 1, simp, swap, {apply cast_eq_hrfl},
--      {swap, simp, rw[dvector.insert_cons], simp, rw[dvector.insert_cons], let p, swap,
--      let q, swap, change p == q, apply (@heq_iff_eq _ p (q.cast (by simp))).mpr, }}
end

lemma asjh'' {L} {S : Structure L}  : ∀ {n n' n'' : ℕ} {n'''} {l} {h : n + n' + 1 = n''} {h' : n'' + 1 = n'''} (f : bounded_preformula L (n''') l) (t : bounded_term L n') (v : dvector S n'') (xs : dvector S l), (S[(f[t  // (n+1) // (by {substs h h', simp})]).cast_eq (by {subst h, simp}) ;; v ;; xs]) = (S[f.cast_eq (by substs h h'; simp) ;; (v.insert (S[t.cast (by {substs h h', linarith}) ;;; v]) (n+1)) ;; xs])
:=
begin
  intros,
  induction f generalizing n n' n'' v,
    {intros, simp},
    {sorry},
    {simp},
    {sorry},
    {have this_f := f_ih_f₁ xs v t, have this_g := f_ih_f₂ xs v t, simp, simp at this_f this_g, rw[<-this_f,<-this_g]},
    {substs h h', have := @subst_all' L (n+1) n' (n + n' + 1 + 1) (by {simp}) t (f_f), ext, simp[this], let k, swap, change realize_bounded_formula v (bounded_preformula.cast_eq k _) _ ↔ _,
let j, swap, change realize_bounded_formula v (bounded_preformula.cast_eq k (∀' j)) _ ↔ _,
rw[cast_eq_all], dsimp[k,j], clear k j, apply forall_congr, intro x,
     have := @f_ih xs (n+1) n' ((n+1) + n' + 1) (x::(v.cast (by simp))) (by simp) (by simp) t,
     rw[cast_eq_trans], rw[dvector_cast_pull_out] at this, swap, simp, swap, simp, simp,
     rw[realize_bounded_formula_cast_eq_irrel], rw[realize_bounded_formula_cast_eq_irrel] at this, rw[dvector.cast_trans] at this, rw[this], clear this, clear this f_ih,
     rw[dvector.insert_cons], apply iff_of_eq, congr' 1, simp, swap, {apply cast_eq_hrfl},
     {swap, simp, rw[dvector.insert_cons], simp, rw[dvector.insert_cons],--  let p, swap,
     -- let q, swap, change p == q,
     -- apply (@heq_iff_eq _ p (q.cast (by simp))).mpr, }}
     congr' 1, simp, 
end
-- AHA! so we can see here that the term itself actually needs to be lifted... by 1.
-- note: doing just t ↦ t ↑ 1 doesn't work. need to lift the formula instead

-- #check (((&0 ≃ &1) : bounded_formula L_empty 2) ⟹ (∀'((&0 ≃ &1 : bounded_formula L_empty 3) ⊓ (&0 ≃ &2 : bounded_formula L_empty 3)) : bounded_formula L_empty 2))

-- TODO : figure out the correct statement of this lemma
-- lemma asjh'' {L} {S : Structure L}  : ∀ {n n' n'' : ℕ} {l} {h : n + n' + 1 = n''} (f : bounded_preformula L n'' l) (t : bounded_term L n') (v : dvector S n'') (xs : dvector S l), (S[((f ↑' 1 # (n+1))[t  // (n+1) // (by {subst h, simp})]).cast_eq (by {subst h, simp}) ;; v ;; xs]) ↔ (S[f.cast (by {subst h, repeat{constructor} }) ;; (v.insert (S[t.cast (by {subst h, linarith}) ;;; v]) (n+1)) ;; xs])
-- :=
-- begin
--   intros,
--   induction f generalizing n n' v,
--     {intros, simp},
--     {sorry},
--     {simp},
--     {sorry},
--     {-- have this_f := f_ih_f₁ xs v t, have this_g := f_ih_f₂ xs v t, simp, simp at this_f this_g, simp*
--     sorry
--     },
--     {rw[subst_all'],
--       }



-- substs h h', have := @subst_all' L (n+1) n' (n + n' + 1 + 1) (by {simp}) t (f_f), simp[this], let k, swap, change realize_bounded_formula v (bounded_preformula.cast_eq k _) _ ↔ _,
-- let j, swap, change realize_bounded_formula v (bounded_preformula.cast_eq k (∀' j)) _ ↔ _,
-- rw[cast_eq_all], dsimp[k,j], clear k j, apply forall_congr, intro x,
--      have := @f_ih xs (n+1) n' ((n+1) + n' + 1) (x::(v.cast (by simp))) (by simp) (by simp) t,
--      rw[cast_eq_trans], rw[dvector_cast_pull_out] at this, swap, simp, swap, simp, simp,
--      rw[realize_bounded_formula_cast_eq_irrel], rw[realize_bounded_formula_cast_eq_irrel] at this, rw[dvector.cast_trans] at this, rw[this], clear this, clear this f_ih,
--      rw[dvector.insert_cons], apply iff_of_eq, congr' 2; simp, 

--  -- congr' 1, simp, swap, {apply cast_eq_hrfl},
--      -- {swap, simp, rw[dvector.insert_cons], simp, rw[dvector.insert_cons], let p, swap,
--      -- let q, swap, change p == q, apply (@heq_iff_eq _ p (q.cast (by simp))).mpr, }
-- }


-- -- congr' 2, simp, simp, {apply realize_bounded_term_irrel', swap, simp, tidy,  },
--      -- {apply dvector.cast_hrfl}, {apply cast_eq_hrfl},
end


-- have := @subst_all' L (n+1) n' (n'' + 1) (by {subst h, simp}) t (f_f.cast_eq (by simp[h'])),ext, simp[-subst_all'] at this, 

-- @[simp]lemma subst_all' {L} {n n' n''} {h : n + n' + 1 = n''} {t : bounded_term L n'} {f : bounded_formula L (n'' + 1)} :
  -- (∀'f)[t  // n // (by {simp[h]})]
  -- = ∀'(f[(t : bounded_term L n') // (n+1) // (by {subst h; simp})]).cast_eq (by simp) := by ext; simp

-- | _ _ _ _ _ _ _ bd_falsum t v xs := by {intros; simp}
-- | _ _ _ _ _ _ _ (t₁ ≃ t₂) t v xs := by {sorry} -- follows from term version
-- | _ _ _ _ _ _ _ (bd_rel R) t v xs := by simp
-- | _ _ _  _ _ _ _ (bd_apprel f s) t v xs := by sorry
-- | _ _ _ n'' l h h' (f ⟹ g) t v xs := by {have this_f := asjh'' f t v xs, have this_g := asjh'' g t v xs, simp[*, -asjh''], simp at this_f this_g, rw[<-this_f,<-this_g]}
-- | n n' n'' n''' l h h' (∀' f) t v xs := begin
-- -- clear asjh'',
-- substs h h',
-- simp,
--         let k, swap, change _ = k, let j, tactic.rotate 1, change realize_bounded_formula v (bounded_preformula.cast_eq _ ∀'j) _ = k, swap, by simp,
--         conv {to_lhs, congr, skip, rw[bounded_preformula.cast_eq_all],}, dsimp[k,j], clear k j,
--         ext, apply forall_congr, intro x, repeat{rw[realize_bounded_formula_cast_eq_irrel]},
--         rw[dvector.cast_trans], rw[<-dvector.insert],
--         swap,
--         have := @asjh'' (n+1) n' (n + n' + 1 + 1) (n + n' + 1 + 1 + 1) 0 (by {simp}) (by refl) f t (x::v) xs, simp at this, 
--       sorry --- might need to lift, actually




-- OK, now it's clear that i simply don't understand how to perform the recursive call on ∀' f.

-- so what's happening is, S[(∀'f)[t // n]] unfolds to S[∀' f[t // (n+1)]],
-- which unfolds to ∀x, realize (x::v) S[f[t // (n+1)]]

-- and the goal is to show that this is all equal to:

-- realize(v.insert S[t // v] (n+1)) (∀' f) = ∀ x, realize (x :: v.insert (S[t // v]) (n+1)) f

-- so it remains to check that

-- realize (x :: v.insert S[t // v] (n+1)) f ↔ realize (x::v) S[f[t // (n+1)]]

-- and this should boil down to the recursive call on the vector itself, right? i.e. this should follow immediately from

-- @asjh'' (n n' (n''+1) (n'''+1)) l (by assumption) (by assumption) f t v xs

--------

        -- subst h, simp,
        -- let k, swap, change _ = k, let j, swap, change realize_bounded_formula v (bounded_preformula.cast_eq _ ∀'j) _ = k, swap, by simp,
        -- conv {to_lhs, congr, skip, rw[bounded_preformula.cast_eq_all],}, dsimp[k,j], clear k j,
        -- ext, apply forall_congr, intro x, simp[realize_bounded_formula_cast_eq_irrel],
        -- let n'' := n + n' + 1,
        -- have h : n + n' + 1 = n'', by refl,
        -- have := asjh'' _ n n' 0 h t -- (subst_bounded_formula f t (by simp)) v xs
        -- -- apply asjh'',
      

-- by {subst h, simp, have := @bounded_preformula.cast_eq_all _ (n + 1 + n') (n + n' + 1) (by simp),
-- let k, swap, change _ = k, show Language, exact L, let j, swap, change realize_bounded_formula v (bounded_preformula.cast_eq _ ∀'j) _ = k, swap, by simp,
-- conv {to_lhs, congr, skip, rw[bounded_preformula.cast_eq_all],}, dsimp[k,j], clear k j,
-- ext, apply forall_congr, intro x,   }


-- @[simp]lemma realize_bounded_term_subst0_gen {L} {S : Structure L} {n l} {s : bounded_preterm L (n+1) l} {v : dvector S n} 

set_option pp.implicit false

-- rw[subst0_bounded_formula_bd_apps_rel], simp[realize_bounded_formula_bd_apps_rel, rel_subst0_irrel]

namespace dvector
section
variable {α : Type*}

@[simp]protected lemma trunc_nth {n m l: ℕ} {h : n ≤ m} {h' : l < n} {v : dvector α m} : (v.trunc h).nth l h' = v.nth l (lt_of_lt_of_le h' h) :=
begin
  induction n generalizing m, cases h',
  by_cases l = n_n, subst h, 
end

protected lemma nth_irrel1 : ∀{n k : ℕ} {h : k < n + 1} {h' : k < n + 1 + 1} (v : dvector α (n+1)) (x : α),
  (x :: (v.trunc (nat.le_succ n))).nth k h = (x::v).nth k h' :=
begin
  sorry
  -- intros, induction n generalizing k v, {have : k = 0, by sorry, subst this, refl},
  -- {by_cases k = nat.succ n_n + 1,
  --    {subst h, refl}

  --   }
end

end
end dvector

@[simp]lemma realize_bounded_term_subst0 {L} {S : Structure L} {n} (s : bounded_term L (n+1)) {v : dvector S n} (t : closed_term L) : realize_bounded_term v (s[(t.cast (by simp)) /0]) [] = realize_bounded_term ((realize_closed_term S t)::v) s [] :=
begin
revert s, refine bounded_term.rec1 _ _,
  {intro k, rcases k with ⟨k_val, k_H⟩, simp,
    induction n generalizing k_val, swap,
    by_cases k_val = n_n + 1,
          {subst h, refl},
          {have : k_val < n_n + 1,
                by {apply nat.lt_of_le_and_ne, exact nat.le_of_lt_succ k_H, exact h},
          have := @n_ih (v.trunc (nat.le_succ n_n)) k_val this,
          rw[dvector.nth_irrel1] at this, swap, dedup, apply nat.lt_of_lt_of_le, exact this,
          exact nat.le_succ (n_n + 1),
          rw[<-this], apply realize_bounded_term_irrel', swap, simp,
          intros, simp only [dvector.trunc_nth]},
    have := zero_of_lt_one k_val (by exact k_H), subst this,
    congr, {apply dvector.zero_eq}, {ext, simp}},
  {intros, simp[subst0_bounded_term_bd_apps,realize_bounded_term_bd_apps, func_subst0_irrel],
  congr' 1, apply dvector.map_congr_pmem, intros x Hx, exact ih_ts x Hx}
end

-- intro k, rcases k with ⟨k_val, k_H⟩, simp,
--     induction n generalizing k_val, have := zero_of_lt_one k_val (by exact k_H), subst this,
--     congr, {apply dvector.zero_eq}, {ext, simp}, cases nat.le_of_lt_succ k_H with H1 H2,
--     swap, repeat{sorry}

-- /-- realization of a subst0 is the realization with the substituted term prepended to the realizing vector --/
lemma realize_bounded_formula_subst0 {L} {S : Structure L} {n} (f : bounded_formula L (n+1)) {v : dvector S n} (t : closed_term L) : realize_bounded_formula v (f[(t.cast0 n) /0]) [] ↔ realize_bounded_formula ((realize_closed_term S t)::v) f [] :=
begin
  revert n f v, refine bounded_formula.rec1 _ _ _ _ _; intros,
  {simp},
  {simp},
  {rw[subst0_bounded_formula_bd_apps_rel], simp[realize_bounded_formula_bd_apps_rel, rel_subst0_irrel]},
  {simp*},
  {simp[-realize_bounded_formula_cast_eq_irrel], apply forall_congr, clear ih, intro x, have := @asjh''0 L S 0 n (n+1) (n+2) 0 (by simp) (by simp) f t (x::v) [], simp at *, exact this}
end

-- lemma HERRO {L} {S : Structure L} : ∀ {n l} {f : bounded_preformula L (n+1) l} {v : dvector S n} {t : closed_term L} {xs : dvector S l}, realize_bounded_formula v (f[t.cast0 n/0]) xs ↔ realize_bounded_formula ((realize_closed_term S t) :: v) f xs
-- | n l (bd_falsum) v t xs := by simp
-- | n l (t₁ ≃ t₂) v t xs := sorry
-- | n l (∀' f) v t xs := by {simp, apply forall_congr, intro x, have := @HERRO (n+2) _ (f.cast (by linarith)) (x::((realize_closed_term S t) :: v)) t xs,}

-- set_option pp.implicit false
-- lemma HEWWO {L} {S : Structure L} {n} {f : bounded_formula L (n+1)} {v : dvector S n} {t : closed_term L} : realize_bounded_formula v (f[t.cast0 n /0]) [] ↔ realize_bounded_formula ((realize_closed_term S t) :: v) f [] :=
-- begin
--   -- unfold subst0_bounded_formula,
--   revert n f v, refine bounded_formula.rec1 _ _ _ _ _; intros,
--   {simp}, {sorry}, {sorry}, {sorry},
--   {rw[subst0_all], apply forall_congr, intro a, simp,
--     have := @ih (a :: v), simp[subst0_all] at this, -- clearly the induction hypothesis here is not strong enough
--    }
-- end

-- -- begin
-- -- dsimp[closed_term, closed_preterm] at t,
-- -- have := @realize_bounded_formula_subst0_gen L S n 0 f v [] (t.cast (by simp)),
-- -- unfold realize_closed_term, rw[<-realize_closed_term_realize_irrel] at this,
-- -- simp at this, split,
-- -- -- rest of this lemma relies on rewriting the bounded_preterm.cast t, after which simp[this] should work
-- -- {intro, apply this.mp, revert a, sorry},
-- -- {sorry},
-- -- end

lemma realize_bounded_formula_subst0' {L} {S : Structure L} {n} (f : bounded_formula L (n+1)) {v : dvector S n} (t : bounded_term L 1) (x : S) : realize_bounded_formula (x :: v) ((f ↑' 1 # 1)[(t.cast (by simp)) /0]) [] ↔ realize_bounded_formula ((realize_bounded_term ([x] : dvector S 1) t []) :: v) f [] := 
begin
revert f n v, refine bounded_formula.rec1 _ _ _ _ _; intros,
  {simp},
  {sorry}, -- this requires a version of this lemma for terms
  {sorry}, -- same issue as the corresponding case above
  {sorry}, -- this one should be easy, just need a lemma about commutation with bd_imp
  {sorry}, -- same issues as the corresponding case above
end

end
end realization

export fol realization

