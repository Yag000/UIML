Require Import ISL.Environments ISL.Sequents ISL.SequentProps ISL.Cut.

Definition Lindenbaum_Tarski_preorder φ ψ :=
  ∅ • φ ⊢ ψ.

Notation "φ ≼ ψ" := (Lindenbaum_Tarski_preorder φ ψ) (at level 150).

Corollary weak_cut φ ψ θ:
  (φ ≼ ψ) -> (ψ ≼ θ) ->
  φ ≼ θ.
Proof.
intros H1 H2.
eapply additive_cut.
- apply H1.
- exch 0. apply weakening. apply H2.
Qed.


Lemma top_provable Γ :
 Γ ⊢ ⊤.
Proof.
  apply ImpR. apply ExFalso.
Qed.


(* Some tactics for the obviously_smaller proofs. *)

(* Solve goals involving the equality decision at the end of the match *)
Ltac eq_clean := match goal with 
| H : (if decide (?f1 = ?f2) then ?t else Eq) = ?t |- _ => 
    case decide in H;
    match goal with
    | e : ?f1 = ?f2 |- _ => rewrite e; apply generalised_axiom
    | _ => discriminate
    end
| H : (if decide (?f1 = ?f2) then Lt else Eq) = Gt |- _ => 
    case decide in H; discriminate
end.


(* Solve goals that involve directly using ExFalso *)
Ltac bot_clean  := match goal with
| [ |- Bot ≼ _] => apply ExFalso
| [ |- _ ≼ Bot  → _ ] => apply ImpR; apply ExFalso
| _ => idtac
end.

(* Solve induction goals *)
Ltac induction_auto := match goal with
| IH : obviously_smaller ?f ?f2 = Lt → ?f ≼ ?f2 , H :  obviously_smaller ?f ?f2 = Lt |- (∅ • ?f) ⊢ ?f2 => 
    apply IH; assumption
| IH : obviously_smaller ?f ?f2 = Gt → ?f2 ≼ ?f , H :  obviously_smaller ?f ?f2 = Gt |- (∅ • ?f2) ⊢ ?f => 
    apply IH; assumption

| IH : obviously_smaller ?f _ = Lt → ?f ≼ _ , H :  obviously_smaller ?f _ = Lt |- ?f ∧ _ ≼ _ => 
    apply AndL; apply weakening; apply IH; assumption
| IH : obviously_smaller ?f _ = Lt → ?f ≼ _ , H :  obviously_smaller ?f _ = Lt |- _ ∧ ?f ≼ _ =>
    apply AndL; exch 0; apply weakening; apply IH; assumption

| IH : obviously_smaller ?f _ = Gt → _ ≼ ?f , H :  obviously_smaller ?f _ = Gt |- _ ≼ ?f ∨ _ => 
    apply OrR1;  apply IH; assumption
| IH : obviously_smaller ?f _ = Gt → _ ≼ ?f , H :  obviously_smaller ?f _ = Gt |- _ ≼ _ ∨ ?f => 
    apply OrR2;  apply IH; assumption
| _ => idtac
end.

Lemma obviously_smaller_compatible_LT φ ψ :
  obviously_smaller φ ψ = Lt -> φ ≼ ψ.
Proof.
intro H.
induction φ; destruct ψ; 
try (unfold obviously_smaller in H; try discriminate;  eq_clean); bot_clean; 
repeat match goal with
  | [ H : obviously_smaller _ (?f → _) = Lt |- _ ≼ ?f → _ ] => 
      destruct f; simpl in H; try discriminate; bot_clean
  | |- _ ∧ _ ≼ ?f =>
    case_eq (obviously_smaller φ1 f); case_eq (obviously_smaller φ2 f); intros H0 H1; 
    simpl in H; rewrite H0 in H; rewrite H1 in H; try discriminate; induction_auto
  | |- _ ∨ _ ≼ ?f =>
    case_eq (obviously_smaller φ1 f); case_eq (obviously_smaller φ2 f); intros H0 H1; 
    simpl in H; rewrite H0 in H; rewrite H1 in H; try discriminate;
    apply OrL; induction_auto
  | |- (?f → _) ≼ _ => destruct f; try eq_clean; discriminate
end. 
Qed.


Lemma obviously_smaller_compatible_GT φ ψ :
  obviously_smaller φ ψ = Gt -> ψ ≼ φ .
