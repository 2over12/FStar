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
                   let uu____111 =
                     let uu____122 =
                       let uu____127 = FStar_Syntax_Print.nm_to_string bv in
                       FStar_Util.Inl uu____127 in
                     let uu____128 = FStar_Syntax_Syntax.range_of_bv bv in
                     (uu____122,
                       (info.FStar_TypeChecker_Common.identifier_ty),
                       uu____128) in
                   FStar_Pervasives_Native.Some uu____111
               | FStar_Util.Inr fv ->
                   let uu____144 =
                     let uu____155 =
                       let uu____160 = FStar_Syntax_Syntax.lid_of_fv fv in
                       FStar_Util.Inr uu____160 in
                     let uu____161 = FStar_Syntax_Syntax.range_of_fv fv in
                     (uu____155,
                       (info.FStar_TypeChecker_Common.identifier_ty),
                       uu____161) in
                   FStar_Pervasives_Native.Some uu____144)
let add_errors:
  FStar_TypeChecker_Env.env ->
    (FStar_Errors.raw_error,Prims.string,FStar_Range.range)
      FStar_Pervasives_Native.tuple3 Prims.list -> Prims.unit
  =
  fun env  ->
    fun errs  ->
      let errs1 =
        FStar_All.pipe_right errs
          (FStar_List.map
             (fun uu____240  ->
                match uu____240 with
                | (e,msg,r) ->
                    if r = FStar_Range.dummyRange
                    then
                      let uu____262 = FStar_TypeChecker_Env.get_range env in
                      (e, msg, uu____262)
                    else
                      (let r' =
                         let uu____265 = FStar_Range.use_range r in
                         FStar_Range.set_def_range r uu____265 in
                       let uu____266 =
                         let uu____267 = FStar_Range.file_of_range r' in
                         let uu____268 =
                           let uu____269 =
                             FStar_TypeChecker_Env.get_range env in
                           FStar_Range.file_of_range uu____269 in
                         uu____267 <> uu____268 in
                       if uu____266
                       then
                         let uu____276 =
                           let uu____277 =
                             let uu____278 =
                               let uu____279 =
                                 FStar_Range.string_of_use_range r in
                               Prims.strcat uu____279 ")" in
                             Prims.strcat "(Also see: " uu____278 in
                           Prims.strcat msg uu____277 in
                         let uu____280 = FStar_TypeChecker_Env.get_range env in
                         (e, uu____276, uu____280)
                       else (e, msg, r)))) in
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
            (fun uu____313  ->
               (let uu____315 =
                  FStar_Options.set_options FStar_Options.Set
                    "--print_full_names --print_universes" in
                ());
               (let uu____316 =
                  FStar_TypeChecker_Normalize.term_to_string env t1 in
                let uu____317 =
                  FStar_TypeChecker_Normalize.term_to_string env t2 in
                (uu____316, uu____317)))
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
          let uu____331 = err_msg_type_strings env t1 t2 in
          match uu____331 with
          | (s1,s2) ->
              FStar_Util.format2
                "Subtyping check failed; expected type %s; got type %s" s2 s1
let ill_kinded_type: Prims.string = "Ill-kinded type"
let totality_check: Prims.string = "This term may not terminate"
let unexpected_signature_for_monad:
  FStar_TypeChecker_Env.env ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.term ->
        (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun m  ->
      fun k  ->
        let uu____351 =
          let uu____352 = FStar_TypeChecker_Normalize.term_to_string env k in
          FStar_Util.format2
            "Unexpected signature for monad \"%s\". Expected a signature of the form (a:Type => WP a => Effect); got %s"
            m.FStar_Ident.str uu____352 in
        (FStar_Errors.Fatal_UnexpectedSignatureForMonad, uu____351)
let expected_a_term_of_type_t_got_a_function:
  FStar_TypeChecker_Env.env ->
    Prims.string ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors.raw_error,Prims.string)
            FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun msg  ->
      fun t  ->
        fun e  ->
          let uu____369 =
            let uu____370 = FStar_TypeChecker_Normalize.term_to_string env t in
            let uu____371 = FStar_Syntax_Print.term_to_string e in
            FStar_Util.format3
              "Expected a term of type \"%s\"; got a function \"%s\" (%s)"
              uu____370 uu____371 msg in
          (FStar_Errors.Fatal_ExpectTermGotFunction, uu____369)
