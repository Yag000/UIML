Require Import ISL.Environments ISL.Sequents ISL.SequentProps ISL.Cut.


Definition obviously_smaller φ ψ :=
  if decide (φ = ⊥) then Lt
  else if decide (ψ = ⊥) then Gt
  else if decide (φ = ⊤) then Gt
  else if decide (ψ = ⊤) then Lt
  else if decide (φ = ψ) then Lt
  else Eq.

Definition simp_or φ ψ := 
match obviously_smaller φ ψ with
  | Lt => ψ
  | Gt => φ
  | Eq => φ ∨ ψ
 end.


Infix "⊻" := simp_or (at level 65).

Definition simp_ors φ ψ :=
match (φ,ψ) with
  |(φ1 ∨ φ2, ψ) => ψ ⊻ (φ1 ∨ φ2)
  |(φ, ψ1 ∨ ψ2) => φ ⊻ (ψ1 ∨ ψ2)
  |(φ, ψ) => φ ⊻ ψ
end.


Definition simp_and φ ψ :=
  if decide (φ =⊥) then ⊥
  else if decide (ψ = ⊥) then ⊥
  else if decide (φ = ⊤) then ψ
  else if decide (ψ = ⊤) then φ
  else if decide (φ = ψ) then φ
  else φ ∧ ψ.


Definition simp_imp φ ψ :=
  if decide (φ = ⊤) then ψ
  else if decide (φ = ⊥) then ⊤
  else if decide (φ = ψ) then ⊤
  else φ → ψ.

Fixpoint simp φ :=
match φ with
  | φ ∨ ψ => simp_ors (simp φ) (simp ψ)
  | φ ∧ ψ => simp_and (simp φ) (simp ψ)
  | φ → ψ => simp_imp (simp φ) (simp ψ)
  | _ => φ
end.


Definition Lindenbaum_Tarski_preorder φ ψ :=
  ∅ • φ ⊢ ψ.

Notation "φ ≼ ψ" := (Lindenbaum_Tarski_preorder φ ψ) (at level 149).

Lemma top_provable Γ :
 Γ ⊢ ⊤.
Proof.
  apply ImpR. apply ExFalso.
Qed.

Lemma preorder_singleton  φ ψ:
  {[φ]} ⊢ ψ -> (φ ≼ ψ).
Proof.
intro H.
assert (H3: (φ ≼ ψ) = ({[φ]} ⊢ ψ)) by (apply proper_Provable; ms).
rewrite H3.
apply H.
Qed.

Corollary cut2 φ ψ θ:
  (φ ≼ ψ) -> (ψ ≼ θ) ->
  φ ≼ θ.
Proof.
  intros H1 H2.
  assert ({[φ]} ⊎ ∅ ⊢ θ). {
  peapply (cut  {[φ]} ∅ ψ θ).
  - peapply H1.
  - apply H2.
  }
  apply H.
Qed.

Lemma obviously_smaller_compatible_LT φ ψ :
  obviously_smaller φ ψ = Lt -> φ ≼ ψ.
Proof.
intro H.
unfold obviously_smaller in H.
case decide in H.
- rewrite e. apply ExFalso.
- case decide in H.
  + contradict H; auto.
  + case decide in H.
    * contradict H; auto.
    * case decide in H.
      -- rewrite e. apply top_provable.
      -- case decide in H.
         ++ rewrite e; apply generalised_axiom.
         ++ contradict H; auto.
Qed.


Lemma obviously_smaller_compatible_GT φ ψ :
  obviously_smaller φ ψ = Gt -> ψ ≼ φ .
Proof.
intro H.
unfold obviously_smaller in H.
case decide in H.
- contradict H; auto.
- case decide in H.
  + rewrite e. apply ExFalso.
  + case decide in H.
    * rewrite e. apply top_provable.
    * case decide in H.
      -- contradict H; auto.
      -- case decide in H; contradict H; auto.
Qed.

Lemma or_congruence φ ψ φ' ψ':
  (φ ≼ φ') -> (ψ ≼ ψ') ->
  (φ ∨ ψ) ≼ φ' ∨ ψ'.
