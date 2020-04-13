open Prims
let mkForall_fuel' :
  'uuuuuu14 .
    Prims.string ->
      FStar_Range.range ->
        'uuuuuu14 ->
          (FStar_SMTEncoding_Term.pat Prims.list Prims.list *
            FStar_SMTEncoding_Term.fvs * FStar_SMTEncoding_Term.term) ->
            FStar_SMTEncoding_Term.term
  =
  fun mname  ->
    fun r  ->
      fun n  ->
        fun uu____45  ->
          match uu____45 with
          | (pats,vars,body) ->
              let fallback uu____73 =
                FStar_SMTEncoding_Term.mkForall r (pats, vars, body)  in
              let uu____78 = FStar_Options.unthrottle_inductives ()  in
              if uu____78
              then fallback ()
              else
                (let uu____83 =
                   FStar_SMTEncoding_Env.fresh_fvar mname "f"
                     FStar_SMTEncoding_Term.Fuel_sort
                    in
                 match uu____83 with
                 | (fsym,fterm) ->
                     let add_fuel tms =
                       FStar_All.pipe_right tms
                         (FStar_List.map
                            (fun p  ->
                               match p.FStar_SMTEncoding_Term.tm with
                               | FStar_SMTEncoding_Term.App
                                   (FStar_SMTEncoding_Term.Var
                                    "HasType",args)
                                   ->
                                   FStar_SMTEncoding_Util.mkApp
                                     ("HasTypeFuel", (fterm :: args))
                               | uu____123 -> p))
                        in
                     let pats1 = FStar_List.map add_fuel pats  in
                     let body1 =
                       match body.FStar_SMTEncoding_Term.tm with
                       | FStar_SMTEncoding_Term.App
                           (FStar_SMTEncoding_Term.Imp ,guard::body'::[]) ->
                           let guard1 =
                             match guard.FStar_SMTEncoding_Term.tm with
                             | FStar_SMTEncoding_Term.App
                                 (FStar_SMTEncoding_Term.And ,guards) ->
                                 let uu____144 = add_fuel guards  in
                                 FStar_SMTEncoding_Util.mk_and_l uu____144
                             | uu____147 ->
                                 let uu____148 = add_fuel [guard]  in
                                 FStar_All.pipe_right uu____148 FStar_List.hd
                              in
                           FStar_SMTEncoding_Util.mkImp (guard1, body')
                       | uu____153 -> body  in
                     let vars1 =
                       let uu____165 =
                         FStar_SMTEncoding_Term.mk_fv
                           (fsym, FStar_SMTEncoding_Term.Fuel_sort)
                          in
                       uu____165 :: vars  in
                     FStar_SMTEncoding_Term.mkForall r (pats1, vars1, body1))
  
let (mkForall_fuel :
  Prims.string ->
    FStar_Range.range ->
      (FStar_SMTEncoding_Term.pat Prims.list Prims.list *
        FStar_SMTEncoding_Term.fvs * FStar_SMTEncoding_Term.term) ->
        FStar_SMTEncoding_Term.term)
  = fun mname  -> fun r  -> mkForall_fuel' mname r Prims.int_one 
let (head_normal :
  FStar_SMTEncoding_Env.env_t -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun env  ->
    fun t  ->
      let t1 = FStar_Syntax_Util.unmeta t  in
      match t1.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_arrow uu____229 -> true
      | FStar_Syntax_Syntax.Tm_refine uu____245 -> true
      | FStar_Syntax_Syntax.Tm_bvar uu____253 -> true
      | FStar_Syntax_Syntax.Tm_uvar uu____255 -> true
      | FStar_Syntax_Syntax.Tm_abs uu____269 -> true
      | FStar_Syntax_Syntax.Tm_constant uu____289 -> true
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          let uu____292 =
            FStar_TypeChecker_Env.lookup_definition
              [FStar_TypeChecker_Env.Eager_unfolding_only]
              env.FStar_SMTEncoding_Env.tcenv
              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
             in
          FStar_All.pipe_right uu____292 FStar_Option.isNone
      | FStar_Syntax_Syntax.Tm_app
          ({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv;
             FStar_Syntax_Syntax.pos = uu____311;
             FStar_Syntax_Syntax.vars = uu____312;_},uu____313)
          ->
          let uu____338 =
            FStar_TypeChecker_Env.lookup_definition
              [FStar_TypeChecker_Env.Eager_unfolding_only]
              env.FStar_SMTEncoding_Env.tcenv
              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
             in
          FStar_All.pipe_right uu____338 FStar_Option.isNone
      | uu____356 -> false
  
let (head_redex :
  FStar_SMTEncoding_Env.env_t -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun env  ->
    fun t  ->
      let uu____370 =
        let uu____371 = FStar_Syntax_Util.un_uinst t  in
        uu____371.FStar_Syntax_Syntax.n  in
      match uu____370 with
      | FStar_Syntax_Syntax.Tm_abs
          (uu____375,uu____376,FStar_Pervasives_Native.Some rc) ->
          ((FStar_Ident.lid_equals rc.FStar_Syntax_Syntax.residual_effect
              FStar_Parser_Const.effect_Tot_lid)
             ||
             (FStar_Ident.lid_equals rc.FStar_Syntax_Syntax.residual_effect
                FStar_Parser_Const.effect_GTot_lid))
            ||
            (FStar_List.existsb
               (fun uu___0_401  ->
                  match uu___0_401 with
                  | FStar_Syntax_Syntax.TOTAL  -> true
                  | uu____404 -> false) rc.FStar_Syntax_Syntax.residual_flags)
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          let uu____407 =
            FStar_TypeChecker_Env.lookup_definition
              [FStar_TypeChecker_Env.Eager_unfolding_only]
              env.FStar_SMTEncoding_Env.tcenv
              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
             in
          FStar_All.pipe_right uu____407 FStar_Option.isSome
      | uu____425 -> false
  
let (norm_with_steps :
  FStar_TypeChecker_Env.steps ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun steps  ->
    fun env  ->
      fun t  ->
        let uu____443 =
          let uu____447 =
            let uu____449 = FStar_TypeChecker_Env.current_module env  in
            FStar_Ident.string_of_lid uu____449  in
          FStar_Pervasives_Native.Some uu____447  in
        FStar_Profiling.profile
          (fun uu____452  ->
             FStar_TypeChecker_Normalize.normalize steps env t) uu____443
          "FStar.TypeChecker.SMTEncoding.EncodeTerm.norm_with_steps"
  
let (normalize_refinement :
  FStar_TypeChecker_Env.steps ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.typ)
  =
  fun steps  ->
    fun env  ->
      fun t  ->
        let uu____470 =
          let uu____474 =
            let uu____476 = FStar_TypeChecker_Env.current_module env  in
            FStar_Ident.string_of_lid uu____476  in
          FStar_Pervasives_Native.Some uu____474  in
        FStar_Profiling.profile
          (fun uu____479  ->
             FStar_TypeChecker_Normalize.normalize_refinement steps env t)
          uu____470
          "FStar.TypeChecker.SMTEncoding.EncodeTerm.normalize_refinement"
  
let (whnf :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun t  ->
      let uu____492 = head_normal env t  in
      if uu____492
      then t
      else
        norm_with_steps
          [FStar_TypeChecker_Env.Beta;
          FStar_TypeChecker_Env.Weak;
          FStar_TypeChecker_Env.HNF;
          FStar_TypeChecker_Env.Exclude FStar_TypeChecker_Env.Zeta;
          FStar_TypeChecker_Env.Eager_unfolding;
          FStar_TypeChecker_Env.EraseUniverses]
          env.FStar_SMTEncoding_Env.tcenv t
  
let (norm :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun t  ->
      norm_with_steps
        [FStar_TypeChecker_Env.Beta;
        FStar_TypeChecker_Env.Exclude FStar_TypeChecker_Env.Zeta;
        FStar_TypeChecker_Env.Eager_unfolding;
        FStar_TypeChecker_Env.EraseUniverses] env.FStar_SMTEncoding_Env.tcenv
        t
  
let (maybe_whnf :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun env  ->
    fun t  ->
      let t' = whnf env t  in
      let uu____522 = FStar_Syntax_Util.head_and_args t'  in
      match uu____522 with
      | (head',uu____542) ->
          let uu____567 = head_redex env head'  in
          if uu____567
          then FStar_Pervasives_Native.None
          else FStar_Pervasives_Native.Some t'
  
let (trivial_post : FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) =
  fun t  ->
    let uu____580 =
      let uu____581 = FStar_Syntax_Syntax.null_binder t  in [uu____581]  in
    let uu____600 =
      FStar_Syntax_Syntax.fvar FStar_Parser_Const.true_lid
        FStar_Syntax_Syntax.delta_constant FStar_Pervasives_Native.None
       in
    FStar_Syntax_Util.abs uu____580 uu____600 FStar_Pervasives_Native.None
  
let (mk_Apply :
  FStar_SMTEncoding_Term.term ->
    FStar_SMTEncoding_Term.fvs -> FStar_SMTEncoding_Term.term)
  =
  fun e  ->
    fun vars  ->
      FStar_All.pipe_right vars
        (FStar_List.fold_left
           (fun out  ->
              fun var  ->
                let uu____622 = FStar_SMTEncoding_Term.fv_sort var  in
                match uu____622 with
                | FStar_SMTEncoding_Term.Fuel_sort  ->
                    let uu____623 = FStar_SMTEncoding_Util.mkFreeV var  in
                    FStar_SMTEncoding_Term.mk_ApplyTF out uu____623
                | s ->
                    let uu____625 = FStar_SMTEncoding_Util.mkFreeV var  in
                    FStar_SMTEncoding_Util.mk_ApplyTT out uu____625) e)
  
let (mk_Apply_args :
  FStar_SMTEncoding_Term.term ->
    FStar_SMTEncoding_Term.term Prims.list -> FStar_SMTEncoding_Term.term)
  =
  fun e  ->
    fun args  ->
      FStar_All.pipe_right args
        (FStar_List.fold_left FStar_SMTEncoding_Util.mk_ApplyTT e)
  
let raise_arity_mismatch :
  'a . Prims.string -> Prims.int -> Prims.int -> FStar_Range.range -> 'a =
  fun head  ->
    fun arity  ->
      fun n_args  ->
        fun rng  ->
          let uu____681 =
            let uu____687 =
              let uu____689 = FStar_Util.string_of_int arity  in
              let uu____691 = FStar_Util.string_of_int n_args  in
              FStar_Util.format3
                "Head symbol %s expects at least %s arguments; got only %s"
                head uu____689 uu____691
               in
            (FStar_Errors.Fatal_SMTEncodingArityMismatch, uu____687)  in
          FStar_Errors.raise_error uu____681 rng
  
let (isTotFun_axioms :
  FStar_Range.range ->
    FStar_SMTEncoding_Term.term ->
      FStar_SMTEncoding_Term.fvs ->
        FStar_SMTEncoding_Term.term Prims.list ->
          Prims.bool -> FStar_SMTEncoding_Term.term)
  =
  fun pos  ->
    fun head  ->
      fun vars  ->
        fun guards  ->
          fun is_pure  ->
            let maybe_mkForall pat vars1 body =
              match vars1 with
              | [] -> body
              | uu____779 ->
                  FStar_SMTEncoding_Term.mkForall pos (pat, vars1, body)
               in
            let rec is_tot_fun_axioms ctx ctx_guard head1 vars1 guards1 =
              match (vars1, guards1) with
              | ([],[]) -> FStar_SMTEncoding_Util.mkTrue
              | (uu____896::[],uu____897) ->
                  if is_pure
                  then
                    let uu____937 =
                      let uu____938 =
                        let uu____943 =
                          FStar_SMTEncoding_Term.mk_IsTotFun head1  in
                        (ctx_guard, uu____943)  in
                      FStar_SMTEncoding_Util.mkImp uu____938  in
                    maybe_mkForall [[head1]] ctx uu____937
                  else FStar_SMTEncoding_Util.mkTrue
              | (x::vars2,g_x::guards2) ->
                  let is_tot_fun_head =
                    let uu____995 =
                      let uu____996 =
                        let uu____1001 =
                          FStar_SMTEncoding_Term.mk_IsTotFun head1  in
                        (ctx_guard, uu____1001)  in
                      FStar_SMTEncoding_Util.mkImp uu____996  in
                    maybe_mkForall [[head1]] ctx uu____995  in
                  let app = mk_Apply head1 [x]  in
                  let ctx1 = FStar_List.append ctx [x]  in
                  let ctx_guard1 =
                    FStar_SMTEncoding_Util.mkAnd (ctx_guard, g_x)  in
                  let rest =
                    is_tot_fun_axioms ctx1 ctx_guard1 app vars2 guards2  in
                  FStar_SMTEncoding_Util.mkAnd (is_tot_fun_head, rest)
              | uu____1060 -> failwith "impossible: isTotFun_axioms"  in
            is_tot_fun_axioms [] FStar_SMTEncoding_Util.mkTrue head vars
              guards
  
let (maybe_curry_app :
  FStar_Range.range ->
    (FStar_SMTEncoding_Term.op,FStar_SMTEncoding_Term.term) FStar_Util.either
      ->
      Prims.int ->
        FStar_SMTEncoding_Term.term Prims.list -> FStar_SMTEncoding_Term.term)
  =
  fun rng  ->
    fun head  ->
      fun arity  ->
        fun args  ->
          let n_args = FStar_List.length args  in
          match head with
          | FStar_Util.Inr head1 -> mk_Apply_args head1 args
          | FStar_Util.Inl head1 ->
              if n_args = arity
              then FStar_SMTEncoding_Util.mkApp' (head1, args)
              else
                if n_args > arity
                then
                  (let uu____1131 = FStar_Util.first_N arity args  in
                   match uu____1131 with
                   | (args1,rest) ->
                       let head2 =
                         FStar_SMTEncoding_Util.mkApp' (head1, args1)  in
                       mk_Apply_args head2 rest)
                else
                  (let uu____1155 = FStar_SMTEncoding_Term.op_to_string head1
                      in
                   raise_arity_mismatch uu____1155 arity n_args rng)
  
let (maybe_curry_fvb :
  FStar_Range.range ->
    FStar_SMTEncoding_Env.fvar_binding ->
      FStar_SMTEncoding_Term.term Prims.list -> FStar_SMTEncoding_Term.term)
  =
  fun rng  ->
    fun fvb  ->
      fun args  ->
        if fvb.FStar_SMTEncoding_Env.fvb_thunked
        then
          let uu____1178 = FStar_SMTEncoding_Env.force_thunk fvb  in
          mk_Apply_args uu____1178 args
        else
          maybe_curry_app rng
            (FStar_Util.Inl
               (FStar_SMTEncoding_Term.Var (fvb.FStar_SMTEncoding_Env.smt_id)))
            fvb.FStar_SMTEncoding_Env.smt_arity args
  
let (is_app : FStar_SMTEncoding_Term.op -> Prims.bool) =
  fun uu___1_1187  ->
    match uu___1_1187 with
    | FStar_SMTEncoding_Term.Var "ApplyTT" -> true
    | FStar_SMTEncoding_Term.Var "ApplyTF" -> true
    | uu____1193 -> false
  
let (is_an_eta_expansion :
  FStar_SMTEncoding_Env.env_t ->
    FStar_SMTEncoding_Term.fv Prims.list ->
      FStar_SMTEncoding_Term.term ->
        FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option)
  =
  fun env  ->
    fun vars  ->
      fun body  ->
        let rec check_partial_applications t xs =
          match ((t.FStar_SMTEncoding_Term.tm), xs) with
          | (FStar_SMTEncoding_Term.App
             (app,f::{
                       FStar_SMTEncoding_Term.tm =
                         FStar_SMTEncoding_Term.FreeV y;
                       FStar_SMTEncoding_Term.freevars = uu____1241;
                       FStar_SMTEncoding_Term.rng = uu____1242;_}::[]),x::xs1)
              when (is_app app) && (FStar_SMTEncoding_Term.fv_eq x y) ->
              check_partial_applications f xs1
          | (FStar_SMTEncoding_Term.App
             (FStar_SMTEncoding_Term.Var f,args),uu____1273) ->
              let uu____1283 =
                ((FStar_List.length args) = (FStar_List.length xs)) &&
                  (FStar_List.forall2
                     (fun a  ->
                        fun v  ->
                          match a.FStar_SMTEncoding_Term.tm with
                          | FStar_SMTEncoding_Term.FreeV fv ->
                              FStar_SMTEncoding_Term.fv_eq fv v
                          | uu____1300 -> false) args (FStar_List.rev xs))
                 in
              if uu____1283
              then
                let n = FStar_SMTEncoding_Env.tok_of_name env f  in
                ((let uu____1309 =
                    FStar_All.pipe_left
                      (FStar_TypeChecker_Env.debug
                         env.FStar_SMTEncoding_Env.tcenv)
                      (FStar_Options.Other "PartialApp")
                     in
                  if uu____1309
                  then
                    let uu____1314 = FStar_SMTEncoding_Term.print_smt_term t
                       in
                    let uu____1316 =
                      match n with
                      | FStar_Pervasives_Native.None  -> "None"
                      | FStar_Pervasives_Native.Some x ->
                          FStar_SMTEncoding_Term.print_smt_term x
                       in
                    FStar_Util.print2
                      "is_eta_expansion %s  ... tok_of_name = %s\n"
                      uu____1314 uu____1316
                  else ());
                 n)
              else FStar_Pervasives_Native.None
          | (uu____1326,[]) ->
              let fvs = FStar_SMTEncoding_Term.free_variables t  in
              let uu____1330 =
                FStar_All.pipe_right fvs
                  (FStar_List.for_all
                     (fun fv  ->
                        let uu____1338 =
                          FStar_Util.for_some
                            (FStar_SMTEncoding_Term.fv_eq fv) vars
                           in
                        Prims.op_Negation uu____1338))
                 in
              if uu____1330
              then FStar_Pervasives_Native.Some t
              else FStar_Pervasives_Native.None
          | uu____1345 -> FStar_Pervasives_Native.None  in
        check_partial_applications body (FStar_List.rev vars)
  
let check_pattern_vars :
  'uuuuuu1363 'uuuuuu1364 .
    FStar_SMTEncoding_Env.env_t ->
      (FStar_Syntax_Syntax.bv * 'uuuuuu1363) Prims.list ->
        (FStar_Syntax_Syntax.term * 'uuuuuu1364) Prims.list -> unit
  =
  fun env  ->
    fun vars  ->
      fun pats  ->
        let pats1 =
          FStar_All.pipe_right pats
            (FStar_List.map
               (fun uu____1422  ->
                  match uu____1422 with
                  | (x,uu____1428) ->
                      norm_with_steps
                        [FStar_TypeChecker_Env.Beta;
                        FStar_TypeChecker_Env.AllowUnboundUniverses;
                        FStar_TypeChecker_Env.EraseUniverses]
                        env.FStar_SMTEncoding_Env.tcenv x))
           in
        match pats1 with
        | [] -> ()
        | hd::tl ->
            let pat_vars =
              let uu____1436 = FStar_Syntax_Free.names hd  in
              FStar_List.fold_left
                (fun out  ->
                   fun x  ->
                     let uu____1448 = FStar_Syntax_Free.names x  in
                     FStar_Util.set_union out uu____1448) uu____1436 tl
               in
            let uu____1451 =
              FStar_All.pipe_right vars
                (FStar_Util.find_opt
                   (fun uu____1478  ->
                      match uu____1478 with
                      | (b,uu____1485) ->
                          let uu____1486 = FStar_Util.set_mem b pat_vars  in
                          Prims.op_Negation uu____1486))
               in
            (match uu____1451 with
             | FStar_Pervasives_Native.None  -> ()
             | FStar_Pervasives_Native.Some (x,uu____1493) ->
                 let pos =
                   FStar_List.fold_left
                     (fun out  ->
                        fun t  ->
                          FStar_Range.union_ranges out
                            t.FStar_Syntax_Syntax.pos)
                     hd.FStar_Syntax_Syntax.pos tl
                    in
                 let uu____1507 =
                   let uu____1513 =
                     let uu____1515 = FStar_Syntax_Print.bv_to_string x  in
                     FStar_Util.format1
                       "SMT pattern misses at least one bound variable: %s"
                       uu____1515
                      in
                   (FStar_Errors.Warning_SMTPatternIllFormed, uu____1513)  in
                 FStar_Errors.log_issue pos uu____1507)
  
type label = (FStar_SMTEncoding_Term.fv * Prims.string * FStar_Range.range)
type labels = label Prims.list
type pattern =
  {
  pat_vars: (FStar_Syntax_Syntax.bv * FStar_SMTEncoding_Term.fv) Prims.list ;
  pat_term:
    unit -> (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t) ;
  guard: FStar_SMTEncoding_Term.term -> FStar_SMTEncoding_Term.term ;
  projections:
    FStar_SMTEncoding_Term.term ->
      (FStar_Syntax_Syntax.bv * FStar_SMTEncoding_Term.term) Prims.list
    }
let (__proj__Mkpattern__item__pat_vars :
  pattern -> (FStar_Syntax_Syntax.bv * FStar_SMTEncoding_Term.fv) Prims.list)
  =
  fun projectee  ->
    match projectee with
    | { pat_vars; pat_term; guard; projections;_} -> pat_vars
  
let (__proj__Mkpattern__item__pat_term :
  pattern ->
    unit -> (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun projectee  ->
    match projectee with
    | { pat_vars; pat_term; guard; projections;_} -> pat_term
  
let (__proj__Mkpattern__item__guard :
  pattern -> FStar_SMTEncoding_Term.term -> FStar_SMTEncoding_Term.term) =
  fun projectee  ->
    match projectee with
    | { pat_vars; pat_term; guard; projections;_} -> guard
  
let (__proj__Mkpattern__item__projections :
  pattern ->
    FStar_SMTEncoding_Term.term ->
      (FStar_Syntax_Syntax.bv * FStar_SMTEncoding_Term.term) Prims.list)
  =
  fun projectee  ->
    match projectee with
    | { pat_vars; pat_term; guard; projections;_} -> projections
  
let (as_function_typ :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun t0  ->
      let rec aux norm1 t =
        let t1 = FStar_Syntax_Subst.compress t  in
        match t1.FStar_Syntax_Syntax.n with
        | FStar_Syntax_Syntax.Tm_arrow uu____1801 -> t1
        | FStar_Syntax_Syntax.Tm_refine uu____1816 ->
            let uu____1823 = FStar_Syntax_Util.unrefine t1  in
            aux true uu____1823
        | uu____1825 ->
            if norm1
            then let uu____1827 = whnf env t1  in aux false uu____1827
            else
              (let uu____1831 =
                 let uu____1833 =
                   FStar_Range.string_of_range t0.FStar_Syntax_Syntax.pos  in
                 let uu____1835 = FStar_Syntax_Print.term_to_string t0  in
                 FStar_Util.format2 "(%s) Expected a function typ; got %s"
                   uu____1833 uu____1835
                  in
               failwith uu____1831)
         in
      aux true t0
  
let rec (curried_arrow_formals_comp :
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.comp))
  =
  fun k  ->
    let k1 = FStar_Syntax_Subst.compress k  in
    match k1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_arrow (bs,c) ->
        FStar_Syntax_Subst.open_comp bs c
    | FStar_Syntax_Syntax.Tm_refine (bv,uu____1877) ->
        let uu____1882 =
          curried_arrow_formals_comp bv.FStar_Syntax_Syntax.sort  in
        (match uu____1882 with
         | (args,res) ->
             (match args with
              | [] ->
                  let uu____1903 = FStar_Syntax_Syntax.mk_Total k1  in
                  ([], uu____1903)
              | uu____1910 -> (args, res)))
    | uu____1911 ->
        let uu____1912 = FStar_Syntax_Syntax.mk_Total k1  in ([], uu____1912)
  
let is_arithmetic_primitive :
  'uuuuuu1926 .
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      'uuuuuu1926 Prims.list -> Prims.bool
  =
  fun head  ->
    fun args  ->
      match ((head.FStar_Syntax_Syntax.n), args) with
      | (FStar_Syntax_Syntax.Tm_fvar fv,uu____1949::uu____1950::[]) ->
          ((((((((((((FStar_Syntax_Syntax.fv_eq_lid fv
                        FStar_Parser_Const.op_Addition)
                       ||
                       (FStar_Syntax_Syntax.fv_eq_lid fv
                          FStar_Parser_Const.op_Subtraction))
                      ||
                      (FStar_Syntax_Syntax.fv_eq_lid fv
                         FStar_Parser_Const.op_Multiply))
                     ||
                     (FStar_Syntax_Syntax.fv_eq_lid fv
                        FStar_Parser_Const.op_Division))
                    ||
                    (FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.op_Modulus))
                   ||
                   (FStar_Syntax_Syntax.fv_eq_lid fv
                      FStar_Parser_Const.real_op_LT))
                  ||
                  (FStar_Syntax_Syntax.fv_eq_lid fv
                     FStar_Parser_Const.real_op_LTE))
                 ||
                 (FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.real_op_GT))
                ||
                (FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.real_op_GTE))
               ||
               (FStar_Syntax_Syntax.fv_eq_lid fv
                  FStar_Parser_Const.real_op_Addition))
              ||
              (FStar_Syntax_Syntax.fv_eq_lid fv
                 FStar_Parser_Const.real_op_Subtraction))
             ||
             (FStar_Syntax_Syntax.fv_eq_lid fv
                FStar_Parser_Const.real_op_Multiply))
            ||
            (FStar_Syntax_Syntax.fv_eq_lid fv
               FStar_Parser_Const.real_op_Division)
      | (FStar_Syntax_Syntax.Tm_fvar fv,uu____1954::[]) ->
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.op_Minus
      | uu____1957 -> false
  
let (isInteger : FStar_Syntax_Syntax.term' -> Prims.bool) =
  fun tm  ->
    match tm with
    | FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_int
        (n,FStar_Pervasives_Native.None )) -> true
    | uu____1988 -> false
  
let (getInteger : FStar_Syntax_Syntax.term' -> Prims.int) =
  fun tm  ->
    match tm with
    | FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_int
        (n,FStar_Pervasives_Native.None )) -> FStar_Util.int_of_string n
    | uu____2011 -> failwith "Expected an Integer term"
  
let is_BitVector_primitive :
  'uuuuuu2021 .
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax * 'uuuuuu2021)
        Prims.list -> Prims.bool
  =
  fun head  ->
    fun args  ->
      match ((head.FStar_Syntax_Syntax.n), args) with
      | (FStar_Syntax_Syntax.Tm_fvar
         fv,(sz_arg,uu____2063)::uu____2064::uu____2065::[]) ->
          (((((((((((FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.bv_and_lid)
                      ||
                      (FStar_Syntax_Syntax.fv_eq_lid fv
                         FStar_Parser_Const.bv_xor_lid))
                     ||
                     (FStar_Syntax_Syntax.fv_eq_lid fv
                        FStar_Parser_Const.bv_or_lid))
                    ||
                    (FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.bv_add_lid))
                   ||
                   (FStar_Syntax_Syntax.fv_eq_lid fv
                      FStar_Parser_Const.bv_sub_lid))
                  ||
                  (FStar_Syntax_Syntax.fv_eq_lid fv
                     FStar_Parser_Const.bv_shift_left_lid))
                 ||
                 (FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.bv_shift_right_lid))
                ||
                (FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.bv_udiv_lid))
               ||
               (FStar_Syntax_Syntax.fv_eq_lid fv
                  FStar_Parser_Const.bv_mod_lid))
              ||
              (FStar_Syntax_Syntax.fv_eq_lid fv
                 FStar_Parser_Const.bv_uext_lid))
             ||
             (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.bv_mul_lid))
            && (isInteger sz_arg.FStar_Syntax_Syntax.n)
      | (FStar_Syntax_Syntax.Tm_fvar fv,(sz_arg,uu____2116)::uu____2117::[])
          ->
          ((FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.nat_to_bv_lid)
             ||
             (FStar_Syntax_Syntax.fv_eq_lid fv
                FStar_Parser_Const.bv_to_nat_lid))
            && (isInteger sz_arg.FStar_Syntax_Syntax.n)
      | uu____2154 -> false
  
let (encode_string_const : Prims.string -> FStar_SMTEncoding_Term.term) =
  fun s  ->
    let rec aux acc i bs =
      let uu____2194 =
        let uu____2196 = FStar_Compiler_Bytes.length bs  in i = uu____2196
         in
      if uu____2194
      then acc
      else
        (let acc1 =
           let uu____2203 =
             let uu____2204 = FStar_BigInt.of_int_fs (Prims.of_int (256))  in
             FStar_BigInt.mult_big_int uu____2204 acc  in
           let uu____2206 =
             let uu____2207 = FStar_Compiler_Bytes.get bs i  in
             FStar_All.pipe_right uu____2207 FStar_BigInt.of_int_fs  in
           FStar_BigInt.add_big_int uu____2203 uu____2206  in
         aux acc1 (i + Prims.int_one) bs)
       in
    let id =
      let uu____2212 = FStar_Compiler_Bytes.string_as_unicode_bytes s  in
      aux FStar_BigInt.zero Prims.int_zero uu____2212  in
    let uu____2214 = FStar_SMTEncoding_Util.mk_String_const id  in
    FStar_All.pipe_left FStar_SMTEncoding_Term.boxString uu____2214
  
let rec (encode_const :
  FStar_Const.sconst ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun c  ->
    fun env  ->
      match c with
      | FStar_Const.Const_unit  -> (FStar_SMTEncoding_Term.mk_Term_unit, [])
      | FStar_Const.Const_bool (true ) ->
          let uu____2525 =
            FStar_SMTEncoding_Term.boxBool FStar_SMTEncoding_Util.mkTrue  in
          (uu____2525, [])
      | FStar_Const.Const_bool (false ) ->
          let uu____2527 =
            FStar_SMTEncoding_Term.boxBool FStar_SMTEncoding_Util.mkFalse  in
          (uu____2527, [])
      | FStar_Const.Const_char c1 ->
          let uu____2530 =
            let uu____2531 =
              let uu____2539 =
                let uu____2542 =
                  let uu____2543 =
                    FStar_SMTEncoding_Util.mkInteger'
                      (FStar_Util.int_of_char c1)
                     in
                  FStar_SMTEncoding_Term.boxInt uu____2543  in
                [uu____2542]  in
              ("FStar.Char.__char_of_int", uu____2539)  in
            FStar_SMTEncoding_Util.mkApp uu____2531  in
          (uu____2530, [])
      | FStar_Const.Const_int (i,FStar_Pervasives_Native.None ) ->
          let uu____2561 =
            let uu____2562 = FStar_SMTEncoding_Util.mkInteger i  in
            FStar_SMTEncoding_Term.boxInt uu____2562  in
          (uu____2561, [])
      | FStar_Const.Const_int (repr,FStar_Pervasives_Native.Some sw) ->
          let syntax_term =
            FStar_ToSyntax_ToSyntax.desugar_machine_integer
              (env.FStar_SMTEncoding_Env.tcenv).FStar_TypeChecker_Env.dsenv
              repr sw FStar_Range.dummyRange
             in
          encode_term syntax_term env
      | FStar_Const.Const_string (s,uu____2583) ->
          let uu____2586 = encode_string_const s  in (uu____2586, [])
      | FStar_Const.Const_range uu____2587 ->
          let uu____2588 = FStar_SMTEncoding_Term.mk_Range_const ()  in
          (uu____2588, [])
      | FStar_Const.Const_effect  ->
          (FStar_SMTEncoding_Term.mk_Term_type, [])
      | FStar_Const.Const_real r ->
          let uu____2591 =
            let uu____2592 = FStar_SMTEncoding_Util.mkReal r  in
            FStar_SMTEncoding_Term.boxReal uu____2592  in
          (uu____2591, [])
      | c1 ->
          let uu____2594 =
            let uu____2596 = FStar_Syntax_Print.const_to_string c1  in
            FStar_Util.format1 "Unhandled constant: %s" uu____2596  in
          failwith uu____2594

and (encode_binders :
  FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ->
    FStar_Syntax_Syntax.binders ->
      FStar_SMTEncoding_Env.env_t ->
        (FStar_SMTEncoding_Term.fv Prims.list * FStar_SMTEncoding_Term.term
          Prims.list * FStar_SMTEncoding_Env.env_t *
          FStar_SMTEncoding_Term.decls_t * FStar_Syntax_Syntax.bv Prims.list))
  =
  fun fuel_opt  ->
    fun bs  ->
      fun env  ->
        (let uu____2625 =
           FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv
             FStar_Options.Medium
            in
         if uu____2625
         then
           let uu____2628 = FStar_Syntax_Print.binders_to_string ", " bs  in
           FStar_Util.print1 "Encoding binders %s\n" uu____2628
         else ());
        (let uu____2634 =
           FStar_All.pipe_right bs
             (FStar_List.fold_left
                (fun uu____2716  ->
                   fun b  ->
                     match uu____2716 with
                     | (vars,guards,env1,decls,names) ->
                         let uu____2781 =
                           let x = FStar_Pervasives_Native.fst b  in
                           let uu____2797 =
                             FStar_SMTEncoding_Env.gen_term_var env1 x  in
                           match uu____2797 with
                           | (xxsym,xx,env') ->
                               let uu____2822 =
                                 let uu____2827 =
                                   norm env1 x.FStar_Syntax_Syntax.sort  in
                                 encode_term_pred fuel_opt uu____2827 env1 xx
                                  in
                               (match uu____2822 with
                                | (guard_x_t,decls') ->
                                    let uu____2842 =
                                      FStar_SMTEncoding_Term.mk_fv
                                        (xxsym,
                                          FStar_SMTEncoding_Term.Term_sort)
                                       in
                                    (uu____2842, guard_x_t, env', decls', x))
                            in
                         (match uu____2781 with
                          | (v,g,env2,decls',n) ->
                              ((v :: vars), (g :: guards), env2,
                                (FStar_List.append decls decls'), (n ::
                                names)))) ([], [], env, [], []))
            in
         match uu____2634 with
         | (vars,guards,env1,decls,names) ->
             ((FStar_List.rev vars), (FStar_List.rev guards), env1, decls,
               (FStar_List.rev names)))

and (encode_term_pred :
  FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ->
    FStar_Syntax_Syntax.typ ->
      FStar_SMTEncoding_Env.env_t ->
        FStar_SMTEncoding_Term.term ->
          (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun fuel_opt  ->
    fun t  ->
      fun env  ->
        fun e  ->
          let uu____2942 = encode_term t env  in
          match uu____2942 with
          | (t1,decls) ->
              let uu____2953 =
                FStar_SMTEncoding_Term.mk_HasTypeWithFuel fuel_opt e t1  in
              (uu____2953, decls)

and (encode_term_pred' :
  FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ->
    FStar_Syntax_Syntax.typ ->
      FStar_SMTEncoding_Env.env_t ->
        FStar_SMTEncoding_Term.term ->
          (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun fuel_opt  ->
    fun t  ->
      fun env  ->
        fun e  ->
          let uu____2964 = encode_term t env  in
          match uu____2964 with
          | (t1,decls) ->
              (match fuel_opt with
               | FStar_Pervasives_Native.None  ->
                   let uu____2979 = FStar_SMTEncoding_Term.mk_HasTypeZ e t1
                      in
                   (uu____2979, decls)
               | FStar_Pervasives_Native.Some f ->
                   let uu____2981 =
                     FStar_SMTEncoding_Term.mk_HasTypeFuel f e t1  in
                   (uu____2981, decls))

and (encode_arith_term :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.args ->
        (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun env  ->
    fun head  ->
      fun args_e  ->
        let uu____2987 = encode_args args_e env  in
        match uu____2987 with
        | (arg_tms,decls) ->
            let head_fv =
              match head.FStar_Syntax_Syntax.n with
              | FStar_Syntax_Syntax.Tm_fvar fv -> fv
              | uu____3006 -> failwith "Impossible"  in
            let unary unbox arg_tms1 =
              let uu____3028 = FStar_List.hd arg_tms1  in unbox uu____3028
               in
            let binary unbox arg_tms1 =
              let uu____3053 =
                let uu____3054 = FStar_List.hd arg_tms1  in unbox uu____3054
                 in
              let uu____3055 =
                let uu____3056 =
                  let uu____3057 = FStar_List.tl arg_tms1  in
                  FStar_List.hd uu____3057  in
                unbox uu____3056  in
              (uu____3053, uu____3055)  in
            let mk_default uu____3065 =
              let uu____3066 =
                FStar_SMTEncoding_Env.lookup_free_var_sym env
                  head_fv.FStar_Syntax_Syntax.fv_name
                 in
              match uu____3066 with
              | (fname,fuel_args,arity) ->
                  let args = FStar_List.append fuel_args arg_tms  in
                  maybe_curry_app head.FStar_Syntax_Syntax.pos fname arity
                    args
               in
            let mk_l box op mk_args ts =
              let uu____3155 = FStar_Options.smtencoding_l_arith_native ()
                 in
              if uu____3155
              then
                let uu____3158 =
                  let uu____3159 = mk_args ts  in op uu____3159  in
                FStar_All.pipe_right uu____3158 box
              else mk_default ()  in
            let mk_nl box unbox nm op ts =
              let uu____3217 = FStar_Options.smtencoding_nl_arith_wrapped ()
                 in
              if uu____3217
              then
                let uu____3220 = binary unbox ts  in
                match uu____3220 with
                | (t1,t2) ->
                    let uu____3227 =
                      FStar_SMTEncoding_Util.mkApp (nm, [t1; t2])  in
                    FStar_All.pipe_right uu____3227 box
              else
                (let uu____3233 =
                   FStar_Options.smtencoding_nl_arith_native ()  in
                 if uu____3233
                 then
                   let uu____3236 =
                     let uu____3237 = binary unbox ts  in op uu____3237  in
                   FStar_All.pipe_right uu____3236 box
                 else mk_default ())
               in
            let add box unbox =
              mk_l box FStar_SMTEncoding_Util.mkAdd (binary unbox)  in
            let sub box unbox =
              mk_l box FStar_SMTEncoding_Util.mkSub (binary unbox)  in
            let minus box unbox =
              mk_l box FStar_SMTEncoding_Util.mkMinus (unary unbox)  in
            let mul box unbox nm =
              mk_nl box unbox nm FStar_SMTEncoding_Util.mkMul  in
            let div box unbox nm =
              mk_nl box unbox nm FStar_SMTEncoding_Util.mkDiv  in
            let modulus box unbox =
              mk_nl box unbox "_mod" FStar_SMTEncoding_Util.mkMod  in
            let ops =
              [(FStar_Parser_Const.op_Addition,
                 (add FStar_SMTEncoding_Term.boxInt
                    FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.op_Subtraction,
                (sub FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.op_Multiply,
                (mul FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt "_mul"));
              (FStar_Parser_Const.op_Division,
                (div FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt "_div"));
              (FStar_Parser_Const.op_Modulus,
                (modulus FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.op_Minus,
                (minus FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.real_op_Addition,
                (add FStar_SMTEncoding_Term.boxReal
                   FStar_SMTEncoding_Term.unboxReal));
              (FStar_Parser_Const.real_op_Subtraction,
                (sub FStar_SMTEncoding_Term.boxReal
                   FStar_SMTEncoding_Term.unboxReal));
              (FStar_Parser_Const.real_op_Multiply,
                (mul FStar_SMTEncoding_Term.boxReal
                   FStar_SMTEncoding_Term.unboxReal "_rmul"));
              (FStar_Parser_Const.real_op_Division,
                (mk_nl FStar_SMTEncoding_Term.boxReal
                   FStar_SMTEncoding_Term.unboxReal "_rdiv"
                   FStar_SMTEncoding_Util.mkRealDiv));
              (FStar_Parser_Const.real_op_LT,
                (mk_l FStar_SMTEncoding_Term.boxBool
                   FStar_SMTEncoding_Util.mkLT
                   (binary FStar_SMTEncoding_Term.unboxReal)));
              (FStar_Parser_Const.real_op_LTE,
                (mk_l FStar_SMTEncoding_Term.boxBool
                   FStar_SMTEncoding_Util.mkLTE
                   (binary FStar_SMTEncoding_Term.unboxReal)));
              (FStar_Parser_Const.real_op_GT,
                (mk_l FStar_SMTEncoding_Term.boxBool
                   FStar_SMTEncoding_Util.mkGT
                   (binary FStar_SMTEncoding_Term.unboxReal)));
              (FStar_Parser_Const.real_op_GTE,
                (mk_l FStar_SMTEncoding_Term.boxBool
                   FStar_SMTEncoding_Util.mkGTE
                   (binary FStar_SMTEncoding_Term.unboxReal)))]
               in
            let uu____3672 =
              let uu____3682 =
                FStar_List.tryFind
                  (fun uu____3706  ->
                     match uu____3706 with
                     | (l,uu____3717) ->
                         FStar_Syntax_Syntax.fv_eq_lid head_fv l) ops
                 in
              FStar_All.pipe_right uu____3682 FStar_Util.must  in
            (match uu____3672 with
             | (uu____3761,op) ->
                 let uu____3773 = op arg_tms  in (uu____3773, decls))

and (encode_BitVector_term :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax *
        FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option)
        Prims.list ->
        (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_elt
          Prims.list))
  =
  fun env  ->
    fun head  ->
      fun args_e  ->
        let uu____3789 = FStar_List.hd args_e  in
        match uu____3789 with
        | (tm_sz,uu____3805) ->
            let uu____3814 = uu____3789  in
            let sz = getInteger tm_sz.FStar_Syntax_Syntax.n  in
            let sz_key =
              FStar_Util.format1 "BitVector_%s" (Prims.string_of_int sz)  in
            let sz_decls =
              let t_decls = FStar_SMTEncoding_Term.mkBvConstructor sz  in
              FStar_SMTEncoding_Term.mk_decls "" sz_key t_decls []  in
            let uu____3825 =
              match ((head.FStar_Syntax_Syntax.n), args_e) with
              | (FStar_Syntax_Syntax.Tm_fvar
                 fv,uu____3851::(sz_arg,uu____3853)::uu____3854::[]) when
                  (FStar_Syntax_Syntax.fv_eq_lid fv
                     FStar_Parser_Const.bv_uext_lid)
                    && (isInteger sz_arg.FStar_Syntax_Syntax.n)
                  ->
                  let uu____3921 =
                    let uu____3922 = FStar_List.tail args_e  in
                    FStar_List.tail uu____3922  in
                  let uu____3949 =
                    let uu____3953 = getInteger sz_arg.FStar_Syntax_Syntax.n
                       in
                    FStar_Pervasives_Native.Some uu____3953  in
                  (uu____3921, uu____3949)
              | (FStar_Syntax_Syntax.Tm_fvar
                 fv,uu____3960::(sz_arg,uu____3962)::uu____3963::[]) when
                  FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.bv_uext_lid
                  ->
                  let uu____4030 =
                    let uu____4032 = FStar_Syntax_Print.term_to_string sz_arg
                       in
                    FStar_Util.format1
                      "Not a constant bitvector extend size: %s" uu____4032
                     in
                  failwith uu____4030
              | uu____4042 ->
                  let uu____4057 = FStar_List.tail args_e  in
                  (uu____4057, FStar_Pervasives_Native.None)
               in
            (match uu____3825 with
             | (arg_tms,ext_sz) ->
                 let uu____4084 = encode_args arg_tms env  in
                 (match uu____4084 with
                  | (arg_tms1,decls) ->
                      let head_fv =
                        match head.FStar_Syntax_Syntax.n with
                        | FStar_Syntax_Syntax.Tm_fvar fv -> fv
                        | uu____4105 -> failwith "Impossible"  in
                      let unary arg_tms2 =
                        let uu____4117 = FStar_List.hd arg_tms2  in
                        FStar_SMTEncoding_Term.unboxBitVec sz uu____4117  in
                      let unary_arith arg_tms2 =
                        let uu____4128 = FStar_List.hd arg_tms2  in
                        FStar_SMTEncoding_Term.unboxInt uu____4128  in
                      let binary arg_tms2 =
                        let uu____4143 =
                          let uu____4144 = FStar_List.hd arg_tms2  in
                          FStar_SMTEncoding_Term.unboxBitVec sz uu____4144
                           in
                        let uu____4145 =
                          let uu____4146 =
                            let uu____4147 = FStar_List.tl arg_tms2  in
                            FStar_List.hd uu____4147  in
                          FStar_SMTEncoding_Term.unboxBitVec sz uu____4146
                           in
                        (uu____4143, uu____4145)  in
                      let binary_arith arg_tms2 =
                        let uu____4164 =
                          let uu____4165 = FStar_List.hd arg_tms2  in
                          FStar_SMTEncoding_Term.unboxBitVec sz uu____4165
                           in
                        let uu____4166 =
                          let uu____4167 =
                            let uu____4168 = FStar_List.tl arg_tms2  in
                            FStar_List.hd uu____4168  in
                          FStar_SMTEncoding_Term.unboxInt uu____4167  in
                        (uu____4164, uu____4166)  in
                      let mk_bv op mk_args resBox ts =
                        let uu____4226 =
                          let uu____4227 = mk_args ts  in op uu____4227  in
                        FStar_All.pipe_right uu____4226 resBox  in
                      let bv_and =
                        mk_bv FStar_SMTEncoding_Util.mkBvAnd binary
                          (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_xor =
                        mk_bv FStar_SMTEncoding_Util.mkBvXor binary
                          (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_or =
                        mk_bv FStar_SMTEncoding_Util.mkBvOr binary
                          (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_add =
                        mk_bv FStar_SMTEncoding_Util.mkBvAdd binary
                          (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_sub =
                        mk_bv FStar_SMTEncoding_Util.mkBvSub binary
                          (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_shl =
                        mk_bv (FStar_SMTEncoding_Util.mkBvShl sz)
                          binary_arith (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_shr =
                        mk_bv (FStar_SMTEncoding_Util.mkBvShr sz)
                          binary_arith (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_udiv =
                        mk_bv (FStar_SMTEncoding_Util.mkBvUdiv sz)
                          binary_arith (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_mod =
                        mk_bv (FStar_SMTEncoding_Util.mkBvMod sz)
                          binary_arith (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_mul =
                        mk_bv (FStar_SMTEncoding_Util.mkBvMul sz)
                          binary_arith (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let bv_ult =
                        mk_bv FStar_SMTEncoding_Util.mkBvUlt binary
                          FStar_SMTEncoding_Term.boxBool
                         in
                      let bv_uext arg_tms2 =
                        let uu____4359 =
                          let uu____4364 =
                            match ext_sz with
                            | FStar_Pervasives_Native.Some x -> x
                            | FStar_Pervasives_Native.None  ->
                                failwith "impossible"
                             in
                          FStar_SMTEncoding_Util.mkBvUext uu____4364  in
                        let uu____4373 =
                          let uu____4378 =
                            let uu____4380 =
                              match ext_sz with
                              | FStar_Pervasives_Native.Some x -> x
                              | FStar_Pervasives_Native.None  ->
                                  failwith "impossible"
                               in
                            sz + uu____4380  in
                          FStar_SMTEncoding_Term.boxBitVec uu____4378  in
                        mk_bv uu____4359 unary uu____4373 arg_tms2  in
                      let to_int =
                        mk_bv FStar_SMTEncoding_Util.mkBvToNat unary
                          FStar_SMTEncoding_Term.boxInt
                         in
                      let bv_to =
                        mk_bv (FStar_SMTEncoding_Util.mkNatToBv sz)
                          unary_arith (FStar_SMTEncoding_Term.boxBitVec sz)
                         in
                      let ops =
                        [(FStar_Parser_Const.bv_and_lid, bv_and);
                        (FStar_Parser_Const.bv_xor_lid, bv_xor);
                        (FStar_Parser_Const.bv_or_lid, bv_or);
                        (FStar_Parser_Const.bv_add_lid, bv_add);
                        (FStar_Parser_Const.bv_sub_lid, bv_sub);
                        (FStar_Parser_Const.bv_shift_left_lid, bv_shl);
                        (FStar_Parser_Const.bv_shift_right_lid, bv_shr);
                        (FStar_Parser_Const.bv_udiv_lid, bv_udiv);
                        (FStar_Parser_Const.bv_mod_lid, bv_mod);
                        (FStar_Parser_Const.bv_mul_lid, bv_mul);
                        (FStar_Parser_Const.bv_ult_lid, bv_ult);
                        (FStar_Parser_Const.bv_uext_lid, bv_uext);
                        (FStar_Parser_Const.bv_to_nat_lid, to_int);
                        (FStar_Parser_Const.nat_to_bv_lid, bv_to)]  in
                      let uu____4620 =
                        let uu____4630 =
                          FStar_List.tryFind
                            (fun uu____4654  ->
                               match uu____4654 with
                               | (l,uu____4665) ->
                                   FStar_Syntax_Syntax.fv_eq_lid head_fv l)
                            ops
                           in
                        FStar_All.pipe_right uu____4630 FStar_Util.must  in
                      (match uu____4620 with
                       | (uu____4711,op) ->
                           let uu____4723 = op arg_tms1  in
                           (uu____4723, (FStar_List.append sz_decls decls)))))

and (encode_deeply_embedded_quantifier :
  FStar_Syntax_Syntax.term ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun t  ->
    fun env  ->
      let env1 =
        let uu___609_4733 = env  in
        {
          FStar_SMTEncoding_Env.bvar_bindings =
            (uu___609_4733.FStar_SMTEncoding_Env.bvar_bindings);
          FStar_SMTEncoding_Env.fvar_bindings =
            (uu___609_4733.FStar_SMTEncoding_Env.fvar_bindings);
          FStar_SMTEncoding_Env.depth =
            (uu___609_4733.FStar_SMTEncoding_Env.depth);
          FStar_SMTEncoding_Env.tcenv =
            (uu___609_4733.FStar_SMTEncoding_Env.tcenv);
          FStar_SMTEncoding_Env.warn =
            (uu___609_4733.FStar_SMTEncoding_Env.warn);
          FStar_SMTEncoding_Env.nolabels =
            (uu___609_4733.FStar_SMTEncoding_Env.nolabels);
          FStar_SMTEncoding_Env.use_zfuel_name =
            (uu___609_4733.FStar_SMTEncoding_Env.use_zfuel_name);
          FStar_SMTEncoding_Env.encode_non_total_function_typ =
            (uu___609_4733.FStar_SMTEncoding_Env.encode_non_total_function_typ);
          FStar_SMTEncoding_Env.current_module_name =
            (uu___609_4733.FStar_SMTEncoding_Env.current_module_name);
          FStar_SMTEncoding_Env.encoding_quantifier = true;
          FStar_SMTEncoding_Env.global_cache =
            (uu___609_4733.FStar_SMTEncoding_Env.global_cache)
        }  in
      let uu____4735 = encode_term t env1  in
      match uu____4735 with
      | (tm,decls) ->
          let vars = FStar_SMTEncoding_Term.free_variables tm  in
          let valid_tm = FStar_SMTEncoding_Term.mk_Valid tm  in
          let key =
            FStar_SMTEncoding_Term.mkForall t.FStar_Syntax_Syntax.pos
              ([], vars, valid_tm)
             in
          let tkey_hash = FStar_SMTEncoding_Term.hash_of_term key  in
          (match tm.FStar_SMTEncoding_Term.tm with
           | FStar_SMTEncoding_Term.App
               (uu____4761,{
                             FStar_SMTEncoding_Term.tm =
                               FStar_SMTEncoding_Term.FreeV uu____4762;
                             FStar_SMTEncoding_Term.freevars = uu____4763;
                             FStar_SMTEncoding_Term.rng = uu____4764;_}::
                {
                  FStar_SMTEncoding_Term.tm = FStar_SMTEncoding_Term.FreeV
                    uu____4765;
                  FStar_SMTEncoding_Term.freevars = uu____4766;
                  FStar_SMTEncoding_Term.rng = uu____4767;_}::[])
               ->
               (FStar_Errors.log_issue t.FStar_Syntax_Syntax.pos
                  (FStar_Errors.Warning_QuantifierWithoutPattern,
                    "Not encoding deeply embedded, unguarded quantifier to SMT");
                (tm, decls))
           | uu____4813 ->
               let uu____4814 = encode_formula t env1  in
               (match uu____4814 with
                | (phi,decls') ->
                    let interp =
                      match vars with
                      | [] ->
                          let uu____4834 =
                            let uu____4839 =
                              FStar_SMTEncoding_Term.mk_Valid tm  in
                            (uu____4839, phi)  in
                          FStar_SMTEncoding_Util.mkIff uu____4834
                      | uu____4840 ->
                          let uu____4841 =
                            let uu____4852 =
                              let uu____4853 =
                                let uu____4858 =
                                  FStar_SMTEncoding_Term.mk_Valid tm  in
                                (uu____4858, phi)  in
                              FStar_SMTEncoding_Util.mkIff uu____4853  in
                            ([[valid_tm]], vars, uu____4852)  in
                          FStar_SMTEncoding_Term.mkForall
                            t.FStar_Syntax_Syntax.pos uu____4841
                       in
                    let ax =
                      let uu____4868 =
                        let uu____4876 =
                          let uu____4878 =
                            FStar_Util.digest_of_string tkey_hash  in
                          Prims.op_Hat "l_quant_interp_" uu____4878  in
                        (interp,
                          (FStar_Pervasives_Native.Some
                             "Interpretation of deeply embedded quantifier"),
                          uu____4876)
                         in
                      FStar_SMTEncoding_Util.mkAssume uu____4868  in
                    let uu____4884 =
                      let uu____4885 =
                        let uu____4888 =
                          FStar_SMTEncoding_Term.mk_decls "" tkey_hash 
                            [ax] (FStar_List.append decls decls')
                           in
                        FStar_List.append decls' uu____4888  in
                      FStar_List.append decls uu____4885  in
                    (tm, uu____4884)))

and (encode_term :
  FStar_Syntax_Syntax.typ ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun t  ->
    fun env  ->
      let t1 = FStar_Syntax_Subst.compress t  in
      let t0 = t1  in
      (let uu____4901 =
         FStar_All.pipe_left
           (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
           (FStar_Options.Other "SMTEncoding")
          in
       if uu____4901
       then
         let uu____4906 = FStar_Syntax_Print.tag_of_term t1  in
         let uu____4908 = FStar_Syntax_Print.term_to_string t1  in
         FStar_Util.print2 "(%s)   %s\n" uu____4906 uu____4908
       else ());
      (match t1.FStar_Syntax_Syntax.n with
       | FStar_Syntax_Syntax.Tm_delayed uu____4917 ->
           let uu____4932 =
             let uu____4934 =
               FStar_All.pipe_left FStar_Range.string_of_range
                 t1.FStar_Syntax_Syntax.pos
                in
             let uu____4937 = FStar_Syntax_Print.tag_of_term t1  in
             let uu____4939 = FStar_Syntax_Print.term_to_string t1  in
             FStar_Util.format3 "(%s) Impossible: %s\n%s\n" uu____4934
               uu____4937 uu____4939
              in
           failwith uu____4932
       | FStar_Syntax_Syntax.Tm_unknown  ->
           let uu____4946 =
             let uu____4948 =
               FStar_All.pipe_left FStar_Range.string_of_range
                 t1.FStar_Syntax_Syntax.pos
                in
             let uu____4951 = FStar_Syntax_Print.tag_of_term t1  in
             let uu____4953 = FStar_Syntax_Print.term_to_string t1  in
             FStar_Util.format3 "(%s) Impossible: %s\n%s\n" uu____4948
               uu____4951 uu____4953
              in
           failwith uu____4946
       | FStar_Syntax_Syntax.Tm_lazy i ->
           let e = FStar_Syntax_Util.unfold_lazy i  in
           ((let uu____4963 =
               FStar_All.pipe_left
                 (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
                 (FStar_Options.Other "SMTEncoding")
                in
             if uu____4963
             then
               let uu____4968 = FStar_Syntax_Print.term_to_string t1  in
               let uu____4970 = FStar_Syntax_Print.term_to_string e  in
               FStar_Util.print2 ">> Unfolded (%s) ~> (%s)\n" uu____4968
                 uu____4970
             else ());
            encode_term e env)
       | FStar_Syntax_Syntax.Tm_bvar x ->
           let uu____4976 =
             let uu____4978 = FStar_Syntax_Print.bv_to_string x  in
             FStar_Util.format1 "Impossible: locally nameless; got %s"
               uu____4978
              in
           failwith uu____4976
       | FStar_Syntax_Syntax.Tm_ascribed (t2,(k,uu____4987),uu____4988) ->
           let uu____5037 =
             match k with
             | FStar_Util.Inl t3 -> FStar_Syntax_Util.is_unit t3
             | uu____5047 -> false  in
           if uu____5037
           then (FStar_SMTEncoding_Term.mk_Term_unit, [])
           else encode_term t2 env
       | FStar_Syntax_Syntax.Tm_quoted (qt,uu____5065) ->
           let tv =
             let uu____5071 =
               let uu____5078 = FStar_Reflection_Basic.inspect_ln qt  in
               FStar_Syntax_Embeddings.embed
                 FStar_Reflection_Embeddings.e_term_view uu____5078
                in
             uu____5071 t1.FStar_Syntax_Syntax.pos
               FStar_Pervasives_Native.None
               FStar_Syntax_Embeddings.id_norm_cb
              in
           ((let uu____5082 =
               FStar_All.pipe_left
                 (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
                 (FStar_Options.Other "SMTEncoding")
                in
             if uu____5082
             then
               let uu____5087 = FStar_Syntax_Print.term_to_string t0  in
               let uu____5089 = FStar_Syntax_Print.term_to_string tv  in
               FStar_Util.print2 ">> Inspected (%s) ~> (%s)\n" uu____5087
                 uu____5089
             else ());
            (let t2 =
               let uu____5097 =
                 let uu____5108 = FStar_Syntax_Syntax.as_arg tv  in
                 [uu____5108]  in
               FStar_Syntax_Util.mk_app
                 (FStar_Reflection_Data.refl_constant_term
                    FStar_Reflection_Data.fstar_refl_pack_ln) uu____5097
                in
             encode_term t2 env))
       | FStar_Syntax_Syntax.Tm_meta
           (t2,FStar_Syntax_Syntax.Meta_pattern uu____5134) ->
           encode_term t2
             (let uu___682_5160 = env  in
              {
                FStar_SMTEncoding_Env.bvar_bindings =
                  (uu___682_5160.FStar_SMTEncoding_Env.bvar_bindings);
                FStar_SMTEncoding_Env.fvar_bindings =
                  (uu___682_5160.FStar_SMTEncoding_Env.fvar_bindings);
                FStar_SMTEncoding_Env.depth =
                  (uu___682_5160.FStar_SMTEncoding_Env.depth);
                FStar_SMTEncoding_Env.tcenv =
                  (uu___682_5160.FStar_SMTEncoding_Env.tcenv);
                FStar_SMTEncoding_Env.warn =
                  (uu___682_5160.FStar_SMTEncoding_Env.warn);
                FStar_SMTEncoding_Env.nolabels =
                  (uu___682_5160.FStar_SMTEncoding_Env.nolabels);
                FStar_SMTEncoding_Env.use_zfuel_name =
                  (uu___682_5160.FStar_SMTEncoding_Env.use_zfuel_name);
                FStar_SMTEncoding_Env.encode_non_total_function_typ =
                  (uu___682_5160.FStar_SMTEncoding_Env.encode_non_total_function_typ);
                FStar_SMTEncoding_Env.current_module_name =
                  (uu___682_5160.FStar_SMTEncoding_Env.current_module_name);
                FStar_SMTEncoding_Env.encoding_quantifier = false;
                FStar_SMTEncoding_Env.global_cache =
                  (uu___682_5160.FStar_SMTEncoding_Env.global_cache)
              })
       | FStar_Syntax_Syntax.Tm_meta (t2,uu____5163) -> encode_term t2 env
       | FStar_Syntax_Syntax.Tm_name x ->
           let t2 = FStar_SMTEncoding_Env.lookup_term_var env x  in (t2, [])
       | FStar_Syntax_Syntax.Tm_fvar v ->
           let encode_freev uu____5180 =
             let fvb =
               FStar_SMTEncoding_Env.lookup_free_var_name env
                 v.FStar_Syntax_Syntax.fv_name
                in
             let tok =
               FStar_SMTEncoding_Env.lookup_free_var env
                 v.FStar_Syntax_Syntax.fv_name
                in
             let tkey_hash = FStar_SMTEncoding_Term.hash_of_term tok  in
             let uu____5185 =
               if fvb.FStar_SMTEncoding_Env.smt_arity > Prims.int_zero
               then
                 match tok.FStar_SMTEncoding_Term.tm with
                 | FStar_SMTEncoding_Term.FreeV uu____5209 ->
                     let sym_name =
                       let uu____5220 = FStar_Util.digest_of_string tkey_hash
                          in
                       Prims.op_Hat "@kick_partial_app_" uu____5220  in
                     let uu____5223 =
                       let uu____5226 =
                         let uu____5227 =
                           let uu____5235 =
                             FStar_SMTEncoding_Term.kick_partial_app tok  in
                           (uu____5235,
                             (FStar_Pervasives_Native.Some "kick_partial_app"),
                             sym_name)
                            in
                         FStar_SMTEncoding_Util.mkAssume uu____5227  in
                       [uu____5226]  in
                     (uu____5223, sym_name)
                 | FStar_SMTEncoding_Term.App (uu____5242,[]) ->
                     let sym_name =
                       let uu____5247 = FStar_Util.digest_of_string tkey_hash
                          in
                       Prims.op_Hat "@kick_partial_app_" uu____5247  in
                     let uu____5250 =
                       let uu____5253 =
                         let uu____5254 =
                           let uu____5262 =
                             FStar_SMTEncoding_Term.kick_partial_app tok  in
                           (uu____5262,
                             (FStar_Pervasives_Native.Some "kick_partial_app"),
                             sym_name)
                            in
                         FStar_SMTEncoding_Util.mkAssume uu____5254  in
                       [uu____5253]  in
                     (uu____5250, sym_name)
                 | uu____5269 -> ([], "")
               else ([], "")  in
             match uu____5185 with
             | (aux_decls,sym_name) ->
                 let uu____5292 =
                   if aux_decls = []
                   then
                     FStar_All.pipe_right []
                       FStar_SMTEncoding_Term.mk_decls_trivial
                   else
                     FStar_SMTEncoding_Term.mk_decls sym_name tkey_hash
                       aux_decls []
                    in
                 (tok, uu____5292)
              in
           let uu____5300 = head_redex env t1  in
           if uu____5300
           then
             let uu____5307 = maybe_whnf env t1  in
             (match uu____5307 with
              | FStar_Pervasives_Native.None  -> encode_freev ()
              | FStar_Pervasives_Native.Some t2 -> encode_term t2 env)
           else encode_freev ()
       | FStar_Syntax_Syntax.Tm_type uu____5317 ->
           (FStar_SMTEncoding_Term.mk_Term_type, [])
       | FStar_Syntax_Syntax.Tm_uinst (t2,uu____5319) -> encode_term t2 env
       | FStar_Syntax_Syntax.Tm_constant c -> encode_const c env
       | FStar_Syntax_Syntax.Tm_arrow (binders,c) ->
           let module_name = env.FStar_SMTEncoding_Env.current_module_name
              in
           let uu____5349 = FStar_Syntax_Subst.open_comp binders c  in
           (match uu____5349 with
            | (binders1,res) ->
                let uu____5360 =
                  (env.FStar_SMTEncoding_Env.encode_non_total_function_typ &&
                     (FStar_Syntax_Util.is_pure_or_ghost_comp res))
                    || (FStar_Syntax_Util.is_tot_or_gtot_comp res)
                   in
                if uu____5360
                then
                  let uu____5367 =
                    encode_binders FStar_Pervasives_Native.None binders1 env
                     in
                  (match uu____5367 with
                   | (vars,guards_l,env',decls,uu____5392) ->
                       let fsym =
                         let uu____5406 =
                           let uu____5412 =
                             FStar_SMTEncoding_Env.varops.FStar_SMTEncoding_Env.fresh
                               module_name "f"
                              in
                           (uu____5412, FStar_SMTEncoding_Term.Term_sort)  in
                         FStar_SMTEncoding_Term.mk_fv uu____5406  in
                       let f = FStar_SMTEncoding_Util.mkFreeV fsym  in
                       let app = mk_Apply f vars  in
                       let uu____5418 =
                         FStar_TypeChecker_Util.pure_or_ghost_pre_and_post
                           (let uu___741_5427 =
                              env.FStar_SMTEncoding_Env.tcenv  in
                            {
                              FStar_TypeChecker_Env.solver =
                                (uu___741_5427.FStar_TypeChecker_Env.solver);
                              FStar_TypeChecker_Env.range =
                                (uu___741_5427.FStar_TypeChecker_Env.range);
                              FStar_TypeChecker_Env.curmodule =
                                (uu___741_5427.FStar_TypeChecker_Env.curmodule);
                              FStar_TypeChecker_Env.gamma =
                                (uu___741_5427.FStar_TypeChecker_Env.gamma);
                              FStar_TypeChecker_Env.gamma_sig =
                                (uu___741_5427.FStar_TypeChecker_Env.gamma_sig);
                              FStar_TypeChecker_Env.gamma_cache =
                                (uu___741_5427.FStar_TypeChecker_Env.gamma_cache);
                              FStar_TypeChecker_Env.modules =
                                (uu___741_5427.FStar_TypeChecker_Env.modules);
                              FStar_TypeChecker_Env.expected_typ =
                                (uu___741_5427.FStar_TypeChecker_Env.expected_typ);
                              FStar_TypeChecker_Env.sigtab =
                                (uu___741_5427.FStar_TypeChecker_Env.sigtab);
                              FStar_TypeChecker_Env.attrtab =
                                (uu___741_5427.FStar_TypeChecker_Env.attrtab);
                              FStar_TypeChecker_Env.instantiate_imp =
                                (uu___741_5427.FStar_TypeChecker_Env.instantiate_imp);
                              FStar_TypeChecker_Env.effects =
                                (uu___741_5427.FStar_TypeChecker_Env.effects);
                              FStar_TypeChecker_Env.generalize =
                                (uu___741_5427.FStar_TypeChecker_Env.generalize);
                              FStar_TypeChecker_Env.letrecs =
                                (uu___741_5427.FStar_TypeChecker_Env.letrecs);
                              FStar_TypeChecker_Env.top_level =
                                (uu___741_5427.FStar_TypeChecker_Env.top_level);
                              FStar_TypeChecker_Env.check_uvars =
                                (uu___741_5427.FStar_TypeChecker_Env.check_uvars);
                              FStar_TypeChecker_Env.use_eq =
                                (uu___741_5427.FStar_TypeChecker_Env.use_eq);
                              FStar_TypeChecker_Env.use_eq_strict =
                                (uu___741_5427.FStar_TypeChecker_Env.use_eq_strict);
                              FStar_TypeChecker_Env.is_iface =
                                (uu___741_5427.FStar_TypeChecker_Env.is_iface);
                              FStar_TypeChecker_Env.admit =
                                (uu___741_5427.FStar_TypeChecker_Env.admit);
                              FStar_TypeChecker_Env.lax = true;
                              FStar_TypeChecker_Env.lax_universes =
                                (uu___741_5427.FStar_TypeChecker_Env.lax_universes);
                              FStar_TypeChecker_Env.phase1 =
                                (uu___741_5427.FStar_TypeChecker_Env.phase1);
                              FStar_TypeChecker_Env.failhard =
                                (uu___741_5427.FStar_TypeChecker_Env.failhard);
                              FStar_TypeChecker_Env.nosynth =
                                (uu___741_5427.FStar_TypeChecker_Env.nosynth);
                              FStar_TypeChecker_Env.uvar_subtyping =
                                (uu___741_5427.FStar_TypeChecker_Env.uvar_subtyping);
                              FStar_TypeChecker_Env.tc_term =
                                (uu___741_5427.FStar_TypeChecker_Env.tc_term);
                              FStar_TypeChecker_Env.type_of =
                                (uu___741_5427.FStar_TypeChecker_Env.type_of);
                              FStar_TypeChecker_Env.universe_of =
                                (uu___741_5427.FStar_TypeChecker_Env.universe_of);
                              FStar_TypeChecker_Env.check_type_of =
                                (uu___741_5427.FStar_TypeChecker_Env.check_type_of);
                              FStar_TypeChecker_Env.use_bv_sorts =
                                (uu___741_5427.FStar_TypeChecker_Env.use_bv_sorts);
                              FStar_TypeChecker_Env.qtbl_name_and_index =
                                (uu___741_5427.FStar_TypeChecker_Env.qtbl_name_and_index);
                              FStar_TypeChecker_Env.normalized_eff_names =
                                (uu___741_5427.FStar_TypeChecker_Env.normalized_eff_names);
                              FStar_TypeChecker_Env.fv_delta_depths =
                                (uu___741_5427.FStar_TypeChecker_Env.fv_delta_depths);
                              FStar_TypeChecker_Env.proof_ns =
                                (uu___741_5427.FStar_TypeChecker_Env.proof_ns);
                              FStar_TypeChecker_Env.synth_hook =
                                (uu___741_5427.FStar_TypeChecker_Env.synth_hook);
                              FStar_TypeChecker_Env.try_solve_implicits_hook
                                =
                                (uu___741_5427.FStar_TypeChecker_Env.try_solve_implicits_hook);
                              FStar_TypeChecker_Env.splice =
                                (uu___741_5427.FStar_TypeChecker_Env.splice);
                              FStar_TypeChecker_Env.mpreprocess =
                                (uu___741_5427.FStar_TypeChecker_Env.mpreprocess);
                              FStar_TypeChecker_Env.postprocess =
                                (uu___741_5427.FStar_TypeChecker_Env.postprocess);
                              FStar_TypeChecker_Env.is_native_tactic =
                                (uu___741_5427.FStar_TypeChecker_Env.is_native_tactic);
                              FStar_TypeChecker_Env.identifier_info =
                                (uu___741_5427.FStar_TypeChecker_Env.identifier_info);
                              FStar_TypeChecker_Env.tc_hooks =
                                (uu___741_5427.FStar_TypeChecker_Env.tc_hooks);
                              FStar_TypeChecker_Env.dsenv =
                                (uu___741_5427.FStar_TypeChecker_Env.dsenv);
                              FStar_TypeChecker_Env.nbe =
                                (uu___741_5427.FStar_TypeChecker_Env.nbe);
                              FStar_TypeChecker_Env.strict_args_tab =
                                (uu___741_5427.FStar_TypeChecker_Env.strict_args_tab);
                              FStar_TypeChecker_Env.erasable_types_tab =
                                (uu___741_5427.FStar_TypeChecker_Env.erasable_types_tab)
                            }) res
                          in
                       (match uu____5418 with
                        | (pre_opt,res_t) ->
                            let uu____5439 =
                              encode_term_pred FStar_Pervasives_Native.None
                                res_t env' app
                               in
                            (match uu____5439 with
                             | (res_pred,decls') ->
                                 let uu____5450 =
                                   match pre_opt with
                                   | FStar_Pervasives_Native.None  ->
                                       let uu____5463 =
                                         FStar_SMTEncoding_Util.mk_and_l
                                           guards_l
                                          in
                                       (uu____5463, [])
                                   | FStar_Pervasives_Native.Some pre ->
                                       let uu____5467 =
                                         encode_formula pre env'  in
                                       (match uu____5467 with
                                        | (guard,decls0) ->
                                            let uu____5480 =
                                              FStar_SMTEncoding_Util.mk_and_l
                                                (guard :: guards_l)
                                               in
                                            (uu____5480, decls0))
                                    in
                                 (match uu____5450 with
                                  | (guards,guard_decls) ->
                                      let is_pure =
                                        let uu____5495 =
                                          FStar_All.pipe_right res
                                            (FStar_TypeChecker_Normalize.ghost_to_pure
                                               env.FStar_SMTEncoding_Env.tcenv)
                                           in
                                        FStar_All.pipe_right uu____5495
                                          FStar_Syntax_Util.is_pure_comp
                                         in
                                      let t_interp =
                                        let uu____5504 =
                                          let uu____5515 =
                                            FStar_SMTEncoding_Util.mkImp
                                              (guards, res_pred)
                                             in
                                          ([[app]], vars, uu____5515)  in
                                        FStar_SMTEncoding_Term.mkForall
                                          t1.FStar_Syntax_Syntax.pos
                                          uu____5504
                                         in
                                      let t_interp1 =
                                        let tot_fun_axioms =
                                          isTotFun_axioms
                                            t1.FStar_Syntax_Syntax.pos f vars
                                            guards_l is_pure
                                           in
                                        FStar_SMTEncoding_Util.mkAnd
                                          (t_interp, tot_fun_axioms)
                                         in
                                      let cvars =
                                        let uu____5537 =
                                          FStar_SMTEncoding_Term.free_variables
                                            t_interp1
                                           in
                                        FStar_All.pipe_right uu____5537
                                          (FStar_List.filter
                                             (fun x  ->
                                                let uu____5556 =
                                                  FStar_SMTEncoding_Term.fv_name
                                                    x
                                                   in
                                                let uu____5558 =
                                                  FStar_SMTEncoding_Term.fv_name
                                                    fsym
                                                   in
                                                uu____5556 <> uu____5558))
                                         in
                                      let tkey =
                                        FStar_SMTEncoding_Term.mkForall
                                          t1.FStar_Syntax_Syntax.pos
                                          ([], (fsym :: cvars), t_interp1)
                                         in
                                      let prefix =
                                        if is_pure
                                        then "Tm_arrow_"
                                        else "Tm_ghost_arrow_"  in
                                      let tkey_hash =
                                        let uu____5586 =
                                          FStar_SMTEncoding_Term.hash_of_term
                                            tkey
                                           in
                                        Prims.op_Hat prefix uu____5586  in
                                      let tsym =
                                        let uu____5590 =
                                          FStar_Util.digest_of_string
                                            tkey_hash
                                           in
                                        Prims.op_Hat prefix uu____5590  in
                                      let cvar_sorts =
                                        FStar_List.map
                                          FStar_SMTEncoding_Term.fv_sort
                                          cvars
                                         in
                                      let caption =
                                        let uu____5604 =
                                          FStar_Options.log_queries ()  in
                                        if uu____5604
                                        then
                                          let uu____5607 =
                                            let uu____5609 =
                                              FStar_TypeChecker_Normalize.term_to_string
                                                env.FStar_SMTEncoding_Env.tcenv
                                                t0
                                               in
                                            FStar_Util.replace_char
                                              uu____5609 10 32
                                             in
                                          FStar_Pervasives_Native.Some
                                            uu____5607
                                        else FStar_Pervasives_Native.None  in
                                      let tdecl =
                                        FStar_SMTEncoding_Term.DeclFun
                                          (tsym, cvar_sorts,
                                            FStar_SMTEncoding_Term.Term_sort,
                                            caption)
                                         in
                                      let t2 =
                                        let uu____5622 =
                                          let uu____5630 =
                                            FStar_List.map
                                              FStar_SMTEncoding_Util.mkFreeV
                                              cvars
                                             in
                                          (tsym, uu____5630)  in
                                        FStar_SMTEncoding_Util.mkApp
                                          uu____5622
                                         in
                                      let t_has_kind =
                                        FStar_SMTEncoding_Term.mk_HasType t2
                                          FStar_SMTEncoding_Term.mk_Term_type
                                         in
                                      let k_assumption =
                                        let a_name =
                                          Prims.op_Hat "kinding_" tsym  in
                                        let uu____5649 =
                                          let uu____5657 =
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              ([[t_has_kind]], cvars,
                                                t_has_kind)
                                             in
                                          (uu____5657,
                                            (FStar_Pervasives_Native.Some
                                               a_name), a_name)
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____5649
                                         in
                                      let f_has_t =
                                        FStar_SMTEncoding_Term.mk_HasType f
                                          t2
                                         in
                                      let f_has_t_z =
                                        FStar_SMTEncoding_Term.mk_HasTypeZ f
                                          t2
                                         in
                                      let pre_typing =
                                        let a_name =
                                          Prims.op_Hat "pre_typing_" tsym  in
                                        let uu____5674 =
                                          let uu____5682 =
                                            let uu____5683 =
                                              let uu____5694 =
                                                let uu____5695 =
                                                  let uu____5700 =
                                                    let uu____5701 =
                                                      FStar_SMTEncoding_Term.mk_PreType
                                                        f
                                                       in
                                                    FStar_SMTEncoding_Term.mk_tester
                                                      "Tm_arrow" uu____5701
                                                     in
                                                  (f_has_t, uu____5700)  in
                                                FStar_SMTEncoding_Util.mkImp
                                                  uu____5695
                                                 in
                                              ([[f_has_t]], (fsym :: cvars),
                                                uu____5694)
                                               in
                                            let uu____5719 =
                                              mkForall_fuel module_name
                                                t0.FStar_Syntax_Syntax.pos
                                               in
                                            uu____5719 uu____5683  in
                                          (uu____5682,
                                            (FStar_Pervasives_Native.Some
                                               "pre-typing for functions"),
                                            (Prims.op_Hat module_name
                                               (Prims.op_Hat "_" a_name)))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____5674
                                         in
                                      let t_interp2 =
                                        let a_name =
                                          Prims.op_Hat "interpretation_" tsym
                                           in
                                        let uu____5742 =
                                          let uu____5750 =
                                            let uu____5751 =
                                              let uu____5762 =
                                                FStar_SMTEncoding_Util.mkIff
                                                  (f_has_t_z, t_interp1)
                                                 in
                                              ([[f_has_t_z]], (fsym ::
                                                cvars), uu____5762)
                                               in
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              uu____5751
                                             in
                                          (uu____5750,
                                            (FStar_Pervasives_Native.Some
                                               a_name),
                                            (Prims.op_Hat module_name
                                               (Prims.op_Hat "_" a_name)))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____5742
                                         in
                                      let t_decls =
                                        [tdecl;
                                        k_assumption;
                                        pre_typing;
                                        t_interp2]  in
                                      let uu____5785 =
                                        let uu____5786 =
                                          let uu____5789 =
                                            let uu____5792 =
                                              FStar_SMTEncoding_Term.mk_decls
                                                tsym tkey_hash t_decls
                                                (FStar_List.append decls
                                                   (FStar_List.append decls'
                                                      guard_decls))
                                               in
                                            FStar_List.append guard_decls
                                              uu____5792
                                             in
                                          FStar_List.append decls' uu____5789
                                           in
                                        FStar_List.append decls uu____5786
                                         in
                                      (t2, uu____5785)))))
                else
                  (let tsym =
                     FStar_SMTEncoding_Env.varops.FStar_SMTEncoding_Env.fresh
                       module_name "Non_total_Tm_arrow"
                      in
                   let tdecl =
                     FStar_SMTEncoding_Term.DeclFun
                       (tsym, [], FStar_SMTEncoding_Term.Term_sort,
                         FStar_Pervasives_Native.None)
                      in
                   let t2 = FStar_SMTEncoding_Util.mkApp (tsym, [])  in
                   let t_kinding =
                     let a_name =
                       Prims.op_Hat "non_total_function_typing_" tsym  in
                     let uu____5813 =
                       let uu____5821 =
                         FStar_SMTEncoding_Term.mk_HasType t2
                           FStar_SMTEncoding_Term.mk_Term_type
                          in
                       (uu____5821,
                         (FStar_Pervasives_Native.Some
                            "Typing for non-total arrows"), a_name)
                        in
                     FStar_SMTEncoding_Util.mkAssume uu____5813  in
                   let fsym =
                     FStar_SMTEncoding_Term.mk_fv
                       ("f", FStar_SMTEncoding_Term.Term_sort)
                      in
                   let f = FStar_SMTEncoding_Util.mkFreeV fsym  in
                   let f_has_t = FStar_SMTEncoding_Term.mk_HasType f t2  in
                   let t_interp =
                     let a_name = Prims.op_Hat "pre_typing_" tsym  in
                     let uu____5834 =
                       let uu____5842 =
                         let uu____5843 =
                           let uu____5854 =
                             let uu____5855 =
                               let uu____5860 =
                                 let uu____5861 =
                                   FStar_SMTEncoding_Term.mk_PreType f  in
                                 FStar_SMTEncoding_Term.mk_tester "Tm_arrow"
                                   uu____5861
                                  in
                               (f_has_t, uu____5860)  in
                             FStar_SMTEncoding_Util.mkImp uu____5855  in
                           ([[f_has_t]], [fsym], uu____5854)  in
                         let uu____5887 =
                           mkForall_fuel module_name
                             t0.FStar_Syntax_Syntax.pos
                            in
                         uu____5887 uu____5843  in
                       (uu____5842, (FStar_Pervasives_Native.Some a_name),
                         a_name)
                        in
                     FStar_SMTEncoding_Util.mkAssume uu____5834  in
                   let uu____5904 =
                     FStar_All.pipe_right [tdecl; t_kinding; t_interp]
                       FStar_SMTEncoding_Term.mk_decls_trivial
                      in
                   (t2, uu____5904)))
       | FStar_Syntax_Syntax.Tm_refine uu____5907 ->
           let uu____5914 =
             let steps =
               [FStar_TypeChecker_Env.Weak;
               FStar_TypeChecker_Env.HNF;
               FStar_TypeChecker_Env.EraseUniverses]  in
             let uu____5924 =
               normalize_refinement steps env.FStar_SMTEncoding_Env.tcenv t0
                in
             match uu____5924 with
             | { FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_refine (x,f);
                 FStar_Syntax_Syntax.pos = uu____5933;
                 FStar_Syntax_Syntax.vars = uu____5934;_} ->
                 let uu____5941 =
                   FStar_Syntax_Subst.open_term
                     [(x, FStar_Pervasives_Native.None)] f
                    in
                 (match uu____5941 with
                  | (b,f1) ->
                      let uu____5968 =
                        let uu____5969 = FStar_List.hd b  in
                        FStar_Pervasives_Native.fst uu____5969  in
                      (uu____5968, f1))
             | uu____5986 -> failwith "impossible"  in
           (match uu____5914 with
            | (x,f) ->
                let uu____6004 = encode_term x.FStar_Syntax_Syntax.sort env
                   in
                (match uu____6004 with
                 | (base_t,decls) ->
                     let uu____6015 =
                       FStar_SMTEncoding_Env.gen_term_var env x  in
                     (match uu____6015 with
                      | (x1,xtm,env') ->
                          let uu____6032 = encode_formula f env'  in
                          (match uu____6032 with
                           | (refinement,decls') ->
                               let uu____6043 =
                                 FStar_SMTEncoding_Env.fresh_fvar
                                   env.FStar_SMTEncoding_Env.current_module_name
                                   "f" FStar_SMTEncoding_Term.Fuel_sort
                                  in
                               (match uu____6043 with
                                | (fsym,fterm) ->
                                    let tm_has_type_with_fuel =
                                      FStar_SMTEncoding_Term.mk_HasTypeWithFuel
                                        (FStar_Pervasives_Native.Some fterm)
                                        xtm base_t
                                       in
                                    let encoding =
                                      FStar_SMTEncoding_Util.mkAnd
                                        (tm_has_type_with_fuel, refinement)
                                       in
                                    let cvars =
                                      let uu____6071 =
                                        let uu____6082 =
                                          FStar_SMTEncoding_Term.free_variables
                                            refinement
                                           in
                                        let uu____6093 =
                                          FStar_SMTEncoding_Term.free_variables
                                            tm_has_type_with_fuel
                                           in
                                        FStar_List.append uu____6082
                                          uu____6093
                                         in
                                      FStar_Util.remove_dups
                                        FStar_SMTEncoding_Term.fv_eq
                                        uu____6071
                                       in
                                    let cvars1 =
                                      FStar_All.pipe_right cvars
                                        (FStar_List.filter
                                           (fun y  ->
                                              (let uu____6147 =
                                                 FStar_SMTEncoding_Term.fv_name
                                                   y
                                                  in
                                               uu____6147 <> x1) &&
                                                (let uu____6151 =
                                                   FStar_SMTEncoding_Term.fv_name
                                                     y
                                                    in
                                                 uu____6151 <> fsym)))
                                       in
                                    let xfv =
                                      FStar_SMTEncoding_Term.mk_fv
                                        (x1,
                                          FStar_SMTEncoding_Term.Term_sort)
                                       in
                                    let ffv =
                                      FStar_SMTEncoding_Term.mk_fv
                                        (fsym,
                                          FStar_SMTEncoding_Term.Fuel_sort)
                                       in
                                    let tkey =
                                      FStar_SMTEncoding_Term.mkForall
                                        t0.FStar_Syntax_Syntax.pos
                                        ([], (ffv :: xfv :: cvars1),
                                          encoding)
                                       in
                                    let tkey_hash =
                                      FStar_SMTEncoding_Term.hash_of_term
                                        tkey
                                       in
                                    ((let uu____6184 =
                                        FStar_TypeChecker_Env.debug
                                          env.FStar_SMTEncoding_Env.tcenv
                                          (FStar_Options.Other "SMTEncoding")
                                         in
                                      if uu____6184
                                      then
                                        let uu____6188 =
                                          FStar_Syntax_Print.term_to_string f
                                           in
                                        let uu____6190 =
                                          FStar_Util.digest_of_string
                                            tkey_hash
                                           in
                                        FStar_Util.print3
                                          "Encoding Tm_refine %s with tkey_hash %s and digest %s\n"
                                          uu____6188 tkey_hash uu____6190
                                      else ());
                                     (let tsym =
                                        let uu____6197 =
                                          FStar_Util.digest_of_string
                                            tkey_hash
                                           in
                                        Prims.op_Hat "Tm_refine_" uu____6197
                                         in
                                      let cvar_sorts =
                                        FStar_List.map
                                          FStar_SMTEncoding_Term.fv_sort
                                          cvars1
                                         in
                                      let tdecl =
                                        FStar_SMTEncoding_Term.DeclFun
                                          (tsym, cvar_sorts,
                                            FStar_SMTEncoding_Term.Term_sort,
                                            FStar_Pervasives_Native.None)
                                         in
                                      let t2 =
                                        let uu____6217 =
                                          let uu____6225 =
                                            FStar_List.map
                                              FStar_SMTEncoding_Util.mkFreeV
                                              cvars1
                                             in
                                          (tsym, uu____6225)  in
                                        FStar_SMTEncoding_Util.mkApp
                                          uu____6217
                                         in
                                      let x_has_base_t =
                                        FStar_SMTEncoding_Term.mk_HasType xtm
                                          base_t
                                         in
                                      let x_has_t =
                                        FStar_SMTEncoding_Term.mk_HasTypeWithFuel
                                          (FStar_Pervasives_Native.Some fterm)
                                          xtm t2
                                         in
                                      let t_has_kind =
                                        FStar_SMTEncoding_Term.mk_HasType t2
                                          FStar_SMTEncoding_Term.mk_Term_type
                                         in
                                      let t_haseq_base =
                                        FStar_SMTEncoding_Term.mk_haseq
                                          base_t
                                         in
                                      let t_haseq_ref =
                                        FStar_SMTEncoding_Term.mk_haseq t2
                                         in
                                      let t_haseq =
                                        let uu____6245 =
                                          let uu____6253 =
                                            let uu____6254 =
                                              let uu____6265 =
                                                FStar_SMTEncoding_Util.mkIff
                                                  (t_haseq_ref, t_haseq_base)
                                                 in
                                              ([[t_haseq_ref]], cvars1,
                                                uu____6265)
                                               in
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              uu____6254
                                             in
                                          (uu____6253,
                                            (FStar_Pervasives_Native.Some
                                               (Prims.op_Hat "haseq for "
                                                  tsym)),
                                            (Prims.op_Hat "haseq" tsym))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____6245
                                         in
                                      let t_kinding =
                                        let uu____6279 =
                                          let uu____6287 =
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              ([[t_has_kind]], cvars1,
                                                t_has_kind)
                                             in
                                          (uu____6287,
                                            (FStar_Pervasives_Native.Some
                                               "refinement kinding"),
                                            (Prims.op_Hat
                                               "refinement_kinding_" tsym))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____6279
                                         in
                                      let t_interp =
                                        let uu____6301 =
                                          let uu____6309 =
                                            let uu____6310 =
                                              let uu____6321 =
                                                FStar_SMTEncoding_Util.mkIff
                                                  (x_has_t, encoding)
                                                 in
                                              ([[x_has_t]], (ffv :: xfv ::
                                                cvars1), uu____6321)
                                               in
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              uu____6310
                                             in
                                          (uu____6309,
                                            (FStar_Pervasives_Native.Some
                                               "refinement_interpretation"),
                                            (Prims.op_Hat
                                               "refinement_interpretation_"
                                               tsym))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____6301
                                         in
                                      let t_decls =
                                        [tdecl; t_kinding; t_interp; t_haseq]
                                         in
                                      let uu____6353 =
                                        let uu____6354 =
                                          let uu____6357 =
                                            FStar_SMTEncoding_Term.mk_decls
                                              tsym tkey_hash t_decls
                                              (FStar_List.append decls decls')
                                             in
                                          FStar_List.append decls' uu____6357
                                           in
                                        FStar_List.append decls uu____6354
                                         in
                                      (t2, uu____6353))))))))
       | FStar_Syntax_Syntax.Tm_uvar (uv,uu____6361) ->
           let ttm =
             let uu____6379 =
               FStar_Syntax_Unionfind.uvar_id
                 uv.FStar_Syntax_Syntax.ctx_uvar_head
                in
             FStar_SMTEncoding_Util.mk_Term_uvar uu____6379  in
           let uu____6381 =
             encode_term_pred FStar_Pervasives_Native.None
               uv.FStar_Syntax_Syntax.ctx_uvar_typ env ttm
              in
           (match uu____6381 with
            | (t_has_k,decls) ->
                let d =
                  let uu____6393 =
                    let uu____6401 =
                      let uu____6403 =
                        let uu____6405 =
                          let uu____6407 =
                            FStar_Syntax_Unionfind.uvar_id
                              uv.FStar_Syntax_Syntax.ctx_uvar_head
                             in
                          FStar_Util.string_of_int uu____6407  in
                        FStar_Util.format1 "uvar_typing_%s" uu____6405  in
                      FStar_SMTEncoding_Env.varops.FStar_SMTEncoding_Env.mk_unique
                        uu____6403
                       in
                    (t_has_k, (FStar_Pervasives_Native.Some "Uvar typing"),
                      uu____6401)
                     in
                  FStar_SMTEncoding_Util.mkAssume uu____6393  in
                let uu____6413 =
                  let uu____6414 =
                    FStar_All.pipe_right [d]
                      FStar_SMTEncoding_Term.mk_decls_trivial
                     in
                  FStar_List.append decls uu____6414  in
                (ttm, uu____6413))
       | FStar_Syntax_Syntax.Tm_app uu____6421 ->
           let uu____6438 = FStar_Syntax_Util.head_and_args t0  in
           (match uu____6438 with
            | (head,args_e) ->
                let uu____6485 =
                  let uu____6502 = head_redex env head  in
                  if uu____6502
                  then
                    let uu____6521 = maybe_whnf env t0  in
                    match uu____6521 with
                    | FStar_Pervasives_Native.None  -> (head, args_e)
                    | FStar_Pervasives_Native.Some t2 ->
                        FStar_Syntax_Util.head_and_args t2
                  else (head, args_e)  in
                (match uu____6485 with
                 | (head1,args_e1) ->
                     let uu____6597 =
                       let uu____6612 =
                         let uu____6613 = FStar_Syntax_Subst.compress head1
                            in
                         uu____6613.FStar_Syntax_Syntax.n  in
                       (uu____6612, args_e1)  in
                     (match uu____6597 with
                      | uu____6630 when is_arithmetic_primitive head1 args_e1
                          -> encode_arith_term env head1 args_e1
                      | uu____6653 when is_BitVector_primitive head1 args_e1
                          -> encode_BitVector_term env head1 args_e1
                      | (FStar_Syntax_Syntax.Tm_fvar fv,uu____6671) when
                          (Prims.op_Negation
                             env.FStar_SMTEncoding_Env.encoding_quantifier)
                            &&
                            ((FStar_Syntax_Syntax.fv_eq_lid fv
                                FStar_Parser_Const.forall_lid)
                               ||
                               (FStar_Syntax_Syntax.fv_eq_lid fv
                                  FStar_Parser_Const.exists_lid))
                          -> encode_deeply_embedded_quantifier t0 env
                      | (FStar_Syntax_Syntax.Tm_uinst
                         ({
                            FStar_Syntax_Syntax.n =
                              FStar_Syntax_Syntax.Tm_fvar fv;
                            FStar_Syntax_Syntax.pos = uu____6693;
                            FStar_Syntax_Syntax.vars = uu____6694;_},uu____6695),uu____6696)
                          when
                          (Prims.op_Negation
                             env.FStar_SMTEncoding_Env.encoding_quantifier)
                            &&
                            ((FStar_Syntax_Syntax.fv_eq_lid fv
                                FStar_Parser_Const.forall_lid)
                               ||
                               (FStar_Syntax_Syntax.fv_eq_lid fv
                                  FStar_Parser_Const.exists_lid))
                          -> encode_deeply_embedded_quantifier t0 env
                      | (FStar_Syntax_Syntax.Tm_uinst
                         ({
                            FStar_Syntax_Syntax.n =
                              FStar_Syntax_Syntax.Tm_fvar fv;
                            FStar_Syntax_Syntax.pos = uu____6722;
                            FStar_Syntax_Syntax.vars = uu____6723;_},uu____6724),
                         (v0,uu____6726)::(v1,uu____6728)::(v2,uu____6730)::[])
                          when
                          FStar_Syntax_Syntax.fv_eq_lid fv
                            FStar_Parser_Const.lexcons_lid
                          ->
                          let uu____6801 = encode_term v0 env  in
                          (match uu____6801 with
                           | (v01,decls0) ->
                               let uu____6812 = encode_term v1 env  in
                               (match uu____6812 with
                                | (v11,decls1) ->
                                    let uu____6823 = encode_term v2 env  in
                                    (match uu____6823 with
                                     | (v21,decls2) ->
                                         let uu____6834 =
                                           FStar_SMTEncoding_Util.mk_LexCons
                                             v01 v11 v21
                                            in
                                         (uu____6834,
                                           (FStar_List.append decls0
                                              (FStar_List.append decls1
                                                 decls2))))))
                      | (FStar_Syntax_Syntax.Tm_fvar
                         fv,(v0,uu____6837)::(v1,uu____6839)::(v2,uu____6841)::[])
                          when
                          FStar_Syntax_Syntax.fv_eq_lid fv
                            FStar_Parser_Const.lexcons_lid
                          ->
                          let uu____6908 = encode_term v0 env  in
                          (match uu____6908 with
                           | (v01,decls0) ->
                               let uu____6919 = encode_term v1 env  in
                               (match uu____6919 with
                                | (v11,decls1) ->
                                    let uu____6930 = encode_term v2 env  in
                                    (match uu____6930 with
                                     | (v21,decls2) ->
                                         let uu____6941 =
                                           FStar_SMTEncoding_Util.mk_LexCons
                                             v01 v11 v21
                                            in
                                         (uu____6941,
                                           (FStar_List.append decls0
                                              (FStar_List.append decls1
                                                 decls2))))))
                      | (FStar_Syntax_Syntax.Tm_constant
                         (FStar_Const.Const_range_of ),(arg,uu____6943)::[])
                          ->
                          encode_const
                            (FStar_Const.Const_range
                               (arg.FStar_Syntax_Syntax.pos)) env
                      | (FStar_Syntax_Syntax.Tm_constant
                         (FStar_Const.Const_set_range_of
                         ),(arg,uu____6979)::(rng,uu____6981)::[]) ->
                          encode_term arg env
                      | (FStar_Syntax_Syntax.Tm_constant
                         (FStar_Const.Const_reify ),uu____7032) ->
                          let e0 =
                            let uu____7054 = FStar_List.hd args_e1  in
                            FStar_TypeChecker_Util.reify_body_with_arg
                              env.FStar_SMTEncoding_Env.tcenv [] head1
                              uu____7054
                             in
                          ((let uu____7064 =
                              FStar_All.pipe_left
                                (FStar_TypeChecker_Env.debug
                                   env.FStar_SMTEncoding_Env.tcenv)
                                (FStar_Options.Other "SMTEncodingReify")
                               in
                            if uu____7064
                            then
                              let uu____7069 =
                                FStar_Syntax_Print.term_to_string e0  in
                              FStar_Util.print1
                                "Result of normalization %s\n" uu____7069
                            else ());
                           (let e =
                              let uu____7077 =
                                let uu____7082 =
                                  FStar_TypeChecker_Util.remove_reify e0  in
                                let uu____7083 = FStar_List.tl args_e1  in
                                FStar_Syntax_Syntax.mk_Tm_app uu____7082
                                  uu____7083
                                 in
                              uu____7077 FStar_Pervasives_Native.None
                                t0.FStar_Syntax_Syntax.pos
                               in
                            encode_term e env))
                      | (FStar_Syntax_Syntax.Tm_constant
                         (FStar_Const.Const_reflect
                         uu____7092),(arg,uu____7094)::[]) ->
                          encode_term arg env
                      | uu____7129 ->
                          let uu____7144 = encode_args args_e1 env  in
                          (match uu____7144 with
                           | (args,decls) ->
                               let encode_partial_app ht_opt =
                                 let uu____7213 = encode_term head1 env  in
                                 match uu____7213 with
                                 | (smt_head,decls') ->
                                     let app_tm = mk_Apply_args smt_head args
                                        in
                                     (match ht_opt with
                                      | uu____7233 when
                                          Prims.int_one = Prims.int_one ->
                                          (app_tm,
                                            (FStar_List.append decls decls'))
                                      | FStar_Pervasives_Native.Some
                                          (head_type,formals,c) ->
                                          ((let uu____7305 =
                                              FStar_TypeChecker_Env.debug
                                                env.FStar_SMTEncoding_Env.tcenv
                                                (FStar_Options.Other
                                                   "PartialApp")
                                               in
                                            if uu____7305
                                            then
                                              let uu____7309 =
                                                FStar_Syntax_Print.term_to_string
                                                  head1
                                                 in
                                              let uu____7311 =
                                                FStar_Syntax_Print.term_to_string
                                                  head_type
                                                 in
                                              let uu____7313 =
                                                FStar_Syntax_Print.binders_to_string
                                                  ", " formals
                                                 in
                                              let uu____7316 =
                                                FStar_Syntax_Print.comp_to_string
                                                  c
                                                 in
                                              let uu____7318 =
                                                FStar_Syntax_Print.args_to_string
                                                  args_e1
                                                 in
                                              FStar_Util.print5
                                                "Encoding partial application:\n\thead=%s\n\thead_type=%s\n\tformals=%s\n\tcomp=%s\n\tactual args=%s\n"
                                                uu____7309 uu____7311
                                                uu____7313 uu____7316
                                                uu____7318
                                            else ());
                                           (let uu____7323 =
                                              FStar_Util.first_N
                                                (FStar_List.length args_e1)
                                                formals
                                               in
                                            match uu____7323 with
                                            | (formals1,rest) ->
                                                let subst =
                                                  FStar_List.map2
                                                    (fun uu____7421  ->
                                                       fun uu____7422  ->
                                                         match (uu____7421,
                                                                 uu____7422)
                                                         with
                                                         | ((bv,uu____7452),
                                                            (a,uu____7454))
                                                             ->
                                                             FStar_Syntax_Syntax.NT
                                                               (bv, a))
                                                    formals1 args_e1
                                                   in
                                                let ty =
                                                  let uu____7486 =
                                                    FStar_Syntax_Util.arrow
                                                      rest c
                                                     in
                                                  FStar_All.pipe_right
                                                    uu____7486
                                                    (FStar_Syntax_Subst.subst
                                                       subst)
                                                   in
                                                ((let uu____7490 =
                                                    FStar_TypeChecker_Env.debug
                                                      env.FStar_SMTEncoding_Env.tcenv
                                                      (FStar_Options.Other
                                                         "PartialApp")
                                                     in
                                                  if uu____7490
                                                  then
                                                    let uu____7494 =
                                                      FStar_Syntax_Print.term_to_string
                                                        ty
                                                       in
                                                    FStar_Util.print1
                                                      "Encoding partial application, after subst:\n\tty=%s\n"
                                                      uu____7494
                                                  else ());
                                                 (let uu____7499 =
                                                    let uu____7512 =
                                                      FStar_List.fold_left2
                                                        (fun uu____7547  ->
                                                           fun uu____7548  ->
                                                             fun e  ->
                                                               match 
                                                                 (uu____7547,
                                                                   uu____7548)
                                                               with
                                                               | ((t_hyps,decls1),
                                                                  (bv,uu____7589))
                                                                   ->
                                                                   let t2 =
                                                                    FStar_Syntax_Subst.subst
                                                                    subst
                                                                    bv.FStar_Syntax_Syntax.sort
                                                                     in
                                                                   let uu____7617
                                                                    =
                                                                    encode_term_pred
                                                                    FStar_Pervasives_Native.None
                                                                    t2 env e
                                                                     in
                                                                   (match uu____7617
                                                                    with
                                                                    | 
                                                                    (t_hyp,decls'1)
                                                                    ->
                                                                    ((
                                                                    let uu____7633
                                                                    =
                                                                    FStar_TypeChecker_Env.debug
                                                                    env.FStar_SMTEncoding_Env.tcenv
                                                                    (FStar_Options.Other
                                                                    "PartialApp")
                                                                     in
                                                                    if
                                                                    uu____7633
                                                                    then
                                                                    let uu____7637
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    t2  in
                                                                    let uu____7639
                                                                    =
                                                                    FStar_SMTEncoding_Term.print_smt_term
                                                                    t_hyp  in
                                                                    FStar_Util.print2
                                                                    "Encoded typing hypothesis for %s ... got %s\n"
                                                                    uu____7637
                                                                    uu____7639
                                                                    else ());
                                                                    ((t_hyp
                                                                    ::
                                                                    t_hyps),
                                                                    (FStar_List.append
                                                                    decls1
                                                                    decls'1)))))
                                                        ([], []) formals1
                                                        args
                                                       in
                                                    match uu____7512 with
                                                    | (t_hyps,decls1) ->
                                                        let uu____7674 =
                                                          match smt_head.FStar_SMTEncoding_Term.tm
                                                          with
                                                          | FStar_SMTEncoding_Term.FreeV
                                                              uu____7683 ->
                                                              encode_term_pred
                                                                FStar_Pervasives_Native.None
                                                                head_type env
                                                                smt_head
                                                          | uu____7692 ->
                                                              (FStar_SMTEncoding_Util.mkTrue,
                                                                [])
                                                           in
                                                        (match uu____7674
                                                         with
                                                         | (t_head_hyp,decls'1)
                                                             ->
                                                             let hyp =
                                                               FStar_SMTEncoding_Term.mk_and_l
                                                                 (t_head_hyp
                                                                 :: t_hyps)
                                                                 FStar_Range.dummyRange
                                                                in
                                                             let uu____7708 =
                                                               encode_term_pred
                                                                 FStar_Pervasives_Native.None
                                                                 ty env
                                                                 app_tm
                                                                in
                                                             (match uu____7708
                                                              with
                                                              | (has_type_conclusion,decls'')
                                                                  ->
                                                                  let has_type
                                                                    =
                                                                    FStar_SMTEncoding_Util.mkImp
                                                                    (hyp,
                                                                    has_type_conclusion)
                                                                     in
                                                                  let cvars =
                                                                    FStar_SMTEncoding_Term.free_variables
                                                                    has_type
                                                                     in
                                                                  let app_tm_vars
                                                                    =
                                                                    FStar_SMTEncoding_Term.free_variables
                                                                    app_tm
                                                                     in
                                                                  let uu____7730
                                                                    =
                                                                    let uu____7737
                                                                    =
                                                                    FStar_SMTEncoding_Term.fvs_subset_of
                                                                    cvars
                                                                    app_tm_vars
                                                                     in
                                                                    if
                                                                    uu____7737
                                                                    then
                                                                    ([app_tm],
                                                                    app_tm_vars)
                                                                    else
                                                                    (let uu____7750
                                                                    =
                                                                    let uu____7752
                                                                    =
                                                                    FStar_SMTEncoding_Term.free_variables
                                                                    has_type_conclusion
                                                                     in
                                                                    FStar_SMTEncoding_Term.fvs_subset_of
                                                                    cvars
                                                                    uu____7752
                                                                     in
                                                                    if
                                                                    uu____7750
                                                                    then
                                                                    ([has_type_conclusion],
                                                                    cvars)
                                                                    else
                                                                    ((
                                                                    let uu____7765
                                                                    =
                                                                    let uu____7771
                                                                    =
                                                                    let uu____7773
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    t0  in
                                                                    FStar_Util.format1
                                                                    "No SMT pattern for partial application %s"
                                                                    uu____7773
                                                                     in
                                                                    (FStar_Errors.Warning_SMTPatternIllFormed,
                                                                    uu____7771)
                                                                     in
                                                                    FStar_Errors.log_issue
                                                                    t0.FStar_Syntax_Syntax.pos
                                                                    uu____7765);
                                                                    ([],
                                                                    cvars)))
                                                                     in
                                                                  (match uu____7730
                                                                   with
                                                                   | 
                                                                   (pattern1,vars)
                                                                    ->
                                                                    (vars,
                                                                    pattern1,
                                                                    has_type,
                                                                    (FStar_List.append
                                                                    decls1
                                                                    (FStar_List.append
                                                                    decls'1
                                                                    decls''))))))
                                                     in
                                                  match uu____7499 with
                                                  | (vars,pattern1,has_type,decls'')
                                                      ->
                                                      ((let uu____7820 =
                                                          FStar_TypeChecker_Env.debug
                                                            env.FStar_SMTEncoding_Env.tcenv
                                                            (FStar_Options.Other
                                                               "PartialApp")
                                                           in
                                                        if uu____7820
                                                        then
                                                          let uu____7824 =
                                                            FStar_SMTEncoding_Term.print_smt_term
                                                              has_type
                                                             in
                                                          FStar_Util.print1
                                                            "Encoding partial application, after SMT encoded predicate:\n\t=%s\n"
                                                            uu____7824
                                                        else ());
                                                       (let tkey_hash =
                                                          FStar_SMTEncoding_Term.hash_of_term
                                                            app_tm
                                                           in
                                                        let e_typing =
                                                          let uu____7832 =
                                                            let uu____7840 =
                                                              FStar_SMTEncoding_Term.mkForall
                                                                t0.FStar_Syntax_Syntax.pos
                                                                ([pattern1],
                                                                  vars,
                                                                  has_type)
                                                               in
                                                            let uu____7849 =
                                                              let uu____7851
                                                                =
                                                                let uu____7853
                                                                  =
                                                                  FStar_SMTEncoding_Term.hash_of_term
                                                                    app_tm
                                                                   in
                                                                FStar_Util.digest_of_string
                                                                  uu____7853
                                                                 in
                                                              Prims.op_Hat
                                                                "partial_app_typing_"
                                                                uu____7851
                                                               in
                                                            (uu____7840,
                                                              (FStar_Pervasives_Native.Some
                                                                 "Partial app typing"),
                                                              uu____7849)
                                                             in
                                                          FStar_SMTEncoding_Util.mkAssume
                                                            uu____7832
                                                           in
                                                        let uu____7859 =
                                                          let uu____7862 =
                                                            let uu____7865 =
                                                              let uu____7868
                                                                =
                                                                FStar_SMTEncoding_Term.mk_decls
                                                                  ""
                                                                  tkey_hash
                                                                  [e_typing]
                                                                  (FStar_List.append
                                                                    decls
                                                                    (FStar_List.append
                                                                    decls'
                                                                    decls''))
                                                                 in
                                                              FStar_List.append
                                                                decls''
                                                                uu____7868
                                                               in
                                                            FStar_List.append
                                                              decls'
                                                              uu____7865
                                                             in
                                                          FStar_List.append
                                                            decls uu____7862
                                                           in
                                                        (app_tm, uu____7859)))))))
                                      | FStar_Pervasives_Native.None  ->
                                          failwith "impossible")
                                  in
                               let encode_full_app fv =
                                 let uu____7913 =
                                   FStar_SMTEncoding_Env.lookup_free_var_sym
                                     env fv
                                    in
                                 match uu____7913 with
                                 | (fname,fuel_args,arity) ->
                                     let tm =
                                       maybe_curry_app
                                         t0.FStar_Syntax_Syntax.pos fname
                                         arity
                                         (FStar_List.append fuel_args args)
                                        in
                                     (tm, decls)
                                  in
                               let head2 = FStar_Syntax_Subst.compress head1
                                  in
                               let head_type =
                                 match head2.FStar_Syntax_Syntax.n with
                                 | FStar_Syntax_Syntax.Tm_uinst
                                     ({
                                        FStar_Syntax_Syntax.n =
                                          FStar_Syntax_Syntax.Tm_name x;
                                        FStar_Syntax_Syntax.pos = uu____7956;
                                        FStar_Syntax_Syntax.vars = uu____7957;_},uu____7958)
                                     ->
                                     FStar_Pervasives_Native.Some
                                       (x.FStar_Syntax_Syntax.sort)
                                 | FStar_Syntax_Syntax.Tm_name x ->
                                     FStar_Pervasives_Native.Some
                                       (x.FStar_Syntax_Syntax.sort)
                                 | FStar_Syntax_Syntax.Tm_uinst
                                     ({
                                        FStar_Syntax_Syntax.n =
                                          FStar_Syntax_Syntax.Tm_fvar fv;
                                        FStar_Syntax_Syntax.pos = uu____7965;
                                        FStar_Syntax_Syntax.vars = uu____7966;_},uu____7967)
                                     ->
                                     let uu____7972 =
                                       let uu____7973 =
                                         let uu____7978 =
                                           FStar_TypeChecker_Env.lookup_lid
                                             env.FStar_SMTEncoding_Env.tcenv
                                             (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                            in
                                         FStar_All.pipe_right uu____7978
                                           FStar_Pervasives_Native.fst
                                          in
                                       FStar_All.pipe_right uu____7973
                                         FStar_Pervasives_Native.snd
                                        in
                                     FStar_Pervasives_Native.Some uu____7972
                                 | FStar_Syntax_Syntax.Tm_fvar fv ->
                                     let uu____8008 =
                                       let uu____8009 =
                                         let uu____8014 =
                                           FStar_TypeChecker_Env.lookup_lid
                                             env.FStar_SMTEncoding_Env.tcenv
                                             (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                            in
                                         FStar_All.pipe_right uu____8014
                                           FStar_Pervasives_Native.fst
                                          in
                                       FStar_All.pipe_right uu____8009
                                         FStar_Pervasives_Native.snd
                                        in
                                     FStar_Pervasives_Native.Some uu____8008
                                 | FStar_Syntax_Syntax.Tm_ascribed
                                     (uu____8043,(FStar_Util.Inl
                                                  t2,uu____8045),uu____8046)
                                     -> FStar_Pervasives_Native.Some t2
                                 | FStar_Syntax_Syntax.Tm_ascribed
                                     (uu____8093,(FStar_Util.Inr
                                                  c,uu____8095),uu____8096)
                                     ->
                                     FStar_Pervasives_Native.Some
                                       (FStar_Syntax_Util.comp_result c)
                                 | uu____8143 -> FStar_Pervasives_Native.None
                                  in
                               (match head_type with
                                | FStar_Pervasives_Native.None  ->
                                    encode_partial_app
                                      FStar_Pervasives_Native.None
                                | FStar_Pervasives_Native.Some head_type1 ->
                                    let uu____8167 =
                                      let head_type2 =
                                        let uu____8189 =
                                          normalize_refinement
                                            [FStar_TypeChecker_Env.Weak;
                                            FStar_TypeChecker_Env.HNF;
                                            FStar_TypeChecker_Env.EraseUniverses]
                                            env.FStar_SMTEncoding_Env.tcenv
                                            head_type1
                                           in
                                        FStar_All.pipe_left
                                          FStar_Syntax_Util.unrefine
                                          uu____8189
                                         in
                                      let uu____8192 =
                                        curried_arrow_formals_comp head_type2
                                         in
                                      match uu____8192 with
                                      | (formals,c) ->
                                          if
                                            (FStar_List.length formals) <
                                              (FStar_List.length args)
                                          then
                                            let head_type3 =
                                              let uu____8243 =
                                                normalize_refinement
                                                  [FStar_TypeChecker_Env.Weak;
                                                  FStar_TypeChecker_Env.HNF;
                                                  FStar_TypeChecker_Env.EraseUniverses;
                                                  FStar_TypeChecker_Env.UnfoldUntil
                                                    FStar_Syntax_Syntax.delta_constant]
                                                  env.FStar_SMTEncoding_Env.tcenv
                                                  head_type2
                                                 in
                                              FStar_All.pipe_left
                                                FStar_Syntax_Util.unrefine
                                                uu____8243
                                               in
                                            let uu____8244 =
                                              curried_arrow_formals_comp
                                                head_type3
                                               in
                                            (match uu____8244 with
                                             | (formals1,c1) ->
                                                 (head_type3, formals1, c1))
                                          else (head_type2, formals, c)
                                       in
                                    (match uu____8167 with
                                     | (head_type2,formals,c) ->
                                         ((let uu____8327 =
                                             FStar_TypeChecker_Env.debug
                                               env.FStar_SMTEncoding_Env.tcenv
                                               (FStar_Options.Other
                                                  "PartialApp")
                                              in
                                           if uu____8327
                                           then
                                             let uu____8331 =
                                               FStar_Syntax_Print.term_to_string
                                                 head_type2
                                                in
                                             let uu____8333 =
                                               FStar_Syntax_Print.binders_to_string
                                                 ", " formals
                                                in
                                             let uu____8336 =
                                               FStar_Syntax_Print.args_to_string
                                                 args_e1
                                                in
                                             FStar_Util.print3
                                               "Encoding partial application, head_type = %s, formals = %s, args = %s\n"
                                               uu____8331 uu____8333
                                               uu____8336
                                           else ());
                                          (match head2.FStar_Syntax_Syntax.n
                                           with
                                           | FStar_Syntax_Syntax.Tm_uinst
                                               ({
                                                  FStar_Syntax_Syntax.n =
                                                    FStar_Syntax_Syntax.Tm_fvar
                                                    fv;
                                                  FStar_Syntax_Syntax.pos =
                                                    uu____8346;
                                                  FStar_Syntax_Syntax.vars =
                                                    uu____8347;_},uu____8348)
                                               when
                                               (FStar_List.length formals) =
                                                 (FStar_List.length args)
                                               ->
                                               encode_full_app
                                                 fv.FStar_Syntax_Syntax.fv_name
                                           | FStar_Syntax_Syntax.Tm_fvar fv
                                               when
                                               (FStar_List.length formals) =
                                                 (FStar_List.length args)
                                               ->
                                               encode_full_app
                                                 fv.FStar_Syntax_Syntax.fv_name
                                           | uu____8366 ->
                                               if
                                                 (FStar_List.length formals)
                                                   > (FStar_List.length args)
                                               then
                                                 encode_partial_app
                                                   (FStar_Pervasives_Native.Some
                                                      (head_type2, formals,
                                                        c))
                                               else
                                                 encode_partial_app
                                                   FStar_Pervasives_Native.None))))))))
       | FStar_Syntax_Syntax.Tm_abs (bs,body,lopt) ->
           let uu____8455 = FStar_Syntax_Subst.open_term' bs body  in
           (match uu____8455 with
            | (bs1,body1,opening) ->
                let fallback uu____8478 =
                  let f =
                    FStar_SMTEncoding_Env.varops.FStar_SMTEncoding_Env.fresh
                      env.FStar_SMTEncoding_Env.current_module_name "Tm_abs"
                     in
                  let decl =
                    FStar_SMTEncoding_Term.DeclFun
                      (f, [], FStar_SMTEncoding_Term.Term_sort,
                        (FStar_Pervasives_Native.Some
                           "Imprecise function encoding"))
                     in
                  let uu____8488 =
                    let uu____8489 =
                      FStar_SMTEncoding_Term.mk_fv
                        (f, FStar_SMTEncoding_Term.Term_sort)
                       in
                    FStar_All.pipe_left FStar_SMTEncoding_Util.mkFreeV
                      uu____8489
                     in
                  let uu____8491 =
                    FStar_All.pipe_right [decl]
                      FStar_SMTEncoding_Term.mk_decls_trivial
                     in
                  (uu____8488, uu____8491)  in
                let is_impure rc =
                  let uu____8501 =
                    FStar_TypeChecker_Util.is_pure_or_ghost_effect
                      env.FStar_SMTEncoding_Env.tcenv
                      rc.FStar_Syntax_Syntax.residual_effect
                     in
                  FStar_All.pipe_right uu____8501 Prims.op_Negation  in
                let codomain_eff rc =
                  let res_typ =
                    match rc.FStar_Syntax_Syntax.residual_typ with
                    | FStar_Pervasives_Native.None  ->
                        let uu____8516 =
                          let uu____8529 =
                            FStar_TypeChecker_Env.get_range
                              env.FStar_SMTEncoding_Env.tcenv
                             in
                          FStar_TypeChecker_Util.new_implicit_var
                            "SMTEncoding codomain" uu____8529
                            env.FStar_SMTEncoding_Env.tcenv
                            FStar_Syntax_Util.ktype0
                           in
                        (match uu____8516 with
                         | (t2,uu____8532,uu____8533) -> t2)
                    | FStar_Pervasives_Native.Some t2 -> t2  in
                  let uu____8551 =
                    FStar_Ident.lid_equals
                      rc.FStar_Syntax_Syntax.residual_effect
                      FStar_Parser_Const.effect_Tot_lid
                     in
                  if uu____8551
                  then
                    let uu____8556 = FStar_Syntax_Syntax.mk_Total res_typ  in
                    FStar_Pervasives_Native.Some uu____8556
                  else
                    (let uu____8559 =
                       FStar_Ident.lid_equals
                         rc.FStar_Syntax_Syntax.residual_effect
                         FStar_Parser_Const.effect_GTot_lid
                        in
                     if uu____8559
                     then
                       let uu____8564 = FStar_Syntax_Syntax.mk_GTotal res_typ
                          in
                       FStar_Pervasives_Native.Some uu____8564
                     else FStar_Pervasives_Native.None)
                   in
                (match lopt with
                 | FStar_Pervasives_Native.None  ->
                     ((let uu____8572 =
                         let uu____8578 =
                           let uu____8580 =
                             FStar_Syntax_Print.term_to_string t0  in
                           FStar_Util.format1
                             "Losing precision when encoding a function literal: %s\n(Unnannotated abstraction in the compiler ?)"
                             uu____8580
                            in
                         (FStar_Errors.Warning_FunctionLiteralPrecisionLoss,
                           uu____8578)
                          in
                       FStar_Errors.log_issue t0.FStar_Syntax_Syntax.pos
                         uu____8572);
                      fallback ())
                 | FStar_Pervasives_Native.Some rc ->
                     let uu____8585 =
                       (is_impure rc) &&
                         (let uu____8588 =
                            FStar_SMTEncoding_Util.is_smt_reifiable_rc
                              env.FStar_SMTEncoding_Env.tcenv rc
                             in
                          Prims.op_Negation uu____8588)
                        in
                     if uu____8585
                     then fallback ()
                     else
                       (let uu____8597 =
                          encode_binders FStar_Pervasives_Native.None bs1 env
                           in
                        match uu____8597 with
                        | (vars,guards,envbody,decls,uu____8622) ->
                            let body2 =
                              let uu____8636 =
                                FStar_SMTEncoding_Util.is_smt_reifiable_rc
                                  env.FStar_SMTEncoding_Env.tcenv rc
                                 in
                              if uu____8636
                              then
                                FStar_TypeChecker_Util.reify_body
                                  env.FStar_SMTEncoding_Env.tcenv [] body1
                              else body1  in
                            let uu____8641 = encode_term body2 envbody  in
                            (match uu____8641 with
                             | (body3,decls') ->
                                 let is_pure =
                                   FStar_Syntax_Util.is_pure_effect
                                     rc.FStar_Syntax_Syntax.residual_effect
                                    in
                                 let uu____8654 =
                                   let uu____8663 = codomain_eff rc  in
                                   match uu____8663 with
                                   | FStar_Pervasives_Native.None  ->
                                       (FStar_Pervasives_Native.None, [])
                                   | FStar_Pervasives_Native.Some c ->
                                       let tfun =
                                         FStar_Syntax_Util.arrow bs1 c  in
                                       let uu____8682 = encode_term tfun env
                                          in
                                       (match uu____8682 with
                                        | (t2,decls1) ->
                                            ((FStar_Pervasives_Native.Some t2),
                                              decls1))
                                    in
                                 (match uu____8654 with
                                  | (arrow_t_opt,decls'') ->
                                      let key_body =
                                        let uu____8716 =
                                          let uu____8727 =
                                            let uu____8728 =
                                              let uu____8733 =
                                                FStar_SMTEncoding_Util.mk_and_l
                                                  guards
                                                 in
                                              (uu____8733, body3)  in
                                            FStar_SMTEncoding_Util.mkImp
                                              uu____8728
                                             in
                                          ([], vars, uu____8727)  in
                                        FStar_SMTEncoding_Term.mkForall
                                          t0.FStar_Syntax_Syntax.pos
                                          uu____8716
                                         in
                                      let cvars =
                                        FStar_SMTEncoding_Term.free_variables
                                          key_body
                                         in
                                      let uu____8741 =
                                        match arrow_t_opt with
                                        | FStar_Pervasives_Native.None  ->
                                            (cvars, key_body)
                                        | FStar_Pervasives_Native.Some t2 ->
                                            let uu____8757 =
                                              let uu____8760 =
                                                let uu____8771 =
                                                  FStar_SMTEncoding_Term.free_variables
                                                    t2
                                                   in
                                                FStar_List.append uu____8771
                                                  cvars
                                                 in
                                              FStar_Util.remove_dups
                                                FStar_SMTEncoding_Term.fv_eq
                                                uu____8760
                                               in
                                            let uu____8798 =
                                              FStar_SMTEncoding_Util.mkAnd
                                                (key_body, t2)
                                               in
                                            (uu____8757, uu____8798)
                                         in
                                      (match uu____8741 with
                                       | (cvars1,key_body1) ->
                                           let tkey =
                                             FStar_SMTEncoding_Term.mkForall
                                               t0.FStar_Syntax_Syntax.pos
                                               ([], cvars1, key_body1)
                                              in
                                           let tkey_hash =
                                             FStar_SMTEncoding_Term.hash_of_term
                                               tkey
                                              in
                                           ((let uu____8821 =
                                               FStar_All.pipe_left
                                                 (FStar_TypeChecker_Env.debug
                                                    env.FStar_SMTEncoding_Env.tcenv)
                                                 (FStar_Options.Other
                                                    "PartialApp")
                                                in
                                             if uu____8821
                                             then
                                               let uu____8826 =
                                                 let uu____8828 =
                                                   FStar_List.map
                                                     FStar_SMTEncoding_Term.fv_name
                                                     vars
                                                    in
                                                 FStar_All.pipe_right
                                                   uu____8828
                                                   (FStar_String.concat ", ")
                                                  in
                                               let uu____8838 =
                                                 FStar_SMTEncoding_Term.print_smt_term
                                                   body3
                                                  in
                                               FStar_Util.print2
                                                 "Checking eta expansion of\n\tvars={%s}\n\tbody=%s\n"
                                                 uu____8826 uu____8838
                                             else ());
                                            (let uu____8843 =
                                               is_an_eta_expansion env vars
                                                 body3
                                                in
                                             match uu____8843 with
                                             | FStar_Pervasives_Native.Some
                                                 t2 ->
                                                 ((let uu____8852 =
                                                     FStar_All.pipe_left
                                                       (FStar_TypeChecker_Env.debug
                                                          env.FStar_SMTEncoding_Env.tcenv)
                                                       (FStar_Options.Other
                                                          "PartialApp")
                                                      in
                                                   if uu____8852
                                                   then
                                                     let uu____8857 =
                                                       FStar_SMTEncoding_Term.print_smt_term
                                                         t2
                                                        in
                                                     FStar_Util.print1
                                                       "Yes, is an eta expansion of\n\tcore=%s\n"
                                                       uu____8857
                                                   else ());
                                                  (let decls1 =
                                                     FStar_List.append decls
                                                       (FStar_List.append
                                                          decls' decls'')
                                                      in
                                                   (t2, decls1)))
                                             | FStar_Pervasives_Native.None 
                                                 ->
                                                 let cvar_sorts =
                                                   FStar_List.map
                                                     FStar_SMTEncoding_Term.fv_sort
                                                     cvars1
                                                    in
                                                 let fsym =
                                                   let uu____8870 =
                                                     FStar_Util.digest_of_string
                                                       tkey_hash
                                                      in
                                                   Prims.op_Hat "Tm_abs_"
                                                     uu____8870
                                                    in
                                                 let fdecl =
                                                   FStar_SMTEncoding_Term.DeclFun
                                                     (fsym, cvar_sorts,
                                                       FStar_SMTEncoding_Term.Term_sort,
                                                       FStar_Pervasives_Native.None)
                                                    in
                                                 let f =
                                                   let uu____8879 =
                                                     let uu____8887 =
                                                       FStar_List.map
                                                         FStar_SMTEncoding_Util.mkFreeV
                                                         cvars1
                                                        in
                                                     (fsym, uu____8887)  in
                                                   FStar_SMTEncoding_Util.mkApp
                                                     uu____8879
                                                    in
                                                 let app = mk_Apply f vars
                                                    in
                                                 let typing_f =
                                                   match arrow_t_opt with
                                                   | FStar_Pervasives_Native.None
                                                        ->
                                                       let tot_fun_ax =
                                                         let ax =
                                                           let uu____8901 =
                                                             FStar_All.pipe_right
                                                               vars
                                                               (FStar_List.map
                                                                  (fun
                                                                    uu____8909
                                                                     ->
                                                                    FStar_SMTEncoding_Util.mkTrue))
                                                              in
                                                           isTotFun_axioms
                                                             t0.FStar_Syntax_Syntax.pos
                                                             f vars
                                                             uu____8901
                                                             is_pure
                                                            in
                                                         match cvars1 with
                                                         | [] -> ax
                                                         | uu____8910 ->
                                                             FStar_SMTEncoding_Term.mkForall
                                                               t0.FStar_Syntax_Syntax.pos
                                                               ([[f]],
                                                                 cvars1, ax)
                                                          in
                                                       let a_name =
                                                         Prims.op_Hat
                                                           "tot_fun_" fsym
                                                          in
                                                       let uu____8924 =
                                                         FStar_SMTEncoding_Util.mkAssume
                                                           (tot_fun_ax,
                                                             (FStar_Pervasives_Native.Some
                                                                a_name),
                                                             a_name)
                                                          in
                                                       [uu____8924]
                                                   | FStar_Pervasives_Native.Some
                                                       t2 ->
                                                       let f_has_t =
                                                         FStar_SMTEncoding_Term.mk_HasTypeWithFuel
                                                           FStar_Pervasives_Native.None
                                                           f t2
                                                          in
                                                       let a_name =
                                                         Prims.op_Hat
                                                           "typing_" fsym
                                                          in
                                                       let uu____8932 =
                                                         let uu____8933 =
                                                           let uu____8941 =
                                                             FStar_SMTEncoding_Term.mkForall
                                                               t0.FStar_Syntax_Syntax.pos
                                                               ([[f]],
                                                                 cvars1,
                                                                 f_has_t)
                                                              in
                                                           (uu____8941,
                                                             (FStar_Pervasives_Native.Some
                                                                a_name),
                                                             a_name)
                                                            in
                                                         FStar_SMTEncoding_Util.mkAssume
                                                           uu____8933
                                                          in
                                                       [uu____8932]
                                                    in
                                                 let interp_f =
                                                   let a_name =
                                                     Prims.op_Hat
                                                       "interpretation_" fsym
                                                      in
                                                   let uu____8956 =
                                                     let uu____8964 =
                                                       let uu____8965 =
                                                         let uu____8976 =
                                                           FStar_SMTEncoding_Util.mkEq
                                                             (app, body3)
                                                            in
                                                         ([[app]],
                                                           (FStar_List.append
                                                              vars cvars1),
                                                           uu____8976)
                                                          in
                                                       FStar_SMTEncoding_Term.mkForall
                                                         t0.FStar_Syntax_Syntax.pos
                                                         uu____8965
                                                        in
                                                     (uu____8964,
                                                       (FStar_Pervasives_Native.Some
                                                          a_name), a_name)
                                                      in
                                                   FStar_SMTEncoding_Util.mkAssume
                                                     uu____8956
                                                    in
                                                 let f_decls =
                                                   FStar_List.append (fdecl
                                                     :: typing_f) [interp_f]
                                                    in
                                                 let uu____8990 =
                                                   let uu____8991 =
                                                     let uu____8994 =
                                                       let uu____8997 =
                                                         FStar_SMTEncoding_Term.mk_decls
                                                           fsym tkey_hash
                                                           f_decls
                                                           (FStar_List.append
                                                              decls
                                                              (FStar_List.append
                                                                 decls'
                                                                 decls''))
                                                          in
                                                       FStar_List.append
                                                         decls'' uu____8997
                                                        in
                                                     FStar_List.append decls'
                                                       uu____8994
                                                      in
                                                   FStar_List.append decls
                                                     uu____8991
                                                    in
                                                 (f, uu____8990)))))))))
       | FStar_Syntax_Syntax.Tm_let
           ((uu____9000,{
                          FStar_Syntax_Syntax.lbname = FStar_Util.Inr
                            uu____9001;
                          FStar_Syntax_Syntax.lbunivs = uu____9002;
                          FStar_Syntax_Syntax.lbtyp = uu____9003;
                          FStar_Syntax_Syntax.lbeff = uu____9004;
                          FStar_Syntax_Syntax.lbdef = uu____9005;
                          FStar_Syntax_Syntax.lbattrs = uu____9006;
                          FStar_Syntax_Syntax.lbpos = uu____9007;_}::uu____9008),uu____9009)
           -> failwith "Impossible: already handled by encoding of Sig_let"
       | FStar_Syntax_Syntax.Tm_let
           ((false
             ,{ FStar_Syntax_Syntax.lbname = FStar_Util.Inl x;
                FStar_Syntax_Syntax.lbunivs = uu____9043;
                FStar_Syntax_Syntax.lbtyp = t11;
                FStar_Syntax_Syntax.lbeff = uu____9045;
                FStar_Syntax_Syntax.lbdef = e1;
                FStar_Syntax_Syntax.lbattrs = uu____9047;
                FStar_Syntax_Syntax.lbpos = uu____9048;_}::[]),e2)
           -> encode_let x t11 e1 e2 env encode_term
       | FStar_Syntax_Syntax.Tm_let
           ((false ,uu____9075::uu____9076),uu____9077) ->
           failwith "Impossible: non-recursive let with multiple bindings"
       | FStar_Syntax_Syntax.Tm_let ((uu____9100,lbs),uu____9102) ->
           let names =
             FStar_All.pipe_right lbs
               (FStar_List.map
                  (fun lb  ->
                     let uu____9155 = lb  in
                     match uu____9155 with
                     | { FStar_Syntax_Syntax.lbname = lbname;
                         FStar_Syntax_Syntax.lbunivs = uu____9162;
                         FStar_Syntax_Syntax.lbtyp = uu____9163;
                         FStar_Syntax_Syntax.lbeff = uu____9164;
                         FStar_Syntax_Syntax.lbdef = uu____9165;
                         FStar_Syntax_Syntax.lbattrs = uu____9166;
                         FStar_Syntax_Syntax.lbpos = uu____9167;_} ->
                         let x = FStar_Util.left lbname  in
                         let uu____9183 =
                           FStar_Ident.text_of_id
                             x.FStar_Syntax_Syntax.ppname
                            in
                         let uu____9185 = FStar_Syntax_Syntax.range_of_bv x
                            in
                         (uu____9183, uu____9185)))
              in
           FStar_Exn.raise (FStar_SMTEncoding_Env.Inner_let_rec names)
       | FStar_Syntax_Syntax.Tm_match (e,pats) ->
           encode_match e pats FStar_SMTEncoding_Term.mk_Term_unit env
             encode_term)

and (encode_let :
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.typ ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          FStar_SMTEncoding_Env.env_t ->
            (FStar_Syntax_Syntax.term ->
               FStar_SMTEncoding_Env.env_t ->
                 (FStar_SMTEncoding_Term.term *
                   FStar_SMTEncoding_Term.decls_t))
              ->
              (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun x  ->
    fun t1  ->
      fun e1  ->
        fun e2  ->
          fun env  ->
            fun encode_body  ->
              let uu____9243 =
                let uu____9248 =
                  FStar_Syntax_Util.ascribe e1
                    ((FStar_Util.Inl t1), FStar_Pervasives_Native.None)
                   in
                encode_term uu____9248 env  in
              match uu____9243 with
              | (ee1,decls1) ->
                  let uu____9273 =
                    FStar_Syntax_Subst.open_term
                      [(x, FStar_Pervasives_Native.None)] e2
                     in
                  (match uu____9273 with
                   | (xs,e21) ->
                       let uu____9298 = FStar_List.hd xs  in
                       (match uu____9298 with
                        | (x1,uu____9316) ->
                            let env' =
                              FStar_SMTEncoding_Env.push_term_var env x1 ee1
                               in
                            let uu____9322 = encode_body e21 env'  in
                            (match uu____9322 with
                             | (ee2,decls2) ->
                                 (ee2, (FStar_List.append decls1 decls2)))))

and (encode_match :
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.branch Prims.list ->
      FStar_SMTEncoding_Term.term ->
        FStar_SMTEncoding_Env.env_t ->
          (FStar_Syntax_Syntax.term ->
             FStar_SMTEncoding_Env.env_t ->
               (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
            -> (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun e  ->
    fun pats  ->
      fun default_case  ->
        fun env  ->
          fun encode_br  ->
            let uu____9352 =
              let uu____9360 =
                let uu____9361 =
                  FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown
                    FStar_Pervasives_Native.None FStar_Range.dummyRange
                   in
                FStar_Syntax_Syntax.null_bv uu____9361  in
              FStar_SMTEncoding_Env.gen_term_var env uu____9360  in
            match uu____9352 with
            | (scrsym,scr',env1) ->
                let uu____9371 = encode_term e env1  in
                (match uu____9371 with
                 | (scr,decls) ->
                     let uu____9382 =
                       let encode_branch b uu____9411 =
                         match uu____9411 with
                         | (else_case,decls1) ->
                             let uu____9430 =
                               FStar_Syntax_Subst.open_branch b  in
                             (match uu____9430 with
                              | (p,w,br) ->
                                  let uu____9456 = encode_pat env1 p  in
                                  (match uu____9456 with
                                   | (env0,pattern1) ->
                                       let guard = pattern1.guard scr'  in
                                       let projections =
                                         pattern1.projections scr'  in
                                       let env2 =
                                         FStar_All.pipe_right projections
                                           (FStar_List.fold_left
                                              (fun env2  ->
                                                 fun uu____9493  ->
                                                   match uu____9493 with
                                                   | (x,t) ->
                                                       FStar_SMTEncoding_Env.push_term_var
                                                         env2 x t) env1)
                                          in
                                       let uu____9500 =
                                         match w with
                                         | FStar_Pervasives_Native.None  ->
                                             (guard, [])
                                         | FStar_Pervasives_Native.Some w1 ->
                                             let uu____9522 =
                                               encode_term w1 env2  in
                                             (match uu____9522 with
                                              | (w2,decls2) ->
                                                  let uu____9535 =
                                                    let uu____9536 =
                                                      let uu____9541 =
                                                        let uu____9542 =
                                                          let uu____9547 =
                                                            FStar_SMTEncoding_Term.boxBool
                                                              FStar_SMTEncoding_Util.mkTrue
                                                             in
                                                          (w2, uu____9547)
                                                           in
                                                        FStar_SMTEncoding_Util.mkEq
                                                          uu____9542
                                                         in
                                                      (guard, uu____9541)  in
                                                    FStar_SMTEncoding_Util.mkAnd
                                                      uu____9536
                                                     in
                                                  (uu____9535, decls2))
                                          in
                                       (match uu____9500 with
                                        | (guard1,decls2) ->
                                            let uu____9562 =
                                              encode_br br env2  in
                                            (match uu____9562 with
                                             | (br1,decls3) ->
                                                 let uu____9575 =
                                                   FStar_SMTEncoding_Util.mkITE
                                                     (guard1, br1, else_case)
                                                    in
                                                 (uu____9575,
                                                   (FStar_List.append decls1
                                                      (FStar_List.append
                                                         decls2 decls3)))))))
                          in
                       FStar_List.fold_right encode_branch pats
                         (default_case, decls)
                        in
                     (match uu____9382 with
                      | (match_tm,decls1) ->
                          let uu____9596 =
                            let uu____9597 =
                              let uu____9608 =
                                let uu____9615 =
                                  let uu____9620 =
                                    FStar_SMTEncoding_Term.mk_fv
                                      (scrsym,
                                        FStar_SMTEncoding_Term.Term_sort)
                                     in
                                  (uu____9620, scr)  in
                                [uu____9615]  in
                              (uu____9608, match_tm)  in
                            FStar_SMTEncoding_Term.mkLet' uu____9597
                              FStar_Range.dummyRange
                             in
                          (uu____9596, decls1)))

and (encode_pat :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.pat -> (FStar_SMTEncoding_Env.env_t * pattern))
  =
  fun env  ->
    fun pat  ->
      (let uu____9643 =
         FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv
           FStar_Options.Medium
          in
       if uu____9643
       then
         let uu____9646 = FStar_Syntax_Print.pat_to_string pat  in
         FStar_Util.print1 "Encoding pattern %s\n" uu____9646
       else ());
      (let uu____9651 = FStar_TypeChecker_Util.decorated_pattern_as_term pat
          in
       match uu____9651 with
       | (vars,pat_term) ->
           let uu____9668 =
             FStar_All.pipe_right vars
               (FStar_List.fold_left
                  (fun uu____9710  ->
                     fun v  ->
                       match uu____9710 with
                       | (env1,vars1) ->
                           let uu____9746 =
                             FStar_SMTEncoding_Env.gen_term_var env1 v  in
                           (match uu____9746 with
                            | (xx,uu____9765,env2) ->
                                let uu____9769 =
                                  let uu____9776 =
                                    let uu____9781 =
                                      FStar_SMTEncoding_Term.mk_fv
                                        (xx,
                                          FStar_SMTEncoding_Term.Term_sort)
                                       in
                                    (v, uu____9781)  in
                                  uu____9776 :: vars1  in
                                (env2, uu____9769))) (env, []))
              in
           (match uu____9668 with
            | (env1,vars1) ->
                let rec mk_guard pat1 scrutinee =
                  match pat1.FStar_Syntax_Syntax.v with
                  | FStar_Syntax_Syntax.Pat_var uu____9836 ->
                      FStar_SMTEncoding_Util.mkTrue
                  | FStar_Syntax_Syntax.Pat_wild uu____9837 ->
                      FStar_SMTEncoding_Util.mkTrue
                  | FStar_Syntax_Syntax.Pat_dot_term uu____9838 ->
                      FStar_SMTEncoding_Util.mkTrue
                  | FStar_Syntax_Syntax.Pat_constant c ->
                      let uu____9846 = encode_const c env1  in
                      (match uu____9846 with
                       | (tm,decls) ->
                           ((match decls with
                             | uu____9854::uu____9855 ->
                                 failwith
                                   "Unexpected encoding of constant pattern"
                             | uu____9859 -> ());
                            FStar_SMTEncoding_Util.mkEq (scrutinee, tm)))
                  | FStar_Syntax_Syntax.Pat_cons (f,args) ->
                      let is_f =
                        let tc_name =
                          FStar_TypeChecker_Env.typ_of_datacon
                            env1.FStar_SMTEncoding_Env.tcenv
                            (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                           in
                        let uu____9882 =
                          FStar_TypeChecker_Env.datacons_of_typ
                            env1.FStar_SMTEncoding_Env.tcenv tc_name
                           in
                        match uu____9882 with
                        | (uu____9890,uu____9891::[]) ->
                            FStar_SMTEncoding_Util.mkTrue
                        | uu____9896 ->
                            FStar_SMTEncoding_Env.mk_data_tester env1
                              (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                              scrutinee
                         in
                      let sub_term_guards =
                        FStar_All.pipe_right args
                          (FStar_List.mapi
                             (fun i  ->
                                fun uu____9932  ->
                                  match uu____9932 with
                                  | (arg,uu____9942) ->
                                      let proj =
                                        FStar_SMTEncoding_Env.primitive_projector_by_pos
                                          env1.FStar_SMTEncoding_Env.tcenv
                                          (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                          i
                                         in
                                      let uu____9951 =
                                        FStar_SMTEncoding_Util.mkApp
                                          (proj, [scrutinee])
                                         in
                                      mk_guard arg uu____9951))
                         in
                      FStar_SMTEncoding_Util.mk_and_l (is_f ::
                        sub_term_guards)
                   in
                let rec mk_projections pat1 scrutinee =
                  match pat1.FStar_Syntax_Syntax.v with
                  | FStar_Syntax_Syntax.Pat_dot_term (x,uu____9983) ->
                      [(x, scrutinee)]
                  | FStar_Syntax_Syntax.Pat_var x -> [(x, scrutinee)]
                  | FStar_Syntax_Syntax.Pat_wild x -> [(x, scrutinee)]
                  | FStar_Syntax_Syntax.Pat_constant uu____10014 -> []
                  | FStar_Syntax_Syntax.Pat_cons (f,args) ->
                      let uu____10039 =
                        FStar_All.pipe_right args
                          (FStar_List.mapi
                             (fun i  ->
                                fun uu____10085  ->
                                  match uu____10085 with
                                  | (arg,uu____10101) ->
                                      let proj =
                                        FStar_SMTEncoding_Env.primitive_projector_by_pos
                                          env1.FStar_SMTEncoding_Env.tcenv
                                          (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                          i
                                         in
                                      let uu____10110 =
                                        FStar_SMTEncoding_Util.mkApp
                                          (proj, [scrutinee])
                                         in
                                      mk_projections arg uu____10110))
                         in
                      FStar_All.pipe_right uu____10039 FStar_List.flatten
                   in
                let pat_term1 uu____10141 = encode_term pat_term env1  in
                let pattern1 =
                  {
                    pat_vars = vars1;
                    pat_term = pat_term1;
                    guard = (mk_guard pat);
                    projections = (mk_projections pat)
                  }  in
                (env1, pattern1)))

and (encode_args :
  FStar_Syntax_Syntax.args ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term Prims.list *
        FStar_SMTEncoding_Term.decls_t))
  =
  fun l  ->
    fun env  ->
      let uu____10151 =
        FStar_All.pipe_right l
          (FStar_List.fold_left
             (fun uu____10199  ->
                fun uu____10200  ->
                  match (uu____10199, uu____10200) with
                  | ((tms,decls),(t,uu____10240)) ->
                      let uu____10267 = encode_term t env  in
                      (match uu____10267 with
                       | (t1,decls') ->
                           ((t1 :: tms), (FStar_List.append decls decls'))))
             ([], []))
         in
      match uu____10151 with | (l1,decls) -> ((FStar_List.rev l1), decls)

and (encode_function_type_as_formula :
  FStar_Syntax_Syntax.typ ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun t  ->
    fun env  ->
      let universe_of_binders binders =
        FStar_List.map (fun uu____10345  -> FStar_Syntax_Syntax.U_zero)
          binders
         in
      let quant = FStar_Syntax_Util.smt_lemma_as_forall t universe_of_binders
         in
      let env1 =
        let uu___1417_10354 = env  in
        {
          FStar_SMTEncoding_Env.bvar_bindings =
            (uu___1417_10354.FStar_SMTEncoding_Env.bvar_bindings);
          FStar_SMTEncoding_Env.fvar_bindings =
            (uu___1417_10354.FStar_SMTEncoding_Env.fvar_bindings);
          FStar_SMTEncoding_Env.depth =
            (uu___1417_10354.FStar_SMTEncoding_Env.depth);
          FStar_SMTEncoding_Env.tcenv =
            (uu___1417_10354.FStar_SMTEncoding_Env.tcenv);
          FStar_SMTEncoding_Env.warn =
            (uu___1417_10354.FStar_SMTEncoding_Env.warn);
          FStar_SMTEncoding_Env.nolabels =
            (uu___1417_10354.FStar_SMTEncoding_Env.nolabels);
          FStar_SMTEncoding_Env.use_zfuel_name = true;
          FStar_SMTEncoding_Env.encode_non_total_function_typ =
            (uu___1417_10354.FStar_SMTEncoding_Env.encode_non_total_function_typ);
          FStar_SMTEncoding_Env.current_module_name =
            (uu___1417_10354.FStar_SMTEncoding_Env.current_module_name);
          FStar_SMTEncoding_Env.encoding_quantifier =
            (uu___1417_10354.FStar_SMTEncoding_Env.encoding_quantifier);
          FStar_SMTEncoding_Env.global_cache =
            (uu___1417_10354.FStar_SMTEncoding_Env.global_cache)
        }  in
      encode_formula quant env1

and (encode_smt_patterns :
  FStar_Syntax_Syntax.arg Prims.list Prims.list ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term Prims.list Prims.list *
        FStar_SMTEncoding_Term.decls_t))
  =
  fun pats_l  ->
    fun env  ->
      let env1 =
        let uu___1422_10371 = env  in
        {
          FStar_SMTEncoding_Env.bvar_bindings =
            (uu___1422_10371.FStar_SMTEncoding_Env.bvar_bindings);
          FStar_SMTEncoding_Env.fvar_bindings =
            (uu___1422_10371.FStar_SMTEncoding_Env.fvar_bindings);
          FStar_SMTEncoding_Env.depth =
            (uu___1422_10371.FStar_SMTEncoding_Env.depth);
          FStar_SMTEncoding_Env.tcenv =
            (uu___1422_10371.FStar_SMTEncoding_Env.tcenv);
          FStar_SMTEncoding_Env.warn =
            (uu___1422_10371.FStar_SMTEncoding_Env.warn);
          FStar_SMTEncoding_Env.nolabels =
            (uu___1422_10371.FStar_SMTEncoding_Env.nolabels);
          FStar_SMTEncoding_Env.use_zfuel_name = true;
          FStar_SMTEncoding_Env.encode_non_total_function_typ =
            (uu___1422_10371.FStar_SMTEncoding_Env.encode_non_total_function_typ);
          FStar_SMTEncoding_Env.current_module_name =
            (uu___1422_10371.FStar_SMTEncoding_Env.current_module_name);
          FStar_SMTEncoding_Env.encoding_quantifier =
            (uu___1422_10371.FStar_SMTEncoding_Env.encoding_quantifier);
          FStar_SMTEncoding_Env.global_cache =
            (uu___1422_10371.FStar_SMTEncoding_Env.global_cache)
        }  in
      let encode_smt_pattern t =
        let uu____10387 = FStar_Syntax_Util.head_and_args t  in
        match uu____10387 with
        | (head,args) ->
            let head1 = FStar_Syntax_Util.un_uinst head  in
            (match ((head1.FStar_Syntax_Syntax.n), args) with
             | (FStar_Syntax_Syntax.Tm_fvar
                fv,uu____10450::(x,uu____10452)::(t1,uu____10454)::[]) when
                 FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.has_type_lid
                 ->
                 let uu____10521 = encode_term x env1  in
                 (match uu____10521 with
                  | (x1,decls) ->
                      let uu____10532 = encode_term t1 env1  in
                      (match uu____10532 with
                       | (t2,decls') ->
                           let uu____10543 =
                             FStar_SMTEncoding_Term.mk_HasType x1 t2  in
                           (uu____10543, (FStar_List.append decls decls'))))
             | uu____10544 -> encode_term t env1)
         in
      FStar_List.fold_right
        (fun pats  ->
           fun uu____10587  ->
             match uu____10587 with
             | (pats_l1,decls) ->
                 let uu____10632 =
                   FStar_List.fold_right
                     (fun uu____10667  ->
                        fun uu____10668  ->
                          match (uu____10667, uu____10668) with
                          | ((p,uu____10710),(pats1,decls1)) ->
                              let uu____10745 = encode_smt_pattern p  in
                              (match uu____10745 with
                               | (t,d) ->
                                   let uu____10760 =
                                     FStar_SMTEncoding_Term.check_pattern_ok
                                       t
                                      in
                                   (match uu____10760 with
                                    | FStar_Pervasives_Native.None  ->
                                        ((t :: pats1),
                                          (FStar_List.append d decls1))
                                    | FStar_Pervasives_Native.Some
                                        illegal_subterm ->
                                        ((let uu____10777 =
                                            let uu____10783 =
                                              let uu____10785 =
                                                FStar_Syntax_Print.term_to_string
                                                  p
                                                 in
                                              let uu____10787 =
                                                FStar_SMTEncoding_Term.print_smt_term
                                                  illegal_subterm
                                                 in
                                              FStar_Util.format2
                                                "Pattern %s contains illegal sub-term (%s); dropping it"
                                                uu____10785 uu____10787
                                               in
                                            (FStar_Errors.Warning_SMTPatternIllFormed,
                                              uu____10783)
                                             in
                                          FStar_Errors.log_issue
                                            p.FStar_Syntax_Syntax.pos
                                            uu____10777);
                                         (pats1,
                                           (FStar_List.append d decls1))))))
                     pats ([], decls)
                    in
                 (match uu____10632 with
                  | (pats1,decls1) -> ((pats1 :: pats_l1), decls1))) pats_l
        ([], [])

and (encode_formula :
  FStar_Syntax_Syntax.typ ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun phi  ->
    fun env  ->
      let debug phi1 =
        let uu____10847 =
          FStar_All.pipe_left
            (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
            (FStar_Options.Other "SMTEncoding")
           in
        if uu____10847
        then
          let uu____10852 = FStar_Syntax_Print.tag_of_term phi1  in
          let uu____10854 = FStar_Syntax_Print.term_to_string phi1  in
          FStar_Util.print2 "Formula (%s)  %s\n" uu____10852 uu____10854
        else ()  in
      let enc f r l =
        let uu____10896 =
          FStar_Util.fold_map
            (fun decls  ->
               fun x  ->
                 let uu____10928 =
                   encode_term (FStar_Pervasives_Native.fst x) env  in
                 match uu____10928 with
                 | (t,decls') -> ((FStar_List.append decls decls'), t)) [] l
           in
        match uu____10896 with
        | (decls,args) ->
            let uu____10959 =
              let uu___1486_10960 = f args  in
              {
                FStar_SMTEncoding_Term.tm =
                  (uu___1486_10960.FStar_SMTEncoding_Term.tm);
                FStar_SMTEncoding_Term.freevars =
                  (uu___1486_10960.FStar_SMTEncoding_Term.freevars);
                FStar_SMTEncoding_Term.rng = r
              }  in
            (uu____10959, decls)
         in
      let const_op f r uu____10995 =
        let uu____11008 = f r  in (uu____11008, [])  in
      let un_op f l =
        let uu____11031 = FStar_List.hd l  in
        FStar_All.pipe_left f uu____11031  in
      let bin_op f uu___2_11051 =
        match uu___2_11051 with
        | t1::t2::[] -> f (t1, t2)
        | uu____11062 -> failwith "Impossible"  in
      let enc_prop_c f r l =
        let uu____11103 =
          FStar_Util.fold_map
            (fun decls  ->
               fun uu____11128  ->
                 match uu____11128 with
                 | (t,uu____11144) ->
                     let uu____11149 = encode_formula t env  in
                     (match uu____11149 with
                      | (phi1,decls') ->
                          ((FStar_List.append decls decls'), phi1))) [] l
           in
        match uu____11103 with
        | (decls,phis) ->
            let uu____11178 =
              let uu___1516_11179 = f phis  in
              {
                FStar_SMTEncoding_Term.tm =
                  (uu___1516_11179.FStar_SMTEncoding_Term.tm);
                FStar_SMTEncoding_Term.freevars =
                  (uu___1516_11179.FStar_SMTEncoding_Term.freevars);
                FStar_SMTEncoding_Term.rng = r
              }  in
            (uu____11178, decls)
         in
      let eq_op r args =
        let rf =
          FStar_List.filter
            (fun uu____11242  ->
               match uu____11242 with
               | (a,q) ->
                   (match q with
                    | FStar_Pervasives_Native.Some
                        (FStar_Syntax_Syntax.Implicit uu____11263) -> false
                    | uu____11266 -> true)) args
           in
        if (FStar_List.length rf) <> (Prims.of_int (2))
        then
          let uu____11285 =
            FStar_Util.format1
              "eq_op: got %s non-implicit arguments instead of 2?"
              (Prims.string_of_int (FStar_List.length rf))
             in
          failwith uu____11285
        else
          (let uu____11302 = enc (bin_op FStar_SMTEncoding_Util.mkEq)  in
           uu____11302 r rf)
         in
      let eq3_op r args =
        let n = FStar_List.length args  in
        if n = (Prims.of_int (4))
        then
          let uu____11370 =
            enc
              (fun terms  ->
                 match terms with
                 | t0::t1::v0::v1::[] ->
                     let uu____11402 =
                       let uu____11407 = FStar_SMTEncoding_Util.mkEq (t0, t1)
                          in
                       let uu____11408 = FStar_SMTEncoding_Util.mkEq (v0, v1)
                          in
                       (uu____11407, uu____11408)  in
                     FStar_SMTEncoding_Util.mkAnd uu____11402
                 | uu____11409 -> failwith "Impossible")
             in
          uu____11370 r args
        else
          (let uu____11415 =
             FStar_Util.format1
               "eq3_op: got %s non-implicit arguments instead of 4?"
               (Prims.string_of_int n)
              in
           failwith uu____11415)
         in
      let h_equals_op r args =
        let n = FStar_List.length args  in
        if n = (Prims.of_int (4))
        then
          let uu____11477 =
            enc
              (fun terms  ->
                 match terms with
                 | t0::v0::t1::v1::[] ->
                     let uu____11509 =
                       let uu____11514 = FStar_SMTEncoding_Util.mkEq (t0, t1)
                          in
                       let uu____11515 = FStar_SMTEncoding_Util.mkEq (v0, v1)
                          in
                       (uu____11514, uu____11515)  in
                     FStar_SMTEncoding_Util.mkAnd uu____11509
                 | uu____11516 -> failwith "Impossible")
             in
          uu____11477 r args
        else
          (let uu____11522 =
             FStar_Util.format1
               "eq3_op: got %s non-implicit arguments instead of 4?"
               (Prims.string_of_int n)
              in
           failwith uu____11522)
         in
      let mk_imp r uu___3_11551 =
        match uu___3_11551 with
        | (lhs,uu____11557)::(rhs,uu____11559)::[] ->
            let uu____11600 = encode_formula rhs env  in
            (match uu____11600 with
             | (l1,decls1) ->
                 (match l1.FStar_SMTEncoding_Term.tm with
                  | FStar_SMTEncoding_Term.App
                      (FStar_SMTEncoding_Term.TrueOp ,uu____11615) ->
                      (l1, decls1)
                  | uu____11620 ->
                      let uu____11621 = encode_formula lhs env  in
                      (match uu____11621 with
                       | (l2,decls2) ->
                           let uu____11632 =
                             FStar_SMTEncoding_Term.mkImp (l2, l1) r  in
                           (uu____11632, (FStar_List.append decls1 decls2)))))
        | uu____11633 -> failwith "impossible"  in
      let mk_ite r uu___4_11661 =
        match uu___4_11661 with
        | (guard,uu____11667)::(_then,uu____11669)::(_else,uu____11671)::[]
            ->
            let uu____11728 = encode_formula guard env  in
            (match uu____11728 with
             | (g,decls1) ->
                 let uu____11739 = encode_formula _then env  in
                 (match uu____11739 with
                  | (t,decls2) ->
                      let uu____11750 = encode_formula _else env  in
                      (match uu____11750 with
                       | (e,decls3) ->
                           let res = FStar_SMTEncoding_Term.mkITE (g, t, e) r
                              in
                           (res,
                             (FStar_List.append decls1
                                (FStar_List.append decls2 decls3))))))
        | uu____11762 -> failwith "impossible"  in
      let unboxInt_l f l =
        let uu____11792 = FStar_List.map FStar_SMTEncoding_Term.unboxInt l
           in
        f uu____11792  in
      let connectives =
        let uu____11822 =
          let uu____11847 = enc_prop_c (bin_op FStar_SMTEncoding_Util.mkAnd)
             in
          (FStar_Parser_Const.and_lid, uu____11847)  in
        let uu____11890 =
          let uu____11917 =
            let uu____11942 = enc_prop_c (bin_op FStar_SMTEncoding_Util.mkOr)
               in
            (FStar_Parser_Const.or_lid, uu____11942)  in
          let uu____11985 =
            let uu____12012 =
              let uu____12039 =
                let uu____12064 =
                  enc_prop_c (bin_op FStar_SMTEncoding_Util.mkIff)  in
                (FStar_Parser_Const.iff_lid, uu____12064)  in
              let uu____12107 =
                let uu____12134 =
                  let uu____12161 =
                    let uu____12186 =
                      enc_prop_c (un_op FStar_SMTEncoding_Util.mkNot)  in
                    (FStar_Parser_Const.not_lid, uu____12186)  in
                  [uu____12161;
                  (FStar_Parser_Const.eq2_lid, eq_op);
                  (FStar_Parser_Const.c_eq2_lid, eq_op);
                  (FStar_Parser_Const.eq3_lid, eq3_op);
                  (FStar_Parser_Const.c_eq3_lid, h_equals_op);
                  (FStar_Parser_Const.true_lid,
                    (const_op FStar_SMTEncoding_Term.mkTrue));
                  (FStar_Parser_Const.false_lid,
                    (const_op FStar_SMTEncoding_Term.mkFalse))]
                   in
                (FStar_Parser_Const.ite_lid, mk_ite) :: uu____12134  in
              uu____12039 :: uu____12107  in
            (FStar_Parser_Const.imp_lid, mk_imp) :: uu____12012  in
          uu____11917 :: uu____11985  in
        uu____11822 :: uu____11890  in
      let rec fallback phi1 =
        match phi1.FStar_Syntax_Syntax.n with
        | FStar_Syntax_Syntax.Tm_meta
            (phi',FStar_Syntax_Syntax.Meta_labeled (msg,r,b)) ->
            let uu____12731 = encode_formula phi' env  in
            (match uu____12731 with
             | (phi2,decls) ->
                 let uu____12742 =
                   FStar_SMTEncoding_Term.mk
                     (FStar_SMTEncoding_Term.Labeled (phi2, msg, r)) r
                    in
                 (uu____12742, decls))
        | FStar_Syntax_Syntax.Tm_meta uu____12744 ->
            let uu____12751 = FStar_Syntax_Util.unmeta phi1  in
            encode_formula uu____12751 env
        | FStar_Syntax_Syntax.Tm_match (e,pats) ->
            let uu____12790 =
              encode_match e pats FStar_SMTEncoding_Util.mkFalse env
                encode_formula
               in
            (match uu____12790 with | (t,decls) -> (t, decls))
        | FStar_Syntax_Syntax.Tm_let
            ((false
              ,{ FStar_Syntax_Syntax.lbname = FStar_Util.Inl x;
                 FStar_Syntax_Syntax.lbunivs = uu____12802;
                 FStar_Syntax_Syntax.lbtyp = t1;
                 FStar_Syntax_Syntax.lbeff = uu____12804;
                 FStar_Syntax_Syntax.lbdef = e1;
                 FStar_Syntax_Syntax.lbattrs = uu____12806;
                 FStar_Syntax_Syntax.lbpos = uu____12807;_}::[]),e2)
            ->
            let uu____12834 = encode_let x t1 e1 e2 env encode_formula  in
            (match uu____12834 with | (t,decls) -> (t, decls))
        | FStar_Syntax_Syntax.Tm_app (head,args) ->
            let head1 = FStar_Syntax_Util.un_uinst head  in
            (match ((head1.FStar_Syntax_Syntax.n), args) with
             | (FStar_Syntax_Syntax.Tm_fvar
                fv,uu____12887::(x,uu____12889)::(t,uu____12891)::[]) when
                 FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.has_type_lid
                 ->
                 let uu____12958 = encode_term x env  in
                 (match uu____12958 with
                  | (x1,decls) ->
                      let uu____12969 = encode_term t env  in
                      (match uu____12969 with
                       | (t1,decls') ->
                           let uu____12980 =
                             FStar_SMTEncoding_Term.mk_HasType x1 t1  in
                           (uu____12980, (FStar_List.append decls decls'))))
             | (FStar_Syntax_Syntax.Tm_fvar
                fv,(r,uu____12983)::(msg,uu____12985)::(phi2,uu____12987)::[])
                 when
                 FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.labeled_lid
                 ->
                 let uu____13054 =
                   let uu____13059 =
                     let uu____13060 = FStar_Syntax_Subst.compress r  in
                     uu____13060.FStar_Syntax_Syntax.n  in
                   let uu____13063 =
                     let uu____13064 = FStar_Syntax_Subst.compress msg  in
                     uu____13064.FStar_Syntax_Syntax.n  in
                   (uu____13059, uu____13063)  in
                 (match uu____13054 with
                  | (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_range
                     r1),FStar_Syntax_Syntax.Tm_constant
                     (FStar_Const.Const_string (s,uu____13073))) ->
                      let phi3 =
                        FStar_Syntax_Syntax.mk
                          (FStar_Syntax_Syntax.Tm_meta
                             (phi2,
                               (FStar_Syntax_Syntax.Meta_labeled
                                  (s, r1, false))))
                          FStar_Pervasives_Native.None r1
                         in
                      fallback phi3
                  | uu____13084 -> fallback phi2)
             | (FStar_Syntax_Syntax.Tm_fvar fv,(t,uu____13091)::[]) when
                 (FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.squash_lid)
                   ||
                   (FStar_Syntax_Syntax.fv_eq_lid fv
                      FStar_Parser_Const.auto_squash_lid)
                 -> encode_formula t env
             | uu____13126 ->
                 let encode_valid uu____13150 =
                   let uu____13151 = encode_term phi1 env  in
                   match uu____13151 with
                   | (tt,decls) ->
                       let tt1 =
                         let uu____13163 =
                           let uu____13165 =
                             FStar_Range.use_range
                               tt.FStar_SMTEncoding_Term.rng
                              in
                           let uu____13166 =
                             FStar_Range.use_range
                               phi1.FStar_Syntax_Syntax.pos
                              in
                           FStar_Range.rng_included uu____13165 uu____13166
                            in
                         if uu____13163
                         then tt
                         else
                           (let uu___1704_13170 = tt  in
                            {
                              FStar_SMTEncoding_Term.tm =
                                (uu___1704_13170.FStar_SMTEncoding_Term.tm);
                              FStar_SMTEncoding_Term.freevars =
                                (uu___1704_13170.FStar_SMTEncoding_Term.freevars);
                              FStar_SMTEncoding_Term.rng =
                                (phi1.FStar_Syntax_Syntax.pos)
                            })
                          in
                       let uu____13171 = FStar_SMTEncoding_Term.mk_Valid tt1
                          in
                       (uu____13171, decls)
                    in
                 let uu____13172 = head_redex env head1  in
                 if uu____13172
                 then
                   let uu____13179 = maybe_whnf env head1  in
                   (match uu____13179 with
                    | FStar_Pervasives_Native.None  -> encode_valid ()
                    | FStar_Pervasives_Native.Some phi2 ->
                        encode_formula phi2 env)
                 else encode_valid ())
        | uu____13189 ->
            let uu____13190 = encode_term phi1 env  in
            (match uu____13190 with
             | (tt,decls) ->
                 let tt1 =
                   let uu____13202 =
                     let uu____13204 =
                       FStar_Range.use_range tt.FStar_SMTEncoding_Term.rng
                        in
                     let uu____13205 =
                       FStar_Range.use_range phi1.FStar_Syntax_Syntax.pos  in
                     FStar_Range.rng_included uu____13204 uu____13205  in
                   if uu____13202
                   then tt
                   else
                     (let uu___1716_13209 = tt  in
                      {
                        FStar_SMTEncoding_Term.tm =
                          (uu___1716_13209.FStar_SMTEncoding_Term.tm);
                        FStar_SMTEncoding_Term.freevars =
                          (uu___1716_13209.FStar_SMTEncoding_Term.freevars);
                        FStar_SMTEncoding_Term.rng =
                          (phi1.FStar_Syntax_Syntax.pos)
                      })
                    in
                 let uu____13210 = FStar_SMTEncoding_Term.mk_Valid tt1  in
                 (uu____13210, decls))
         in
      let encode_q_body env1 bs ps body =
        let uu____13254 = encode_binders FStar_Pervasives_Native.None bs env1
           in
        match uu____13254 with
        | (vars,guards,env2,decls,uu____13293) ->
            let uu____13306 = encode_smt_patterns ps env2  in
            (match uu____13306 with
             | (pats,decls') ->
                 let uu____13343 = encode_formula body env2  in
                 (match uu____13343 with
                  | (body1,decls'') ->
                      let guards1 =
                        match pats with
                        | ({
                             FStar_SMTEncoding_Term.tm =
                               FStar_SMTEncoding_Term.App
                               (FStar_SMTEncoding_Term.Var gf,p::[]);
                             FStar_SMTEncoding_Term.freevars = uu____13375;
                             FStar_SMTEncoding_Term.rng = uu____13376;_}::[])::[]
                            when
                            let uu____13396 =
                              FStar_Ident.text_of_lid
                                FStar_Parser_Const.guard_free
                               in
                            uu____13396 = gf -> []
                        | uu____13399 -> guards  in
                      let uu____13404 =
                        FStar_SMTEncoding_Util.mk_and_l guards1  in
                      (vars, pats, uu____13404, body1,
                        (FStar_List.append decls
                           (FStar_List.append decls' decls'')))))
         in
      debug phi;
      (let phi1 = FStar_Syntax_Util.unascribe phi  in
       let uu____13415 = FStar_Syntax_Util.destruct_typ_as_formula phi1  in
       match uu____13415 with
       | FStar_Pervasives_Native.None  -> fallback phi1
       | FStar_Pervasives_Native.Some (FStar_Syntax_Util.BaseConn (op,arms))
           ->
           let uu____13424 =
             FStar_All.pipe_right connectives
               (FStar_List.tryFind
                  (fun uu____13530  ->
                     match uu____13530 with
                     | (l,uu____13555) -> FStar_Ident.lid_equals op l))
              in
           (match uu____13424 with
            | FStar_Pervasives_Native.None  -> fallback phi1
            | FStar_Pervasives_Native.Some (uu____13624,f) ->
                f phi1.FStar_Syntax_Syntax.pos arms)
       | FStar_Pervasives_Native.Some (FStar_Syntax_Util.QAll
           (vars,pats,body)) ->
           (FStar_All.pipe_right pats
              (FStar_List.iter (check_pattern_vars env vars));
            (let uu____13716 = encode_q_body env vars pats body  in
             match uu____13716 with
             | (vars1,pats1,guard,body1,decls) ->
                 let tm =
                   let uu____13761 =
                     let uu____13772 =
                       FStar_SMTEncoding_Util.mkImp (guard, body1)  in
                     (pats1, vars1, uu____13772)  in
                   FStar_SMTEncoding_Term.mkForall
                     phi1.FStar_Syntax_Syntax.pos uu____13761
                    in
                 (tm, decls)))
       | FStar_Pervasives_Native.Some (FStar_Syntax_Util.QEx
           (vars,pats,body)) ->
           (FStar_All.pipe_right pats
              (FStar_List.iter (check_pattern_vars env vars));
            (let uu____13803 = encode_q_body env vars pats body  in
             match uu____13803 with
             | (vars1,pats1,guard,body1,decls) ->
                 let uu____13847 =
                   let uu____13848 =
                     let uu____13859 =
                       FStar_SMTEncoding_Util.mkAnd (guard, body1)  in
                     (pats1, vars1, uu____13859)  in
                   FStar_SMTEncoding_Term.mkExists
                     phi1.FStar_Syntax_Syntax.pos uu____13848
                    in
                 (uu____13847, decls))))