let unexpected_implicit_argument:
  (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2 =
  (FStar_Errors.Fatal_UnexpectedImplicitArgument,
    "Unexpected instantiation of an implicit argument to a function that only expects explicit arguments")
let expected_expression_of_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors.raw_error,Prims.string)
            FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun t1  ->
      fun e  ->
        fun t2  ->
          let uu____392 = err_msg_type_strings env t1 t2 in
          match uu____392 with
          | (s1,s2) ->
              let uu____403 =
                let uu____404 = FStar_Syntax_Print.term_to_string e in
                FStar_Util.format3
                  "Expected expression of type \"%s\"; got expression \"%s\" of type \"%s\""
                  s1 uu____404 s2 in
              (FStar_Errors.Fatal_UnexpectedExpressionType, uu____403)
let expected_function_with_parameter_of_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> Prims.string -> Prims.string
  =
  fun env  ->
    fun t1  ->
      fun t2  ->
        let uu____416 = err_msg_type_strings env t1 t2 in
        match uu____416 with
        | (s1,s2) ->
            FStar_Util.format3
              "Expected a function with a parameter of type \"%s\"; this function has a parameter of type \"%s\""
              s1 s2
let expected_pattern_of_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors.raw_error,Prims.string)
            FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun t1  ->
      fun e  ->
        fun t2  ->
          let uu____441 = err_msg_type_strings env t1 t2 in
          match uu____441 with
          | (s1,s2) ->
              let uu____452 =
                let uu____453 = FStar_Syntax_Print.term_to_string e in
                FStar_Util.format3
                  "Expected pattern of type \"%s\"; got pattern \"%s\" of type \"%s\""
                  s1 uu____453 s2 in
              (FStar_Errors.Fatal_UnexpectedPattern, uu____452)
let basic_type_error:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors.raw_error,Prims.string)
            FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun eopt  ->
      fun t1  ->
        fun t2  ->
          let uu____474 = err_msg_type_strings env t1 t2 in
          match uu____474 with
          | (s1,s2) ->
              let msg =
                match eopt with
                | FStar_Pervasives_Native.None  ->
                    FStar_Util.format2
                      "Expected type \"%s\"; got type \"%s\"" s1 s2
                | FStar_Pervasives_Native.Some e ->
                    let uu____487 =
                      FStar_TypeChecker_Normalize.term_to_string env e in
                    FStar_Util.format3
                      "Expected type \"%s\"; but \"%s\" has type \"%s\"" s1
                      uu____487 s2 in
              (FStar_Errors.Error_TypeError, msg)
