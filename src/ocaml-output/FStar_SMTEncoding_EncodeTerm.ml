open Prims
let mkForall_fuel' :
  'Auu____14 .
    Prims.string ->
      FStar_Range.range ->
        'Auu____14 ->
          (FStar_SMTEncoding_Term.pat Prims.list Prims.list *
            FStar_SMTEncoding_Term.fvs * FStar_SMTEncoding_Term.term) ->
            FStar_SMTEncoding_Term.term
  =
  fun mname  ->
    fun r  ->
      fun n1  ->
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
                     let add_fuel1 tms =
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
                     let pats1 = FStar_List.map add_fuel1 pats  in
                     let body1 =
                       match body.FStar_SMTEncoding_Term.tm with
                       | FStar_SMTEncoding_Term.App
                           (FStar_SMTEncoding_Term.Imp ,guard::body'::[]) ->
                           let guard1 =
                             match guard.FStar_SMTEncoding_Term.tm with
                             | FStar_SMTEncoding_Term.App
                                 (FStar_SMTEncoding_Term.And ,guards) ->
                                 let uu____144 = add_fuel1 guards  in
                                 FStar_SMTEncoding_Util.mk_and_l uu____144
                             | uu____147 ->
                                 let uu____148 = add_fuel1 [guard]  in
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
  = fun mname  -> fun r  -> mkForall_fuel' mname r (Prims.parse_int "1") 
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
  
let (whnf :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun t  ->
      let uu____438 = head_normal env t  in
      if uu____438
      then t
      else
        FStar_TypeChecker_Normalize.normalize
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
      FStar_TypeChecker_Normalize.normalize
        [FStar_TypeChecker_Env.Beta;
        FStar_TypeChecker_Env.Exclude FStar_TypeChecker_Env.Zeta;
        FStar_TypeChecker_Env.Eager_unfolding;
        FStar_TypeChecker_Env.EraseUniverses] env.FStar_SMTEncoding_Env.tcenv
        t
  
let (trivial_post : FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) =
  fun t  ->
    let uu____460 =
      let uu____461 = FStar_Syntax_Syntax.null_binder t  in [uu____461]  in
    let uu____480 =
      FStar_Syntax_Syntax.fvar FStar_Parser_Const.true_lid
        FStar_Syntax_Syntax.delta_constant FStar_Pervasives_Native.None
       in
    FStar_Syntax_Util.abs uu____460 uu____480 FStar_Pervasives_Native.None
  
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
                let uu____502 = FStar_SMTEncoding_Term.fv_sort var  in
                match uu____502 with
                | FStar_SMTEncoding_Term.Fuel_sort  ->
                    let uu____503 = FStar_SMTEncoding_Util.mkFreeV var  in
                    FStar_SMTEncoding_Term.mk_ApplyTF out uu____503
                | s ->
                    let uu____506 = FStar_SMTEncoding_Util.mkFreeV var  in
                    FStar_SMTEncoding_Util.mk_ApplyTT out uu____506) e)
  
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
  fun head1  ->
    fun arity  ->
      fun n_args  ->
        fun rng  ->
          let uu____562 =
            let uu____568 =
              let uu____570 = FStar_Util.string_of_int arity  in
              let uu____572 = FStar_Util.string_of_int n_args  in
              FStar_Util.format3
                "Head symbol %s expects at least %s arguments; got only %s"
                head1 uu____570 uu____572
               in
            (FStar_Errors.Fatal_SMTEncodingArityMismatch, uu____568)  in
          FStar_Errors.raise_error uu____562 rng
  
let (maybe_curry_app :
  FStar_Range.range ->
    (FStar_SMTEncoding_Term.op,FStar_SMTEncoding_Term.term) FStar_Util.either
      ->
      Prims.int ->
        FStar_SMTEncoding_Term.term Prims.list -> FStar_SMTEncoding_Term.term)
  =
  fun rng  ->
    fun head1  ->
      fun arity  ->
        fun args  ->
          let n_args = FStar_List.length args  in
          match head1 with
          | FStar_Util.Inr head2 -> mk_Apply_args head2 args
          | FStar_Util.Inl head2 ->
              if n_args = arity
              then FStar_SMTEncoding_Util.mkApp' (head2, args)
              else
                if n_args > arity
                then
                  (let uu____621 = FStar_Util.first_N arity args  in
                   match uu____621 with
                   | (args1,rest) ->
                       let head3 =
                         FStar_SMTEncoding_Util.mkApp' (head2, args1)  in
                       mk_Apply_args head3 rest)
                else
                  (let uu____645 = FStar_SMTEncoding_Term.op_to_string head2
                      in
                   raise_arity_mismatch uu____645 arity n_args rng)
  
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
          let uu____668 = FStar_SMTEncoding_Env.force_thunk fvb  in
          mk_Apply_args uu____668 args
        else
          maybe_curry_app rng
            (FStar_Util.Inl
               (FStar_SMTEncoding_Term.Var (fvb.FStar_SMTEncoding_Env.smt_id)))
            fvb.FStar_SMTEncoding_Env.smt_arity args
  
let (is_app : FStar_SMTEncoding_Term.op -> Prims.bool) =
  fun uu___1_677  ->
    match uu___1_677 with
    | FStar_SMTEncoding_Term.Var "ApplyTT" -> true
    | FStar_SMTEncoding_Term.Var "ApplyTF" -> true
    | uu____683 -> false
  
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
                       FStar_SMTEncoding_Term.freevars = uu____731;
                       FStar_SMTEncoding_Term.rng = uu____732;_}::[]),x::xs1)
              when (is_app app) && (FStar_SMTEncoding_Term.fv_eq x y) ->
              check_partial_applications f xs1
          | (FStar_SMTEncoding_Term.App
             (FStar_SMTEncoding_Term.Var f,args),uu____763) ->
              let uu____773 =
                ((FStar_List.length args) = (FStar_List.length xs)) &&
                  (FStar_List.forall2
                     (fun a  ->
                        fun v1  ->
                          match a.FStar_SMTEncoding_Term.tm with
                          | FStar_SMTEncoding_Term.FreeV fv ->
                              FStar_SMTEncoding_Term.fv_eq fv v1
                          | uu____790 -> false) args (FStar_List.rev xs))
                 in
              if uu____773
              then
                let n1 = FStar_SMTEncoding_Env.tok_of_name env f  in
                ((let uu____799 =
                    FStar_All.pipe_left
                      (FStar_TypeChecker_Env.debug
                         env.FStar_SMTEncoding_Env.tcenv)
                      (FStar_Options.Other "PartialApp")
                     in
                  if uu____799
                  then
                    let uu____804 = FStar_SMTEncoding_Term.print_smt_term t
                       in
                    let uu____806 =
                      match n1 with
                      | FStar_Pervasives_Native.None  -> "None"
                      | FStar_Pervasives_Native.Some x ->
                          FStar_SMTEncoding_Term.print_smt_term x
                       in
                    FStar_Util.print2
                      "is_eta_expansion %s  ... tok_of_name = %s\n" uu____804
                      uu____806
                  else ());
                 n1)
              else FStar_Pervasives_Native.None
          | (uu____816,[]) ->
              let fvs = FStar_SMTEncoding_Term.free_variables t  in
              let uu____820 =
                FStar_All.pipe_right fvs
                  (FStar_List.for_all
                     (fun fv  ->
                        let uu____828 =
                          FStar_Util.for_some
                            (FStar_SMTEncoding_Term.fv_eq fv) vars
                           in
                        Prims.op_Negation uu____828))
                 in
              if uu____820
              then FStar_Pervasives_Native.Some t
              else FStar_Pervasives_Native.None
          | uu____835 -> FStar_Pervasives_Native.None  in
        check_partial_applications body (FStar_List.rev vars)
  
