(*
   Copyright 2008-2018 Microsoft Research

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
﻿#light "off"

module FStar.SMTEncoding.Util
open FStar.ST
open FStar.All

open FStar
open FStar.TypeChecker.Env
open FStar.Util
open FStar.Syntax
open FStar.Syntax.Syntax
open FStar.TypeChecker
open FStar.SMTEncoding.Term
open FStar.Ident
open FStar.Const
module S = FStar.Syntax.Syntax
module SS = FStar.Syntax.Subst
module N = FStar.TypeChecker.Normalize

let mkAssume (tm, cap, nm) =
    Assume ({
        assumption_name=escape nm;
        assumption_caption=cap;
        assumption_term=tm;
        assumption_fact_ids=[]
    })
let norng f = fun x -> f x Range.dummyRange
let mkTrue   = mkTrue Range.dummyRange
let mkFalse  = mkFalse Range.dummyRange
let mkInteger  = norng mkInteger
let mkInteger' = norng mkInteger'
let mkBoundV   = norng mkBoundV
let mkFreeV    = norng mkFreeV
let mkApp'     = norng mkApp'
let mkApp      = norng mkApp
let mkNot = norng mkNot
let mkMinus = norng mkMinus
let mkAnd = norng mkAnd
let mkOr = norng mkOr
let mkImp = norng mkImp
let mkIff = norng mkIff
let mkEq = norng mkEq
let mkLT = norng mkLT
let mkLTE = norng mkLTE
let mkGT = norng mkGT
let mkGTE = norng mkGTE
let mkAdd = norng mkAdd
let mkSub = norng mkSub
let mkDiv = norng mkDiv
let mkMul = norng mkMul
let mkMod = norng mkMod
let mkNatToBv sz = norng (mkNatToBv sz)
let mkBvAnd = norng mkBvAnd
let mkBvXor = norng mkBvXor
let mkBvOr = norng mkBvOr
let mkBvAdd = norng mkBvAdd
let mkBvSub = norng mkBvSub
let mkBvShl sz = norng (mkBvShl sz)
let mkBvShr sz = norng (mkBvShr sz)
let mkBvUdiv sz = norng (mkBvUdiv sz)
let mkBvMod sz = norng (mkBvMod sz)
let mkBvMul sz = norng (mkBvMul sz)
let mkBvUlt = norng mkBvUlt
let mkBvUext sz = norng (mkBvUext sz)
let mkBvToNat = norng mkBvToNat
let mkITE = norng mkITE
let mkCases = norng mkCases

let norng2 f = fun x y -> f x y Range.dummyRange
let norng3 f = fun x y z -> f x y z Range.dummyRange
let norng4 f = fun x y z w -> f x y z w Range.dummyRange
let mk_Term_app  = norng2 mk_Term_app
let mk_Term_uvar = norng mk_Term_uvar
let mk_and_l = norng mk_and_l
let mk_or_l = norng mk_or_l
let mk_ApplyTT = norng2 mk_ApplyTT
let mk_String_const = norng mk_String_const
let mk_Precedes = norng4 mk_Precedes
let mk_LexCons = norng3 mk_LexCons