let occurs_check:
  (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2 =
  (FStar_Errors.Fatal_PossibleInfiniteTyp,
    "Possibly infinite typ (occurs check failed)")
let unification_well_formedness:
  (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2 =
  (FStar_Errors.Fatal_UnificationNotWellFormed,
    "Term or type of an unexpected sort")
let incompatible_kinds:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun k1  ->
      fun k2  ->
        let uu____509 =
          let uu____510 = FStar_TypeChecker_Normalize.term_to_string env k1 in
          let uu____511 = FStar_TypeChecker_Normalize.term_to_string env k2 in
          FStar_Util.format2 "Kinds \"%s\" and \"%s\" are incompatible"
            uu____510 uu____511 in
        (FStar_Errors.Fatal_IncompatibleKinds, uu____509)
let constructor_builds_the_wrong_type:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors.raw_error,Prims.string)
            FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun d  ->
      fun t  ->
        fun t'  ->
          let uu____528 =
            let uu____529 = FStar_Syntax_Print.term_to_string d in
            let uu____530 = FStar_TypeChecker_Normalize.term_to_string env t in
            let uu____531 = FStar_TypeChecker_Normalize.term_to_string env t' in
            FStar_Util.format3
              "Constructor \"%s\" builds a value of type \"%s\"; expected \"%s\""
              uu____529 uu____530 uu____531 in
          (FStar_Errors.Fatal_ConstsructorBuildWrongType, uu____528)
let constructor_fails_the_positivity_check:
  'Auu____536 .
    'Auu____536 ->
      FStar_Syntax_Syntax.term ->
        FStar_Ident.lid ->
          (FStar_Errors.raw_error,Prims.string)
            FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun d  ->
      fun l  ->
        let uu____553 =
          let uu____554 = FStar_Syntax_Print.term_to_string d in
          let uu____555 = FStar_Syntax_Print.lid_to_string l in
          FStar_Util.format2
            "Constructor \"%s\" fails the strict positivity check; the constructed type \"%s\" occurs to the left of a pure function type"
            uu____554 uu____555 in
        (FStar_Errors.Fatal_ConstructorFailedCheck, uu____553)
let inline_type_annotation_and_val_decl:
  FStar_Ident.lid ->
    (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun l  ->
    let uu____563 =
      let uu____564 = FStar_Syntax_Print.lid_to_string l in
      FStar_Util.format1
        "\"%s\" has a val declaration as well as an inlined type annotation; remove one"
        uu____564 in
    (FStar_Errors.Fatal_DuplicateTypeAnnotationAndValDecl, uu____563)
let inferred_type_causes_variable_to_escape:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.bv ->
        (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun t  ->
      fun x  ->
        let uu____578 =
          let uu____579 = FStar_TypeChecker_Normalize.term_to_string env t in
          let uu____580 = FStar_Syntax_Print.bv_to_string x in
          FStar_Util.format2
            "Inferred type \"%s\" causes variable \"%s\" to escape its scope"
            uu____579 uu____580 in
        (FStar_Errors.Fatal_InferredTypeCauseVarEscape, uu____578)
let expected_function_typ:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun t  ->
      let uu____591 =
        let uu____592 = FStar_TypeChecker_Normalize.term_to_string env t in
        FStar_Util.format1
          "Expected a function; got an expression of type \"%s\"" uu____592 in
      (FStar_Errors.Fatal_FunctionTypeExpected, uu____591)
let expected_poly_typ:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors.raw_error,Prims.string)
            FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun f  ->
      fun t  ->
        fun targ  ->
          let uu____609 =
            let uu____610 = FStar_Syntax_Print.term_to_string f in
            let uu____611 = FStar_TypeChecker_Normalize.term_to_string env t in
            let uu____612 =
              FStar_TypeChecker_Normalize.term_to_string env targ in
            FStar_Util.format3
              "Expected a polymorphic function; got an expression \"%s\" of type \"%s\" applied to a type \"%s\""
              uu____610 uu____611 uu____612 in
          (FStar_Errors.Fatal_PolyTypeExpected, uu____609)
let nonlinear_pattern_variable:
  FStar_Syntax_Syntax.bv ->
    (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun x  ->
    let m = FStar_Syntax_Print.bv_to_string x in
    let uu____621 =
      FStar_Util.format1
        "The pattern variable \"%s\" was used more than once" m in
    (FStar_Errors.Fatal_NonLinearPatternVars, uu____621)
let disjunctive_pattern_vars:
  FStar_Syntax_Syntax.bv Prims.list ->
    FStar_Syntax_Syntax.bv Prims.list ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun v1  ->
    fun v2  ->
      let vars v3 =
        let uu____648 =
          FStar_All.pipe_right v3
            (FStar_List.map FStar_Syntax_Print.bv_to_string) in
        FStar_All.pipe_right uu____648 (FStar_String.concat ", ") in
      let uu____657 =
        let uu____658 = vars v1 in
        let uu____659 = vars v2 in
        FStar_Util.format2
          "Every alternative of an 'or' pattern must bind the same variables; here one branch binds (\"%s\") and another (\"%s\")"
          uu____658 uu____659 in
      (FStar_Errors.Fatal_DisjuctivePatternVarsMismatch, uu____657)
let name_and_result:
  FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
    (Prims.string,FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
      FStar_Pervasives_Native.tuple2
  =
  fun c  ->
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Total (t,uu____680) -> ("Tot", t)
    | FStar_Syntax_Syntax.GTotal (t,uu____692) -> ("GTot", t)
    | FStar_Syntax_Syntax.Comp ct ->
        let uu____704 =
          FStar_Syntax_Print.lid_to_string ct.FStar_Syntax_Syntax.effect_name in
        (uu____704, (ct.FStar_Syntax_Syntax.result_typ))
let computed_computation_type_does_not_match_annotation:
  'Auu____712 .
    FStar_TypeChecker_Env.env ->
      'Auu____712 ->
        FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
          FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
            (FStar_Errors.raw_error,Prims.string)
              FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun e  ->
      fun c  ->
        fun c'  ->
          let uu____741 = name_and_result c in
          match uu____741 with
          | (f1,r1) ->
              let uu____758 = name_and_result c' in
              (match uu____758 with
               | (f2,r2) ->
                   let uu____775 = err_msg_type_strings env r1 r2 in
                   (match uu____775 with
                    | (s1,s2) ->
                        let uu____786 =
                          FStar_Util.format4
                            "Computed type \"%s\" and effect \"%s\" is not compatible with the annotated type \"%s\" effect \"%s\""
                            s1 f1 s2 f2 in
                        (FStar_Errors.Fatal_ComputedTypeNotMatchAnnotation,
                          uu____786)))
let unexpected_non_trivial_precondition_on_term:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun f  ->
      let uu____797 =
        let uu____798 = FStar_TypeChecker_Normalize.term_to_string env f in
        FStar_Util.format1
          "Term has an unexpected non-trivial pre-condition: %s" uu____798 in
      (FStar_Errors.Fatal_UnExpectedPreCondition, uu____797)
let expected_pure_expression:
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun e  ->
    fun c  ->
      let uu____813 =
        let uu____814 = FStar_Syntax_Print.term_to_string e in
        let uu____815 =
          let uu____816 = name_and_result c in
          FStar_All.pipe_left FStar_Pervasives_Native.fst uu____816 in
        FStar_Util.format2
          "Expected a pure expression; got an expression \"%s\" with effect \"%s\""
          uu____814 uu____815 in
      (FStar_Errors.Fatal_ExpectedPureExpression, uu____813)
let expected_ghost_expression:
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun e  ->
    fun c  ->
      let uu____845 =
        let uu____846 = FStar_Syntax_Print.term_to_string e in
        let uu____847 =
          let uu____848 = name_and_result c in
          FStar_All.pipe_left FStar_Pervasives_Native.fst uu____848 in
        FStar_Util.format2
          "Expected a ghost expression; got an expression \"%s\" with effect \"%s\""
          uu____846 uu____847 in
      (FStar_Errors.Fatal_ExpectedGhostExpression, uu____845)
let expected_effect_1_got_effect_2:
  FStar_Ident.lident ->
    FStar_Ident.lident ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun c1  ->
    fun c2  ->
      let uu____873 =
        let uu____874 = FStar_Syntax_Print.lid_to_string c1 in
        let uu____875 = FStar_Syntax_Print.lid_to_string c2 in
        FStar_Util.format2
          "Expected a computation with effect %s; but it has effect %s"
          uu____874 uu____875 in
      (FStar_Errors.Fatal_UnexpectedEffect, uu____873)
let failed_to_prove_specification_of:
  FStar_Syntax_Syntax.lbname ->
    Prims.string Prims.list ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun l  ->
    fun lbls  ->
      let uu____890 =
        let uu____891 = FStar_Syntax_Print.lbname_to_string l in
        let uu____892 = FStar_All.pipe_right lbls (FStar_String.concat ", ") in
        FStar_Util.format2
          "Failed to prove specification of %s; assertions at [%s] may fail"
          uu____891 uu____892 in
      (FStar_Errors.Error_TypeCheckerFailToProve, uu____890)
let failed_to_prove_specification:
  Prims.string Prims.list ->
    (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun lbls  ->
    let msg =
      match lbls with
      | [] ->
          "An unknown assertion in the term at this location was not provable"
      | uu____907 ->
          let uu____910 =
            FStar_All.pipe_right lbls (FStar_String.concat "\n\t") in
          FStar_Util.format1 "The following problems were found:\n\t%s"
            uu____910 in
    (FStar_Errors.Error_TypeCheckerFailToProve, msg)
let top_level_effect:
  (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2 =
  (FStar_Errors.Warning_TopLevelEffect,
    "Top-level let-bindings must be total; this term may have effects")
let cardinality_constraint_violated:
  FStar_Ident.lid ->
    FStar_Syntax_Syntax.bv FStar_Syntax_Syntax.withinfo_t ->
      (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun l  ->
    fun a  ->
      let uu____931 =
        let uu____932 = FStar_Syntax_Print.lid_to_string l in
        let uu____933 =
          FStar_Syntax_Print.bv_to_string a.FStar_Syntax_Syntax.v in
        FStar_Util.format2
          "Constructor %s violates the cardinality of Type at parameter '%s'; type arguments are not allowed"
          uu____932 uu____933 in
      (FStar_Errors.Fatal_CardinalityConstraintViolated, uu____931)