Proof.
intros Hφ Hψ.
apply OrL.
- apply OrR1; apply Hφ. 
- apply OrR2; apply Hψ. 
Qed.


Lemma or_comm φ ψ:
  φ ∨ ψ ≼  ψ ∨ φ.
Proof.
apply OrL; [apply OrR2 | apply OrR1]; apply generalised_axiom.
Qed.


Lemma or_assoc_L φ ψ ϴ :
  (φ ∨ (ψ ∨ ϴ)  ≼ (φ ∨ ψ) ∨ ϴ).
Proof.
  apply OrL.
  - apply OrR1; apply OrR1; apply generalised_axiom.
  - apply OrL.
    + apply OrR1; apply OrR2; apply generalised_axiom.
    + apply OrR2; apply generalised_axiom.
Qed.


Lemma or_assoc_R φ ψ ϴ :
  ((φ ∨ ψ) ∨ ϴ  ≼ φ ∨ (ψ ∨ ϴ)).
Proof.
  apply OrL.
  - apply OrL.
    + apply OrR1; apply generalised_axiom.
    + apply OrR2; apply OrR1; apply generalised_axiom.
  - apply OrR2; apply OrR2; apply generalised_axiom.
Qed.

Lemma simp_or_equiv_L φ ψ φ' ψ' : 
  (φ ≼ φ') -> (ψ ≼ ψ') ->
  (φ ∨ ψ) ≼ simp_or φ' ψ'.
Proof.
intros Hφ Hψ.
unfold simp_or.
case (decide (obviously_smaller φ' ψ' = Lt)); [intro HLt | intro Hneq1].
- rewrite HLt. apply OrL.
  + eapply cut2. 
    * apply Hφ.
    * apply obviously_smaller_compatible_LT; assumption.
  + assumption.
- case (decide (obviously_smaller φ' ψ' = Gt)); [intro HGt| intro Hneq2].
  + rewrite HGt. apply OrL.
    * assumption.
    * eapply cut2.
      -- eapply cut2.
         ++ apply Hψ.
         ++ apply obviously_smaller_compatible_GT. apply HGt.
      -- apply generalised_axiom.
  + case (decide (obviously_smaller φ' ψ' = Eq)); [intro HEq| intro Hneq3].
    * rewrite HEq. apply or_congruence; [apply Hφ | apply Hψ].
    * destruct (obviously_smaller φ' ψ'); [contradict Hneq3 | contradict Hneq1 |contradict Hneq2]; trivial.
Qed.



Lemma simp_or_equiv_R φ ψ φ' ψ' : 
  (φ' ≼ φ) -> (ψ' ≼ ψ) ->
  simp_or φ' ψ' ≼  φ ∨ ψ.
Proof.
intros Hφ Hψ.
unfold simp_or.
case (decide (obviously_smaller φ' ψ' = Lt)); [intro HLt | intro Hneq1].
- rewrite HLt. apply OrR2; assumption.
- case (decide (obviously_smaller φ' ψ' = Gt)); [intro HGt| intro Hneq2].
  + rewrite HGt. apply OrR1; assumption.
  + case (decide (obviously_smaller φ' ψ' = Eq)); [intro HEq| intro Hneq3].
    * rewrite HEq. apply or_congruence; [apply Hφ | apply Hψ].
    * destruct (obviously_smaller φ' ψ'); [contradict Hneq3 | contradict Hneq1 |contradict Hneq2]; trivial.
Qed.



Lemma simp_or_assoc_L φ ψ ϴ :
  (φ ⊻ (ψ ⊻ ϴ)  ≼ (φ ⊻  ψ) ⊻ ϴ).
Proof.
  apply (cut2 _ (φ ∨ (ψ ∨ ϴ)) _).
  - apply simp_or_equiv_R.
    + apply generalised_axiom.
    + apply simp_or_equiv_R; apply generalised_axiom.
  -apply (cut2 _ ((φ ∨ ψ) ∨ ϴ) _).
    + apply or_assoc_L.
    + apply simp_or_equiv_L.
      * apply simp_or_equiv_L; apply generalised_axiom.
      * apply generalised_axiom.