Proof.
intro H.
induction φ; destruct ψ; 
try (unfold obviously_smaller in H; try discriminate; eq_clean); bot_clean;
repeat match goal with
  | |-  ?f ≼ _ ∧ _ =>
    case_eq (obviously_smaller φ1 f); case_eq (obviously_smaller φ2 f); intros H0 H1; 
    simpl in H; rewrite H0 in H; rewrite H1 in H; try discriminate; apply AndR; induction_auto
  | |- ?f ≼ _∨ _  =>
    case_eq (obviously_smaller φ1 f); case_eq (obviously_smaller φ2 f); intros H0 H1; 
    simpl in H; rewrite H0 in H; rewrite H1 in H; try discriminate; induction_auto
  | |- (?f1 → _) ≼ ?f2 → _ =>
    simpl in H; destruct f1; destruct f2; bot_clean; try eq_clean; discriminate
  | |- (?f → _) ≼ _ => destruct f; discriminate
  | |- (∅ • (?f → _)) ⊢ _ => destruct f; discriminate
  | |- _ ≼ (?f → _) => destruct f; bot_clean; discriminate
end.
Qed.


Lemma and_congruence φ ψ φ' ψ':
  (φ ≼ φ') -> (ψ ≼ ψ') -> (φ ∧ ψ) ≼ φ' ∧ ψ'.
Proof.
intros Hφ Hψ.
apply AndL.
apply AndR.
- apply weakening. apply Hφ. 
- exch 0. apply weakening. apply Hψ. 
Qed.



Lemma choose_conj_equiv_L φ ψ φ' ψ':
  (φ ≼ φ') -> (ψ ≼ ψ') -> (φ ∧ ψ) ≼ choose_conj φ' ψ'.
Proof.
intros Hφ Hψ.
unfold choose_conj.
case_eq (obviously_smaller φ' ψ'); intro Heq.
- apply and_congruence; assumption.
- apply AndL, weakening, Hφ.
- apply AndL. exch 0. apply weakening, Hψ.
Qed.


Lemma choose_and_equiv_R φ ψ φ' ψ':
  (φ' ≼ φ) -> (ψ' ≼ ψ) -> choose_conj φ' ψ' ≼  φ ∧ ψ.
Proof.
intros Hφ Hψ.
unfold choose_conj.
case_eq (obviously_smaller φ' ψ'); intro Heq.
- apply and_congruence; assumption.
- apply AndR.
  + assumption.
  + eapply weak_cut.
    * apply obviously_smaller_compatible_LT, Heq.
    * assumption.
- apply AndR.
  + eapply weak_cut.
    * apply obviously_smaller_compatible_GT, Heq.
    * assumption.
  + assumption.
Qed.


Lemma make_conj_equiv_L φ ψ φ' ψ' : 
  (φ ≼ φ') -> (ψ ≼ ψ') -> (φ ∧ ψ) ≼ φ' ⊼ ψ'.
Proof.
intros Hφ Hψ.
unfold make_conj.
destruct ψ'; try (apply choose_conj_equiv_L; assumption).
- case_eq (obviously_smaller φ' ψ'1); intro Heq.
  + apply and_congruence; assumption.
  + apply and_congruence.
    * assumption.
    * apply AndR_rev in Hψ; apply Hψ.
  + apply AndL. exch 0. apply weakening. assumption.
- case (decide (obviously_smaller φ' ψ'1 = Lt)); intro.
  + apply AndL. now apply weakening.
  + apply and_congruence; assumption.
Qed.

Lemma make_conj_equiv_R φ ψ φ' ψ' : 
  (φ' ≼ φ) -> (ψ' ≼ ψ) -> φ' ⊼ ψ' ≼  φ ∧ ψ.
Proof.
intros Hφ Hψ.
unfold make_conj.
destruct  ψ'.
- apply choose_and_equiv_R; assumption.
- apply choose_and_equiv_R; assumption.
- case_eq (obviously_smaller φ' ψ'1); intro Heq.
  + apply and_congruence; assumption.
  + apply AndR.
    * apply AndL. apply weakening; assumption.
    * apply (weak_cut _ ( ψ'1 ∧ ψ'2) _).
      -- apply and_congruence; 
         [now apply obviously_smaller_compatible_LT | apply generalised_axiom].
      -- assumption.
  + apply AndR.
    * apply AndL. apply weakening. eapply weak_cut.
      -- apply obviously_smaller_compatible_GT; apply Heq.
      -- assumption.
    * assumption.
- case (decide (obviously_smaller φ' ψ'1 = Lt)); [intro HLt | intro Hneq].
  + apply AndR.
    * assumption.
    * eapply weak_cut.
      -- apply obviously_smaller_compatible_LT; apply HLt.
      -- apply OrL_rev in Hψ; apply Hψ.
  + apply and_congruence; assumption.
- apply choose_and_equiv_R; assumption.
- apply choose_and_equiv_R; assumption.
Qed.