let check_pattern_vars :
  'Auu____853 'Auu____854 .
    FStar_SMTEncoding_Env.env_t ->
      (FStar_Syntax_Syntax.bv * 'Auu____853) Prims.list ->
        (FStar_Syntax_Syntax.term * 'Auu____854) Prims.list -> unit
  =
  fun env  ->
    fun vars  ->
      fun pats  ->
        let pats1 =
          FStar_All.pipe_right pats
            (FStar_List.map
               (fun uu____912  ->
                  match uu____912 with
                  | (x,uu____918) ->
                      FStar_TypeChecker_Normalize.normalize
                        [FStar_TypeChecker_Env.Beta;
                        FStar_TypeChecker_Env.AllowUnboundUniverses;
                        FStar_TypeChecker_Env.EraseUniverses]
                        env.FStar_SMTEncoding_Env.tcenv x))
           in
        match pats1 with
        | [] -> ()
        | hd1::tl1 ->
            let pat_vars =
              let uu____926 = FStar_Syntax_Free.names hd1  in
              FStar_List.fold_left
                (fun out  ->
                   fun x  ->
                     let uu____938 = FStar_Syntax_Free.names x  in
                     FStar_Util.set_union out uu____938) uu____926 tl1
               in
            let uu____941 =
              FStar_All.pipe_right vars
                (FStar_Util.find_opt
                   (fun uu____968  ->
                      match uu____968 with
                      | (b,uu____975) ->
                          let uu____976 = FStar_Util.set_mem b pat_vars  in
                          Prims.op_Negation uu____976))
               in
            (match uu____941 with
             | FStar_Pervasives_Native.None  -> ()
             | FStar_Pervasives_Native.Some (x,uu____983) ->
                 let pos =
                   FStar_List.fold_left
                     (fun out  ->
                        fun t  ->
                          FStar_Range.union_ranges out
                            t.FStar_Syntax_Syntax.pos)
                     hd1.FStar_Syntax_Syntax.pos tl1
                    in
                 let uu____997 =
                   let uu____1003 =
                     let uu____1005 = FStar_Syntax_Print.bv_to_string x  in
                     FStar_Util.format1
                       "SMT pattern misses at least one bound variable: %s"
                       uu____1005
                      in
                   (FStar_Errors.Warning_SMTPatternIllFormed, uu____1003)  in
                 FStar_Errors.log_issue pos uu____997)
  
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
        | FStar_Syntax_Syntax.Tm_arrow uu____1291 -> t1
        | FStar_Syntax_Syntax.Tm_refine uu____1306 ->
            let uu____1313 = FStar_Syntax_Util.unrefine t1  in
            aux true uu____1313
        | uu____1315 ->
            if norm1
            then let uu____1317 = whnf env t1  in aux false uu____1317
            else
              (let uu____1321 =
                 let uu____1323 =
                   FStar_Range.string_of_range t0.FStar_Syntax_Syntax.pos  in
                 let uu____1325 = FStar_Syntax_Print.term_to_string t0  in
                 FStar_Util.format2 "(%s) Expected a function typ; got %s"
                   uu____1323 uu____1325
                  in
               failwith uu____1321)
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
    | FStar_Syntax_Syntax.Tm_refine (bv,uu____1367) ->
        let uu____1372 =
          curried_arrow_formals_comp bv.FStar_Syntax_Syntax.sort  in
        (match uu____1372 with
         | (args,res) ->
             (match args with
              | [] ->
                  let uu____1393 = FStar_Syntax_Syntax.mk_Total k1  in
                  ([], uu____1393)
              | uu____1400 -> (args, res)))
    | uu____1401 ->
        let uu____1402 = FStar_Syntax_Syntax.mk_Total k1  in ([], uu____1402)
  
let is_arithmetic_primitive :
  'Auu____1416 .
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      'Auu____1416 Prims.list -> Prims.bool
  =
  fun head1  ->
    fun args  ->
      match ((head1.FStar_Syntax_Syntax.n), args) with
      | (FStar_Syntax_Syntax.Tm_fvar fv,uu____1439::uu____1440::[]) ->
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
      | (FStar_Syntax_Syntax.Tm_fvar fv,uu____1444::[]) ->
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.op_Minus
      | uu____1447 -> false
  
let (isInteger : FStar_Syntax_Syntax.term' -> Prims.bool) =
  fun tm  ->
    match tm with
    | FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_int
        (n1,FStar_Pervasives_Native.None )) -> true
    | uu____1478 -> false
  
let (getInteger : FStar_Syntax_Syntax.term' -> Prims.int) =
  fun tm  ->
    match tm with
    | FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_int
        (n1,FStar_Pervasives_Native.None )) -> FStar_Util.int_of_string n1
    | uu____1501 -> failwith "Expected an Integer term"
  
let is_BitVector_primitive :
  'Auu____1511 .
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax * 'Auu____1511)
        Prims.list -> Prims.bool
  =
  fun head1  ->
    fun args  ->
      match ((head1.FStar_Syntax_Syntax.n), args) with
      | (FStar_Syntax_Syntax.Tm_fvar
         fv,(sz_arg,uu____1553)::uu____1554::uu____1555::[]) ->
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
      | (FStar_Syntax_Syntax.Tm_fvar fv,(sz_arg,uu____1606)::uu____1607::[])
          ->
          ((FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.nat_to_bv_lid)
             ||
             (FStar_Syntax_Syntax.fv_eq_lid fv
                FStar_Parser_Const.bv_to_nat_lid))
            && (isInteger sz_arg.FStar_Syntax_Syntax.n)
      | uu____1644 -> false
  
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
          let uu____1968 =
            FStar_SMTEncoding_Term.boxBool FStar_SMTEncoding_Util.mkTrue  in
          (uu____1968, [])
      | FStar_Const.Const_bool (false ) ->
          let uu____1970 =
            FStar_SMTEncoding_Term.boxBool FStar_SMTEncoding_Util.mkFalse  in
          (uu____1970, [])
      | FStar_Const.Const_char c1 ->
          let uu____1973 =
            let uu____1974 =
              let uu____1982 =
                let uu____1985 =
                  let uu____1986 =
                    FStar_SMTEncoding_Util.mkInteger'
                      (FStar_Util.int_of_char c1)
                     in
                  FStar_SMTEncoding_Term.boxInt uu____1986  in
                [uu____1985]  in
              ("FStar.Char.__char_of_int", uu____1982)  in
            FStar_SMTEncoding_Util.mkApp uu____1974  in
          (uu____1973, [])
      | FStar_Const.Const_int (i,FStar_Pervasives_Native.None ) ->
          let uu____2004 =
            let uu____2005 = FStar_SMTEncoding_Util.mkInteger i  in
            FStar_SMTEncoding_Term.boxInt uu____2005  in
          (uu____2004, [])
      | FStar_Const.Const_int (repr,FStar_Pervasives_Native.Some sw) ->
          let syntax_term =
            FStar_ToSyntax_ToSyntax.desugar_machine_integer
              (env.FStar_SMTEncoding_Env.tcenv).FStar_TypeChecker_Env.dsenv
              repr sw FStar_Range.dummyRange
             in
          encode_term syntax_term env
      | FStar_Const.Const_string (s,uu____2026) ->
          let uu____2029 =
            FStar_SMTEncoding_Env.varops.FStar_SMTEncoding_Env.string_const s
             in
          (uu____2029, [])
      | FStar_Const.Const_range uu____2030 ->
          let uu____2031 = FStar_SMTEncoding_Term.mk_Range_const ()  in
          (uu____2031, [])
      | FStar_Const.Const_effect  ->
          (FStar_SMTEncoding_Term.mk_Term_type, [])
      | FStar_Const.Const_real r ->
          let uu____2034 =
            let uu____2035 = FStar_SMTEncoding_Util.mkReal r  in
            FStar_SMTEncoding_Term.boxReal uu____2035  in
          (uu____2034, [])
      | c1 ->
          let uu____2037 =
            let uu____2039 = FStar_Syntax_Print.const_to_string c1  in
            FStar_Util.format1 "Unhandled constant: %s" uu____2039  in
          failwith uu____2037

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
        (let uu____2068 =
           FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv
             FStar_Options.Medium
            in
         if uu____2068
         then
           let uu____2071 = FStar_Syntax_Print.binders_to_string ", " bs  in
           FStar_Util.print1 "Encoding binders %s\n" uu____2071
         else ());
        (let uu____2077 =
           FStar_All.pipe_right bs
             (FStar_List.fold_left
                (fun uu____2159  ->
                   fun b  ->
                     match uu____2159 with
                     | (vars,guards,env1,decls,names1) ->
                         let uu____2224 =
                           let x = FStar_Pervasives_Native.fst b  in
                           let uu____2240 =
                             FStar_SMTEncoding_Env.gen_term_var env1 x  in
                           match uu____2240 with
                           | (xxsym,xx,env') ->
                               let uu____2265 =
                                 let uu____2270 =
                                   norm env1 x.FStar_Syntax_Syntax.sort  in
                                 encode_term_pred fuel_opt uu____2270 env1 xx
                                  in
                               (match uu____2265 with
                                | (guard_x_t,decls') ->
                                    let uu____2285 =
                                      FStar_SMTEncoding_Term.mk_fv
                                        (xxsym,
                                          FStar_SMTEncoding_Term.Term_sort)
                                       in
                                    (uu____2285, guard_x_t, env', decls', x))
                            in
                         (match uu____2224 with
                          | (v1,g,env2,decls',n1) ->
                              ((v1 :: vars), (g :: guards), env2,
                                (FStar_List.append decls decls'), (n1 ::
                                names1)))) ([], [], env, [], []))
            in
         match uu____2077 with
         | (vars,guards,env1,decls,names1) ->
             ((FStar_List.rev vars), (FStar_List.rev guards), env1, decls,
               (FStar_List.rev names1)))

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
          let uu____2385 = encode_term t env  in
          match uu____2385 with
          | (t1,decls) ->
              let uu____2396 =
                FStar_SMTEncoding_Term.mk_HasTypeWithFuel fuel_opt e t1  in
              (uu____2396, decls)

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
          let uu____2407 = encode_term t env  in
          match uu____2407 with
          | (t1,decls) ->
              (match fuel_opt with
               | FStar_Pervasives_Native.None  ->
                   let uu____2422 = FStar_SMTEncoding_Term.mk_HasTypeZ e t1
                      in
                   (uu____2422, decls)
               | FStar_Pervasives_Native.Some f ->
                   let uu____2424 =
                     FStar_SMTEncoding_Term.mk_HasTypeFuel f e t1  in
                   (uu____2424, decls))

and (encode_arith_term :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.args ->
        (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun env  ->
    fun head1  ->
      fun args_e  ->
        let uu____2430 = encode_args args_e env  in
        match uu____2430 with
        | (arg_tms,decls) ->
            let head_fv =
              match head1.FStar_Syntax_Syntax.n with
              | FStar_Syntax_Syntax.Tm_fvar fv -> fv
              | uu____2449 -> failwith "Impossible"  in
            let unary unbox arg_tms1 =
              let uu____2471 = FStar_List.hd arg_tms1  in unbox uu____2471
               in
            let binary unbox arg_tms1 =
              let uu____2496 =
                let uu____2497 = FStar_List.hd arg_tms1  in unbox uu____2497
                 in
              let uu____2498 =
                let uu____2499 =
                  let uu____2500 = FStar_List.tl arg_tms1  in
                  FStar_List.hd uu____2500  in
                unbox uu____2499  in
              (uu____2496, uu____2498)  in
            let mk_default uu____2508 =
              let uu____2509 =
                FStar_SMTEncoding_Env.lookup_free_var_sym env
                  head_fv.FStar_Syntax_Syntax.fv_name
                 in
              match uu____2509 with
              | (fname,fuel_args,arity) ->
                  let args = FStar_List.append fuel_args arg_tms  in
                  maybe_curry_app head1.FStar_Syntax_Syntax.pos fname arity
                    args
               in
            let mk_l box op mk_args ts =
              let uu____2598 = FStar_Options.smtencoding_l_arith_native ()
                 in
              if uu____2598
              then
                let uu____2601 =
                  let uu____2602 = mk_args ts  in op uu____2602  in
                FStar_All.pipe_right uu____2601 box
              else mk_default ()  in
            let mk_nl box unbox nm op ts =
              let uu____2660 = FStar_Options.smtencoding_nl_arith_wrapped ()
                 in
              if uu____2660
              then
                let uu____2663 = binary unbox ts  in
                match uu____2663 with
                | (t1,t2) ->
                    let uu____2670 =
                      FStar_SMTEncoding_Util.mkApp (nm, [t1; t2])  in
                    FStar_All.pipe_right uu____2670 box
              else
                (let uu____2676 =
                   FStar_Options.smtencoding_nl_arith_native ()  in
                 if uu____2676
                 then
                   let uu____2679 =
                     let uu____2680 = binary unbox ts  in op uu____2680  in
                   FStar_All.pipe_right uu____2679 box
                 else mk_default ())
               in
            let add1 box unbox =
              mk_l box FStar_SMTEncoding_Util.mkAdd (binary unbox)  in
            let sub1 box unbox =
              mk_l box FStar_SMTEncoding_Util.mkSub (binary unbox)  in
            let minus1 box unbox =
              mk_l box FStar_SMTEncoding_Util.mkMinus (unary unbox)  in
            let mul1 box unbox nm =
              mk_nl box unbox nm FStar_SMTEncoding_Util.mkMul  in
            let div1 box unbox nm =
              mk_nl box unbox nm FStar_SMTEncoding_Util.mkDiv  in
            let modulus box unbox =
              mk_nl box unbox "_mod" FStar_SMTEncoding_Util.mkMod  in
            let ops =
              [(FStar_Parser_Const.op_Addition,
                 (add1 FStar_SMTEncoding_Term.boxInt
                    FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.op_Subtraction,
                (sub1 FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.op_Multiply,
                (mul1 FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt "_mul"));
              (FStar_Parser_Const.op_Division,
                (div1 FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt "_div"));
              (FStar_Parser_Const.op_Modulus,
                (modulus FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.op_Minus,
                (minus1 FStar_SMTEncoding_Term.boxInt
                   FStar_SMTEncoding_Term.unboxInt));
              (FStar_Parser_Const.real_op_Addition,
                (add1 FStar_SMTEncoding_Term.boxReal
                   FStar_SMTEncoding_Term.unboxReal));
              (FStar_Parser_Const.real_op_Subtraction,
                (sub1 FStar_SMTEncoding_Term.boxReal
                   FStar_SMTEncoding_Term.unboxReal));
              (FStar_Parser_Const.real_op_Multiply,
                (mul1 FStar_SMTEncoding_Term.boxReal
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
            let uu____3115 =
              let uu____3125 =
                FStar_List.tryFind
                  (fun uu____3149  ->
                     match uu____3149 with
                     | (l,uu____3160) ->
                         FStar_Syntax_Syntax.fv_eq_lid head_fv l) ops
                 in
              FStar_All.pipe_right uu____3125 FStar_Util.must  in
            (match uu____3115 with
             | (uu____3204,op) ->
                 let uu____3216 = op arg_tms  in (uu____3216, decls))

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
    fun head1  ->
      fun args_e  ->
        let uu____3232 = FStar_List.hd args_e  in
        match uu____3232 with
        | (tm_sz,uu____3248) ->
            let uu____3257 = uu____3232  in
            let sz = getInteger tm_sz.FStar_Syntax_Syntax.n  in
            let sz_key =
              FStar_Util.format1 "BitVector_%s" (Prims.string_of_int sz)  in
            let sz_decls =
              let t_decls1 = FStar_SMTEncoding_Term.mkBvConstructor sz  in
              FStar_SMTEncoding_Term.mk_decls "" sz_key t_decls1 []  in
            let uu____3268 =
              match ((head1.FStar_Syntax_Syntax.n), args_e) with
              | (FStar_Syntax_Syntax.Tm_fvar
                 fv,uu____3294::(sz_arg,uu____3296)::uu____3297::[]) when
                  (FStar_Syntax_Syntax.fv_eq_lid fv
                     FStar_Parser_Const.bv_uext_lid)
                    && (isInteger sz_arg.FStar_Syntax_Syntax.n)
                  ->
                  let uu____3364 =
                    let uu____3365 = FStar_List.tail args_e  in
                    FStar_List.tail uu____3365  in
                  let uu____3392 =
                    let uu____3396 = getInteger sz_arg.FStar_Syntax_Syntax.n
                       in
                    FStar_Pervasives_Native.Some uu____3396  in
                  (uu____3364, uu____3392)
              | (FStar_Syntax_Syntax.Tm_fvar
                 fv,uu____3403::(sz_arg,uu____3405)::uu____3406::[]) when
                  FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.bv_uext_lid
                  ->
                  let uu____3473 =
                    let uu____3475 = FStar_Syntax_Print.term_to_string sz_arg
                       in
                    FStar_Util.format1
                      "Not a constant bitvector extend size: %s" uu____3475
                     in
                  failwith uu____3473
              | uu____3485 ->
                  let uu____3500 = FStar_List.tail args_e  in
                  (uu____3500, FStar_Pervasives_Native.None)
               in
            (match uu____3268 with
             | (arg_tms,ext_sz) ->
                 let uu____3527 = encode_args arg_tms env  in
                 (match uu____3527 with
                  | (arg_tms1,decls) ->
                      let head_fv =
                        match head1.FStar_Syntax_Syntax.n with
                        | FStar_Syntax_Syntax.Tm_fvar fv -> fv
                        | uu____3548 -> failwith "Impossible"  in
                      let unary arg_tms2 =
                        let uu____3560 = FStar_List.hd arg_tms2  in
                        FStar_SMTEncoding_Term.unboxBitVec sz uu____3560  in
                      let unary_arith arg_tms2 =
                        let uu____3571 = FStar_List.hd arg_tms2  in
                        FStar_SMTEncoding_Term.unboxInt uu____3571  in
                      let binary arg_tms2 =
                        let uu____3586 =
                          let uu____3587 = FStar_List.hd arg_tms2  in
                          FStar_SMTEncoding_Term.unboxBitVec sz uu____3587
                           in
                        let uu____3588 =
                          let uu____3589 =
                            let uu____3590 = FStar_List.tl arg_tms2  in
                            FStar_List.hd uu____3590  in
                          FStar_SMTEncoding_Term.unboxBitVec sz uu____3589
                           in
                        (uu____3586, uu____3588)  in
                      let binary_arith arg_tms2 =
                        let uu____3607 =
                          let uu____3608 = FStar_List.hd arg_tms2  in
                          FStar_SMTEncoding_Term.unboxBitVec sz uu____3608
                           in
                        let uu____3609 =
                          let uu____3610 =
                            let uu____3611 = FStar_List.tl arg_tms2  in
                            FStar_List.hd uu____3611  in
                          FStar_SMTEncoding_Term.unboxInt uu____3610  in
                        (uu____3607, uu____3609)  in
                      let mk_bv op mk_args resBox ts =
                        let uu____3669 =
                          let uu____3670 = mk_args ts  in op uu____3670  in
                        FStar_All.pipe_right uu____3669 resBox  in
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
                        let uu____3802 =
                          let uu____3807 =
                            match ext_sz with
                            | FStar_Pervasives_Native.Some x -> x
                            | FStar_Pervasives_Native.None  ->
                                failwith "impossible"
                             in
                          FStar_SMTEncoding_Util.mkBvUext uu____3807  in
                        let uu____3816 =
                          let uu____3821 =
                            let uu____3823 =
                              match ext_sz with
                              | FStar_Pervasives_Native.Some x -> x
                              | FStar_Pervasives_Native.None  ->
                                  failwith "impossible"
                               in
                            sz + uu____3823  in
                          FStar_SMTEncoding_Term.boxBitVec uu____3821  in
                        mk_bv uu____3802 unary uu____3816 arg_tms2  in
                      let to_int1 =
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
                        (FStar_Parser_Const.bv_to_nat_lid, to_int1);
                        (FStar_Parser_Const.nat_to_bv_lid, bv_to)]  in
                      let uu____4063 =
                        let uu____4073 =
                          FStar_List.tryFind
                            (fun uu____4097  ->
                               match uu____4097 with
                               | (l,uu____4108) ->
                                   FStar_Syntax_Syntax.fv_eq_lid head_fv l)
                            ops
                           in
                        FStar_All.pipe_right uu____4073 FStar_Util.must  in
                      (match uu____4063 with
                       | (uu____4154,op) ->
                           let uu____4166 = op arg_tms1  in
                           (uu____4166, (FStar_List.append sz_decls decls)))))

and (encode_deeply_embedded_quantifier :
  FStar_Syntax_Syntax.term ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun t  ->
    fun env  ->
      let env1 =
        let uu___546_4176 = env  in
        {
          FStar_SMTEncoding_Env.bvar_bindings =
            (uu___546_4176.FStar_SMTEncoding_Env.bvar_bindings);
          FStar_SMTEncoding_Env.fvar_bindings =
            (uu___546_4176.FStar_SMTEncoding_Env.fvar_bindings);
          FStar_SMTEncoding_Env.depth =
            (uu___546_4176.FStar_SMTEncoding_Env.depth);
          FStar_SMTEncoding_Env.tcenv =
            (uu___546_4176.FStar_SMTEncoding_Env.tcenv);
          FStar_SMTEncoding_Env.warn =
            (uu___546_4176.FStar_SMTEncoding_Env.warn);
          FStar_SMTEncoding_Env.nolabels =
            (uu___546_4176.FStar_SMTEncoding_Env.nolabels);
          FStar_SMTEncoding_Env.use_zfuel_name =
            (uu___546_4176.FStar_SMTEncoding_Env.use_zfuel_name);
          FStar_SMTEncoding_Env.encode_non_total_function_typ =
            (uu___546_4176.FStar_SMTEncoding_Env.encode_non_total_function_typ);
          FStar_SMTEncoding_Env.current_module_name =
            (uu___546_4176.FStar_SMTEncoding_Env.current_module_name);
          FStar_SMTEncoding_Env.encoding_quantifier = true;
          FStar_SMTEncoding_Env.global_cache =
            (uu___546_4176.FStar_SMTEncoding_Env.global_cache)
        }  in
      let uu____4178 = encode_term t env1  in
      match uu____4178 with
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
               (uu____4204,{
                             FStar_SMTEncoding_Term.tm =
                               FStar_SMTEncoding_Term.FreeV uu____4205;
                             FStar_SMTEncoding_Term.freevars = uu____4206;
                             FStar_SMTEncoding_Term.rng = uu____4207;_}::
                {
                  FStar_SMTEncoding_Term.tm = FStar_SMTEncoding_Term.FreeV
                    uu____4208;
                  FStar_SMTEncoding_Term.freevars = uu____4209;
                  FStar_SMTEncoding_Term.rng = uu____4210;_}::[])
               ->
               (FStar_Errors.log_issue t.FStar_Syntax_Syntax.pos
                  (FStar_Errors.Warning_QuantifierWithoutPattern,
                    "Not encoding deeply embedded, unguarded quantifier to SMT");
                (tm, decls))
           | uu____4256 ->
               let uu____4257 = encode_formula t env1  in
               (match uu____4257 with
                | (phi,decls') ->
                    let interp =
                      match vars with
                      | [] ->
                          let uu____4277 =
                            let uu____4282 =
                              FStar_SMTEncoding_Term.mk_Valid tm  in
                            (uu____4282, phi)  in
                          FStar_SMTEncoding_Util.mkIff uu____4277
                      | uu____4283 ->
                          let uu____4284 =
                            let uu____4295 =
                              let uu____4296 =
                                let uu____4301 =
                                  FStar_SMTEncoding_Term.mk_Valid tm  in
                                (uu____4301, phi)  in
                              FStar_SMTEncoding_Util.mkIff uu____4296  in
                            ([[valid_tm]], vars, uu____4295)  in
                          FStar_SMTEncoding_Term.mkForall
                            t.FStar_Syntax_Syntax.pos uu____4284
                       in
                    let ax =
                      let uu____4311 =
                        let uu____4319 =
                          let uu____4321 =
                            FStar_Util.digest_of_string tkey_hash  in
                          Prims.op_Hat "l_quant_interp_" uu____4321  in
                        (interp,
                          (FStar_Pervasives_Native.Some
                             "Interpretation of deeply embedded quantifier"),
                          uu____4319)
                         in
                      FStar_SMTEncoding_Util.mkAssume uu____4311  in
                    let uu____4327 =
                      let uu____4328 =
                        let uu____4331 =
                          FStar_SMTEncoding_Term.mk_decls "" tkey_hash 
                            [ax] (FStar_List.append decls decls')
                           in
                        FStar_List.append decls' uu____4331  in
                      FStar_List.append decls uu____4328  in
                    (tm, uu____4327)))

and (encode_term :
  FStar_Syntax_Syntax.typ ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun t  ->
    fun env  ->
      let t0 = FStar_Syntax_Subst.compress t  in
      (let uu____4343 =
         FStar_All.pipe_left
           (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
           (FStar_Options.Other "SMTEncoding")
          in
       if uu____4343
       then
         let uu____4348 = FStar_Syntax_Print.tag_of_term t  in
         let uu____4350 = FStar_Syntax_Print.tag_of_term t0  in
         let uu____4352 = FStar_Syntax_Print.term_to_string t0  in
         FStar_Util.print3 "(%s) (%s)   %s\n" uu____4348 uu____4350
           uu____4352
       else ());
      (match t0.FStar_Syntax_Syntax.n with
       | FStar_Syntax_Syntax.Tm_delayed uu____4361 ->
           let uu____4384 =
             let uu____4386 =
               FStar_All.pipe_left FStar_Range.string_of_range
                 t.FStar_Syntax_Syntax.pos
                in
             let uu____4389 = FStar_Syntax_Print.tag_of_term t0  in
             let uu____4391 = FStar_Syntax_Print.term_to_string t0  in
             let uu____4393 = FStar_Syntax_Print.term_to_string t  in
             FStar_Util.format4 "(%s) Impossible: %s\n%s\n%s\n" uu____4386
               uu____4389 uu____4391 uu____4393
              in
           failwith uu____4384
       | FStar_Syntax_Syntax.Tm_unknown  ->
           let uu____4400 =
             let uu____4402 =
               FStar_All.pipe_left FStar_Range.string_of_range
                 t.FStar_Syntax_Syntax.pos
                in
             let uu____4405 = FStar_Syntax_Print.tag_of_term t0  in
             let uu____4407 = FStar_Syntax_Print.term_to_string t0  in
             let uu____4409 = FStar_Syntax_Print.term_to_string t  in
             FStar_Util.format4 "(%s) Impossible: %s\n%s\n%s\n" uu____4402
               uu____4405 uu____4407 uu____4409
              in
           failwith uu____4400
       | FStar_Syntax_Syntax.Tm_lazy i ->
           let e = FStar_Syntax_Util.unfold_lazy i  in
           ((let uu____4419 =
               FStar_All.pipe_left
                 (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
                 (FStar_Options.Other "SMTEncoding")
                in
             if uu____4419
             then
               let uu____4424 = FStar_Syntax_Print.term_to_string t0  in
               let uu____4426 = FStar_Syntax_Print.term_to_string e  in
               FStar_Util.print2 ">> Unfolded (%s) ~> (%s)\n" uu____4424
                 uu____4426
             else ());
            encode_term e env)
       | FStar_Syntax_Syntax.Tm_bvar x ->
           let uu____4432 =
             let uu____4434 = FStar_Syntax_Print.bv_to_string x  in
             FStar_Util.format1 "Impossible: locally nameless; got %s"
               uu____4434
              in
           failwith uu____4432
       | FStar_Syntax_Syntax.Tm_ascribed (t1,(k,uu____4443),uu____4444) ->
           let uu____4493 =
             match k with
             | FStar_Util.Inl t2 -> FStar_Syntax_Util.is_unit t2
             | uu____4503 -> false  in
           if uu____4493
           then (FStar_SMTEncoding_Term.mk_Term_unit, [])
           else encode_term t1 env
       | FStar_Syntax_Syntax.Tm_quoted (qt,uu____4521) ->
           let tv =
             let uu____4527 =
               let uu____4534 = FStar_Reflection_Basic.inspect_ln qt  in
               FStar_Syntax_Embeddings.embed
                 FStar_Reflection_Embeddings.e_term_view uu____4534
                in
             uu____4527 t.FStar_Syntax_Syntax.pos
               FStar_Pervasives_Native.None
               FStar_Syntax_Embeddings.id_norm_cb
              in
           ((let uu____4538 =
               FStar_All.pipe_left
                 (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
                 (FStar_Options.Other "SMTEncoding")
                in
             if uu____4538
             then
               let uu____4543 = FStar_Syntax_Print.term_to_string t0  in
               let uu____4545 = FStar_Syntax_Print.term_to_string tv  in
               FStar_Util.print2 ">> Inspected (%s) ~> (%s)\n" uu____4543
                 uu____4545
             else ());
            (let t1 =
               let uu____4553 =
                 let uu____4564 = FStar_Syntax_Syntax.as_arg tv  in
                 [uu____4564]  in
               FStar_Syntax_Util.mk_app
                 (FStar_Reflection_Data.refl_constant_term
                    FStar_Reflection_Data.fstar_refl_pack_ln) uu____4553
                in
             encode_term t1 env))
       | FStar_Syntax_Syntax.Tm_meta
           (t1,FStar_Syntax_Syntax.Meta_pattern uu____4590) ->
           encode_term t1
             (let uu___618_4616 = env  in
              {
                FStar_SMTEncoding_Env.bvar_bindings =
                  (uu___618_4616.FStar_SMTEncoding_Env.bvar_bindings);
                FStar_SMTEncoding_Env.fvar_bindings =
                  (uu___618_4616.FStar_SMTEncoding_Env.fvar_bindings);
                FStar_SMTEncoding_Env.depth =
                  (uu___618_4616.FStar_SMTEncoding_Env.depth);
                FStar_SMTEncoding_Env.tcenv =
                  (uu___618_4616.FStar_SMTEncoding_Env.tcenv);
                FStar_SMTEncoding_Env.warn =
                  (uu___618_4616.FStar_SMTEncoding_Env.warn);
                FStar_SMTEncoding_Env.nolabels =
                  (uu___618_4616.FStar_SMTEncoding_Env.nolabels);
                FStar_SMTEncoding_Env.use_zfuel_name =
                  (uu___618_4616.FStar_SMTEncoding_Env.use_zfuel_name);
                FStar_SMTEncoding_Env.encode_non_total_function_typ =
                  (uu___618_4616.FStar_SMTEncoding_Env.encode_non_total_function_typ);
                FStar_SMTEncoding_Env.current_module_name =
                  (uu___618_4616.FStar_SMTEncoding_Env.current_module_name);
                FStar_SMTEncoding_Env.encoding_quantifier = false;
                FStar_SMTEncoding_Env.global_cache =
                  (uu___618_4616.FStar_SMTEncoding_Env.global_cache)
              })
       | FStar_Syntax_Syntax.Tm_meta (t1,uu____4619) -> encode_term t1 env
       | FStar_Syntax_Syntax.Tm_name x ->
           let t1 = FStar_SMTEncoding_Env.lookup_term_var env x  in (t1, [])
       | FStar_Syntax_Syntax.Tm_fvar v1 ->
           let uu____4627 = head_redex env t  in
           if uu____4627
           then let uu____4634 = whnf env t  in encode_term uu____4634 env
           else
             (let fvb =
                FStar_SMTEncoding_Env.lookup_free_var_name env
                  v1.FStar_Syntax_Syntax.fv_name
                 in
              let tok =
                FStar_SMTEncoding_Env.lookup_free_var env
                  v1.FStar_Syntax_Syntax.fv_name
                 in
              let tkey_hash = FStar_SMTEncoding_Term.hash_of_term tok  in
              let uu____4641 =
                if
                  fvb.FStar_SMTEncoding_Env.smt_arity > (Prims.parse_int "0")
                then
                  match tok.FStar_SMTEncoding_Term.tm with
                  | FStar_SMTEncoding_Term.FreeV uu____4665 ->
                      let sym_name =
                        let uu____4676 =
                          FStar_Util.digest_of_string tkey_hash  in
                        Prims.op_Hat "@kick_partial_app_" uu____4676  in
                      let uu____4679 =
                        let uu____4682 =
                          let uu____4683 =
                            let uu____4691 =
                              FStar_SMTEncoding_Term.kick_partial_app tok  in
                            (uu____4691,
                              (FStar_Pervasives_Native.Some
                                 "kick_partial_app"), sym_name)
                             in
                          FStar_SMTEncoding_Util.mkAssume uu____4683  in
                        [uu____4682]  in
                      (uu____4679, sym_name)
                  | FStar_SMTEncoding_Term.App (uu____4698,[]) ->
                      let sym_name =
                        let uu____4703 =
                          FStar_Util.digest_of_string tkey_hash  in
                        Prims.op_Hat "@kick_partial_app_" uu____4703  in
                      let uu____4706 =
                        let uu____4709 =
                          let uu____4710 =
                            let uu____4718 =
                              FStar_SMTEncoding_Term.kick_partial_app tok  in
                            (uu____4718,
                              (FStar_Pervasives_Native.Some
                                 "kick_partial_app"), sym_name)
                             in
                          FStar_SMTEncoding_Util.mkAssume uu____4710  in
                        [uu____4709]  in
                      (uu____4706, sym_name)
                  | uu____4725 -> ([], "")
                else ([], "")  in
              match uu____4641 with
              | (aux_decls,sym_name) ->
                  let uu____4748 =
                    if aux_decls = []
                    then
                      FStar_All.pipe_right []
                        FStar_SMTEncoding_Term.mk_decls_trivial
                    else
                      FStar_SMTEncoding_Term.mk_decls sym_name tkey_hash
                        aux_decls []
                     in
                  (tok, uu____4748))
       | FStar_Syntax_Syntax.Tm_type uu____4756 ->
           (FStar_SMTEncoding_Term.mk_Term_type, [])
       | FStar_Syntax_Syntax.Tm_uinst (t1,uu____4758) -> encode_term t1 env
       | FStar_Syntax_Syntax.Tm_constant c -> encode_const c env
       | FStar_Syntax_Syntax.Tm_arrow (binders,c) ->
           let module_name = env.FStar_SMTEncoding_Env.current_module_name
              in
           let uu____4788 = FStar_Syntax_Subst.open_comp binders c  in
           (match uu____4788 with
            | (binders1,res) ->
                let uu____4799 =
                  (env.FStar_SMTEncoding_Env.encode_non_total_function_typ &&
                     (FStar_Syntax_Util.is_pure_or_ghost_comp res))
                    || (FStar_Syntax_Util.is_tot_or_gtot_comp res)
                   in
                if uu____4799
                then
                  let uu____4806 =
                    encode_binders FStar_Pervasives_Native.None binders1 env
                     in
                  (match uu____4806 with
                   | (vars,guards_l,env',decls,uu____4831) ->
                       let fsym =
                         let uu____4845 =
                           let uu____4851 =
                             FStar_SMTEncoding_Env.varops.FStar_SMTEncoding_Env.fresh
                               module_name "f"
                              in
                           (uu____4851, FStar_SMTEncoding_Term.Term_sort)  in
                         FStar_SMTEncoding_Term.mk_fv uu____4845  in
                       let f = FStar_SMTEncoding_Util.mkFreeV fsym  in
                       let app = mk_Apply f vars  in
                       let uu____4857 =
                         FStar_TypeChecker_Util.pure_or_ghost_pre_and_post
                           (let uu___672_4866 =
                              env.FStar_SMTEncoding_Env.tcenv  in
                            {
                              FStar_TypeChecker_Env.solver =
                                (uu___672_4866.FStar_TypeChecker_Env.solver);
                              FStar_TypeChecker_Env.range =
                                (uu___672_4866.FStar_TypeChecker_Env.range);
                              FStar_TypeChecker_Env.curmodule =
                                (uu___672_4866.FStar_TypeChecker_Env.curmodule);
                              FStar_TypeChecker_Env.gamma =
                                (uu___672_4866.FStar_TypeChecker_Env.gamma);
                              FStar_TypeChecker_Env.gamma_sig =
                                (uu___672_4866.FStar_TypeChecker_Env.gamma_sig);
                              FStar_TypeChecker_Env.gamma_cache =
                                (uu___672_4866.FStar_TypeChecker_Env.gamma_cache);
                              FStar_TypeChecker_Env.modules =
                                (uu___672_4866.FStar_TypeChecker_Env.modules);
                              FStar_TypeChecker_Env.expected_typ =
                                (uu___672_4866.FStar_TypeChecker_Env.expected_typ);
                              FStar_TypeChecker_Env.sigtab =
                                (uu___672_4866.FStar_TypeChecker_Env.sigtab);
                              FStar_TypeChecker_Env.attrtab =
                                (uu___672_4866.FStar_TypeChecker_Env.attrtab);
                              FStar_TypeChecker_Env.is_pattern =
                                (uu___672_4866.FStar_TypeChecker_Env.is_pattern);
                              FStar_TypeChecker_Env.instantiate_imp =
                                (uu___672_4866.FStar_TypeChecker_Env.instantiate_imp);
                              FStar_TypeChecker_Env.effects =
                                (uu___672_4866.FStar_TypeChecker_Env.effects);
                              FStar_TypeChecker_Env.generalize =
                                (uu___672_4866.FStar_TypeChecker_Env.generalize);
                              FStar_TypeChecker_Env.letrecs =
                                (uu___672_4866.FStar_TypeChecker_Env.letrecs);
                              FStar_TypeChecker_Env.top_level =
                                (uu___672_4866.FStar_TypeChecker_Env.top_level);
                              FStar_TypeChecker_Env.check_uvars =
                                (uu___672_4866.FStar_TypeChecker_Env.check_uvars);
                              FStar_TypeChecker_Env.use_eq =
                                (uu___672_4866.FStar_TypeChecker_Env.use_eq);
                              FStar_TypeChecker_Env.is_iface =
                                (uu___672_4866.FStar_TypeChecker_Env.is_iface);
                              FStar_TypeChecker_Env.admit =
                                (uu___672_4866.FStar_TypeChecker_Env.admit);
                              FStar_TypeChecker_Env.lax = true;
                              FStar_TypeChecker_Env.lax_universes =
                                (uu___672_4866.FStar_TypeChecker_Env.lax_universes);
                              FStar_TypeChecker_Env.phase1 =
                                (uu___672_4866.FStar_TypeChecker_Env.phase1);
                              FStar_TypeChecker_Env.failhard =
                                (uu___672_4866.FStar_TypeChecker_Env.failhard);
                              FStar_TypeChecker_Env.nosynth =
                                (uu___672_4866.FStar_TypeChecker_Env.nosynth);
                              FStar_TypeChecker_Env.uvar_subtyping =
                                (uu___672_4866.FStar_TypeChecker_Env.uvar_subtyping);
                              FStar_TypeChecker_Env.tc_term =
                                (uu___672_4866.FStar_TypeChecker_Env.tc_term);
                              FStar_TypeChecker_Env.type_of =
                                (uu___672_4866.FStar_TypeChecker_Env.type_of);
                              FStar_TypeChecker_Env.universe_of =
                                (uu___672_4866.FStar_TypeChecker_Env.universe_of);
                              FStar_TypeChecker_Env.check_type_of =
                                (uu___672_4866.FStar_TypeChecker_Env.check_type_of);
                              FStar_TypeChecker_Env.use_bv_sorts =
                                (uu___672_4866.FStar_TypeChecker_Env.use_bv_sorts);
                              FStar_TypeChecker_Env.qtbl_name_and_index =
                                (uu___672_4866.FStar_TypeChecker_Env.qtbl_name_and_index);
                              FStar_TypeChecker_Env.normalized_eff_names =
                                (uu___672_4866.FStar_TypeChecker_Env.normalized_eff_names);
                              FStar_TypeChecker_Env.fv_delta_depths =
                                (uu___672_4866.FStar_TypeChecker_Env.fv_delta_depths);
                              FStar_TypeChecker_Env.proof_ns =
                                (uu___672_4866.FStar_TypeChecker_Env.proof_ns);
                              FStar_TypeChecker_Env.synth_hook =
                                (uu___672_4866.FStar_TypeChecker_Env.synth_hook);
                              FStar_TypeChecker_Env.splice =
                                (uu___672_4866.FStar_TypeChecker_Env.splice);
                              FStar_TypeChecker_Env.postprocess =
                                (uu___672_4866.FStar_TypeChecker_Env.postprocess);
                              FStar_TypeChecker_Env.is_native_tactic =
                                (uu___672_4866.FStar_TypeChecker_Env.is_native_tactic);
                              FStar_TypeChecker_Env.identifier_info =
                                (uu___672_4866.FStar_TypeChecker_Env.identifier_info);
                              FStar_TypeChecker_Env.tc_hooks =
                                (uu___672_4866.FStar_TypeChecker_Env.tc_hooks);
                              FStar_TypeChecker_Env.dsenv =
                                (uu___672_4866.FStar_TypeChecker_Env.dsenv);
                              FStar_TypeChecker_Env.nbe =
                                (uu___672_4866.FStar_TypeChecker_Env.nbe)
                            }) res
                          in
                       (match uu____4857 with
                        | (pre_opt,res_t) ->
                            let uu____4878 =
                              encode_term_pred FStar_Pervasives_Native.None
                                res_t env' app
                               in
                            (match uu____4878 with
                             | (res_pred,decls') ->
                                 let uu____4889 =
                                   match pre_opt with
                                   | FStar_Pervasives_Native.None  ->
                                       let uu____4902 =
                                         FStar_SMTEncoding_Util.mk_and_l
                                           guards_l
                                          in
                                       (uu____4902, [])
                                   | FStar_Pervasives_Native.Some pre ->
                                       let uu____4906 =
                                         encode_formula pre env'  in
                                       (match uu____4906 with
                                        | (guard,decls0) ->
                                            let uu____4919 =
                                              FStar_SMTEncoding_Util.mk_and_l
                                                (guard :: guards_l)
                                               in
                                            (uu____4919, decls0))
                                    in
                                 (match uu____4889 with
                                  | (guards,guard_decls) ->
                                      let is_pure =
                                        FStar_Syntax_Util.is_pure_comp res
                                         in
                                      let t_interp =
                                        let uu____4935 =
                                          let uu____4946 =
                                            FStar_SMTEncoding_Util.mkImp
                                              (guards, res_pred)
                                             in
                                          ([[app]], vars, uu____4946)  in
                                        FStar_SMTEncoding_Term.mkForall
                                          t.FStar_Syntax_Syntax.pos
                                          uu____4935
                                         in
                                      let uu____4955 =
                                        let uu____4972 =
                                          FStar_All.pipe_right
                                            (FStar_Util.prefix vars)
                                            FStar_Pervasives_Native.fst
                                           in
                                        let uu____5017 =
                                          FStar_All.pipe_right
                                            (FStar_Util.prefix guards_l)
                                            FStar_Pervasives_Native.fst
                                           in
                                        (uu____4972, uu____5017)  in
                                      (match uu____4955 with
                                       | (all_vars_but_one,all_guards_but_one)
                                           ->
                                           let uu____5072 =
                                             FStar_List.fold_left2
                                               (fun uu____5129  ->
                                                  fun var  ->
                                                    fun guard  ->
                                                      match uu____5129 with
                                                      | (t_interp1,app1,vars1,guards1)
                                                          ->
                                                          let app2 =
                                                            mk_Apply app1
                                                              [var]
                                                             in
                                                          let vars2 =
                                                            FStar_List.append
                                                              vars1 [var]
                                                             in
                                                          let guards2 =
                                                            FStar_SMTEncoding_Util.mkAnd
                                                              (guards1,
                                                                guard)
                                                             in
                                                          let is_tot_fun_pred_for_partial_app
                                                            =
                                                            let uu____5254 =
                                                              let uu____5265
                                                                =
                                                                let uu____5266
                                                                  =
                                                                  let uu____5271
                                                                    =
                                                                    FStar_SMTEncoding_Term.mk_IsTotFun
                                                                    app2  in
                                                                  (guards2,
                                                                    uu____5271)
                                                                   in
                                                                FStar_SMTEncoding_Util.mkImp
                                                                  uu____5266
                                                                 in
                                                              ([[app2]],
                                                                vars2,
                                                                uu____5265)
                                                               in
                                                            FStar_SMTEncoding_Term.mkForall
                                                              t.FStar_Syntax_Syntax.pos
                                                              uu____5254
                                                             in
                                                          let t1 =
                                                            FStar_SMTEncoding_Util.mkAnd
                                                              (t_interp1,
                                                                is_tot_fun_pred_for_partial_app)
                                                             in
                                                          (t1, app2, vars2,
                                                            guards2))
                                               (t_interp, f, [],
                                                 FStar_SMTEncoding_Util.mkTrue)
                                               all_vars_but_one
                                               all_guards_but_one
                                              in
                                           (match uu____5072 with
                                            | (t_interp1,uu____5314,uu____5315,uu____5316)
                                                ->
                                                let t_interp2 =
                                                  if is_pure
                                                  then
                                                    let uu____5339 =
                                                      let uu____5344 =
                                                        FStar_SMTEncoding_Term.mk_IsTotFun
                                                          f
                                                         in
                                                      (t_interp1, uu____5344)
                                                       in
                                                    FStar_SMTEncoding_Util.mkAnd
                                                      uu____5339
                                                  else t_interp1  in
                                                let cvars =
                                                  let uu____5358 =
                                                    FStar_SMTEncoding_Term.free_variables
                                                      t_interp2
                                                     in
                                                  FStar_All.pipe_right
                                                    uu____5358
                                                    (FStar_List.filter
                                                       (fun x  ->
                                                          let uu____5377 =
                                                            FStar_SMTEncoding_Term.fv_name
                                                              x
                                                             in
                                                          let uu____5379 =
                                                            FStar_SMTEncoding_Term.fv_name
                                                              fsym
                                                             in
                                                          uu____5377 <>
                                                            uu____5379))
                                                   in
                                                let tkey =
                                                  FStar_SMTEncoding_Term.mkForall
                                                    t.FStar_Syntax_Syntax.pos
                                                    ([], (fsym :: cvars),
                                                      t_interp2)
                                                   in
                                                let prefix1 =
                                                  if is_pure
                                                  then "Tm_arrow_"
                                                  else "Tm_ghost_arrow_"  in
                                                let tkey_hash =
                                                  let uu____5407 =
                                                    FStar_SMTEncoding_Term.hash_of_term
                                                      tkey
                                                     in
                                                  Prims.op_Hat prefix1
                                                    uu____5407
                                                   in
                                                let tsym =
                                                  let uu____5411 =
                                                    FStar_Util.digest_of_string
                                                      tkey_hash
                                                     in
                                                  Prims.op_Hat prefix1
                                                    uu____5411
                                                   in
                                                let cvar_sorts =
                                                  FStar_List.map
                                                    FStar_SMTEncoding_Term.fv_sort
                                                    cvars
                                                   in
                                                let caption =
                                                  let uu____5425 =
                                                    FStar_Options.log_queries
                                                      ()
                                                     in
                                                  if uu____5425
                                                  then
                                                    let uu____5428 =
                                                      let uu____5430 =
                                                        FStar_TypeChecker_Normalize.term_to_string
                                                          env.FStar_SMTEncoding_Env.tcenv
                                                          t0
                                                         in
                                                      FStar_Util.replace_char
                                                        uu____5430 10 32
                                                       in
                                                    FStar_Pervasives_Native.Some
                                                      uu____5428
                                                  else
                                                    FStar_Pervasives_Native.None
                                                   in
                                                let tdecl =
                                                  FStar_SMTEncoding_Term.DeclFun
                                                    (tsym, cvar_sorts,
                                                      FStar_SMTEncoding_Term.Term_sort,
                                                      caption)
                                                   in
                                                let t1 =
                                                  let uu____5443 =
                                                    let uu____5451 =
                                                      FStar_List.map
                                                        FStar_SMTEncoding_Util.mkFreeV
                                                        cvars
                                                       in
                                                    (tsym, uu____5451)  in
                                                  FStar_SMTEncoding_Util.mkApp
                                                    uu____5443
                                                   in
                                                let t_has_kind =
                                                  FStar_SMTEncoding_Term.mk_HasType
                                                    t1
                                                    FStar_SMTEncoding_Term.mk_Term_type
                                                   in
                                                let k_assumption =
                                                  let a_name =
                                                    Prims.op_Hat "kinding_"
                                                      tsym
                                                     in
                                                  let uu____5470 =
                                                    let uu____5478 =
                                                      FStar_SMTEncoding_Term.mkForall
                                                        t0.FStar_Syntax_Syntax.pos
                                                        ([[t_has_kind]],
                                                          cvars, t_has_kind)
                                                       in
                                                    (uu____5478,
                                                      (FStar_Pervasives_Native.Some
                                                         a_name), a_name)
                                                     in
                                                  FStar_SMTEncoding_Util.mkAssume
                                                    uu____5470
                                                   in
                                                let f_has_t =
                                                  FStar_SMTEncoding_Term.mk_HasType
                                                    f t1
                                                   in
                                                let f_has_t_z =
                                                  FStar_SMTEncoding_Term.mk_HasTypeZ
                                                    f t1
                                                   in
                                                let pre_typing =
                                                  let a_name =
                                                    Prims.op_Hat
                                                      "pre_typing_" tsym
                                                     in
                                                  let uu____5495 =
                                                    let uu____5503 =
                                                      let uu____5504 =
                                                        let uu____5515 =
                                                          let uu____5516 =
                                                            let uu____5521 =
                                                              let uu____5522
                                                                =
                                                                FStar_SMTEncoding_Term.mk_PreType
                                                                  f
                                                                 in
                                                              FStar_SMTEncoding_Term.mk_tester
                                                                "Tm_arrow"
                                                                uu____5522
                                                               in
                                                            (f_has_t,
                                                              uu____5521)
                                                             in
                                                          FStar_SMTEncoding_Util.mkImp
                                                            uu____5516
                                                           in
                                                        ([[f_has_t]], (fsym
                                                          :: cvars),
                                                          uu____5515)
                                                         in
                                                      let uu____5540 =
                                                        mkForall_fuel
                                                          module_name
                                                          t0.FStar_Syntax_Syntax.pos
                                                         in
                                                      uu____5540 uu____5504
                                                       in
                                                    (uu____5503,
                                                      (FStar_Pervasives_Native.Some
                                                         "pre-typing for functions"),
                                                      (Prims.op_Hat
                                                         module_name
                                                         (Prims.op_Hat "_"
                                                            a_name)))
                                                     in
                                                  FStar_SMTEncoding_Util.mkAssume
                                                    uu____5495
                                                   in
                                                let t_interp3 =
                                                  let a_name =
                                                    Prims.op_Hat
                                                      "interpretation_" tsym
                                                     in
                                                  let uu____5563 =
                                                    let uu____5571 =
                                                      let uu____5572 =
                                                        let uu____5583 =
                                                          FStar_SMTEncoding_Util.mkIff
                                                            (f_has_t_z,
                                                              t_interp2)
                                                           in
                                                        ([[f_has_t_z]], (fsym
                                                          :: cvars),
                                                          uu____5583)
                                                         in
                                                      FStar_SMTEncoding_Term.mkForall
                                                        t0.FStar_Syntax_Syntax.pos
                                                        uu____5572
                                                       in
                                                    (uu____5571,
                                                      (FStar_Pervasives_Native.Some
                                                         a_name),
                                                      (Prims.op_Hat
                                                         module_name
                                                         (Prims.op_Hat "_"
                                                            a_name)))
                                                     in
                                                  FStar_SMTEncoding_Util.mkAssume
                                                    uu____5563
                                                   in
                                                let t_decls1 =
                                                  [tdecl;
                                                  k_assumption;
                                                  pre_typing;
                                                  t_interp3]  in
                                                let uu____5606 =
                                                  let uu____5607 =
                                                    let uu____5610 =
                                                      let uu____5613 =
                                                        FStar_SMTEncoding_Term.mk_decls
                                                          tsym tkey_hash
                                                          t_decls1
                                                          (FStar_List.append
                                                             decls
                                                             (FStar_List.append
                                                                decls'
                                                                guard_decls))
                                                         in
                                                      FStar_List.append
                                                        guard_decls
                                                        uu____5613
                                                       in
                                                    FStar_List.append decls'
                                                      uu____5610
                                                     in
                                                  FStar_List.append decls
                                                    uu____5607
                                                   in
                                                (t1, uu____5606)))))))
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
                   let t1 = FStar_SMTEncoding_Util.mkApp (tsym, [])  in
                   let t_kinding =
                     let a_name =
                       Prims.op_Hat "non_total_function_typing_" tsym  in
                     let uu____5634 =
                       let uu____5642 =
                         FStar_SMTEncoding_Term.mk_HasType t1
                           FStar_SMTEncoding_Term.mk_Term_type
                          in
                       (uu____5642,
                         (FStar_Pervasives_Native.Some
                            "Typing for non-total arrows"), a_name)
                        in
                     FStar_SMTEncoding_Util.mkAssume uu____5634  in
                   let fsym =
                     FStar_SMTEncoding_Term.mk_fv
                       ("f", FStar_SMTEncoding_Term.Term_sort)
                      in
                   let f = FStar_SMTEncoding_Util.mkFreeV fsym  in
                   let f_has_t = FStar_SMTEncoding_Term.mk_HasType f t1  in
                   let t_interp =
                     let a_name = Prims.op_Hat "pre_typing_" tsym  in
                     let uu____5655 =
                       let uu____5663 =
                         let uu____5664 =
                           let uu____5675 =
                             let uu____5676 =
                               let uu____5681 =
                                 let uu____5682 =
                                   FStar_SMTEncoding_Term.mk_PreType f  in
                                 FStar_SMTEncoding_Term.mk_tester "Tm_arrow"
                                   uu____5682
                                  in
                               (f_has_t, uu____5681)  in
                             FStar_SMTEncoding_Util.mkImp uu____5676  in
                           ([[f_has_t]], [fsym], uu____5675)  in
                         let uu____5708 =
                           mkForall_fuel module_name
                             t0.FStar_Syntax_Syntax.pos
                            in
                         uu____5708 uu____5664  in
                       (uu____5663, (FStar_Pervasives_Native.Some a_name),
                         a_name)
                        in
                     FStar_SMTEncoding_Util.mkAssume uu____5655  in
                   let uu____5725 =
                     FStar_All.pipe_right [tdecl; t_kinding; t_interp]
                       FStar_SMTEncoding_Term.mk_decls_trivial
                      in
                   (t1, uu____5725)))
       | FStar_Syntax_Syntax.Tm_refine uu____5728 ->
           let uu____5735 =
             let steps =
               [FStar_TypeChecker_Env.Weak;
               FStar_TypeChecker_Env.HNF;
               FStar_TypeChecker_Env.EraseUniverses]  in
             let uu____5745 =
               FStar_TypeChecker_Normalize.normalize_refinement steps
                 env.FStar_SMTEncoding_Env.tcenv t0
                in
             match uu____5745 with
             | { FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_refine (x,f);
                 FStar_Syntax_Syntax.pos = uu____5754;
                 FStar_Syntax_Syntax.vars = uu____5755;_} ->
                 let uu____5762 =
                   FStar_Syntax_Subst.open_term
                     [(x, FStar_Pervasives_Native.None)] f
                    in
                 (match uu____5762 with
                  | (b,f1) ->
                      let uu____5789 =
                        let uu____5790 = FStar_List.hd b  in
                        FStar_Pervasives_Native.fst uu____5790  in
                      (uu____5789, f1))
             | uu____5807 -> failwith "impossible"  in
           (match uu____5735 with
            | (x,f) ->
                let uu____5825 = encode_term x.FStar_Syntax_Syntax.sort env
                   in
                (match uu____5825 with
                 | (base_t,decls) ->
                     let uu____5836 =
                       FStar_SMTEncoding_Env.gen_term_var env x  in
                     (match uu____5836 with
                      | (x1,xtm,env') ->
                          let uu____5853 = encode_formula f env'  in
                          (match uu____5853 with
                           | (refinement,decls') ->
                               let uu____5864 =
                                 FStar_SMTEncoding_Env.fresh_fvar
                                   env.FStar_SMTEncoding_Env.current_module_name
                                   "f" FStar_SMTEncoding_Term.Fuel_sort
                                  in
                               (match uu____5864 with
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
                                      let uu____5892 =
                                        let uu____5903 =
                                          FStar_SMTEncoding_Term.free_variables
                                            refinement
                                           in
                                        let uu____5914 =
                                          FStar_SMTEncoding_Term.free_variables
                                            tm_has_type_with_fuel
                                           in
                                        FStar_List.append uu____5903
                                          uu____5914
                                         in
                                      FStar_Util.remove_dups
                                        FStar_SMTEncoding_Term.fv_eq
                                        uu____5892
                                       in
                                    let cvars1 =
                                      FStar_All.pipe_right cvars
                                        (FStar_List.filter
                                           (fun y  ->
                                              (let uu____5968 =
                                                 FStar_SMTEncoding_Term.fv_name
                                                   y
                                                  in
                                               uu____5968 <> x1) &&
                                                (let uu____5972 =
                                                   FStar_SMTEncoding_Term.fv_name
                                                     y
                                                    in
                                                 uu____5972 <> fsym)))
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
                                    ((let uu____6005 =
                                        FStar_TypeChecker_Env.debug
                                          env.FStar_SMTEncoding_Env.tcenv
                                          (FStar_Options.Other "SMTEncoding")
                                         in
                                      if uu____6005
                                      then
                                        let uu____6009 =
                                          FStar_Syntax_Print.term_to_string f
                                           in
                                        let uu____6011 =
                                          FStar_Util.digest_of_string
                                            tkey_hash
                                           in
                                        FStar_Util.print3
                                          "Encoding Tm_refine %s with tkey_hash %s and digest %s\n"
                                          uu____6009 tkey_hash uu____6011
                                      else ());
                                     (let tsym =
                                        let uu____6018 =
                                          FStar_Util.digest_of_string
                                            tkey_hash
                                           in
                                        Prims.op_Hat "Tm_refine_" uu____6018
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
                                      let t1 =
                                        let uu____6038 =
                                          let uu____6046 =
                                            FStar_List.map
                                              FStar_SMTEncoding_Util.mkFreeV
                                              cvars1
                                             in
                                          (tsym, uu____6046)  in
                                        FStar_SMTEncoding_Util.mkApp
                                          uu____6038
                                         in
                                      let x_has_base_t =
                                        FStar_SMTEncoding_Term.mk_HasType xtm
                                          base_t
                                         in
                                      let x_has_t =
                                        FStar_SMTEncoding_Term.mk_HasTypeWithFuel
                                          (FStar_Pervasives_Native.Some fterm)
                                          xtm t1
                                         in
                                      let t_has_kind =
                                        FStar_SMTEncoding_Term.mk_HasType t1
                                          FStar_SMTEncoding_Term.mk_Term_type
                                         in
                                      let t_haseq_base =
                                        FStar_SMTEncoding_Term.mk_haseq
                                          base_t
                                         in
                                      let t_haseq_ref =
                                        FStar_SMTEncoding_Term.mk_haseq t1
                                         in
                                      let t_haseq1 =
                                        let uu____6066 =
                                          let uu____6074 =
                                            let uu____6075 =
                                              let uu____6086 =
                                                FStar_SMTEncoding_Util.mkIff
                                                  (t_haseq_ref, t_haseq_base)
                                                 in
                                              ([[t_haseq_ref]], cvars1,
                                                uu____6086)
                                               in
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              uu____6075
                                             in
                                          (uu____6074,
                                            (FStar_Pervasives_Native.Some
                                               (Prims.op_Hat "haseq for "
                                                  tsym)),
                                            (Prims.op_Hat "haseq" tsym))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____6066
                                         in
                                      let t_kinding =
                                        let uu____6100 =
                                          let uu____6108 =
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              ([[t_has_kind]], cvars1,
                                                t_has_kind)
                                             in
                                          (uu____6108,
                                            (FStar_Pervasives_Native.Some
                                               "refinement kinding"),
                                            (Prims.op_Hat
                                               "refinement_kinding_" tsym))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____6100
                                         in
                                      let t_interp =
                                        let uu____6122 =
                                          let uu____6130 =
                                            let uu____6131 =
                                              let uu____6142 =
                                                FStar_SMTEncoding_Util.mkIff
                                                  (x_has_t, encoding)
                                                 in
                                              ([[x_has_t]], (ffv :: xfv ::
                                                cvars1), uu____6142)
                                               in
                                            FStar_SMTEncoding_Term.mkForall
                                              t0.FStar_Syntax_Syntax.pos
                                              uu____6131
                                             in
                                          (uu____6130,
                                            (FStar_Pervasives_Native.Some
                                               "refinement_interpretation"),
                                            (Prims.op_Hat
                                               "refinement_interpretation_"
                                               tsym))
                                           in
                                        FStar_SMTEncoding_Util.mkAssume
                                          uu____6122
                                         in
                                      let t_decls1 =
                                        [tdecl;
                                        t_kinding;
                                        t_interp;
                                        t_haseq1]  in
                                      let uu____6174 =
                                        let uu____6175 =
                                          let uu____6178 =
                                            FStar_SMTEncoding_Term.mk_decls
                                              tsym tkey_hash t_decls1
                                              (FStar_List.append decls decls')
                                             in
                                          FStar_List.append decls' uu____6178
                                           in
                                        FStar_List.append decls uu____6175
                                         in
                                      (t1, uu____6174))))))))
       | FStar_Syntax_Syntax.Tm_uvar (uv,uu____6182) ->
           let ttm =
             let uu____6200 =
               FStar_Syntax_Unionfind.uvar_id
                 uv.FStar_Syntax_Syntax.ctx_uvar_head
                in
             FStar_SMTEncoding_Util.mk_Term_uvar uu____6200  in
           let uu____6202 =
             encode_term_pred FStar_Pervasives_Native.None
               uv.FStar_Syntax_Syntax.ctx_uvar_typ env ttm
              in
           (match uu____6202 with
            | (t_has_k,decls) ->
                let d =
                  let uu____6214 =
                    let uu____6222 =
                      let uu____6224 =
                        let uu____6226 =
                          let uu____6228 =
                            FStar_Syntax_Unionfind.uvar_id
                              uv.FStar_Syntax_Syntax.ctx_uvar_head
                             in
                          FStar_Util.string_of_int uu____6228  in
                        FStar_Util.format1 "uvar_typing_%s" uu____6226  in
                      FStar_SMTEncoding_Env.varops.FStar_SMTEncoding_Env.mk_unique
                        uu____6224
                       in
                    (t_has_k, (FStar_Pervasives_Native.Some "Uvar typing"),
                      uu____6222)
                     in
                  FStar_SMTEncoding_Util.mkAssume uu____6214  in
                let uu____6234 =
                  let uu____6235 =
                    FStar_All.pipe_right [d]
                      FStar_SMTEncoding_Term.mk_decls_trivial
                     in
                  FStar_List.append decls uu____6235  in
                (ttm, uu____6234))
       | FStar_Syntax_Syntax.Tm_app uu____6242 ->
           let uu____6259 = FStar_Syntax_Util.head_and_args t0  in
           (match uu____6259 with
            | (head1,args_e) ->
                let uu____6306 =
                  let uu____6321 =
                    let uu____6322 = FStar_Syntax_Subst.compress head1  in
                    uu____6322.FStar_Syntax_Syntax.n  in
                  (uu____6321, args_e)  in
                (match uu____6306 with
                 | uu____6339 when head_redex env head1 ->
                     let uu____6354 = whnf env t  in
                     encode_term uu____6354 env
                 | uu____6355 when is_arithmetic_primitive head1 args_e ->
                     encode_arith_term env head1 args_e
                 | uu____6378 when is_BitVector_primitive head1 args_e ->
                     encode_BitVector_term env head1 args_e
                 | (FStar_Syntax_Syntax.Tm_fvar fv,uu____6396) when
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
                       FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv;
                       FStar_Syntax_Syntax.pos = uu____6418;
                       FStar_Syntax_Syntax.vars = uu____6419;_},uu____6420),uu____6421)
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
                       FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv;
                       FStar_Syntax_Syntax.pos = uu____6447;
                       FStar_Syntax_Syntax.vars = uu____6448;_},uu____6449),
                    (v0,uu____6451)::(v1,uu____6453)::(v2,uu____6455)::[])
                     when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.lexcons_lid
                     ->
                     let uu____6526 = encode_term v0 env  in
                     (match uu____6526 with
                      | (v01,decls0) ->
                          let uu____6537 = encode_term v1 env  in
                          (match uu____6537 with
                           | (v11,decls1) ->
                               let uu____6548 = encode_term v2 env  in
                               (match uu____6548 with
                                | (v21,decls2) ->
                                    let uu____6559 =
                                      FStar_SMTEncoding_Util.mk_LexCons v01
                                        v11 v21
                                       in
                                    (uu____6559,
                                      (FStar_List.append decls0
                                         (FStar_List.append decls1 decls2))))))
                 | (FStar_Syntax_Syntax.Tm_fvar
                    fv,(v0,uu____6562)::(v1,uu____6564)::(v2,uu____6566)::[])
                     when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.lexcons_lid
                     ->
                     let uu____6633 = encode_term v0 env  in
                     (match uu____6633 with
                      | (v01,decls0) ->
                          let uu____6644 = encode_term v1 env  in
                          (match uu____6644 with
                           | (v11,decls1) ->
                               let uu____6655 = encode_term v2 env  in
                               (match uu____6655 with
                                | (v21,decls2) ->
                                    let uu____6666 =
                                      FStar_SMTEncoding_Util.mk_LexCons v01
                                        v11 v21
                                       in
                                    (uu____6666,
                                      (FStar_List.append decls0
                                         (FStar_List.append decls1 decls2))))))
                 | (FStar_Syntax_Syntax.Tm_constant
                    (FStar_Const.Const_range_of ),(arg,uu____6668)::[]) ->
                     encode_const
                       (FStar_Const.Const_range (arg.FStar_Syntax_Syntax.pos))
                       env
                 | (FStar_Syntax_Syntax.Tm_constant
                    (FStar_Const.Const_set_range_of
                    ),(arg,uu____6704)::(rng,uu____6706)::[]) ->
                     encode_term arg env
                 | (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_reify
                    ),uu____6757) ->
                     let e0 =
                       let uu____6779 = FStar_List.hd args_e  in
                       FStar_TypeChecker_Util.reify_body_with_arg
                         env.FStar_SMTEncoding_Env.tcenv head1 uu____6779
                        in
                     ((let uu____6789 =
                         FStar_All.pipe_left
                           (FStar_TypeChecker_Env.debug
                              env.FStar_SMTEncoding_Env.tcenv)
                           (FStar_Options.Other "SMTEncodingReify")
                          in
                       if uu____6789
                       then
                         let uu____6794 =
                           FStar_Syntax_Print.term_to_string e0  in
                         FStar_Util.print1 "Result of normalization %s\n"
                           uu____6794
                       else ());
                      (let e =
                         let uu____6802 =
                           let uu____6807 =
                             FStar_TypeChecker_Util.remove_reify e0  in
                           let uu____6808 = FStar_List.tl args_e  in
                           FStar_Syntax_Syntax.mk_Tm_app uu____6807
                             uu____6808
                            in
                         uu____6802 FStar_Pervasives_Native.None
                           t0.FStar_Syntax_Syntax.pos
                          in
                       encode_term e env))
                 | (FStar_Syntax_Syntax.Tm_constant
                    (FStar_Const.Const_reflect
                    uu____6817),(arg,uu____6819)::[]) -> encode_term arg env
                 | uu____6854 ->
                     let uu____6869 = encode_args args_e env  in
                     (match uu____6869 with
                      | (args,decls) ->
                          let encode_partial_app ht_opt =
                            let uu____6938 = encode_term head1 env  in
                            match uu____6938 with
                            | (smt_head,decls') ->
                                let app_tm = mk_Apply_args smt_head args  in
                                (match ht_opt with
                                 | FStar_Pervasives_Native.None  ->
                                     (app_tm,
                                       (FStar_List.append decls decls'))
                                 | FStar_Pervasives_Native.Some
                                     (head_type,formals,c) ->
                                     ((let uu____7024 =
                                         FStar_TypeChecker_Env.debug
                                           env.FStar_SMTEncoding_Env.tcenv
                                           (FStar_Options.Other "PartialApp")
                                          in
                                       if uu____7024
                                       then
                                         let uu____7028 =
                                           FStar_Syntax_Print.term_to_string
                                             head1
                                            in
                                         let uu____7030 =
                                           FStar_Syntax_Print.term_to_string
                                             head_type
                                            in
                                         let uu____7032 =
                                           FStar_Syntax_Print.binders_to_string
                                             ", " formals
                                            in
                                         let uu____7035 =
                                           FStar_Syntax_Print.comp_to_string
                                             c
                                            in
                                         let uu____7037 =
                                           FStar_Syntax_Print.args_to_string
                                             args_e
                                            in
                                         FStar_Util.print5
                                           "Encoding partial application:\n\thead=%s\n\thead_type=%s\n\tformals=%s\n\tcomp=%s\n\tactual args=%s\n"
                                           uu____7028 uu____7030 uu____7032
                                           uu____7035 uu____7037
                                       else ());
                                      (let uu____7042 =
                                         FStar_Util.first_N
                                           (FStar_List.length args_e) formals
                                          in
                                       match uu____7042 with
                                       | (formals1,rest) ->
                                           let subst1 =
                                             FStar_List.map2
                                               (fun uu____7140  ->
                                                  fun uu____7141  ->
                                                    match (uu____7140,
                                                            uu____7141)
                                                    with
                                                    | ((bv,uu____7171),
                                                       (a,uu____7173)) ->
                                                        FStar_Syntax_Syntax.NT
                                                          (bv, a)) formals1
                                               args_e
                                              in
                                           let ty =
                                             let uu____7205 =
                                               FStar_Syntax_Util.arrow rest c
                                                in
                                             FStar_All.pipe_right uu____7205
                                               (FStar_Syntax_Subst.subst
                                                  subst1)
                                              in
                                           ((let uu____7209 =
                                               FStar_TypeChecker_Env.debug
                                                 env.FStar_SMTEncoding_Env.tcenv
                                                 (FStar_Options.Other
                                                    "PartialApp")
                                                in
                                             if uu____7209
                                             then
                                               let uu____7213 =
                                                 FStar_Syntax_Print.term_to_string
                                                   ty
                                                  in
                                               FStar_Util.print1
                                                 "Encoding partial application, after subst:\n\tty=%s\n"
                                                 uu____7213
                                             else ());
                                            (let uu____7218 =
                                               let uu____7231 =
                                                 FStar_List.fold_left2
                                                   (fun uu____7266  ->
                                                      fun uu____7267  ->
                                                        fun e  ->
                                                          match (uu____7266,
                                                                  uu____7267)
                                                          with
                                                          | ((t_hyps,decls1),
                                                             (bv,uu____7308))
                                                              ->
                                                              let t1 =
                                                                FStar_Syntax_Subst.subst
                                                                  subst1
                                                                  bv.FStar_Syntax_Syntax.sort
                                                                 in
                                                              let uu____7336
                                                                =
                                                                encode_term_pred
                                                                  FStar_Pervasives_Native.None
                                                                  t1 env e
                                                                 in
                                                              (match uu____7336
                                                               with
                                                               | (t_hyp,decls'1)
                                                                   ->
                                                                   ((
                                                                    let uu____7352
                                                                    =
                                                                    FStar_TypeChecker_Env.debug
                                                                    env.FStar_SMTEncoding_Env.tcenv
                                                                    (FStar_Options.Other
                                                                    "PartialApp")
                                                                     in
                                                                    if
                                                                    uu____7352
                                                                    then
                                                                    let uu____7356
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    t1  in
                                                                    let uu____7358
                                                                    =
                                                                    FStar_SMTEncoding_Term.print_smt_term
                                                                    t_hyp  in
                                                                    FStar_Util.print2
                                                                    "Encoded typing hypothesis for %s ... got %s\n"
                                                                    uu____7356
                                                                    uu____7358
                                                                    else ());
                                                                    ((t_hyp
                                                                    ::
                                                                    t_hyps),
                                                                    (FStar_List.append
                                                                    decls1
                                                                    decls'1)))))
                                                   ([], []) formals1 args
                                                  in
                                               match uu____7231 with
                                               | (t_hyps,decls1) ->
                                                   let uu____7393 =
                                                     match smt_head.FStar_SMTEncoding_Term.tm
                                                     with
                                                     | FStar_SMTEncoding_Term.FreeV
                                                         uu____7402 ->
                                                         encode_term_pred
                                                           FStar_Pervasives_Native.None
                                                           head_type env
                                                           smt_head
                                                     | uu____7411 ->
                                                         (FStar_SMTEncoding_Util.mkTrue,
                                                           [])
                                                      in
                                                   (match uu____7393 with
                                                    | (t_head_hyp,decls'1) ->
                                                        let hyp =
                                                          FStar_SMTEncoding_Term.mk_and_l
                                                            (t_head_hyp ::
                                                            t_hyps)
                                                            FStar_Range.dummyRange
                                                           in
                                                        let uu____7427 =
                                                          encode_term_pred
                                                            FStar_Pervasives_Native.None
                                                            ty env app_tm
                                                           in
                                                        (match uu____7427
                                                         with
                                                         | (has_type_conclusion,decls'')
                                                             ->
                                                             let has_type =
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
                                                             let uu____7449 =
                                                               let uu____7456
                                                                 =
                                                                 FStar_SMTEncoding_Term.fvs_subset_of
                                                                   cvars
                                                                   app_tm_vars
                                                                  in
                                                               if uu____7456
                                                               then
                                                                 ([app_tm],
                                                                   app_tm_vars)
                                                               else
                                                                 (let uu____7469
                                                                    =
                                                                    let uu____7471
                                                                    =
                                                                    FStar_SMTEncoding_Term.free_variables
                                                                    has_type_conclusion
                                                                     in
                                                                    FStar_SMTEncoding_Term.fvs_subset_of
                                                                    cvars
                                                                    uu____7471
                                                                     in
                                                                  if
                                                                    uu____7469
                                                                  then
                                                                    ([has_type_conclusion],
                                                                    cvars)
                                                                  else
                                                                    (
                                                                    (
                                                                    let uu____7484
                                                                    =
                                                                    let uu____7490
                                                                    =
                                                                    let uu____7492
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    t0  in
                                                                    FStar_Util.format1
                                                                    "No SMT pattern for partial application %s"
                                                                    uu____7492
                                                                     in
                                                                    (FStar_Errors.Warning_SMTPatternIllFormed,
                                                                    uu____7490)
                                                                     in
                                                                    FStar_Errors.log_issue
                                                                    t0.FStar_Syntax_Syntax.pos
                                                                    uu____7484);
                                                                    ([],
                                                                    cvars)))
                                                                in
                                                             (match uu____7449
                                                              with
                                                              | (pattern,vars)
                                                                  ->
                                                                  (vars,
                                                                    pattern,
                                                                    has_type,
                                                                    (
                                                                    FStar_List.append
                                                                    decls1
                                                                    (FStar_List.append
                                                                    decls'1
                                                                    decls''))))))
                                                in
                                             match uu____7218 with
                                             | (vars,pattern,has_type,decls'')
                                                 ->
                                                 ((let uu____7539 =
                                                     FStar_TypeChecker_Env.debug
                                                       env.FStar_SMTEncoding_Env.tcenv
                                                       (FStar_Options.Other
                                                          "PartialApp")
                                                      in
                                                   if uu____7539
                                                   then
                                                     let uu____7543 =
                                                       FStar_SMTEncoding_Term.print_smt_term
                                                         has_type
                                                        in
                                                     FStar_Util.print1
                                                       "Encoding partial application, after SMT encoded predicate:\n\t=%s\n"
                                                       uu____7543
                                                   else ());
                                                  (let tkey_hash =
                                                     FStar_SMTEncoding_Term.hash_of_term
                                                       app_tm
                                                      in
                                                   let e_typing =
                                                     let uu____7551 =
                                                       let uu____7559 =
                                                         FStar_SMTEncoding_Term.mkForall
                                                           t0.FStar_Syntax_Syntax.pos
                                                           ([pattern], vars,
                                                             has_type)
                                                          in
                                                       let uu____7568 =
                                                         let uu____7570 =
                                                           let uu____7572 =
                                                             FStar_SMTEncoding_Term.hash_of_term
                                                               app_tm
                                                              in
                                                           FStar_Util.digest_of_string
                                                             uu____7572
                                                            in
                                                         Prims.op_Hat
                                                           "partial_app_typing_"
                                                           uu____7570
                                                          in
                                                       (uu____7559,
                                                         (FStar_Pervasives_Native.Some
                                                            "Partial app typing"),
                                                         uu____7568)
                                                        in
                                                     FStar_SMTEncoding_Util.mkAssume
                                                       uu____7551
                                                      in
                                                   let uu____7578 =
                                                     let uu____7581 =
                                                       let uu____7584 =
                                                         let uu____7587 =
                                                           FStar_SMTEncoding_Term.mk_decls
                                                             "" tkey_hash
                                                             [e_typing]
                                                             (FStar_List.append
                                                                decls
                                                                (FStar_List.append
                                                                   decls'
                                                                   decls''))
                                                            in
                                                         FStar_List.append
                                                           decls'' uu____7587
                                                          in
                                                       FStar_List.append
                                                         decls' uu____7584
                                                        in
                                                     FStar_List.append decls
                                                       uu____7581
                                                      in
                                                   (app_tm, uu____7578))))))))
                             in
                          let encode_full_app fv =
                            let uu____7607 =
                              FStar_SMTEncoding_Env.lookup_free_var_sym env
                                fv
                               in
                            match uu____7607 with
                            | (fname,fuel_args,arity) ->
                                let tm =
                                  maybe_curry_app t0.FStar_Syntax_Syntax.pos
                                    fname arity
                                    (FStar_List.append fuel_args args)
                                   in
                                (tm, decls)
                             in
                          let head2 = FStar_Syntax_Subst.compress head1  in
                          let head_type =
                            match head2.FStar_Syntax_Syntax.n with
                            | FStar_Syntax_Syntax.Tm_uinst
                                ({
                                   FStar_Syntax_Syntax.n =
                                     FStar_Syntax_Syntax.Tm_name x;
                                   FStar_Syntax_Syntax.pos = uu____7650;
                                   FStar_Syntax_Syntax.vars = uu____7651;_},uu____7652)
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
                                   FStar_Syntax_Syntax.pos = uu____7659;
                                   FStar_Syntax_Syntax.vars = uu____7660;_},uu____7661)
                                ->
                                let uu____7666 =
                                  let uu____7667 =
                                    let uu____7672 =
                                      FStar_TypeChecker_Env.lookup_lid
                                        env.FStar_SMTEncoding_Env.tcenv
                                        (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                       in
                                    FStar_All.pipe_right uu____7672
                                      FStar_Pervasives_Native.fst
                                     in
                                  FStar_All.pipe_right uu____7667
                                    FStar_Pervasives_Native.snd
                                   in
                                FStar_Pervasives_Native.Some uu____7666
                            | FStar_Syntax_Syntax.Tm_fvar fv ->
                                let uu____7702 =
                                  let uu____7703 =
                                    let uu____7708 =
                                      FStar_TypeChecker_Env.lookup_lid
                                        env.FStar_SMTEncoding_Env.tcenv
                                        (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                       in
                                    FStar_All.pipe_right uu____7708
                                      FStar_Pervasives_Native.fst
                                     in
                                  FStar_All.pipe_right uu____7703
                                    FStar_Pervasives_Native.snd
                                   in
                                FStar_Pervasives_Native.Some uu____7702
                            | FStar_Syntax_Syntax.Tm_ascribed
                                (uu____7737,(FStar_Util.Inl t1,uu____7739),uu____7740)
                                -> FStar_Pervasives_Native.Some t1
                            | FStar_Syntax_Syntax.Tm_ascribed
                                (uu____7787,(FStar_Util.Inr c,uu____7789),uu____7790)
                                ->
                                FStar_Pervasives_Native.Some
                                  (FStar_Syntax_Util.comp_result c)
                            | uu____7837 -> FStar_Pervasives_Native.None  in
                          (match head_type with
                           | FStar_Pervasives_Native.None  ->
                               encode_partial_app
                                 FStar_Pervasives_Native.None
                           | FStar_Pervasives_Native.Some head_type1 ->
                               let uu____7861 =
                                 let head_type2 =
                                   let uu____7883 =
                                     FStar_TypeChecker_Normalize.normalize_refinement
                                       [FStar_TypeChecker_Env.Weak;
                                       FStar_TypeChecker_Env.HNF;
                                       FStar_TypeChecker_Env.EraseUniverses]
                                       env.FStar_SMTEncoding_Env.tcenv
                                       head_type1
                                      in
                                   FStar_All.pipe_left
                                     FStar_Syntax_Util.unrefine uu____7883
                                    in
                                 let uu____7886 =
                                   curried_arrow_formals_comp head_type2  in
                                 match uu____7886 with
                                 | (formals,c) ->
                                     if
                                       (FStar_List.length formals) <
                                         (FStar_List.length args)
                                     then
                                       let head_type3 =
                                         let uu____7937 =
                                           FStar_TypeChecker_Normalize.normalize_refinement
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
                                           uu____7937
                                          in
                                       let uu____7938 =
                                         curried_arrow_formals_comp
                                           head_type3
                                          in
                                       (match uu____7938 with
                                        | (formals1,c1) ->
                                            (head_type3, formals1, c1))
                                     else (head_type2, formals, c)
                                  in
                               (match uu____7861 with
                                | (head_type2,formals,c) ->
                                    ((let uu____8021 =
                                        FStar_TypeChecker_Env.debug
                                          env.FStar_SMTEncoding_Env.tcenv
                                          (FStar_Options.Other "PartialApp")
                                         in
                                      if uu____8021
                                      then
                                        let uu____8025 =
                                          FStar_Syntax_Print.term_to_string
                                            head_type2
                                           in
                                        let uu____8027 =
                                          FStar_Syntax_Print.binders_to_string
                                            ", " formals
                                           in
                                        let uu____8030 =
                                          FStar_Syntax_Print.args_to_string
                                            args_e
                                           in
                                        FStar_Util.print3
                                          "Encoding partial application, head_type = %s, formals = %s, args = %s\n"
                                          uu____8025 uu____8027 uu____8030
                                      else ());
                                     (match head2.FStar_Syntax_Syntax.n with
                                      | FStar_Syntax_Syntax.Tm_uinst
                                          ({
                                             FStar_Syntax_Syntax.n =
                                               FStar_Syntax_Syntax.Tm_fvar fv;
                                             FStar_Syntax_Syntax.pos =
                                               uu____8040;
                                             FStar_Syntax_Syntax.vars =
                                               uu____8041;_},uu____8042)
                                          when
                                          (FStar_List.length formals) =
                                            (FStar_List.length args)
                                          ->
                                          encode_full_app
                                            fv.FStar_Syntax_Syntax.fv_name
                                      | FStar_Syntax_Syntax.Tm_fvar fv when
                                          (FStar_List.length formals) =
                                            (FStar_List.length args)
                                          ->
                                          encode_full_app
                                            fv.FStar_Syntax_Syntax.fv_name
                                      | uu____8060 ->
                                          if
                                            (FStar_List.length formals) >
                                              (FStar_List.length args)
                                          then
                                            encode_partial_app
                                              (FStar_Pervasives_Native.Some
                                                 (head_type2, formals, c))
                                          else
                                            encode_partial_app
                                              FStar_Pervasives_Native.None)))))))
       | FStar_Syntax_Syntax.Tm_abs (bs,body,lopt) ->
           let uu____8149 = FStar_Syntax_Subst.open_term' bs body  in
           (match uu____8149 with
            | (bs1,body1,opening) ->
                let fallback uu____8172 =
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
                  let uu____8182 =
                    let uu____8183 =
                      FStar_SMTEncoding_Term.mk_fv
                        (f, FStar_SMTEncoding_Term.Term_sort)
                       in
                    FStar_All.pipe_left FStar_SMTEncoding_Util.mkFreeV
                      uu____8183
                     in
                  let uu____8185 =
                    FStar_All.pipe_right [decl]
                      FStar_SMTEncoding_Term.mk_decls_trivial
                     in
                  (uu____8182, uu____8185)  in
                let is_impure rc =
                  let uu____8195 =
                    FStar_TypeChecker_Util.is_pure_or_ghost_effect
                      env.FStar_SMTEncoding_Env.tcenv
                      rc.FStar_Syntax_Syntax.residual_effect
                     in
                  FStar_All.pipe_right uu____8195 Prims.op_Negation  in
                let codomain_eff rc =
                  let res_typ =
                    match rc.FStar_Syntax_Syntax.residual_typ with
                    | FStar_Pervasives_Native.None  ->
                        let uu____8210 =
                          let uu____8223 =
                            FStar_TypeChecker_Env.get_range
                              env.FStar_SMTEncoding_Env.tcenv
                             in
                          FStar_TypeChecker_Util.new_implicit_var
                            "SMTEncoding codomain" uu____8223
                            env.FStar_SMTEncoding_Env.tcenv
                            FStar_Syntax_Util.ktype0
                           in
                        (match uu____8210 with
                         | (t1,uu____8226,uu____8227) -> t1)
                    | FStar_Pervasives_Native.Some t1 -> t1  in
                  let uu____8245 =
                    FStar_Ident.lid_equals
                      rc.FStar_Syntax_Syntax.residual_effect
                      FStar_Parser_Const.effect_Tot_lid
                     in
                  if uu____8245
                  then
                    let uu____8250 = FStar_Syntax_Syntax.mk_Total res_typ  in
                    FStar_Pervasives_Native.Some uu____8250
                  else
                    (let uu____8253 =
                       FStar_Ident.lid_equals
                         rc.FStar_Syntax_Syntax.residual_effect
                         FStar_Parser_Const.effect_GTot_lid
                        in
                     if uu____8253
                     then
                       let uu____8258 = FStar_Syntax_Syntax.mk_GTotal res_typ
                          in
                       FStar_Pervasives_Native.Some uu____8258
                     else FStar_Pervasives_Native.None)
                   in
                (match lopt with
                 | FStar_Pervasives_Native.None  ->
                     ((let uu____8266 =
                         let uu____8272 =
                           let uu____8274 =
                             FStar_Syntax_Print.term_to_string t0  in
                           FStar_Util.format1
                             "Losing precision when encoding a function literal: %s\n(Unnannotated abstraction in the compiler ?)"
                             uu____8274
                            in
                         (FStar_Errors.Warning_FunctionLiteralPrecisionLoss,
                           uu____8272)
                          in
                       FStar_Errors.log_issue t0.FStar_Syntax_Syntax.pos
                         uu____8266);
                      fallback ())
                 | FStar_Pervasives_Native.Some rc ->
                     let uu____8279 =
                       (is_impure rc) &&
                         (let uu____8282 =
                            FStar_TypeChecker_Env.is_reifiable_rc
                              env.FStar_SMTEncoding_Env.tcenv rc
                             in
                          Prims.op_Negation uu____8282)
                        in
                     if uu____8279
                     then fallback ()
                     else
                       (let uu____8291 =
                          encode_binders FStar_Pervasives_Native.None bs1 env
                           in
                        match uu____8291 with
                        | (vars,guards,envbody,decls,uu____8316) ->
                            let body2 =
                              let uu____8330 =
                                FStar_TypeChecker_Env.is_reifiable_rc
                                  env.FStar_SMTEncoding_Env.tcenv rc
                                 in
                              if uu____8330
                              then
                                FStar_TypeChecker_Util.reify_body
                                  env.FStar_SMTEncoding_Env.tcenv body1
                              else body1  in
                            let uu____8335 = encode_term body2 envbody  in
                            (match uu____8335 with
                             | (body3,decls') ->
                                 let uu____8346 =
                                   let uu____8355 = codomain_eff rc  in
                                   match uu____8355 with
                                   | FStar_Pervasives_Native.None  ->
                                       (FStar_Pervasives_Native.None, [])
                                   | FStar_Pervasives_Native.Some c ->
                                       let tfun =
                                         FStar_Syntax_Util.arrow bs1 c  in
                                       let uu____8374 = encode_term tfun env
                                          in
                                       (match uu____8374 with
                                        | (t1,decls1) ->
                                            ((FStar_Pervasives_Native.Some t1),
                                              decls1))
                                    in
                                 (match uu____8346 with
                                  | (arrow_t_opt,decls'') ->
                                      let key_body =
                                        let uu____8408 =
                                          let uu____8419 =
                                            let uu____8420 =
                                              let uu____8425 =
                                                FStar_SMTEncoding_Util.mk_and_l
                                                  guards
                                                 in
                                              (uu____8425, body3)  in
                                            FStar_SMTEncoding_Util.mkImp
                                              uu____8420
                                             in
                                          ([], vars, uu____8419)  in
                                        FStar_SMTEncoding_Term.mkForall
                                          t0.FStar_Syntax_Syntax.pos
                                          uu____8408
                                         in
                                      let cvars =
                                        FStar_SMTEncoding_Term.free_variables
                                          key_body
                                         in
                                      let uu____8433 =
                                        match arrow_t_opt with
                                        | FStar_Pervasives_Native.None  ->
                                            (cvars, key_body)
                                        | FStar_Pervasives_Native.Some t1 ->
                                            let uu____8473 =
                                              let uu____8484 =
                                                let uu____8495 =
                                                  FStar_SMTEncoding_Term.free_variables
                                                    t1
                                                   in
                                                FStar_List.append uu____8495
                                                  cvars
                                                 in
                                              FStar_Util.remove_dups
                                                FStar_SMTEncoding_Term.fv_eq
                                                uu____8484
                                               in
                                            let uu____8522 =
                                              FStar_SMTEncoding_Util.mkAnd
                                                (key_body, t1)
                                               in
                                            (uu____8473, uu____8522)
                                         in
                                      (match uu____8433 with
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
                                           ((let uu____8569 =
                                               FStar_All.pipe_left
                                                 (FStar_TypeChecker_Env.debug
                                                    env.FStar_SMTEncoding_Env.tcenv)
                                                 (FStar_Options.Other
                                                    "PartialApp")
                                                in
                                             if uu____8569
                                             then
                                               let uu____8574 =
                                                 let uu____8576 =
                                                   FStar_List.map
                                                     FStar_SMTEncoding_Term.fv_name
                                                     vars
                                                    in
                                                 FStar_All.pipe_right
                                                   uu____8576
                                                   (FStar_String.concat ", ")
                                                  in
                                               let uu____8586 =
                                                 FStar_SMTEncoding_Term.print_smt_term
                                                   body3
                                                  in
                                               FStar_Util.print2
                                                 "Checking eta expansion of\n\tvars={%s}\n\tbody=%s\n"
                                                 uu____8574 uu____8586
                                             else ());
                                            (let uu____8591 =
                                               is_an_eta_expansion env vars
                                                 body3
                                                in
                                             match uu____8591 with
                                             | FStar_Pervasives_Native.Some
                                                 t1 ->
                                                 ((let uu____8600 =
                                                     FStar_All.pipe_left
                                                       (FStar_TypeChecker_Env.debug
                                                          env.FStar_SMTEncoding_Env.tcenv)
                                                       (FStar_Options.Other
                                                          "PartialApp")
                                                      in
                                                   if uu____8600
                                                   then
                                                     let uu____8605 =
                                                       FStar_SMTEncoding_Term.print_smt_term
                                                         t1
                                                        in
                                                     FStar_Util.print1
                                                       "Yes, is an eta expansion of\n\tcore=%s\n"
                                                       uu____8605
                                                   else ());
                                                  (let decls1 =
                                                     FStar_List.append decls
                                                       (FStar_List.append
                                                          decls' decls'')
                                                      in
                                                   (t1, decls1)))
                                             | FStar_Pervasives_Native.None 
                                                 ->
                                                 let cvar_sorts =
                                                   FStar_List.map
                                                     FStar_SMTEncoding_Term.fv_sort
                                                     cvars1
                                                    in
                                                 let fsym =
                                                   let uu____8626 =
                                                     FStar_Util.digest_of_string
                                                       tkey_hash
                                                      in
                                                   Prims.op_Hat "Tm_abs_"
                                                     uu____8626
                                                    in
                                                 let fdecl =
                                                   FStar_SMTEncoding_Term.DeclFun
                                                     (fsym, cvar_sorts,
                                                       FStar_SMTEncoding_Term.Term_sort,
                                                       FStar_Pervasives_Native.None)
                                                    in
                                                 let f =
                                                   let uu____8635 =
                                                     let uu____8643 =
                                                       FStar_List.map
                                                         FStar_SMTEncoding_Util.mkFreeV
                                                         cvars1
                                                        in
                                                     (fsym, uu____8643)  in
                                                   FStar_SMTEncoding_Util.mkApp
                                                     uu____8635
                                                    in
                                                 let app = mk_Apply f vars
                                                    in
                                                 let typing_f =
                                                   match arrow_t_opt with
                                                   | FStar_Pervasives_Native.None
                                                        -> []
                                                   | FStar_Pervasives_Native.Some
                                                       t1 ->
                                                       let f_has_t =
                                                         FStar_SMTEncoding_Term.mk_HasTypeWithFuel
                                                           FStar_Pervasives_Native.None
                                                           f t1
                                                          in
                                                       let a_name =
                                                         Prims.op_Hat
                                                           "typing_" fsym
                                                          in
                                                       let uu____8660 =
                                                         let uu____8661 =
                                                           let uu____8669 =
                                                             FStar_SMTEncoding_Term.mkForall
                                                               t0.FStar_Syntax_Syntax.pos
                                                               ([[f]],
                                                                 cvars1,
                                                                 f_has_t)
                                                              in
                                                           (uu____8669,
                                                             (FStar_Pervasives_Native.Some
                                                                a_name),
                                                             a_name)
                                                            in
                                                         FStar_SMTEncoding_Util.mkAssume
                                                           uu____8661
                                                          in
                                                       [uu____8660]
                                                    in
                                                 let interp_f =
                                                   let a_name =
                                                     Prims.op_Hat
                                                       "interpretation_" fsym
                                                      in
                                                   let uu____8684 =
                                                     let uu____8692 =
                                                       let uu____8693 =
                                                         let uu____8704 =
                                                           FStar_SMTEncoding_Util.mkEq
                                                             (app, body3)
                                                            in
                                                         ([[app]],
                                                           (FStar_List.append
                                                              vars cvars1),
                                                           uu____8704)
                                                          in
                                                       FStar_SMTEncoding_Term.mkForall
                                                         t0.FStar_Syntax_Syntax.pos
                                                         uu____8693
                                                        in
                                                     (uu____8692,
                                                       (FStar_Pervasives_Native.Some
                                                          a_name), a_name)
                                                      in
                                                   FStar_SMTEncoding_Util.mkAssume
                                                     uu____8684
                                                    in
                                                 let f_decls =
                                                   FStar_List.append (fdecl
                                                     :: typing_f) [interp_f]
                                                    in
                                                 let uu____8718 =
                                                   let uu____8719 =
                                                     let uu____8722 =
                                                       let uu____8725 =
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
                                                         decls'' uu____8725
                                                        in
                                                     FStar_List.append decls'
                                                       uu____8722
                                                      in
                                                   FStar_List.append decls
                                                     uu____8719
                                                    in
                                                 (f, uu____8718)))))))))
       | FStar_Syntax_Syntax.Tm_let
           ((uu____8728,{
                          FStar_Syntax_Syntax.lbname = FStar_Util.Inr
                            uu____8729;
                          FStar_Syntax_Syntax.lbunivs = uu____8730;
                          FStar_Syntax_Syntax.lbtyp = uu____8731;
                          FStar_Syntax_Syntax.lbeff = uu____8732;
                          FStar_Syntax_Syntax.lbdef = uu____8733;
                          FStar_Syntax_Syntax.lbattrs = uu____8734;
                          FStar_Syntax_Syntax.lbpos = uu____8735;_}::uu____8736),uu____8737)
           -> failwith "Impossible: already handled by encoding of Sig_let"
       | FStar_Syntax_Syntax.Tm_let
           ((false
             ,{ FStar_Syntax_Syntax.lbname = FStar_Util.Inl x;
                FStar_Syntax_Syntax.lbunivs = uu____8771;
                FStar_Syntax_Syntax.lbtyp = t1;
                FStar_Syntax_Syntax.lbeff = uu____8773;
                FStar_Syntax_Syntax.lbdef = e1;
                FStar_Syntax_Syntax.lbattrs = uu____8775;
                FStar_Syntax_Syntax.lbpos = uu____8776;_}::[]),e2)
           -> encode_let x t1 e1 e2 env encode_term
       | FStar_Syntax_Syntax.Tm_let uu____8803 ->
           (FStar_Errors.diag t0.FStar_Syntax_Syntax.pos
              "Non-top-level recursive functions, and their enclosings let bindings (including the top-level let) are not yet fully encoded to the SMT solver; you may not be able to prove some facts";
            FStar_Exn.raise FStar_SMTEncoding_Env.Inner_let_rec)
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
              let uu____8875 =
                let uu____8880 =
                  FStar_Syntax_Util.ascribe e1
                    ((FStar_Util.Inl t1), FStar_Pervasives_Native.None)
                   in
                encode_term uu____8880 env  in
              match uu____8875 with
              | (ee1,decls1) ->
                  let uu____8905 =
                    FStar_Syntax_Subst.open_term
                      [(x, FStar_Pervasives_Native.None)] e2
                     in
                  (match uu____8905 with
                   | (xs,e21) ->
                       let uu____8930 = FStar_List.hd xs  in
                       (match uu____8930 with
                        | (x1,uu____8948) ->
                            let env' =
                              FStar_SMTEncoding_Env.push_term_var env x1 ee1
                               in
                            let uu____8954 = encode_body e21 env'  in
                            (match uu____8954 with
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
            let uu____8984 =
              let uu____8992 =
                let uu____8993 =
                  FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown
                    FStar_Pervasives_Native.None FStar_Range.dummyRange
                   in
                FStar_Syntax_Syntax.null_bv uu____8993  in
              FStar_SMTEncoding_Env.gen_term_var env uu____8992  in
            match uu____8984 with
            | (scrsym,scr',env1) ->
                let uu____9003 = encode_term e env1  in
                (match uu____9003 with
                 | (scr,decls) ->
                     let uu____9014 =
                       let encode_branch b uu____9043 =
                         match uu____9043 with
                         | (else_case,decls1) ->
                             let uu____9062 =
                               FStar_Syntax_Subst.open_branch b  in
                             (match uu____9062 with
                              | (p,w,br) ->
                                  let uu____9088 = encode_pat env1 p  in
                                  (match uu____9088 with
                                   | (env0,pattern) ->
                                       let guard = pattern.guard scr'  in
                                       let projections =
                                         pattern.projections scr'  in
                                       let env2 =
                                         FStar_All.pipe_right projections
                                           (FStar_List.fold_left
                                              (fun env2  ->
                                                 fun uu____9125  ->
                                                   match uu____9125 with
                                                   | (x,t) ->
                                                       FStar_SMTEncoding_Env.push_term_var
                                                         env2 x t) env1)
                                          in
                                       let uu____9132 =
                                         match w with
                                         | FStar_Pervasives_Native.None  ->
                                             (guard, [])
                                         | FStar_Pervasives_Native.Some w1 ->
                                             let uu____9154 =
                                               encode_term w1 env2  in
                                             (match uu____9154 with
                                              | (w2,decls2) ->
                                                  let uu____9167 =
                                                    let uu____9168 =
                                                      let uu____9173 =
                                                        let uu____9174 =
                                                          let uu____9179 =
                                                            FStar_SMTEncoding_Term.boxBool
                                                              FStar_SMTEncoding_Util.mkTrue
                                                             in
                                                          (w2, uu____9179)
                                                           in
                                                        FStar_SMTEncoding_Util.mkEq
                                                          uu____9174
                                                         in
                                                      (guard, uu____9173)  in
                                                    FStar_SMTEncoding_Util.mkAnd
                                                      uu____9168
                                                     in
                                                  (uu____9167, decls2))
                                          in
                                       (match uu____9132 with
                                        | (guard1,decls2) ->
                                            let uu____9194 =
                                              encode_br br env2  in
                                            (match uu____9194 with
                                             | (br1,decls3) ->
                                                 let uu____9207 =
                                                   FStar_SMTEncoding_Util.mkITE
                                                     (guard1, br1, else_case)
                                                    in
                                                 (uu____9207,
                                                   (FStar_List.append decls1
                                                      (FStar_List.append
                                                         decls2 decls3)))))))
                          in
                       FStar_List.fold_right encode_branch pats
                         (default_case, decls)
                        in
                     (match uu____9014 with
                      | (match_tm,decls1) ->
                          let uu____9228 =
                            let uu____9229 =
                              let uu____9240 =
                                let uu____9247 =
                                  let uu____9252 =
                                    FStar_SMTEncoding_Term.mk_fv
                                      (scrsym,
                                        FStar_SMTEncoding_Term.Term_sort)
                                     in
                                  (uu____9252, scr)  in
                                [uu____9247]  in
                              (uu____9240, match_tm)  in
                            FStar_SMTEncoding_Term.mkLet' uu____9229
                              FStar_Range.dummyRange
                             in
                          (uu____9228, decls1)))

and (encode_pat :
  FStar_SMTEncoding_Env.env_t ->
    FStar_Syntax_Syntax.pat -> (FStar_SMTEncoding_Env.env_t * pattern))
  =
  fun env  ->
    fun pat  ->
      (let uu____9275 =
         FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv
           FStar_Options.Medium
          in
       if uu____9275
       then
         let uu____9278 = FStar_Syntax_Print.pat_to_string pat  in
         FStar_Util.print1 "Encoding pattern %s\n" uu____9278
       else ());
      (let uu____9283 = FStar_TypeChecker_Util.decorated_pattern_as_term pat
          in
       match uu____9283 with
       | (vars,pat_term) ->
           let uu____9300 =
             FStar_All.pipe_right vars
               (FStar_List.fold_left
                  (fun uu____9342  ->
                     fun v1  ->
                       match uu____9342 with
                       | (env1,vars1) ->
                           let uu____9378 =
                             FStar_SMTEncoding_Env.gen_term_var env1 v1  in
                           (match uu____9378 with
                            | (xx,uu____9397,env2) ->
                                let uu____9401 =
                                  let uu____9408 =
                                    let uu____9413 =
                                      FStar_SMTEncoding_Term.mk_fv
                                        (xx,
                                          FStar_SMTEncoding_Term.Term_sort)
                                       in
                                    (v1, uu____9413)  in
                                  uu____9408 :: vars1  in
                                (env2, uu____9401))) (env, []))
              in
           (match uu____9300 with
            | (env1,vars1) ->
                let rec mk_guard pat1 scrutinee =
                  match pat1.FStar_Syntax_Syntax.v with
                  | FStar_Syntax_Syntax.Pat_var uu____9468 ->
                      FStar_SMTEncoding_Util.mkTrue
                  | FStar_Syntax_Syntax.Pat_wild uu____9469 ->
                      FStar_SMTEncoding_Util.mkTrue
                  | FStar_Syntax_Syntax.Pat_dot_term uu____9470 ->
                      FStar_SMTEncoding_Util.mkTrue
                  | FStar_Syntax_Syntax.Pat_constant c ->
                      let uu____9478 = encode_const c env1  in
                      (match uu____9478 with
                       | (tm,decls) ->
                           ((match decls with
                             | uu____9486::uu____9487 ->
                                 failwith
                                   "Unexpected encoding of constant pattern"
                             | uu____9491 -> ());
                            FStar_SMTEncoding_Util.mkEq (scrutinee, tm)))
                  | FStar_Syntax_Syntax.Pat_cons (f,args) ->
                      let is_f =
                        let tc_name =
                          FStar_TypeChecker_Env.typ_of_datacon
                            env1.FStar_SMTEncoding_Env.tcenv
                            (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                           in
                        let uu____9514 =
                          FStar_TypeChecker_Env.datacons_of_typ
                            env1.FStar_SMTEncoding_Env.tcenv tc_name
                           in
                        match uu____9514 with
                        | (uu____9522,uu____9523::[]) ->
                            FStar_SMTEncoding_Util.mkTrue
                        | uu____9528 ->
                            FStar_SMTEncoding_Env.mk_data_tester env1
                              (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                              scrutinee
                         in
                      let sub_term_guards =
                        FStar_All.pipe_right args
                          (FStar_List.mapi
                             (fun i  ->
                                fun uu____9564  ->
                                  match uu____9564 with
                                  | (arg,uu____9574) ->
                                      let proj =
                                        FStar_SMTEncoding_Env.primitive_projector_by_pos
                                          env1.FStar_SMTEncoding_Env.tcenv
                                          (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                          i
                                         in
                                      let uu____9583 =
                                        FStar_SMTEncoding_Util.mkApp
                                          (proj, [scrutinee])
                                         in
                                      mk_guard arg uu____9583))
                         in
                      FStar_SMTEncoding_Util.mk_and_l (is_f ::
                        sub_term_guards)
                   in
                let rec mk_projections pat1 scrutinee =
                  match pat1.FStar_Syntax_Syntax.v with
                  | FStar_Syntax_Syntax.Pat_dot_term (x,uu____9615) ->
                      [(x, scrutinee)]
                  | FStar_Syntax_Syntax.Pat_var x -> [(x, scrutinee)]
                  | FStar_Syntax_Syntax.Pat_wild x -> [(x, scrutinee)]
                  | FStar_Syntax_Syntax.Pat_constant uu____9646 -> []
                  | FStar_Syntax_Syntax.Pat_cons (f,args) ->
                      let uu____9671 =
                        FStar_All.pipe_right args
                          (FStar_List.mapi
                             (fun i  ->
                                fun uu____9717  ->
                                  match uu____9717 with
                                  | (arg,uu____9733) ->
                                      let proj =
                                        FStar_SMTEncoding_Env.primitive_projector_by_pos
                                          env1.FStar_SMTEncoding_Env.tcenv
                                          (f.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                          i
                                         in
                                      let uu____9742 =
                                        FStar_SMTEncoding_Util.mkApp
                                          (proj, [scrutinee])
                                         in
                                      mk_projections arg uu____9742))
                         in
                      FStar_All.pipe_right uu____9671 FStar_List.flatten
                   in
                let pat_term1 uu____9773 = encode_term pat_term env1  in
                let pattern =
                  {
                    pat_vars = vars1;
                    pat_term = pat_term1;
                    guard = (mk_guard pat);
                    projections = (mk_projections pat)
                  }  in
                (env1, pattern)))

and (encode_args :
  FStar_Syntax_Syntax.args ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term Prims.list *
        FStar_SMTEncoding_Term.decls_t))
  =
  fun l  ->
    fun env  ->
      let uu____9783 =
        FStar_All.pipe_right l
          (FStar_List.fold_left
             (fun uu____9831  ->
                fun uu____9832  ->
                  match (uu____9831, uu____9832) with
                  | ((tms,decls),(t,uu____9872)) ->
                      let uu____9899 = encode_term t env  in
                      (match uu____9899 with
                       | (t1,decls') ->
                           ((t1 :: tms), (FStar_List.append decls decls'))))
             ([], []))
         in
      match uu____9783 with | (l1,decls) -> ((FStar_List.rev l1), decls)

and (encode_function_type_as_formula :
  FStar_Syntax_Syntax.typ ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun t  ->
    fun env  ->
      let universe_of_binders binders =
        FStar_List.map (fun uu____9977  -> FStar_Syntax_Syntax.U_zero)
          binders
         in
      let quant = FStar_Syntax_Util.smt_lemma_as_forall t universe_of_binders
         in
      let env1 =
        let uu___1332_9986 = env  in
        {
          FStar_SMTEncoding_Env.bvar_bindings =
            (uu___1332_9986.FStar_SMTEncoding_Env.bvar_bindings);
          FStar_SMTEncoding_Env.fvar_bindings =
            (uu___1332_9986.FStar_SMTEncoding_Env.fvar_bindings);
          FStar_SMTEncoding_Env.depth =
            (uu___1332_9986.FStar_SMTEncoding_Env.depth);
          FStar_SMTEncoding_Env.tcenv =
            (uu___1332_9986.FStar_SMTEncoding_Env.tcenv);
          FStar_SMTEncoding_Env.warn =
            (uu___1332_9986.FStar_SMTEncoding_Env.warn);
          FStar_SMTEncoding_Env.nolabels =
            (uu___1332_9986.FStar_SMTEncoding_Env.nolabels);
          FStar_SMTEncoding_Env.use_zfuel_name = true;
          FStar_SMTEncoding_Env.encode_non_total_function_typ =
            (uu___1332_9986.FStar_SMTEncoding_Env.encode_non_total_function_typ);
          FStar_SMTEncoding_Env.current_module_name =
            (uu___1332_9986.FStar_SMTEncoding_Env.current_module_name);
          FStar_SMTEncoding_Env.encoding_quantifier =
            (uu___1332_9986.FStar_SMTEncoding_Env.encoding_quantifier);
          FStar_SMTEncoding_Env.global_cache =
            (uu___1332_9986.FStar_SMTEncoding_Env.global_cache)
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
        let uu___1337_10003 = env  in
        {
          FStar_SMTEncoding_Env.bvar_bindings =
            (uu___1337_10003.FStar_SMTEncoding_Env.bvar_bindings);
          FStar_SMTEncoding_Env.fvar_bindings =
            (uu___1337_10003.FStar_SMTEncoding_Env.fvar_bindings);
          FStar_SMTEncoding_Env.depth =
            (uu___1337_10003.FStar_SMTEncoding_Env.depth);
          FStar_SMTEncoding_Env.tcenv =
            (uu___1337_10003.FStar_SMTEncoding_Env.tcenv);
          FStar_SMTEncoding_Env.warn =
            (uu___1337_10003.FStar_SMTEncoding_Env.warn);
          FStar_SMTEncoding_Env.nolabels =
            (uu___1337_10003.FStar_SMTEncoding_Env.nolabels);
          FStar_SMTEncoding_Env.use_zfuel_name = true;
          FStar_SMTEncoding_Env.encode_non_total_function_typ =
            (uu___1337_10003.FStar_SMTEncoding_Env.encode_non_total_function_typ);
          FStar_SMTEncoding_Env.current_module_name =
            (uu___1337_10003.FStar_SMTEncoding_Env.current_module_name);
          FStar_SMTEncoding_Env.encoding_quantifier =
            (uu___1337_10003.FStar_SMTEncoding_Env.encoding_quantifier);
          FStar_SMTEncoding_Env.global_cache =
            (uu___1337_10003.FStar_SMTEncoding_Env.global_cache)
        }  in
      let encode_smt_pattern t =
        let uu____10019 = FStar_Syntax_Util.head_and_args t  in
        match uu____10019 with
        | (head1,args) ->
            let head2 = FStar_Syntax_Util.un_uinst head1  in
            (match ((head2.FStar_Syntax_Syntax.n), args) with
             | (FStar_Syntax_Syntax.Tm_fvar
                fv,uu____10082::(x,uu____10084)::(t1,uu____10086)::[]) when
                 FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.has_type_lid
                 ->
                 let uu____10153 = encode_term x env1  in
                 (match uu____10153 with
                  | (x1,decls) ->
                      let uu____10164 = encode_term t1 env1  in
                      (match uu____10164 with
                       | (t2,decls') ->
                           let uu____10175 =
                             FStar_SMTEncoding_Term.mk_HasType x1 t2  in
                           (uu____10175, (FStar_List.append decls decls'))))
             | uu____10176 -> encode_term t env1)
         in
      FStar_List.fold_right
        (fun pats  ->
           fun uu____10219  ->
             match uu____10219 with
             | (pats_l1,decls) ->
                 let uu____10264 =
                   FStar_List.fold_right
                     (fun uu____10299  ->
                        fun uu____10300  ->
                          match (uu____10299, uu____10300) with
                          | ((p,uu____10342),(pats1,decls1)) ->
                              let uu____10377 = encode_smt_pattern p  in
                              (match uu____10377 with
                               | (t,d) ->
                                   let uu____10392 =
                                     FStar_SMTEncoding_Term.check_pattern_ok
                                       t
                                      in
                                   (match uu____10392 with
                                    | FStar_Pervasives_Native.None  ->
                                        ((t :: pats1),
                                          (FStar_List.append d decls1))
                                    | FStar_Pervasives_Native.Some
                                        illegal_subterm ->
                                        ((let uu____10409 =
                                            let uu____10415 =
                                              let uu____10417 =
                                                FStar_Syntax_Print.term_to_string
                                                  p
                                                 in
                                              let uu____10419 =
                                                FStar_SMTEncoding_Term.print_smt_term
                                                  illegal_subterm
                                                 in
                                              FStar_Util.format2
                                                "Pattern %s contains illegal sub-term (%s); dropping it"
                                                uu____10417 uu____10419
                                               in
                                            (FStar_Errors.Warning_SMTPatternIllFormed,
                                              uu____10415)
                                             in
                                          FStar_Errors.log_issue
                                            p.FStar_Syntax_Syntax.pos
                                            uu____10409);
                                         (pats1,
                                           (FStar_List.append d decls1))))))
                     pats ([], decls)
                    in
                 (match uu____10264 with
                  | (pats1,decls1) -> ((pats1 :: pats_l1), decls1))) pats_l
        ([], [])

and (encode_formula :
  FStar_Syntax_Syntax.typ ->
    FStar_SMTEncoding_Env.env_t ->
      (FStar_SMTEncoding_Term.term * FStar_SMTEncoding_Term.decls_t))
  =
  fun phi  ->
    fun env  ->
      let debug1 phi1 =
        let uu____10479 =
          FStar_All.pipe_left
            (FStar_TypeChecker_Env.debug env.FStar_SMTEncoding_Env.tcenv)
            (FStar_Options.Other "SMTEncoding")
           in
        if uu____10479
        then
          let uu____10484 = FStar_Syntax_Print.tag_of_term phi1  in
          let uu____10486 = FStar_Syntax_Print.term_to_string phi1  in
          FStar_Util.print2 "Formula (%s)  %s\n" uu____10484 uu____10486
        else ()  in
      let enc f r l =
        let uu____10528 =
          FStar_Util.fold_map
            (fun decls  ->
               fun x  ->
                 let uu____10560 =
                   encode_term (FStar_Pervasives_Native.fst x) env  in
                 match uu____10560 with
                 | (t,decls') -> ((FStar_List.append decls decls'), t)) [] l
           in
        match uu____10528 with
        | (decls,args) ->
            let uu____10591 =
              let uu___1401_10592 = f args  in
              {
                FStar_SMTEncoding_Term.tm =
                  (uu___1401_10592.FStar_SMTEncoding_Term.tm);
                FStar_SMTEncoding_Term.freevars =
                  (uu___1401_10592.FStar_SMTEncoding_Term.freevars);
                FStar_SMTEncoding_Term.rng = r
              }  in
            (uu____10591, decls)
         in
      let const_op f r uu____10627 =
        let uu____10640 = f r  in (uu____10640, [])  in
      let un_op f l =
        let uu____10663 = FStar_List.hd l  in
        FStar_All.pipe_left f uu____10663  in
      let bin_op f uu___2_10683 =
        match uu___2_10683 with
        | t1::t2::[] -> f (t1, t2)
        | uu____10694 -> failwith "Impossible"  in
      let enc_prop_c f r l =
        let uu____10735 =
          FStar_Util.fold_map
            (fun decls  ->
               fun uu____10760  ->
                 match uu____10760 with
                 | (t,uu____10776) ->
                     let uu____10781 = encode_formula t env  in
                     (match uu____10781 with
                      | (phi1,decls') ->
                          ((FStar_List.append decls decls'), phi1))) [] l
           in
        match uu____10735 with
        | (decls,phis) ->
            let uu____10810 =
              let uu___1431_10811 = f phis  in
              {
                FStar_SMTEncoding_Term.tm =
                  (uu___1431_10811.FStar_SMTEncoding_Term.tm);
                FStar_SMTEncoding_Term.freevars =
                  (uu___1431_10811.FStar_SMTEncoding_Term.freevars);
                FStar_SMTEncoding_Term.rng = r
              }  in
            (uu____10810, decls)
         in
      let eq_op r args =
        let rf =
          FStar_List.filter
            (fun uu____10874  ->
               match uu____10874 with
               | (a,q) ->
                   (match q with
                    | FStar_Pervasives_Native.Some
                        (FStar_Syntax_Syntax.Implicit uu____10895) -> false
                    | uu____10898 -> true)) args
           in
        if (FStar_List.length rf) <> (Prims.parse_int "2")
        then
          let uu____10917 =
            FStar_Util.format1
              "eq_op: got %s non-implicit arguments instead of 2?"
              (Prims.string_of_int (FStar_List.length rf))
             in
          failwith uu____10917
        else
          (let uu____10934 = enc (bin_op FStar_SMTEncoding_Util.mkEq)  in
           uu____10934 r rf)
         in
      let eq3_op r args =
        let n1 = FStar_List.length args  in
        if n1 = (Prims.parse_int "4")
        then
          let uu____11002 =
            enc
              (fun terms  ->
                 match terms with
                 | t0::t1::v0::v1::[] ->
                     let uu____11034 =
                       let uu____11039 = FStar_SMTEncoding_Util.mkEq (t0, t1)
                          in
                       let uu____11040 = FStar_SMTEncoding_Util.mkEq (v0, v1)
                          in
                       (uu____11039, uu____11040)  in
                     FStar_SMTEncoding_Util.mkAnd uu____11034
                 | uu____11041 -> failwith "Impossible")
             in
          uu____11002 r args
        else
          (let uu____11047 =
             FStar_Util.format1
               "eq3_op: got %s non-implicit arguments instead of 4?"
               (Prims.string_of_int n1)
              in
           failwith uu____11047)
         in
      let h_equals_op r args =
        let n1 = FStar_List.length args  in
        if n1 = (Prims.parse_int "4")
        then
          let uu____11109 =
            enc
              (fun terms  ->
                 match terms with
                 | t0::v0::t1::v1::[] ->
                     let uu____11141 =
                       let uu____11146 = FStar_SMTEncoding_Util.mkEq (t0, t1)
                          in
                       let uu____11147 = FStar_SMTEncoding_Util.mkEq (v0, v1)
                          in
                       (uu____11146, uu____11147)  in
                     FStar_SMTEncoding_Util.mkAnd uu____11141
                 | uu____11148 -> failwith "Impossible")
             in
          uu____11109 r args
        else
          (let uu____11154 =
             FStar_Util.format1
               "eq3_op: got %s non-implicit arguments instead of 4?"
               (Prims.string_of_int n1)
              in
           failwith uu____11154)
         in
      let mk_imp1 r uu___3_11183 =
        match uu___3_11183 with
        | (lhs,uu____11189)::(rhs,uu____11191)::[] ->
            let uu____11232 = encode_formula rhs env  in
            (match uu____11232 with
             | (l1,decls1) ->
                 (match l1.FStar_SMTEncoding_Term.tm with
                  | FStar_SMTEncoding_Term.App
                      (FStar_SMTEncoding_Term.TrueOp ,uu____11247) ->
                      (l1, decls1)
                  | uu____11252 ->
                      let uu____11253 = encode_formula lhs env  in
                      (match uu____11253 with
                       | (l2,decls2) ->
                           let uu____11264 =
                             FStar_SMTEncoding_Term.mkImp (l2, l1) r  in
                           (uu____11264, (FStar_List.append decls1 decls2)))))
        | uu____11265 -> failwith "impossible"  in
      let mk_ite r uu___4_11293 =
        match uu___4_11293 with
        | (guard,uu____11299)::(_then,uu____11301)::(_else,uu____11303)::[]
            ->
            let uu____11360 = encode_formula guard env  in
            (match uu____11360 with
             | (g,decls1) ->
                 let uu____11371 = encode_formula _then env  in
                 (match uu____11371 with
                  | (t,decls2) ->
                      let uu____11382 = encode_formula _else env  in
                      (match uu____11382 with
                       | (e,decls3) ->
                           let res = FStar_SMTEncoding_Term.mkITE (g, t, e) r
                              in
                           (res,
                             (FStar_List.append decls1
                                (FStar_List.append decls2 decls3))))))
        | uu____11394 -> failwith "impossible"  in
      let unboxInt_l f l =
        let uu____11424 = FStar_List.map FStar_SMTEncoding_Term.unboxInt l
           in
        f uu____11424  in
      let connectives =
        let uu____11454 =
          let uu____11479 = enc_prop_c (bin_op FStar_SMTEncoding_Util.mkAnd)
             in
          (FStar_Parser_Const.and_lid, uu____11479)  in
        let uu____11522 =
          let uu____11549 =
            let uu____11574 = enc_prop_c (bin_op FStar_SMTEncoding_Util.mkOr)
               in
            (FStar_Parser_Const.or_lid, uu____11574)  in
          let uu____11617 =
            let uu____11644 =
              let uu____11671 =
                let uu____11696 =
                  enc_prop_c (bin_op FStar_SMTEncoding_Util.mkIff)  in
                (FStar_Parser_Const.iff_lid, uu____11696)  in
              let uu____11739 =
                let uu____11766 =
                  let uu____11793 =
                    let uu____11818 =
                      enc_prop_c (un_op FStar_SMTEncoding_Util.mkNot)  in
                    (FStar_Parser_Const.not_lid, uu____11818)  in
                  [uu____11793;
                  (FStar_Parser_Const.eq2_lid, eq_op);
                  (FStar_Parser_Const.c_eq2_lid, eq_op);
                  (FStar_Parser_Const.eq3_lid, eq3_op);
                  (FStar_Parser_Const.c_eq3_lid, h_equals_op);
                  (FStar_Parser_Const.true_lid,
                    (const_op FStar_SMTEncoding_Term.mkTrue));
                  (FStar_Parser_Const.false_lid,
                    (const_op FStar_SMTEncoding_Term.mkFalse))]
                   in
                (FStar_Parser_Const.ite_lid, mk_ite) :: uu____11766  in
              uu____11671 :: uu____11739  in
            (FStar_Parser_Const.imp_lid, mk_imp1) :: uu____11644  in
          uu____11549 :: uu____11617  in
        uu____11454 :: uu____11522  in
      let rec fallback phi1 =
        match phi1.FStar_Syntax_Syntax.n with
        | FStar_Syntax_Syntax.Tm_meta
            (phi',FStar_Syntax_Syntax.Meta_labeled (msg,r,b)) ->
            let uu____12363 = encode_formula phi' env  in
            (match uu____12363 with
             | (phi2,decls) ->
                 let uu____12374 =
                   FStar_SMTEncoding_Term.mk
                     (FStar_SMTEncoding_Term.Labeled (phi2, msg, r)) r
                    in
                 (uu____12374, decls))
        | FStar_Syntax_Syntax.Tm_meta uu____12376 ->
            let uu____12383 = FStar_Syntax_Util.unmeta phi1  in
            encode_formula uu____12383 env
        | FStar_Syntax_Syntax.Tm_match (e,pats) ->
            let uu____12422 =
              encode_match e pats FStar_SMTEncoding_Util.mkFalse env
                encode_formula
               in
            (match uu____12422 with | (t,decls) -> (t, decls))
        | FStar_Syntax_Syntax.Tm_let
            ((false
              ,{ FStar_Syntax_Syntax.lbname = FStar_Util.Inl x;
                 FStar_Syntax_Syntax.lbunivs = uu____12434;
                 FStar_Syntax_Syntax.lbtyp = t1;
                 FStar_Syntax_Syntax.lbeff = uu____12436;
                 FStar_Syntax_Syntax.lbdef = e1;
                 FStar_Syntax_Syntax.lbattrs = uu____12438;
                 FStar_Syntax_Syntax.lbpos = uu____12439;_}::[]),e2)
            ->
            let uu____12466 = encode_let x t1 e1 e2 env encode_formula  in
            (match uu____12466 with | (t,decls) -> (t, decls))
        | FStar_Syntax_Syntax.Tm_app (head1,args) ->
            let head2 = FStar_Syntax_Util.un_uinst head1  in
            (match ((head2.FStar_Syntax_Syntax.n), args) with
             | (FStar_Syntax_Syntax.Tm_fvar
                fv,uu____12519::(x,uu____12521)::(t,uu____12523)::[]) when
                 FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.has_type_lid
                 ->
                 let uu____12590 = encode_term x env  in
                 (match uu____12590 with
                  | (x1,decls) ->
                      let uu____12601 = encode_term t env  in
                      (match uu____12601 with
                       | (t1,decls') ->
                           let uu____12612 =
                             FStar_SMTEncoding_Term.mk_HasType x1 t1  in
                           (uu____12612, (FStar_List.append decls decls'))))
             | (FStar_Syntax_Syntax.Tm_fvar
                fv,(r,uu____12615)::(msg,uu____12617)::(phi2,uu____12619)::[])
                 when
                 FStar_Syntax_Syntax.fv_eq_lid fv
                   FStar_Parser_Const.labeled_lid
                 ->
                 let uu____12686 =
                   let uu____12691 =
                     let uu____12692 = FStar_Syntax_Subst.compress r  in
                     uu____12692.FStar_Syntax_Syntax.n  in
                   let uu____12695 =
                     let uu____12696 = FStar_Syntax_Subst.compress msg  in
                     uu____12696.FStar_Syntax_Syntax.n  in
                   (uu____12691, uu____12695)  in
                 (match uu____12686 with
                  | (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_range
                     r1),FStar_Syntax_Syntax.Tm_constant
                     (FStar_Const.Const_string (s,uu____12705))) ->
                      let phi3 =
                        FStar_Syntax_Syntax.mk
                          (FStar_Syntax_Syntax.Tm_meta
                             (phi2,
                               (FStar_Syntax_Syntax.Meta_labeled
                                  (s, r1, false))))
                          FStar_Pervasives_Native.None r1
                         in
                      fallback phi3
                  | uu____12716 -> fallback phi2)
             | (FStar_Syntax_Syntax.Tm_fvar fv,(t,uu____12723)::[]) when
                 (FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.squash_lid)
                   ||
                   (FStar_Syntax_Syntax.fv_eq_lid fv
                      FStar_Parser_Const.auto_squash_lid)
                 -> encode_formula t env
             | uu____12758 when head_redex env head2 ->
                 let uu____12773 = whnf env phi1  in
                 encode_formula uu____12773 env
             | uu____12774 ->
                 let uu____12789 = encode_term phi1 env  in
                 (match uu____12789 with
                  | (tt,decls) ->
                      let tt1 =
                        let uu____12801 =
                          let uu____12803 =
                            FStar_Range.use_range
                              tt.FStar_SMTEncoding_Term.rng
                             in
                          let uu____12804 =
                            FStar_Range.use_range
                              phi1.FStar_Syntax_Syntax.pos
                             in
                          FStar_Range.rng_included uu____12803 uu____12804
                           in
                        if uu____12801
                        then tt
                        else
                          (let uu___1618_12808 = tt  in
                           {
                             FStar_SMTEncoding_Term.tm =
                               (uu___1618_12808.FStar_SMTEncoding_Term.tm);
                             FStar_SMTEncoding_Term.freevars =
                               (uu___1618_12808.FStar_SMTEncoding_Term.freevars);
                             FStar_SMTEncoding_Term.rng =
                               (phi1.FStar_Syntax_Syntax.pos)
                           })
                         in
                      let uu____12809 = FStar_SMTEncoding_Term.mk_Valid tt1
                         in
                      (uu____12809, decls)))
        | uu____12810 ->
            let uu____12811 = encode_term phi1 env  in
            (match uu____12811 with
             | (tt,decls) ->
                 let tt1 =
                   let uu____12823 =
                     let uu____12825 =
                       FStar_Range.use_range tt.FStar_SMTEncoding_Term.rng
                        in
                     let uu____12826 =
                       FStar_Range.use_range phi1.FStar_Syntax_Syntax.pos  in
                     FStar_Range.rng_included uu____12825 uu____12826  in
                   if uu____12823
                   then tt
                   else
                     (let uu___1626_12830 = tt  in
                      {
                        FStar_SMTEncoding_Term.tm =
                          (uu___1626_12830.FStar_SMTEncoding_Term.tm);
                        FStar_SMTEncoding_Term.freevars =
                          (uu___1626_12830.FStar_SMTEncoding_Term.freevars);
                        FStar_SMTEncoding_Term.rng =
                          (phi1.FStar_Syntax_Syntax.pos)
                      })
                    in
                 let uu____12831 = FStar_SMTEncoding_Term.mk_Valid tt1  in
                 (uu____12831, decls))
         in
      let encode_q_body env1 bs ps body =
        let uu____12875 = encode_binders FStar_Pervasives_Native.None bs env1
           in
        match uu____12875 with
        | (vars,guards,env2,decls,uu____12914) ->
            let uu____12927 = encode_smt_patterns ps env2  in
            (match uu____12927 with
             | (pats,decls') ->
                 let uu____12964 = encode_formula body env2  in
                 (match uu____12964 with
                  | (body1,decls'') ->
                      let guards1 =
                        match pats with
                        | ({
                             FStar_SMTEncoding_Term.tm =
                               FStar_SMTEncoding_Term.App
                               (FStar_SMTEncoding_Term.Var gf,p::[]);
                             FStar_SMTEncoding_Term.freevars = uu____12996;
                             FStar_SMTEncoding_Term.rng = uu____12997;_}::[])::[]
                            when
                            let uu____13017 =
                              FStar_Ident.text_of_lid
                                FStar_Parser_Const.guard_free
                               in
                            uu____13017 = gf -> []
                        | uu____13020 -> guards  in
                      let uu____13025 =
                        FStar_SMTEncoding_Util.mk_and_l guards1  in
                      (vars, pats, uu____13025, body1,
                        (FStar_List.append decls
                           (FStar_List.append decls' decls'')))))
         in
      debug1 phi;
      (let phi1 = FStar_Syntax_Util.unascribe phi  in
       let uu____13036 = FStar_Syntax_Util.destruct_typ_as_formula phi1  in
       match uu____13036 with
       | FStar_Pervasives_Native.None  -> fallback phi1
       | FStar_Pervasives_Native.Some (FStar_Syntax_Util.BaseConn (op,arms))
           ->
           let uu____13045 =
             FStar_All.pipe_right connectives
               (FStar_List.tryFind
                  (fun uu____13151  ->
                     match uu____13151 with
                     | (l,uu____13176) -> FStar_Ident.lid_equals op l))
              in
           (match uu____13045 with
            | FStar_Pervasives_Native.None  -> fallback phi1
            | FStar_Pervasives_Native.Some (uu____13245,f) ->
                f phi1.FStar_Syntax_Syntax.pos arms)
       | FStar_Pervasives_Native.Some (FStar_Syntax_Util.QAll
           (vars,pats,body)) ->
           (FStar_All.pipe_right pats
              (FStar_List.iter (check_pattern_vars env vars));
            (let uu____13337 = encode_q_body env vars pats body  in
             match uu____13337 with
             | (vars1,pats1,guard,body1,decls) ->
                 let tm =
                   let uu____13382 =
                     let uu____13393 =
                       FStar_SMTEncoding_Util.mkImp (guard, body1)  in
                     (pats1, vars1, uu____13393)  in
                   FStar_SMTEncoding_Term.mkForall
                     phi1.FStar_Syntax_Syntax.pos uu____13382
                    in
                 (tm, decls)))
       | FStar_Pervasives_Native.Some (FStar_Syntax_Util.QEx
           (vars,pats,body)) ->
           (FStar_All.pipe_right pats
              (FStar_List.iter (check_pattern_vars env vars));
            (let uu____13424 = encode_q_body env vars pats body  in
             match uu____13424 with
             | (vars1,pats1,guard,body1,decls) ->
                 let uu____13468 =
                   let uu____13469 =
                     let uu____13480 =
                       FStar_SMTEncoding_Util.mkAnd (guard, body1)  in
                     (pats1, vars1, uu____13480)  in
                   FStar_SMTEncoding_Term.mkExists
                     phi1.FStar_Syntax_Syntax.pos uu____13469
                    in
                 (uu____13468, decls))))