Qed.


Lemma simp_or_assoc_R φ ψ ϴ :
  ((φ ⊻ ψ) ⊻ ϴ  ≼ φ ⊻  (ψ ⊻ ϴ)).
Proof.
  apply (cut2 _ ((φ ∨ ψ) ∨ ϴ) _).
  - apply simp_or_equiv_R.
    + apply simp_or_equiv_R; apply generalised_axiom.
    + apply generalised_axiom.
  -apply (cut2 _ (φ ∨ (ψ ∨ ϴ)) _).
    + apply or_assoc_R.
    + apply simp_or_equiv_L.
      * apply generalised_axiom.
      * apply simp_or_equiv_L; apply generalised_axiom.
Qed.

Lemma simp_or_assoc_ctx_R_R  a φ ψ ϴ :
  (a ≼ (φ ⊻ ψ) ⊻ ϴ)  -> a ≼ φ ⊻ (ψ ⊻ ϴ). 
Proof.
  intro H.
  eapply cut2.
  apply H.
  apply simp_or_assoc_R.
Qed.


Lemma simp_or_assoc_ctx_L_R  a φ ψ ϴ :
  (a ≼ φ ⊻ (ψ ⊻ ϴ))  -> a ≼ (φ ⊻ ψ) ⊻ ϴ. 
Proof.
  intro H.
  eapply cut2.
  apply H.
  apply simp_or_assoc_L.
Qed.


Lemma simp_or_assoc_ctx_R_L  a φ ψ ϴ :
  ((φ ⊻ ψ) ⊻ ϴ ≼ a)  -> φ ⊻ (ψ ⊻ ϴ) ≼ a.
Proof.
  intro H.
  eapply cut2.
  apply simp_or_assoc_L.
  apply H.
Qed.


Lemma simp_or_assoc_ctx_L_L  a φ ψ ϴ :
  (φ ⊻ (ψ ⊻ ϴ) ≼ a)  -> (φ ⊻ ψ) ⊻ ϴ ≼ a.
Proof.
  intro H.
  eapply cut2.
  apply simp_or_assoc_R.
  apply H.
Qed.



Lemma simp_or_comm φ ψ :
  (φ ⊻ ψ) ≼ (ψ ⊻  φ).
Proof.
  apply (cut2 _ (φ ∨ ψ) _).
  - apply simp_or_equiv_R; apply generalised_axiom.
  - apply (cut2 _ (ψ ∨ φ) _).
    + apply or_comm.
    + apply simp_or_equiv_L; apply generalised_axiom.
Qed.




Lemma simp_or_comm_ctx_R  a φ ψ :
  (a ≼ φ ⊻ ψ)  -> a ≼ ψ ⊻ φ.
Proof.
  intro H.
  eapply cut2.
  apply H.
  apply simp_or_comm.
Qed.



Lemma simp_or_comm_ctx_L  a φ ψ :
  (φ ⊻ ψ ≼ a)  ->  ψ ⊻ φ ≼ a.
Proof.
  intro H.
  eapply cut2.
  apply simp_or_comm.
  apply H.
Qed.



Lemma simp_ors_equiv_L φ ψ φ' ψ':
  (φ ≼ φ') -> (ψ ≼ ψ') ->
  (φ ∨ ψ) ≼ simp_ors φ' ψ'.
Proof.
intros Hφ Hψ.
destruct φ';
simpl; destruct ψ';
try (eapply simp_or_equiv_L; assumption);
apply simp_or_comm_ctx_R; (apply simp_or_equiv_L; assumption).
Qed.

Lemma simp_equiv_or_L φ ψ : 
  (φ  ≼ simp φ) -> (ψ  ≼ simp ψ) ->
  (φ ∨ ψ) ≼ simp (φ ∨ ψ).
Proof.
intros Hφ Hψ.
apply simp_ors_equiv_L; [apply Hφ | apply Hψ].
Qed.