Lemma specialised_weakening Γ φ ψ : (φ ≼ ψ) ->  Γ•φ ⊢ ψ.
Proof.
intro H. 
apply generalised_weakeningL.
peapply H.
Qed.

Lemma make_conj_sound_L Γ φ ψ θ : Γ•φ ∧ψ ⊢ θ -> Γ• φ ⊼ ψ ⊢ θ.
Proof.
intro H.
eapply additive_cut.
- apply specialised_weakening.
  apply make_conj_equiv_R; apply generalised_axiom.
- exch 0. apply weakening. assumption.
Qed.

Global Hint Resolve make_conj_sound_L : proof.

Lemma make_conj_complete_L Γ φ ψ θ : Γ• φ ⊼ ψ ⊢ θ -> Γ•φ ∧ψ ⊢ θ.
Proof.
intro H.
eapply additive_cut.
- apply specialised_weakening.
  apply make_conj_equiv_L; apply generalised_axiom.
- exch 0. apply weakening. assumption.
Qed.

Lemma make_conj_sound_R Γ φ ψ : Γ  ⊢ φ ∧ψ -> Γ ⊢ φ ⊼ ψ.
Proof.
intro H.
eapply additive_cut.
- apply H.
- apply make_conj_complete_L. apply generalised_axiom.
Qed.

Global Hint Resolve make_conj_sound_R : proof.

Lemma make_conj_complete_R Γ φ ψ : Γ  ⊢ φ ⊼ ψ -> Γ  ⊢ φ ∧ψ.
Proof.
intro H.
eapply additive_cut.
- apply H.
- apply make_conj_sound_L. apply generalised_axiom.
Qed.


(** ** Generalized AndR *)

Lemma conjunction_R1 Γ Δ : (forall φ, φ ∈ Δ -> Γ  ⊢ φ) -> (Γ  ⊢ ⋀ Δ).
Proof.
intro Hprov. unfold conjunction.
assert(Hcut : forall θ, Γ ⊢ θ -> Γ ⊢ foldl make_conj θ (nodup form_eq_dec Δ)).
{
  induction Δ; intros θ Hθ; simpl; trivial.
  case in_dec; intro; auto with *.
  apply IHΔ.
  - intros; apply Hprov. now right.
  - apply make_conj_sound_R, AndR; trivial. apply Hprov. now left.
}
apply Hcut. apply ImpR, ExFalso.
Qed.

(** ** Generalized invertibility of AndR *)

Lemma conjunction_R2 Γ Δ : (Γ  ⊢ ⋀ Δ) -> (forall φ, φ ∈ Δ -> Γ  ⊢ φ).
Proof.
 unfold conjunction.
assert(Hcut : forall θ, Γ ⊢ foldl make_conj θ (nodup form_eq_dec Δ) -> (Γ ⊢ θ) * (forall φ, φ ∈ Δ -> Γ  ⊢ φ)).
{
  induction Δ; simpl; intros θ Hθ.
  - split; trivial. intros φ Hin; contradict Hin. auto with *.
  - case in_dec in Hθ; destruct (IHΔ _ Hθ) as (Hθ' & Hi);
     try (apply make_conj_complete_R in Hθ'; destruct (AndR_rev Hθ')); split; trivial;
     intros φ Hin; apply elem_of_cons in Hin;
     destruct (decide (φ = a)); subst; trivial.
     + apply Hi.  rewrite elem_of_list_In; tauto.
     + apply (IHΔ _ Hθ). tauto.
     + apply (IHΔ _ Hθ). tauto.
}
apply Hcut.
Qed.

(** ** Generalized AndL *)

Lemma conjunction_L Γ Δ φ θ: (φ ∈ Δ) -> (Γ•φ ⊢ θ) -> (Γ•⋀ Δ ⊢ θ).
Proof.
intros Hin Hprov. unfold conjunction. revert Hin.
assert(Hcut : forall ψ, ((φ ∈ Δ) + (Γ•ψ ⊢ θ)) -> (Γ•foldl make_conj ψ (nodup form_eq_dec Δ) ⊢ θ)).
{
  induction Δ; simpl; intros ψ [Hin | Hψ].
  - contradict Hin; auto with *.
  - trivial.
  - case in_dec; intro; apply IHΔ; destruct (decide (φ = a)).
    + subst. left. now apply elem_of_list_In.
    + left. auto with *.
    + subst. right. apply make_conj_sound_L. auto with proof.
    + left. auto with *.
  - case in_dec; intro; apply IHΔ; right; trivial.
     apply make_conj_sound_L. auto with proof.
}
intro Hin. apply Hcut. now left.
Qed.

