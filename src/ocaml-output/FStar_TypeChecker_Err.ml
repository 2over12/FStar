open Prims
let info_at_pos:
  FStar_TypeChecker_Env.env ->
    Prims.string ->
      Prims.int ->
        Prims.int ->
          ((Prims.string,FStar_Ident.lid) FStar_Util.either,FStar_Syntax_Syntax.typ,
            FStar_Range.range) FStar_Pervasives_Native.tuple3
            FStar_Pervasives_Native.option
  =
  fun env  ->
    fun file  ->
      fun row  ->
        fun col  ->
          let uu____25 =
            let uu____28 =
              FStar_ST.op_Bang env.FStar_TypeChecker_Env.identifier_info in
            FStar_TypeChecker_Common.id_info_at_pos uu____28 file row col in
          match uu____25 with
          | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
          | FStar_Pervasives_Native.Some info ->
              (match info.FStar_TypeChecker_Common.identifier with
               | FStar_Util.Inl bv ->
                   let uu____113 =
                     let uu____124 =
                       let uu____129 = FStar_Syntax_Print.nm_to_string bv in
                       FStar_Util.Inl uu____129 in
                     let uu____130 = FStar_Syntax_Syntax.range_of_bv bv in
                     (uu____124,
                       (info.FStar_TypeChecker_Common.identifier_ty),
                       uu____130) in
                   FStar_Pervasives_Native.Some uu____113
               | FStar_Util.Inr fv ->
                   let uu____146 =
                     let uu____157 =
                       let uu____162 = FStar_Syntax_Syntax.lid_of_fv fv in
                       FStar_Util.Inr uu____162 in
                     let uu____163 = FStar_Syntax_Syntax.range_of_fv fv in
                     (uu____157,
                       (info.FStar_TypeChecker_Common.identifier_ty),
                       uu____163) in
                   FStar_Pervasives_Native.Some uu____146)
let add_errors:
  FStar_TypeChecker_Env.env ->
    (Prims.string,FStar_Range.range) FStar_Pervasives_Native.tuple2
      Prims.list -> Prims.unit
  =
  fun env  ->
    fun errs  ->
      let errs1 =
        FStar_All.pipe_right errs
          (FStar_List.map
             (fun uu____227  ->
                match uu____227 with
                | (msg,r) ->
                    if r = FStar_Range.dummyRange
                    then
                      let uu____242 = FStar_TypeChecker_Env.get_range env in
                      (msg, uu____242)
                    else
                      (let r' =
                         let uu____245 = FStar_Range.use_range r in
                         FStar_Range.set_def_range r uu____245 in
                       let uu____246 =
                         let uu____247 = FStar_Range.file_of_range r' in
                         let uu____248 =
                           let uu____249 =
                             FStar_TypeChecker_Env.get_range env in
                           FStar_Range.file_of_range uu____249 in
                         uu____247 <> uu____248 in
                       if uu____246
                       then
                         let uu____254 =
                           let uu____255 =
                             let uu____256 =
                               let uu____257 =
                                 FStar_Range.string_of_use_range r in
                               Prims.strcat uu____257 ")" in
                             Prims.strcat "(Also see: " uu____256 in
                           Prims.strcat msg uu____255 in
                         let uu____258 = FStar_TypeChecker_Env.get_range env in
                         (uu____254, uu____258)
                       else (msg, r)))) in
      FStar_Errors.add_errors errs1