Lemma simp_ors_equiv_R φ ψ φ' ψ':
  (φ' ≼ φ) -> (ψ' ≼ ψ ) ->
  simp_ors φ' ψ' ≼ φ ∨ ψ.
Proof.
intros Hφ Hψ.
destruct φ';
destruct ψ';
try (eapply simp_or_equiv_R; assumption);
apply simp_or_comm_ctx_L; (apply simp_or_equiv_R; assumption).
Qed.

Lemma simp_equiv_or_R φ ψ: 
  (simp φ ≼ φ) -> (simp ψ ≼ ψ) ->
  simp (φ ∨ ψ) ≼ (φ ∨ ψ).
Proof.
intros Hφ Hψ.
apply simp_ors_equiv_R; [apply Hφ | apply Hψ].
Qed.

Lemma simp_equiv_or φ ψ: 
  (φ ≼ simp φ) * (simp φ ≼ φ) ->
  (ψ ≼ simp ψ) * (simp ψ ≼ ψ) ->
  ((φ ∨ ψ) ≼ simp (φ ∨ ψ)) * (simp (φ ∨ ψ) ≼ (φ ∨ ψ)).
Proof.
intros IHφ IHψ.
split; [ apply simp_equiv_or_L | apply simp_equiv_or_R]; try apply IHφ ; try apply IHψ.
Qed.


Lemma simp_equiv_and_L φ ψ : 
  (φ  ≼ simp φ) -> (ψ  ≼ simp ψ) ->
  (φ ∧ ψ) ≼ simp (φ ∧ ψ).
Proof.
intros Hφ Hψ.
simpl. unfold simp_and. 
case decide as [Hbot |].
- rewrite Hbot in Hφ.
  apply AndL. apply weakening.
  apply exfalso. apply Hφ.
- case decide as [Hbot |].
  + rewrite Hbot in Hψ.
    apply AndL. exch 0. apply weakening.
    apply Hψ.
  + case decide as [].
    * apply AndL.
      exch 0. apply weakening.
      apply Hψ.
    * case decide as [].
      -- apply AndL.
         apply weakening.
         apply Hφ.
      -- apply AndL.
         case decide as [].
         ++ apply weakening.
            apply Hφ.
         ++ apply AndR.
            ** apply weakening.
               apply Hφ.
            ** exch 0. apply weakening.
               apply Hψ.
Qed.


Lemma simp_equiv_and_R φ ψ : 
  (simp φ ≼ φ) -> (simp ψ ≼ ψ) ->
  simp (φ ∧ ψ) ≼  φ ∧ ψ.
Proof.
intros Hφ Hψ.
simpl. unfold simp_and. 
case decide as [].
- apply exfalso. apply ExFalso.
- case decide as [].
  + apply exfalso. apply ExFalso.
  + case decide as [Htop |].
    * apply AndR.
      -- rewrite Htop in Hφ.
         apply weakening.
         eapply TopL_rev.
         apply Hφ.
      -- apply Hψ.
    * case decide as [Htop |].
      -- apply AndR. 
         ++ apply Hφ.
         ++ rewrite Htop in Hψ.
            apply weakening.
            eapply TopL_rev.
            apply Hψ.
      -- case decide as [ Heq | Hneq].
         ++ apply AndR; [ apply Hφ| rewrite Heq ; apply Hψ].
         ++ apply AndL.
            apply AndR; [|exch 0]; apply weakening; [apply Hφ | apply Hψ].
Qed.

Lemma simp_equiv_and φ ψ: 
  (φ ≼ simp φ) * (simp φ ≼ φ) ->
  (ψ ≼ simp ψ) * (simp ψ ≼ ψ) ->
  ((φ ∧ ψ) ≼ simp (φ ∧ ψ)) * (simp (φ ∧ ψ) ≼ (φ ∧ ψ)).
Proof.
intros IHφ IHψ.
split; [ apply simp_equiv_and_L | apply simp_equiv_and_R]; try apply IHφ ; try apply IHψ.
Qed.


