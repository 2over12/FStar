open Prims
type name = FStar_Syntax_Syntax.bv
type env = FStar_TypeChecker_Env.env
type implicits = FStar_TypeChecker_Env.implicits
let (normalize :
  FStar_TypeChecker_Env.steps ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun s  ->
    fun e  ->
      fun t  ->
        FStar_TypeChecker_Normalize.normalize_with_primitive_steps
          FStar_Reflection_Interpreter.reflection_primops s e t
  
let (bnorm :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  = fun e  -> fun t  -> normalize [] e t 
let (tts :
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.term -> Prims.string) =
  FStar_TypeChecker_Normalize.term_to_string 
let (bnorm_goal : FStar_Tactics_Types.goal -> FStar_Tactics_Types.goal) =
  fun g  ->
    let uu____44 =
      let uu____45 = FStar_Tactics_Types.goal_env g  in
      let uu____46 = FStar_Tactics_Types.goal_type g  in
      bnorm uu____45 uu____46  in
    FStar_Tactics_Types.goal_with_type g uu____44
  
type 'a tac =
  {
  tac_f: FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result }
let __proj__Mktac__item__tac_f :
  'a .
    'a tac ->
      FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result
  = fun projectee  -> match projectee with | { tac_f;_} -> tac_f 
let mk_tac :
  'a .
    (FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result) ->
      'a tac
  = fun f  -> { tac_f = f } 
let run :
  'a .
    'a tac ->
      FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result
  = fun t  -> fun p  -> t.tac_f p 
let run_safe :
  'a .
    'a tac ->
      FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result
  =
  fun t  ->
    fun p  ->
      let uu____160 = FStar_Options.tactics_failhard ()  in
      if uu____160
      then run t p
      else
        (try (fun uu___33_170  -> match () with | () -> run t p) ()
         with
         | FStar_Errors.Err (uu____179,msg) ->
             FStar_Tactics_Result.Failed
               ((FStar_Tactics_Types.TacticFailure msg), p)
         | FStar_Errors.Error (uu____183,msg,uu____185) ->
             FStar_Tactics_Result.Failed
               ((FStar_Tactics_Types.TacticFailure msg), p)
         | e -> FStar_Tactics_Result.Failed (e, p))
  
let (log : FStar_Tactics_Types.proofstate -> (unit -> unit) -> unit) =
  fun ps  ->
    fun f  -> if ps.FStar_Tactics_Types.tac_verb_dbg then f () else ()
  
let ret : 'a . 'a -> 'a tac =
  fun x  -> mk_tac (fun p  -> FStar_Tactics_Result.Success (x, p)) 
let bind : 'a 'b . 'a tac -> ('a -> 'b tac) -> 'b tac =
  fun t1  ->
    fun t2  ->
      mk_tac
        (fun p  ->
           let uu____265 = run t1 p  in
           match uu____265 with
           | FStar_Tactics_Result.Success (a,q) ->
               let uu____272 = t2 a  in run uu____272 q
           | FStar_Tactics_Result.Failed (msg,q) ->
               FStar_Tactics_Result.Failed (msg, q))
  
let (get : FStar_Tactics_Types.proofstate tac) =
  mk_tac (fun p  -> FStar_Tactics_Result.Success (p, p)) 
let (idtac : unit tac) = ret () 
let (get_uvar_solved :
  FStar_Syntax_Syntax.ctx_uvar ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun uv  ->
    let uu____295 =
      FStar_Syntax_Unionfind.find uv.FStar_Syntax_Syntax.ctx_uvar_head  in
    match uu____295 with
    | FStar_Pervasives_Native.Some t -> FStar_Pervasives_Native.Some t
    | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
  
let (check_goal_solved :
  FStar_Tactics_Types.goal ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  = fun goal  -> get_uvar_solved goal.FStar_Tactics_Types.goal_ctx_uvar 
let (goal_to_string_verbose : FStar_Tactics_Types.goal -> Prims.string) =
  fun g  ->
    let uu____317 =
      FStar_Syntax_Print.ctx_uvar_to_string
        g.FStar_Tactics_Types.goal_ctx_uvar
       in
    let uu____319 =
      let uu____321 = check_goal_solved g  in
      match uu____321 with
      | FStar_Pervasives_Native.None  -> ""
      | FStar_Pervasives_Native.Some t ->
          let uu____327 = FStar_Syntax_Print.term_to_string t  in
          FStar_Util.format1 "\tGOAL ALREADY SOLVED!: %s" uu____327
       in
    FStar_Util.format2 "%s%s\n" uu____317 uu____319
  
let (unshadow :
  FStar_Reflection_Data.binders ->
    FStar_Syntax_Syntax.term ->
      (FStar_Reflection_Data.binders * FStar_Syntax_Syntax.term))
  =
  fun bs  ->
    fun t  ->
      let s b = (b.FStar_Syntax_Syntax.ppname).FStar_Ident.idText  in
      let sset bv s1 =
        FStar_Syntax_Syntax.gen_bv s1
          (FStar_Pervasives_Native.Some
             ((bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idRange))
          bv.FStar_Syntax_Syntax.sort
         in
      let fresh_until b f =
        let rec aux i =
          let t1 =
            let uu____404 =
              let uu____406 = FStar_Util.string_of_int i  in
              Prims.op_Hat "'" uu____406  in
            Prims.op_Hat b uu____404  in
          let uu____409 = f t1  in
          if uu____409 then t1 else aux (i + Prims.int_one)  in
        let uu____416 = f b  in if uu____416 then b else aux Prims.int_zero
         in
      let rec go seen subst bs1 bs' t1 =
        match bs1 with
        | [] ->
            let uu____521 = FStar_Syntax_Subst.subst subst t1  in
            ((FStar_List.rev bs'), uu____521)
        | b::bs2 ->
            let b1 =
              let uu____565 = FStar_Syntax_Subst.subst_binders subst [b]  in
              match uu____565 with
              | b1::[] -> b1
              | uu____603 -> failwith "impossible: unshadow subst_binders"
               in
            let uu____611 = b1  in
            (match uu____611 with
             | (bv0,q) ->
                 let nbs =
                   fresh_until (s bv0)
                     (fun s1  -> Prims.op_Negation (FStar_List.mem s1 seen))
                    in
                 let bv = sset bv0 nbs  in
                 let b2 = (bv, q)  in
                 let uu____652 =
                   let uu____655 =
                     let uu____658 =
                       let uu____659 =
                         let uu____666 = FStar_Syntax_Syntax.bv_to_name bv
                            in
                         (bv0, uu____666)  in
                       FStar_Syntax_Syntax.NT uu____659  in
                     [uu____658]  in
                   FStar_List.append subst uu____655  in
                 go (nbs :: seen) uu____652 bs2 (b2 :: bs') t1)
         in
      go [] [] bs [] t
  
let (goal_to_string :
  Prims.string ->
    (Prims.int * Prims.int) FStar_Pervasives_Native.option ->
      FStar_Tactics_Types.proofstate ->
        FStar_Tactics_Types.goal -> Prims.string)
  =
  fun kind  ->
    fun maybe_num  ->
      fun ps  ->
        fun g  ->
          let w =
            let uu____728 = FStar_Options.print_implicits ()  in
            if uu____728
            then
              let uu____732 = FStar_Tactics_Types.goal_env g  in
              let uu____733 = FStar_Tactics_Types.goal_witness g  in
              tts uu____732 uu____733
            else
              (let uu____736 =
                 get_uvar_solved g.FStar_Tactics_Types.goal_ctx_uvar  in
               match uu____736 with
               | FStar_Pervasives_Native.None  -> "_"
               | FStar_Pervasives_Native.Some t ->
                   let uu____742 = FStar_Tactics_Types.goal_env g  in
                   let uu____743 = FStar_Tactics_Types.goal_witness g  in
                   tts uu____742 uu____743)
             in
          let num =
            match maybe_num with
            | FStar_Pervasives_Native.None  -> ""
            | FStar_Pervasives_Native.Some (i,n) ->
                let uu____766 = FStar_Util.string_of_int i  in
                let uu____768 = FStar_Util.string_of_int n  in
                FStar_Util.format2 " %s/%s" uu____766 uu____768
             in
          let maybe_label =
            match g.FStar_Tactics_Types.label with
            | "" -> ""
            | l -> Prims.op_Hat " (" (Prims.op_Hat l ")")  in
          let goal_binders =
            (g.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_binders
             in
          let goal_ty =
            (g.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_typ
             in
          let uu____792 = unshadow goal_binders goal_ty  in
          match uu____792 with
          | (goal_binders1,goal_ty1) ->
              let actual_goal =
                if ps.FStar_Tactics_Types.tac_verb_dbg
                then goal_to_string_verbose g
                else
                  (let uu____806 =
                     FStar_Syntax_Print.binders_to_string ", " goal_binders1
                      in
                   let uu____809 =
                     let uu____811 = FStar_Tactics_Types.goal_env g  in
                     tts uu____811 goal_ty1  in
                   FStar_Util.format3 "%s |- %s : %s\n" uu____806 w uu____809)
                 in
              FStar_Util.format4 "%s%s%s:\n%s\n" kind num maybe_label
                actual_goal
  
let (tacprint : Prims.string -> unit) =
  fun s  -> FStar_Util.print1 "TAC>> %s\n" s 
let (tacprint1 : Prims.string -> Prims.string -> unit) =
  fun s  ->
    fun x  ->
      let uu____838 = FStar_Util.format1 s x  in
      FStar_Util.print1 "TAC>> %s\n" uu____838
  
let (tacprint2 : Prims.string -> Prims.string -> Prims.string -> unit) =
  fun s  ->
    fun x  ->
      fun y  ->
        let uu____863 = FStar_Util.format2 s x y  in
        FStar_Util.print1 "TAC>> %s\n" uu____863
  
let (tacprint3 :
  Prims.string -> Prims.string -> Prims.string -> Prims.string -> unit) =
  fun s  ->
    fun x  ->
      fun y  ->
        fun z  ->
          let uu____895 = FStar_Util.format3 s x y z  in
          FStar_Util.print1 "TAC>> %s\n" uu____895
  
let (get_phi :
  FStar_Tactics_Types.goal ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun g  ->
    let uu____908 =
      let uu____909 = FStar_Tactics_Types.goal_env g  in
      let uu____910 = FStar_Tactics_Types.goal_type g  in
      FStar_TypeChecker_Normalize.unfold_whnf uu____909 uu____910  in
    FStar_Syntax_Util.un_squash uu____908
  
let (is_irrelevant : FStar_Tactics_Types.goal -> Prims.bool) =
  fun g  -> let uu____919 = get_phi g  in FStar_Option.isSome uu____919 
let (print : Prims.string -> unit tac) = fun msg  -> tacprint msg; ret () 
let (debugging : unit -> Prims.bool tac) =
  fun uu____943  ->
    bind get
      (fun ps  ->
         let uu____951 =
           FStar_TypeChecker_Env.debug ps.FStar_Tactics_Types.main_context
             (FStar_Options.Other "Tac")
            in
         ret uu____951)
  
let (ps_to_string :
  (Prims.string * FStar_Tactics_Types.proofstate) -> Prims.string) =
  fun uu____966  ->
    match uu____966 with
    | (msg,ps) ->
        let p_imp imp =
          FStar_Syntax_Print.uvar_to_string
            (imp.FStar_TypeChecker_Common.imp_uvar).FStar_Syntax_Syntax.ctx_uvar_head
           in
        let n_active = FStar_List.length ps.FStar_Tactics_Types.goals  in
        let n_smt = FStar_List.length ps.FStar_Tactics_Types.smt_goals  in
        let n = n_active + n_smt  in
        let uu____988 =
          let uu____992 =
            let uu____996 =
              let uu____998 =
                FStar_Util.string_of_int ps.FStar_Tactics_Types.depth  in
              FStar_Util.format2 "State dump @ depth %s (%s):\n" uu____998
                msg
               in
            let uu____1001 =
              let uu____1005 =
                if
                  ps.FStar_Tactics_Types.entry_range <>
                    FStar_Range.dummyRange
                then
                  let uu____1009 =
                    FStar_Range.string_of_def_range
                      ps.FStar_Tactics_Types.entry_range
                     in
                  FStar_Util.format1 "Location: %s\n" uu____1009
                else ""  in
              let uu____1015 =
                let uu____1019 =
                  let uu____1021 =
                    FStar_TypeChecker_Env.debug
                      ps.FStar_Tactics_Types.main_context
                      (FStar_Options.Other "Imp")
                     in
                  if uu____1021
                  then
                    let uu____1026 =
                      FStar_Common.string_of_list p_imp
                        ps.FStar_Tactics_Types.all_implicits
                       in
                    FStar_Util.format1 "Imps: %s\n" uu____1026
                  else ""  in
                [uu____1019]  in
              uu____1005 :: uu____1015  in
            uu____996 :: uu____1001  in
          let uu____1036 =
            let uu____1040 =
              FStar_List.mapi
                (fun i  ->
                   fun g  ->
                     goal_to_string "Goal"
                       (FStar_Pervasives_Native.Some ((Prims.int_one + i), n))
                       ps g) ps.FStar_Tactics_Types.goals
               in
            let uu____1060 =
              FStar_List.mapi
                (fun i  ->
                   fun g  ->
                     goal_to_string "SMT Goal"
                       (FStar_Pervasives_Native.Some
                          (((Prims.int_one + n_active) + i), n)) ps g)
                ps.FStar_Tactics_Types.smt_goals
               in
            FStar_List.append uu____1040 uu____1060  in
          FStar_List.append uu____992 uu____1036  in
        FStar_String.concat "" uu____988
  
let (goal_to_json : FStar_Tactics_Types.goal -> FStar_Util.json) =
  fun g  ->
    let g_binders =
      (g.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_binders
       in
    let g_type = FStar_Tactics_Types.goal_type g  in
    let uu____1099 = unshadow g_binders g_type  in
    match uu____1099 with
    | (g_binders1,g_type1) ->
        let j_binders =
          let uu____1107 =
            let uu____1108 = FStar_Tactics_Types.goal_env g  in
            FStar_TypeChecker_Env.dsenv uu____1108  in
          FStar_Syntax_Print.binders_to_json uu____1107 g_binders1  in
        let uu____1109 =
          let uu____1117 =
            let uu____1125 =
              let uu____1131 =
                let uu____1132 =
                  let uu____1140 =
                    let uu____1146 =
                      let uu____1147 =
                        let uu____1149 = FStar_Tactics_Types.goal_env g  in
                        let uu____1150 = FStar_Tactics_Types.goal_witness g
                           in
                        tts uu____1149 uu____1150  in
                      FStar_Util.JsonStr uu____1147  in
                    ("witness", uu____1146)  in
                  let uu____1153 =
                    let uu____1161 =
                      let uu____1167 =
                        let uu____1168 =
                          let uu____1170 = FStar_Tactics_Types.goal_env g  in
                          tts uu____1170 g_type1  in
                        FStar_Util.JsonStr uu____1168  in
                      ("type", uu____1167)  in
                    [uu____1161;
                    ("label",
                      (FStar_Util.JsonStr (g.FStar_Tactics_Types.label)))]
                     in
                  uu____1140 :: uu____1153  in
                FStar_Util.JsonAssoc uu____1132  in
              ("goal", uu____1131)  in
            [uu____1125]  in
          ("hyps", j_binders) :: uu____1117  in
        FStar_Util.JsonAssoc uu____1109
  
let (ps_to_json :
  (Prims.string * FStar_Tactics_Types.proofstate) -> FStar_Util.json) =
  fun uu____1224  ->
    match uu____1224 with
    | (msg,ps) ->
        let uu____1234 =
          let uu____1242 =
            let uu____1250 =
              let uu____1258 =
                let uu____1266 =
                  let uu____1272 =
                    let uu____1273 =
                      FStar_List.map goal_to_json
                        ps.FStar_Tactics_Types.goals
                       in
                    FStar_Util.JsonList uu____1273  in
                  ("goals", uu____1272)  in
                let uu____1278 =
                  let uu____1286 =
                    let uu____1292 =
                      let uu____1293 =
                        FStar_List.map goal_to_json
                          ps.FStar_Tactics_Types.smt_goals
                         in
                      FStar_Util.JsonList uu____1293  in
                    ("smt-goals", uu____1292)  in
                  [uu____1286]  in
                uu____1266 :: uu____1278  in
              ("depth", (FStar_Util.JsonInt (ps.FStar_Tactics_Types.depth)))
                :: uu____1258
               in
            ("label", (FStar_Util.JsonStr msg)) :: uu____1250  in
          let uu____1327 =
            if ps.FStar_Tactics_Types.entry_range <> FStar_Range.dummyRange
            then
              let uu____1343 =
                let uu____1349 =
                  FStar_Range.json_of_def_range
                    ps.FStar_Tactics_Types.entry_range
                   in
                ("location", uu____1349)  in
              [uu____1343]
            else []  in
          FStar_List.append uu____1242 uu____1327  in
        FStar_Util.JsonAssoc uu____1234
  
let (do_dump_proofstate :
  FStar_Tactics_Types.proofstate -> Prims.string -> unit) =
  fun ps  ->
    fun msg  ->
      FStar_Options.with_saved_options
        (fun uu____1390  ->
           FStar_Options.set_option "print_effect_args"
             (FStar_Options.Bool true);
           FStar_Util.print_generic "proof-state" ps_to_string ps_to_json
             (msg, ps);
           FStar_Util.flush_stdout ())
  
let (dump : Prims.string -> unit tac) =
  fun msg  ->
    mk_tac
      (fun ps  ->
         let psc = ps.FStar_Tactics_Types.psc  in
         let subst = FStar_TypeChecker_Cfg.psc_subst psc  in
         (let uu____1422 = FStar_Tactics_Types.subst_proof_state subst ps  in
          do_dump_proofstate uu____1422 msg);
         FStar_Tactics_Result.Success ((), ps))
  
let mlog : 'a . (unit -> unit) -> (unit -> 'a tac) -> 'a tac =
  fun f  -> fun cont  -> bind get (fun ps  -> log ps f; cont ()) 
let traise : 'a . Prims.exn -> 'a tac =
  fun e  -> mk_tac (fun ps  -> FStar_Tactics_Result.Failed (e, ps)) 
let fail : 'a . Prims.string -> 'a tac =
  fun msg  ->
    mk_tac
      (fun ps  ->
         (let uu____1495 =
            FStar_TypeChecker_Env.debug ps.FStar_Tactics_Types.main_context
              (FStar_Options.Other "TacFail")
             in
          if uu____1495
          then do_dump_proofstate ps (Prims.op_Hat "TACTIC FAILING: " msg)
          else ());
         FStar_Tactics_Result.Failed
           ((FStar_Tactics_Types.TacticFailure msg), ps))
  
let fail1 : 'uuuuuu1509 . Prims.string -> Prims.string -> 'uuuuuu1509 tac =
  fun msg  ->
    fun x  -> let uu____1526 = FStar_Util.format1 msg x  in fail uu____1526
  
let fail2 :
  'uuuuuu1537 .
    Prims.string -> Prims.string -> Prims.string -> 'uuuuuu1537 tac
  =
  fun msg  ->
    fun x  ->
      fun y  ->
        let uu____1561 = FStar_Util.format2 msg x y  in fail uu____1561
  
let fail3 :
  'uuuuuu1574 .
    Prims.string ->
      Prims.string -> Prims.string -> Prims.string -> 'uuuuuu1574 tac
  =
  fun msg  ->
    fun x  ->
      fun y  ->
        fun z  ->
          let uu____1605 = FStar_Util.format3 msg x y z  in fail uu____1605
  
let fail4 :
  'uuuuuu1620 .
    Prims.string ->
      Prims.string ->
        Prims.string -> Prims.string -> Prims.string -> 'uuuuuu1620 tac
  =
  fun msg  ->
    fun x  ->
      fun y  ->
        fun z  ->
          fun w  ->
            let uu____1658 = FStar_Util.format4 msg x y z w  in
            fail uu____1658
  
let catch : 'a . 'a tac -> (Prims.exn,'a) FStar_Util.either tac =
  fun t  ->
    mk_tac
      (fun ps  ->
         let tx = FStar_Syntax_Unionfind.new_transaction ()  in
         let uu____1693 = run t ps  in
         match uu____1693 with
         | FStar_Tactics_Result.Success (a,q) ->
             (FStar_Syntax_Unionfind.commit tx;
              FStar_Tactics_Result.Success ((FStar_Util.Inr a), q))
         | FStar_Tactics_Result.Failed (m,q) ->
             (FStar_Syntax_Unionfind.rollback tx;
              (let ps1 =
                 let uu___232_1717 = ps  in
                 {
                   FStar_Tactics_Types.main_context =
                     (uu___232_1717.FStar_Tactics_Types.main_context);
                   FStar_Tactics_Types.all_implicits =
                     (uu___232_1717.FStar_Tactics_Types.all_implicits);
                   FStar_Tactics_Types.goals =
                     (uu___232_1717.FStar_Tactics_Types.goals);
                   FStar_Tactics_Types.smt_goals =
                     (uu___232_1717.FStar_Tactics_Types.smt_goals);
                   FStar_Tactics_Types.depth =
                     (uu___232_1717.FStar_Tactics_Types.depth);
                   FStar_Tactics_Types.__dump =
                     (uu___232_1717.FStar_Tactics_Types.__dump);
                   FStar_Tactics_Types.psc =
                     (uu___232_1717.FStar_Tactics_Types.psc);
                   FStar_Tactics_Types.entry_range =
                     (uu___232_1717.FStar_Tactics_Types.entry_range);
                   FStar_Tactics_Types.guard_policy =
                     (uu___232_1717.FStar_Tactics_Types.guard_policy);
                   FStar_Tactics_Types.freshness =
                     (q.FStar_Tactics_Types.freshness);
                   FStar_Tactics_Types.tac_verb_dbg =
                     (uu___232_1717.FStar_Tactics_Types.tac_verb_dbg);
                   FStar_Tactics_Types.local_state =
                     (uu___232_1717.FStar_Tactics_Types.local_state)
                 }  in
               FStar_Tactics_Result.Success ((FStar_Util.Inl m), ps1))))
  
let recover : 'a . 'a tac -> (Prims.exn,'a) FStar_Util.either tac =
  fun t  ->
    mk_tac
      (fun ps  ->
         let uu____1756 = run t ps  in
         match uu____1756 with
         | FStar_Tactics_Result.Success (a,q) ->
             FStar_Tactics_Result.Success ((FStar_Util.Inr a), q)
         | FStar_Tactics_Result.Failed (m,q) ->
             FStar_Tactics_Result.Success ((FStar_Util.Inl m), q))
  
let trytac : 'a . 'a tac -> 'a FStar_Pervasives_Native.option tac =
  fun t  ->
    let uu____1804 = catch t  in
    bind uu____1804
      (fun r  ->
         match r with
         | FStar_Util.Inr v -> ret (FStar_Pervasives_Native.Some v)
         | FStar_Util.Inl uu____1831 -> ret FStar_Pervasives_Native.None)
  
let trytac_exn : 'a . 'a tac -> 'a FStar_Pervasives_Native.option tac =
  fun t  ->
    mk_tac
      (fun ps  ->
         try
           (fun uu___258_1863  ->
              match () with
              | () -> let uu____1868 = trytac t  in run uu____1868 ps) ()
         with
         | FStar_Errors.Err (uu____1884,msg) ->
             (log ps
                (fun uu____1890  ->
                   FStar_Util.print1 "trytac_exn error: (%s)" msg);
              FStar_Tactics_Result.Success (FStar_Pervasives_Native.None, ps))
         | FStar_Errors.Error (uu____1896,msg,uu____1898) ->
             (log ps
                (fun uu____1903  ->
                   FStar_Util.print1 "trytac_exn error: (%s)" msg);
              FStar_Tactics_Result.Success (FStar_Pervasives_Native.None, ps)))
  
let wrap_err : 'a . Prims.string -> 'a tac -> 'a tac =
  fun pref  ->
    fun t  ->
      mk_tac
        (fun ps  ->
           let uu____1940 = run t ps  in
           match uu____1940 with
           | FStar_Tactics_Result.Success (a,q) ->
               FStar_Tactics_Result.Success (a, q)
           | FStar_Tactics_Result.Failed
               (FStar_Tactics_Types.TacticFailure msg,q) ->
               FStar_Tactics_Result.Failed
                 ((FStar_Tactics_Types.TacticFailure
                     (Prims.op_Hat pref (Prims.op_Hat ": " msg))), q)
           | FStar_Tactics_Result.Failed (e,q) ->
               FStar_Tactics_Result.Failed (e, q))
  
let (set : FStar_Tactics_Types.proofstate -> unit tac) =
  fun p  -> mk_tac (fun uu____1964  -> FStar_Tactics_Result.Success ((), p)) 
let (add_implicits : implicits -> unit tac) =
  fun i  ->
    bind get
      (fun p  ->
         set
           (let uu___293_1979 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___293_1979.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (FStar_List.append i p.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___293_1979.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___293_1979.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___293_1979.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___293_1979.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___293_1979.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___293_1979.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___293_1979.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___293_1979.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___293_1979.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___293_1979.FStar_Tactics_Types.local_state)
            }))
  
let (__do_unify :
  env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac)
  =
  fun env1  ->
    fun t1  ->
      fun t2  ->
        (let uu____2003 =
           FStar_TypeChecker_Env.debug env1 (FStar_Options.Other "1346")  in
         if uu____2003
         then
           let uu____2007 = FStar_Syntax_Print.term_to_string t1  in
           let uu____2009 = FStar_Syntax_Print.term_to_string t2  in
           FStar_Util.print2 "%%%%%%%%do_unify %s =? %s\n" uu____2007
             uu____2009
         else ());
        (try
           (fun uu___301_2020  ->
              match () with
              | () ->
                  let res = FStar_TypeChecker_Rel.teq_nosmt env1 t1 t2  in
                  ((let uu____2028 =
                      FStar_TypeChecker_Env.debug env1
                        (FStar_Options.Other "1346")
                       in
                    if uu____2028
                    then
                      let uu____2032 =
                        FStar_Common.string_of_option
                          (FStar_TypeChecker_Rel.guard_to_string env1) res
                         in
                      let uu____2034 = FStar_Syntax_Print.term_to_string t1
                         in
                      let uu____2036 = FStar_Syntax_Print.term_to_string t2
                         in
                      FStar_Util.print3
                        "%%%%%%%%do_unify (RESULT %s) %s =? %s\n" uu____2032
                        uu____2034 uu____2036
                    else ());
                   (match res with
                    | FStar_Pervasives_Native.None  -> ret false
                    | FStar_Pervasives_Native.Some g ->
                        let uu____2047 =
                          add_implicits g.FStar_TypeChecker_Common.implicits
                           in
                        bind uu____2047 (fun uu____2052  -> ret true)))) ()
         with
         | FStar_Errors.Err (uu____2062,msg) ->
             mlog
               (fun uu____2068  ->
                  FStar_Util.print1 ">> do_unify error, (%s)\n" msg)
               (fun uu____2071  -> ret false)
         | FStar_Errors.Error (uu____2074,msg,r) ->
             mlog
               (fun uu____2082  ->
                  let uu____2083 = FStar_Range.string_of_range r  in
                  FStar_Util.print2 ">> do_unify error, (%s) at (%s)\n" msg
                    uu____2083) (fun uu____2087  -> ret false))
  
let (compress_implicits : unit tac) =
  bind get
    (fun ps  ->
       let imps = ps.FStar_Tactics_Types.all_implicits  in
       let g =
         let uu___327_2101 = FStar_TypeChecker_Env.trivial_guard  in
         {
           FStar_TypeChecker_Common.guard_f =
             (uu___327_2101.FStar_TypeChecker_Common.guard_f);
           FStar_TypeChecker_Common.deferred =
             (uu___327_2101.FStar_TypeChecker_Common.deferred);
           FStar_TypeChecker_Common.univ_ineqs =
             (uu___327_2101.FStar_TypeChecker_Common.univ_ineqs);
           FStar_TypeChecker_Common.implicits = imps
         }  in
       let g1 =
         FStar_TypeChecker_Rel.resolve_implicits_tac
           ps.FStar_Tactics_Types.main_context g
          in
       let ps' =
         let uu___331_2104 = ps  in
         {
           FStar_Tactics_Types.main_context =
             (uu___331_2104.FStar_Tactics_Types.main_context);
           FStar_Tactics_Types.all_implicits =
             (g1.FStar_TypeChecker_Common.implicits);
           FStar_Tactics_Types.goals =
             (uu___331_2104.FStar_Tactics_Types.goals);
           FStar_Tactics_Types.smt_goals =
             (uu___331_2104.FStar_Tactics_Types.smt_goals);
           FStar_Tactics_Types.depth =
             (uu___331_2104.FStar_Tactics_Types.depth);
           FStar_Tactics_Types.__dump =
             (uu___331_2104.FStar_Tactics_Types.__dump);
           FStar_Tactics_Types.psc = (uu___331_2104.FStar_Tactics_Types.psc);
           FStar_Tactics_Types.entry_range =
             (uu___331_2104.FStar_Tactics_Types.entry_range);
           FStar_Tactics_Types.guard_policy =
             (uu___331_2104.FStar_Tactics_Types.guard_policy);
           FStar_Tactics_Types.freshness =
             (uu___331_2104.FStar_Tactics_Types.freshness);
           FStar_Tactics_Types.tac_verb_dbg =
             (uu___331_2104.FStar_Tactics_Types.tac_verb_dbg);
           FStar_Tactics_Types.local_state =
             (uu___331_2104.FStar_Tactics_Types.local_state)
         }  in
       set ps')
  
let (do_unify :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac)
  =
  fun env1  ->
    fun t1  ->
      fun t2  ->
        bind idtac
          (fun uu____2131  ->
             (let uu____2133 =
                FStar_TypeChecker_Env.debug env1 (FStar_Options.Other "1346")
                 in
              if uu____2133
              then
                (FStar_Options.push ();
                 (let uu____2138 =
                    FStar_Options.set_options
                      "--debug_level Rel --debug_level RelCheck"
                     in
                  ()))
              else ());
             (let uu____2142 = __do_unify env1 t1 t2  in
              bind uu____2142
                (fun r  ->
                   (let uu____2153 =
                      FStar_TypeChecker_Env.debug env1
                        (FStar_Options.Other "1346")
                       in
                    if uu____2153 then FStar_Options.pop () else ());
                   ret r)))
  
let (do_match :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac)
  =
  fun env1  ->
    fun t1  ->
      fun t2  ->
        let uvs1 = FStar_Syntax_Free.uvars_uncached t1  in
        let uu____2185 = do_unify env1 t1 t2  in
        bind uu____2185
          (fun r  ->
             if r
             then
               let uvs2 = FStar_Syntax_Free.uvars_uncached t1  in
               let uu____2203 =
                 let uu____2205 = FStar_Util.set_eq uvs1 uvs2  in
                 Prims.op_Negation uu____2205  in
               (if uu____2203 then ret false else ret true)
             else ret false)
  
let (remove_solved_goals : unit tac) =
  bind get
    (fun ps  ->
       let ps' =
         let uu___354_2228 = ps  in
         let uu____2229 =
           FStar_List.filter
             (fun g  ->
                let uu____2235 = check_goal_solved g  in
                FStar_Option.isNone uu____2235) ps.FStar_Tactics_Types.goals
            in
         {
           FStar_Tactics_Types.main_context =
             (uu___354_2228.FStar_Tactics_Types.main_context);
           FStar_Tactics_Types.all_implicits =
             (uu___354_2228.FStar_Tactics_Types.all_implicits);
           FStar_Tactics_Types.goals = uu____2229;
           FStar_Tactics_Types.smt_goals =
             (uu___354_2228.FStar_Tactics_Types.smt_goals);
           FStar_Tactics_Types.depth =
             (uu___354_2228.FStar_Tactics_Types.depth);
           FStar_Tactics_Types.__dump =
             (uu___354_2228.FStar_Tactics_Types.__dump);
           FStar_Tactics_Types.psc = (uu___354_2228.FStar_Tactics_Types.psc);
           FStar_Tactics_Types.entry_range =
             (uu___354_2228.FStar_Tactics_Types.entry_range);
           FStar_Tactics_Types.guard_policy =
             (uu___354_2228.FStar_Tactics_Types.guard_policy);
           FStar_Tactics_Types.freshness =
             (uu___354_2228.FStar_Tactics_Types.freshness);
           FStar_Tactics_Types.tac_verb_dbg =
             (uu___354_2228.FStar_Tactics_Types.tac_verb_dbg);
           FStar_Tactics_Types.local_state =
             (uu___354_2228.FStar_Tactics_Types.local_state)
         }  in
       set ps')
  
let (set_solution :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> unit tac) =
  fun goal  ->
    fun solution  ->
      let uu____2253 =
        FStar_Syntax_Unionfind.find
          (goal.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_head
         in
      match uu____2253 with
      | FStar_Pervasives_Native.Some uu____2258 ->
          let uu____2259 =
            let uu____2261 = goal_to_string_verbose goal  in
            FStar_Util.format1 "Goal %s is already solved" uu____2261  in
          fail uu____2259
      | FStar_Pervasives_Native.None  ->
          (FStar_Syntax_Unionfind.change
             (goal.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_head
             solution;
           ret ())
  
let (trysolve :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> Prims.bool tac) =
  fun goal  ->
    fun solution  ->
      let uu____2282 = FStar_Tactics_Types.goal_env goal  in
      let uu____2283 = FStar_Tactics_Types.goal_witness goal  in
      do_unify uu____2282 solution uu____2283
  
let (__dismiss : unit tac) =
  bind get
    (fun p  ->
       let uu____2290 =
         let uu___367_2291 = p  in
         let uu____2292 = FStar_List.tl p.FStar_Tactics_Types.goals  in
         {
           FStar_Tactics_Types.main_context =
             (uu___367_2291.FStar_Tactics_Types.main_context);
           FStar_Tactics_Types.all_implicits =
             (uu___367_2291.FStar_Tactics_Types.all_implicits);
           FStar_Tactics_Types.goals = uu____2292;
           FStar_Tactics_Types.smt_goals =
             (uu___367_2291.FStar_Tactics_Types.smt_goals);
           FStar_Tactics_Types.depth =
             (uu___367_2291.FStar_Tactics_Types.depth);
           FStar_Tactics_Types.__dump =
             (uu___367_2291.FStar_Tactics_Types.__dump);
           FStar_Tactics_Types.psc = (uu___367_2291.FStar_Tactics_Types.psc);
           FStar_Tactics_Types.entry_range =
             (uu___367_2291.FStar_Tactics_Types.entry_range);
           FStar_Tactics_Types.guard_policy =
             (uu___367_2291.FStar_Tactics_Types.guard_policy);
           FStar_Tactics_Types.freshness =
             (uu___367_2291.FStar_Tactics_Types.freshness);
           FStar_Tactics_Types.tac_verb_dbg =
             (uu___367_2291.FStar_Tactics_Types.tac_verb_dbg);
           FStar_Tactics_Types.local_state =
             (uu___367_2291.FStar_Tactics_Types.local_state)
         }  in
       set uu____2290)
  
let (solve :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> unit tac) =
  fun goal  ->
    fun solution  ->
      let e = FStar_Tactics_Types.goal_env goal  in
      mlog
        (fun uu____2314  ->
           let uu____2315 =
             let uu____2317 = FStar_Tactics_Types.goal_witness goal  in
             FStar_Syntax_Print.term_to_string uu____2317  in
           let uu____2318 = FStar_Syntax_Print.term_to_string solution  in
           FStar_Util.print2 "solve %s := %s\n" uu____2315 uu____2318)
        (fun uu____2323  ->
           let uu____2324 = trysolve goal solution  in
           bind uu____2324
             (fun b  ->
                if b
                then bind __dismiss (fun uu____2336  -> remove_solved_goals)
                else
                  (let uu____2339 =
                     let uu____2341 =
                       let uu____2343 = FStar_Tactics_Types.goal_env goal  in
                       tts uu____2343 solution  in
                     let uu____2344 =
                       let uu____2346 = FStar_Tactics_Types.goal_env goal  in
                       let uu____2347 = FStar_Tactics_Types.goal_witness goal
                          in
                       tts uu____2346 uu____2347  in
                     let uu____2348 =
                       let uu____2350 = FStar_Tactics_Types.goal_env goal  in
                       let uu____2351 = FStar_Tactics_Types.goal_type goal
                          in
                       tts uu____2350 uu____2351  in
                     FStar_Util.format3 "%s does not solve %s : %s"
                       uu____2341 uu____2344 uu____2348
                      in
                   fail uu____2339)))
  
let (solve' :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> unit tac) =
  fun goal  ->
    fun solution  ->
      let uu____2368 = set_solution goal solution  in
      bind uu____2368
        (fun uu____2372  ->
           bind __dismiss (fun uu____2374  -> remove_solved_goals))
  
let (set_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun ps  ->
         set
           (let uu___383_2393 = ps  in
            {
              FStar_Tactics_Types.main_context =
                (uu___383_2393.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (uu___383_2393.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals = gs;
              FStar_Tactics_Types.smt_goals =
                (uu___383_2393.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___383_2393.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___383_2393.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___383_2393.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___383_2393.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___383_2393.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___383_2393.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___383_2393.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___383_2393.FStar_Tactics_Types.local_state)
            }))
  
let (set_smt_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun ps  ->
         set
           (let uu___387_2412 = ps  in
            {
              FStar_Tactics_Types.main_context =
                (uu___387_2412.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (uu___387_2412.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___387_2412.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals = gs;
              FStar_Tactics_Types.depth =
                (uu___387_2412.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___387_2412.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___387_2412.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___387_2412.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___387_2412.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___387_2412.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___387_2412.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___387_2412.FStar_Tactics_Types.local_state)
            }))
  
let (dismiss_all : unit tac) = set_goals [] 
let (nwarn : Prims.int FStar_ST.ref) = FStar_Util.mk_ref Prims.int_zero 
let (check_valid_goal : FStar_Tactics_Types.goal -> unit) =
  fun g  ->
    let uu____2428 = FStar_Options.defensive ()  in
    if uu____2428
    then
      let b = true  in
      let env1 = FStar_Tactics_Types.goal_env g  in
      let b1 =
        b &&
          (let uu____2438 = FStar_Tactics_Types.goal_witness g  in
           FStar_TypeChecker_Env.closed env1 uu____2438)
         in
      let b2 =
        b1 &&
          (let uu____2442 = FStar_Tactics_Types.goal_type g  in
           FStar_TypeChecker_Env.closed env1 uu____2442)
         in
      let rec aux b3 e =
        let uu____2457 = FStar_TypeChecker_Env.pop_bv e  in
        match uu____2457 with
        | FStar_Pervasives_Native.None  -> b3
        | FStar_Pervasives_Native.Some (bv,e1) ->
            let b4 =
              b3 &&
                (FStar_TypeChecker_Env.closed e1 bv.FStar_Syntax_Syntax.sort)
               in
            aux b4 e1
         in
      let uu____2477 =
        (let uu____2481 = aux b2 env1  in Prims.op_Negation uu____2481) &&
          (let uu____2484 = FStar_ST.op_Bang nwarn  in
           uu____2484 < (Prims.of_int (5)))
         in
      (if uu____2477
       then
         ((let uu____2510 =
             let uu____2511 = FStar_Tactics_Types.goal_type g  in
             uu____2511.FStar_Syntax_Syntax.pos  in
           let uu____2514 =
             let uu____2520 =
               let uu____2522 = goal_to_string_verbose g  in
               FStar_Util.format1
                 "The following goal is ill-formed. Keeping calm and carrying on...\n<%s>\n\n"
                 uu____2522
                in
             (FStar_Errors.Warning_IllFormedGoal, uu____2520)  in
           FStar_Errors.log_issue uu____2510 uu____2514);
          (let uu____2526 =
             let uu____2528 = FStar_ST.op_Bang nwarn  in
             uu____2528 + Prims.int_one  in
           FStar_ST.op_Colon_Equals nwarn uu____2526))
       else ())
    else ()
  
let (add_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___409_2597 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___409_2597.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (uu___409_2597.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (FStar_List.append gs p.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___409_2597.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___409_2597.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___409_2597.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___409_2597.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___409_2597.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___409_2597.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___409_2597.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___409_2597.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___409_2597.FStar_Tactics_Types.local_state)
            }))
  
let (add_smt_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___414_2618 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___414_2618.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (uu___414_2618.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___414_2618.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (FStar_List.append gs p.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___414_2618.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___414_2618.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___414_2618.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___414_2618.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___414_2618.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___414_2618.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___414_2618.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___414_2618.FStar_Tactics_Types.local_state)
            }))
  
let (push_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___419_2639 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___419_2639.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (uu___419_2639.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (FStar_List.append p.FStar_Tactics_Types.goals gs);
              FStar_Tactics_Types.smt_goals =
                (uu___419_2639.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___419_2639.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___419_2639.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___419_2639.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___419_2639.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___419_2639.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___419_2639.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___419_2639.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___419_2639.FStar_Tactics_Types.local_state)
            }))
  
let (push_smt_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___424_2660 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___424_2660.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (uu___424_2660.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___424_2660.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (FStar_List.append p.FStar_Tactics_Types.smt_goals gs);
              FStar_Tactics_Types.depth =
                (uu___424_2660.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___424_2660.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___424_2660.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___424_2660.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___424_2660.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___424_2660.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___424_2660.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___424_2660.FStar_Tactics_Types.local_state)
            }))
  
let (replace_cur : FStar_Tactics_Types.goal -> unit tac) =
  fun g  -> bind __dismiss (fun uu____2672  -> add_goals [g]) 
let (new_uvar :
  Prims.string ->
    env ->
      FStar_Reflection_Data.typ ->
        (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.ctx_uvar) tac)
  =
  fun reason  ->
    fun env1  ->
      fun typ  ->
        let uu____2703 =
          FStar_TypeChecker_Env.new_implicit_var_aux reason
            typ.FStar_Syntax_Syntax.pos env1 typ
            FStar_Syntax_Syntax.Allow_untyped FStar_Pervasives_Native.None
           in
        match uu____2703 with
        | (u,ctx_uvar,g_u) ->
            let uu____2741 =
              add_implicits g_u.FStar_TypeChecker_Common.implicits  in
            bind uu____2741
              (fun uu____2750  ->
                 let uu____2751 =
                   let uu____2756 =
                     let uu____2757 = FStar_List.hd ctx_uvar  in
                     FStar_Pervasives_Native.fst uu____2757  in
                   (u, uu____2756)  in
                 ret uu____2751)
  
let (is_true : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun t  ->
    let t1 = FStar_Syntax_Util.unascribe t  in
    let uu____2778 = FStar_Syntax_Util.un_squash t1  in
    match uu____2778 with
    | FStar_Pervasives_Native.Some t' ->
        let t'1 = FStar_Syntax_Util.unascribe t'  in
        let uu____2790 =
          let uu____2791 = FStar_Syntax_Subst.compress t'1  in
          uu____2791.FStar_Syntax_Syntax.n  in
        (match uu____2790 with
         | FStar_Syntax_Syntax.Tm_fvar fv ->
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.true_lid
         | uu____2796 -> false)
    | uu____2798 -> false
  
let (is_false : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun t  ->
    let uu____2811 = FStar_Syntax_Util.un_squash t  in
    match uu____2811 with
    | FStar_Pervasives_Native.Some t' ->
        let uu____2822 =
          let uu____2823 = FStar_Syntax_Subst.compress t'  in
          uu____2823.FStar_Syntax_Syntax.n  in
        (match uu____2822 with
         | FStar_Syntax_Syntax.Tm_fvar fv ->
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.false_lid
         | uu____2828 -> false)
    | uu____2830 -> false
  
let (cur_goal : unit -> FStar_Tactics_Types.goal tac) =
  fun uu____2843  ->
    bind get
      (fun p  ->
         match p.FStar_Tactics_Types.goals with
         | [] -> fail "No more goals (1)"
         | hd::tl ->
             let uu____2855 =
               FStar_Syntax_Unionfind.find
                 (hd.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_head
                in
             (match uu____2855 with
              | FStar_Pervasives_Native.None  -> ret hd
              | FStar_Pervasives_Native.Some t ->
                  ((let uu____2862 = goal_to_string_verbose hd  in
                    let uu____2864 = FStar_Syntax_Print.term_to_string t  in
                    FStar_Util.print2
                      "!!!!!!!!!!!! GOAL IS ALREADY SOLVED! %s\nsol is %s\n"
                      uu____2862 uu____2864);
                   ret hd)))
  
let (tadmit_t : FStar_Syntax_Syntax.term -> unit tac) =
  fun t  ->
    let uu____2877 =
      bind get
        (fun ps  ->
           let uu____2883 = cur_goal ()  in
           bind uu____2883
             (fun g  ->
                (let uu____2890 =
                   let uu____2891 = FStar_Tactics_Types.goal_type g  in
                   uu____2891.FStar_Syntax_Syntax.pos  in
                 let uu____2894 =
                   let uu____2900 =
                     let uu____2902 =
                       goal_to_string "" FStar_Pervasives_Native.None ps g
                        in
                     FStar_Util.format1 "Tactics admitted goal <%s>\n\n"
                       uu____2902
                      in
                   (FStar_Errors.Warning_TacAdmit, uu____2900)  in
                 FStar_Errors.log_issue uu____2890 uu____2894);
                solve' g t))
       in
    FStar_All.pipe_left (wrap_err "tadmit_t") uu____2877
  
let (fresh : unit -> FStar_BigInt.t tac) =
  fun uu____2925  ->
    bind get
      (fun ps  ->
         let n = ps.FStar_Tactics_Types.freshness  in
         let ps1 =
           let uu___469_2936 = ps  in
           {
             FStar_Tactics_Types.main_context =
               (uu___469_2936.FStar_Tactics_Types.main_context);
             FStar_Tactics_Types.all_implicits =
               (uu___469_2936.FStar_Tactics_Types.all_implicits);
             FStar_Tactics_Types.goals =
               (uu___469_2936.FStar_Tactics_Types.goals);
             FStar_Tactics_Types.smt_goals =
               (uu___469_2936.FStar_Tactics_Types.smt_goals);
             FStar_Tactics_Types.depth =
               (uu___469_2936.FStar_Tactics_Types.depth);
             FStar_Tactics_Types.__dump =
               (uu___469_2936.FStar_Tactics_Types.__dump);
             FStar_Tactics_Types.psc =
               (uu___469_2936.FStar_Tactics_Types.psc);
             FStar_Tactics_Types.entry_range =
               (uu___469_2936.FStar_Tactics_Types.entry_range);
             FStar_Tactics_Types.guard_policy =
               (uu___469_2936.FStar_Tactics_Types.guard_policy);
             FStar_Tactics_Types.freshness = (n + Prims.int_one);
             FStar_Tactics_Types.tac_verb_dbg =
               (uu___469_2936.FStar_Tactics_Types.tac_verb_dbg);
             FStar_Tactics_Types.local_state =
               (uu___469_2936.FStar_Tactics_Types.local_state)
           }  in
         let uu____2938 = set ps1  in
         bind uu____2938
           (fun uu____2943  ->
              let uu____2944 = FStar_BigInt.of_int_fs n  in ret uu____2944))
  
let (curms : unit -> FStar_BigInt.t tac) =
  fun uu____2952  ->
    let uu____2955 =
      let uu____2956 = FStar_Util.now_ms ()  in
      FStar_All.pipe_right uu____2956 FStar_BigInt.of_int_fs  in
    ret uu____2955
  
let (mk_irrelevant_goal :
  Prims.string ->
    env ->
      FStar_Reflection_Data.typ ->
        FStar_Options.optionstate ->
          Prims.string -> FStar_Tactics_Types.goal tac)
  =
  fun reason  ->
    fun env1  ->
      fun phi  ->
        fun opts  ->
          fun label  ->
            let typ =
              let uu____2996 =
                env1.FStar_TypeChecker_Env.universe_of env1 phi  in
              FStar_Syntax_Util.mk_squash uu____2996 phi  in
            let uu____2997 = new_uvar reason env1 typ  in
            bind uu____2997
              (fun uu____3012  ->
                 match uu____3012 with
                 | (uu____3019,ctx_uvar) ->
                     let goal =
                       FStar_Tactics_Types.mk_goal env1 ctx_uvar opts false
                         label
                        in
                     ret goal)
  
let (__tc :
  env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term * FStar_Reflection_Data.typ *
        FStar_TypeChecker_Common.guard_t) tac)
  =
  fun e  ->
    fun t  ->
      bind get
        (fun ps  ->
           mlog
             (fun uu____3066  ->
                let uu____3067 = FStar_Syntax_Print.term_to_string t  in
                FStar_Util.print1 "Tac> __tc(%s)\n" uu____3067)
             (fun uu____3072  ->
                let e1 =
                  let uu___488_3074 = e  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___488_3074.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___488_3074.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___488_3074.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___488_3074.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___488_3074.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___488_3074.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___488_3074.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___488_3074.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___488_3074.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___488_3074.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___488_3074.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___488_3074.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___488_3074.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___488_3074.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___488_3074.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___488_3074.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___488_3074.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.use_eq_strict =
                      (uu___488_3074.FStar_TypeChecker_Env.use_eq_strict);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___488_3074.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___488_3074.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax =
                      (uu___488_3074.FStar_TypeChecker_Env.lax);
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___488_3074.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___488_3074.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___488_3074.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___488_3074.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping = false;
                    FStar_TypeChecker_Env.tc_term =
                      (uu___488_3074.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___488_3074.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___488_3074.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___488_3074.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___488_3074.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___488_3074.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___488_3074.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___488_3074.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___488_3074.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___488_3074.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.try_solve_implicits_hook =
                      (uu___488_3074.FStar_TypeChecker_Env.try_solve_implicits_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___488_3074.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.mpreprocess =
                      (uu___488_3074.FStar_TypeChecker_Env.mpreprocess);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___488_3074.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___488_3074.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___488_3074.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___488_3074.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___488_3074.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___488_3074.FStar_TypeChecker_Env.nbe);
                    FStar_TypeChecker_Env.strict_args_tab =
                      (uu___488_3074.FStar_TypeChecker_Env.strict_args_tab);
                    FStar_TypeChecker_Env.erasable_types_tab =
                      (uu___488_3074.FStar_TypeChecker_Env.erasable_types_tab)
                  }  in
                try
                  (fun uu___492_3086  ->
                     match () with
                     | () ->
                         let uu____3095 =
                           FStar_TypeChecker_TcTerm.type_of_tot_term e1 t  in
                         ret uu____3095) ()
                with
                | FStar_Errors.Err (uu____3122,msg) ->
                    let uu____3126 = tts e1 t  in
                    let uu____3128 =
                      let uu____3130 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____3130
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____3126 uu____3128 msg
                | FStar_Errors.Error (uu____3140,msg,uu____3142) ->
                    let uu____3145 = tts e1 t  in
                    let uu____3147 =
                      let uu____3149 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____3149
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____3145 uu____3147 msg))
  
let (__tc_ghost :
  env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term * FStar_Reflection_Data.typ *
        FStar_TypeChecker_Common.guard_t) tac)
  =
  fun e  ->
    fun t  ->
      bind get
        (fun ps  ->
           mlog
             (fun uu____3202  ->
                let uu____3203 = FStar_Syntax_Print.term_to_string t  in
                FStar_Util.print1 "Tac> __tc_ghost(%s)\n" uu____3203)
             (fun uu____3208  ->
                let e1 =
                  let uu___509_3210 = e  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___509_3210.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___509_3210.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___509_3210.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___509_3210.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___509_3210.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___509_3210.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___509_3210.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___509_3210.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___509_3210.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___509_3210.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___509_3210.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___509_3210.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___509_3210.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___509_3210.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___509_3210.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___509_3210.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___509_3210.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.use_eq_strict =
                      (uu___509_3210.FStar_TypeChecker_Env.use_eq_strict);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___509_3210.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___509_3210.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax =
                      (uu___509_3210.FStar_TypeChecker_Env.lax);
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___509_3210.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___509_3210.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___509_3210.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___509_3210.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping = false;
                    FStar_TypeChecker_Env.tc_term =
                      (uu___509_3210.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___509_3210.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___509_3210.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___509_3210.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___509_3210.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___509_3210.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___509_3210.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___509_3210.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___509_3210.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___509_3210.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.try_solve_implicits_hook =
                      (uu___509_3210.FStar_TypeChecker_Env.try_solve_implicits_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___509_3210.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.mpreprocess =
                      (uu___509_3210.FStar_TypeChecker_Env.mpreprocess);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___509_3210.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___509_3210.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___509_3210.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___509_3210.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___509_3210.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___509_3210.FStar_TypeChecker_Env.nbe);
                    FStar_TypeChecker_Env.strict_args_tab =
                      (uu___509_3210.FStar_TypeChecker_Env.strict_args_tab);
                    FStar_TypeChecker_Env.erasable_types_tab =
                      (uu___509_3210.FStar_TypeChecker_Env.erasable_types_tab)
                  }  in
                try
                  (fun uu___513_3225  ->
                     match () with
                     | () ->
                         let uu____3234 =
                           FStar_TypeChecker_TcTerm.tc_tot_or_gtot_term e1 t
                            in
                         (match uu____3234 with
                          | (t1,lc,g) ->
                              ret
                                (t1, (lc.FStar_TypeChecker_Common.res_typ),
                                  g))) ()
                with
                | FStar_Errors.Err (uu____3272,msg) ->
                    let uu____3276 = tts e1 t  in
                    let uu____3278 =
                      let uu____3280 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____3280
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____3276 uu____3278 msg
                | FStar_Errors.Error (uu____3290,msg,uu____3292) ->
                    let uu____3295 = tts e1 t  in
                    let uu____3297 =
                      let uu____3299 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____3299
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____3295 uu____3297 msg))
  
let (__tc_lax :
  env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term * FStar_TypeChecker_Common.lcomp *
        FStar_TypeChecker_Common.guard_t) tac)
  =
  fun e  ->
    fun t  ->
      bind get
        (fun ps  ->
           mlog
             (fun uu____3352  ->
                let uu____3353 = FStar_Syntax_Print.term_to_string t  in
                FStar_Util.print1 "Tac> __tc_lax(%s)\n" uu____3353)
             (fun uu____3359  ->
                let e1 =
                  let uu___534_3361 = e  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___534_3361.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___534_3361.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___534_3361.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___534_3361.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___534_3361.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___534_3361.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___534_3361.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___534_3361.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___534_3361.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___534_3361.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___534_3361.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___534_3361.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___534_3361.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___534_3361.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___534_3361.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___534_3361.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___534_3361.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.use_eq_strict =
                      (uu___534_3361.FStar_TypeChecker_Env.use_eq_strict);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___534_3361.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___534_3361.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax =
                      (uu___534_3361.FStar_TypeChecker_Env.lax);
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___534_3361.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___534_3361.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___534_3361.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___534_3361.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping = false;
                    FStar_TypeChecker_Env.tc_term =
                      (uu___534_3361.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___534_3361.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___534_3361.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___534_3361.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___534_3361.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___534_3361.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___534_3361.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___534_3361.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___534_3361.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___534_3361.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.try_solve_implicits_hook =
                      (uu___534_3361.FStar_TypeChecker_Env.try_solve_implicits_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___534_3361.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.mpreprocess =
                      (uu___534_3361.FStar_TypeChecker_Env.mpreprocess);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___534_3361.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___534_3361.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___534_3361.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___534_3361.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___534_3361.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___534_3361.FStar_TypeChecker_Env.nbe);
                    FStar_TypeChecker_Env.strict_args_tab =
                      (uu___534_3361.FStar_TypeChecker_Env.strict_args_tab);
                    FStar_TypeChecker_Env.erasable_types_tab =
                      (uu___534_3361.FStar_TypeChecker_Env.erasable_types_tab)
                  }  in
                let e2 =
                  let uu___537_3364 = e1  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___537_3364.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___537_3364.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___537_3364.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___537_3364.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___537_3364.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___537_3364.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___537_3364.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___537_3364.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___537_3364.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___537_3364.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___537_3364.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___537_3364.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___537_3364.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___537_3364.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___537_3364.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___537_3364.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___537_3364.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.use_eq_strict =
                      (uu___537_3364.FStar_TypeChecker_Env.use_eq_strict);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___537_3364.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___537_3364.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax = true;
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___537_3364.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___537_3364.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___537_3364.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___537_3364.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping =
                      (uu___537_3364.FStar_TypeChecker_Env.uvar_subtyping);
                    FStar_TypeChecker_Env.tc_term =
                      (uu___537_3364.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___537_3364.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___537_3364.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___537_3364.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___537_3364.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___537_3364.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___537_3364.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___537_3364.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___537_3364.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___537_3364.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.try_solve_implicits_hook =
                      (uu___537_3364.FStar_TypeChecker_Env.try_solve_implicits_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___537_3364.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.mpreprocess =
                      (uu___537_3364.FStar_TypeChecker_Env.mpreprocess);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___537_3364.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___537_3364.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___537_3364.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___537_3364.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___537_3364.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___537_3364.FStar_TypeChecker_Env.nbe);
                    FStar_TypeChecker_Env.strict_args_tab =
                      (uu___537_3364.FStar_TypeChecker_Env.strict_args_tab);
                    FStar_TypeChecker_Env.erasable_types_tab =
                      (uu___537_3364.FStar_TypeChecker_Env.erasable_types_tab)
                  }  in
                try
                  (fun uu___541_3376  ->
                     match () with
                     | () ->
                         let uu____3385 =
                           FStar_TypeChecker_TcTerm.tc_term e2 t  in
                         ret uu____3385) ()
                with
                | FStar_Errors.Err (uu____3412,msg) ->
                    let uu____3416 = tts e2 t  in
                    let uu____3418 =
                      let uu____3420 = FStar_TypeChecker_Env.all_binders e2
                         in
                      FStar_All.pipe_right uu____3420
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____3416 uu____3418 msg
                | FStar_Errors.Error (uu____3430,msg,uu____3432) ->
                    let uu____3435 = tts e2 t  in
                    let uu____3437 =
                      let uu____3439 = FStar_TypeChecker_Env.all_binders e2
                         in
                      FStar_All.pipe_right uu____3439
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____3435 uu____3437 msg))
  
let (istrivial : env -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun e  ->
    fun t  ->
      let steps =
        [FStar_TypeChecker_Env.Reify;
        FStar_TypeChecker_Env.UnfoldUntil FStar_Syntax_Syntax.delta_constant;
        FStar_TypeChecker_Env.Primops;
        FStar_TypeChecker_Env.Simplify;
        FStar_TypeChecker_Env.UnfoldTac;
        FStar_TypeChecker_Env.Unmeta]  in
      let t1 = normalize steps e t  in is_true t1
  
let (get_guard_policy : unit -> FStar_Tactics_Types.guard_policy tac) =
  fun uu____3473  ->
    bind get (fun ps  -> ret ps.FStar_Tactics_Types.guard_policy)
  
let (set_guard_policy : FStar_Tactics_Types.guard_policy -> unit tac) =
  fun pol  ->
    bind get
      (fun ps  ->
         set
           (let uu___562_3492 = ps  in
            {
              FStar_Tactics_Types.main_context =
                (uu___562_3492.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.all_implicits =
                (uu___562_3492.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___562_3492.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___562_3492.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___562_3492.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___562_3492.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___562_3492.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___562_3492.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy = pol;
              FStar_Tactics_Types.freshness =
                (uu___562_3492.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___562_3492.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___562_3492.FStar_Tactics_Types.local_state)
            }))
  
let with_policy : 'a . FStar_Tactics_Types.guard_policy -> 'a tac -> 'a tac =
  fun pol  ->
    fun t  ->
      let uu____3517 = get_guard_policy ()  in
      bind uu____3517
        (fun old_pol  ->
           let uu____3523 = set_guard_policy pol  in
           bind uu____3523
             (fun uu____3527  ->
                bind t
                  (fun r  ->
                     let uu____3531 = set_guard_policy old_pol  in
                     bind uu____3531 (fun uu____3535  -> ret r))))
  
let (getopts : FStar_Options.optionstate tac) =
  let uu____3539 = let uu____3544 = cur_goal ()  in trytac uu____3544  in
  bind uu____3539
    (fun uu___0_3551  ->
       match uu___0_3551 with
       | FStar_Pervasives_Native.Some g -> ret g.FStar_Tactics_Types.opts
       | FStar_Pervasives_Native.None  ->
           let uu____3557 = FStar_Options.peek ()  in ret uu____3557)
  
let (proc_guard :
  Prims.string -> env -> FStar_TypeChecker_Common.guard_t -> unit tac) =
  fun reason  ->
    fun e  ->
      fun g  ->
        mlog
          (fun uu____3582  ->
             let uu____3583 = FStar_TypeChecker_Rel.guard_to_string e g  in
             FStar_Util.print2 "Processing guard (%s:%s)\n" reason uu____3583)
          (fun uu____3588  ->
             let uu____3589 =
               add_implicits g.FStar_TypeChecker_Common.implicits  in
             bind uu____3589
               (fun uu____3593  ->
                  bind getopts
                    (fun opts  ->
                       let uu____3597 =
                         let uu____3598 =
                           FStar_TypeChecker_Rel.simplify_guard e g  in
                         uu____3598.FStar_TypeChecker_Common.guard_f  in
                       match uu____3597 with
                       | FStar_TypeChecker_Common.Trivial  -> ret ()
                       | FStar_TypeChecker_Common.NonTrivial f ->
                           let uu____3602 = istrivial e f  in
                           if uu____3602
                           then ret ()
                           else
                             bind get
                               (fun ps  ->
                                  match ps.FStar_Tactics_Types.guard_policy
                                  with
                                  | FStar_Tactics_Types.Drop  ->
                                      ((let uu____3615 =
                                          let uu____3621 =
                                            let uu____3623 =
                                              FStar_TypeChecker_Rel.guard_to_string
                                                e g
                                               in
                                            FStar_Util.format1
                                              "Tactics admitted guard <%s>\n\n"
                                              uu____3623
                                             in
                                          (FStar_Errors.Warning_TacAdmit,
                                            uu____3621)
                                           in
                                        FStar_Errors.log_issue
                                          e.FStar_TypeChecker_Env.range
                                          uu____3615);
                                       ret ())
                                  | FStar_Tactics_Types.Goal  ->
                                      mlog
                                        (fun uu____3629  ->
                                           let uu____3630 =
                                             FStar_TypeChecker_Rel.guard_to_string
                                               e g
                                              in
                                           FStar_Util.print2
                                             "Making guard (%s:%s) into a goal\n"
                                             reason uu____3630)
                                        (fun uu____3635  ->
                                           let uu____3636 =
                                             mk_irrelevant_goal reason e f
                                               opts ""
                                              in
                                           bind uu____3636
                                             (fun goal  ->
                                                let goal1 =
                                                  let uu___591_3644 = goal
                                                     in
                                                  {
                                                    FStar_Tactics_Types.goal_main_env
                                                      =
                                                      (uu___591_3644.FStar_Tactics_Types.goal_main_env);
                                                    FStar_Tactics_Types.goal_ctx_uvar
                                                      =
                                                      (uu___591_3644.FStar_Tactics_Types.goal_ctx_uvar);
                                                    FStar_Tactics_Types.opts
                                                      =
                                                      (uu___591_3644.FStar_Tactics_Types.opts);
                                                    FStar_Tactics_Types.is_guard
                                                      = true;
                                                    FStar_Tactics_Types.label
                                                      =
                                                      (uu___591_3644.FStar_Tactics_Types.label)
                                                  }  in
                                                push_goals [goal1]))
                                  | FStar_Tactics_Types.SMT  ->
                                      mlog
                                        (fun uu____3648  ->
                                           let uu____3649 =
                                             FStar_TypeChecker_Rel.guard_to_string
                                               e g
                                              in
                                           FStar_Util.print2
                                             "Sending guard (%s:%s) to SMT goal\n"
                                             reason uu____3649)
                                        (fun uu____3654  ->
                                           let uu____3655 =
                                             mk_irrelevant_goal reason e f
                                               opts ""
                                              in
                                           bind uu____3655
                                             (fun goal  ->
                                                let goal1 =
                                                  let uu___598_3663 = goal
                                                     in
                                                  {
                                                    FStar_Tactics_Types.goal_main_env
                                                      =
                                                      (uu___598_3663.FStar_Tactics_Types.goal_main_env);
                                                    FStar_Tactics_Types.goal_ctx_uvar
                                                      =
                                                      (uu___598_3663.FStar_Tactics_Types.goal_ctx_uvar);
                                                    FStar_Tactics_Types.opts
                                                      =
                                                      (uu___598_3663.FStar_Tactics_Types.opts);
                                                    FStar_Tactics_Types.is_guard
                                                      = true;
                                                    FStar_Tactics_Types.label
                                                      =
                                                      (uu___598_3663.FStar_Tactics_Types.label)
                                                  }  in
                                                push_smt_goals [goal1]))
                                  | FStar_Tactics_Types.Force  ->
                                      mlog
                                        (fun uu____3667  ->
                                           let uu____3668 =
                                             FStar_TypeChecker_Rel.guard_to_string
                                               e g
                                              in
                                           FStar_Util.print2
                                             "Forcing guard (%s:%s)\n" reason
                                             uu____3668)
                                        (fun uu____3672  ->
                                           try
                                             (fun uu___605_3677  ->
                                                match () with
                                                | () ->
                                                    let uu____3680 =
                                                      let uu____3682 =
                                                        let uu____3684 =
                                                          FStar_TypeChecker_Rel.discharge_guard_no_smt
                                                            e g
                                                           in
                                                        FStar_All.pipe_left
                                                          FStar_TypeChecker_Env.is_trivial
                                                          uu____3684
                                                         in
                                                      Prims.op_Negation
                                                        uu____3682
                                                       in
                                                    if uu____3680
                                                    then
                                                      mlog
                                                        (fun uu____3691  ->
                                                           let uu____3692 =
                                                             FStar_TypeChecker_Rel.guard_to_string
                                                               e g
                                                              in
                                                           FStar_Util.print1
                                                             "guard = %s\n"
                                                             uu____3692)
                                                        (fun uu____3696  ->
                                                           fail1
                                                             "Forcing the guard failed (%s)"
                                                             reason)
                                                    else ret ()) ()
                                           with
                                           | uu___604_3701 ->
                                               mlog
                                                 (fun uu____3706  ->
                                                    let uu____3707 =
                                                      FStar_TypeChecker_Rel.guard_to_string
                                                        e g
                                                       in
                                                    FStar_Util.print1
                                                      "guard = %s\n"
                                                      uu____3707)
                                                 (fun uu____3711  ->
                                                    fail1
                                                      "Forcing the guard failed (%s)"
                                                      reason))))))
  
let (tcc : env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.comp tac) =
  fun e  ->
    fun t  ->
      let uu____3728 =
        let uu____3731 = __tc_lax e t  in
        bind uu____3731
          (fun uu____3751  ->
             match uu____3751 with
             | (uu____3760,lc,uu____3762) ->
                 let uu____3763 =
                   let uu____3764 = FStar_TypeChecker_Common.lcomp_comp lc
                      in
                   FStar_All.pipe_right uu____3764
                     FStar_Pervasives_Native.fst
                    in
                 ret uu____3763)
         in
      FStar_All.pipe_left (wrap_err "tcc") uu____3728
  
let (tc : env -> FStar_Syntax_Syntax.term -> FStar_Reflection_Data.typ tac) =
  fun e  ->
    fun t  ->
      let uu____3793 =
        let uu____3798 = tcc e t  in
        bind uu____3798 (fun c  -> ret (FStar_Syntax_Util.comp_result c))  in
      FStar_All.pipe_left (wrap_err "tc") uu____3793
  
let (add_irrelevant_goal :
  Prims.string ->
    env ->
      FStar_Reflection_Data.typ ->
        FStar_Options.optionstate -> Prims.string -> unit tac)
  =
  fun reason  ->
    fun env1  ->
      fun phi  ->
        fun opts  ->
          fun label  ->
            let uu____3850 = mk_irrelevant_goal reason env1 phi opts label
               in
            bind uu____3850 (fun goal  -> add_goals [goal])
  
let (trivial : unit -> unit tac) =
  fun uu____3862  ->
    let uu____3865 = cur_goal ()  in
    bind uu____3865
      (fun goal  ->
         let uu____3871 =
           let uu____3873 = FStar_Tactics_Types.goal_env goal  in
           let uu____3874 = FStar_Tactics_Types.goal_type goal  in
           istrivial uu____3873 uu____3874  in
         if uu____3871
         then solve' goal FStar_Syntax_Util.exp_unit
         else
           (let uu____3880 =
              let uu____3882 = FStar_Tactics_Types.goal_env goal  in
              let uu____3883 = FStar_Tactics_Types.goal_type goal  in
              tts uu____3882 uu____3883  in
            fail1 "Not a trivial goal: %s" uu____3880))
  
let divide : 'a 'b . FStar_BigInt.t -> 'a tac -> 'b tac -> ('a * 'b) tac =
  fun n  ->
    fun l  ->
      fun r  ->
        bind get
          (fun p  ->
             let uu____3934 =
               try
                 (fun uu___664_3957  ->
                    match () with
                    | () ->
                        let uu____3968 =
                          let uu____3977 = FStar_BigInt.to_int_fs n  in
                          FStar_List.splitAt uu____3977
                            p.FStar_Tactics_Types.goals
                           in
                        ret uu____3968) ()
               with | uu___663_3988 -> fail "divide: not enough goals"  in
             bind uu____3934
               (fun uu____4025  ->
                  match uu____4025 with
                  | (lgs,rgs) ->
                      let lp =
                        let uu___646_4051 = p  in
                        {
                          FStar_Tactics_Types.main_context =
                            (uu___646_4051.FStar_Tactics_Types.main_context);
                          FStar_Tactics_Types.all_implicits =
                            (uu___646_4051.FStar_Tactics_Types.all_implicits);
                          FStar_Tactics_Types.goals = lgs;
                          FStar_Tactics_Types.smt_goals = [];
                          FStar_Tactics_Types.depth =
                            (uu___646_4051.FStar_Tactics_Types.depth);
                          FStar_Tactics_Types.__dump =
                            (uu___646_4051.FStar_Tactics_Types.__dump);
                          FStar_Tactics_Types.psc =
                            (uu___646_4051.FStar_Tactics_Types.psc);
                          FStar_Tactics_Types.entry_range =
                            (uu___646_4051.FStar_Tactics_Types.entry_range);
                          FStar_Tactics_Types.guard_policy =
                            (uu___646_4051.FStar_Tactics_Types.guard_policy);
                          FStar_Tactics_Types.freshness =
                            (uu___646_4051.FStar_Tactics_Types.freshness);
                          FStar_Tactics_Types.tac_verb_dbg =
                            (uu___646_4051.FStar_Tactics_Types.tac_verb_dbg);
                          FStar_Tactics_Types.local_state =
                            (uu___646_4051.FStar_Tactics_Types.local_state)
                        }  in
                      let uu____4052 = set lp  in
                      bind uu____4052
                        (fun uu____4060  ->
                           bind l
                             (fun a  ->
                                bind get
                                  (fun lp'  ->
                                     let rp =
                                       let uu___652_4076 = lp'  in
                                       {
                                         FStar_Tactics_Types.main_context =
                                           (uu___652_4076.FStar_Tactics_Types.main_context);
                                         FStar_Tactics_Types.all_implicits =
                                           (uu___652_4076.FStar_Tactics_Types.all_implicits);
                                         FStar_Tactics_Types.goals = rgs;
                                         FStar_Tactics_Types.smt_goals = [];
                                         FStar_Tactics_Types.depth =
                                           (uu___652_4076.FStar_Tactics_Types.depth);
                                         FStar_Tactics_Types.__dump =
                                           (uu___652_4076.FStar_Tactics_Types.__dump);
                                         FStar_Tactics_Types.psc =
                                           (uu___652_4076.FStar_Tactics_Types.psc);
                                         FStar_Tactics_Types.entry_range =
                                           (uu___652_4076.FStar_Tactics_Types.entry_range);
                                         FStar_Tactics_Types.guard_policy =
                                           (uu___652_4076.FStar_Tactics_Types.guard_policy);
                                         FStar_Tactics_Types.freshness =
                                           (uu___652_4076.FStar_Tactics_Types.freshness);
                                         FStar_Tactics_Types.tac_verb_dbg =
                                           (uu___652_4076.FStar_Tactics_Types.tac_verb_dbg);
                                         FStar_Tactics_Types.local_state =
                                           (uu___652_4076.FStar_Tactics_Types.local_state)
                                       }  in
                                     let uu____4077 = set rp  in
                                     bind uu____4077
                                       (fun uu____4085  ->
                                          bind r
                                            (fun b  ->
                                               bind get
                                                 (fun rp'  ->
                                                    let p' =
                                                      let uu___658_4101 = rp'
                                                         in
                                                      {
                                                        FStar_Tactics_Types.main_context
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.main_context);
                                                        FStar_Tactics_Types.all_implicits
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.all_implicits);
                                                        FStar_Tactics_Types.goals
                                                          =
                                                          (FStar_List.append
                                                             lp'.FStar_Tactics_Types.goals
                                                             rp'.FStar_Tactics_Types.goals);
                                                        FStar_Tactics_Types.smt_goals
                                                          =
                                                          (FStar_List.append
                                                             lp'.FStar_Tactics_Types.smt_goals
                                                             (FStar_List.append
                                                                rp'.FStar_Tactics_Types.smt_goals
                                                                p.FStar_Tactics_Types.smt_goals));
                                                        FStar_Tactics_Types.depth
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.depth);
                                                        FStar_Tactics_Types.__dump
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.__dump);
                                                        FStar_Tactics_Types.psc
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.psc);
                                                        FStar_Tactics_Types.entry_range
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.entry_range);
                                                        FStar_Tactics_Types.guard_policy
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.guard_policy);
                                                        FStar_Tactics_Types.freshness
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.freshness);
                                                        FStar_Tactics_Types.tac_verb_dbg
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.tac_verb_dbg);
                                                        FStar_Tactics_Types.local_state
                                                          =
                                                          (uu___658_4101.FStar_Tactics_Types.local_state)
                                                      }  in
                                                    let uu____4102 = set p'
                                                       in
                                                    bind uu____4102
                                                      (fun uu____4110  ->
                                                         bind
                                                           remove_solved_goals
                                                           (fun uu____4116 
                                                              -> ret (a, b)))))))))))
  
let focus : 'a . 'a tac -> 'a tac =
  fun f  ->
    let uu____4138 = divide FStar_BigInt.one f idtac  in
    bind uu____4138
      (fun uu____4151  -> match uu____4151 with | (a,()) -> ret a)
  
let rec map : 'a . 'a tac -> 'a Prims.list tac =
  fun tau  ->
    bind get
      (fun p  ->
         match p.FStar_Tactics_Types.goals with
         | [] -> ret []
         | uu____4189::uu____4190 ->
             let uu____4193 =
               let uu____4202 = map tau  in
               divide FStar_BigInt.one tau uu____4202  in
             bind uu____4193
               (fun uu____4220  ->
                  match uu____4220 with | (h,t) -> ret (h :: t)))
  
let (seq : unit tac -> unit tac -> unit tac) =
  fun t1  ->
    fun t2  ->
      let uu____4262 =
        bind t1
          (fun uu____4267  ->
             let uu____4268 = map t2  in
             bind uu____4268 (fun uu____4276  -> ret ()))
         in
      focus uu____4262
  
let (intro : unit -> FStar_Syntax_Syntax.binder tac) =
  fun uu____4286  ->
    let uu____4289 =
      let uu____4292 = cur_goal ()  in
      bind uu____4292
        (fun goal  ->
           let uu____4301 =
             let uu____4308 = FStar_Tactics_Types.goal_type goal  in
             FStar_Syntax_Util.arrow_one uu____4308  in
           match uu____4301 with
           | FStar_Pervasives_Native.Some (b,c) ->
               let uu____4317 =
                 let uu____4319 = FStar_Syntax_Util.is_total_comp c  in
                 Prims.op_Negation uu____4319  in
               if uu____4317
               then fail "Codomain is effectful"
               else
                 (let env' =
                    let uu____4328 = FStar_Tactics_Types.goal_env goal  in
                    FStar_TypeChecker_Env.push_binders uu____4328 [b]  in
                  let typ' = FStar_Syntax_Util.comp_result c  in
                  let uu____4344 = new_uvar "intro" env' typ'  in
                  bind uu____4344
                    (fun uu____4361  ->
                       match uu____4361 with
                       | (body,ctx_uvar) ->
                           let sol =
                             FStar_Syntax_Util.abs [b] body
                               (FStar_Pervasives_Native.Some
                                  (FStar_Syntax_Util.residual_comp_of_comp c))
                              in
                           let uu____4385 = set_solution goal sol  in
                           bind uu____4385
                             (fun uu____4391  ->
                                let g =
                                  FStar_Tactics_Types.mk_goal env' ctx_uvar
                                    goal.FStar_Tactics_Types.opts
                                    goal.FStar_Tactics_Types.is_guard
                                    goal.FStar_Tactics_Types.label
                                   in
                                let uu____4393 =
                                  let uu____4396 = bnorm_goal g  in
                                  replace_cur uu____4396  in
                                bind uu____4393 (fun uu____4398  -> ret b))))
           | FStar_Pervasives_Native.None  ->
               let uu____4403 =
                 let uu____4405 = FStar_Tactics_Types.goal_env goal  in
                 let uu____4406 = FStar_Tactics_Types.goal_type goal  in
                 tts uu____4405 uu____4406  in
               fail1 "goal is not an arrow (%s)" uu____4403)
       in
    FStar_All.pipe_left (wrap_err "intro") uu____4289
  
let (intro_rec :
  unit -> (FStar_Syntax_Syntax.binder * FStar_Syntax_Syntax.binder) tac) =
  fun uu____4424  ->
    let uu____4431 = cur_goal ()  in
    bind uu____4431
      (fun goal  ->
         FStar_Util.print_string
           "WARNING (intro_rec): calling this is known to cause normalizer loops\n";
         FStar_Util.print_string
           "WARNING (intro_rec): proceed at your own risk...\n";
         (let uu____4450 =
            let uu____4457 = FStar_Tactics_Types.goal_type goal  in
            FStar_Syntax_Util.arrow_one uu____4457  in
          match uu____4450 with
          | FStar_Pervasives_Native.Some (b,c) ->
              let uu____4470 =
                let uu____4472 = FStar_Syntax_Util.is_total_comp c  in
                Prims.op_Negation uu____4472  in
              if uu____4470
              then fail "Codomain is effectful"
              else
                (let bv =
                   let uu____4489 = FStar_Tactics_Types.goal_type goal  in
                   FStar_Syntax_Syntax.gen_bv "__recf"
                     FStar_Pervasives_Native.None uu____4489
                    in
                 let bs =
                   let uu____4500 = FStar_Syntax_Syntax.mk_binder bv  in
                   [uu____4500; b]  in
                 let env' =
                   let uu____4526 = FStar_Tactics_Types.goal_env goal  in
                   FStar_TypeChecker_Env.push_binders uu____4526 bs  in
                 let uu____4527 =
                   new_uvar "intro_rec" env'
                     (FStar_Syntax_Util.comp_result c)
                    in
                 bind uu____4527
                   (fun uu____4553  ->
                      match uu____4553 with
                      | (u,ctx_uvar_u) ->
                          let lb =
                            let uu____4567 =
                              FStar_Tactics_Types.goal_type goal  in
                            let uu____4570 =
                              FStar_Syntax_Util.abs [b] u
                                FStar_Pervasives_Native.None
                               in
                            FStar_Syntax_Util.mk_letbinding
                              (FStar_Util.Inl bv) [] uu____4567
                              FStar_Parser_Const.effect_Tot_lid uu____4570 []
                              FStar_Range.dummyRange
                             in
                          let body = FStar_Syntax_Syntax.bv_to_name bv  in
                          let uu____4588 =
                            FStar_Syntax_Subst.close_let_rec [lb] body  in
                          (match uu____4588 with
                           | (lbs,body1) ->
                               let tm =
                                 let uu____4610 =
                                   let uu____4611 =
                                     FStar_Tactics_Types.goal_witness goal
                                      in
                                   uu____4611.FStar_Syntax_Syntax.pos  in
                                 FStar_Syntax_Syntax.mk
                                   (FStar_Syntax_Syntax.Tm_let
                                      ((true, lbs), body1))
                                   FStar_Pervasives_Native.None uu____4610
                                  in
                               let uu____4627 = set_solution goal tm  in
                               bind uu____4627
                                 (fun uu____4636  ->
                                    let uu____4637 =
                                      let uu____4640 =
                                        bnorm_goal
                                          (let uu___729_4643 = goal  in
                                           {
                                             FStar_Tactics_Types.goal_main_env
                                               =
                                               (uu___729_4643.FStar_Tactics_Types.goal_main_env);
                                             FStar_Tactics_Types.goal_ctx_uvar
                                               = ctx_uvar_u;
                                             FStar_Tactics_Types.opts =
                                               (uu___729_4643.FStar_Tactics_Types.opts);
                                             FStar_Tactics_Types.is_guard =
                                               (uu___729_4643.FStar_Tactics_Types.is_guard);
                                             FStar_Tactics_Types.label =
                                               (uu___729_4643.FStar_Tactics_Types.label)
                                           })
                                         in
                                      replace_cur uu____4640  in
                                    bind uu____4637
                                      (fun uu____4650  ->
                                         let uu____4651 =
                                           let uu____4656 =
                                             FStar_Syntax_Syntax.mk_binder bv
                                              in
                                           (uu____4656, b)  in
                                         ret uu____4651)))))
          | FStar_Pervasives_Native.None  ->
              let uu____4665 =
                let uu____4667 = FStar_Tactics_Types.goal_env goal  in
                let uu____4668 = FStar_Tactics_Types.goal_type goal  in
                tts uu____4667 uu____4668  in
              fail1 "intro_rec: goal is not an arrow (%s)" uu____4665))
  
let (norm : FStar_Syntax_Embeddings.norm_step Prims.list -> unit tac) =
  fun s  ->
    let uu____4688 = cur_goal ()  in
    bind uu____4688
      (fun goal  ->
         mlog
           (fun uu____4695  ->
              let uu____4696 =
                let uu____4698 = FStar_Tactics_Types.goal_witness goal  in
                FStar_Syntax_Print.term_to_string uu____4698  in
              FStar_Util.print1 "norm: witness = %s\n" uu____4696)
           (fun uu____4704  ->
              let steps =
                let uu____4708 = FStar_TypeChecker_Normalize.tr_norm_steps s
                   in
                FStar_List.append
                  [FStar_TypeChecker_Env.Reify;
                  FStar_TypeChecker_Env.UnfoldTac] uu____4708
                 in
              let t =
                let uu____4712 = FStar_Tactics_Types.goal_env goal  in
                let uu____4713 = FStar_Tactics_Types.goal_type goal  in
                normalize steps uu____4712 uu____4713  in
              let uu____4714 = FStar_Tactics_Types.goal_with_type goal t  in
              replace_cur uu____4714))
  
let (norm_term_env :
  env ->
    FStar_Syntax_Embeddings.norm_step Prims.list ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun e  ->
    fun s  ->
      fun t  ->
        let uu____4739 =
          bind get
            (fun ps  ->
               let opts =
                 match ps.FStar_Tactics_Types.goals with
                 | g::uu____4747 -> g.FStar_Tactics_Types.opts
                 | uu____4750 -> FStar_Options.peek ()  in
               mlog
                 (fun uu____4755  ->
                    let uu____4756 = FStar_Syntax_Print.term_to_string t  in
                    FStar_Util.print1 "norm_term_env: t = %s\n" uu____4756)
                 (fun uu____4761  ->
                    let uu____4762 = __tc_lax e t  in
                    bind uu____4762
                      (fun uu____4783  ->
                         match uu____4783 with
                         | (t1,uu____4793,uu____4794) ->
                             let steps =
                               let uu____4798 =
                                 FStar_TypeChecker_Normalize.tr_norm_steps s
                                  in
                               FStar_List.append
                                 [FStar_TypeChecker_Env.Reify;
                                 FStar_TypeChecker_Env.UnfoldTac] uu____4798
                                in
                             let t2 =
                               normalize steps
                                 ps.FStar_Tactics_Types.main_context t1
                                in
                             mlog
                               (fun uu____4804  ->
                                  let uu____4805 =
                                    FStar_Syntax_Print.term_to_string t2  in
                                  FStar_Util.print1
                                    "norm_term_env: t' = %s\n" uu____4805)
                               (fun uu____4809  -> ret t2))))
           in
        FStar_All.pipe_left (wrap_err "norm_term") uu____4739
  
let (refine_intro : unit -> unit tac) =
  fun uu____4822  ->
    let uu____4825 =
      let uu____4828 = cur_goal ()  in
      bind uu____4828
        (fun g  ->
           let uu____4835 =
             let uu____4846 = FStar_Tactics_Types.goal_env g  in
             let uu____4847 = FStar_Tactics_Types.goal_type g  in
             FStar_TypeChecker_Rel.base_and_refinement uu____4846 uu____4847
              in
           match uu____4835 with
           | (uu____4850,FStar_Pervasives_Native.None ) ->
               fail "not a refinement"
           | (t,FStar_Pervasives_Native.Some (bv,phi)) ->
               let g1 = FStar_Tactics_Types.goal_with_type g t  in
               let uu____4876 =
                 let uu____4881 =
                   let uu____4886 =
                     let uu____4887 = FStar_Syntax_Syntax.mk_binder bv  in
                     [uu____4887]  in
                   FStar_Syntax_Subst.open_term uu____4886 phi  in
                 match uu____4881 with
                 | (bvs,phi1) ->
                     let uu____4912 =
                       let uu____4913 = FStar_List.hd bvs  in
                       FStar_Pervasives_Native.fst uu____4913  in
                     (uu____4912, phi1)
                  in
               (match uu____4876 with
                | (bv1,phi1) ->
                    let uu____4932 =
                      let uu____4935 = FStar_Tactics_Types.goal_env g  in
                      let uu____4936 =
                        let uu____4937 =
                          let uu____4940 =
                            let uu____4941 =
                              let uu____4948 =
                                FStar_Tactics_Types.goal_witness g  in
                              (bv1, uu____4948)  in
                            FStar_Syntax_Syntax.NT uu____4941  in
                          [uu____4940]  in
                        FStar_Syntax_Subst.subst uu____4937 phi1  in
                      mk_irrelevant_goal "refine_intro refinement" uu____4935
                        uu____4936 g.FStar_Tactics_Types.opts
                        g.FStar_Tactics_Types.label
                       in
                    bind uu____4932
                      (fun g2  ->
                         bind __dismiss
                           (fun uu____4957  -> add_goals [g1; g2]))))
       in
    FStar_All.pipe_left (wrap_err "refine_intro") uu____4825
  
let (__exact_now : Prims.bool -> FStar_Syntax_Syntax.term -> unit tac) =
  fun set_expected_typ  ->
    fun t  ->
      let uu____4980 = cur_goal ()  in
      bind uu____4980
        (fun goal  ->
           let env1 =
             if set_expected_typ
             then
               let uu____4989 = FStar_Tactics_Types.goal_env goal  in
               let uu____4990 = FStar_Tactics_Types.goal_type goal  in
               FStar_TypeChecker_Env.set_expected_typ uu____4989 uu____4990
             else FStar_Tactics_Types.goal_env goal  in
           let uu____4993 = __tc env1 t  in
           bind uu____4993
             (fun uu____5012  ->
                match uu____5012 with
                | (t1,typ,guard) ->
                    mlog
                      (fun uu____5027  ->
                         let uu____5028 =
                           FStar_Syntax_Print.term_to_string typ  in
                         let uu____5030 =
                           let uu____5032 = FStar_Tactics_Types.goal_env goal
                              in
                           FStar_TypeChecker_Rel.guard_to_string uu____5032
                             guard
                            in
                         FStar_Util.print2
                           "__exact_now: got type %s\n__exact_now: and guard %s\n"
                           uu____5028 uu____5030)
                      (fun uu____5036  ->
                         let uu____5037 =
                           let uu____5040 = FStar_Tactics_Types.goal_env goal
                              in
                           proc_guard "__exact typing" uu____5040 guard  in
                         bind uu____5037
                           (fun uu____5043  ->
                              mlog
                                (fun uu____5047  ->
                                   let uu____5048 =
                                     FStar_Syntax_Print.term_to_string typ
                                      in
                                   let uu____5050 =
                                     let uu____5052 =
                                       FStar_Tactics_Types.goal_type goal  in
                                     FStar_Syntax_Print.term_to_string
                                       uu____5052
                                      in
                                   FStar_Util.print2
                                     "__exact_now: unifying %s and %s\n"
                                     uu____5048 uu____5050)
                                (fun uu____5056  ->
                                   let uu____5057 =
                                     let uu____5061 =
                                       FStar_Tactics_Types.goal_env goal  in
                                     let uu____5062 =
                                       FStar_Tactics_Types.goal_type goal  in
                                     do_unify uu____5061 typ uu____5062  in
                                   bind uu____5057
                                     (fun b  ->
                                        if b
                                        then solve goal t1
                                        else
                                          (let uu____5072 =
                                             let uu____5079 =
                                               let uu____5085 =
                                                 FStar_Tactics_Types.goal_env
                                                   goal
                                                  in
                                               tts uu____5085  in
                                             let uu____5086 =
                                               FStar_Tactics_Types.goal_type
                                                 goal
                                                in
                                             FStar_TypeChecker_Err.print_discrepancy
                                               uu____5079 typ uu____5086
                                              in
                                           match uu____5072 with
                                           | (typ1,goalt) ->
                                               let uu____5095 =
                                                 let uu____5097 =
                                                   FStar_Tactics_Types.goal_env
                                                     goal
                                                    in
                                                 tts uu____5097 t1  in
                                               let uu____5098 =
                                                 let uu____5100 =
                                                   FStar_Tactics_Types.goal_env
                                                     goal
                                                    in
                                                 let uu____5101 =
                                                   FStar_Tactics_Types.goal_witness
                                                     goal
                                                    in
                                                 tts uu____5100 uu____5101
                                                  in
                                               fail4
                                                 "%s : %s does not exactly solve the goal %s (witness = %s)"
                                                 uu____5095 typ1 goalt
                                                 uu____5098)))))))
  
let (t_exact :
  Prims.bool -> Prims.bool -> FStar_Syntax_Syntax.term -> unit tac) =
  fun try_refine  ->
    fun set_expected_typ  ->
      fun tm  ->
        let uu____5127 =
          mlog
            (fun uu____5132  ->
               let uu____5133 = FStar_Syntax_Print.term_to_string tm  in
               FStar_Util.print1 "t_exact: tm = %s\n" uu____5133)
            (fun uu____5138  ->
               let uu____5139 =
                 let uu____5146 = __exact_now set_expected_typ tm  in
                 catch uu____5146  in
               bind uu____5139
                 (fun uu___2_5155  ->
                    match uu___2_5155 with
                    | FStar_Util.Inr r -> ret ()
                    | FStar_Util.Inl e when Prims.op_Negation try_refine ->
                        traise e
                    | FStar_Util.Inl e ->
                        mlog
                          (fun uu____5166  ->
                             FStar_Util.print_string
                               "__exact_now failed, trying refine...\n")
                          (fun uu____5170  ->
                             let uu____5171 =
                               let uu____5178 =
                                 let uu____5181 =
                                   norm [FStar_Syntax_Embeddings.Delta]  in
                                 bind uu____5181
                                   (fun uu____5186  ->
                                      let uu____5187 = refine_intro ()  in
                                      bind uu____5187
                                        (fun uu____5191  ->
                                           __exact_now set_expected_typ tm))
                                  in
                               catch uu____5178  in
                             bind uu____5171
                               (fun uu___1_5198  ->
                                  match uu___1_5198 with
                                  | FStar_Util.Inr r ->
                                      mlog
                                        (fun uu____5207  ->
                                           FStar_Util.print_string
                                             "__exact_now: failed after refining too\n")
                                        (fun uu____5210  -> ret ())
                                  | FStar_Util.Inl uu____5211 ->
                                      mlog
                                        (fun uu____5213  ->
                                           FStar_Util.print_string
                                             "__exact_now: was not a refinement\n")
                                        (fun uu____5216  -> traise e)))))
           in
        FStar_All.pipe_left (wrap_err "exact") uu____5127
  
let rec mapM : 'a 'b . ('a -> 'b tac) -> 'a Prims.list -> 'b Prims.list tac =
  fun f  ->
    fun l  ->
      match l with
      | [] -> ret []
      | x::xs ->
          let uu____5268 = f x  in
          bind uu____5268
            (fun y  ->
               let uu____5276 = mapM f xs  in
               bind uu____5276 (fun ys  -> ret (y :: ys)))
  
let rec (__try_unify_by_application :
  Prims.bool ->
    (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.aqual *
      FStar_Syntax_Syntax.ctx_uvar) Prims.list ->
      env ->
        FStar_Syntax_Syntax.term ->
          FStar_Syntax_Syntax.term ->
            (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.aqual *
              FStar_Syntax_Syntax.ctx_uvar) Prims.list tac)
  =
  fun only_match  ->
    fun acc  ->
      fun e  ->
        fun ty1  ->
          fun ty2  ->
            let f = if only_match then do_match else do_unify  in
            let uu____5386 = f e ty2 ty1  in
            bind uu____5386
              (fun uu___3_5400  ->
                 if uu___3_5400
                 then ret acc
                 else
                   (let uu____5420 = FStar_Syntax_Util.arrow_one ty1  in
                    match uu____5420 with
                    | FStar_Pervasives_Native.None  ->
                        let uu____5441 =
                          FStar_Syntax_Print.term_to_string ty1  in
                        let uu____5443 =
                          FStar_Syntax_Print.term_to_string ty2  in
                        fail2 "Could not instantiate, %s to %s" uu____5441
                          uu____5443
                    | FStar_Pervasives_Native.Some (b,c) ->
                        let uu____5460 =
                          let uu____5462 = FStar_Syntax_Util.is_total_comp c
                             in
                          Prims.op_Negation uu____5462  in
                        if uu____5460
                        then fail "Codomain is effectful"
                        else
                          (let uu____5486 =
                             new_uvar "apply arg" e
                               (FStar_Pervasives_Native.fst b).FStar_Syntax_Syntax.sort
                              in
                           bind uu____5486
                             (fun uu____5513  ->
                                match uu____5513 with
                                | (uvt,uv) ->
                                    let typ = FStar_Syntax_Util.comp_result c
                                       in
                                    let typ' =
                                      FStar_Syntax_Subst.subst
                                        [FStar_Syntax_Syntax.NT
                                           ((FStar_Pervasives_Native.fst b),
                                             uvt)] typ
                                       in
                                    __try_unify_by_application only_match
                                      ((uvt, (FStar_Pervasives_Native.snd b),
                                         uv) :: acc) e typ' ty2))))
  
let (try_unify_by_application :
  Prims.bool ->
    env ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.aqual *
            FStar_Syntax_Syntax.ctx_uvar) Prims.list tac)
  =
  fun only_match  ->
    fun e  ->
      fun ty1  ->
        fun ty2  -> __try_unify_by_application only_match [] e ty1 ty2
  
let (t_apply :
  Prims.bool -> Prims.bool -> FStar_Syntax_Syntax.term -> unit tac) =
  fun uopt  ->
    fun only_match  ->
      fun tm  ->
        let uu____5619 =
          mlog
            (fun uu____5624  ->
               let uu____5625 = FStar_Syntax_Print.term_to_string tm  in
               FStar_Util.print1 "t_apply: tm = %s\n" uu____5625)
            (fun uu____5630  ->
               let uu____5631 = cur_goal ()  in
               bind uu____5631
                 (fun goal  ->
                    let e = FStar_Tactics_Types.goal_env goal  in
                    let uu____5639 = __tc e tm  in
                    bind uu____5639
                      (fun uu____5660  ->
                         match uu____5660 with
                         | (tm1,typ,guard) ->
                             let typ1 = bnorm e typ  in
                             let uu____5673 =
                               let uu____5684 =
                                 FStar_Tactics_Types.goal_type goal  in
                               try_unify_by_application only_match e typ1
                                 uu____5684
                                in
                             bind uu____5673
                               (fun uvs  ->
                                  mlog
                                    (fun uu____5705  ->
                                       let uu____5706 =
                                         FStar_Common.string_of_list
                                           (fun uu____5718  ->
                                              match uu____5718 with
                                              | (t,uu____5727,uu____5728) ->
                                                  FStar_Syntax_Print.term_to_string
                                                    t) uvs
                                          in
                                       FStar_Util.print1
                                         "t_apply: found args = %s\n"
                                         uu____5706)
                                    (fun uu____5736  ->
                                       let fix_qual q =
                                         match q with
                                         | FStar_Pervasives_Native.Some
                                             (FStar_Syntax_Syntax.Meta
                                             uu____5751) ->
                                             FStar_Pervasives_Native.Some
                                               (FStar_Syntax_Syntax.Implicit
                                                  false)
                                         | uu____5755 -> q  in
                                       let w =
                                         FStar_List.fold_right
                                           (fun uu____5778  ->
                                              fun w  ->
                                                match uu____5778 with
                                                | (uvt,q,uu____5796) ->
                                                    FStar_Syntax_Util.mk_app
                                                      w [(uvt, (fix_qual q))])
                                           uvs tm1
                                          in
                                       let uvset =
                                         let uu____5828 =
                                           FStar_Syntax_Free.new_uv_set ()
                                            in
                                         FStar_List.fold_right
                                           (fun uu____5845  ->
                                              fun s  ->
                                                match uu____5845 with
                                                | (uu____5857,uu____5858,uv)
                                                    ->
                                                    let uu____5860 =
                                                      FStar_Syntax_Free.uvars
                                                        uv.FStar_Syntax_Syntax.ctx_uvar_typ
                                                       in
                                                    FStar_Util.set_union s
                                                      uu____5860) uvs
                                           uu____5828
                                          in
                                       let free_in_some_goal uv =
                                         FStar_Util.set_mem uv uvset  in
                                       let uu____5870 = solve' goal w  in
                                       bind uu____5870
                                         (fun uu____5875  ->
                                            let uu____5876 =
                                              mapM
                                                (fun uu____5893  ->
                                                   match uu____5893 with
                                                   | (uvt,q,uv) ->
                                                       let uu____5905 =
                                                         FStar_Syntax_Unionfind.find
                                                           uv.FStar_Syntax_Syntax.ctx_uvar_head
                                                          in
                                                       (match uu____5905 with
                                                        | FStar_Pervasives_Native.Some
                                                            uu____5910 ->
                                                            ret ()
                                                        | FStar_Pervasives_Native.None
                                                             ->
                                                            let uu____5911 =
                                                              uopt &&
                                                                (free_in_some_goal
                                                                   uv)
                                                               in
                                                            if uu____5911
                                                            then ret ()
                                                            else
                                                              (let uu____5918
                                                                 =
                                                                 let uu____5921
                                                                   =
                                                                   bnorm_goal
                                                                    (let uu___899_5924
                                                                    = goal
                                                                     in
                                                                    {
                                                                    FStar_Tactics_Types.goal_main_env
                                                                    =
                                                                    (uu___899_5924.FStar_Tactics_Types.goal_main_env);
                                                                    FStar_Tactics_Types.goal_ctx_uvar
                                                                    = uv;
                                                                    FStar_Tactics_Types.opts
                                                                    =
                                                                    (uu___899_5924.FStar_Tactics_Types.opts);
                                                                    FStar_Tactics_Types.is_guard
                                                                    = false;
                                                                    FStar_Tactics_Types.label
                                                                    =
                                                                    (uu___899_5924.FStar_Tactics_Types.label)
                                                                    })
                                                                    in
                                                                 [uu____5921]
                                                                  in
                                                               add_goals
                                                                 uu____5918)))
                                                uvs
                                               in
                                            bind uu____5876
                                              (fun uu____5929  ->
                                                 proc_guard "apply guard" e
                                                   guard)))))))
           in
        FStar_All.pipe_left (wrap_err "apply") uu____5619
  
let (lemma_or_sq :
  FStar_Syntax_Syntax.comp ->
    (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.option)
  =
  fun c  ->
    let ct = FStar_Syntax_Util.comp_to_comp_typ_nouniv c  in
    let uu____5957 =
      FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
        FStar_Parser_Const.effect_Lemma_lid
       in
    if uu____5957
    then
      let uu____5966 =
        match ct.FStar_Syntax_Syntax.effect_args with
        | pre::post::uu____5981 ->
            ((FStar_Pervasives_Native.fst pre),
              (FStar_Pervasives_Native.fst post))
        | uu____6034 -> failwith "apply_lemma: impossible: not a lemma"  in
      match uu____5966 with
      | (pre,post) ->
          let post1 =
            let uu____6067 =
              let uu____6078 =
                FStar_Syntax_Syntax.as_arg FStar_Syntax_Util.exp_unit  in
              [uu____6078]  in
            FStar_Syntax_Util.mk_app post uu____6067  in
          FStar_Pervasives_Native.Some (pre, post1)
    else
      (let uu____6109 =
         FStar_Syntax_Util.is_pure_effect ct.FStar_Syntax_Syntax.effect_name
          in
       if uu____6109
       then
         let uu____6118 =
           FStar_Syntax_Util.un_squash ct.FStar_Syntax_Syntax.result_typ  in
         FStar_Util.map_opt uu____6118
           (fun post  -> (FStar_Syntax_Util.t_true, post))
       else FStar_Pervasives_Native.None)
  
let rec fold_left :
  'a 'b . ('a -> 'b -> 'b tac) -> 'b -> 'a Prims.list -> 'b tac =
  fun f  ->
    fun e  ->
      fun xs  ->
        match xs with
        | [] -> ret e
        | x::xs1 ->
            let uu____6197 = f x e  in
            bind uu____6197 (fun e'  -> fold_left f e' xs1)
  
let (apply_lemma : FStar_Syntax_Syntax.term -> unit tac) =
  fun tm  ->
    let uu____6212 =
      let uu____6215 =
        bind get
          (fun ps  ->
             mlog
               (fun uu____6222  ->
                  let uu____6223 = FStar_Syntax_Print.term_to_string tm  in
                  FStar_Util.print1 "apply_lemma: tm = %s\n" uu____6223)
               (fun uu____6229  ->
                  let is_unit_t t =
                    let uu____6237 =
                      let uu____6238 = FStar_Syntax_Subst.compress t  in
                      uu____6238.FStar_Syntax_Syntax.n  in
                    match uu____6237 with
                    | FStar_Syntax_Syntax.Tm_fvar fv when
                        FStar_Syntax_Syntax.fv_eq_lid fv
                          FStar_Parser_Const.unit_lid
                        -> true
                    | uu____6244 -> false  in
                  let uu____6246 = cur_goal ()  in
                  bind uu____6246
                    (fun goal  ->
                       let uu____6252 =
                         let uu____6261 = FStar_Tactics_Types.goal_env goal
                            in
                         __tc uu____6261 tm  in
                       bind uu____6252
                         (fun uu____6276  ->
                            match uu____6276 with
                            | (tm1,t,guard) ->
                                let uu____6288 =
                                  FStar_Syntax_Util.arrow_formals_comp t  in
                                (match uu____6288 with
                                 | (bs,comp) ->
                                     let uu____6297 = lemma_or_sq comp  in
                                     (match uu____6297 with
                                      | FStar_Pervasives_Native.None  ->
                                          fail
                                            "not a lemma or squashed function"
                                      | FStar_Pervasives_Native.Some
                                          (pre,post) ->
                                          let uu____6317 =
                                            fold_left
                                              (fun uu____6379  ->
                                                 fun uu____6380  ->
                                                   match (uu____6379,
                                                           uu____6380)
                                                   with
                                                   | ((b,aq),(uvs,imps,subst))
                                                       ->
                                                       let b_t =
                                                         FStar_Syntax_Subst.subst
                                                           subst
                                                           b.FStar_Syntax_Syntax.sort
                                                          in
                                                       let uu____6531 =
                                                         is_unit_t b_t  in
                                                       if uu____6531
                                                       then
                                                         FStar_All.pipe_left
                                                           ret
                                                           (((FStar_Syntax_Util.exp_unit,
                                                               aq) :: uvs),
                                                             imps,
                                                             ((FStar_Syntax_Syntax.NT
                                                                 (b,
                                                                   FStar_Syntax_Util.exp_unit))
                                                             :: subst))
                                                       else
                                                         (let uu____6654 =
                                                            let uu____6661 =
                                                              FStar_Tactics_Types.goal_env
                                                                goal
                                                               in
                                                            new_uvar
                                                              "apply_lemma"
                                                              uu____6661 b_t
                                                             in
                                                          bind uu____6654
                                                            (fun uu____6692 
                                                               ->
                                                               match uu____6692
                                                               with
                                                               | (t1,u) ->
                                                                   FStar_All.pipe_left
                                                                    ret
                                                                    (((t1,
                                                                    aq) ::
                                                                    uvs),
                                                                    ((t1, u)
                                                                    :: imps),
                                                                    ((FStar_Syntax_Syntax.NT
                                                                    (b, t1))
                                                                    ::
                                                                    subst)))))
                                              ([], [], []) bs
                                             in
                                          bind uu____6317
                                            (fun uu____6878  ->
                                               match uu____6878 with
                                               | (uvs,implicits1,subst) ->
                                                   let implicits2 =
                                                     FStar_List.rev
                                                       implicits1
                                                      in
                                                   let uvs1 =
                                                     FStar_List.rev uvs  in
                                                   let pre1 =
                                                     FStar_Syntax_Subst.subst
                                                       subst pre
                                                      in
                                                   let post1 =
                                                     FStar_Syntax_Subst.subst
                                                       subst post
                                                      in
                                                   let uu____6966 =
                                                     let uu____6970 =
                                                       FStar_Tactics_Types.goal_env
                                                         goal
                                                        in
                                                     let uu____6971 =
                                                       FStar_Syntax_Util.mk_squash
                                                         FStar_Syntax_Syntax.U_zero
                                                         post1
                                                        in
                                                     let uu____6972 =
                                                       FStar_Tactics_Types.goal_type
                                                         goal
                                                        in
                                                     do_unify uu____6970
                                                       uu____6971 uu____6972
                                                      in
                                                   bind uu____6966
                                                     (fun b  ->
                                                        if
                                                          Prims.op_Negation b
                                                        then
                                                          let uu____6984 =
                                                            let uu____6991 =
                                                              let uu____6997
                                                                =
                                                                FStar_Tactics_Types.goal_env
                                                                  goal
                                                                 in
                                                              tts uu____6997
                                                               in
                                                            let uu____6998 =
                                                              FStar_Syntax_Util.mk_squash
                                                                FStar_Syntax_Syntax.U_zero
                                                                post1
                                                               in
                                                            let uu____6999 =
                                                              FStar_Tactics_Types.goal_type
                                                                goal
                                                               in
                                                            FStar_TypeChecker_Err.print_discrepancy
                                                              uu____6991
                                                              uu____6998
                                                              uu____6999
                                                             in
                                                          match uu____6984
                                                          with
                                                          | (post2,goalt) ->
                                                              let uu____7008
                                                                =
                                                                let uu____7010
                                                                  =
                                                                  FStar_Tactics_Types.goal_env
                                                                    goal
                                                                   in
                                                                tts
                                                                  uu____7010
                                                                  tm1
                                                                 in
                                                              fail3
                                                                "Cannot instantiate lemma %s (with postcondition: %s) to match goal (%s)"
                                                                uu____7008
                                                                post2 goalt
                                                        else
                                                          (let uu____7014 =
                                                             solve' goal
                                                               FStar_Syntax_Util.exp_unit
                                                              in
                                                           bind uu____7014
                                                             (fun uu____7022 
                                                                ->
                                                                let is_free_uvar
                                                                  uv t1 =
                                                                  let free_uvars
                                                                    =
                                                                    let uu____7048
                                                                    =
                                                                    let uu____7051
                                                                    =
                                                                    FStar_Syntax_Free.uvars
                                                                    t1  in
                                                                    FStar_Util.set_elements
                                                                    uu____7051
                                                                     in
                                                                    FStar_List.map
                                                                    (fun x 
                                                                    ->
                                                                    x.FStar_Syntax_Syntax.ctx_uvar_head)
                                                                    uu____7048
                                                                     in
                                                                  FStar_List.existsML
                                                                    (
                                                                    fun u  ->
                                                                    FStar_Syntax_Unionfind.equiv
                                                                    u uv)
                                                                    free_uvars
                                                                   in
                                                                let appears
                                                                  uv goals =
                                                                  FStar_List.existsML
                                                                    (
                                                                    fun g' 
                                                                    ->
                                                                    let uu____7087
                                                                    =
                                                                    FStar_Tactics_Types.goal_type
                                                                    g'  in
                                                                    is_free_uvar
                                                                    uv
                                                                    uu____7087)
                                                                    goals
                                                                   in
                                                                let checkone
                                                                  t1 goals =
                                                                  let uu____7104
                                                                    =
                                                                    FStar_Syntax_Util.head_and_args
                                                                    t1  in
                                                                  match uu____7104
                                                                  with
                                                                  | (hd,uu____7123)
                                                                    ->
                                                                    (match 
                                                                    hd.FStar_Syntax_Syntax.n
                                                                    with
                                                                    | 
                                                                    FStar_Syntax_Syntax.Tm_uvar
                                                                    (uv,uu____7150)
                                                                    ->
                                                                    appears
                                                                    uv.FStar_Syntax_Syntax.ctx_uvar_head
                                                                    goals
                                                                    | 
                                                                    uu____7167
                                                                    -> false)
                                                                   in
                                                                let uu____7169
                                                                  =
                                                                  FStar_All.pipe_right
                                                                    implicits2
                                                                    (
                                                                    mapM
                                                                    (fun imp 
                                                                    ->
                                                                    let uu____7210
                                                                    = imp  in
                                                                    match uu____7210
                                                                    with
                                                                    | 
                                                                    (term,ctx_uvar)
                                                                    ->
                                                                    let uu____7221
                                                                    =
                                                                    FStar_Syntax_Util.head_and_args
                                                                    term  in
                                                                    (match uu____7221
                                                                    with
                                                                    | 
                                                                    (hd,uu____7243)
                                                                    ->
                                                                    let uu____7268
                                                                    =
                                                                    let uu____7269
                                                                    =
                                                                    FStar_Syntax_Subst.compress
                                                                    hd  in
                                                                    uu____7269.FStar_Syntax_Syntax.n
                                                                     in
                                                                    (match uu____7268
                                                                    with
                                                                    | 
                                                                    FStar_Syntax_Syntax.Tm_uvar
                                                                    (ctx_uvar1,uu____7277)
                                                                    ->
                                                                    let goal1
                                                                    =
                                                                    bnorm_goal
                                                                    (let uu___1016_7297
                                                                    = goal
                                                                     in
                                                                    {
                                                                    FStar_Tactics_Types.goal_main_env
                                                                    =
                                                                    (uu___1016_7297.FStar_Tactics_Types.goal_main_env);
                                                                    FStar_Tactics_Types.goal_ctx_uvar
                                                                    =
                                                                    ctx_uvar1;
                                                                    FStar_Tactics_Types.opts
                                                                    =
                                                                    (uu___1016_7297.FStar_Tactics_Types.opts);
                                                                    FStar_Tactics_Types.is_guard
                                                                    =
                                                                    (uu___1016_7297.FStar_Tactics_Types.is_guard);
                                                                    FStar_Tactics_Types.label
                                                                    =
                                                                    (uu___1016_7297.FStar_Tactics_Types.label)
                                                                    })  in
                                                                    ret
                                                                    [goal1]
                                                                    | 
                                                                    uu____7300
                                                                    ->
                                                                    mlog
                                                                    (fun
                                                                    uu____7306
                                                                     ->
                                                                    let uu____7307
                                                                    =
                                                                    FStar_Syntax_Print.uvar_to_string
                                                                    ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_head
                                                                     in
                                                                    let uu____7309
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    term  in
                                                                    FStar_Util.print2
                                                                    "apply_lemma: arg %s unified to (%s)\n"
                                                                    uu____7307
                                                                    uu____7309)
                                                                    (fun
                                                                    uu____7315
                                                                     ->
                                                                    let g_typ
                                                                    =
                                                                    let uu____7317
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    FStar_TypeChecker_TcTerm.check_type_of_well_typed_term'
                                                                    true
                                                                    uu____7317
                                                                    term
                                                                    ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_typ
                                                                     in
                                                                    let uu____7319
                                                                    =
                                                                    let uu____7322
                                                                    =
                                                                    if
                                                                    ps.FStar_Tactics_Types.tac_verb_dbg
                                                                    then
                                                                    let uu____7326
                                                                    =
                                                                    FStar_Syntax_Print.ctx_uvar_to_string
                                                                    ctx_uvar
                                                                     in
                                                                    let uu____7328
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    term  in
                                                                    FStar_Util.format2
                                                                    "apply_lemma solved arg %s to %s\n"
                                                                    uu____7326
                                                                    uu____7328
                                                                    else
                                                                    "apply_lemma solved arg"
                                                                     in
                                                                    let uu____7334
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    proc_guard
                                                                    uu____7322
                                                                    uu____7334
                                                                    g_typ  in
                                                                    bind
                                                                    uu____7319
                                                                    (fun
                                                                    uu____7338
                                                                     ->
                                                                    ret []))))))
                                                                   in
                                                                bind
                                                                  uu____7169
                                                                  (fun
                                                                    sub_goals
                                                                     ->
                                                                    let sub_goals1
                                                                    =
                                                                    FStar_List.flatten
                                                                    sub_goals
                                                                     in
                                                                    let rec filter'
                                                                    f xs =
                                                                    match xs
                                                                    with
                                                                    | 
                                                                    [] -> []
                                                                    | 
                                                                    x::xs1 ->
                                                                    let uu____7402
                                                                    = f x xs1
                                                                     in
                                                                    if
                                                                    uu____7402
                                                                    then
                                                                    let uu____7407
                                                                    =
                                                                    filter' f
                                                                    xs1  in x
                                                                    ::
                                                                    uu____7407
                                                                    else
                                                                    filter' f
                                                                    xs1  in
                                                                    let sub_goals2
                                                                    =
                                                                    filter'
                                                                    (fun g 
                                                                    ->
                                                                    fun goals
                                                                     ->
                                                                    let uu____7422
                                                                    =
                                                                    let uu____7424
                                                                    =
                                                                    FStar_Tactics_Types.goal_witness
                                                                    g  in
                                                                    checkone
                                                                    uu____7424
                                                                    goals  in
                                                                    Prims.op_Negation
                                                                    uu____7422)
                                                                    sub_goals1
                                                                     in
                                                                    let uu____7425
                                                                    =
                                                                    let uu____7428
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    proc_guard
                                                                    "apply_lemma guard"
                                                                    uu____7428
                                                                    guard  in
                                                                    bind
                                                                    uu____7425
                                                                    (fun
                                                                    uu____7432
                                                                     ->
                                                                    let uu____7433
                                                                    =
                                                                    let uu____7436
                                                                    =
                                                                    let uu____7438
                                                                    =
                                                                    let uu____7440
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    let uu____7441
                                                                    =
                                                                    FStar_Syntax_Util.mk_squash
                                                                    FStar_Syntax_Syntax.U_zero
                                                                    pre1  in
                                                                    istrivial
                                                                    uu____7440
                                                                    uu____7441
                                                                     in
                                                                    Prims.op_Negation
                                                                    uu____7438
                                                                     in
                                                                    if
                                                                    uu____7436
                                                                    then
                                                                    let uu____7445
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    add_irrelevant_goal
                                                                    "apply_lemma precondition"
                                                                    uu____7445
                                                                    pre1
                                                                    goal.FStar_Tactics_Types.opts
                                                                    goal.FStar_Tactics_Types.label
                                                                    else
                                                                    ret ()
                                                                     in
                                                                    bind
                                                                    uu____7433
                                                                    (fun
                                                                    uu____7450
                                                                     ->
                                                                    add_goals
                                                                    sub_goals2)))))))))))))
         in
      focus uu____6215  in
    FStar_All.pipe_left (wrap_err "apply_lemma") uu____6212
  
let (destruct_eq' :
  FStar_Reflection_Data.typ ->
    (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.option)
  =
  fun typ  ->
    let uu____7474 = FStar_Syntax_Util.destruct_typ_as_formula typ  in
    match uu____7474 with
    | FStar_Pervasives_Native.Some (FStar_Syntax_Util.BaseConn
        (l,uu____7484::(e1,FStar_Pervasives_Native.None )::(e2,FStar_Pervasives_Native.None
                                                            )::[]))
        when
        (FStar_Ident.lid_equals l FStar_Parser_Const.eq2_lid) ||
          (FStar_Ident.lid_equals l FStar_Parser_Const.c_eq2_lid)
        -> FStar_Pervasives_Native.Some (e1, e2)
    | FStar_Pervasives_Native.Some (FStar_Syntax_Util.BaseConn
        (l,uu____7544::uu____7545::(e1,uu____7547)::(e2,uu____7549)::[]))
        when FStar_Ident.lid_equals l FStar_Parser_Const.eq3_lid ->
        FStar_Pervasives_Native.Some (e1, e2)
    | uu____7626 ->
        let uu____7629 = FStar_Syntax_Util.unb2t typ  in
        (match uu____7629 with
         | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
         | FStar_Pervasives_Native.Some t ->
             let uu____7643 = FStar_Syntax_Util.head_and_args t  in
             (match uu____7643 with
              | (hd,args) ->
                  let uu____7692 =
                    let uu____7707 =
                      let uu____7708 = FStar_Syntax_Subst.compress hd  in
                      uu____7708.FStar_Syntax_Syntax.n  in
                    (uu____7707, args)  in
                  (match uu____7692 with
                   | (FStar_Syntax_Syntax.Tm_fvar
                      fv,(uu____7728,FStar_Pervasives_Native.Some
                          (FStar_Syntax_Syntax.Implicit uu____7729))::
                      (e1,FStar_Pervasives_Native.None )::(e2,FStar_Pervasives_Native.None
                                                           )::[])
                       when
                       FStar_Syntax_Syntax.fv_eq_lid fv
                         FStar_Parser_Const.op_Eq
                       -> FStar_Pervasives_Native.Some (e1, e2)
                   | uu____7797 -> FStar_Pervasives_Native.None)))
  
let (destruct_eq :
  FStar_Reflection_Data.typ ->
    (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.option)
  =
  fun typ  ->
    let uu____7834 = destruct_eq' typ  in
    match uu____7834 with
    | FStar_Pervasives_Native.Some t -> FStar_Pervasives_Native.Some t
    | FStar_Pervasives_Native.None  ->
        let uu____7864 = FStar_Syntax_Util.un_squash typ  in
        (match uu____7864 with
         | FStar_Pervasives_Native.Some typ1 -> destruct_eq' typ1
         | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None)
  
let (split_env :
  FStar_Syntax_Syntax.bv ->
    env ->
      (env * FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.bv Prims.list)
        FStar_Pervasives_Native.option)
  =
  fun bvar  ->
    fun e  ->
      let rec aux e1 =
        let uu____7933 = FStar_TypeChecker_Env.pop_bv e1  in
        match uu____7933 with
        | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
        | FStar_Pervasives_Native.Some (bv',e') ->
            if FStar_Syntax_Syntax.bv_eq bvar bv'
            then FStar_Pervasives_Native.Some (e', bv', [])
            else
              (let uu____7991 = aux e'  in
               FStar_Util.map_opt uu____7991
                 (fun uu____8022  ->
                    match uu____8022 with
                    | (e'',bv,bvs) -> (e'', bv, (bv' :: bvs))))
         in
      let uu____8048 = aux e  in
      FStar_Util.map_opt uu____8048
        (fun uu____8079  ->
           match uu____8079 with
           | (e',bv,bvs) -> (e', bv, (FStar_List.rev bvs)))
  
let (push_bvs :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.bv Prims.list -> FStar_TypeChecker_Env.env)
  =
  fun e  ->
    fun bvs  ->
      FStar_List.fold_left
        (fun e1  -> fun b  -> FStar_TypeChecker_Env.push_bv e1 b) e bvs
  
let (subst_goal :
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.bv ->
      FStar_Syntax_Syntax.subst_elt Prims.list ->
        FStar_Tactics_Types.goal ->
          FStar_Tactics_Types.goal FStar_Pervasives_Native.option tac)
  =
  fun b1  ->
    fun b2  ->
      fun s  ->
        fun g  ->
          let uu____8157 =
            let uu____8168 = FStar_Tactics_Types.goal_env g  in
            split_env b1 uu____8168  in
          match uu____8157 with
          | FStar_Pervasives_Native.Some (e0,b11,bvs) ->
              let s1 bv =
                let uu___1127_8194 = bv  in
                let uu____8195 =
                  FStar_Syntax_Subst.subst s bv.FStar_Syntax_Syntax.sort  in
                {
                  FStar_Syntax_Syntax.ppname =
                    (uu___1127_8194.FStar_Syntax_Syntax.ppname);
                  FStar_Syntax_Syntax.index =
                    (uu___1127_8194.FStar_Syntax_Syntax.index);
                  FStar_Syntax_Syntax.sort = uu____8195
                }  in
              let bvs' = FStar_List.map s1 bvs  in
              let new_env = push_bvs e0 (b2 :: bvs')  in
              let new_goal_ty =
                let uu____8203 = FStar_Tactics_Types.goal_type g  in
                FStar_Syntax_Subst.subst s uu____8203  in
              let uu____8204 = new_uvar "subst_goal" new_env new_goal_ty  in
              bind uu____8204
                (fun uu____8224  ->
                   match uu____8224 with
                   | (uvt,uv) ->
                       let goal' =
                         FStar_Tactics_Types.mk_goal new_env uv
                           g.FStar_Tactics_Types.opts
                           g.FStar_Tactics_Types.is_guard
                           g.FStar_Tactics_Types.label
                          in
                       let sol =
                         let uu____8239 =
                           let uu____8242 =
                             FStar_List.map FStar_Syntax_Syntax.mk_binder (b2
                               :: bvs')
                              in
                           FStar_Syntax_Util.abs uu____8242 uvt
                             FStar_Pervasives_Native.None
                            in
                         let uu____8249 =
                           FStar_List.map
                             (fun bv  ->
                                let uu____8263 =
                                  FStar_Syntax_Syntax.bv_to_name bv  in
                                FStar_Syntax_Syntax.as_arg uu____8263) (b11
                             :: bvs)
                            in
                         FStar_Syntax_Util.mk_app uu____8239 uu____8249  in
                       let uu____8264 = set_solution g sol  in
                       bind uu____8264
                         (fun uu____8270  ->
                            ret (FStar_Pervasives_Native.Some goal')))
          | FStar_Pervasives_Native.None  -> ret FStar_Pervasives_Native.None
  
let (rewrite : FStar_Syntax_Syntax.binder -> unit tac) =
  fun h  ->
    let uu____8293 =
      let uu____8296 = cur_goal ()  in
      bind uu____8296
        (fun goal  ->
           let uu____8304 = h  in
           match uu____8304 with
           | (bv,uu____8308) ->
               mlog
                 (fun uu____8316  ->
                    let uu____8317 = FStar_Syntax_Print.bv_to_string bv  in
                    let uu____8319 =
                      FStar_Syntax_Print.term_to_string
                        bv.FStar_Syntax_Syntax.sort
                       in
                    FStar_Util.print2 "+++Rewrite %s : %s\n" uu____8317
                      uu____8319)
                 (fun uu____8324  ->
                    let uu____8325 =
                      let uu____8336 = FStar_Tactics_Types.goal_env goal  in
                      split_env bv uu____8336  in
                    match uu____8325 with
                    | FStar_Pervasives_Native.None  ->
                        fail "binder not found in environment"
                    | FStar_Pervasives_Native.Some (e0,bv1,bvs) ->
                        let uu____8363 =
                          destruct_eq bv1.FStar_Syntax_Syntax.sort  in
                        (match uu____8363 with
                         | FStar_Pervasives_Native.Some (x,e) ->
                             let uu____8378 =
                               let uu____8379 = FStar_Syntax_Subst.compress x
                                  in
                               uu____8379.FStar_Syntax_Syntax.n  in
                             (match uu____8378 with
                              | FStar_Syntax_Syntax.Tm_name x1 ->
                                  let s = [FStar_Syntax_Syntax.NT (x1, e)]
                                     in
                                  let s1 bv2 =
                                    let uu___1161_8396 = bv2  in
                                    let uu____8397 =
                                      FStar_Syntax_Subst.subst s
                                        bv2.FStar_Syntax_Syntax.sort
                                       in
                                    {
                                      FStar_Syntax_Syntax.ppname =
                                        (uu___1161_8396.FStar_Syntax_Syntax.ppname);
                                      FStar_Syntax_Syntax.index =
                                        (uu___1161_8396.FStar_Syntax_Syntax.index);
                                      FStar_Syntax_Syntax.sort = uu____8397
                                    }  in
                                  let bvs' = FStar_List.map s1 bvs  in
                                  let new_env = push_bvs e0 (bv1 :: bvs')  in
                                  let new_goal_ty =
                                    let uu____8405 =
                                      FStar_Tactics_Types.goal_type goal  in
                                    FStar_Syntax_Subst.subst s uu____8405  in
                                  let uu____8406 =
                                    new_uvar "rewrite" new_env new_goal_ty
                                     in
                                  bind uu____8406
                                    (fun uu____8424  ->
                                       match uu____8424 with
                                       | (uvt,uv) ->
                                           let goal' =
                                             FStar_Tactics_Types.mk_goal
                                               new_env uv
                                               goal.FStar_Tactics_Types.opts
                                               goal.FStar_Tactics_Types.is_guard
                                               goal.FStar_Tactics_Types.label
                                              in
                                           let sol =
                                             let uu____8437 =
                                               let uu____8440 =
                                                 FStar_List.map
                                                   FStar_Syntax_Syntax.mk_binder
                                                   bvs'
                                                  in
                                               FStar_Syntax_Util.abs
                                                 uu____8440 uvt
                                                 FStar_Pervasives_Native.None
                                                in
                                             let uu____8447 =
                                               FStar_List.map
                                                 (fun bv2  ->
                                                    let uu____8461 =
                                                      FStar_Syntax_Syntax.bv_to_name
                                                        bv2
                                                       in
                                                    FStar_Syntax_Syntax.as_arg
                                                      uu____8461) bvs
                                                in
                                             FStar_Syntax_Util.mk_app
                                               uu____8437 uu____8447
                                              in
                                           let uu____8462 =
                                             set_solution goal sol  in
                                           bind uu____8462
                                             (fun uu____8466  ->
                                                replace_cur goal'))
                              | uu____8467 ->
                                  fail
                                    "Not an equality hypothesis with a variable on the LHS")
                         | uu____8469 -> fail "Not an equality hypothesis")))
       in
    FStar_All.pipe_left (wrap_err "rewrite") uu____8293
  
let (rename_to :
  FStar_Syntax_Syntax.binder ->
    Prims.string -> FStar_Syntax_Syntax.binder tac)
  =
  fun b  ->
    fun s  ->
      let uu____8499 =
        let uu____8508 = cur_goal ()  in
        bind uu____8508
          (fun goal  ->
             let uu____8525 = b  in
             match uu____8525 with
             | (bv,q) ->
                 let bv' =
                   let uu____8541 =
                     let uu___1182_8542 = bv  in
                     let uu____8543 =
                       FStar_Ident.mk_ident
                         (s,
                           ((bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idRange))
                        in
                     {
                       FStar_Syntax_Syntax.ppname = uu____8543;
                       FStar_Syntax_Syntax.index =
                         (uu___1182_8542.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort =
                         (uu___1182_8542.FStar_Syntax_Syntax.sort)
                     }  in
                   FStar_Syntax_Syntax.freshen_bv uu____8541  in
                 let s1 =
                   let uu____8548 =
                     let uu____8549 =
                       let uu____8556 = FStar_Syntax_Syntax.bv_to_name bv'
                          in
                       (bv, uu____8556)  in
                     FStar_Syntax_Syntax.NT uu____8549  in
                   [uu____8548]  in
                 let uu____8561 = subst_goal bv bv' s1 goal  in
                 bind uu____8561
                   (fun uu___4_8575  ->
                      match uu___4_8575 with
                      | FStar_Pervasives_Native.None  ->
                          fail "binder not found in environment"
                      | FStar_Pervasives_Native.Some goal1 ->
                          let uu____8594 = replace_cur goal1  in
                          bind uu____8594 (fun uu____8604  -> ret (bv', q))))
         in
      FStar_All.pipe_left (wrap_err "rename_to") uu____8499
  
let (binder_retype : FStar_Syntax_Syntax.binder -> unit tac) =
  fun b  ->
    let uu____8640 =
      let uu____8643 = cur_goal ()  in
      bind uu____8643
        (fun goal  ->
           let uu____8652 = b  in
           match uu____8652 with
           | (bv,uu____8656) ->
               let uu____8661 =
                 let uu____8672 = FStar_Tactics_Types.goal_env goal  in
                 split_env bv uu____8672  in
               (match uu____8661 with
                | FStar_Pervasives_Native.None  ->
                    fail "binder is not present in environment"
                | FStar_Pervasives_Native.Some (e0,bv1,bvs) ->
                    let uu____8699 = FStar_Syntax_Util.type_u ()  in
                    (match uu____8699 with
                     | (ty,u) ->
                         let uu____8708 = new_uvar "binder_retype" e0 ty  in
                         bind uu____8708
                           (fun uu____8727  ->
                              match uu____8727 with
                              | (t',u_t') ->
                                  let bv'' =
                                    let uu___1208_8737 = bv1  in
                                    {
                                      FStar_Syntax_Syntax.ppname =
                                        (uu___1208_8737.FStar_Syntax_Syntax.ppname);
                                      FStar_Syntax_Syntax.index =
                                        (uu___1208_8737.FStar_Syntax_Syntax.index);
                                      FStar_Syntax_Syntax.sort = t'
                                    }  in
                                  let s =
                                    let uu____8741 =
                                      let uu____8742 =
                                        let uu____8749 =
                                          FStar_Syntax_Syntax.bv_to_name bv''
                                           in
                                        (bv1, uu____8749)  in
                                      FStar_Syntax_Syntax.NT uu____8742  in
                                    [uu____8741]  in
                                  let bvs1 =
                                    FStar_List.map
                                      (fun b1  ->
                                         let uu___1213_8761 = b1  in
                                         let uu____8762 =
                                           FStar_Syntax_Subst.subst s
                                             b1.FStar_Syntax_Syntax.sort
                                            in
                                         {
                                           FStar_Syntax_Syntax.ppname =
                                             (uu___1213_8761.FStar_Syntax_Syntax.ppname);
                                           FStar_Syntax_Syntax.index =
                                             (uu___1213_8761.FStar_Syntax_Syntax.index);
                                           FStar_Syntax_Syntax.sort =
                                             uu____8762
                                         }) bvs
                                     in
                                  let env' = push_bvs e0 (bv'' :: bvs1)  in
                                  bind __dismiss
                                    (fun uu____8769  ->
                                       let new_goal =
                                         let uu____8771 =
                                           FStar_Tactics_Types.goal_with_env
                                             goal env'
                                            in
                                         let uu____8772 =
                                           let uu____8773 =
                                             FStar_Tactics_Types.goal_type
                                               goal
                                              in
                                           FStar_Syntax_Subst.subst s
                                             uu____8773
                                            in
                                         FStar_Tactics_Types.goal_with_type
                                           uu____8771 uu____8772
                                          in
                                       let uu____8774 = add_goals [new_goal]
                                          in
                                       bind uu____8774
                                         (fun uu____8779  ->
                                            let uu____8780 =
                                              FStar_Syntax_Util.mk_eq2
                                                (FStar_Syntax_Syntax.U_succ u)
                                                ty
                                                bv1.FStar_Syntax_Syntax.sort
                                                t'
                                               in
                                            add_irrelevant_goal
                                              "binder_retype equation" e0
                                              uu____8780
                                              goal.FStar_Tactics_Types.opts
                                              goal.FStar_Tactics_Types.label))))))
       in
    FStar_All.pipe_left (wrap_err "binder_retype") uu____8640
  
let (norm_binder_type :
  FStar_Syntax_Embeddings.norm_step Prims.list ->
    FStar_Syntax_Syntax.binder -> unit tac)
  =
  fun s  ->
    fun b  ->
      let uu____8806 =
        let uu____8809 = cur_goal ()  in
        bind uu____8809
          (fun goal  ->
             let uu____8818 = b  in
             match uu____8818 with
             | (bv,uu____8822) ->
                 let uu____8827 =
                   let uu____8838 = FStar_Tactics_Types.goal_env goal  in
                   split_env bv uu____8838  in
                 (match uu____8827 with
                  | FStar_Pervasives_Native.None  ->
                      fail "binder is not present in environment"
                  | FStar_Pervasives_Native.Some (e0,bv1,bvs) ->
                      let steps =
                        let uu____8868 =
                          FStar_TypeChecker_Normalize.tr_norm_steps s  in
                        FStar_List.append
                          [FStar_TypeChecker_Env.Reify;
                          FStar_TypeChecker_Env.UnfoldTac] uu____8868
                         in
                      let sort' =
                        normalize steps e0 bv1.FStar_Syntax_Syntax.sort  in
                      let bv' =
                        let uu___1234_8873 = bv1  in
                        {
                          FStar_Syntax_Syntax.ppname =
                            (uu___1234_8873.FStar_Syntax_Syntax.ppname);
                          FStar_Syntax_Syntax.index =
                            (uu___1234_8873.FStar_Syntax_Syntax.index);
                          FStar_Syntax_Syntax.sort = sort'
                        }  in
                      let env' = push_bvs e0 (bv' :: bvs)  in
                      let uu____8875 =
                        FStar_Tactics_Types.goal_with_env goal env'  in
                      replace_cur uu____8875))
         in
      FStar_All.pipe_left (wrap_err "norm_binder_type") uu____8806
  
let (revert : unit -> unit tac) =
  fun uu____8888  ->
    let uu____8891 = cur_goal ()  in
    bind uu____8891
      (fun goal  ->
         let uu____8897 =
           let uu____8904 = FStar_Tactics_Types.goal_env goal  in
           FStar_TypeChecker_Env.pop_bv uu____8904  in
         match uu____8897 with
         | FStar_Pervasives_Native.None  ->
             fail "Cannot revert; empty context"
         | FStar_Pervasives_Native.Some (x,env') ->
             let typ' =
               let uu____8921 =
                 let uu____8924 = FStar_Tactics_Types.goal_type goal  in
                 FStar_Syntax_Syntax.mk_Total uu____8924  in
               FStar_Syntax_Util.arrow [(x, FStar_Pervasives_Native.None)]
                 uu____8921
                in
             let uu____8939 = new_uvar "revert" env' typ'  in
             bind uu____8939
               (fun uu____8955  ->
                  match uu____8955 with
                  | (r,u_r) ->
                      let uu____8964 =
                        let uu____8967 =
                          let uu____8968 =
                            let uu____8969 =
                              FStar_Tactics_Types.goal_type goal  in
                            uu____8969.FStar_Syntax_Syntax.pos  in
                          let uu____8972 =
                            let uu____8977 =
                              let uu____8978 =
                                let uu____8987 =
                                  FStar_Syntax_Syntax.bv_to_name x  in
                                FStar_Syntax_Syntax.as_arg uu____8987  in
                              [uu____8978]  in
                            FStar_Syntax_Syntax.mk_Tm_app r uu____8977  in
                          uu____8972 FStar_Pervasives_Native.None uu____8968
                           in
                        set_solution goal uu____8967  in
                      bind uu____8964
                        (fun uu____9006  ->
                           let g =
                             FStar_Tactics_Types.mk_goal env' u_r
                               goal.FStar_Tactics_Types.opts
                               goal.FStar_Tactics_Types.is_guard
                               goal.FStar_Tactics_Types.label
                              in
                           replace_cur g)))
  
let (free_in :
  FStar_Syntax_Syntax.bv -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun bv  ->
    fun t  ->
      let uu____9020 = FStar_Syntax_Free.names t  in
      FStar_Util.set_mem bv uu____9020
  
let (clear : FStar_Syntax_Syntax.binder -> unit tac) =
  fun b  ->
    let bv = FStar_Pervasives_Native.fst b  in
    let uu____9036 = cur_goal ()  in
    bind uu____9036
      (fun goal  ->
         mlog
           (fun uu____9044  ->
              let uu____9045 = FStar_Syntax_Print.binder_to_string b  in
              let uu____9047 =
                let uu____9049 =
                  let uu____9051 =
                    let uu____9060 = FStar_Tactics_Types.goal_env goal  in
                    FStar_TypeChecker_Env.all_binders uu____9060  in
                  FStar_All.pipe_right uu____9051 FStar_List.length  in
                FStar_All.pipe_right uu____9049 FStar_Util.string_of_int  in
              FStar_Util.print2 "Clear of (%s), env has %s binders\n"
                uu____9045 uu____9047)
           (fun uu____9081  ->
              let uu____9082 =
                let uu____9093 = FStar_Tactics_Types.goal_env goal  in
                split_env bv uu____9093  in
              match uu____9082 with
              | FStar_Pervasives_Native.None  ->
                  fail "Cannot clear; binder not in environment"
              | FStar_Pervasives_Native.Some (e',bv1,bvs) ->
                  let rec check bvs1 =
                    match bvs1 with
                    | [] -> ret ()
                    | bv'::bvs2 ->
                        let uu____9138 =
                          free_in bv1 bv'.FStar_Syntax_Syntax.sort  in
                        if uu____9138
                        then
                          let uu____9143 =
                            let uu____9145 =
                              FStar_Syntax_Print.bv_to_string bv'  in
                            FStar_Util.format1
                              "Cannot clear; binder present in the type of %s"
                              uu____9145
                             in
                          fail uu____9143
                        else check bvs2
                     in
                  let uu____9150 =
                    let uu____9152 = FStar_Tactics_Types.goal_type goal  in
                    free_in bv1 uu____9152  in
                  if uu____9150
                  then fail "Cannot clear; binder present in goal"
                  else
                    (let uu____9159 = check bvs  in
                     bind uu____9159
                       (fun uu____9165  ->
                          let env' = push_bvs e' bvs  in
                          let uu____9167 =
                            let uu____9174 =
                              FStar_Tactics_Types.goal_type goal  in
                            new_uvar "clear.witness" env' uu____9174  in
                          bind uu____9167
                            (fun uu____9184  ->
                               match uu____9184 with
                               | (ut,uvar_ut) ->
                                   let uu____9193 = set_solution goal ut  in
                                   bind uu____9193
                                     (fun uu____9198  ->
                                        let uu____9199 =
                                          FStar_Tactics_Types.mk_goal env'
                                            uvar_ut
                                            goal.FStar_Tactics_Types.opts
                                            goal.FStar_Tactics_Types.is_guard
                                            goal.FStar_Tactics_Types.label
                                           in
                                        replace_cur uu____9199))))))
  
let (clear_top : unit -> unit tac) =
  fun uu____9207  ->
    let uu____9210 = cur_goal ()  in
    bind uu____9210
      (fun goal  ->
         let uu____9216 =
           let uu____9223 = FStar_Tactics_Types.goal_env goal  in
           FStar_TypeChecker_Env.pop_bv uu____9223  in
         match uu____9216 with
         | FStar_Pervasives_Native.None  ->
             fail "Cannot clear; empty context"
         | FStar_Pervasives_Native.Some (x,uu____9232) ->
             let uu____9237 = FStar_Syntax_Syntax.mk_binder x  in
             clear uu____9237)
  
let (prune : Prims.string -> unit tac) =
  fun s  ->
    let uu____9250 = cur_goal ()  in
    bind uu____9250
      (fun g  ->
         let ctx = FStar_Tactics_Types.goal_env g  in
         let ctx' =
           let uu____9260 = FStar_Ident.path_of_text s  in
           FStar_TypeChecker_Env.rem_proof_ns ctx uu____9260  in
         let g' = FStar_Tactics_Types.goal_with_env g ctx'  in replace_cur g')
  
let (addns : Prims.string -> unit tac) =
  fun s  ->
    let uu____9274 = cur_goal ()  in
    bind uu____9274
      (fun g  ->
         let ctx = FStar_Tactics_Types.goal_env g  in
         let ctx' =
           let uu____9284 = FStar_Ident.path_of_text s  in
           FStar_TypeChecker_Env.add_proof_ns ctx uu____9284  in
         let g' = FStar_Tactics_Types.goal_with_env g ctx'  in replace_cur g')
  
let rec (tac_fold_env :
  FStar_Tactics_Types.direction ->
    (env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac) ->
      env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun d  ->
    fun f  ->
      fun env1  ->
        fun t  ->
          let tn =
            let uu____9326 = FStar_Syntax_Subst.compress t  in
            uu____9326.FStar_Syntax_Syntax.n  in
          let uu____9329 =
            if d = FStar_Tactics_Types.TopDown
            then
              f env1
                (let uu___1416_9336 = t  in
                 {
                   FStar_Syntax_Syntax.n = tn;
                   FStar_Syntax_Syntax.pos =
                     (uu___1416_9336.FStar_Syntax_Syntax.pos);
                   FStar_Syntax_Syntax.vars =
                     (uu___1416_9336.FStar_Syntax_Syntax.vars)
                 })
            else ret t  in
          bind uu____9329
            (fun t1  ->
               let ff = tac_fold_env d f env1  in
               let tn1 =
                 let uu____9353 =
                   let uu____9354 = FStar_Syntax_Subst.compress t1  in
                   uu____9354.FStar_Syntax_Syntax.n  in
                 match uu____9353 with
                 | FStar_Syntax_Syntax.Tm_app (hd,args) ->
                     let uu____9385 = ff hd  in
                     bind uu____9385
                       (fun hd1  ->
                          let fa uu____9411 =
                            match uu____9411 with
                            | (a,q) ->
                                let uu____9432 = ff a  in
                                bind uu____9432 (fun a1  -> ret (a1, q))
                             in
                          let uu____9451 = mapM fa args  in
                          bind uu____9451
                            (fun args1  ->
                               ret (FStar_Syntax_Syntax.Tm_app (hd1, args1))))
                 | FStar_Syntax_Syntax.Tm_abs (bs,t2,k) ->
                     let uu____9533 = FStar_Syntax_Subst.open_term bs t2  in
                     (match uu____9533 with
                      | (bs1,t') ->
                          let uu____9542 =
                            let uu____9545 =
                              FStar_TypeChecker_Env.push_binders env1 bs1  in
                            tac_fold_env d f uu____9545 t'  in
                          bind uu____9542
                            (fun t''  ->
                               let uu____9549 =
                                 let uu____9550 =
                                   let uu____9569 =
                                     FStar_Syntax_Subst.close_binders bs1  in
                                   let uu____9578 =
                                     FStar_Syntax_Subst.close bs1 t''  in
                                   (uu____9569, uu____9578, k)  in
                                 FStar_Syntax_Syntax.Tm_abs uu____9550  in
                               ret uu____9549))
                 | FStar_Syntax_Syntax.Tm_arrow (bs,k) -> ret tn
                 | FStar_Syntax_Syntax.Tm_match (hd,brs) ->
                     let uu____9653 = ff hd  in
                     bind uu____9653
                       (fun hd1  ->
                          let ffb br =
                            let uu____9668 =
                              FStar_Syntax_Subst.open_branch br  in
                            match uu____9668 with
                            | (pat,w,e) ->
                                let bvs = FStar_Syntax_Syntax.pat_bvs pat  in
                                let ff1 =
                                  let uu____9700 =
                                    FStar_TypeChecker_Env.push_bvs env1 bvs
                                     in
                                  tac_fold_env d f uu____9700  in
                                let uu____9701 = ff1 e  in
                                bind uu____9701
                                  (fun e1  ->
                                     let br1 =
                                       FStar_Syntax_Subst.close_branch
                                         (pat, w, e1)
                                        in
                                     ret br1)
                             in
                          let uu____9716 = mapM ffb brs  in
                          bind uu____9716
                            (fun brs1  ->
                               ret (FStar_Syntax_Syntax.Tm_match (hd1, brs1))))
                 | FStar_Syntax_Syntax.Tm_let
                     ((false
                       ,{ FStar_Syntax_Syntax.lbname = FStar_Util.Inl bv;
                          FStar_Syntax_Syntax.lbunivs = uu____9760;
                          FStar_Syntax_Syntax.lbtyp = uu____9761;
                          FStar_Syntax_Syntax.lbeff = uu____9762;
                          FStar_Syntax_Syntax.lbdef = def;
                          FStar_Syntax_Syntax.lbattrs = uu____9764;
                          FStar_Syntax_Syntax.lbpos = uu____9765;_}::[]),e)
                     ->
                     let lb =
                       let uu____9793 =
                         let uu____9794 = FStar_Syntax_Subst.compress t1  in
                         uu____9794.FStar_Syntax_Syntax.n  in
                       match uu____9793 with
                       | FStar_Syntax_Syntax.Tm_let
                           ((false ,lb::[]),uu____9798) -> lb
                       | uu____9814 -> failwith "impossible"  in
                     let fflb lb1 =
                       let uu____9824 = ff lb1.FStar_Syntax_Syntax.lbdef  in
                       bind uu____9824
                         (fun def1  ->
                            ret
                              (let uu___1369_9830 = lb1  in
                               {
                                 FStar_Syntax_Syntax.lbname =
                                   (uu___1369_9830.FStar_Syntax_Syntax.lbname);
                                 FStar_Syntax_Syntax.lbunivs =
                                   (uu___1369_9830.FStar_Syntax_Syntax.lbunivs);
                                 FStar_Syntax_Syntax.lbtyp =
                                   (uu___1369_9830.FStar_Syntax_Syntax.lbtyp);
                                 FStar_Syntax_Syntax.lbeff =
                                   (uu___1369_9830.FStar_Syntax_Syntax.lbeff);
                                 FStar_Syntax_Syntax.lbdef = def1;
                                 FStar_Syntax_Syntax.lbattrs =
                                   (uu___1369_9830.FStar_Syntax_Syntax.lbattrs);
                                 FStar_Syntax_Syntax.lbpos =
                                   (uu___1369_9830.FStar_Syntax_Syntax.lbpos)
                               }))
                        in
                     let uu____9831 = fflb lb  in
                     bind uu____9831
                       (fun lb1  ->
                          let uu____9841 =
                            let uu____9846 =
                              let uu____9847 =
                                FStar_Syntax_Syntax.mk_binder bv  in
                              [uu____9847]  in
                            FStar_Syntax_Subst.open_term uu____9846 e  in
                          match uu____9841 with
                          | (bs,e1) ->
                              let ff1 =
                                let uu____9877 =
                                  FStar_TypeChecker_Env.push_binders env1 bs
                                   in
                                tac_fold_env d f uu____9877  in
                              let uu____9878 = ff1 e1  in
                              bind uu____9878
                                (fun e2  ->
                                   let e3 = FStar_Syntax_Subst.close bs e2
                                      in
                                   ret
                                     (FStar_Syntax_Syntax.Tm_let
                                        ((false, [lb1]), e3))))
                 | FStar_Syntax_Syntax.Tm_let ((true ,lbs),e) ->
                     let fflb lb =
                       let uu____9925 = ff lb.FStar_Syntax_Syntax.lbdef  in
                       bind uu____9925
                         (fun def  ->
                            ret
                              (let uu___1387_9931 = lb  in
                               {
                                 FStar_Syntax_Syntax.lbname =
                                   (uu___1387_9931.FStar_Syntax_Syntax.lbname);
                                 FStar_Syntax_Syntax.lbunivs =
                                   (uu___1387_9931.FStar_Syntax_Syntax.lbunivs);
                                 FStar_Syntax_Syntax.lbtyp =
                                   (uu___1387_9931.FStar_Syntax_Syntax.lbtyp);
                                 FStar_Syntax_Syntax.lbeff =
                                   (uu___1387_9931.FStar_Syntax_Syntax.lbeff);
                                 FStar_Syntax_Syntax.lbdef = def;
                                 FStar_Syntax_Syntax.lbattrs =
                                   (uu___1387_9931.FStar_Syntax_Syntax.lbattrs);
                                 FStar_Syntax_Syntax.lbpos =
                                   (uu___1387_9931.FStar_Syntax_Syntax.lbpos)
                               }))
                        in
                     let uu____9932 = FStar_Syntax_Subst.open_let_rec lbs e
                        in
                     (match uu____9932 with
                      | (lbs1,e1) ->
                          let uu____9947 = mapM fflb lbs1  in
                          bind uu____9947
                            (fun lbs2  ->
                               let uu____9959 = ff e1  in
                               bind uu____9959
                                 (fun e2  ->
                                    let uu____9967 =
                                      FStar_Syntax_Subst.close_let_rec lbs2
                                        e2
                                       in
                                    match uu____9967 with
                                    | (lbs3,e3) ->
                                        ret
                                          (FStar_Syntax_Syntax.Tm_let
                                             ((true, lbs3), e3)))))
                 | FStar_Syntax_Syntax.Tm_ascribed (t2,asc,eff) ->
                     let uu____10038 = ff t2  in
                     bind uu____10038
                       (fun t3  ->
                          ret
                            (FStar_Syntax_Syntax.Tm_ascribed (t3, asc, eff)))
                 | FStar_Syntax_Syntax.Tm_meta (t2,m) ->
                     let uu____10069 = ff t2  in
                     bind uu____10069
                       (fun t3  -> ret (FStar_Syntax_Syntax.Tm_meta (t3, m)))
                 | uu____10076 -> ret tn  in
               bind tn1
                 (fun tn2  ->
                    let t' =
                      let uu___1411_10083 = t1  in
                      {
                        FStar_Syntax_Syntax.n = tn2;
                        FStar_Syntax_Syntax.pos =
                          (uu___1411_10083.FStar_Syntax_Syntax.pos);
                        FStar_Syntax_Syntax.vars =
                          (uu___1411_10083.FStar_Syntax_Syntax.vars)
                      }  in
                    if d = FStar_Tactics_Types.BottomUp
                    then f env1 t'
                    else ret t'))
  
let (pointwise_rec :
  FStar_Tactics_Types.proofstate ->
    unit tac ->
      FStar_Options.optionstate ->
        Prims.string ->
          FStar_TypeChecker_Env.env ->
            FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun ps  ->
    fun tau  ->
      fun opts  ->
        fun label  ->
          fun env1  ->
            fun t  ->
              let uu____10130 =
                FStar_TypeChecker_TcTerm.tc_term
                  (let uu___1424_10139 = env1  in
                   {
                     FStar_TypeChecker_Env.solver =
                       (uu___1424_10139.FStar_TypeChecker_Env.solver);
                     FStar_TypeChecker_Env.range =
                       (uu___1424_10139.FStar_TypeChecker_Env.range);
                     FStar_TypeChecker_Env.curmodule =
                       (uu___1424_10139.FStar_TypeChecker_Env.curmodule);
                     FStar_TypeChecker_Env.gamma =
                       (uu___1424_10139.FStar_TypeChecker_Env.gamma);
                     FStar_TypeChecker_Env.gamma_sig =
                       (uu___1424_10139.FStar_TypeChecker_Env.gamma_sig);
                     FStar_TypeChecker_Env.gamma_cache =
                       (uu___1424_10139.FStar_TypeChecker_Env.gamma_cache);
                     FStar_TypeChecker_Env.modules =
                       (uu___1424_10139.FStar_TypeChecker_Env.modules);
                     FStar_TypeChecker_Env.expected_typ =
                       (uu___1424_10139.FStar_TypeChecker_Env.expected_typ);
                     FStar_TypeChecker_Env.sigtab =
                       (uu___1424_10139.FStar_TypeChecker_Env.sigtab);
                     FStar_TypeChecker_Env.attrtab =
                       (uu___1424_10139.FStar_TypeChecker_Env.attrtab);
                     FStar_TypeChecker_Env.instantiate_imp =
                       (uu___1424_10139.FStar_TypeChecker_Env.instantiate_imp);
                     FStar_TypeChecker_Env.effects =
                       (uu___1424_10139.FStar_TypeChecker_Env.effects);
                     FStar_TypeChecker_Env.generalize =
                       (uu___1424_10139.FStar_TypeChecker_Env.generalize);
                     FStar_TypeChecker_Env.letrecs =
                       (uu___1424_10139.FStar_TypeChecker_Env.letrecs);
                     FStar_TypeChecker_Env.top_level =
                       (uu___1424_10139.FStar_TypeChecker_Env.top_level);
                     FStar_TypeChecker_Env.check_uvars =
                       (uu___1424_10139.FStar_TypeChecker_Env.check_uvars);
                     FStar_TypeChecker_Env.use_eq =
                       (uu___1424_10139.FStar_TypeChecker_Env.use_eq);
                     FStar_TypeChecker_Env.use_eq_strict =
                       (uu___1424_10139.FStar_TypeChecker_Env.use_eq_strict);
                     FStar_TypeChecker_Env.is_iface =
                       (uu___1424_10139.FStar_TypeChecker_Env.is_iface);
                     FStar_TypeChecker_Env.admit =
                       (uu___1424_10139.FStar_TypeChecker_Env.admit);
                     FStar_TypeChecker_Env.lax = true;
                     FStar_TypeChecker_Env.lax_universes =
                       (uu___1424_10139.FStar_TypeChecker_Env.lax_universes);
                     FStar_TypeChecker_Env.phase1 =
                       (uu___1424_10139.FStar_TypeChecker_Env.phase1);
                     FStar_TypeChecker_Env.failhard =
                       (uu___1424_10139.FStar_TypeChecker_Env.failhard);
                     FStar_TypeChecker_Env.nosynth =
                       (uu___1424_10139.FStar_TypeChecker_Env.nosynth);
                     FStar_TypeChecker_Env.uvar_subtyping =
                       (uu___1424_10139.FStar_TypeChecker_Env.uvar_subtyping);
                     FStar_TypeChecker_Env.tc_term =
                       (uu___1424_10139.FStar_TypeChecker_Env.tc_term);
                     FStar_TypeChecker_Env.type_of =
                       (uu___1424_10139.FStar_TypeChecker_Env.type_of);
                     FStar_TypeChecker_Env.universe_of =
                       (uu___1424_10139.FStar_TypeChecker_Env.universe_of);
                     FStar_TypeChecker_Env.check_type_of =
                       (uu___1424_10139.FStar_TypeChecker_Env.check_type_of);
                     FStar_TypeChecker_Env.use_bv_sorts =
                       (uu___1424_10139.FStar_TypeChecker_Env.use_bv_sorts);
                     FStar_TypeChecker_Env.qtbl_name_and_index =
                       (uu___1424_10139.FStar_TypeChecker_Env.qtbl_name_and_index);
                     FStar_TypeChecker_Env.normalized_eff_names =
                       (uu___1424_10139.FStar_TypeChecker_Env.normalized_eff_names);
                     FStar_TypeChecker_Env.fv_delta_depths =
                       (uu___1424_10139.FStar_TypeChecker_Env.fv_delta_depths);
                     FStar_TypeChecker_Env.proof_ns =
                       (uu___1424_10139.FStar_TypeChecker_Env.proof_ns);
                     FStar_TypeChecker_Env.synth_hook =
                       (uu___1424_10139.FStar_TypeChecker_Env.synth_hook);
                     FStar_TypeChecker_Env.try_solve_implicits_hook =
                       (uu___1424_10139.FStar_TypeChecker_Env.try_solve_implicits_hook);
                     FStar_TypeChecker_Env.splice =
                       (uu___1424_10139.FStar_TypeChecker_Env.splice);
                     FStar_TypeChecker_Env.mpreprocess =
                       (uu___1424_10139.FStar_TypeChecker_Env.mpreprocess);
                     FStar_TypeChecker_Env.postprocess =
                       (uu___1424_10139.FStar_TypeChecker_Env.postprocess);
                     FStar_TypeChecker_Env.is_native_tactic =
                       (uu___1424_10139.FStar_TypeChecker_Env.is_native_tactic);
                     FStar_TypeChecker_Env.identifier_info =
                       (uu___1424_10139.FStar_TypeChecker_Env.identifier_info);
                     FStar_TypeChecker_Env.tc_hooks =
                       (uu___1424_10139.FStar_TypeChecker_Env.tc_hooks);
                     FStar_TypeChecker_Env.dsenv =
                       (uu___1424_10139.FStar_TypeChecker_Env.dsenv);
                     FStar_TypeChecker_Env.nbe =
                       (uu___1424_10139.FStar_TypeChecker_Env.nbe);
                     FStar_TypeChecker_Env.strict_args_tab =
                       (uu___1424_10139.FStar_TypeChecker_Env.strict_args_tab);
                     FStar_TypeChecker_Env.erasable_types_tab =
                       (uu___1424_10139.FStar_TypeChecker_Env.erasable_types_tab)
                   }) t
                 in
              match uu____10130 with
              | (uu____10143,lcomp,g) ->
                  let uu____10146 =
                    (let uu____10150 =
                       FStar_TypeChecker_Common.is_pure_or_ghost_lcomp lcomp
                        in
                     Prims.op_Negation uu____10150) ||
                      (let uu____10153 = FStar_TypeChecker_Env.is_trivial g
                          in
                       Prims.op_Negation uu____10153)
                     in
                  if uu____10146
                  then ret t
                  else
                    (let rewrite_eq =
                       let typ = lcomp.FStar_TypeChecker_Common.res_typ  in
                       let uu____10164 = new_uvar "pointwise_rec" env1 typ
                          in
                       bind uu____10164
                         (fun uu____10181  ->
                            match uu____10181 with
                            | (ut,uvar_ut) ->
                                (log ps
                                   (fun uu____10194  ->
                                      let uu____10195 =
                                        FStar_Syntax_Print.term_to_string t
                                         in
                                      let uu____10197 =
                                        FStar_Syntax_Print.term_to_string ut
                                         in
                                      FStar_Util.print2
                                        "Pointwise_rec: making equality\n\t%s ==\n\t%s\n"
                                        uu____10195 uu____10197);
                                 (let uu____10200 =
                                    let uu____10203 =
                                      let uu____10204 =
                                        FStar_TypeChecker_TcTerm.universe_of
                                          env1 typ
                                         in
                                      FStar_Syntax_Util.mk_eq2 uu____10204
                                        typ t ut
                                       in
                                    add_irrelevant_goal
                                      "pointwise_rec equation" env1
                                      uu____10203 opts label
                                     in
                                  bind uu____10200
                                    (fun uu____10208  ->
                                       let uu____10209 =
                                         bind tau
                                           (fun uu____10215  ->
                                              let ut1 =
                                                FStar_TypeChecker_Normalize.reduce_uvar_solutions
                                                  env1 ut
                                                 in
                                              log ps
                                                (fun uu____10221  ->
                                                   let uu____10222 =
                                                     FStar_Syntax_Print.term_to_string
                                                       t
                                                      in
                                                   let uu____10224 =
                                                     FStar_Syntax_Print.term_to_string
                                                       ut1
                                                      in
                                                   FStar_Util.print2
                                                     "pointwise_rec: succeeded rewriting\n\t%s to\n\t%s\n"
                                                     uu____10222 uu____10224);
                                              ret ut1)
                                          in
                                       focus uu____10209))))
                        in
                     let uu____10227 = catch rewrite_eq  in
                     bind uu____10227
                       (fun uu___5_10239  ->
                          match uu___5_10239 with
                          | FStar_Util.Inl (FStar_Tactics_Types.TacticFailure
                              "SKIP") -> ret t
                          | FStar_Util.Inl e -> traise e
                          | FStar_Util.Inr x -> ret x))
  
type ctrl = FStar_BigInt.t
let (keepGoing : ctrl) = FStar_BigInt.zero 
let (proceedToNextSubtree : FStar_BigInt.bigint) = FStar_BigInt.one 
let (globalStop : FStar_BigInt.bigint) =
  FStar_BigInt.succ_big_int FStar_BigInt.one 
type rewrite_result = Prims.bool
let (skipThisTerm : Prims.bool) = false 
let (rewroteThisTerm : Prims.bool) = true 
type 'a ctrl_tac = ('a * ctrl) tac
let rec (ctrl_tac_fold :
  (env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac) ->
    env ->
      ctrl -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac)
  =
  fun f  ->
    fun env1  ->
      fun ctrl1  ->
        fun t  ->
          let keep_going c =
            if c = proceedToNextSubtree then keepGoing else c  in
          let maybe_continue ctrl2 t1 k =
            if ctrl2 = globalStop
            then ret (t1, globalStop)
            else
              if ctrl2 = proceedToNextSubtree
              then ret (t1, keepGoing)
              else k t1
             in
          let uu____10439 = FStar_Syntax_Subst.compress t  in
          maybe_continue ctrl1 uu____10439
            (fun t1  ->
               let uu____10447 =
                 f env1
                   (let uu___1501_10455 = t1  in
                    {
                      FStar_Syntax_Syntax.n = (t1.FStar_Syntax_Syntax.n);
                      FStar_Syntax_Syntax.pos =
                        (uu___1501_10455.FStar_Syntax_Syntax.pos);
                      FStar_Syntax_Syntax.vars =
                        (uu___1501_10455.FStar_Syntax_Syntax.vars)
                    })
                  in
               bind uu____10447
                 (fun uu____10471  ->
                    match uu____10471 with
                    | (t2,ctrl2) ->
                        maybe_continue ctrl2 t2
                          (fun t3  ->
                             let uu____10494 =
                               let uu____10495 =
                                 FStar_Syntax_Subst.compress t3  in
                               uu____10495.FStar_Syntax_Syntax.n  in
                             match uu____10494 with
                             | FStar_Syntax_Syntax.Tm_app (hd,args) ->
                                 let uu____10532 =
                                   ctrl_tac_fold f env1 ctrl2 hd  in
                                 bind uu____10532
                                   (fun uu____10554  ->
                                      match uu____10554 with
                                      | (hd1,ctrl3) ->
                                          let ctrl4 = keep_going ctrl3  in
                                          let uu____10570 =
                                            ctrl_tac_fold_args f env1 ctrl4
                                              args
                                             in
                                          bind uu____10570
                                            (fun uu____10594  ->
                                               match uu____10594 with
                                               | (args1,ctrl5) ->
                                                   ret
                                                     ((let uu___1481_10624 =
                                                         t3  in
                                                       {
                                                         FStar_Syntax_Syntax.n
                                                           =
                                                           (FStar_Syntax_Syntax.Tm_app
                                                              (hd1, args1));
                                                         FStar_Syntax_Syntax.pos
                                                           =
                                                           (uu___1481_10624.FStar_Syntax_Syntax.pos);
                                                         FStar_Syntax_Syntax.vars
                                                           =
                                                           (uu___1481_10624.FStar_Syntax_Syntax.vars)
                                                       }), ctrl5)))
                             | FStar_Syntax_Syntax.Tm_abs (bs,t4,k) ->
                                 let uu____10666 =
                                   FStar_Syntax_Subst.open_term bs t4  in
                                 (match uu____10666 with
                                  | (bs1,t') ->
                                      let uu____10681 =
                                        let uu____10688 =
                                          FStar_TypeChecker_Env.push_binders
                                            env1 bs1
                                           in
                                        ctrl_tac_fold f uu____10688 ctrl2 t'
                                         in
                                      bind uu____10681
                                        (fun uu____10703  ->
                                           match uu____10703 with
                                           | (t'',ctrl3) ->
                                               let uu____10718 =
                                                 let uu____10725 =
                                                   let uu___1494_10728 = t4
                                                      in
                                                   let uu____10731 =
                                                     let uu____10732 =
                                                       let uu____10751 =
                                                         FStar_Syntax_Subst.close_binders
                                                           bs1
                                                          in
                                                       let uu____10760 =
                                                         FStar_Syntax_Subst.close
                                                           bs1 t''
                                                          in
                                                       (uu____10751,
                                                         uu____10760, k)
                                                        in
                                                     FStar_Syntax_Syntax.Tm_abs
                                                       uu____10732
                                                      in
                                                   {
                                                     FStar_Syntax_Syntax.n =
                                                       uu____10731;
                                                     FStar_Syntax_Syntax.pos
                                                       =
                                                       (uu___1494_10728.FStar_Syntax_Syntax.pos);
                                                     FStar_Syntax_Syntax.vars
                                                       =
                                                       (uu___1494_10728.FStar_Syntax_Syntax.vars)
                                                   }  in
                                                 (uu____10725, ctrl3)  in
                                               ret uu____10718))
                             | FStar_Syntax_Syntax.Tm_arrow (bs,k) ->
                                 ret (t3, ctrl2)
                             | uu____10813 -> ret (t3, ctrl2))))

and (ctrl_tac_fold_args :
  (env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac) ->
    env ->
      ctrl ->
        FStar_Syntax_Syntax.arg Prims.list ->
          FStar_Syntax_Syntax.arg Prims.list ctrl_tac)
  =
  fun f  ->
    fun env1  ->
      fun ctrl1  ->
        fun ts  ->
          match ts with
          | [] -> ret ([], ctrl1)
          | (t,q)::ts1 ->
              let uu____10859 = ctrl_tac_fold f env1 ctrl1 t  in
              bind uu____10859
                (fun uu____10880  ->
                   match uu____10880 with
                   | (t1,ctrl2) ->
                       let uu____10895 = ctrl_tac_fold_args f env1 ctrl2 ts1
                          in
                       bind uu____10895
                         (fun uu____10919  ->
                            match uu____10919 with
                            | (ts2,ctrl3) -> ret (((t1, q) :: ts2), ctrl3)))

let (rewrite_rec :
  FStar_Tactics_Types.proofstate ->
    (FStar_Syntax_Syntax.term -> rewrite_result ctrl_tac) ->
      unit tac ->
        FStar_Options.optionstate ->
          Prims.string ->
            FStar_TypeChecker_Env.env ->
              FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac)
  =
  fun ps  ->
    fun ctrl1  ->
      fun rewriter  ->
        fun opts  ->
          fun label  ->
            fun env1  ->
              fun t  ->
                let t1 = FStar_Syntax_Subst.compress t  in
                let uu____11010 =
                  let uu____11018 =
                    add_irrelevant_goal "dummy" env1 FStar_Syntax_Util.t_true
                      opts label
                     in
                  bind uu____11018
                    (fun uu____11029  ->
                       let uu____11030 = ctrl1 t1  in
                       bind uu____11030
                         (fun res  ->
                            let uu____11056 = trivial ()  in
                            bind uu____11056 (fun uu____11065  -> ret res)))
                   in
                bind uu____11010
                  (fun uu____11083  ->
                     match uu____11083 with
                     | (should_rewrite,ctrl2) ->
                         if Prims.op_Negation should_rewrite
                         then ret (t1, ctrl2)
                         else
                           (let uu____11112 =
                              FStar_TypeChecker_TcTerm.tc_term
                                (let uu___1531_11121 = env1  in
                                 {
                                   FStar_TypeChecker_Env.solver =
                                     (uu___1531_11121.FStar_TypeChecker_Env.solver);
                                   FStar_TypeChecker_Env.range =
                                     (uu___1531_11121.FStar_TypeChecker_Env.range);
                                   FStar_TypeChecker_Env.curmodule =
                                     (uu___1531_11121.FStar_TypeChecker_Env.curmodule);
                                   FStar_TypeChecker_Env.gamma =
                                     (uu___1531_11121.FStar_TypeChecker_Env.gamma);
                                   FStar_TypeChecker_Env.gamma_sig =
                                     (uu___1531_11121.FStar_TypeChecker_Env.gamma_sig);
                                   FStar_TypeChecker_Env.gamma_cache =
                                     (uu___1531_11121.FStar_TypeChecker_Env.gamma_cache);
                                   FStar_TypeChecker_Env.modules =
                                     (uu___1531_11121.FStar_TypeChecker_Env.modules);
                                   FStar_TypeChecker_Env.expected_typ =
                                     (uu___1531_11121.FStar_TypeChecker_Env.expected_typ);
                                   FStar_TypeChecker_Env.sigtab =
                                     (uu___1531_11121.FStar_TypeChecker_Env.sigtab);
                                   FStar_TypeChecker_Env.attrtab =
                                     (uu___1531_11121.FStar_TypeChecker_Env.attrtab);
                                   FStar_TypeChecker_Env.instantiate_imp =
                                     (uu___1531_11121.FStar_TypeChecker_Env.instantiate_imp);
                                   FStar_TypeChecker_Env.effects =
                                     (uu___1531_11121.FStar_TypeChecker_Env.effects);
                                   FStar_TypeChecker_Env.generalize =
                                     (uu___1531_11121.FStar_TypeChecker_Env.generalize);
                                   FStar_TypeChecker_Env.letrecs =
                                     (uu___1531_11121.FStar_TypeChecker_Env.letrecs);
                                   FStar_TypeChecker_Env.top_level =
                                     (uu___1531_11121.FStar_TypeChecker_Env.top_level);
                                   FStar_TypeChecker_Env.check_uvars =
                                     (uu___1531_11121.FStar_TypeChecker_Env.check_uvars);
                                   FStar_TypeChecker_Env.use_eq =
                                     (uu___1531_11121.FStar_TypeChecker_Env.use_eq);
                                   FStar_TypeChecker_Env.use_eq_strict =
                                     (uu___1531_11121.FStar_TypeChecker_Env.use_eq_strict);
                                   FStar_TypeChecker_Env.is_iface =
                                     (uu___1531_11121.FStar_TypeChecker_Env.is_iface);
                                   FStar_TypeChecker_Env.admit =
                                     (uu___1531_11121.FStar_TypeChecker_Env.admit);
                                   FStar_TypeChecker_Env.lax = true;
                                   FStar_TypeChecker_Env.lax_universes =
                                     (uu___1531_11121.FStar_TypeChecker_Env.lax_universes);
                                   FStar_TypeChecker_Env.phase1 =
                                     (uu___1531_11121.FStar_TypeChecker_Env.phase1);
                                   FStar_TypeChecker_Env.failhard =
                                     (uu___1531_11121.FStar_TypeChecker_Env.failhard);
                                   FStar_TypeChecker_Env.nosynth =
                                     (uu___1531_11121.FStar_TypeChecker_Env.nosynth);
                                   FStar_TypeChecker_Env.uvar_subtyping =
                                     (uu___1531_11121.FStar_TypeChecker_Env.uvar_subtyping);
                                   FStar_TypeChecker_Env.tc_term =
                                     (uu___1531_11121.FStar_TypeChecker_Env.tc_term);
                                   FStar_TypeChecker_Env.type_of =
                                     (uu___1531_11121.FStar_TypeChecker_Env.type_of);
                                   FStar_TypeChecker_Env.universe_of =
                                     (uu___1531_11121.FStar_TypeChecker_Env.universe_of);
                                   FStar_TypeChecker_Env.check_type_of =
                                     (uu___1531_11121.FStar_TypeChecker_Env.check_type_of);
                                   FStar_TypeChecker_Env.use_bv_sorts =
                                     (uu___1531_11121.FStar_TypeChecker_Env.use_bv_sorts);
                                   FStar_TypeChecker_Env.qtbl_name_and_index
                                     =
                                     (uu___1531_11121.FStar_TypeChecker_Env.qtbl_name_and_index);
                                   FStar_TypeChecker_Env.normalized_eff_names
                                     =
                                     (uu___1531_11121.FStar_TypeChecker_Env.normalized_eff_names);
                                   FStar_TypeChecker_Env.fv_delta_depths =
                                     (uu___1531_11121.FStar_TypeChecker_Env.fv_delta_depths);
                                   FStar_TypeChecker_Env.proof_ns =
                                     (uu___1531_11121.FStar_TypeChecker_Env.proof_ns);
                                   FStar_TypeChecker_Env.synth_hook =
                                     (uu___1531_11121.FStar_TypeChecker_Env.synth_hook);
                                   FStar_TypeChecker_Env.try_solve_implicits_hook
                                     =
                                     (uu___1531_11121.FStar_TypeChecker_Env.try_solve_implicits_hook);
                                   FStar_TypeChecker_Env.splice =
                                     (uu___1531_11121.FStar_TypeChecker_Env.splice);
                                   FStar_TypeChecker_Env.mpreprocess =
                                     (uu___1531_11121.FStar_TypeChecker_Env.mpreprocess);
                                   FStar_TypeChecker_Env.postprocess =
                                     (uu___1531_11121.FStar_TypeChecker_Env.postprocess);
                                   FStar_TypeChecker_Env.is_native_tactic =
                                     (uu___1531_11121.FStar_TypeChecker_Env.is_native_tactic);
                                   FStar_TypeChecker_Env.identifier_info =
                                     (uu___1531_11121.FStar_TypeChecker_Env.identifier_info);
                                   FStar_TypeChecker_Env.tc_hooks =
                                     (uu___1531_11121.FStar_TypeChecker_Env.tc_hooks);
                                   FStar_TypeChecker_Env.dsenv =
                                     (uu___1531_11121.FStar_TypeChecker_Env.dsenv);
                                   FStar_TypeChecker_Env.nbe =
                                     (uu___1531_11121.FStar_TypeChecker_Env.nbe);
                                   FStar_TypeChecker_Env.strict_args_tab =
                                     (uu___1531_11121.FStar_TypeChecker_Env.strict_args_tab);
                                   FStar_TypeChecker_Env.erasable_types_tab =
                                     (uu___1531_11121.FStar_TypeChecker_Env.erasable_types_tab)
                                 }) t1
                               in
                            match uu____11112 with
                            | (t2,lcomp,g) ->
                                let uu____11132 =
                                  (let uu____11136 =
                                     FStar_TypeChecker_Common.is_pure_or_ghost_lcomp
                                       lcomp
                                      in
                                   Prims.op_Negation uu____11136) ||
                                    (let uu____11139 =
                                       FStar_TypeChecker_Env.is_trivial g  in
                                     Prims.op_Negation uu____11139)
                                   in
                                if uu____11132
                                then ret (t2, globalStop)
                                else
                                  (let typ =
                                     lcomp.FStar_TypeChecker_Common.res_typ
                                      in
                                   let uu____11155 =
                                     new_uvar "pointwise_rec" env1 typ  in
                                   bind uu____11155
                                     (fun uu____11176  ->
                                        match uu____11176 with
                                        | (ut,uvar_ut) ->
                                            (log ps
                                               (fun uu____11193  ->
                                                  let uu____11194 =
                                                    FStar_Syntax_Print.term_to_string
                                                      t2
                                                     in
                                                  let uu____11196 =
                                                    FStar_Syntax_Print.term_to_string
                                                      ut
                                                     in
                                                  FStar_Util.print2
                                                    "Pointwise_rec: making equality\n\t%s ==\n\t%s\n"
                                                    uu____11194 uu____11196);
                                             (let uu____11199 =
                                                let uu____11202 =
                                                  let uu____11203 =
                                                    FStar_TypeChecker_TcTerm.universe_of
                                                      env1 typ
                                                     in
                                                  FStar_Syntax_Util.mk_eq2
                                                    uu____11203 typ t2 ut
                                                   in
                                                add_irrelevant_goal
                                                  "rewrite_rec equation" env1
                                                  uu____11202 opts label
                                                 in
                                              bind uu____11199
                                                (fun uu____11211  ->
                                                   let uu____11212 =
                                                     bind rewriter
                                                       (fun uu____11226  ->
                                                          let ut1 =
                                                            FStar_TypeChecker_Normalize.reduce_uvar_solutions
                                                              env1 ut
                                                             in
                                                          log ps
                                                            (fun uu____11232 
                                                               ->
                                                               let uu____11233
                                                                 =
                                                                 FStar_Syntax_Print.term_to_string
                                                                   t2
                                                                  in
                                                               let uu____11235
                                                                 =
                                                                 FStar_Syntax_Print.term_to_string
                                                                   ut1
                                                                  in
                                                               FStar_Util.print2
                                                                 "rewrite_rec: succeeded rewriting\n\t%s to\n\t%s\n"
                                                                 uu____11233
                                                                 uu____11235);
                                                          ret (ut1, ctrl2))
                                                      in
                                                   focus uu____11212)))))))
  
let (topdown_rewrite :
  (FStar_Syntax_Syntax.term -> (Prims.bool * FStar_BigInt.t) tac) ->
    unit tac -> unit tac)
  =
  fun ctrl1  ->
    fun rewriter  ->
      let uu____11280 =
        bind get
          (fun ps  ->
             let uu____11290 =
               match ps.FStar_Tactics_Types.goals with
               | g::gs -> (g, gs)
               | [] -> failwith "no goals"  in
             match uu____11290 with
             | (g,gs) ->
                 let gt = FStar_Tactics_Types.goal_type g  in
                 (log ps
                    (fun uu____11328  ->
                       let uu____11329 = FStar_Syntax_Print.term_to_string gt
                          in
                       FStar_Util.print1 "Topdown_rewrite starting with %s\n"
                         uu____11329);
                  bind dismiss_all
                    (fun uu____11334  ->
                       let uu____11335 =
                         let uu____11342 = FStar_Tactics_Types.goal_env g  in
                         ctrl_tac_fold
                           (rewrite_rec ps ctrl1 rewriter
                              g.FStar_Tactics_Types.opts
                              g.FStar_Tactics_Types.label) uu____11342
                           keepGoing gt
                          in
                       bind uu____11335
                         (fun uu____11352  ->
                            match uu____11352 with
                            | (gt',uu____11360) ->
                                (log ps
                                   (fun uu____11364  ->
                                      let uu____11365 =
                                        FStar_Syntax_Print.term_to_string gt'
                                         in
                                      FStar_Util.print1
                                        "Topdown_rewrite seems to have succeded with %s\n"
                                        uu____11365);
                                 (let uu____11368 = push_goals gs  in
                                  bind uu____11368
                                    (fun uu____11373  ->
                                       let uu____11374 =
                                         let uu____11377 =
                                           let uu____11378 =
                                             FStar_Tactics_Types.goal_with_type
                                               g gt'
                                              in
                                           FStar_All.pipe_right uu____11378
                                             bnorm_goal
                                            in
                                         [uu____11377]  in
                                       add_goals uu____11374)))))))
         in
      FStar_All.pipe_left (wrap_err "topdown_rewrite") uu____11280
  
let (t_pointwise : FStar_Tactics_Types.direction -> unit tac -> unit tac) =
  fun d  ->
    fun tau  ->
      let uu____11403 =
        bind get
          (fun ps  ->
             let uu____11413 =
               match ps.FStar_Tactics_Types.goals with
               | g::gs -> (g, gs)
               | [] -> failwith "no goals"  in
             match uu____11413 with
             | (g,gs) ->
                 let gt = FStar_Tactics_Types.goal_type g  in
                 (log ps
                    (fun uu____11451  ->
                       let uu____11452 = FStar_Syntax_Print.term_to_string gt
                          in
                       FStar_Util.print1 "Pointwise starting with %s\n"
                         uu____11452);
                  bind dismiss_all
                    (fun uu____11457  ->
                       let uu____11458 =
                         let uu____11461 = FStar_Tactics_Types.goal_env g  in
                         tac_fold_env d
                           (pointwise_rec ps tau g.FStar_Tactics_Types.opts
                              g.FStar_Tactics_Types.label) uu____11461 gt
                          in
                       bind uu____11458
                         (fun gt'  ->
                            log ps
                              (fun uu____11469  ->
                                 let uu____11470 =
                                   FStar_Syntax_Print.term_to_string gt'  in
                                 FStar_Util.print1
                                   "Pointwise seems to have succeded with %s\n"
                                   uu____11470);
                            (let uu____11473 = push_goals gs  in
                             bind uu____11473
                               (fun uu____11478  ->
                                  let uu____11479 =
                                    let uu____11482 =
                                      let uu____11483 =
                                        FStar_Tactics_Types.goal_with_type g
                                          gt'
                                         in
                                      FStar_All.pipe_right uu____11483
                                        bnorm_goal
                                       in
                                    [uu____11482]  in
                                  add_goals uu____11479))))))
         in
      FStar_All.pipe_left (wrap_err "t_pointwise") uu____11403
  
let (_trefl :
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> unit tac) =
  fun l  ->
    fun r  ->
      let uu____11504 = cur_goal ()  in
      bind uu____11504
        (fun g  ->
           let uu____11510 =
             let uu____11514 = FStar_Tactics_Types.goal_env g  in
             do_unify uu____11514 l r  in
           bind uu____11510
             (fun b  ->
                if b
                then solve' g FStar_Syntax_Util.exp_unit
                else
                  (let l1 =
                     let uu____11525 = FStar_Tactics_Types.goal_env g  in
                     FStar_TypeChecker_Normalize.normalize
                       [FStar_TypeChecker_Env.UnfoldUntil
                          FStar_Syntax_Syntax.delta_constant;
                       FStar_TypeChecker_Env.Primops;
                       FStar_TypeChecker_Env.UnfoldTac] uu____11525 l
                      in
                   let r1 =
                     let uu____11527 = FStar_Tactics_Types.goal_env g  in
                     FStar_TypeChecker_Normalize.normalize
                       [FStar_TypeChecker_Env.UnfoldUntil
                          FStar_Syntax_Syntax.delta_constant;
                       FStar_TypeChecker_Env.Primops;
                       FStar_TypeChecker_Env.UnfoldTac] uu____11527 r
                      in
                   let uu____11528 =
                     let uu____11532 = FStar_Tactics_Types.goal_env g  in
                     do_unify uu____11532 l1 r1  in
                   bind uu____11528
                     (fun b1  ->
                        if b1
                        then solve' g FStar_Syntax_Util.exp_unit
                        else
                          (let uu____11542 =
                             let uu____11549 =
                               let uu____11555 =
                                 FStar_Tactics_Types.goal_env g  in
                               tts uu____11555  in
                             FStar_TypeChecker_Err.print_discrepancy
                               uu____11549 l1 r1
                              in
                           match uu____11542 with
                           | (ls,rs) ->
                               fail2 "not a trivial equality ((%s) vs (%s))"
                                 ls rs)))))
  
let (trefl : unit -> unit tac) =
  fun uu____11572  ->
    let uu____11575 =
      let uu____11578 = cur_goal ()  in
      bind uu____11578
        (fun g  ->
           let uu____11586 =
             let uu____11593 =
               let uu____11594 = FStar_Tactics_Types.goal_env g  in
               let uu____11595 = FStar_Tactics_Types.goal_type g  in
               bnorm uu____11594 uu____11595  in
             destruct_eq uu____11593  in
           match uu____11586 with
           | FStar_Pervasives_Native.Some (l,r) -> _trefl l r
           | FStar_Pervasives_Native.None  ->
               let uu____11608 =
                 let uu____11610 = FStar_Tactics_Types.goal_env g  in
                 let uu____11611 = FStar_Tactics_Types.goal_type g  in
                 tts uu____11610 uu____11611  in
               fail1 "not an equality (%s)" uu____11608)
       in
    FStar_All.pipe_left (wrap_err "trefl") uu____11575
  
let (dup : unit -> unit tac) =
  fun uu____11625  ->
    let uu____11628 = cur_goal ()  in
    bind uu____11628
      (fun g  ->
         let uu____11634 =
           let uu____11641 = FStar_Tactics_Types.goal_env g  in
           let uu____11642 = FStar_Tactics_Types.goal_type g  in
           new_uvar "dup" uu____11641 uu____11642  in
         bind uu____11634
           (fun uu____11652  ->
              match uu____11652 with
              | (u,u_uvar) ->
                  let g' =
                    let uu___1614_11662 = g  in
                    {
                      FStar_Tactics_Types.goal_main_env =
                        (uu___1614_11662.FStar_Tactics_Types.goal_main_env);
                      FStar_Tactics_Types.goal_ctx_uvar = u_uvar;
                      FStar_Tactics_Types.opts =
                        (uu___1614_11662.FStar_Tactics_Types.opts);
                      FStar_Tactics_Types.is_guard =
                        (uu___1614_11662.FStar_Tactics_Types.is_guard);
                      FStar_Tactics_Types.label =
                        (uu___1614_11662.FStar_Tactics_Types.label)
                    }  in
                  bind __dismiss
                    (fun uu____11665  ->
                       let uu____11666 =
                         let uu____11669 = FStar_Tactics_Types.goal_env g  in
                         let uu____11670 =
                           let uu____11671 =
                             let uu____11672 = FStar_Tactics_Types.goal_env g
                                in
                             let uu____11673 =
                               FStar_Tactics_Types.goal_type g  in
                             FStar_TypeChecker_TcTerm.universe_of uu____11672
                               uu____11673
                              in
                           let uu____11674 = FStar_Tactics_Types.goal_type g
                              in
                           let uu____11675 =
                             FStar_Tactics_Types.goal_witness g  in
                           FStar_Syntax_Util.mk_eq2 uu____11671 uu____11674 u
                             uu____11675
                            in
                         add_irrelevant_goal "dup equation" uu____11669
                           uu____11670 g.FStar_Tactics_Types.opts
                           g.FStar_Tactics_Types.label
                          in
                       bind uu____11666
                         (fun uu____11679  ->
                            let uu____11680 = add_goals [g']  in
                            bind uu____11680 (fun uu____11684  -> ret ())))))
  
let longest_prefix :
  'a .
    ('a -> 'a -> Prims.bool) ->
      'a Prims.list ->
        'a Prims.list -> ('a Prims.list * 'a Prims.list * 'a Prims.list)
  =
  fun f  ->
    fun l1  ->
      fun l2  ->
        let rec aux acc l11 l21 =
          match (l11, l21) with
          | (x::xs,y::ys) ->
              let uu____11810 = f x y  in
              if uu____11810 then aux (x :: acc) xs ys else (acc, xs, ys)
          | uu____11833 -> (acc, l11, l21)  in
        let uu____11848 = aux [] l1 l2  in
        match uu____11848 with | (pr,t1,t2) -> ((FStar_List.rev pr), t1, t2)
  
let (join_goals :
  FStar_Tactics_Types.goal ->
    FStar_Tactics_Types.goal -> FStar_Tactics_Types.goal tac)
  =
  fun g1  ->
    fun g2  ->
      let close_forall_no_univs bs f =
        FStar_List.fold_right
          (fun b  ->
             fun f1  ->
               FStar_Syntax_Util.mk_forall_no_univ
                 (FStar_Pervasives_Native.fst b) f1) bs f
         in
      let uu____11954 = get_phi g1  in
      match uu____11954 with
      | FStar_Pervasives_Native.None  -> fail "goal 1 is not irrelevant"
      | FStar_Pervasives_Native.Some phi1 ->
          let uu____11961 = get_phi g2  in
          (match uu____11961 with
           | FStar_Pervasives_Native.None  -> fail "goal 2 is not irrelevant"
           | FStar_Pervasives_Native.Some phi2 ->
               let gamma1 =
                 (g1.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_gamma
                  in
               let gamma2 =
                 (g2.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_gamma
                  in
               let uu____11974 =
                 longest_prefix FStar_Syntax_Syntax.eq_binding
                   (FStar_List.rev gamma1) (FStar_List.rev gamma2)
                  in
               (match uu____11974 with
                | (gamma,r1,r2) ->
                    let t1 =
                      let uu____12005 =
                        FStar_TypeChecker_Env.binders_of_bindings
                          (FStar_List.rev r1)
                         in
                      close_forall_no_univs uu____12005 phi1  in
                    let t2 =
                      let uu____12015 =
                        FStar_TypeChecker_Env.binders_of_bindings
                          (FStar_List.rev r2)
                         in
                      close_forall_no_univs uu____12015 phi2  in
                    let uu____12024 =
                      set_solution g1 FStar_Syntax_Util.exp_unit  in
                    bind uu____12024
                      (fun uu____12029  ->
                         let uu____12030 =
                           set_solution g2 FStar_Syntax_Util.exp_unit  in
                         bind uu____12030
                           (fun uu____12037  ->
                              let ng = FStar_Syntax_Util.mk_conj t1 t2  in
                              let nenv =
                                let uu___1665_12042 =
                                  FStar_Tactics_Types.goal_env g1  in
                                let uu____12043 =
                                  FStar_Util.smap_create (Prims.of_int (100))
                                   in
                                {
                                  FStar_TypeChecker_Env.solver =
                                    (uu___1665_12042.FStar_TypeChecker_Env.solver);
                                  FStar_TypeChecker_Env.range =
                                    (uu___1665_12042.FStar_TypeChecker_Env.range);
                                  FStar_TypeChecker_Env.curmodule =
                                    (uu___1665_12042.FStar_TypeChecker_Env.curmodule);
                                  FStar_TypeChecker_Env.gamma =
                                    (FStar_List.rev gamma);
                                  FStar_TypeChecker_Env.gamma_sig =
                                    (uu___1665_12042.FStar_TypeChecker_Env.gamma_sig);
                                  FStar_TypeChecker_Env.gamma_cache =
                                    uu____12043;
                                  FStar_TypeChecker_Env.modules =
                                    (uu___1665_12042.FStar_TypeChecker_Env.modules);
                                  FStar_TypeChecker_Env.expected_typ =
                                    (uu___1665_12042.FStar_TypeChecker_Env.expected_typ);
                                  FStar_TypeChecker_Env.sigtab =
                                    (uu___1665_12042.FStar_TypeChecker_Env.sigtab);
                                  FStar_TypeChecker_Env.attrtab =
                                    (uu___1665_12042.FStar_TypeChecker_Env.attrtab);
                                  FStar_TypeChecker_Env.instantiate_imp =
                                    (uu___1665_12042.FStar_TypeChecker_Env.instantiate_imp);
                                  FStar_TypeChecker_Env.effects =
                                    (uu___1665_12042.FStar_TypeChecker_Env.effects);
                                  FStar_TypeChecker_Env.generalize =
                                    (uu___1665_12042.FStar_TypeChecker_Env.generalize);
                                  FStar_TypeChecker_Env.letrecs =
                                    (uu___1665_12042.FStar_TypeChecker_Env.letrecs);
                                  FStar_TypeChecker_Env.top_level =
                                    (uu___1665_12042.FStar_TypeChecker_Env.top_level);
                                  FStar_TypeChecker_Env.check_uvars =
                                    (uu___1665_12042.FStar_TypeChecker_Env.check_uvars);
                                  FStar_TypeChecker_Env.use_eq =
                                    (uu___1665_12042.FStar_TypeChecker_Env.use_eq);
                                  FStar_TypeChecker_Env.use_eq_strict =
                                    (uu___1665_12042.FStar_TypeChecker_Env.use_eq_strict);
                                  FStar_TypeChecker_Env.is_iface =
                                    (uu___1665_12042.FStar_TypeChecker_Env.is_iface);
                                  FStar_TypeChecker_Env.admit =
                                    (uu___1665_12042.FStar_TypeChecker_Env.admit);
                                  FStar_TypeChecker_Env.lax =
                                    (uu___1665_12042.FStar_TypeChecker_Env.lax);
                                  FStar_TypeChecker_Env.lax_universes =
                                    (uu___1665_12042.FStar_TypeChecker_Env.lax_universes);
                                  FStar_TypeChecker_Env.phase1 =
                                    (uu___1665_12042.FStar_TypeChecker_Env.phase1);
                                  FStar_TypeChecker_Env.failhard =
                                    (uu___1665_12042.FStar_TypeChecker_Env.failhard);
                                  FStar_TypeChecker_Env.nosynth =
                                    (uu___1665_12042.FStar_TypeChecker_Env.nosynth);
                                  FStar_TypeChecker_Env.uvar_subtyping =
                                    (uu___1665_12042.FStar_TypeChecker_Env.uvar_subtyping);
                                  FStar_TypeChecker_Env.tc_term =
                                    (uu___1665_12042.FStar_TypeChecker_Env.tc_term);
                                  FStar_TypeChecker_Env.type_of =
                                    (uu___1665_12042.FStar_TypeChecker_Env.type_of);
                                  FStar_TypeChecker_Env.universe_of =
                                    (uu___1665_12042.FStar_TypeChecker_Env.universe_of);
                                  FStar_TypeChecker_Env.check_type_of =
                                    (uu___1665_12042.FStar_TypeChecker_Env.check_type_of);
                                  FStar_TypeChecker_Env.use_bv_sorts =
                                    (uu___1665_12042.FStar_TypeChecker_Env.use_bv_sorts);
                                  FStar_TypeChecker_Env.qtbl_name_and_index =
                                    (uu___1665_12042.FStar_TypeChecker_Env.qtbl_name_and_index);
                                  FStar_TypeChecker_Env.normalized_eff_names
                                    =
                                    (uu___1665_12042.FStar_TypeChecker_Env.normalized_eff_names);
                                  FStar_TypeChecker_Env.fv_delta_depths =
                                    (uu___1665_12042.FStar_TypeChecker_Env.fv_delta_depths);
                                  FStar_TypeChecker_Env.proof_ns =
                                    (uu___1665_12042.FStar_TypeChecker_Env.proof_ns);
                                  FStar_TypeChecker_Env.synth_hook =
                                    (uu___1665_12042.FStar_TypeChecker_Env.synth_hook);
                                  FStar_TypeChecker_Env.try_solve_implicits_hook
                                    =
                                    (uu___1665_12042.FStar_TypeChecker_Env.try_solve_implicits_hook);
                                  FStar_TypeChecker_Env.splice =
                                    (uu___1665_12042.FStar_TypeChecker_Env.splice);
                                  FStar_TypeChecker_Env.mpreprocess =
                                    (uu___1665_12042.FStar_TypeChecker_Env.mpreprocess);
                                  FStar_TypeChecker_Env.postprocess =
                                    (uu___1665_12042.FStar_TypeChecker_Env.postprocess);
                                  FStar_TypeChecker_Env.is_native_tactic =
                                    (uu___1665_12042.FStar_TypeChecker_Env.is_native_tactic);
                                  FStar_TypeChecker_Env.identifier_info =
                                    (uu___1665_12042.FStar_TypeChecker_Env.identifier_info);
                                  FStar_TypeChecker_Env.tc_hooks =
                                    (uu___1665_12042.FStar_TypeChecker_Env.tc_hooks);
                                  FStar_TypeChecker_Env.dsenv =
                                    (uu___1665_12042.FStar_TypeChecker_Env.dsenv);
                                  FStar_TypeChecker_Env.nbe =
                                    (uu___1665_12042.FStar_TypeChecker_Env.nbe);
                                  FStar_TypeChecker_Env.strict_args_tab =
                                    (uu___1665_12042.FStar_TypeChecker_Env.strict_args_tab);
                                  FStar_TypeChecker_Env.erasable_types_tab =
                                    (uu___1665_12042.FStar_TypeChecker_Env.erasable_types_tab)
                                }  in
                              let uu____12047 =
                                mk_irrelevant_goal "joined" nenv ng
                                  g1.FStar_Tactics_Types.opts
                                  g1.FStar_Tactics_Types.label
                                 in
                              bind uu____12047
                                (fun goal  ->
                                   mlog
                                     (fun uu____12057  ->
                                        let uu____12058 =
                                          goal_to_string_verbose g1  in
                                        let uu____12060 =
                                          goal_to_string_verbose g2  in
                                        let uu____12062 =
                                          goal_to_string_verbose goal  in
                                        FStar_Util.print3
                                          "join_goals of\n(%s)\nand\n(%s)\n= (%s)\n"
                                          uu____12058 uu____12060 uu____12062)
                                     (fun uu____12066  -> ret goal))))))
  
let (join : unit -> unit tac) =
  fun uu____12074  ->
    bind get
      (fun ps  ->
         match ps.FStar_Tactics_Types.goals with
         | g1::g2::gs ->
             let uu____12090 =
               set
                 (let uu___1680_12095 = ps  in
                  {
                    FStar_Tactics_Types.main_context =
                      (uu___1680_12095.FStar_Tactics_Types.main_context);
                    FStar_Tactics_Types.all_implicits =
                      (uu___1680_12095.FStar_Tactics_Types.all_implicits);
                    FStar_Tactics_Types.goals = gs;
                    FStar_Tactics_Types.smt_goals =
                      (uu___1680_12095.FStar_Tactics_Types.smt_goals);
                    FStar_Tactics_Types.depth =
                      (uu___1680_12095.FStar_Tactics_Types.depth);
                    FStar_Tactics_Types.__dump =
                      (uu___1680_12095.FStar_Tactics_Types.__dump);
                    FStar_Tactics_Types.psc =
                      (uu___1680_12095.FStar_Tactics_Types.psc);
                    FStar_Tactics_Types.entry_range =
                      (uu___1680_12095.FStar_Tactics_Types.entry_range);
                    FStar_Tactics_Types.guard_policy =
                      (uu___1680_12095.FStar_Tactics_Types.guard_policy);
                    FStar_Tactics_Types.freshness =
                      (uu___1680_12095.FStar_Tactics_Types.freshness);
                    FStar_Tactics_Types.tac_verb_dbg =
                      (uu___1680_12095.FStar_Tactics_Types.tac_verb_dbg);
                    FStar_Tactics_Types.local_state =
                      (uu___1680_12095.FStar_Tactics_Types.local_state)
                  })
                in
             bind uu____12090
               (fun uu____12098  ->
                  let uu____12099 = join_goals g1 g2  in
                  bind uu____12099 (fun g12  -> add_goals [g12]))
         | uu____12104 -> fail "join: less than 2 goals")
  
let (set_options : Prims.string -> unit tac) =
  fun s  ->
    let uu____12120 =
      let uu____12123 = cur_goal ()  in
      bind uu____12123
        (fun g  ->
           FStar_Options.push ();
           (let uu____12136 = FStar_Util.smap_copy g.FStar_Tactics_Types.opts
               in
            FStar_Options.set uu____12136);
           (let res = FStar_Options.set_options s  in
            let opts' = FStar_Options.peek ()  in
            FStar_Options.pop ();
            (match res with
             | FStar_Getopt.Success  ->
                 let g' =
                   let uu___1691_12143 = g  in
                   {
                     FStar_Tactics_Types.goal_main_env =
                       (uu___1691_12143.FStar_Tactics_Types.goal_main_env);
                     FStar_Tactics_Types.goal_ctx_uvar =
                       (uu___1691_12143.FStar_Tactics_Types.goal_ctx_uvar);
                     FStar_Tactics_Types.opts = opts';
                     FStar_Tactics_Types.is_guard =
                       (uu___1691_12143.FStar_Tactics_Types.is_guard);
                     FStar_Tactics_Types.label =
                       (uu___1691_12143.FStar_Tactics_Types.label)
                   }  in
                 replace_cur g'
             | FStar_Getopt.Error err ->
                 fail2 "Setting options `%s` failed: %s" s err
             | FStar_Getopt.Help  ->
                 fail1 "Setting options `%s` failed (got `Help`?)" s)))
       in
    FStar_All.pipe_left (wrap_err "set_options") uu____12120
  
let (top_env : unit -> env tac) =
  fun uu____12160  ->
    bind get
      (fun ps  -> FStar_All.pipe_left ret ps.FStar_Tactics_Types.main_context)
  
let (lax_on : unit -> Prims.bool tac) =
  fun uu____12175  ->
    let uu____12179 = cur_goal ()  in
    bind uu____12179
      (fun g  ->
         let uu____12186 =
           (FStar_Options.lax ()) ||
             (let uu____12189 = FStar_Tactics_Types.goal_env g  in
              uu____12189.FStar_TypeChecker_Env.lax)
            in
         ret uu____12186)
  
let (unquote :
  FStar_Reflection_Data.typ ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun ty  ->
    fun tm  ->
      let uu____12206 =
        mlog
          (fun uu____12211  ->
             let uu____12212 = FStar_Syntax_Print.term_to_string tm  in
             FStar_Util.print1 "unquote: tm = %s\n" uu____12212)
          (fun uu____12217  ->
             let uu____12218 = cur_goal ()  in
             bind uu____12218
               (fun goal  ->
                  let env1 =
                    let uu____12226 = FStar_Tactics_Types.goal_env goal  in
                    FStar_TypeChecker_Env.set_expected_typ uu____12226 ty  in
                  let uu____12227 = __tc_ghost env1 tm  in
                  bind uu____12227
                    (fun uu____12246  ->
                       match uu____12246 with
                       | (tm1,typ,guard) ->
                           mlog
                             (fun uu____12260  ->
                                let uu____12261 =
                                  FStar_Syntax_Print.term_to_string tm1  in
                                FStar_Util.print1 "unquote: tm' = %s\n"
                                  uu____12261)
                             (fun uu____12265  ->
                                mlog
                                  (fun uu____12268  ->
                                     let uu____12269 =
                                       FStar_Syntax_Print.term_to_string typ
                                        in
                                     FStar_Util.print1 "unquote: typ = %s\n"
                                       uu____12269)
                                  (fun uu____12274  ->
                                     let uu____12275 =
                                       proc_guard "unquote" env1 guard  in
                                     bind uu____12275
                                       (fun uu____12280  -> ret tm1))))))
         in
      FStar_All.pipe_left (wrap_err "unquote") uu____12206
  
let (uvar_env :
  env ->
    FStar_Reflection_Data.typ FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.term tac)
  =
  fun env1  ->
    fun ty  ->
      let uu____12305 =
        match ty with
        | FStar_Pervasives_Native.Some ty1 -> ret ty1
        | FStar_Pervasives_Native.None  ->
            let uu____12311 =
              let uu____12318 =
                let uu____12319 = FStar_Syntax_Util.type_u ()  in
                FStar_All.pipe_left FStar_Pervasives_Native.fst uu____12319
                 in
              new_uvar "uvar_env.2" env1 uu____12318  in
            bind uu____12311
              (fun uu____12336  ->
                 match uu____12336 with | (typ,uvar_typ) -> ret typ)
         in
      bind uu____12305
        (fun typ  ->
           let uu____12348 = new_uvar "uvar_env" env1 typ  in
           bind uu____12348
             (fun uu____12363  ->
                match uu____12363 with | (t,uvar_t) -> ret t))
  
let (unshelve : FStar_Syntax_Syntax.term -> unit tac) =
  fun t  ->
    let uu____12382 =
      bind get
        (fun ps  ->
           let env1 = ps.FStar_Tactics_Types.main_context  in
           let opts =
             match ps.FStar_Tactics_Types.goals with
             | g::uu____12401 -> g.FStar_Tactics_Types.opts
             | uu____12404 -> FStar_Options.peek ()  in
           let uu____12407 = FStar_Syntax_Util.head_and_args t  in
           match uu____12407 with
           | ({
                FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_uvar
                  (ctx_uvar,uu____12427);
                FStar_Syntax_Syntax.pos = uu____12428;
                FStar_Syntax_Syntax.vars = uu____12429;_},uu____12430)
               ->
               let env2 =
                 let uu___1745_12472 = env1  in
                 {
                   FStar_TypeChecker_Env.solver =
                     (uu___1745_12472.FStar_TypeChecker_Env.solver);
                   FStar_TypeChecker_Env.range =
                     (uu___1745_12472.FStar_TypeChecker_Env.range);
                   FStar_TypeChecker_Env.curmodule =
                     (uu___1745_12472.FStar_TypeChecker_Env.curmodule);
                   FStar_TypeChecker_Env.gamma =
                     (ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_gamma);
                   FStar_TypeChecker_Env.gamma_sig =
                     (uu___1745_12472.FStar_TypeChecker_Env.gamma_sig);
                   FStar_TypeChecker_Env.gamma_cache =
                     (uu___1745_12472.FStar_TypeChecker_Env.gamma_cache);
                   FStar_TypeChecker_Env.modules =
                     (uu___1745_12472.FStar_TypeChecker_Env.modules);
                   FStar_TypeChecker_Env.expected_typ =
                     (uu___1745_12472.FStar_TypeChecker_Env.expected_typ);
                   FStar_TypeChecker_Env.sigtab =
                     (uu___1745_12472.FStar_TypeChecker_Env.sigtab);
                   FStar_TypeChecker_Env.attrtab =
                     (uu___1745_12472.FStar_TypeChecker_Env.attrtab);
                   FStar_TypeChecker_Env.instantiate_imp =
                     (uu___1745_12472.FStar_TypeChecker_Env.instantiate_imp);
                   FStar_TypeChecker_Env.effects =
                     (uu___1745_12472.FStar_TypeChecker_Env.effects);
                   FStar_TypeChecker_Env.generalize =
                     (uu___1745_12472.FStar_TypeChecker_Env.generalize);
                   FStar_TypeChecker_Env.letrecs =
                     (uu___1745_12472.FStar_TypeChecker_Env.letrecs);
                   FStar_TypeChecker_Env.top_level =
                     (uu___1745_12472.FStar_TypeChecker_Env.top_level);
                   FStar_TypeChecker_Env.check_uvars =
                     (uu___1745_12472.FStar_TypeChecker_Env.check_uvars);
                   FStar_TypeChecker_Env.use_eq =
                     (uu___1745_12472.FStar_TypeChecker_Env.use_eq);
                   FStar_TypeChecker_Env.use_eq_strict =
                     (uu___1745_12472.FStar_TypeChecker_Env.use_eq_strict);
                   FStar_TypeChecker_Env.is_iface =
                     (uu___1745_12472.FStar_TypeChecker_Env.is_iface);
                   FStar_TypeChecker_Env.admit =
                     (uu___1745_12472.FStar_TypeChecker_Env.admit);
                   FStar_TypeChecker_Env.lax =
                     (uu___1745_12472.FStar_TypeChecker_Env.lax);
                   FStar_TypeChecker_Env.lax_universes =
                     (uu___1745_12472.FStar_TypeChecker_Env.lax_universes);
                   FStar_TypeChecker_Env.phase1 =
                     (uu___1745_12472.FStar_TypeChecker_Env.phase1);
                   FStar_TypeChecker_Env.failhard =
                     (uu___1745_12472.FStar_TypeChecker_Env.failhard);
                   FStar_TypeChecker_Env.nosynth =
                     (uu___1745_12472.FStar_TypeChecker_Env.nosynth);
                   FStar_TypeChecker_Env.uvar_subtyping =
                     (uu___1745_12472.FStar_TypeChecker_Env.uvar_subtyping);
                   FStar_TypeChecker_Env.tc_term =
                     (uu___1745_12472.FStar_TypeChecker_Env.tc_term);
                   FStar_TypeChecker_Env.type_of =
                     (uu___1745_12472.FStar_TypeChecker_Env.type_of);
                   FStar_TypeChecker_Env.universe_of =
                     (uu___1745_12472.FStar_TypeChecker_Env.universe_of);
                   FStar_TypeChecker_Env.check_type_of =
                     (uu___1745_12472.FStar_TypeChecker_Env.check_type_of);
                   FStar_TypeChecker_Env.use_bv_sorts =
                     (uu___1745_12472.FStar_TypeChecker_Env.use_bv_sorts);
                   FStar_TypeChecker_Env.qtbl_name_and_index =
                     (uu___1745_12472.FStar_TypeChecker_Env.qtbl_name_and_index);
                   FStar_TypeChecker_Env.normalized_eff_names =
                     (uu___1745_12472.FStar_TypeChecker_Env.normalized_eff_names);
                   FStar_TypeChecker_Env.fv_delta_depths =
                     (uu___1745_12472.FStar_TypeChecker_Env.fv_delta_depths);
                   FStar_TypeChecker_Env.proof_ns =
                     (uu___1745_12472.FStar_TypeChecker_Env.proof_ns);
                   FStar_TypeChecker_Env.synth_hook =
                     (uu___1745_12472.FStar_TypeChecker_Env.synth_hook);
                   FStar_TypeChecker_Env.try_solve_implicits_hook =
                     (uu___1745_12472.FStar_TypeChecker_Env.try_solve_implicits_hook);
                   FStar_TypeChecker_Env.splice =
                     (uu___1745_12472.FStar_TypeChecker_Env.splice);
                   FStar_TypeChecker_Env.mpreprocess =
                     (uu___1745_12472.FStar_TypeChecker_Env.mpreprocess);
                   FStar_TypeChecker_Env.postprocess =
                     (uu___1745_12472.FStar_TypeChecker_Env.postprocess);
                   FStar_TypeChecker_Env.is_native_tactic =
                     (uu___1745_12472.FStar_TypeChecker_Env.is_native_tactic);
                   FStar_TypeChecker_Env.identifier_info =
                     (uu___1745_12472.FStar_TypeChecker_Env.identifier_info);
                   FStar_TypeChecker_Env.tc_hooks =
                     (uu___1745_12472.FStar_TypeChecker_Env.tc_hooks);
                   FStar_TypeChecker_Env.dsenv =
                     (uu___1745_12472.FStar_TypeChecker_Env.dsenv);
                   FStar_TypeChecker_Env.nbe =
                     (uu___1745_12472.FStar_TypeChecker_Env.nbe);
                   FStar_TypeChecker_Env.strict_args_tab =
                     (uu___1745_12472.FStar_TypeChecker_Env.strict_args_tab);
                   FStar_TypeChecker_Env.erasable_types_tab =
                     (uu___1745_12472.FStar_TypeChecker_Env.erasable_types_tab)
                 }  in
               let g =
                 FStar_Tactics_Types.mk_goal env2 ctx_uvar opts false ""  in
               let uu____12476 =
                 let uu____12479 = bnorm_goal g  in [uu____12479]  in
               add_goals uu____12476
           | uu____12480 -> fail "not a uvar")
       in
    FStar_All.pipe_left (wrap_err "unshelve") uu____12382
  
let (tac_and : Prims.bool tac -> Prims.bool tac -> Prims.bool tac) =
  fun t1  ->
    fun t2  ->
      let comp =
        bind t1
          (fun b  ->
             let uu____12542 = if b then t2 else ret false  in
             bind uu____12542 (fun b'  -> if b' then ret b' else fail ""))
         in
      let uu____12568 = trytac comp  in
      bind uu____12568
        (fun uu___6_12580  ->
           match uu___6_12580 with
           | FStar_Pervasives_Native.Some (true ) -> ret true
           | FStar_Pervasives_Native.Some (false ) -> failwith "impossible"
           | FStar_Pervasives_Native.None  -> ret false)
  
let (unify_env :
  env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac)
  =
  fun e  ->
    fun t1  ->
      fun t2  ->
        let uu____12622 =
          bind get
            (fun ps  ->
               let uu____12630 = __tc e t1  in
               bind uu____12630
                 (fun uu____12651  ->
                    match uu____12651 with
                    | (t11,ty1,g1) ->
                        let uu____12664 = __tc e t2  in
                        bind uu____12664
                          (fun uu____12685  ->
                             match uu____12685 with
                             | (t21,ty2,g2) ->
                                 let uu____12698 =
                                   proc_guard "unify_env g1" e g1  in
                                 bind uu____12698
                                   (fun uu____12705  ->
                                      let uu____12706 =
                                        proc_guard "unify_env g2" e g2  in
                                      bind uu____12706
                                        (fun uu____12714  ->
                                           let uu____12715 =
                                             do_unify e ty1 ty2  in
                                           let uu____12719 =
                                             do_unify e t11 t21  in
                                           tac_and uu____12715 uu____12719)))))
           in
        FStar_All.pipe_left (wrap_err "unify_env") uu____12622
  
let (launch_process :
  Prims.string -> Prims.string Prims.list -> Prims.string -> Prims.string tac)
  =
  fun prog  ->
    fun args  ->
      fun input  ->
        bind idtac
          (fun uu____12767  ->
             let uu____12768 = FStar_Options.unsafe_tactic_exec ()  in
             if uu____12768
             then
               let s =
                 FStar_Util.run_process "tactic_launch" prog args
                   (FStar_Pervasives_Native.Some input)
                  in
               ret s
             else
               fail
                 "launch_process: will not run anything unless --unsafe_tactic_exec is provided")
  
let (fresh_bv_named :
  Prims.string -> FStar_Reflection_Data.typ -> FStar_Syntax_Syntax.bv tac) =
  fun nm  ->
    fun t  ->
      bind idtac
        (fun uu____12802  ->
           let uu____12803 =
             FStar_Syntax_Syntax.gen_bv nm FStar_Pervasives_Native.None t  in
           ret uu____12803)
  
let (change : FStar_Reflection_Data.typ -> unit tac) =
  fun ty  ->
    let uu____12814 =
      mlog
        (fun uu____12819  ->
           let uu____12820 = FStar_Syntax_Print.term_to_string ty  in
           FStar_Util.print1 "change: ty = %s\n" uu____12820)
        (fun uu____12825  ->
           let uu____12826 = cur_goal ()  in
           bind uu____12826
             (fun g  ->
                let uu____12832 =
                  let uu____12841 = FStar_Tactics_Types.goal_env g  in
                  __tc uu____12841 ty  in
                bind uu____12832
                  (fun uu____12853  ->
                     match uu____12853 with
                     | (ty1,uu____12863,guard) ->
                         let uu____12865 =
                           let uu____12868 = FStar_Tactics_Types.goal_env g
                              in
                           proc_guard "change" uu____12868 guard  in
                         bind uu____12865
                           (fun uu____12872  ->
                              let uu____12873 =
                                let uu____12877 =
                                  FStar_Tactics_Types.goal_env g  in
                                let uu____12878 =
                                  FStar_Tactics_Types.goal_type g  in
                                do_unify uu____12877 uu____12878 ty1  in
                              bind uu____12873
                                (fun bb  ->
                                   if bb
                                   then
                                     let uu____12887 =
                                       FStar_Tactics_Types.goal_with_type g
                                         ty1
                                        in
                                     replace_cur uu____12887
                                   else
                                     (let steps =
                                        [FStar_TypeChecker_Env.AllowUnboundUniverses;
                                        FStar_TypeChecker_Env.UnfoldUntil
                                          FStar_Syntax_Syntax.delta_constant;
                                        FStar_TypeChecker_Env.Primops]  in
                                      let ng =
                                        let uu____12894 =
                                          FStar_Tactics_Types.goal_env g  in
                                        let uu____12895 =
                                          FStar_Tactics_Types.goal_type g  in
                                        normalize steps uu____12894
                                          uu____12895
                                         in
                                      let nty =
                                        let uu____12897 =
                                          FStar_Tactics_Types.goal_env g  in
                                        normalize steps uu____12897 ty1  in
                                      let uu____12898 =
                                        let uu____12902 =
                                          FStar_Tactics_Types.goal_env g  in
                                        do_unify uu____12902 ng nty  in
                                      bind uu____12898
                                        (fun b  ->
                                           if b
                                           then
                                             let uu____12911 =
                                               FStar_Tactics_Types.goal_with_type
                                                 g ty1
                                                in
                                             replace_cur uu____12911
                                           else fail "not convertible")))))))
       in
    FStar_All.pipe_left (wrap_err "change") uu____12814
  
let failwhen : 'a . Prims.bool -> Prims.string -> (unit -> 'a tac) -> 'a tac
  = fun b  -> fun msg  -> fun k  -> if b then fail msg else k () 
let (t_destruct :
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.fv * FStar_BigInt.t) Prims.list tac)
  =
  fun s_tm  ->
    let uu____12985 =
      let uu____12994 = cur_goal ()  in
      bind uu____12994
        (fun g  ->
           let uu____13006 =
             let uu____13015 = FStar_Tactics_Types.goal_env g  in
             __tc uu____13015 s_tm  in
           bind uu____13006
             (fun uu____13033  ->
                match uu____13033 with
                | (s_tm1,s_ty,guard) ->
                    let uu____13051 =
                      let uu____13054 = FStar_Tactics_Types.goal_env g  in
                      proc_guard "destruct" uu____13054 guard  in
                    bind uu____13051
                      (fun uu____13068  ->
                         let s_ty1 =
                           let uu____13070 = FStar_Tactics_Types.goal_env g
                              in
                           FStar_TypeChecker_Normalize.normalize
                             [FStar_TypeChecker_Env.UnfoldTac;
                             FStar_TypeChecker_Env.Weak;
                             FStar_TypeChecker_Env.HNF;
                             FStar_TypeChecker_Env.UnfoldUntil
                               FStar_Syntax_Syntax.delta_constant]
                             uu____13070 s_ty
                            in
                         let uu____13071 =
                           FStar_Syntax_Util.head_and_args' s_ty1  in
                         match uu____13071 with
                         | (h,args) ->
                             let uu____13116 =
                               let uu____13123 =
                                 let uu____13124 =
                                   FStar_Syntax_Subst.compress h  in
                                 uu____13124.FStar_Syntax_Syntax.n  in
                               match uu____13123 with
                               | FStar_Syntax_Syntax.Tm_fvar fv ->
                                   ret (fv, [])
                               | FStar_Syntax_Syntax.Tm_uinst
                                   ({
                                      FStar_Syntax_Syntax.n =
                                        FStar_Syntax_Syntax.Tm_fvar fv;
                                      FStar_Syntax_Syntax.pos = uu____13139;
                                      FStar_Syntax_Syntax.vars = uu____13140;_},us)
                                   -> ret (fv, us)
                               | uu____13150 -> fail "type is not an fv"  in
                             bind uu____13116
                               (fun uu____13171  ->
                                  match uu____13171 with
                                  | (fv,a_us) ->
                                      let t_lid =
                                        FStar_Syntax_Syntax.lid_of_fv fv  in
                                      let uu____13187 =
                                        let uu____13190 =
                                          FStar_Tactics_Types.goal_env g  in
                                        FStar_TypeChecker_Env.lookup_sigelt
                                          uu____13190 t_lid
                                         in
                                      (match uu____13187 with
                                       | FStar_Pervasives_Native.None  ->
                                           fail
                                             "type not found in environment"
                                       | FStar_Pervasives_Native.Some se ->
                                           (match se.FStar_Syntax_Syntax.sigel
                                            with
                                            | FStar_Syntax_Syntax.Sig_inductive_typ
                                                (_lid,t_us,t_ps,t_ty,mut,c_lids)
                                                ->
                                                let erasable =
                                                  FStar_Syntax_Util.has_attribute
                                                    se.FStar_Syntax_Syntax.sigattrs
                                                    FStar_Parser_Const.erasable_attr
                                                   in
                                                let uu____13231 =
                                                  erasable &&
                                                    (let uu____13234 =
                                                       is_irrelevant g  in
                                                     Prims.op_Negation
                                                       uu____13234)
                                                   in
                                                failwhen uu____13231
                                                  "cannot destruct erasable type to solve proof-relevant goal"
                                                  (fun uu____13244  ->
                                                     failwhen
                                                       ((FStar_List.length
                                                           a_us)
                                                          <>
                                                          (FStar_List.length
                                                             t_us))
                                                       "t_us don't match?"
                                                       (fun uu____13257  ->
                                                          let uu____13258 =
                                                            FStar_Syntax_Subst.open_term
                                                              t_ps t_ty
                                                             in
                                                          match uu____13258
                                                          with
                                                          | (t_ps1,t_ty1) ->
                                                              let uu____13273
                                                                =
                                                                mapM
                                                                  (fun c_lid 
                                                                    ->
                                                                    let uu____13301
                                                                    =
                                                                    let uu____13304
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    g  in
                                                                    FStar_TypeChecker_Env.lookup_sigelt
                                                                    uu____13304
                                                                    c_lid  in
                                                                    match uu____13301
                                                                    with
                                                                    | 
                                                                    FStar_Pervasives_Native.None
                                                                     ->
                                                                    fail
                                                                    "ctor not found?"
                                                                    | 
                                                                    FStar_Pervasives_Native.Some
                                                                    se1 ->
                                                                    (match 
                                                                    se1.FStar_Syntax_Syntax.sigel
                                                                    with
                                                                    | 
                                                                    FStar_Syntax_Syntax.Sig_datacon
                                                                    (_c_lid,c_us,c_ty,_t_lid,nparam,mut1)
                                                                    ->
                                                                    let fv1 =
                                                                    FStar_Syntax_Syntax.lid_as_fv
                                                                    c_lid
                                                                    FStar_Syntax_Syntax.delta_constant
                                                                    (FStar_Pervasives_Native.Some
                                                                    FStar_Syntax_Syntax.Data_ctor)
                                                                     in
                                                                    failwhen
                                                                    ((FStar_List.length
                                                                    a_us) <>
                                                                    (FStar_List.length
                                                                    c_us))
                                                                    "t_us don't match?"
                                                                    (fun
                                                                    uu____13381
                                                                     ->
                                                                    let s =
                                                                    FStar_TypeChecker_Env.mk_univ_subst
                                                                    c_us a_us
                                                                     in
                                                                    let c_ty1
                                                                    =
                                                                    FStar_Syntax_Subst.subst
                                                                    s c_ty
                                                                     in
                                                                    let uu____13386
                                                                    =
                                                                    FStar_TypeChecker_Env.inst_tscheme
                                                                    (c_us,
                                                                    c_ty1)
                                                                     in
                                                                    match uu____13386
                                                                    with
                                                                    | 
                                                                    (c_us1,c_ty2)
                                                                    ->
                                                                    let uu____13409
                                                                    =
                                                                    FStar_Syntax_Util.arrow_formals_comp
                                                                    c_ty2  in
                                                                    (match uu____13409
                                                                    with
                                                                    | 
                                                                    (bs,comp)
                                                                    ->
                                                                    let uu____13428
                                                                    =
                                                                    let rename_bv
                                                                    bv =
                                                                    let ppname
                                                                    =
                                                                    bv.FStar_Syntax_Syntax.ppname
                                                                     in
                                                                    let ppname1
                                                                    =
                                                                    let uu___1872_13451
                                                                    = ppname
                                                                     in
                                                                    {
                                                                    FStar_Ident.idText
                                                                    =
                                                                    (Prims.op_Hat
                                                                    "a"
                                                                    ppname.FStar_Ident.idText);
                                                                    FStar_Ident.idRange
                                                                    =
                                                                    (uu___1872_13451.FStar_Ident.idRange)
                                                                    }  in
                                                                    FStar_Syntax_Syntax.freshen_bv
                                                                    (let uu___1875_13455
                                                                    = bv  in
                                                                    {
                                                                    FStar_Syntax_Syntax.ppname
                                                                    = ppname1;
                                                                    FStar_Syntax_Syntax.index
                                                                    =
                                                                    (uu___1875_13455.FStar_Syntax_Syntax.index);
                                                                    FStar_Syntax_Syntax.sort
                                                                    =
                                                                    (uu___1875_13455.FStar_Syntax_Syntax.sort)
                                                                    })  in
                                                                    let bs' =
                                                                    FStar_List.map
                                                                    (fun
                                                                    uu____13481
                                                                     ->
                                                                    match uu____13481
                                                                    with
                                                                    | 
                                                                    (bv,aq)
                                                                    ->
                                                                    let uu____13500
                                                                    =
                                                                    rename_bv
                                                                    bv  in
                                                                    (uu____13500,
                                                                    aq)) bs
                                                                     in
                                                                    let subst
                                                                    =
                                                                    FStar_List.map2
                                                                    (fun
                                                                    uu____13525
                                                                     ->
                                                                    fun
                                                                    uu____13526
                                                                     ->
                                                                    match 
                                                                    (uu____13525,
                                                                    uu____13526)
                                                                    with
                                                                    | 
                                                                    ((bv,uu____13552),
                                                                    (bv',uu____13554))
                                                                    ->
                                                                    let uu____13575
                                                                    =
                                                                    let uu____13582
                                                                    =
                                                                    FStar_Syntax_Syntax.bv_to_name
                                                                    bv'  in
                                                                    (bv,
                                                                    uu____13582)
                                                                     in
                                                                    FStar_Syntax_Syntax.NT
                                                                    uu____13575)
                                                                    bs bs'
                                                                     in
                                                                    let uu____13587
                                                                    =
                                                                    FStar_Syntax_Subst.subst_binders
                                                                    subst bs'
                                                                     in
                                                                    let uu____13596
                                                                    =
                                                                    FStar_Syntax_Subst.subst_comp
                                                                    subst
                                                                    comp  in
                                                                    (uu____13587,
                                                                    uu____13596)
                                                                     in
                                                                    (match uu____13428
                                                                    with
                                                                    | 
                                                                    (bs1,comp1)
                                                                    ->
                                                                    let uu____13643
                                                                    =
                                                                    FStar_List.splitAt
                                                                    nparam
                                                                    bs1  in
                                                                    (match uu____13643
                                                                    with
                                                                    | 
                                                                    (d_ps,bs2)
                                                                    ->
                                                                    let uu____13716
                                                                    =
                                                                    let uu____13718
                                                                    =
                                                                    FStar_Syntax_Util.is_total_comp
                                                                    comp1  in
                                                                    Prims.op_Negation
                                                                    uu____13718
                                                                     in
                                                                    failwhen
                                                                    uu____13716
                                                                    "not total?"
                                                                    (fun
                                                                    uu____13737
                                                                     ->
                                                                    let mk_pat
                                                                    p =
                                                                    {
                                                                    FStar_Syntax_Syntax.v
                                                                    = p;
                                                                    FStar_Syntax_Syntax.p
                                                                    =
                                                                    (s_tm1.FStar_Syntax_Syntax.pos)
                                                                    }  in
                                                                    let is_imp
                                                                    uu___7_13754
                                                                    =
                                                                    match uu___7_13754
                                                                    with
                                                                    | 
                                                                    FStar_Pervasives_Native.Some
                                                                    (FStar_Syntax_Syntax.Implicit
                                                                    uu____13758)
                                                                    -> true
                                                                    | 
                                                                    uu____13761
                                                                    -> false
                                                                     in
                                                                    let uu____13765
                                                                    =
                                                                    FStar_List.splitAt
                                                                    nparam
                                                                    args  in
                                                                    match uu____13765
                                                                    with
                                                                    | 
                                                                    (a_ps,a_is)
                                                                    ->
                                                                    failwhen
                                                                    ((FStar_List.length
                                                                    a_ps) <>
                                                                    (FStar_List.length
                                                                    d_ps))
                                                                    "params not match?"
                                                                    (fun
                                                                    uu____13901
                                                                     ->
                                                                    let d_ps_a_ps
                                                                    =
                                                                    FStar_List.zip
                                                                    d_ps a_ps
                                                                     in
                                                                    let subst
                                                                    =
                                                                    FStar_List.map
                                                                    (fun
                                                                    uu____13963
                                                                     ->
                                                                    match uu____13963
                                                                    with
                                                                    | 
                                                                    ((bv,uu____13983),
                                                                    (t,uu____13985))
                                                                    ->
                                                                    FStar_Syntax_Syntax.NT
                                                                    (bv, t))
                                                                    d_ps_a_ps
                                                                     in
                                                                    let bs3 =
                                                                    FStar_Syntax_Subst.subst_binders
                                                                    subst bs2
                                                                     in
                                                                    let subpats_1
                                                                    =
                                                                    FStar_List.map
                                                                    (fun
                                                                    uu____14055
                                                                     ->
                                                                    match uu____14055
                                                                    with
                                                                    | 
                                                                    ((bv,uu____14082),
                                                                    (t,uu____14084))
                                                                    ->
                                                                    ((mk_pat
                                                                    (FStar_Syntax_Syntax.Pat_dot_term
                                                                    (bv, t))),
                                                                    true))
                                                                    d_ps_a_ps
                                                                     in
                                                                    let subpats_2
                                                                    =
                                                                    FStar_List.map
                                                                    (fun
                                                                    uu____14143
                                                                     ->
                                                                    match uu____14143
                                                                    with
                                                                    | 
                                                                    (bv,aq)
                                                                    ->
                                                                    ((mk_pat
                                                                    (FStar_Syntax_Syntax.Pat_var
                                                                    bv)),
                                                                    (is_imp
                                                                    aq))) bs3
                                                                     in
                                                                    let subpats
                                                                    =
                                                                    FStar_List.append
                                                                    subpats_1
                                                                    subpats_2
                                                                     in
                                                                    let pat =
                                                                    mk_pat
                                                                    (FStar_Syntax_Syntax.Pat_cons
                                                                    (fv1,
                                                                    subpats))
                                                                     in
                                                                    let env1
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    g  in
                                                                    let cod =
                                                                    FStar_Tactics_Types.goal_type
                                                                    g  in
                                                                    let equ =
                                                                    env1.FStar_TypeChecker_Env.universe_of
                                                                    env1
                                                                    s_ty1  in
                                                                    let uu____14198
                                                                    =
                                                                    FStar_TypeChecker_TcTerm.tc_pat
                                                                    (let uu___1934_14222
                                                                    = env1
                                                                     in
                                                                    {
                                                                    FStar_TypeChecker_Env.solver
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.solver);
                                                                    FStar_TypeChecker_Env.range
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.range);
                                                                    FStar_TypeChecker_Env.curmodule
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.curmodule);
                                                                    FStar_TypeChecker_Env.gamma
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.gamma);
                                                                    FStar_TypeChecker_Env.gamma_sig
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.gamma_sig);
                                                                    FStar_TypeChecker_Env.gamma_cache
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.gamma_cache);
                                                                    FStar_TypeChecker_Env.modules
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.modules);
                                                                    FStar_TypeChecker_Env.expected_typ
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.expected_typ);
                                                                    FStar_TypeChecker_Env.sigtab
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.sigtab);
                                                                    FStar_TypeChecker_Env.attrtab
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.attrtab);
                                                                    FStar_TypeChecker_Env.instantiate_imp
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.instantiate_imp);
                                                                    FStar_TypeChecker_Env.effects
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.effects);
                                                                    FStar_TypeChecker_Env.generalize
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.generalize);
                                                                    FStar_TypeChecker_Env.letrecs
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.letrecs);
                                                                    FStar_TypeChecker_Env.top_level
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.top_level);
                                                                    FStar_TypeChecker_Env.check_uvars
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.check_uvars);
                                                                    FStar_TypeChecker_Env.use_eq
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.use_eq);
                                                                    FStar_TypeChecker_Env.use_eq_strict
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.use_eq_strict);
                                                                    FStar_TypeChecker_Env.is_iface
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.is_iface);
                                                                    FStar_TypeChecker_Env.admit
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.admit);
                                                                    FStar_TypeChecker_Env.lax
                                                                    = true;
                                                                    FStar_TypeChecker_Env.lax_universes
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.lax_universes);
                                                                    FStar_TypeChecker_Env.phase1
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.phase1);
                                                                    FStar_TypeChecker_Env.failhard
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.failhard);
                                                                    FStar_TypeChecker_Env.nosynth
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.nosynth);
                                                                    FStar_TypeChecker_Env.uvar_subtyping
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.uvar_subtyping);
                                                                    FStar_TypeChecker_Env.tc_term
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.tc_term);
                                                                    FStar_TypeChecker_Env.type_of
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.type_of);
                                                                    FStar_TypeChecker_Env.universe_of
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.universe_of);
                                                                    FStar_TypeChecker_Env.check_type_of
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.check_type_of);
                                                                    FStar_TypeChecker_Env.use_bv_sorts
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.use_bv_sorts);
                                                                    FStar_TypeChecker_Env.qtbl_name_and_index
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.qtbl_name_and_index);
                                                                    FStar_TypeChecker_Env.normalized_eff_names
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.normalized_eff_names);
                                                                    FStar_TypeChecker_Env.fv_delta_depths
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.fv_delta_depths);
                                                                    FStar_TypeChecker_Env.proof_ns
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.proof_ns);
                                                                    FStar_TypeChecker_Env.synth_hook
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.synth_hook);
                                                                    FStar_TypeChecker_Env.try_solve_implicits_hook
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.try_solve_implicits_hook);
                                                                    FStar_TypeChecker_Env.splice
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.splice);
                                                                    FStar_TypeChecker_Env.mpreprocess
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.mpreprocess);
                                                                    FStar_TypeChecker_Env.postprocess
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.postprocess);
                                                                    FStar_TypeChecker_Env.is_native_tactic
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.is_native_tactic);
                                                                    FStar_TypeChecker_Env.identifier_info
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.identifier_info);
                                                                    FStar_TypeChecker_Env.tc_hooks
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.tc_hooks);
                                                                    FStar_TypeChecker_Env.dsenv
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.dsenv);
                                                                    FStar_TypeChecker_Env.nbe
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.nbe);
                                                                    FStar_TypeChecker_Env.strict_args_tab
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.strict_args_tab);
                                                                    FStar_TypeChecker_Env.erasable_types_tab
                                                                    =
                                                                    (uu___1934_14222.FStar_TypeChecker_Env.erasable_types_tab)
                                                                    }) s_ty1
                                                                    pat  in
                                                                    match uu____14198
                                                                    with
                                                                    | 
                                                                    (uu____14236,uu____14237,uu____14238,uu____14239,pat_t,uu____14241,_guard_pat,_erasable)
                                                                    ->
                                                                    let eq_b
                                                                    =
                                                                    let uu____14255
                                                                    =
                                                                    let uu____14256
                                                                    =
                                                                    FStar_Syntax_Util.mk_eq2
                                                                    equ s_ty1
                                                                    s_tm1
                                                                    pat_t  in
                                                                    FStar_Syntax_Util.mk_squash
                                                                    equ
                                                                    uu____14256
                                                                     in
                                                                    FStar_Syntax_Syntax.gen_bv
                                                                    "breq"
                                                                    FStar_Pervasives_Native.None
                                                                    uu____14255
                                                                     in
                                                                    let cod1
                                                                    =
                                                                    let uu____14261
                                                                    =
                                                                    let uu____14270
                                                                    =
                                                                    FStar_Syntax_Syntax.mk_binder
                                                                    eq_b  in
                                                                    [uu____14270]
                                                                     in
                                                                    let uu____14289
                                                                    =
                                                                    FStar_Syntax_Syntax.mk_Total
                                                                    cod  in
                                                                    FStar_Syntax_Util.arrow
                                                                    uu____14261
                                                                    uu____14289
                                                                     in
                                                                    let nty =
                                                                    let uu____14295
                                                                    =
                                                                    FStar_Syntax_Syntax.mk_Total
                                                                    cod1  in
                                                                    FStar_Syntax_Util.arrow
                                                                    bs3
                                                                    uu____14295
                                                                     in
                                                                    let uu____14298
                                                                    =
                                                                    new_uvar
                                                                    "destruct branch"
                                                                    env1 nty
                                                                     in
                                                                    bind
                                                                    uu____14298
                                                                    (fun
                                                                    uu____14328
                                                                     ->
                                                                    match uu____14328
                                                                    with
                                                                    | 
                                                                    (uvt,uv)
                                                                    ->
                                                                    let g' =
                                                                    FStar_Tactics_Types.mk_goal
                                                                    env1 uv
                                                                    g.FStar_Tactics_Types.opts
                                                                    false
                                                                    g.FStar_Tactics_Types.label
                                                                     in
                                                                    let brt =
                                                                    FStar_Syntax_Util.mk_app_binders
                                                                    uvt bs3
                                                                     in
                                                                    let brt1
                                                                    =
                                                                    let uu____14355
                                                                    =
                                                                    let uu____14366
                                                                    =
                                                                    FStar_Syntax_Syntax.as_arg
                                                                    FStar_Syntax_Util.exp_unit
                                                                     in
                                                                    [uu____14366]
                                                                     in
                                                                    FStar_Syntax_Util.mk_app
                                                                    brt
                                                                    uu____14355
                                                                     in
                                                                    let br =
                                                                    FStar_Syntax_Subst.close_branch
                                                                    (pat,
                                                                    FStar_Pervasives_Native.None,
                                                                    brt1)  in
                                                                    let uu____14402
                                                                    =
                                                                    let uu____14413
                                                                    =
                                                                    let uu____14418
                                                                    =
                                                                    FStar_BigInt.of_int_fs
                                                                    (FStar_List.length
                                                                    bs3)  in
                                                                    (fv1,
                                                                    uu____14418)
                                                                     in
                                                                    (g', br,
                                                                    uu____14413)
                                                                     in
                                                                    ret
                                                                    uu____14402)))))))
                                                                    | 
                                                                    uu____14439
                                                                    ->
                                                                    fail
                                                                    "impossible: not a ctor"))
                                                                  c_lids
                                                                 in
                                                              bind
                                                                uu____13273
                                                                (fun goal_brs
                                                                    ->
                                                                   let uu____14489
                                                                    =
                                                                    FStar_List.unzip3
                                                                    goal_brs
                                                                     in
                                                                   match uu____14489
                                                                   with
                                                                   | 
                                                                   (goals,brs,infos)
                                                                    ->
                                                                    let w =
                                                                    FStar_Syntax_Syntax.mk
                                                                    (FStar_Syntax_Syntax.Tm_match
                                                                    (s_tm1,
                                                                    brs))
                                                                    FStar_Pervasives_Native.None
                                                                    s_tm1.FStar_Syntax_Syntax.pos
                                                                     in
                                                                    let uu____14562
                                                                    =
                                                                    solve' g
                                                                    w  in
                                                                    bind
                                                                    uu____14562
                                                                    (fun
                                                                    uu____14573
                                                                     ->
                                                                    let uu____14574
                                                                    =
                                                                    add_goals
                                                                    goals  in
                                                                    bind
                                                                    uu____14574
                                                                    (fun
                                                                    uu____14584
                                                                     ->
                                                                    ret infos)))))
                                            | uu____14591 ->
                                                fail "not an inductive type"))))))
       in
    FStar_All.pipe_left (wrap_err "destruct") uu____12985
  
let rec last : 'a . 'a Prims.list -> 'a =
  fun l  ->
    match l with
    | [] -> failwith "last: empty list"
    | x::[] -> x
    | uu____14640::xs -> last xs
  
let rec init : 'a . 'a Prims.list -> 'a Prims.list =
  fun l  ->
    match l with
    | [] -> failwith "init: empty list"
    | x::[] -> []
    | x::xs -> let uu____14670 = init xs  in x :: uu____14670
  
let rec (inspect :
  FStar_Syntax_Syntax.term -> FStar_Reflection_Data.term_view tac) =
  fun t  ->
    let uu____14683 =
      let t1 = FStar_Syntax_Util.unascribe t  in
      let t2 = FStar_Syntax_Util.un_uinst t1  in
      let t3 = FStar_Syntax_Util.unlazy_emb t2  in
      match t3.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_meta (t4,uu____14692) -> inspect t4
      | FStar_Syntax_Syntax.Tm_name bv ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_Var bv)
      | FStar_Syntax_Syntax.Tm_bvar bv ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_BVar bv)
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_FVar fv)
      | FStar_Syntax_Syntax.Tm_app (hd,[]) ->
          failwith "empty arguments on Tm_app"
      | FStar_Syntax_Syntax.Tm_app (hd,args) ->
          let uu____14758 = last args  in
          (match uu____14758 with
           | (a,q) ->
               let q' = FStar_Reflection_Basic.inspect_aqual q  in
               let uu____14788 =
                 let uu____14789 =
                   let uu____14794 =
                     let uu____14795 =
                       let uu____14800 = init args  in
                       FStar_Syntax_Syntax.mk_Tm_app hd uu____14800  in
                     uu____14795 FStar_Pervasives_Native.None
                       t3.FStar_Syntax_Syntax.pos
                      in
                   (uu____14794, (a, q'))  in
                 FStar_Reflection_Data.Tv_App uu____14789  in
               FStar_All.pipe_left ret uu____14788)
      | FStar_Syntax_Syntax.Tm_abs ([],uu____14811,uu____14812) ->
          failwith "empty arguments on Tm_abs"
      | FStar_Syntax_Syntax.Tm_abs (bs,t4,k) ->
          let uu____14865 = FStar_Syntax_Subst.open_term bs t4  in
          (match uu____14865 with
           | (bs1,t5) ->
               (match bs1 with
                | [] -> failwith "impossible"
                | b::bs2 ->
                    let uu____14907 =
                      let uu____14908 =
                        let uu____14913 = FStar_Syntax_Util.abs bs2 t5 k  in
                        (b, uu____14913)  in
                      FStar_Reflection_Data.Tv_Abs uu____14908  in
                    FStar_All.pipe_left ret uu____14907))
      | FStar_Syntax_Syntax.Tm_type uu____14916 ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_Type ())
      | FStar_Syntax_Syntax.Tm_arrow ([],k) ->
          failwith "empty binders on arrow"
      | FStar_Syntax_Syntax.Tm_arrow uu____14941 ->
          let uu____14956 = FStar_Syntax_Util.arrow_one t3  in
          (match uu____14956 with
           | FStar_Pervasives_Native.Some (b,c) ->
               FStar_All.pipe_left ret
                 (FStar_Reflection_Data.Tv_Arrow (b, c))
           | FStar_Pervasives_Native.None  -> failwith "impossible")
      | FStar_Syntax_Syntax.Tm_refine (bv,t4) ->
          let b = FStar_Syntax_Syntax.mk_binder bv  in
          let uu____14987 = FStar_Syntax_Subst.open_term [b] t4  in
          (match uu____14987 with
           | (b',t5) ->
               let b1 =
                 match b' with
                 | b'1::[] -> b'1
                 | uu____15040 -> failwith "impossible"  in
               FStar_All.pipe_left ret
                 (FStar_Reflection_Data.Tv_Refine
                    ((FStar_Pervasives_Native.fst b1), t5)))
      | FStar_Syntax_Syntax.Tm_constant c ->
          let uu____15053 =
            let uu____15054 = FStar_Reflection_Basic.inspect_const c  in
            FStar_Reflection_Data.Tv_Const uu____15054  in
          FStar_All.pipe_left ret uu____15053
      | FStar_Syntax_Syntax.Tm_uvar (ctx_u,s) ->
          let uu____15075 =
            let uu____15076 =
              let uu____15081 =
                let uu____15082 =
                  FStar_Syntax_Unionfind.uvar_id
                    ctx_u.FStar_Syntax_Syntax.ctx_uvar_head
                   in
                FStar_BigInt.of_int_fs uu____15082  in
              (uu____15081, (ctx_u, s))  in
            FStar_Reflection_Data.Tv_Uvar uu____15076  in
          FStar_All.pipe_left ret uu____15075
      | FStar_Syntax_Syntax.Tm_let ((false ,lb::[]),t21) ->
          if lb.FStar_Syntax_Syntax.lbunivs <> []
          then FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
          else
            (match lb.FStar_Syntax_Syntax.lbname with
             | FStar_Util.Inr uu____15122 ->
                 FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
             | FStar_Util.Inl bv ->
                 let b = FStar_Syntax_Syntax.mk_binder bv  in
                 let uu____15127 = FStar_Syntax_Subst.open_term [b] t21  in
                 (match uu____15127 with
                  | (bs,t22) ->
                      let b1 =
                        match bs with
                        | b1::[] -> b1
                        | uu____15180 ->
                            failwith
                              "impossible: open_term returned different amount of binders"
                         in
                      FStar_All.pipe_left ret
                        (FStar_Reflection_Data.Tv_Let
                           (false, (lb.FStar_Syntax_Syntax.lbattrs),
                             (FStar_Pervasives_Native.fst b1),
                             (lb.FStar_Syntax_Syntax.lbdef), t22))))
      | FStar_Syntax_Syntax.Tm_let ((true ,lb::[]),t21) ->
          if lb.FStar_Syntax_Syntax.lbunivs <> []
          then FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
          else
            (match lb.FStar_Syntax_Syntax.lbname with
             | FStar_Util.Inr uu____15224 ->
                 FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
             | FStar_Util.Inl bv ->
                 let uu____15228 = FStar_Syntax_Subst.open_let_rec [lb] t21
                    in
                 (match uu____15228 with
                  | (lbs,t22) ->
                      (match lbs with
                       | lb1::[] ->
                           (match lb1.FStar_Syntax_Syntax.lbname with
                            | FStar_Util.Inr uu____15248 ->
                                ret FStar_Reflection_Data.Tv_Unknown
                            | FStar_Util.Inl bv1 ->
                                FStar_All.pipe_left ret
                                  (FStar_Reflection_Data.Tv_Let
                                     (true,
                                       (lb1.FStar_Syntax_Syntax.lbattrs),
                                       bv1, (lb1.FStar_Syntax_Syntax.lbdef),
                                       t22)))
                       | uu____15256 ->
                           failwith
                             "impossible: open_term returned different amount of binders")))
      | FStar_Syntax_Syntax.Tm_match (t4,brs) ->
          let rec inspect_pat p =
            match p.FStar_Syntax_Syntax.v with
            | FStar_Syntax_Syntax.Pat_constant c ->
                let uu____15311 = FStar_Reflection_Basic.inspect_const c  in
                FStar_Reflection_Data.Pat_Constant uu____15311
            | FStar_Syntax_Syntax.Pat_cons (fv,ps) ->
                let uu____15332 =
                  let uu____15344 =
                    FStar_List.map
                      (fun uu____15368  ->
                         match uu____15368 with
                         | (p1,b) ->
                             let uu____15389 = inspect_pat p1  in
                             (uu____15389, b)) ps
                     in
                  (fv, uu____15344)  in
                FStar_Reflection_Data.Pat_Cons uu____15332
            | FStar_Syntax_Syntax.Pat_var bv ->
                FStar_Reflection_Data.Pat_Var bv
            | FStar_Syntax_Syntax.Pat_wild bv ->
                FStar_Reflection_Data.Pat_Wild bv
            | FStar_Syntax_Syntax.Pat_dot_term (bv,t5) ->
                FStar_Reflection_Data.Pat_Dot_Term (bv, t5)
             in
          let brs1 = FStar_List.map FStar_Syntax_Subst.open_branch brs  in
          let brs2 =
            FStar_List.map
              (fun uu___8_15485  ->
                 match uu___8_15485 with
                 | (pat,uu____15507,t5) ->
                     let uu____15525 = inspect_pat pat  in (uu____15525, t5))
              brs1
             in
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_Match (t4, brs2))
      | FStar_Syntax_Syntax.Tm_unknown  ->
          FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
      | uu____15534 ->
          ((let uu____15536 =
              let uu____15542 =
                let uu____15544 = FStar_Syntax_Print.tag_of_term t3  in
                let uu____15546 = FStar_Syntax_Print.term_to_string t3  in
                FStar_Util.format2
                  "inspect: outside of expected syntax (%s, %s)\n"
                  uu____15544 uu____15546
                 in
              (FStar_Errors.Warning_CantInspect, uu____15542)  in
            FStar_Errors.log_issue t3.FStar_Syntax_Syntax.pos uu____15536);
           FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown)
       in
    wrap_err "inspect" uu____14683
  
let (pack : FStar_Reflection_Data.term_view -> FStar_Syntax_Syntax.term tac)
  =
  fun tv  ->
    match tv with
    | FStar_Reflection_Data.Tv_Var bv ->
        let uu____15564 = FStar_Syntax_Syntax.bv_to_name bv  in
        FStar_All.pipe_left ret uu____15564
    | FStar_Reflection_Data.Tv_BVar bv ->
        let uu____15568 = FStar_Syntax_Syntax.bv_to_tm bv  in
        FStar_All.pipe_left ret uu____15568
    | FStar_Reflection_Data.Tv_FVar fv ->
        let uu____15572 = FStar_Syntax_Syntax.fv_to_tm fv  in
        FStar_All.pipe_left ret uu____15572
    | FStar_Reflection_Data.Tv_App (l,(r,q)) ->
        let q' = FStar_Reflection_Basic.pack_aqual q  in
        let uu____15579 = FStar_Syntax_Util.mk_app l [(r, q')]  in
        FStar_All.pipe_left ret uu____15579
    | FStar_Reflection_Data.Tv_Abs (b,t) ->
        let uu____15604 =
          FStar_Syntax_Util.abs [b] t FStar_Pervasives_Native.None  in
        FStar_All.pipe_left ret uu____15604
    | FStar_Reflection_Data.Tv_Arrow (b,c) ->
        let uu____15621 = FStar_Syntax_Util.arrow [b] c  in
        FStar_All.pipe_left ret uu____15621
    | FStar_Reflection_Data.Tv_Type () ->
        FStar_All.pipe_left ret FStar_Syntax_Util.ktype
    | FStar_Reflection_Data.Tv_Refine (bv,t) ->
        let uu____15640 = FStar_Syntax_Util.refine bv t  in
        FStar_All.pipe_left ret uu____15640
    | FStar_Reflection_Data.Tv_Const c ->
        let uu____15644 =
          let uu____15645 =
            let uu____15652 =
              let uu____15653 = FStar_Reflection_Basic.pack_const c  in
              FStar_Syntax_Syntax.Tm_constant uu____15653  in
            FStar_Syntax_Syntax.mk uu____15652  in
          uu____15645 FStar_Pervasives_Native.None FStar_Range.dummyRange  in
        FStar_All.pipe_left ret uu____15644
    | FStar_Reflection_Data.Tv_Uvar (_u,ctx_u_s) ->
        let uu____15658 =
          FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_uvar ctx_u_s)
            FStar_Pervasives_Native.None FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____15658
    | FStar_Reflection_Data.Tv_Let (false ,attrs,bv,t1,t2) ->
        let lb =
          FStar_Syntax_Util.mk_letbinding (FStar_Util.Inl bv) []
            bv.FStar_Syntax_Syntax.sort FStar_Parser_Const.effect_Tot_lid t1
            attrs FStar_Range.dummyRange
           in
        let uu____15672 =
          let uu____15673 =
            let uu____15680 =
              let uu____15681 =
                let uu____15695 =
                  let uu____15698 =
                    let uu____15699 = FStar_Syntax_Syntax.mk_binder bv  in
                    [uu____15699]  in
                  FStar_Syntax_Subst.close uu____15698 t2  in
                ((false, [lb]), uu____15695)  in
              FStar_Syntax_Syntax.Tm_let uu____15681  in
            FStar_Syntax_Syntax.mk uu____15680  in
          uu____15673 FStar_Pervasives_Native.None FStar_Range.dummyRange  in
        FStar_All.pipe_left ret uu____15672
    | FStar_Reflection_Data.Tv_Let (true ,attrs,bv,t1,t2) ->
        let lb =
          FStar_Syntax_Util.mk_letbinding (FStar_Util.Inl bv) []
            bv.FStar_Syntax_Syntax.sort FStar_Parser_Const.effect_Tot_lid t1
            attrs FStar_Range.dummyRange
           in
        let uu____15744 = FStar_Syntax_Subst.close_let_rec [lb] t2  in
        (match uu____15744 with
         | (lbs,body) ->
             let uu____15759 =
               FStar_Syntax_Syntax.mk
                 (FStar_Syntax_Syntax.Tm_let ((true, lbs), body))
                 FStar_Pervasives_Native.None FStar_Range.dummyRange
                in
             FStar_All.pipe_left ret uu____15759)
    | FStar_Reflection_Data.Tv_Match (t,brs) ->
        let wrap v =
          {
            FStar_Syntax_Syntax.v = v;
            FStar_Syntax_Syntax.p = FStar_Range.dummyRange
          }  in
        let rec pack_pat p =
          match p with
          | FStar_Reflection_Data.Pat_Constant c ->
              let uu____15796 =
                let uu____15797 = FStar_Reflection_Basic.pack_const c  in
                FStar_Syntax_Syntax.Pat_constant uu____15797  in
              FStar_All.pipe_left wrap uu____15796
          | FStar_Reflection_Data.Pat_Cons (fv,ps) ->
              let uu____15814 =
                let uu____15815 =
                  let uu____15829 =
                    FStar_List.map
                      (fun uu____15853  ->
                         match uu____15853 with
                         | (p1,b) ->
                             let uu____15868 = pack_pat p1  in
                             (uu____15868, b)) ps
                     in
                  (fv, uu____15829)  in
                FStar_Syntax_Syntax.Pat_cons uu____15815  in
              FStar_All.pipe_left wrap uu____15814
          | FStar_Reflection_Data.Pat_Var bv ->
              FStar_All.pipe_left wrap (FStar_Syntax_Syntax.Pat_var bv)
          | FStar_Reflection_Data.Pat_Wild bv ->
              FStar_All.pipe_left wrap (FStar_Syntax_Syntax.Pat_wild bv)
          | FStar_Reflection_Data.Pat_Dot_Term (bv,t1) ->
              FStar_All.pipe_left wrap
                (FStar_Syntax_Syntax.Pat_dot_term (bv, t1))
           in
        let brs1 =
          FStar_List.map
            (fun uu___9_15916  ->
               match uu___9_15916 with
               | (pat,t1) ->
                   let uu____15933 = pack_pat pat  in
                   (uu____15933, FStar_Pervasives_Native.None, t1)) brs
           in
        let brs2 = FStar_List.map FStar_Syntax_Subst.close_branch brs1  in
        let uu____15981 =
          FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match (t, brs2))
            FStar_Pervasives_Native.None FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____15981
    | FStar_Reflection_Data.Tv_AscribedT (e,t,tacopt) ->
        let uu____16009 =
          FStar_Syntax_Syntax.mk
            (FStar_Syntax_Syntax.Tm_ascribed
               (e, ((FStar_Util.Inl t), tacopt),
                 FStar_Pervasives_Native.None)) FStar_Pervasives_Native.None
            FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____16009
    | FStar_Reflection_Data.Tv_AscribedC (e,c,tacopt) ->
        let uu____16055 =
          FStar_Syntax_Syntax.mk
            (FStar_Syntax_Syntax.Tm_ascribed
               (e, ((FStar_Util.Inr c), tacopt),
                 FStar_Pervasives_Native.None)) FStar_Pervasives_Native.None
            FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____16055
    | FStar_Reflection_Data.Tv_Unknown  ->
        let uu____16094 =
          FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown
            FStar_Pervasives_Native.None FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____16094
  
let (lget :
  FStar_Reflection_Data.typ -> Prims.string -> FStar_Syntax_Syntax.term tac)
  =
  fun ty  ->
    fun k  ->
      let uu____16114 =
        bind get
          (fun ps  ->
             let uu____16120 =
               FStar_Util.psmap_try_find ps.FStar_Tactics_Types.local_state k
                in
             match uu____16120 with
             | FStar_Pervasives_Native.None  -> fail "not found"
             | FStar_Pervasives_Native.Some t -> unquote ty t)
         in
      FStar_All.pipe_left (wrap_err "lget") uu____16114
  
let (lset :
  FStar_Reflection_Data.typ ->
    Prims.string -> FStar_Syntax_Syntax.term -> unit tac)
  =
  fun _ty  ->
    fun k  ->
      fun t  ->
        let uu____16154 =
          bind get
            (fun ps  ->
               let ps1 =
                 let uu___2238_16161 = ps  in
                 let uu____16162 =
                   FStar_Util.psmap_add ps.FStar_Tactics_Types.local_state k
                     t
                    in
                 {
                   FStar_Tactics_Types.main_context =
                     (uu___2238_16161.FStar_Tactics_Types.main_context);
                   FStar_Tactics_Types.all_implicits =
                     (uu___2238_16161.FStar_Tactics_Types.all_implicits);
                   FStar_Tactics_Types.goals =
                     (uu___2238_16161.FStar_Tactics_Types.goals);
                   FStar_Tactics_Types.smt_goals =
                     (uu___2238_16161.FStar_Tactics_Types.smt_goals);
                   FStar_Tactics_Types.depth =
                     (uu___2238_16161.FStar_Tactics_Types.depth);
                   FStar_Tactics_Types.__dump =
                     (uu___2238_16161.FStar_Tactics_Types.__dump);
                   FStar_Tactics_Types.psc =
                     (uu___2238_16161.FStar_Tactics_Types.psc);
                   FStar_Tactics_Types.entry_range =
                     (uu___2238_16161.FStar_Tactics_Types.entry_range);
                   FStar_Tactics_Types.guard_policy =
                     (uu___2238_16161.FStar_Tactics_Types.guard_policy);
                   FStar_Tactics_Types.freshness =
                     (uu___2238_16161.FStar_Tactics_Types.freshness);
                   FStar_Tactics_Types.tac_verb_dbg =
                     (uu___2238_16161.FStar_Tactics_Types.tac_verb_dbg);
                   FStar_Tactics_Types.local_state = uu____16162
                 }  in
               set ps1)
           in
        FStar_All.pipe_left (wrap_err "lset") uu____16154
  
let (goal_of_goal_ty :
  env ->
    FStar_Reflection_Data.typ ->
      (FStar_Tactics_Types.goal * FStar_TypeChecker_Common.guard_t))
  =
  fun env1  ->
    fun typ  ->
      let uu____16189 =
        FStar_TypeChecker_Util.new_implicit_var "proofstate_of_goal_ty"
          typ.FStar_Syntax_Syntax.pos env1 typ
         in
      match uu____16189 with
      | (u,ctx_uvars,g_u) ->
          let uu____16222 = FStar_List.hd ctx_uvars  in
          (match uu____16222 with
           | (ctx_uvar,uu____16236) ->
               let g =
                 let uu____16238 = FStar_Options.peek ()  in
                 FStar_Tactics_Types.mk_goal env1 ctx_uvar uu____16238 false
                   ""
                  in
               (g, g_u))
  
let (tac_env : FStar_TypeChecker_Env.env -> FStar_TypeChecker_Env.env) =
  fun env1  ->
    let uu____16247 = FStar_TypeChecker_Env.clear_expected_typ env1  in
    match uu____16247 with
    | (env2,uu____16255) ->
        let env3 =
          let uu___2255_16261 = env2  in
          {
            FStar_TypeChecker_Env.solver =
              (uu___2255_16261.FStar_TypeChecker_Env.solver);
            FStar_TypeChecker_Env.range =
              (uu___2255_16261.FStar_TypeChecker_Env.range);
            FStar_TypeChecker_Env.curmodule =
              (uu___2255_16261.FStar_TypeChecker_Env.curmodule);
            FStar_TypeChecker_Env.gamma =
              (uu___2255_16261.FStar_TypeChecker_Env.gamma);
            FStar_TypeChecker_Env.gamma_sig =
              (uu___2255_16261.FStar_TypeChecker_Env.gamma_sig);
            FStar_TypeChecker_Env.gamma_cache =
              (uu___2255_16261.FStar_TypeChecker_Env.gamma_cache);
            FStar_TypeChecker_Env.modules =
              (uu___2255_16261.FStar_TypeChecker_Env.modules);
            FStar_TypeChecker_Env.expected_typ =
              (uu___2255_16261.FStar_TypeChecker_Env.expected_typ);
            FStar_TypeChecker_Env.sigtab =
              (uu___2255_16261.FStar_TypeChecker_Env.sigtab);
            FStar_TypeChecker_Env.attrtab =
              (uu___2255_16261.FStar_TypeChecker_Env.attrtab);
            FStar_TypeChecker_Env.instantiate_imp = false;
            FStar_TypeChecker_Env.effects =
              (uu___2255_16261.FStar_TypeChecker_Env.effects);
            FStar_TypeChecker_Env.generalize =
              (uu___2255_16261.FStar_TypeChecker_Env.generalize);
            FStar_TypeChecker_Env.letrecs =
              (uu___2255_16261.FStar_TypeChecker_Env.letrecs);
            FStar_TypeChecker_Env.top_level =
              (uu___2255_16261.FStar_TypeChecker_Env.top_level);
            FStar_TypeChecker_Env.check_uvars =
              (uu___2255_16261.FStar_TypeChecker_Env.check_uvars);
            FStar_TypeChecker_Env.use_eq =
              (uu___2255_16261.FStar_TypeChecker_Env.use_eq);
            FStar_TypeChecker_Env.use_eq_strict =
              (uu___2255_16261.FStar_TypeChecker_Env.use_eq_strict);
            FStar_TypeChecker_Env.is_iface =
              (uu___2255_16261.FStar_TypeChecker_Env.is_iface);
            FStar_TypeChecker_Env.admit =
              (uu___2255_16261.FStar_TypeChecker_Env.admit);
            FStar_TypeChecker_Env.lax =
              (uu___2255_16261.FStar_TypeChecker_Env.lax);
            FStar_TypeChecker_Env.lax_universes =
              (uu___2255_16261.FStar_TypeChecker_Env.lax_universes);
            FStar_TypeChecker_Env.phase1 =
              (uu___2255_16261.FStar_TypeChecker_Env.phase1);
            FStar_TypeChecker_Env.failhard =
              (uu___2255_16261.FStar_TypeChecker_Env.failhard);
            FStar_TypeChecker_Env.nosynth =
              (uu___2255_16261.FStar_TypeChecker_Env.nosynth);
            FStar_TypeChecker_Env.uvar_subtyping =
              (uu___2255_16261.FStar_TypeChecker_Env.uvar_subtyping);
            FStar_TypeChecker_Env.tc_term =
              (uu___2255_16261.FStar_TypeChecker_Env.tc_term);
            FStar_TypeChecker_Env.type_of =
              (uu___2255_16261.FStar_TypeChecker_Env.type_of);
            FStar_TypeChecker_Env.universe_of =
              (uu___2255_16261.FStar_TypeChecker_Env.universe_of);
            FStar_TypeChecker_Env.check_type_of =
              (uu___2255_16261.FStar_TypeChecker_Env.check_type_of);
            FStar_TypeChecker_Env.use_bv_sorts =
              (uu___2255_16261.FStar_TypeChecker_Env.use_bv_sorts);
            FStar_TypeChecker_Env.qtbl_name_and_index =
              (uu___2255_16261.FStar_TypeChecker_Env.qtbl_name_and_index);
            FStar_TypeChecker_Env.normalized_eff_names =
              (uu___2255_16261.FStar_TypeChecker_Env.normalized_eff_names);
            FStar_TypeChecker_Env.fv_delta_depths =
              (uu___2255_16261.FStar_TypeChecker_Env.fv_delta_depths);
            FStar_TypeChecker_Env.proof_ns =
              (uu___2255_16261.FStar_TypeChecker_Env.proof_ns);
            FStar_TypeChecker_Env.synth_hook =
              (uu___2255_16261.FStar_TypeChecker_Env.synth_hook);
            FStar_TypeChecker_Env.try_solve_implicits_hook =
              (uu___2255_16261.FStar_TypeChecker_Env.try_solve_implicits_hook);
            FStar_TypeChecker_Env.splice =
              (uu___2255_16261.FStar_TypeChecker_Env.splice);
            FStar_TypeChecker_Env.mpreprocess =
              (uu___2255_16261.FStar_TypeChecker_Env.mpreprocess);
            FStar_TypeChecker_Env.postprocess =
              (uu___2255_16261.FStar_TypeChecker_Env.postprocess);
            FStar_TypeChecker_Env.is_native_tactic =
              (uu___2255_16261.FStar_TypeChecker_Env.is_native_tactic);
            FStar_TypeChecker_Env.identifier_info =
              (uu___2255_16261.FStar_TypeChecker_Env.identifier_info);
            FStar_TypeChecker_Env.tc_hooks =
              (uu___2255_16261.FStar_TypeChecker_Env.tc_hooks);
            FStar_TypeChecker_Env.dsenv =
              (uu___2255_16261.FStar_TypeChecker_Env.dsenv);
            FStar_TypeChecker_Env.nbe =
              (uu___2255_16261.FStar_TypeChecker_Env.nbe);
            FStar_TypeChecker_Env.strict_args_tab =
              (uu___2255_16261.FStar_TypeChecker_Env.strict_args_tab);
            FStar_TypeChecker_Env.erasable_types_tab =
              (uu___2255_16261.FStar_TypeChecker_Env.erasable_types_tab)
          }  in
        let env4 =
          let uu___2258_16264 = env3  in
          {
            FStar_TypeChecker_Env.solver =
              (uu___2258_16264.FStar_TypeChecker_Env.solver);
            FStar_TypeChecker_Env.range =
              (uu___2258_16264.FStar_TypeChecker_Env.range);
            FStar_TypeChecker_Env.curmodule =
              (uu___2258_16264.FStar_TypeChecker_Env.curmodule);
            FStar_TypeChecker_Env.gamma =
              (uu___2258_16264.FStar_TypeChecker_Env.gamma);
            FStar_TypeChecker_Env.gamma_sig =
              (uu___2258_16264.FStar_TypeChecker_Env.gamma_sig);
            FStar_TypeChecker_Env.gamma_cache =
              (uu___2258_16264.FStar_TypeChecker_Env.gamma_cache);
            FStar_TypeChecker_Env.modules =
              (uu___2258_16264.FStar_TypeChecker_Env.modules);
            FStar_TypeChecker_Env.expected_typ =
              (uu___2258_16264.FStar_TypeChecker_Env.expected_typ);
            FStar_TypeChecker_Env.sigtab =
              (uu___2258_16264.FStar_TypeChecker_Env.sigtab);
            FStar_TypeChecker_Env.attrtab =
              (uu___2258_16264.FStar_TypeChecker_Env.attrtab);
            FStar_TypeChecker_Env.instantiate_imp =
              (uu___2258_16264.FStar_TypeChecker_Env.instantiate_imp);
            FStar_TypeChecker_Env.effects =
              (uu___2258_16264.FStar_TypeChecker_Env.effects);
            FStar_TypeChecker_Env.generalize =
              (uu___2258_16264.FStar_TypeChecker_Env.generalize);
            FStar_TypeChecker_Env.letrecs =
              (uu___2258_16264.FStar_TypeChecker_Env.letrecs);
            FStar_TypeChecker_Env.top_level =
              (uu___2258_16264.FStar_TypeChecker_Env.top_level);
            FStar_TypeChecker_Env.check_uvars =
              (uu___2258_16264.FStar_TypeChecker_Env.check_uvars);
            FStar_TypeChecker_Env.use_eq =
              (uu___2258_16264.FStar_TypeChecker_Env.use_eq);
            FStar_TypeChecker_Env.use_eq_strict =
              (uu___2258_16264.FStar_TypeChecker_Env.use_eq_strict);
            FStar_TypeChecker_Env.is_iface =
              (uu___2258_16264.FStar_TypeChecker_Env.is_iface);
            FStar_TypeChecker_Env.admit =
              (uu___2258_16264.FStar_TypeChecker_Env.admit);
            FStar_TypeChecker_Env.lax =
              (uu___2258_16264.FStar_TypeChecker_Env.lax);
            FStar_TypeChecker_Env.lax_universes =
              (uu___2258_16264.FStar_TypeChecker_Env.lax_universes);
            FStar_TypeChecker_Env.phase1 =
              (uu___2258_16264.FStar_TypeChecker_Env.phase1);
            FStar_TypeChecker_Env.failhard = true;
            FStar_TypeChecker_Env.nosynth =
              (uu___2258_16264.FStar_TypeChecker_Env.nosynth);
            FStar_TypeChecker_Env.uvar_subtyping =
              (uu___2258_16264.FStar_TypeChecker_Env.uvar_subtyping);
            FStar_TypeChecker_Env.tc_term =
              (uu___2258_16264.FStar_TypeChecker_Env.tc_term);
            FStar_TypeChecker_Env.type_of =
              (uu___2258_16264.FStar_TypeChecker_Env.type_of);
            FStar_TypeChecker_Env.universe_of =
              (uu___2258_16264.FStar_TypeChecker_Env.universe_of);
            FStar_TypeChecker_Env.check_type_of =
              (uu___2258_16264.FStar_TypeChecker_Env.check_type_of);
            FStar_TypeChecker_Env.use_bv_sorts =
              (uu___2258_16264.FStar_TypeChecker_Env.use_bv_sorts);
            FStar_TypeChecker_Env.qtbl_name_and_index =
              (uu___2258_16264.FStar_TypeChecker_Env.qtbl_name_and_index);
            FStar_TypeChecker_Env.normalized_eff_names =
              (uu___2258_16264.FStar_TypeChecker_Env.normalized_eff_names);
            FStar_TypeChecker_Env.fv_delta_depths =
              (uu___2258_16264.FStar_TypeChecker_Env.fv_delta_depths);
            FStar_TypeChecker_Env.proof_ns =
              (uu___2258_16264.FStar_TypeChecker_Env.proof_ns);
            FStar_TypeChecker_Env.synth_hook =
              (uu___2258_16264.FStar_TypeChecker_Env.synth_hook);
            FStar_TypeChecker_Env.try_solve_implicits_hook =
              (uu___2258_16264.FStar_TypeChecker_Env.try_solve_implicits_hook);
            FStar_TypeChecker_Env.splice =
              (uu___2258_16264.FStar_TypeChecker_Env.splice);
            FStar_TypeChecker_Env.mpreprocess =
              (uu___2258_16264.FStar_TypeChecker_Env.mpreprocess);
            FStar_TypeChecker_Env.postprocess =
              (uu___2258_16264.FStar_TypeChecker_Env.postprocess);
            FStar_TypeChecker_Env.is_native_tactic =
              (uu___2258_16264.FStar_TypeChecker_Env.is_native_tactic);
            FStar_TypeChecker_Env.identifier_info =
              (uu___2258_16264.FStar_TypeChecker_Env.identifier_info);
            FStar_TypeChecker_Env.tc_hooks =
              (uu___2258_16264.FStar_TypeChecker_Env.tc_hooks);
            FStar_TypeChecker_Env.dsenv =
              (uu___2258_16264.FStar_TypeChecker_Env.dsenv);
            FStar_TypeChecker_Env.nbe =
              (uu___2258_16264.FStar_TypeChecker_Env.nbe);
            FStar_TypeChecker_Env.strict_args_tab =
              (uu___2258_16264.FStar_TypeChecker_Env.strict_args_tab);
            FStar_TypeChecker_Env.erasable_types_tab =
              (uu___2258_16264.FStar_TypeChecker_Env.erasable_types_tab)
          }  in
        env4
  
let (proofstate_of_goals :
  FStar_Range.range ->
    env ->
      FStar_Tactics_Types.goal Prims.list ->
        FStar_TypeChecker_Common.implicit Prims.list ->
          FStar_Tactics_Types.proofstate)
  =
  fun rng  ->
    fun env1  ->
      fun goals  ->
        fun imps  ->
          let env2 = tac_env env1  in
          let ps =
            let uu____16297 =
              FStar_TypeChecker_Env.debug env2
                (FStar_Options.Other "TacVerbose")
               in
            let uu____16300 = FStar_Util.psmap_empty ()  in
            {
              FStar_Tactics_Types.main_context = env2;
              FStar_Tactics_Types.all_implicits = imps;
              FStar_Tactics_Types.goals = goals;
              FStar_Tactics_Types.smt_goals = [];
              FStar_Tactics_Types.depth = Prims.int_zero;
              FStar_Tactics_Types.__dump = do_dump_proofstate;
              FStar_Tactics_Types.psc = FStar_TypeChecker_Cfg.null_psc;
              FStar_Tactics_Types.entry_range = rng;
              FStar_Tactics_Types.guard_policy = FStar_Tactics_Types.SMT;
              FStar_Tactics_Types.freshness = Prims.int_zero;
              FStar_Tactics_Types.tac_verb_dbg = uu____16297;
              FStar_Tactics_Types.local_state = uu____16300
            }  in
          ps
  
let (proofstate_of_goal_ty :
  FStar_Range.range ->
    env ->
      FStar_Reflection_Data.typ ->
        (FStar_Tactics_Types.proofstate * FStar_Syntax_Syntax.term))
  =
  fun rng  ->
    fun env1  ->
      fun typ  ->
        let env2 = tac_env env1  in
        let uu____16326 = goal_of_goal_ty env2 typ  in
        match uu____16326 with
        | (g,g_u) ->
            let ps =
              proofstate_of_goals rng env2 [g]
                g_u.FStar_TypeChecker_Common.implicits
               in
            let uu____16338 = FStar_Tactics_Types.goal_witness g  in
            (ps, uu____16338)
  
let (goal_of_implicit :
  FStar_TypeChecker_Env.env ->
    FStar_TypeChecker_Env.implicit -> FStar_Tactics_Types.goal)
  =
  fun env1  ->
    fun i  ->
      let uu____16350 = FStar_Options.peek ()  in
      FStar_Tactics_Types.mk_goal env1 i.FStar_TypeChecker_Common.imp_uvar
        uu____16350 false ""
  
let (proofstate_of_all_implicits :
  FStar_Range.range ->
    env ->
      implicits ->
        (FStar_Tactics_Types.proofstate * FStar_Syntax_Syntax.term))
  =
  fun rng  ->
    fun env1  ->
      fun imps  ->
        let goals = FStar_List.map (goal_of_implicit env1) imps  in
        let w =
          let uu____16377 = FStar_List.hd goals  in
          FStar_Tactics_Types.goal_witness uu____16377  in
        let ps =
          let uu____16379 =
            FStar_TypeChecker_Env.debug env1
              (FStar_Options.Other "TacVerbose")
             in
          let uu____16382 = FStar_Util.psmap_empty ()  in
          {
            FStar_Tactics_Types.main_context = env1;
            FStar_Tactics_Types.all_implicits = imps;
            FStar_Tactics_Types.goals = goals;
            FStar_Tactics_Types.smt_goals = [];
            FStar_Tactics_Types.depth = Prims.int_zero;
            FStar_Tactics_Types.__dump =
              (fun ps  -> fun msg  -> do_dump_proofstate ps msg);
            FStar_Tactics_Types.psc = FStar_TypeChecker_Cfg.null_psc;
            FStar_Tactics_Types.entry_range = rng;
            FStar_Tactics_Types.guard_policy = FStar_Tactics_Types.SMT;
            FStar_Tactics_Types.freshness = Prims.int_zero;
            FStar_Tactics_Types.tac_verb_dbg = uu____16379;
            FStar_Tactics_Types.local_state = uu____16382
          }  in
        (ps, w)
  