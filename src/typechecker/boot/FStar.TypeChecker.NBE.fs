﻿#light "off"
module FStar.TypeChecker.NBE
open FStar.All
open FStar.Exn
open FStar
open FStar.TypeChecker
open FStar.TypeChecker.Env
open FStar.Syntax.Syntax
open FStar.Ident
open FStar.Errors

module S = FStar.Syntax.Syntax
module SS = FStar.Syntax.Subst
module Range = FStar.Range
module U = FStar.Syntax.Util
module P = FStar.Syntax.Print
module BU = FStar.Util
module Env = FStar.TypeChecker.Env
module Z = FStar.BigInt
module C = FStar.Const
module N = FStar.TypeChecker.Normalize

(* Utils *)

// VD: This seems necessary for the OCaml build
let max a b = if a > b then a else b

let map_rev (f : 'a -> 'b) (l : list<'a>) : list<'b> =
  let rec aux (l:list<'a>) (acc:list<'b>) = //NS: weird, this needs an annotation to type-check in F*; cf issue #
    match l with
    | [] -> acc
    | x :: xs -> aux xs (f x :: acc)
  in  aux l []

let rec drop (p: 'a -> bool) (l: list<'a>): list<'a> =
  match l with
  | [] -> []
  | x::xs -> if p x then x::xs else drop p xs

let debug f =
    if Options.debug_at_level "Test" (Options.Other "NBE")
    then f ()

let debug_term (t : term) =
  BU.print1 "%s\n" (P.term_to_string t)

let debug_sigmap (m : BU.smap<sigelt>) =
  BU.smap_fold m (fun k v u -> BU.print2 "%s -> %%s\n" k (P.sigelt_to_string_short v)) ()

type var = bv
type sort = int

type constant =
  | Unit
  | Bool of bool
  | Int of Z.t
  | String of string * Range.range
  | Char of FStar.Char.char

//IN F*: type atom : Type0 =
type atom = //JUST FSHARP
  | Var of var
  | Match of t * (* the scutinee *)
             ((t -> term) -> list<branch>) (* the computation that reconstructs the pattern matching, parameterized by the readback function *)
             // ZP: Keep the original branches to reconstruct just the patterns
             // NS: add a thunked pattern translations here
  | Rec of letbinding * list<letbinding> * list<t> (* Danel: This wraps a unary F* rec. def. as a thunk in F# *)
  (* Zoe : a recursive function definition together with its block of mutually recursive function definitions and its environment *)
//IN F*: and t : Type0 =
and t = //JUST FSHARP
  | Lam of (t -> t) * (unit -> t) * aqual //NS: * (t * (type : unit -> t) * aqual)
  | Accu of atom * args
  (* For simplicity represent constructors with fv as in F* *)
  | Construct of fv * list<universe> * args (* Zoe: This is used for type, data constructors, and primops *)
  | Constant of constant
  | Type_t of universe
  | Univ of universe
  | Unknown (* For translating unknown types *)
  // NS:
  | Refinement of binder * t // VD: do we need to keep the aqual?
  // | Arrow of list binder * comp_t
and args = list<(t * aqual)>
//NS:
// and comp_t =
//   | Comp of lident * universes * args * flags
// and binder = ident * t //ident is just for pretty name on readback

(*
   (xi:ti) -> C uts (attributes ...)

   x:t{t}

*)

type head = t
type annot = option<t>

let constant_to_string (c: constant) =
  match c with
  | Unit -> "Unit"
  | Bool b -> if b then "Bool true" else "Bool false"
  | Int i -> Z.string_of_big_int i
  | Char c -> BU.format1 "'%s'" (BU.string_of_char c)
  | String (s, _) -> BU.format1 "\"%s\"" s

let rec t_to_string (x:t) =
  match x with
  | Lam _ -> "Lam"
  | Accu (a, l) -> "Accu (" ^ (atom_to_string a) ^ ") (" ^ (String.concat "; " (List.map (fun x -> t_to_string (fst x)) l)) ^ ")"
  | Construct (fv, us, l) -> "Construct (" ^ (P.fv_to_string fv) ^ ") [" ^ (String.concat "; "(List.map P.univ_to_string us)) ^ "] (" ^ (String.concat "; " (List.map (fun x -> t_to_string (fst x)) l)) ^ ")"
  | Constant c -> constant_to_string c
  | Univ u -> "Universe " ^ (P.univ_to_string u)
  | Type_t u -> "Type_t " ^ (P.univ_to_string u)
  | Refinement ((b,_), t) -> "Refinement (" ^ (P.bv_to_string b) ^ ", " ^ (t_to_string t) ^ ")"
  | Unknown -> "Unknown"

and atom_to_string (a: atom) =
    match a with
    | Var v -> "Var " ^ (P.bv_to_string v)
    | Match (t, _) -> "Match " ^ (t_to_string t)
    | Rec (_,_, l) -> "Rec (" ^ (String.concat "; " (List.map t_to_string l)) ^ ")"

let is_not_accu (x:t) =
  match x with
  | Accu (_, _) -> false
  | _ -> true

let mkConstruct i us ts = Construct(i, us, ts)

let mkAccuVar (v:var) = Accu(Var v, [])
let mkAccuMatch (s:t) (bs:((t -> term) -> list<branch>)) = Accu(Match (s, bs), [])
let mkAccuRec (b:letbinding) (bs:list<letbinding>) (env:list<t>) = Accu(Rec(b, bs, env), [])

let isAccu (trm:t) =
  match trm with
  | Accu _ -> true
  | _ -> false

let pickBranch (scrut : t) (branches : list<branch>) : option<(term * list<t>)> =
  let rec pickBranch_aux (scrut : t) (branches : list<branch>) (branches0 : list<branch>) : option<(term * list<t>)> =
    //NS: adapted from FStar.TypeChecker.Normalize: rebuild_match
    let rec matches_pat (scrutinee:t) (p:pat)
        : BU.either<list<t>, bool> =
        (* Inl ts: p matches t and ts are bindings for the branch *)
        (* Inr false: p definitely does not match t *)
        (* Inr true: p may match t, but p is an open term and we cannot decide for sure *)
        match p.v with
        | Pat_var bv
        | Pat_wild bv ->
            BU.Inl [scrutinee]

        | Pat_dot_term _ ->
            BU.Inl []

        | Pat_constant s ->
            let matches_const (c: t) (s: S.sconst) =
                match c with
                | Constant (Unit) -> s = C.Const_unit
                | Constant (Bool b) -> (match s with | C.Const_bool p -> b = p | _ -> false)
                | Constant (Int i) -> (match s with | C.Const_int (p, None) -> i = Z.big_int_of_string p | _ -> false)
                | Constant (String (st, _)) -> (match s with | C.Const_string(p, _) -> st = p | _ -> false)
                | Constant (Char c) -> (match s with | C.Const_char p -> c = p | _ -> false)
                | _ -> false
            in
            if matches_const scrutinee s then BU.Inl [] else BU.Inr false

        | Pat_cons(fv, arg_pats) ->
            let rec matches_args out (a:list<(t * aqual)>) (p:list<(pat * bool)>)
                : BU.either<list<t>, bool> =
                match a, p with
                | [], [] -> BU.Inl out
                | (t, _)::rest_a, (p, _)::rest_p ->
                  (match matches_pat t p with
                   | BU.Inl s -> matches_args (out@s) rest_a rest_p
                   | m -> m)
                | _ ->
                BU.Inr false
            in
            match scrutinee with
            | Construct(fv', _us, args_rev) ->
                if fv_eq fv fv'
                then matches_args [] (List.rev args_rev) arg_pats
                else BU.Inr false

            | _ -> //must be a variable
            BU.Inr true
    in
    match branches with
    | [] -> failwith "Branch not found"
    | (p, _wopt, e)::branches ->
      match matches_pat scrut p with
      | BU.Inl matches -> Some (e, matches)
      | BU.Inr false -> //definitely did not match
        pickBranch_aux scrut branches branches0
      | BU.Inr true -> //maybe matches; stop
        None
  in pickBranch_aux scrut branches branches

(* Tests is the application is full and if none of the arguments is symbolic *)
let rec test_args ts cnt =
  match ts with
  | [] -> cnt <= 0
  | t :: ts -> (not (isAccu (fst t))) && test_args ts (cnt - 1)

(* Count the number of abstractions in the body of a let rec.
   It accounts for abstractions instantiated inside the body.
   This analysis needs further refinement, for example see the let in case.
*)
let rec count_abstractions (t : term) : int =
    match (SS.compress t).n with
    | Tm_delayed _ | Tm_unknown -> failwith "Impossible"
    | Tm_bvar _
    | Tm_name _
    | Tm_fvar _
    | Tm_constant _
    | Tm_type _
    | Tm_arrow _
    | Tm_uvar _
    | Tm_refine _
    | Tm_unknown -> 0

    | Tm_uinst (t, _)  -> count_abstractions t

    | Tm_abs (xs, body, _) ->
      List.length xs + count_abstractions body

    | Tm_app(head, args) ->
      max (count_abstractions head - List.length args) 0

    | Tm_match(scrut, branches) ->
      (match branches with
       | [] -> failwith "Branch not found"
       (* count just one branch assuming it is well-typed *)
       | (_, _, e) :: bs -> count_abstractions e)

    | Tm_let (_, t)
      (* This is not quite right. We need to somehow cound the abstractions of the let definition
         as it might be used in head position. For instance we might have something like [let t = e in t]
       *)
    | Tm_meta (t, _)
    | Tm_ascribed (t, _, _) -> count_abstractions t
    | _ -> 0

let find_sigelt_in_gamma (env: Env.env) (lid:lident): option<sigelt> =
  let mapper (lr, rng) =
    match lr with
    | BU.Inr (elt, None) -> Some elt
    | BU.Inr (elt, Some us) ->
        debug (fun () -> BU.print1 "Universes in local declaration: %s\n" (P.univs_to_string us));
        Some elt
    | _ -> None in
  BU.bind_opt (Env.lookup_qname env lid) mapper

let translate_univ (bs:list<t>) (u:universe) : t =
    let rec aux u =
        let u = SS.compress_univ u in
        match u with
        | U_bvar i ->
          let Univ u = List.nth bs i in //it has to be a Univ term at position i
          u

        | U_succ u ->
          U_succ (aux u)

        | U_max us ->
          U_max (List.map aux us)

        | U_name _
        | U_zero ->
          u

        | U_unif _
        | U_unknown ->
          failwith "Unknown or unconstrained universe"
    in
    Univ (aux u)

let is_univ (tm : t)=
  match tm with
  | Univ _ -> true
  | _ -> false

let un_univ (tm:t) : universe =
    match tm with
    | Univ u -> u
    | _ -> failwith "Not a universe"


(* Creates the environment of mutually recursive function definitions *)
let make_rec_env (lbs:list<letbinding>) (bs:list<t>) : list<t> =
  let rec aux (lbs:list<letbinding>) (lbs0:list<letbinding>) (bs:list<t>) (bs0:list<t>) : list<t> =
  match lbs with
  | [] -> bs
  | lb::lbs' -> aux lbs' lbs0 ((mkAccuRec lb lbs0 bs0) :: bs) bs0
  in
  aux lbs lbs bs bs

let find_let (lbs : list<letbinding>) (fvar : fv) =
  BU.find_map lbs (fun lb -> match lb.lbname with
                   | BU.Inl _ -> failwith "impossible"
                   | BU.Inr name ->
                     if fv_eq name fvar
                     then Some lb
                     else None)

(* We are not targeting tagless normalization at this point *)
let rec app (f:t) (x:t) (q:aqual) =
  debug (fun () -> BU.print2 "When creating app: %s applied to %s\n" (t_to_string f) (t_to_string x));
  match f with
  | Lam (f, _, _) -> f x
  | Accu (a, ts) -> Accu (a, (x,q)::ts)
  | Construct (i, us, ts) ->
    (match x with
     | Univ u -> Construct (i, u::us, ts)
     | _ -> Construct (i, us, (x,q)::ts))
  | Refinement (b, r) -> Refinement (b, app r x q)
  | Constant _ | Univ _ | Type_t _ | Unknown -> failwith "Ill-typed application"

and iapp (f:t) (args:list<(t * aqual)>) =
  match args with
  | [] -> f
  | _ -> iapp (app f (fst (List.hd args)) (snd (List.hd args))) (List.tl args)


and translate_fv (cfg: N.cfg) (bs:list<t>) (fvar:fv): t =
   let qninfo = Env.lookup_qname (N.cfg_env cfg) (S.lid_of_fv fvar) in
   match N.should_unfold cfg (fun _ -> false) fvar qninfo with
   | N.Should_unfold_fully
   | N.Should_unfold_reify ->
     failwith "Not yet handled"

   | N.Should_unfold_no ->
     mkConstruct fvar [] []

   | N.Should_unfold_yes -> begin
     match qninfo with
     | Some (BU.Inr ({ sigel = Sig_let ((is_rec, lbs), names) }, _us_opt), _rng) ->
        let lbm = find_let lbs fvar in
        (match lbm with
         | Some lb ->
           if is_rec then
             mkAccuRec lb [] [] (* ZP: both the environment and the lists of mutually defined functions are empty
                                   since they are already present in the global environment *)
           else
             begin
                debug (fun() -> BU.print "Translate fv: it's a Sig_let\n" []);
                debug (fun () -> BU.print2 "Type of lbdef: %s - %s\n" (P.tag_of_term (SS.compress lb.lbtyp)) (P.term_to_string (SS.compress lb.lbtyp)));
                debug (fun () -> BU.print2 "Body of lbdef: %s - %s\n" (P.tag_of_term (SS.compress lb.lbdef)) (P.term_to_string (SS.compress lb.lbdef)));
                // VD: Don't unfold primops
                if N.is_prim_step cfg fvar then
                  mkConstruct fvar [] []
                else
                  translate_letbinding cfg [] lb
             end
       | None -> failwith "Could not find mutually recursive definition" (* TODO: is this correct? *))
     | _ ->
       mkConstruct fvar [] [] (* Zoe : Z and S data constructors from the examples are not in the environment *)
    end

(* translate a let-binding - local or global *)
and translate_letbinding (cfg:N.cfg) (bs:list<t>) (lb:letbinding) : t =
  let rec make_univ_abst (us:list<univ_name>) (bs:list<t>) (def:term) : t =
    match us with
    | [] -> 
      let translated_def = translate cfg bs def in
      let translated_type = 
        match (SS.compress lb.lbtyp).n with
        | Tm_refine _ -> app (translate cfg bs lb.lbtyp) translated_def None
        | _ -> Constant Unit
      in
      // VD: For debugging purposes, I'm forcing a readback here, but I don't think this is  necessary
      debug (fun () ->
             match (SS.compress lb.lbtyp).n with
             | Tm_refine _ ->
               let readback_type = readback cfg translated_type in
               BU.print2 "<<< Type of %s is %s\n" (t_to_string translated_def) (P.term_to_string readback_type)
             | _ -> ());
             
      translated_def

    | u :: us' -> Lam ((fun u -> make_univ_abst us' (u :: bs) def), (fun () -> Constant Unit), None) 
     // Zoe: Bogus type! The idea is that we will never readback these lambdas
  in
  make_univ_abst lb.lbunivs bs lb.lbdef


and translate_constant (c : sconst) : constant =
    match c with
    | C.Const_unit -> Unit
    | C.Const_bool b -> Bool b
    | C.Const_int (s, None) -> (Int (Z.big_int_of_string s))
    | C.Const_string (s, r) -> String (s,r)
    | C.Const_char c -> (Char c)
    | _ -> failwith ("Tm_constant " ^ (P.const_to_string c) ^ ": Not yet implemented")

and translate_pat (p : pat) : t =
    match p.v with
    | Pat_constant c -> Constant (translate_constant c)
    | Pat_cons (cfv, pats) -> iapp (mkConstruct cfv [] []) (List.map (fun (p,_) -> (translate_pat p, None)) pats)
    | Pat_var bvar -> mkAccuVar bvar
    | Pat_wild bvar -> mkAccuVar bvar
    | Pat_dot_term (bvar, t) -> failwith "Pat_dot_term not implemented"

and translate (cfg:N.cfg) (bs:list<t>) (e:term) : t =
    debug (fun () -> BU.print2 "Term: %s - %s\n" (P.tag_of_term (SS.compress e)) (P.term_to_string (SS.compress e)));
    debug (fun () -> BU.print1 "BS list: %s\n" (String.concat ";; " (List.map (fun x -> t_to_string x) bs)));

    match (SS.compress e).n with
    | Tm_delayed (_, _) ->
      failwith "Tm_delayed: Impossible"

    | Tm_unknown -> Unknown

    | Tm_constant c ->
      Constant (translate_constant c)

    | Tm_bvar db -> //de Bruijn
      List.nth bs db.index

    | Tm_uinst(t, us) ->
      debug (fun () -> BU.print3 "Term with univs: %s - %s\nUniv %s\n" (P.tag_of_term t) (P.term_to_string t) (List.map P.univ_to_string us |> String.concat ", "));
      List.fold_left (fun head u -> app head u None)
                     (translate cfg bs t)
                     (List.map (translate_univ bs) us)

    | Tm_type u ->
      Type_t (un_univ (translate_univ bs u))

    | Tm_arrow (bs, c) -> debug_term e; failwith "Tm_arrow: Not yet implemented"

    | Tm_refine (db, tm) ->
      Refinement ((db, None), Lam ((fun (y:t) -> translate cfg (y::bs) tm), (fun () -> Constant Unit), None)) // XXX: Bogus type?

    | Tm_ascribed (t, _, _) -> translate cfg bs t

    | Tm_uvar (uvar, t) -> debug_term e; failwith "Tm_uvar: Not yet implemented"

    | Tm_meta (e, _) -> translate cfg bs e

    | Tm_name x ->
      mkAccuVar x

    | Tm_abs ([], _, _) -> failwith "Impossible: abstraction with no binders"

    | Tm_abs ([x], body, _) ->
      debug (fun () -> BU.print2 "Tm_abs body : %s - %s\n" (P.tag_of_term body) (P.term_to_string body));
      let x1 = fst x in
      Lam ((fun (y:t) -> translate cfg (y::bs) body), (fun () -> translate cfg bs x1.sort), snd x)

    | Tm_abs (x::xs, body, _) ->
      let rest = S.mk (Tm_abs(xs, body, None)) None Range.dummyRange in
      let tm = S.mk (Tm_abs([x], rest, None)) None e.pos in
      translate cfg bs tm

    | Tm_fvar fvar ->
      translate_fv cfg bs fvar

    | Tm_app(e, []) -> failwith "Impossible: application with no arguments"

    | Tm_app (e, [arg]) ->
      debug (fun () -> BU.print2 "Application %s / %s\n" (P.term_to_string e) (P.term_to_string (fst arg)));
      app (translate cfg bs e) (translate cfg bs (fst arg)) (snd arg)

    | Tm_app(head, arg::args) ->
      debug (fun () -> BU.print2 "Application %s / %s (...more agrs)\n" (P.term_to_string head) (P.term_to_string (fst arg)));
      let first = S.mk (Tm_app(head, [arg])) None Range.dummyRange in
      let tm = S.mk (Tm_app(first, args)) None e.pos in
      translate cfg bs tm

    | Tm_match(scrut, branches) ->
      let rec case (scrut : t) : t =
        match scrut with
        | Construct(c, us, args) -> (* Scrutinee is a constructed value *)
          (* Assuming that all the arguments to the pattern constructors
             are binders -- i.e. no nested patterns for now *)
          debug (fun () ->
                 BU.print1 "Match args: %s\n"
                            (args
                             |> List.map (fun (x, q) -> (if BU.is_some q then "#" else "") ^ t_to_string x)
                             |> String.concat "; "));
          begin
          match pickBranch scrut branches with
          | Some (branch, args) ->
            translate cfg (List.fold_left (fun bs x -> x::bs) bs args) branch
          | None -> //no branch is determined
            mkAccuMatch scrut make_branches
          end
        | Constant c ->
          (* same as for construted values, but args are either empty or is a singleton list (for wildcard patterns) *)
          (match pickBranch scrut branches with
           | Some (branch, []) ->
             translate cfg bs branch
           | Some (branch, [arg]) ->
             translate cfg (arg::bs) branch
           | None -> //no branch is determined
             mkAccuMatch scrut make_branches
           | Some (_, hd::tl) -> failwith "Impossible: Matching on constants cannot bind more than one variable")

        | _ ->
          mkAccuMatch scrut make_branches
      (* Thunked computation that reconstructs the patterns *)
      (* Zoe TODO : maybe rewrite in CPS? *)
      and make_branches (readback:t -> term) : list<branch> = 
        let rec process_pattern bs (p:pat) : list<t> * pat = (* returns new environment and pattern *) 
          let (bs, p_new) = 
            match p.v with
            | Pat_constant c -> (bs, Pat_constant c)
            | Pat_cons (fvar, args) -> 
              let (bs', args') = 
                  List.fold_left (fun (bs, args) (arg, b) -> 
                                    let (bs', arg') = process_pattern bs arg in
                                    (bs, (arg', b) :: args)) (bs, []) args
              in
              (bs', Pat_cons (fvar, List.rev args'))
            | Pat_var bvar -> 
              let x = S.new_bv None (readback (translate cfg bs bvar.sort)) in 
              (mkAccuVar x :: bs, Pat_var x)
            | Pat_wild bvar -> 
              let x = S.new_bv None (readback (translate cfg bs bvar.sort)) in 
              (mkAccuVar x :: bs, Pat_wild x)
              (* Zoe: I'm not sure what this pattern binds, just speculating the translation *)
            | Pat_dot_term (bvar, tm) -> 
              let x = S.new_bv None (readback (translate cfg bs bvar.sort)) in 
              (mkAccuVar x :: bs, 
               Pat_dot_term (x, readback (translate cfg bs tm)))
          in
          (bs, {p with v = p_new}) (* keep the info and change the pattern *) 
        in
        List.map (fun (pat, when_clause, e) -> 
                  let (bs', pat') = process_pattern bs pat in 
                  (* TODO : handle when clause *)
                  U.branch (pat', when_clause, readback (translate cfg bs' e))) branches 
      in
      case (translate cfg bs scrut)

    | Tm_let((false, lbs), body) -> // non-recursive let
      let bs' =
        List.fold_left (fun bs' lb -> let b = translate_letbinding cfg bs lb in b :: bs') bs lbs  in
      translate cfg bs' body

    | Tm_let((true, lbs), body) ->
      translate cfg (make_rec_env lbs bs) body (* Danel: storing the rec. def. as F* code wrapped in a thunk *)

(* [readback] creates named binders and not De Bruijn *)
and readback (cfg:N.cfg) (x:t) : term =
    debug (fun () -> BU.print1 "Readback: %s\n" (t_to_string x));
    match x with
    | Univ u -> failwith "Readback of universes should not occur"

    | Unknown -> S.mk Tm_unknown None Range.dummyRange

    | Constant Unit -> S.unit_const
    | Constant (Bool true) -> U.exp_true_bool
    | Constant (Bool false) -> U.exp_false_bool
    | Constant (Int i) -> Z.string_of_big_int i |> U.exp_int
    | Constant (String (s, r)) -> mk (S.Tm_constant (C.Const_string (s, r))) None Range.dummyRange
    | Constant (Char c) -> U.exp_char c

    | Type_t u ->
      S.mk (Tm_type u) None Range.dummyRange

    | Lam (f, t, q) ->
      let x = S.new_bv None (readback cfg (t ())) in (* (readback env t) is the type of the binder *)
      let body = readback cfg (f (mkAccuVar x)) in
      U.abs [(x, q)] body None

    | Construct (fv, us, args) ->
      let args = map_rev (fun (x, q) -> (readback cfg x, q)) args in
      let apply tm =
        match args with
         | [] -> tm
         | _ ->  U.mk_app tm args
      in
      let tm () = 
        match us with
        | _ :: _ -> apply (S.mk_Tm_uinst (S.mk (Tm_fvar fv) None Range.dummyRange) (List.rev us))
        | [] -> apply (S.mk (Tm_fvar fv) None Range.dummyRange)
      in
      (match N.find_prim_step cfg fv with
       | Some prim_step when prim_step.strong_reduction_ok (* TODO : || not cfg.strong *) -> 
         (* TODO : can primops be universe polymorphic? *)
         begin
           let l = List.length args in 
           let args_1, args_2 = if l = prim_step.arity
                                then args, []
                                else List.splitAt prim_step.arity args
           in  
           let psc = {
             N.psc_range = Range.dummyRange;
             N.psc_subst = (fun () -> if prim_step.requires_binder_substitution
                                 then failwith "Cannot handle primops that require substitution"
                                 else [])
           } in
           match prim_step.interpretation psc args_1 with 
           | Some tm -> U.mk_app tm args_2
           | None -> tm ()
         end
       | _ -> tm ())

    | Accu (Var bv, []) ->
      S.bv_to_name bv
    | Accu (Var bv, ts) ->
      let args = map_rev (fun (x, q) -> (readback cfg x, q)) ts in
      U.mk_app (S.bv_to_name bv) args

    | Accu (Match (scrut, make_branches), ts) ->
      let args = map_rev (fun (x, q) -> (readback cfg x, q)) ts in
      let head = 
        let scrut_new = readback cfg scrut in
        let branches_new = make_branches (readback cfg) in
        S.mk (Tm_match (scrut_new, branches_new)) None Range.dummyRange
      in
      (*  When `cases scrut` returns a Accu(Match ..))
          we need to reconstruct a source match node.

          To do this, we need to decorate that Match node with the
          patterns in each branch.

          e.g., Consider this source node:

              (match x with
               | Inl (a:ta) -> e1
               | Inr (b:tb) -> e2)

          Match([[x]],
                (cases: t -> t),
                (patterns:[Inl (a:ta); Inr (b:tb)]))

          let branches =
            map (fun v -> v, readback (cases (translate v)))
                patterns
          in
          match (readback [[x]])
                branches
       *)

      (match ts with
       | [] -> head
       | _ -> U.mk_app head args)

    | Accu (Rec(lb, lbs, bs), ts) ->
       let rec curry hd args =
       match args with
       | [] -> hd
       | [arg] -> app hd (fst arg) (snd arg)
       | arg :: args -> app (curry hd args) (fst arg) (snd arg)
       in
       let args_no = count_abstractions lb.lbdef in
       // Printf.printf "Args no. %d\n" args_no;
       if test_args ts args_no then (* if the arguments are not symbolic and the application is not partial compute *)
         readback cfg (curry (translate_letbinding cfg (make_rec_env lbs bs) lb) ts)
       else (* otherwise do not unfold *)
         let head =
           (* Zoe: I want the head to be [let rec f = lb in f]. Is this the right way to construct it? *)
           let f = match lb.lbname with
                   | BU.Inl bv -> S.bv_to_name bv
                   | BU.Inr fv -> failwith "Not yet implemented"
           in
           S.mk (Tm_let((true, lbs), f)) None Range.dummyRange
         in
         let args = map_rev (fun (x, q) -> (readback cfg x, q)) ts in
         (match ts with
          | [] -> head
          | _ -> U.mk_app head args)
    | Refinement (b, r) ->
       let body = translate cfg [] (readback cfg r) in
       debug (fun () -> BU.print1 "Translated refinement body: %s\n" (t_to_string body));
       S.mk (Tm_refine(fst b, readback cfg body)) None Range.dummyRange

type step =
  | Primops
  | UnfoldUntil of delta_depth
  | UnfoldOnly  of list<FStar.Ident.lid>
  | UnfoldAttr of attribute
  | UnfoldTac
  | Reify

let step_as_normalizer_step = function
  | Primops -> Env.Primops
  | UnfoldUntil d -> Env.UnfoldUntil d
  | UnfoldOnly lids -> Env.UnfoldOnly lids
  | UnfoldAttr attr -> Env.UnfoldAttr attr
  | UnfoldTac -> Env.UnfoldTac
  | Reify -> Env.Reify

let normalize (steps:list<step>) (env : Env.env) (e:term) : term =
  let cfg = N.config (List.map step_as_normalizer_step steps) env in
  //debug_sigmap env.sigtab;
  readback cfg (translate cfg [] e)


let normalize' (steps:list<Env.step>) (env : Env.env) (e:term) : term =
  let cfg = N.config steps env in
  //debug_sigmap env.sigtab;
  readback cfg (translate cfg [] e)