Lemma simp_equiv_imp_L φ ψ : 
  (simp φ ≼ φ) ->
  (ψ ≼ simp ψ) ->
  (φ → ψ) ≼ simp (φ → ψ).
Proof.
intros HφR HψL.
simpl. unfold simp_imp. 
case decide as [Htop |].
-  rewrite Htop in HφR.
  apply weak_ImpL.
  + eapply TopL_rev. 
    apply HφR.
  + apply HψL.
- case decide as [].
  + apply weakening.
    apply top_provable.
  + case decide as [].
    * apply ImpR.
      apply ExFalso.
    * apply ImpR.
      exch 0.
      apply ImpL.
      -- apply weakening. apply HφR.
      -- exch 0. apply weakening.
         apply HψL.
Qed.

Lemma simp_equiv_imp_R φ ψ : 
  (φ ≼ simp φ) ->
  (simp ψ ≼ ψ) ->
  simp (φ → ψ) ≼ (φ → ψ).
Proof.
intros HφL HψR.
simpl. unfold simp_imp.
case decide as [Htop |].
- apply ImpR. 
  apply weakening.
  apply HψR.
- case decide as [Htop |].
  + rewrite Htop in HφL.
    apply ImpR.
    apply exfalso.
    exch 0. apply weakening.
    apply HφL.
  + case decide as [Heq |].
    * apply ImpR.
      exch 0. apply weakening.
      rewrite <- Heq in HψR.
      eapply cut2.
      -- apply HφL.
      -- apply HψR.
    * apply ImpR.
      exch 0.
      apply ImpL.
      
      -- apply weakening. apply HφL.
      -- exch 0. apply weakening.
         apply HψR.
Qed.

Lemma simp_equiv_imp φ ψ: 
  (φ ≼ simp φ) * (simp φ ≼ φ) ->
  (ψ ≼ simp ψ) * (simp ψ ≼ ψ) ->
  ((φ → ψ) ≼ simp (φ → ψ)) * (simp (φ → ψ) ≼ (φ → ψ)).
Proof.
intros IHφ IHψ.
split; [ apply simp_equiv_imp_L | apply simp_equiv_imp_R]; try apply IHφ ; try apply IHψ.
Qed.

Theorem simp_equiv φ : 
  (φ ≼ (simp φ)) * ((simp φ) ≼ φ).
Proof.
remember (weight φ) as w.
assert(Hle : weight φ  ≤ w) by lia.
clear Heqw. revert φ Hle.
induction w; intros φ Hle; [destruct φ ; simpl in Hle; lia|].
destruct φ; simpl; try (split ; apply generalised_axiom); 
[eapply (simp_equiv_and φ1  φ2)|
 eapply (simp_equiv_or φ1  φ2)|
eapply (simp_equiv_imp φ1  φ2)]; apply IHw;
[assert (Hφ1w: weight φ1 < weight (φ1 ∧ φ2))|
assert (Hφ1w: weight φ2 < weight (φ1 ∧ φ2))|
assert (Hφ1w: weight φ1 < weight (φ1 ∨ φ2))|
assert (Hφ1w: weight φ2 < weight (φ1 ∨ φ2))|
assert (Hφ1w: weight φ1 < weight (φ1 → φ2))|
assert (Hφ1w: weight φ2 < weight (φ1 → φ2))]; simpl; lia.
Qed.

Require Import ISL.PropQuantifiers.

Definition E_simplified (p: variable) (ψ: form) := simp (Ef p ψ).
Definition A_simplified (p: variable) (ψ: form) := simp (Af p ψ).

Lemma bot_vars_incl V:
vars_incl ⊥ V.
Proof.
  intros x H.
  unfold In.
  induction V; auto.
Qed.


Lemma top_vars_incl V:
vars_incl ⊤ V.
Proof.
  intros x H.
  unfold In.
  induction V. 
  - simpl in H. tauto.
  - auto.
Qed.

Lemma and_vars_incl_L φ ψ V:
  vars_incl (And φ ψ) V ->
  vars_incl φ V * vars_incl ψ V.
Proof.
  intros H.
  split; intros x H1; apply H; simpl; auto.
