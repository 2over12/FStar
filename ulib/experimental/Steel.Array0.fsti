module Steel.Array0

open Steel.Memory
open Steel.Effect.Atomic
open Steel.Effect
include Steel.ST.Array0

/// C arrays of universe 0 elements, with selectors.


/// Non-selector style universe 0 arrays are defined in Steel.ST, but
/// we want to transparently reuse the corresponding operations in
/// Steel, so we need to bring in the lift from Steel.ST to Steel,
/// defined in Steel.ST.Coercions.
module STC = Steel.ST.Coercions

module P = Steel.FractionalPermission
module U32 = FStar.UInt32
module A = Steel.ST.Array0

/// A selector version
val varrayp_hp
  (#elt: Type0) (a: array elt) (p: P.perm)
: Tot (slprop u#1)

val varrayp_sel
  (#elt: Type) (a: array elt) (p: P.perm)
: Tot (selector (Seq.lseq elt (length a)) (varrayp_hp a p))

[@__steel_reduce__] // for t_of
let varrayp
  (#elt: Type) (a: array elt) (p: P.perm)
: Tot vprop
= VUnit ({
    hp = varrayp_hp a p;
    t = _;
    sel = varrayp_sel a p;
  })

[@@ __steel_reduce__]
let aselp (#elt: Type) (#vp: vprop) (a: array elt) (p: P.perm)
  (h: rmem vp { FStar.Tactics.with_tactic selector_tactic (can_be_split vp (varrayp a p) /\ True) })
: GTot (Seq.lseq elt (length a))
= h (varrayp a p)

[@@__steel_reduce__; __reduce__]
let varray
  (#elt: Type) (a: array elt)
: Tot vprop
= varrayp a P.full_perm

[@@ __steel_reduce__]
let asel (#elt: Type) (#vp: vprop) (a: array elt)
  (h: rmem vp { FStar.Tactics.with_tactic selector_tactic (can_be_split vp (varray a) /\ True) })
: GTot (Seq.lseq elt (length a))
= h (varray a)

val intro_varrayp
  (#opened: _) (#elt: Type) (a: array elt) (p: P.perm) (s: Seq.seq elt)
: SteelGhost unit opened
    (pts_to a p s)
    (fun _ -> varrayp a p)
    (fun _ -> True)
    (fun _ _ h' ->
      aselp a p h' == s
    )

let intro_varray
  (#opened: _) (#elt: Type) (a: array elt) (s: Seq.seq elt)
: SteelGhost unit opened
    (pts_to a P.full_perm s)
    (fun _ -> varray a)
    (fun _ -> True)
    (fun _ _ h' ->
      asel a h' == s
    )
= intro_varrayp _ _ _

val elim_varrayp
  (#opened: _) (#elt: Type) (a: array elt) (p: P.perm)
: SteelGhost (Ghost.erased (Seq.seq elt)) opened
    (varrayp a p)
    (fun res -> pts_to a p res)
    (fun _ -> True)
    (fun h res _ ->
      Ghost.reveal res == aselp a p h
    )

let elim_varray
  (#opened: _) (#elt: Type) (a: array elt)
: SteelGhost (Ghost.erased (Seq.seq elt)) opened
    (varray a)
    (fun res -> pts_to a P.full_perm res)
    (fun _ -> True)
    (fun h res _ ->
      Ghost.reveal res == asel a h
    )
= elim_varrayp _ _

/// Allocating a new array of size n, where each cell is initialized
/// with value x. We define the non-selector version of this operation
/// (and others) with a _pt suffix in the name.
inline_for_extraction
[@@noextract_to "krml"]
let malloc
  (#elt: Type)
  (x: elt)
  (n: U32.t)
: Steel (array elt)
    emp
    (fun a -> varray a)
    (fun _ -> True)
    (fun _ a h' ->
      length a == U32.v n /\
      base_len (base (ptr_of a)) == U32.v n /\
      asel a h' == Seq.create (U32.v n) x
    )
= let res = A.malloc x n in
  intro_varray res _;
  return res

/// Freeing a full array. 
inline_for_extraction
[@@ noextract_to "krml";
    warn_on_use "Steel.Array0.free is currently unsound in the presence of zero-size subarrays, have you collected them all?"]
let free
  (#elt: Type)
  (a: array elt)
: Steel unit
    (varray a)
    (fun _ -> emp)
    (fun _ ->
      length a == base_len (base (ptr_of a))
    )
    (fun _ _ _ -> True)
= let _ = elim_varray a in
  A.free a

/// Sharing and gathering permissions on an array. Those only
/// manipulate permissions, so they are nothing more than stateful
/// lemmas.
inline_for_extraction // FIXME: F* bug. This attribute is not necessary here, but if removed, F* complains about duplicate declaration and definition
let share
  (#opened: _)
  (#elt: Type)
  (a: array elt)
  (p p1 p2: P.perm)
: SteelGhost unit opened
    (varrayp a p)
    (fun _ -> varrayp a p1 `star` varrayp a p2)
    (fun _ -> p == p1 `P.sum_perm` p2)
    (fun h _ h' ->
      aselp a p1 h' == aselp a p h /\
      aselp a p2 h' == aselp a p h
    )
= let _ = elim_varrayp a p in
  A.share a p p1 p2;
  intro_varrayp a p1 _;
  intro_varrayp a p2 _

inline_for_extraction // same here
let gather
  (#opened: _)
  (#elt: Type)
  (a: array elt)
  (p1: P.perm)
  (p2: P.perm)
: SteelGhost unit opened
    (varrayp a p1 `star` varrayp a p2)
    (fun _ -> varrayp a (p1 `P.sum_perm` p2))
    (fun _ -> True)
    (fun h _ h' ->
      aselp a (p1 `P.sum_perm` p2) h' == aselp a p1 h /\
      aselp a (p1 `P.sum_perm` p2) h' == aselp a p2 h
    )
= let _ = elim_varrayp a p1 in
  let _ = elim_varrayp a p2 in
  A.gather a p1 p2;
  intro_varrayp a _ _

/// Reading the i-th element of an array a.
/// TODO: we should also provide an atomic version for small types.
inline_for_extraction
[@@noextract_to "krml"]
let index
  (#t: Type) (#p: P.perm)
  (a: array t)
  (i: U32.t)
: Steel t
    (varrayp a p)
    (fun _ -> varrayp a p)
    (fun _ -> U32.v i < length a)
    (fun h res h' ->
      let s = aselp a p h in
      aselp a p h' == s /\
      U32.v i < Seq.length s /\
      res == Seq.index s (U32.v i)
    )
= let _ = elim_varrayp a p in
  let res = A.index a i in
  intro_varrayp a _ _;
  return res

/// Writing the value v at the i-th element of an array a.
/// TODO: we should also provide an atomic version for small types.
inline_for_extraction
[@@noextract_to "krml"]
let upd
  (#t: Type)
  (a: array t)
  (i: U32.t)
  (v: t)
: Steel unit
    (varray a)
    (fun _ -> varray a)
    (fun _ ->  U32.v i < length a)
    (fun h _ h' ->
      U32.v i < length a /\
      asel a h' == Seq.upd (asel a h) (U32.v i) v
    )
= let s = elim_varray a in
  A.pts_to_length a _ _;
  [@@inline_let] // FIXME: WHY WHY WHY do I need an explicit refinement here?
  let (i': (i': U32.t { U32.v i' < Seq.length s })) = i in
  A.upd a i' v;
  intro_varray a _

let ghost_join_st // FIXME: WHY WHY WHY do I need this? just because I cannot lift A.ghost_join because of its squash argument
  (#opened: _)
  (#elt: Type)
  (#x1 #x2: Seq.seq elt)
  (#p: P.perm)
  (a1 a2: array elt)
: Steel.ST.Util.STGhost (Ghost.erased (array elt)) opened
    (pts_to a1 p x1 `star` pts_to a2 p x2)
    (fun res -> pts_to res p (x1 `Seq.append` x2))
    (adjacent a1 a2)
    (fun res -> merge_into a1 a2 res)
= A.ghost_join a1 a2 ();
  let res = Ghost.hide (merge a1 a2) in
  Steel.ST.Util.rewrite
    (pts_to _ _ _)
    (pts_to res _ _);
  res

/// Spatial merging of two arrays, expressed in terms of `merge`.
inline_for_extraction // same as above
let ghost_join
  (#opened: _)
  (#elt: Type)
  (#p: P.perm)
  (a1 a2: array elt)
  (sq: squash (adjacent a1 a2))
: SteelGhost unit opened
    (varrayp a1 p `star` varrayp a2 p)
    (fun res -> varrayp (merge a1 a2) p)
    (fun _ -> True)
    (fun h _ h' ->
      aselp (merge a1 a2) p h' == aselp a1 p h `Seq.append` aselp a2 p h
    )
= let _ = elim_varrayp a1 p in
  let _ = elim_varrayp a2 p in
  let res = ghost_join_st a1 a2 in
  intro_varrayp res _ _;
  change_equal_slprop
    (varrayp _ _)
    (varrayp _ _)

/// Spatial merging, combining the use of `merge` and the call to the
/// stateful lemma. Since the only operations are calls to stateful
/// lemmas and pure computations, the overall computation is atomic
/// and unobservable, so can be used anywhere in atomic contexts.  By
/// virtue of the length being ghost, Karamel will extract this to
/// "let res = a1"
inline_for_extraction // this will extract to "let res = a1"
[@@noextract_to "krml"]
let join
  (#opened: _)
  (#elt: Type)
  (#p: P.perm)
  (a1: array elt)
  (a2: Ghost.erased (array elt))
: SteelAtomicBase (array elt) false opened Unobservable
    (varrayp a1 p `star` varrayp a2 p)
    (fun res -> varrayp res p)
    (fun _ -> adjacent a1 a2)
    (fun h res h' ->
      merge_into a1 a2 res /\
      aselp res p h' == aselp a1 p h `Seq.append` aselp a2 p h
    )
= let _ = elim_varrayp a1 _ in
  let _ = elim_varrayp a2 _ in
  let res = A.join a1 a2 in
  intro_varrayp res _ _;
  return res

/// Splitting an array a at offset i, as a stateful lemma expressed in
/// terms of split_l, split_r. In the non-selector case, this stateful
/// lemma returns a proof that offset i is in bounds of the value
/// sequence, which is needed to typecheck the post-resource.
inline_for_extraction // same as above
let ghost_split
  (#opened: _)
  (#elt: Type)
  (#p: P.perm)
  (a: array elt)
  (i: U32.t { U32.v i <= length a })
: SteelGhost unit opened
    (varrayp a p)
    (fun _ -> varrayp (split_l a i) p `star` varrayp (split_r a i) p)
    (fun _ -> True)
    (fun h _ h' ->
      let x = aselp a p h in
      let xl = Seq.slice x 0 (U32.v i) in
      let xr = Seq.slice x (U32.v i) (Seq.length x) in
      aselp (split_l a i) p h' == xl /\
      aselp (split_r a i) p h' == xr /\
      x == Seq.append xl xr
    )
= let _ = elim_varrayp a _ in
  A.ghost_split a i;
  intro_varrayp (split_l a i) _ _;
  intro_varrayp (split_r a i) _ _

/// NOTE: we could implement a SteelAtomicBase Unobservable "split"
/// operation, just like "join", but we don't want it to return a pair
/// of arrays. For now we settle on explicit use of split_l, split_r.
