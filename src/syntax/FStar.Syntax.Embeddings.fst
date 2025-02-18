﻿(*
   Copyright 2008-2014 Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

module FStar.Syntax.Embeddings

open FStar
open FStar.Compiler
open FStar.Pervasives
open FStar.Compiler.Effect
open FStar.Syntax.Syntax
open FStar.Compiler.Range
open FStar.VConfig

module BU    = FStar.Compiler.Util
module C     = FStar.Const
module Err   = FStar.Errors
module Ident = FStar.Ident
module PC    = FStar.Parser.Const
module Print = FStar.Syntax.Print
module S     = FStar.Syntax.Syntax
module SS    = FStar.Syntax.Subst
module U     = FStar.Syntax.Util
module UF    = FStar.Syntax.Unionfind
module Z     = FStar.BigInt

open FStar.Syntax.Embeddings.Base
module AE = FStar.Syntax.Embeddings.AppEmb

friend FStar.Pervasives (* To expose norm_step *)

(*********************************************************************

             A NOTE ON FUNCTIONS AND SHADOW TERMS

Shadow terms exist to acomodate strong reduction of plugins.

Suppose we have this function, marked as a plugin to accelerate it
during typechecking:

    [@@plugin]
    let sort (l : list int) : list int = ...

(Plugins are usually tactics, but do not have to be. This discussion
is actually not so relevant for tactics as they do not run in open
contexts.)

Compilation will generate a version that works on _real_ concrete
lists of integers. To call it on a term, as we have to do during
typechecking, we need to wrap it with embeddings:

    sort_term t = embed_intlist (sort (unembed_intlist t))

This turns the term `t` into an actual `list int`, calls the native
sort function, and then reconstructs a term for the resulting list.

After loading the compiled version of that file, `sort_term` is now
loaded as a primitive step in the normalizer (under the name `sort`, of
course), and will be called everytime we find this symbol applied to an
argument. While its argument must have already been reduced (CBV), there
is no guarantee that it is an actual _value_ as we may be in an open
context, e.g. we may be typechecking this formula:

    forall l. sum (sort l) == sum l

or it can be applied to some abstract lid even in a closed
context, or to a Tm_let that we are not currently reducing (e.g. DIV),
etc. So, we may fail (and often do) to unembed the argument term
to obtain a concrete list, hence sort_term is closer to:

    sort_term t = match unembed_intlist t with
                  | None -> None
                  | Some l -> embed_intlist (sort l)

But, instead of stopping reduction with the None, we can instead
use the definition of sort itself, and call the normalizer with
the unfolded definition applied to the symbolic argument. Shadow
terms are term representations of whatever the embedded thing is,
which can be defaulted to when the embedding does not work.

(TODO: what does this do for recursive functions? sounds
  like it would not unfold? Actually, it seems broken:

    [@@plugin]
    let rec mylen (l : list int) : int =
      match l with
      | [] -> 0
      | x::xs -> 1 + mylen xs

    let test (a b c : int) =
      assert (mylen [a;b;c] == mylen [c;b;a]) by begin
        dump "1";
        compute ();
        dump "2";
        trefl ();
        ()
      end

this file works when mylen is not loaded as a plugin, but fails
otherwise since reduction is blocked.)


*********************************************************************)

let id_norm_cb : norm_cb = function
    | Inr x -> x
    | Inl l -> S.fv_to_tm (S.lid_as_fv l None)
exception Embedding_failure
exception Unembedding_failure

let map_shadow (s:shadow_term) (f:term -> term) : shadow_term =
    BU.map_opt s (Thunk.map f)
let force_shadow (s:shadow_term) = BU.map_opt s Thunk.force

type printer 'a = 'a -> string

let unknown_printer typ _ =
    BU.format1 "unknown %s" (Print.term_to_string typ)

let term_as_fv t =
    match (SS.compress t).n with
    | Tm_fvar fv -> fv
    | _ -> failwith (BU.format1 "Embeddings not defined for type %s" (Print.term_to_string t))

let lazy_embed (pa:printer 'a) (et:emb_typ) rng ta (x:'a) (f:unit -> term) =
    if !Options.debug_embedding
    then BU.print3 "Embedding a %s\n\temb_typ=%s\n\tvalue is %s\n"
                         (Print.term_to_string ta)
                         (Print.emb_typ_to_string et)
                         (pa x);
    if !Options.eager_embedding
    then f()
    else let thunk = Thunk.mk f in
         U.mk_lazy x S.tun (Lazy_embedding (et, thunk)) (Some rng)

let lazy_unembed (pa:printer 'a) (et:emb_typ) (x:term) (ta:term) (f:term -> option 'a) : option 'a =
    let x = unmeta_div_results x in
    match x.n with
    | Tm_lazy {blob=b; lkind=Lazy_embedding (et', t)}  ->
      if et <> et'
      || !Options.eager_embedding
      then let res = f (Thunk.force t) in
           let _ = if !Options.debug_embedding
                   then BU.print3 "Unembed cancellation failed\n\t%s <> %s\nvalue is %s\n"
                                (Print.emb_typ_to_string et)
                                (Print.emb_typ_to_string et')
                                (match res with None -> "None" | Some x -> "Some " ^ (pa x))
           in
           res
      else let a = Dyn.undyn b in
           let _ = if !Options.debug_embedding
                   then BU.print2 "Unembed cancelled for %s\n\tvalue is %s\n"
                                (Print.emb_typ_to_string et)
                                  (pa a)
           in
           Some a
    | _ ->
      let aopt = f x in
      let _ = if !Options.debug_embedding
              then BU.print3 "Unembedding:\n\temb_typ=%s\n\tterm is %s\n\tvalue is %s\n"
                               (Print.emb_typ_to_string et)
                               (Print.term_to_string x)
                               (match aopt with None -> "None" | Some a -> "Some " ^ pa a) in
      aopt


let mk_any_emb typ =
    let em = fun t _r _shadow _norm ->
      if !Options.debug_embedding then
        BU.print1 "Embedding abstract: %s\n" (unknown_printer typ t);
      t
    in
    let un = fun t _n ->
      if !Options.debug_embedding then
        BU.print1 "Unembedding abstract: %s\n" (unknown_printer typ t);
      Some t
    in
    mk_emb_full
        em
        un
        typ
        (unknown_printer typ)
        ET_abstract

let e_any =
    let em = fun t _r _shadow _norm -> t in
    let un = fun t _n -> Some t in
    mk_emb_full
        em
        un
        S.t_term
        Print.term_to_string
        (ET_app (PC.term_lid |> Ident.string_of_lid, []))

let e_unit =
    let em (u:unit) rng _shadow _norm : term = { U.exp_unit with pos = rng } in
    let un (t0:term) _norm : option unit =
        let t = U.unascribe t0 in
        match t.n with
        | S.Tm_constant C.Const_unit -> Some ()
        | _ -> None
    in
    mk_emb_full
        em
        un
        S.t_unit
        (fun _ -> "()")
        (ET_app(PC.unit_lid |> Ident.string_of_lid, []))

let e_bool =
    let em (b:bool) rng _shadow _norm : term =
        let t = if b then U.exp_true_bool else U.exp_false_bool in
        { t with pos = rng }
    in
    let un (t:term) _norm : option bool =
        match (SS.compress t).n with
        | Tm_constant(FStar.Const.Const_bool b) -> Some b
        | _ -> None
    in
    mk_emb_full
        em
        un
        S.t_bool
        BU.string_of_bool
        (ET_app(PC.bool_lid |> Ident.string_of_lid, []))

let e_char =
    let em (c:char) (rng:range) _shadow _norm : term =
        let t = U.exp_char c in
        { t with pos = rng }
    in
    let un (t:term) _norm : option char =
        match (SS.compress t).n with
        | Tm_constant(FStar.Const.Const_char c) -> Some c
        | _ -> None
    in
    mk_emb_full
        em
        un
        S.t_char
        BU.string_of_char
        (ET_app(PC.char_lid |> Ident.string_of_lid, []))

let e_int =
    let ty = S.t_int in
    let emb_t_int = ET_app(PC.int_lid |> Ident.string_of_lid, []) in
    let em (i:Z.t) (rng:range) _shadow _norm : term =
        lazy_embed
            BigInt.string_of_big_int
            emb_t_int
            rng
            ty
            i
            (fun () -> U.exp_int (Z.string_of_big_int i))
    in
    let un (t:term) _norm : option Z.t =
        lazy_unembed
            BigInt.string_of_big_int
            emb_t_int
            t
            ty
            (fun t ->
                match t.n with
                | Tm_constant(FStar.Const.Const_int (s, _)) -> Some (Z.big_int_of_string s)
                | _ -> None)
    in
    mk_emb_full
        em
        un
        ty
        BigInt.string_of_big_int
        emb_t_int

let e_fsint = embed_as e_int Z.to_int_fs Z.of_int_fs None

let e_string =
    let emb_t_string = ET_app(PC.string_lid |> Ident.string_of_lid, []) in
    let em (s:string) (rng:range) _shadow _norm : term =
        S.mk (Tm_constant(FStar.Const.Const_string(s, rng)))
             rng
    in
    let un (t:term) _norm : option string =
        match (SS.compress t).n with
        | Tm_constant(FStar.Const.Const_string(s, _)) -> Some s
        | _ -> None
    in
    mk_emb_full
        em
        un
        S.t_string
        (fun x -> "\"" ^ x ^ "\"")
        emb_t_string

let e_option (ea : embedding 'a) =
    let typ = S.t_option_of (type_of ea) in
    let emb_t_option_a =
        ET_app(PC.option_lid |> Ident.string_of_lid, [emb_typ_of ea])
    in
    let printer = FStar.Common.string_of_option (printer_of ea) in
    let em (o:option 'a) (rng:range) shadow norm : term =
        lazy_embed
            printer
            emb_t_option_a
            rng
            typ
            o
            (fun () ->
                match o with
                | None ->
                  S.mk_Tm_app (S.mk_Tm_uinst (S.tdataconstr PC.none_lid) [U_zero])
                              [S.iarg (type_of ea)]
                              rng
                | Some a ->
                  let shadow_a = map_shadow shadow (fun t ->
                    let v = Ident.mk_ident ("v", rng) in
                    let some_v = U.mk_field_projector_name_from_ident PC.some_lid v in
                    let some_v_tm = S.fv_to_tm (lid_as_fv some_v None) in
                    S.mk_Tm_app (S.mk_Tm_uinst some_v_tm [U_zero])
                                [S.iarg (type_of ea); S.as_arg t]
                                rng)
                  in
                  S.mk_Tm_app (S.mk_Tm_uinst (S.tdataconstr PC.some_lid) [U_zero])
                              [S.iarg (type_of ea); S.as_arg (embed ea a rng shadow_a norm)]
                              rng)
    in
    let un (t:term)  norm : option (option 'a) =
        lazy_unembed
            printer
            emb_t_option_a
            t
            typ
            (fun t ->
                let hd, args = U.head_and_args_full t in
                match (U.un_uinst hd).n, args with
                | Tm_fvar fv, _ when S.fv_eq_lid fv PC.none_lid -> Some None
                | Tm_fvar fv, [_; (a, _)] when S.fv_eq_lid fv PC.some_lid ->
                     BU.bind_opt (try_unembed ea a norm) (fun a -> Some (Some a))
                | _ -> None)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_t_option_a

let e_tuple2 (ea:embedding 'a) (eb:embedding 'b) =
    let typ = S.t_tuple2_of (type_of ea) (type_of eb) in
    let emb_t_pair_a_b =
        ET_app(PC.lid_tuple2 |> Ident.string_of_lid, [emb_typ_of ea; emb_typ_of eb])
    in
    let printer (x, y) =
        BU.format2 "(%s, %s)" (printer_of ea x) (printer_of eb y)
    in
    let em (x:('a * 'b)) (rng:range) shadow norm : term =
        lazy_embed
            printer
            emb_t_pair_a_b
            rng
            typ
            x
            (fun () ->
                let proj i ab =
                    let proj_1 = U.mk_field_projector_name (PC.mk_tuple_data_lid 2 rng) (S.null_bv S.tun) i in
                    let proj_1_tm = S.fv_to_tm (lid_as_fv proj_1 None) in
                    S.mk_Tm_app (S.mk_Tm_uinst proj_1_tm [U_zero])
                                [S.iarg (type_of ea);
                                 S.iarg (type_of eb);
                                 S.as_arg ab] // ab == shadow
                                rng
                in
                let shadow_a = map_shadow shadow (proj 1) in
                let shadow_b = map_shadow shadow (proj 2) in
                S.mk_Tm_app (S.mk_Tm_uinst (S.tdataconstr PC.lid_Mktuple2) [U_zero;U_zero])
                            [S.iarg (type_of ea);
                             S.iarg (type_of eb);
                             S.as_arg (embed ea (fst x) rng shadow_a norm);
                             S.as_arg (embed eb (snd x) rng shadow_b norm)]
                            rng)
    in
    let un (t:term)  norm : option ('a * 'b) =
        lazy_unembed
            printer
            emb_t_pair_a_b
            t
            typ
            (fun t ->
                let hd, args = U.head_and_args_full t in
                match (U.un_uinst hd).n, args with
                | Tm_fvar fv, [_; _; (a, _); (b, _)] when S.fv_eq_lid fv PC.lid_Mktuple2 ->
                    BU.bind_opt (try_unembed ea a norm) (fun a ->
                    BU.bind_opt (try_unembed eb b norm) (fun b ->
                    Some (a, b)))
                | _ -> None)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_t_pair_a_b

let e_tuple3 (ea:embedding 'a) (eb:embedding 'b) (ec:embedding 'c) =
    let typ = S.t_tuple3_of (type_of ea) (type_of eb) (type_of ec) in
    let emb_t_pair_a_b_c =
        ET_app(PC.lid_tuple3 |> Ident.string_of_lid, [emb_typ_of ea; emb_typ_of eb; emb_typ_of ec])
    in
    let printer (x, y, z) =
        BU.format3 "(%s, %s, %s)" (printer_of ea x) (printer_of eb y) (printer_of ec z)
    in
    let em ((x1, x2, x3):('a * 'b * 'c)) (rng:range) shadow norm : term =
        lazy_embed
            printer
            emb_t_pair_a_b_c
            rng
            typ
            (x1, x2, x3)
            (fun () ->
                let proj i abc =
                    let proj_i = U.mk_field_projector_name (PC.mk_tuple_data_lid 3 rng) (S.null_bv S.tun) i in
                    let proj_i_tm = S.fv_to_tm (lid_as_fv proj_i None) in
                    S.mk_Tm_app (S.mk_Tm_uinst proj_i_tm [U_zero])
                                [S.iarg (type_of ea);
                                 S.iarg (type_of eb);
                                 S.iarg (type_of ec);
                                 S.as_arg abc] // abc == shadow
                                rng
                in
                let shadow_a = map_shadow shadow (proj 1) in
                let shadow_b = map_shadow shadow (proj 2) in
                let shadow_c = map_shadow shadow (proj 3) in
                S.mk_Tm_app (S.mk_Tm_uinst (S.tdataconstr PC.lid_Mktuple3) [U_zero;U_zero;U_zero])
                            [S.iarg (type_of ea);
                             S.iarg (type_of eb);
                             S.iarg (type_of ec);
                             S.as_arg (embed ea x1 rng shadow_a norm);
                             S.as_arg (embed eb x2 rng shadow_b norm);
                             S.as_arg (embed ec x3 rng shadow_c norm)]
                            rng)
    in
    let un (t:term) norm : option ('a * 'b * 'c) =
        lazy_unembed
            printer
            emb_t_pair_a_b_c
            t
            typ
            (fun t ->
                let hd, args = U.head_and_args_full t in
                match (U.un_uinst hd).n, args with
                | Tm_fvar fv, [_; _; _; (a, _); (b, _); (c, _)] when S.fv_eq_lid fv PC.lid_Mktuple3 ->
                    BU.bind_opt (try_unembed ea a norm) (fun a ->
                    BU.bind_opt (try_unembed eb b norm) (fun b ->
                    BU.bind_opt (try_unembed ec c norm) (fun c ->
                    Some (a, b, c))))
                | _ -> None)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_t_pair_a_b_c

let e_either (ea:embedding 'a) (eb:embedding 'b) =
    let typ = S.t_either_of (type_of ea) (type_of eb) in
    let emb_t_sum_a_b =
        ET_app(PC.either_lid |> Ident.string_of_lid, [emb_typ_of ea; emb_typ_of eb])
    in
    let printer s =
        match s with
        | Inl a -> BU.format1 "Inl %s" (printer_of ea a)
        | Inr b -> BU.format1 "Inr %s" (printer_of eb b)
    in
    let em (s:either 'a 'b) (rng:range) shadow norm : term =
        lazy_embed
            printer
            emb_t_sum_a_b
            rng
            typ
            s
            (* Eagerly compute which closure we want, but thunk the actual embedding *)
            (match s with
             | Inl a ->
                (fun () ->
                let shadow_a = map_shadow shadow (fun t ->
                  let v = Ident.mk_ident ("v", rng) in
                  let some_v = U.mk_field_projector_name_from_ident PC.inl_lid v in
                  let some_v_tm = S.fv_to_tm (lid_as_fv some_v None) in
                  S.mk_Tm_app (S.mk_Tm_uinst some_v_tm [U_zero])
                              [S.iarg (type_of ea); S.iarg (type_of eb); S.as_arg t]
                              rng)
                in
                S.mk_Tm_app (S.mk_Tm_uinst (S.tdataconstr PC.inl_lid) [U_zero;U_zero])
                            [S.iarg (type_of ea);
                             S.iarg (type_of eb);
                             S.as_arg (embed ea a rng shadow_a norm)]
                            rng)
             | Inr b ->
                (fun () ->
                let shadow_b = map_shadow shadow (fun t ->
                  let v = Ident.mk_ident ("v", rng) in
                  let some_v = U.mk_field_projector_name_from_ident PC.inr_lid v in
                  let some_v_tm = S.fv_to_tm (lid_as_fv some_v None) in
                  S.mk_Tm_app (S.mk_Tm_uinst some_v_tm [U_zero])
                              [S.iarg (type_of ea); S.iarg (type_of eb); S.as_arg t]
                              rng)
                in
                S.mk_Tm_app (S.mk_Tm_uinst (S.tdataconstr PC.inr_lid) [U_zero;U_zero])
                            [S.iarg (type_of ea);
                             S.iarg (type_of eb);
                             S.as_arg (embed eb b rng shadow_b norm)]
                            rng)
             )
    in
    let un (t:term) norm : option (either 'a 'b) =
        lazy_unembed
            printer
            emb_t_sum_a_b
            t
            typ
            (fun t ->
                let hd, args = U.head_and_args_full t in
                match (U.un_uinst hd).n, args with
                | Tm_fvar fv, [_; _; (a, _)] when S.fv_eq_lid fv PC.inl_lid ->
                    BU.bind_opt (try_unembed ea a norm) (fun a ->
                    Some (Inl a))
                | Tm_fvar fv, [_; _; (b, _)] when S.fv_eq_lid fv PC.inr_lid ->
                    BU.bind_opt (try_unembed eb b norm) (fun b ->
                    Some (Inr b))
                | _ ->
                    None)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_t_sum_a_b

let e_list (ea:embedding 'a) =
    let typ = S.t_list_of (type_of ea) in
    let emb_t_list_a =
        ET_app(PC.list_lid |> Ident.string_of_lid, [emb_typ_of ea])
    in
    let printer =
        (fun (l:list 'a) -> "[" ^ (List.map (printer_of ea) l |> String.concat "; ") ^ "]")
    in
    let rec em (l:list 'a) (rng:range) shadow_l norm : term =
        lazy_embed
            printer
            emb_t_list_a
            rng
            typ
            l
            (fun () ->
                let t = S.iarg (type_of ea) in
                match l with
                | [] ->
                  S.mk_Tm_app (S.mk_Tm_uinst (S.tdataconstr PC.nil_lid) [U_zero]) //NS: the universe here is bogus
                              [t]
                              rng
                | hd::tl ->
                  let cons =
                      S.mk_Tm_uinst (S.tdataconstr PC.cons_lid) [U_zero]
                  in
                  let proj f cons_tm =
                    let fid = Ident.mk_ident (f, rng) in
                    let proj = U.mk_field_projector_name_from_ident PC.cons_lid fid in
                    let proj_tm = S.fv_to_tm (lid_as_fv proj None) in
                    S.mk_Tm_app (S.mk_Tm_uinst proj_tm [U_zero])
                                [S.iarg (type_of ea);
                                 S.as_arg cons_tm]
                                rng
                  in
                  let shadow_hd = map_shadow shadow_l (proj "hd") in
                  let shadow_tl = map_shadow shadow_l (proj "tl") in
                  S.mk_Tm_app cons
                              [t;
                               S.as_arg (embed ea hd rng shadow_hd norm);
                               S.as_arg (em tl rng shadow_tl norm)]
                              rng)
    in
    let rec un (t:term) norm : option (list 'a) =
        lazy_unembed
            printer
            emb_t_list_a
            t
            typ
            (fun t ->
                let hd, args = U.head_and_args_full t in
                match (U.un_uinst hd).n, args with
                | Tm_fvar fv, _
                    when S.fv_eq_lid fv PC.nil_lid -> Some []

                | Tm_fvar fv, [(_, Some ({aqual_implicit=true})); (hd, None); (tl, None)]
                | Tm_fvar fv, [(hd, None); (tl, None)]
                    when S.fv_eq_lid fv PC.cons_lid ->
                    BU.bind_opt (try_unembed ea hd norm) (fun hd ->
                    BU.bind_opt (un tl norm) (fun tl ->
                    Some (hd :: tl)))
                | _ ->
                    None)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_t_list_a

let e_string_list = e_list e_string

(* the steps as terms *)
let steps_Simpl         = tconst PC.steps_simpl
let steps_Weak          = tconst PC.steps_weak
let steps_HNF           = tconst PC.steps_hnf
let steps_Primops       = tconst PC.steps_primops
let steps_Delta         = tconst PC.steps_delta
let steps_Zeta          = tconst PC.steps_zeta
let steps_ZetaFull      = tconst PC.steps_zeta_full
let steps_Iota          = tconst PC.steps_iota
let steps_Reify         = tconst PC.steps_reify
let steps_UnfoldOnly    = tconst PC.steps_unfoldonly
let steps_UnfoldFully   = tconst PC.steps_unfoldonly
let steps_UnfoldAttr    = tconst PC.steps_unfoldattr
let steps_UnfoldQual    = tconst PC.steps_unfoldqual
let steps_UnfoldNamespace = tconst PC.steps_unfoldnamespace
let steps_Unascribe     = tconst PC.steps_unascribe
let steps_NBE           = tconst PC.steps_nbe
let steps_Unmeta        = tconst PC.steps_unmeta

let e_norm_step : embedding Pervasives.norm_step =
    let typ = S.t_norm_step in
    let emb_t_norm_step = ET_app (PC.norm_step_lid |> Ident.string_of_lid, []) in
    let printer _ = "norm_step" in
    let em (n:Pervasives.norm_step) (rng:range) _shadow norm : term =
        lazy_embed
            printer
            emb_t_norm_step
            rng
            typ
            n
            (fun () ->
                match n with
                | Simpl ->
                    steps_Simpl
                | Weak ->
                    steps_Weak
                | HNF ->
                    steps_HNF
                | Primops ->
                    steps_Primops
                | Delta ->
                    steps_Delta
                | Zeta ->
                    steps_Zeta
                | ZetaFull ->
                    steps_ZetaFull
                | Iota ->
                    steps_Iota
                | Unascribe ->
                    steps_Unascribe
                | NBE ->
                    steps_NBE
                | Unmeta ->
                    steps_Unmeta
                | Reify ->
                    steps_Reify
                | UnfoldOnly l ->
                    S.mk_Tm_app steps_UnfoldOnly [S.as_arg (embed (e_list e_string) l rng None norm)]
                                rng
                | UnfoldFully l ->
                    S.mk_Tm_app steps_UnfoldFully [S.as_arg (embed (e_list e_string) l rng None norm)]
                                rng
                | UnfoldAttr l ->
                    S.mk_Tm_app steps_UnfoldAttr [S.as_arg (embed (e_list e_string) l rng None norm)]
                                rng
                | UnfoldQual l ->
                    S.mk_Tm_app steps_UnfoldQual [S.as_arg (embed (e_list e_string) l rng None norm)]
                                rng
                | UnfoldNamespace l ->
                    S.mk_Tm_app steps_UnfoldNamespace [S.as_arg (embed (e_list e_string) l rng None norm)]
                                rng


                )
    in
    let un (t:term) norm : option Pervasives.norm_step =
        lazy_unembed
            printer
            emb_t_norm_step
            t
            typ
            (fun t ->
                let hd, args = U.head_and_args t in
                match (U.un_uinst hd).n, args with
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_simpl ->
                    Some Simpl
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_weak ->
                    Some Weak
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_hnf ->
                    Some HNF
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_primops ->
                    Some Primops
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_delta ->
                    Some Delta
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_zeta ->
                    Some Zeta
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_zeta_full ->
                    Some ZetaFull
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_iota ->
                    Some Iota
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_unascribe ->
                    Some Unascribe
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_nbe ->
                    Some NBE
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_unmeta ->
                    Some Unmeta
                | Tm_fvar fv, [] when S.fv_eq_lid fv PC.steps_reify ->
                    Some Reify
                | Tm_fvar fv, [(l, _)] when S.fv_eq_lid fv PC.steps_unfoldonly ->
                    BU.bind_opt (try_unembed (e_list e_string) l norm) (fun ss ->
                    Some <| UnfoldOnly ss)
                | Tm_fvar fv, [(l, _)] when S.fv_eq_lid fv PC.steps_unfoldfully ->
                    BU.bind_opt (try_unembed (e_list e_string) l norm) (fun ss ->
                    Some <| UnfoldFully ss)
                | Tm_fvar fv, [(l, _)] when S.fv_eq_lid fv PC.steps_unfoldattr ->
                    BU.bind_opt (try_unembed (e_list e_string) l norm) (fun ss ->
                    Some <| UnfoldAttr ss)
                | Tm_fvar fv, [(l, _)] when S.fv_eq_lid fv PC.steps_unfoldqual ->
                    BU.bind_opt (try_unembed (e_list e_string) l norm) (fun ss ->
                    Some <| UnfoldQual ss)
                | Tm_fvar fv, [(l, _)] when S.fv_eq_lid fv PC.steps_unfoldnamespace ->
                    BU.bind_opt (try_unembed (e_list e_string) l norm) (fun ss ->
                    Some <| UnfoldNamespace ss)
                | _ -> None)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_t_norm_step

let e_vconfig =
    let em (vcfg:vconfig) (rng:Range.range) _shadow norm : term =
      (* The order is very important here, even if this is a record. *)
      S.mk_Tm_app (tdataconstr PC.mkvconfig_lid) // TODO: should this be a record constructor? does it matter?
                  [S.as_arg (embed e_fsint             vcfg.initial_fuel                              rng None norm);
                   S.as_arg (embed e_fsint             vcfg.max_fuel                                  rng None norm);
                   S.as_arg (embed e_fsint             vcfg.initial_ifuel                             rng None norm);
                   S.as_arg (embed e_fsint             vcfg.max_ifuel                                 rng None norm);
                   S.as_arg (embed e_bool              vcfg.detail_errors                             rng None norm);
                   S.as_arg (embed e_bool              vcfg.detail_hint_replay                        rng None norm);
                   S.as_arg (embed e_bool              vcfg.no_smt                                    rng None norm);
                   S.as_arg (embed e_fsint             vcfg.quake_lo                                  rng None norm);
                   S.as_arg (embed e_fsint             vcfg.quake_hi                                  rng None norm);
                   S.as_arg (embed e_bool              vcfg.quake_keep                                rng None norm);
                   S.as_arg (embed e_bool              vcfg.retry                                     rng None norm);
                   S.as_arg (embed e_bool              vcfg.smtencoding_elim_box                      rng None norm);
                   S.as_arg (embed e_string            vcfg.smtencoding_nl_arith_repr                 rng None norm);
                   S.as_arg (embed e_string            vcfg.smtencoding_l_arith_repr                  rng None norm);
                   S.as_arg (embed e_bool              vcfg.smtencoding_valid_intro                   rng None norm);
                   S.as_arg (embed e_bool              vcfg.smtencoding_valid_elim                    rng None norm);
                   S.as_arg (embed e_bool              vcfg.tcnorm                                    rng None norm);
                   S.as_arg (embed e_bool              vcfg.no_plugins                                rng None norm);
                   S.as_arg (embed e_bool              vcfg.no_tactics                                rng None norm);
                   S.as_arg (embed e_string_list       vcfg.z3cliopt                                  rng None norm);
                   S.as_arg (embed e_string_list       vcfg.z3smtopt                                  rng None norm);
                   S.as_arg (embed e_bool              vcfg.z3refresh                                 rng None norm);
                   S.as_arg (embed e_fsint             vcfg.z3rlimit                                  rng None norm);
                   S.as_arg (embed e_fsint             vcfg.z3rlimit_factor                           rng None norm);
                   S.as_arg (embed e_fsint             vcfg.z3seed                                    rng None norm);
                   S.as_arg (embed e_string            vcfg.z3version                                 rng None norm);
                   S.as_arg (embed e_bool              vcfg.trivial_pre_for_unannotated_effectful_fns rng None norm);
                   S.as_arg (embed (e_option e_string) vcfg.reuse_hint_for                            rng None norm);
                  ]
                  rng
    in
    let un (t:term) norm : option vconfig =
        let hd, args = U.head_and_args t in
        match (U.un_uinst hd).n, args with
        (* Sigh *)
        | Tm_fvar fv, [
            (initial_fuel, _);
            (max_fuel, _);
            (initial_ifuel, _);
            (max_ifuel, _);
            (detail_errors, _);
            (detail_hint_replay, _);
            (no_smt, _);
            (quake_lo, _);
            (quake_hi, _);
            (quake_keep, _);
            (retry, _);
            (smtencoding_elim_box, _);
            (smtencoding_nl_arith_repr, _);
            (smtencoding_l_arith_repr, _);
            (smtencoding_valid_intro, _);
            (smtencoding_valid_elim, _);
            (tcnorm, _);
            (no_plugins, _);
            (no_tactics, _);
            (z3cliopt, _);
            (z3smtopt, _);
            (z3refresh, _);
            (z3rlimit, _);
            (z3rlimit_factor, _);
            (z3seed, _);
            (z3version, _);
            (trivial_pre_for_unannotated_effectful_fns, _);
            (reuse_hint_for, _)
            ] when S.fv_eq_lid fv PC.mkvconfig_lid ->
                  BU.bind_opt (try_unembed e_fsint             initial_fuel norm) (fun initial_fuel ->
                  BU.bind_opt (try_unembed e_fsint             max_fuel norm) (fun max_fuel ->
                  BU.bind_opt (try_unembed e_fsint             initial_ifuel norm) (fun initial_ifuel ->
                  BU.bind_opt (try_unembed e_fsint             max_ifuel norm) (fun max_ifuel ->
                  BU.bind_opt (try_unembed e_bool              detail_errors norm) (fun detail_errors ->
                  BU.bind_opt (try_unembed e_bool              detail_hint_replay norm) (fun detail_hint_replay ->
                  BU.bind_opt (try_unembed e_bool              no_smt norm) (fun no_smt ->
                  BU.bind_opt (try_unembed e_fsint             quake_lo norm) (fun quake_lo ->
                  BU.bind_opt (try_unembed e_fsint             quake_hi norm) (fun quake_hi ->
                  BU.bind_opt (try_unembed e_bool              quake_keep norm) (fun quake_keep ->
                  BU.bind_opt (try_unembed e_bool              retry norm) (fun retry ->
                  BU.bind_opt (try_unembed e_bool              smtencoding_elim_box norm) (fun smtencoding_elim_box ->
                  BU.bind_opt (try_unembed e_string            smtencoding_nl_arith_repr norm) (fun smtencoding_nl_arith_repr ->
                  BU.bind_opt (try_unembed e_string            smtencoding_l_arith_repr norm) (fun smtencoding_l_arith_repr ->
                  BU.bind_opt (try_unembed e_bool              smtencoding_valid_intro norm) (fun smtencoding_valid_intro ->
                  BU.bind_opt (try_unembed e_bool              smtencoding_valid_elim norm) (fun smtencoding_valid_elim ->
                  BU.bind_opt (try_unembed e_bool              tcnorm norm) (fun tcnorm ->
                  BU.bind_opt (try_unembed e_bool              no_plugins norm) (fun no_plugins ->
                  BU.bind_opt (try_unembed e_bool              no_tactics norm) (fun no_tactics ->
                  BU.bind_opt (try_unembed e_string_list       z3cliopt norm) (fun z3cliopt ->
                  BU.bind_opt (try_unembed e_string_list       z3smtopt norm) (fun z3smtopt ->
                  BU.bind_opt (try_unembed e_bool              z3refresh norm) (fun z3refresh ->
                  BU.bind_opt (try_unembed e_fsint             z3rlimit norm) (fun z3rlimit ->
                  BU.bind_opt (try_unembed e_fsint             z3rlimit_factor norm) (fun z3rlimit_factor ->
                  BU.bind_opt (try_unembed e_fsint             z3seed norm) (fun z3seed ->
                  BU.bind_opt (try_unembed e_string            z3version norm) (fun z3version ->
                  BU.bind_opt (try_unembed e_bool              trivial_pre_for_unannotated_effectful_fns norm) (fun trivial_pre_for_unannotated_effectful_fns ->
                  BU.bind_opt (try_unembed (e_option e_string) reuse_hint_for norm) (fun reuse_hint_for ->
                  Some ({
                    initial_fuel = initial_fuel;
                    max_fuel = max_fuel;
                    initial_ifuel = initial_ifuel;
                    max_ifuel = max_ifuel;
                    detail_errors = detail_errors;
                    detail_hint_replay = detail_hint_replay;
                    no_smt = no_smt;
                    quake_lo = quake_lo;
                    quake_hi = quake_hi;
                    quake_keep = quake_keep;
                    retry = retry;
                    smtencoding_elim_box = smtencoding_elim_box;
                    smtencoding_nl_arith_repr = smtencoding_nl_arith_repr;
                    smtencoding_l_arith_repr = smtencoding_l_arith_repr;
                    smtencoding_valid_intro = smtencoding_valid_intro;
                    smtencoding_valid_elim = smtencoding_valid_elim;
                    tcnorm = tcnorm;
                    no_plugins = no_plugins;
                    no_tactics = no_tactics;
                    z3cliopt = z3cliopt;
                    z3smtopt = z3smtopt;
                    z3refresh = z3refresh;
                    z3rlimit = z3rlimit;
                    z3rlimit_factor = z3rlimit_factor;
                    z3seed = z3seed;
                    z3version = z3version;
                    trivial_pre_for_unannotated_effectful_fns = trivial_pre_for_unannotated_effectful_fns;
                    reuse_hint_for = reuse_hint_for;
                  })))))))))))))))))))))))))))))
        | _ ->
          None
    in
    mk_emb_full
        em
        un
        S.t_vconfig
        (fun _ -> "vconfig")
        (ET_app (PC.vconfig_lid |> Ident.string_of_lid, []))

let or_else (f: option 'a) (g:unit -> 'a) =
    match f with
    | Some x -> x
    | None -> g ()

let e_arrow (ea:embedding 'a) (eb:embedding 'b) : embedding ('a -> 'b) =
    let typ =
        S.mk (Tm_arrow {bs=[S.mk_binder (S.null_bv (type_of ea))];
                        comp=S.mk_Total (type_of eb)})
              Range.dummyRange
    in
    let emb_t_arr_a_b = ET_fun(emb_typ_of ea, emb_typ_of eb) in
    let printer (f:'a -> 'b) = "<fun>" in
    let em (f:'a -> 'b) rng shadow_f norm =
        // let f_wrapped (x:term) =
        //     let shadow_app = map_shadow shadow_f (fun f ->
        //         S.mk_Tm_app f [S.as_arg x] None rng)
        //     in
        //     or_else
        //     (BU.map_opt (unembed ea x true norm) (fun x ->
        //         embed eb (f x) rng shadow_app norm))
        //     (fun () ->
        //         match force_shadow shadow_app with
        //         | None -> raise Embedding_failure
        //         | Some app -> norm (BU.Inr app))
        // in
        lazy_embed
            printer
            emb_t_arr_a_b
            rng
            typ
            f //f_wrapped
            (fun () ->
                match force_shadow shadow_f with
                | None -> raise Embedding_failure //TODO: dodgy
                | Some repr_f ->
                  if !Options.debug_embedding then
                  BU.print2 "e_arrow forced back to term using shadow %s; repr=%s\n"
                                   (Print.term_to_string repr_f)
                                   (BU.stack_dump());
                  let res = norm (Inr repr_f) in
                  if !Options.debug_embedding then
                  BU.print3 "e_arrow forced back to term using shadow %s; repr=%s\n\t%s\n"
                                   (Print.term_to_string repr_f)
                                   (Print.term_to_string res)
                                   (BU.stack_dump());
                  res)
    in
    let un (f:term) norm : option ('a -> 'b) =
        lazy_unembed
            printer
            emb_t_arr_a_b
            f
            typ
            (fun f ->
                let f_wrapped (a:'a) : 'b =
                    if !Options.debug_embedding then
                    BU.print2 "Calling back into normalizer for %s\n%s\n"
                              (Print.term_to_string f)
                              (BU.stack_dump());
                    let a_tm = embed ea a f.pos None norm in
                    let b_tm = norm (Inr (S.mk_Tm_app f [S.as_arg a_tm] f.pos)) in
                    match unembed eb b_tm norm with
                    | None -> raise Unembedding_failure
                    | Some b -> b
                in
                Some f_wrapped)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_t_arr_a_b

let e_sealed (ea : embedding 'a) : embedding 'a =
    let typ = S.t_sealed_of (type_of ea) in
    let emb_ty_a =
        ET_app(PC.sealed_lid |> Ident.string_of_lid, [emb_typ_of ea])
    in
    let printer x = "(seal " ^ printer_of ea x ^ ")" in
    let em (a:'a) (rng:range) shadow norm : term =
        lazy_embed
            printer
            emb_ty_a
            rng
            typ
            a
            (fun () ->
                  let shadow_a =
                    (* TODO: this application below is in TAC.. OK? *)
                    map_shadow shadow (fun t ->
                      let unseal = U.fvar_const PC.unseal_lid in
                      S.mk_Tm_app (S.mk_Tm_uinst unseal [U_zero])
                                  [S.iarg (type_of ea); S.as_arg t]
                                  rng)
                  in
                  S.mk_Tm_app (S.mk_Tm_uinst (U.fvar_const PC.seal_lid) [U_zero])
                              [S.iarg (type_of ea); S.as_arg (embed ea a rng shadow_a norm)]
                              rng)
    in
    let un (t:term) norm : option (option 'a) =
        lazy_unembed
            printer
            emb_ty_a
            t
            typ
            (fun t ->
                let hd, args = U.head_and_args_full t in
                match (U.un_uinst hd).n, args with
                | Tm_fvar fv, [_; (a, _)] when S.fv_eq_lid fv PC.seal_lid ->
                     // Just relay it
                     try_unembed ea a norm
                | _ ->
                     None)
    in
    mk_emb_full
        em
        un
        typ
        printer
        emb_ty_a

(*
 * Embed a range as a FStar.Range.__range
 * The user usually manipulates a FStar.Range.range = sealed __range
 * See also e_range below.
 *)
let e___range =
    let em (r:range) (rng:range) _shadow _norm : term =
        S.mk (Tm_constant (C.Const_range r)) rng
    in
    let un (t:term) _norm : option range =
        match (SS.compress t).n with
        | Tm_constant (C.Const_range r) -> Some r
        | _ -> None
    in
    mk_emb_full
        em
        un
        S.t___range
        Range.string_of_range
        (ET_app (PC.range_lid |> Ident.string_of_lid, []))

let e_range = e_sealed e___range

let e_issue : embedding Err.issue = e_lazy Lazy_issue (S.fvar PC.issue_lid None)

 /////////////////////////////////////////////////////////////////////
 //Registering top-level functions
 /////////////////////////////////////////////////////////////////////

let arrow_as_prim_step_1 (ea:embedding 'a) (eb:embedding 'b)
                         (f:'a -> 'b) (n_tvars:int) (fv_lid:Ident.lid) norm
   : args -> option term =
    let rng = Ident.range_of_lid fv_lid in
    let f_wrapped args =
        let _tvar_args, rest_args = List.splitAt n_tvars args in
        //arity mismatches are handled by the caller
        let [(x, _)] = rest_args in
        let shadow_app =
            Some (Thunk.mk (fun () -> S.mk_Tm_app (norm (Inl fv_lid)) args rng))
        in
        match
            (BU.map_opt (try_unembed ea x norm) (fun x ->
             embed eb (f x) rng shadow_app norm))
        with
        // NB: this always returns a Some
        | Some x -> Some x
        | None -> force_shadow shadow_app
    in
    f_wrapped

let arrow_as_prim_step_2 (ea:embedding 'a) (eb:embedding 'b) (ec:embedding 'c)
                         (f:'a -> 'b -> 'c) n_tvars fv_lid norm
   : args -> option term =
    let rng = Ident.range_of_lid fv_lid in
    let f_wrapped args =
        let _tvar_args, rest_args = List.splitAt n_tvars args in
        //arity mismatches are handled by the caller
        let [(x, _); (y, _)] = rest_args in
        let shadow_app =
            Some (Thunk.mk (fun () -> S.mk_Tm_app (norm (Inl fv_lid)) args rng))
        in
        match
            (BU.bind_opt (try_unembed ea x norm) (fun x ->
             BU.bind_opt (try_unembed eb y norm) (fun y ->
             Some (embed ec (f x y) rng shadow_app norm))))
        with
        // NB: this always returns a Some
        | Some x -> Some x
        | None -> force_shadow shadow_app
    in
    f_wrapped

let arrow_as_prim_step_3 (ea:embedding 'a) (eb:embedding 'b)
                         (ec:embedding 'c) (ed:embedding 'd)
                         (f:'a -> 'b -> 'c -> 'd) n_tvars fv_lid norm
   : args -> option term =
    let rng = Ident.range_of_lid fv_lid in
    let f_wrapped args =
        let _tvar_args, rest_args = List.splitAt n_tvars args in
        //arity mismatches are handled by the caller
        let [(x, _); (y, _); (z, _)] = rest_args in
        let shadow_app =
            Some (Thunk.mk (fun () -> S.mk_Tm_app (norm (Inl fv_lid)) args rng))
        in
        match
            (BU.bind_opt (try_unembed ea x norm) (fun x ->
             BU.bind_opt (try_unembed eb y norm) (fun y ->
             BU.bind_opt (try_unembed ec z norm) (fun z ->
             Some (embed ed (f x y z) rng shadow_app norm)))))
        with
        // NB: this always returns a Some
        | Some x -> Some x
        | None -> force_shadow shadow_app
    in
    f_wrapped

let debug_wrap (s:string) (f:unit -> 'a) =
    if !Options.debug_embedding
    then BU.print1 "++++starting %s\n" s;
    let res = f () in
    if !Options.debug_embedding
    then BU.print1 "------ending %s\n" s;
    res