Qed.


Lemma or_vars_incl_L φ ψ V:
  vars_incl (Or φ ψ) V ->
  vars_incl φ V * vars_incl ψ V.
Proof.
  intros H.
  split; intros x H1; apply H; simpl; auto.
Qed.


Lemma and_vars_incl_R φ ψ V:
  vars_incl φ V ->
  vars_incl ψ V ->
  vars_incl (And φ ψ) V.
Proof.
  unfold vars_incl.
  simpl.
  intuition.
Qed.


Lemma or_vars_incl_R φ ψ V:
  vars_incl φ V ->
  vars_incl ψ V ->
  vars_incl (Or φ ψ) V.
Proof.
  unfold vars_incl.
  simpl.
  intuition.
Qed.

Lemma vars_incl_simp_or_equiv_or φ ψ V:
  vars_incl (Or φ ψ) V ->
  vars_incl (simp_or φ ψ) V.
Proof.
intro H.
unfold simp_or. 
apply or_vars_incl_L in H.
case (decide (obviously_smaller φ ψ = Lt)); [intro HLt | intro Hneq1].
- rewrite HLt; apply H.
- case (decide (obviously_smaller φ ψ = Gt)); [intro HGt| intro Hneq2].
  + rewrite HGt; apply H.
  + case (decide (obviously_smaller φ ψ = Eq)); [intro HEq| intro Hneq3].
    * rewrite HEq. apply or_vars_incl_R; apply H.
    * destruct (obviously_smaller φ ψ); [contradict Hneq3 | contradict Hneq1 |contradict Hneq2]; trivial.
Qed.

Lemma vars_incl_simp_or φ ψ V :
  vars_incl φ V -> vars_incl ψ V ->
  vars_incl (φ ⊻ ψ) V.
Proof.
intros Hφ Hψ.
unfold simp_or. 
case (decide (obviously_smaller φ ψ = Lt)); [intro HLt | intro Hneq1].
- now rewrite HLt.
- case (decide (obviously_smaller φ ψ = Gt)); [intro HGt| intro Hneq2].
  + now rewrite HGt.
  + case (decide (obviously_smaller φ ψ = Eq)); [intro HEq| intro Hneq3].
    * rewrite HEq. apply or_vars_incl_R; assumption.
    * destruct (obviously_smaller φ ψ); [contradict Hneq3 | contradict Hneq1 |contradict Hneq2]; trivial.
Qed.



Lemma vars_incl_simp_or_assoc φ ψ ϴ V :
  vars_incl (Or φ (Or ψ ϴ)) V ->
  vars_incl (Or (Or φ  ψ)  ϴ) V.
Proof.
intro H.
unfold vars_incl.
intros x H2.
simpl in H2.
apply or_assoc in H2.
apply H.
simpl.
apply H2.
Qed.



Lemma vars_incl_simp_ors φ ψ V :
  vars_incl φ V -> vars_incl ψ V ->
  vars_incl (simp_ors φ ψ) V.
Proof.
intros Hφ Hψ.
destruct φ; 
try (
  simpl; destruct ψ; 
  (apply vars_incl_simp_or; try assumption; apply vars_incl_simp_or_equiv_or; assumption)
).
Qed.


Lemma vars_incl_simp φ V :
  vars_incl φ V -> vars_incl (simp φ) V.
Proof.
intro H.
induction φ; auto.
- simpl. unfold simp_and. 
  case decide as [].
  + apply bot_vars_incl.
  + case decide as [].
    * apply bot_vars_incl.
    * case decide as [].
      --  apply IHφ2.
          eapply and_vars_incl_L.
          apply H.
      -- case decide as [].
         ++ apply IHφ1.
            apply (and_vars_incl_L _  φ2).
            apply H.
         ++ case decide as [].
            ** apply IHφ1.
               apply (and_vars_incl_L _  φ2).
               apply H.
            ** apply and_vars_incl_R; 
               [ apply IHφ1; apply (and_vars_incl_L _  φ2)|
                  apply IHφ2; eapply and_vars_incl_L];
               apply H.