let err_msg_type_strings:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        (Prims.string,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun t1  ->
      fun t2  ->
        let s1 = FStar_TypeChecker_Normalize.term_to_string env t1 in
        let s2 = FStar_TypeChecker_Normalize.term_to_string env t2 in
        if s1 = s2
        then
          FStar_Options.with_saved_options
            (fun uu____291  ->
               (let uu____293 =
                  FStar_Options.set_options FStar_Options.Set
                    "--print_full_names --print_universes" in
                ());
               (let uu____294 =
                  FStar_TypeChecker_Normalize.term_to_string env t1 in
                let uu____295 =
                  FStar_TypeChecker_Normalize.term_to_string env t2 in
                (uu____294, uu____295)))
        else (s1, s2)
let exhaustiveness_check: Prims.string = "Patterns are incomplete"
let subtyping_failed:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ ->
      FStar_Syntax_Syntax.typ -> Prims.unit -> Prims.string
  =
  fun env  ->
    fun t1  ->
      fun t2  ->
        fun x  ->
          let uu____309 = err_msg_type_strings env t1 t2 in
          match uu____309 with
          | (s1,s2) ->
              FStar_Util.format2
                "Subtyping check failed; expected type %s; got type %s" s2 s1
let ill_kinded_type: Prims.string = "Ill-kinded type"
let totality_check: Prims.string = "This term may not terminate"
let unexpected_signature_for_monad:
  FStar_TypeChecker_Env.env ->
    FStar_Ident.lident -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun m  ->
      fun k  ->
        let uu____325 = FStar_TypeChecker_Normalize.term_to_string env k in
        FStar_Util.format2
          "Unexpected signature for monad \"%s\". Expected a signature of the form (a:Type => WP a => Effect); got %s"
          m.FStar_Ident.str uu____325
let expected_a_term_of_type_t_got_a_function:
  FStar_TypeChecker_Env.env ->
    Prims.string ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun msg  ->
      fun t  ->
        fun e  ->
          let uu____338 = FStar_TypeChecker_Normalize.term_to_string env t in
          let uu____339 = FStar_Syntax_Print.term_to_string e in
          FStar_Util.format3
            "Expected a term of type \"%s\"; got a function \"%s\" (%s)"
            uu____338 uu____339 msg
let unexpected_implicit_argument: Prims.string =
  "Unexpected instantiation of an implicit argument to a function that only expects explicit arguments"
let expected_expression_of_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun t1  ->
      fun e  ->
        fun t2  ->
          let uu____352 = err_msg_type_strings env t1 t2 in
          match uu____352 with
          | (s1,s2) ->
              let uu____359 = FStar_Syntax_Print.term_to_string e in
              FStar_Util.format3
                "Expected expression of type \"%s\"; got expression \"%s\" of type \"%s\""
                s1 uu____359 s2
let expected_function_with_parameter_of_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> Prims.string -> Prims.string
  =
  fun env  ->
    fun t1  ->
      fun t2  ->
        let uu____371 = err_msg_type_strings env t1 t2 in
        match uu____371 with
        | (s1,s2) ->
            FStar_Util.format3
              "Expected a function with a parameter of type \"%s\"; this function has a parameter of type \"%s\""
              s1 s2
let expected_pattern_of_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun t1  ->
      fun e  ->
        fun t2  ->
          let uu____392 = err_msg_type_strings env t1 t2 in
          match uu____392 with
          | (s1,s2) ->
              let uu____399 = FStar_Syntax_Print.term_to_string e in
              FStar_Util.format3
                "Expected pattern of type \"%s\"; got pattern \"%s\" of type \"%s\""
                s1 uu____399 s2
let basic_type_error:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun eopt  ->
      fun t1  ->
        fun t2  ->
          let uu____416 = err_msg_type_strings env t1 t2 in
          match uu____416 with
          | (s1,s2) ->
              (match eopt with
               | FStar_Pervasives_Native.None  ->
                   FStar_Util.format2 "Expected type \"%s\"; got type \"%s\""
                     s1 s2
               | FStar_Pervasives_Native.Some e ->
                   let uu____424 =
                     FStar_TypeChecker_Normalize.term_to_string env e in
                   FStar_Util.format3
                     "Expected type \"%s\"; but \"%s\" has type \"%s\"" s1
                     uu____424 s2)
let occurs_check: Prims.string =
  "Possibly infinite typ (occurs check failed)"
let unification_well_formedness: Prims.string =
  "Term or type of an unexpected sort"
let incompatible_kinds:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun k1  ->
      fun k2  ->
        let uu____434 = FStar_TypeChecker_Normalize.term_to_string env k1 in
        let uu____435 = FStar_TypeChecker_Normalize.term_to_string env k2 in
        FStar_Util.format2 "Kinds \"%s\" and \"%s\" are incompatible"
          uu____434 uu____435
let constructor_builds_the_wrong_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun d  ->
      fun t  ->
        fun t'  ->
          let uu____448 = FStar_Syntax_Print.term_to_string d in
          let uu____449 = FStar_TypeChecker_Normalize.term_to_string env t in
          let uu____450 = FStar_TypeChecker_Normalize.term_to_string env t' in
          FStar_Util.format3
            "Constructor \"%s\" builds a value of type \"%s\"; expected \"%s\""
            uu____448 uu____449 uu____450
let constructor_fails_the_positivity_check:
  'Auu____455 .
    'Auu____455 ->
      FStar_Syntax_Syntax.term -> FStar_Ident.lid -> Prims.string
  =
  fun env  ->
    fun d  ->
      fun l  ->
        let uu____468 = FStar_Syntax_Print.term_to_string d in
        let uu____469 = FStar_Syntax_Print.lid_to_string l in
        FStar_Util.format2
          "Constructor \"%s\" fails the strict positivity check; the constructed type \"%s\" occurs to the left of a pure function type"
          uu____468 uu____469
let inline_type_annotation_and_val_decl: FStar_Ident.lid -> Prims.string =
  fun l  ->
    let uu____473 = FStar_Syntax_Print.lid_to_string l in
    FStar_Util.format1
      "\"%s\" has a val declaration as well as an inlined type annotation; remove one"
      uu____473
let inferred_type_causes_variable_to_escape:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.bv -> Prims.string
  =
  fun env  ->
    fun t  ->
      fun x  ->
        let uu____483 = FStar_TypeChecker_Normalize.term_to_string env t in
        let uu____484 = FStar_Syntax_Print.bv_to_string x in
        FStar_Util.format2
          "Inferred type \"%s\" causes variable \"%s\" to escape its scope"
          uu____483 uu____484
let expected_function_typ:
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.term -> Prims.string =
  fun env  ->
    fun t  ->
      let uu____491 = FStar_TypeChecker_Normalize.term_to_string env t in
      FStar_Util.format1
        "Expected a function; got an expression of type \"%s\"" uu____491
let expected_poly_typ:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.string
  =
  fun env  ->
    fun f  ->
      fun t  ->
        fun targ  ->
          let uu____504 = FStar_Syntax_Print.term_to_string f in
          let uu____505 = FStar_TypeChecker_Normalize.term_to_string env t in
          let uu____506 = FStar_TypeChecker_Normalize.term_to_string env targ in
          FStar_Util.format3
            "Expected a polymorphic function; got an expression \"%s\" of type \"%s\" applied to a type \"%s\""
            uu____504 uu____505 uu____506
let nonlinear_pattern_variable: FStar_Syntax_Syntax.bv -> Prims.string =
  fun x  ->
    let m = FStar_Syntax_Print.bv_to_string x in
    FStar_Util.format1 "The pattern variable \"%s\" was used more than once"
      m
let disjunctive_pattern_vars:
  FStar_Syntax_Syntax.bv Prims.list ->
    FStar_Syntax_Syntax.bv Prims.list -> Prims.string
  =
  fun v1  ->
    fun v2  ->
      let vars v3 =
        let uu____533 =
          FStar_All.pipe_right v3
            (FStar_List.map FStar_Syntax_Print.bv_to_string) in
        FStar_All.pipe_right uu____533 (FStar_String.concat ", ") in
      let uu____542 = vars v1 in
      let uu____543 = vars v2 in
      FStar_Util.format2
        "Every alternative of an 'or' pattern must bind the same variables; here one branch binds (\"%s\") and another (\"%s\")"
        uu____542 uu____543
let name_and_result:
  FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
    (Prims.string,FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
      FStar_Pervasives_Native.tuple2
  =
  fun c  ->
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Total (t,uu____564) -> ("Tot", t)
    | FStar_Syntax_Syntax.GTotal (t,uu____576) -> ("GTot", t)
    | FStar_Syntax_Syntax.Comp ct ->
        let uu____588 =
          FStar_Syntax_Print.lid_to_string ct.FStar_Syntax_Syntax.effect_name in
        (uu____588, (ct.FStar_Syntax_Syntax.result_typ))
let computed_computation_type_does_not_match_annotation:
  'Auu____596 .
    FStar_TypeChecker_Env.env ->
      'Auu____596 ->
        FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
          FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
            Prims.string
  =
  fun env  ->
    fun e  ->
      fun c  ->
        fun c'  ->
          let uu____621 = name_and_result c in
          match uu____621 with
          | (f1,r1) ->
              let uu____634 = name_and_result c' in
              (match uu____634 with
               | (f2,r2) ->
                   let uu____647 = err_msg_type_strings env r1 r2 in
                   (match uu____647 with
                    | (s1,s2) ->
                        FStar_Util.format4
                          "Computed type \"%s\" and effect \"%s\" is not compatible with the annotated type \"%s\" effect \"%s\""
                          s1 f1 s2 f2))
let unexpected_non_trivial_precondition_on_term:
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.term -> Prims.string =
  fun env  ->
    fun f  ->
      let uu____660 = FStar_TypeChecker_Normalize.term_to_string env f in
      FStar_Util.format1
        "Term has an unexpected non-trivial pre-condition: %s" uu____660
let expected_pure_expression:
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax -> Prims.string
  =
  fun e  ->
    fun c  ->
      let uu____671 = FStar_Syntax_Print.term_to_string e in
      let uu____672 =
        let uu____673 = name_and_result c in
        FStar_All.pipe_left FStar_Pervasives_Native.fst uu____673 in
      FStar_Util.format2
        "Expected a pure expression; got an expression \"%s\" with effect \"%s\""
        uu____671 uu____672
let expected_ghost_expression:
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax -> Prims.string
  =
  fun e  ->
    fun c  ->
      let uu____698 = FStar_Syntax_Print.term_to_string e in
      let uu____699 =
        let uu____700 = name_and_result c in
        FStar_All.pipe_left FStar_Pervasives_Native.fst uu____700 in
      FStar_Util.format2
        "Expected a ghost expression; got an expression \"%s\" with effect \"%s\""
        uu____698 uu____699
let expected_effect_1_got_effect_2:
  FStar_Ident.lident -> FStar_Ident.lident -> Prims.string =
  fun c1  ->
    fun c2  ->
      let uu____721 = FStar_Syntax_Print.lid_to_string c1 in
      let uu____722 = FStar_Syntax_Print.lid_to_string c2 in
      FStar_Util.format2
        "Expected a computation with effect %s; but it has effect %s"
        uu____721 uu____722
let failed_to_prove_specification_of:
  FStar_Syntax_Syntax.lbname -> Prims.string Prims.list -> Prims.string =
  fun l  ->
    fun lbls  ->
      let uu____733 = FStar_Syntax_Print.lbname_to_string l in
      let uu____734 = FStar_All.pipe_right lbls (FStar_String.concat ", ") in
      FStar_Util.format2
        "Failed to prove specification of %s; assertions at [%s] may fail"
        uu____733 uu____734
let failed_to_prove_specification: Prims.string Prims.list -> Prims.string =
  fun lbls  ->
    match lbls with
    | [] ->
        "An unknown assertion in the term at this location was not provable"
    | uu____744 ->
        let uu____747 =
          FStar_All.pipe_right lbls (FStar_String.concat "\n\t") in
        FStar_Util.format1 "The following problems were found:\n\t%s"
          uu____747
let top_level_effect: Prims.string =
  "Top-level let-bindings must be total; this term may have effects"
let cardinality_constraint_violated:
  FStar_Ident.lid ->
    FStar_Syntax_Syntax.bv FStar_Syntax_Syntax.withinfo_t -> Prims.string
  =
  fun l  ->
    fun a  ->
      let uu____760 = FStar_Syntax_Print.lid_to_string l in
      let uu____761 = FStar_Syntax_Print.bv_to_string a.FStar_Syntax_Syntax.v in
      FStar_Util.format2
        "Constructor %s violates the cardinality of Type at parameter '%s'; type arguments are not allowed"
        uu____760 uu____761