- simpl. unfold simp_or. 
  apply vars_incl_simp_ors;
  [ apply IHφ1; apply (or_vars_incl_L _  φ2)|
  apply IHφ2; apply (or_vars_incl_L  φ1 _) ];
  assumption.
- simpl. unfold simp_imp. 
  case decide as [].
  + apply IHφ2.
    eapply and_vars_incl_L.
    apply H.
  + case decide as [].
    * apply top_vars_incl.
    * case decide as [].
      -- apply top_vars_incl.
      -- apply and_vars_incl_R;
        [ apply IHφ1; apply (and_vars_incl_L _  φ2)|
          apply IHφ2; eapply and_vars_incl_L];
          apply H.
Qed.

Theorem iSL_uniform_interpolation_simp p V: p ∉ V ->
  ∀ φ, vars_incl φ (p :: V) ->
    (vars_incl (E_simplified p φ) V)
  * (φ ≼ E_simplified p φ)
  * (∀ ψ, vars_incl ψ V -> (φ ≼ ψ) -> E_simplified p φ ≼ ψ)
  * (vars_incl (A_simplified p φ) V)
  * (A_simplified p φ ≼ φ)
  * (∀ θ, vars_incl θ V -> (θ ≼ φ) -> (θ ≼ A_simplified p φ)).
Proof.
intros Hp φ Hvarsφ.
assert (Hislφ : 
    (vars_incl (Ef p φ) V)
  * ({[φ]} ⊢ (Ef p φ))
  * (∀ ψ, vars_incl ψ V -> {[φ]} ⊢ ψ -> {[Ef p φ]} ⊢ ψ)
  * (vars_incl (Af p φ) V)
  * ({[Af p φ]} ⊢ φ)
  * (∀ θ, vars_incl θ V -> {[θ]} ⊢ φ -> {[θ]} ⊢ Af p φ)) by 
    (apply iSL_uniform_interpolation; [apply Hp | apply Hvarsφ]).
repeat split.
  + intros Hx.
    eapply vars_incl_simp.
    apply Hislφ.
  + eapply cut2.
    * assert (Hef: ({[φ]} ⊢ Ef p φ)) by apply Hislφ.
      apply preorder_singleton.
      apply Hef.
    * apply (simp_equiv  (Ef p φ)).
  + intros ψ Hψ Hyp.
    eapply cut2.
    * apply (simp_equiv  (Ef p φ)).
    * assert (Hef: ({[Ef p φ]} ⊢ ψ)) by (apply Hislφ; [apply Hψ | peapply Hyp]).
      apply preorder_singleton.
      apply Hef.
  + intros Hx.
    eapply vars_incl_simp.
    apply Hislφ.
  + eapply cut2.
    * apply (simp_equiv  (Af p φ)).
    * apply preorder_singleton.
      apply Hislφ.
  + intros ψ Hψ Hyp.
    eapply cut2.
    * assert (Hef: ({[ψ]} ⊢ Af p φ)) by (apply Hislφ; [apply Hψ | peapply Hyp]).
      apply preorder_singleton.
      apply Hef.
    * apply (simp_equiv  (Af p φ)).
Qed.

Require Import String.
Local Open Scope string_scope.

Example ex1: simp (Implies (Var "a")  (And (Var "b") (Var "b" ))) = Implies (Var "a")  (Var "b").
Proof. reflexivity. Qed.


Example ex2: simp (Implies (Var "a")  (Or (Var "b") (Var "b" ))) = Implies (Var "a")  (Var "b").
Proof. reflexivity. Qed.


Example ex3: simp (Implies (Var "a")  (Var "a")) = Implies Bot Bot.
Proof. reflexivity. Qed.


Example ex4: simp (Or (Implies (Var "a")  (Var "a")) (Implies (Var "a")  (Var "a"))) = Implies Bot Bot.
Proof. reflexivity. Qed.

Example ex5: simp (And (Implies (Var "a")  (Var "a")) (Implies (Var "a")  (Var "a"))) = Implies Bot Bot.
Proof. reflexivity. Qed.
