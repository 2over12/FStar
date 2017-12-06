open Prims
type local_binding =
  (FStar_Ident.ident,FStar_Syntax_Syntax.bv,Prims.bool)
    FStar_Pervasives_Native.tuple3[@@deriving show]
type rec_binding =
  (FStar_Ident.ident,FStar_Ident.lid,FStar_Syntax_Syntax.delta_depth)
    FStar_Pervasives_Native.tuple3[@@deriving show]
type module_abbrev =
  (FStar_Ident.ident,FStar_Ident.lident) FStar_Pervasives_Native.tuple2
[@@deriving show]
type open_kind =
  | Open_module
  | Open_namespace[@@deriving show]
let uu___is_Open_module: open_kind -> Prims.bool =
  fun projectee  ->
    match projectee with | Open_module  -> true | uu____20 -> false
let uu___is_Open_namespace: open_kind -> Prims.bool =
  fun projectee  ->
    match projectee with | Open_namespace  -> true | uu____24 -> false
type open_module_or_namespace =
  (FStar_Ident.lident,open_kind) FStar_Pervasives_Native.tuple2[@@deriving
                                                                 show]
type record_or_dc =
  {
  typename: FStar_Ident.lident;
  constrname: FStar_Ident.ident;
  parms: FStar_Syntax_Syntax.binders;
  fields:
    (FStar_Ident.ident,FStar_Syntax_Syntax.typ)
      FStar_Pervasives_Native.tuple2 Prims.list;
  is_private_or_abstract: Prims.bool;
  is_record: Prims.bool;}[@@deriving show]
let __proj__Mkrecord_or_dc__item__typename:
  record_or_dc -> FStar_Ident.lident =
  fun projectee  ->
    match projectee with
    | { typename = __fname__typename; constrname = __fname__constrname;
        parms = __fname__parms; fields = __fname__fields;
        is_private_or_abstract = __fname__is_private_or_abstract;
        is_record = __fname__is_record;_} -> __fname__typename
let __proj__Mkrecord_or_dc__item__constrname:
  record_or_dc -> FStar_Ident.ident =
  fun projectee  ->
    match projectee with
    | { typename = __fname__typename; constrname = __fname__constrname;
        parms = __fname__parms; fields = __fname__fields;
        is_private_or_abstract = __fname__is_private_or_abstract;
        is_record = __fname__is_record;_} -> __fname__constrname
let __proj__Mkrecord_or_dc__item__parms:
  record_or_dc -> FStar_Syntax_Syntax.binders =
  fun projectee  ->
    match projectee with
    | { typename = __fname__typename; constrname = __fname__constrname;
        parms = __fname__parms; fields = __fname__fields;
        is_private_or_abstract = __fname__is_private_or_abstract;
        is_record = __fname__is_record;_} -> __fname__parms
let __proj__Mkrecord_or_dc__item__fields:
  record_or_dc ->
    (FStar_Ident.ident,FStar_Syntax_Syntax.typ)
      FStar_Pervasives_Native.tuple2 Prims.list
  =
  fun projectee  ->
    match projectee with
    | { typename = __fname__typename; constrname = __fname__constrname;
        parms = __fname__parms; fields = __fname__fields;
        is_private_or_abstract = __fname__is_private_or_abstract;
        is_record = __fname__is_record;_} -> __fname__fields
let __proj__Mkrecord_or_dc__item__is_private_or_abstract:
  record_or_dc -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { typename = __fname__typename; constrname = __fname__constrname;
        parms = __fname__parms; fields = __fname__fields;
        is_private_or_abstract = __fname__is_private_or_abstract;
        is_record = __fname__is_record;_} -> __fname__is_private_or_abstract
let __proj__Mkrecord_or_dc__item__is_record: record_or_dc -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { typename = __fname__typename; constrname = __fname__constrname;
        parms = __fname__parms; fields = __fname__fields;
        is_private_or_abstract = __fname__is_private_or_abstract;
        is_record = __fname__is_record;_} -> __fname__is_record
type scope_mod =
  | Local_binding of local_binding
  | Rec_binding of rec_binding
  | Module_abbrev of module_abbrev
  | Open_module_or_namespace of open_module_or_namespace
  | Top_level_def of FStar_Ident.ident
  | Record_or_dc of record_or_dc[@@deriving show]
let uu___is_Local_binding: scope_mod -> Prims.bool =
  fun projectee  ->
    match projectee with | Local_binding _0 -> true | uu____189 -> false
let __proj__Local_binding__item___0: scope_mod -> local_binding =
  fun projectee  -> match projectee with | Local_binding _0 -> _0
let uu___is_Rec_binding: scope_mod -> Prims.bool =
  fun projectee  ->
    match projectee with | Rec_binding _0 -> true | uu____201 -> false
let __proj__Rec_binding__item___0: scope_mod -> rec_binding =
  fun projectee  -> match projectee with | Rec_binding _0 -> _0
let uu___is_Module_abbrev: scope_mod -> Prims.bool =
  fun projectee  ->
    match projectee with | Module_abbrev _0 -> true | uu____213 -> false
let __proj__Module_abbrev__item___0: scope_mod -> module_abbrev =
  fun projectee  -> match projectee with | Module_abbrev _0 -> _0
let uu___is_Open_module_or_namespace: scope_mod -> Prims.bool =
  fun projectee  ->
    match projectee with
    | Open_module_or_namespace _0 -> true
    | uu____225 -> false
let __proj__Open_module_or_namespace__item___0:
  scope_mod -> open_module_or_namespace =
  fun projectee  -> match projectee with | Open_module_or_namespace _0 -> _0
let uu___is_Top_level_def: scope_mod -> Prims.bool =
  fun projectee  ->
    match projectee with | Top_level_def _0 -> true | uu____237 -> false
let __proj__Top_level_def__item___0: scope_mod -> FStar_Ident.ident =
  fun projectee  -> match projectee with | Top_level_def _0 -> _0
let uu___is_Record_or_dc: scope_mod -> Prims.bool =
  fun projectee  ->
    match projectee with | Record_or_dc _0 -> true | uu____249 -> false
let __proj__Record_or_dc__item___0: scope_mod -> record_or_dc =
  fun projectee  -> match projectee with | Record_or_dc _0 -> _0
type string_set = Prims.string FStar_Util.set[@@deriving show]
type exported_id_kind =
  | Exported_id_term_type
  | Exported_id_field[@@deriving show]
let uu___is_Exported_id_term_type: exported_id_kind -> Prims.bool =
  fun projectee  ->
    match projectee with
    | Exported_id_term_type  -> true
    | uu____262 -> false
let uu___is_Exported_id_field: exported_id_kind -> Prims.bool =
  fun projectee  ->
    match projectee with | Exported_id_field  -> true | uu____266 -> false
type exported_id_set = exported_id_kind -> string_set FStar_ST.ref[@@deriving
                                                                    show]
type env =
  {
  curmodule: FStar_Ident.lident FStar_Pervasives_Native.option;
  curmonad: FStar_Ident.ident FStar_Pervasives_Native.option;
  modules:
    (FStar_Ident.lident,FStar_Syntax_Syntax.modul)
      FStar_Pervasives_Native.tuple2 Prims.list;
  scope_mods: scope_mod Prims.list;
  exported_ids: exported_id_set FStar_Util.smap;
  trans_exported_ids: exported_id_set FStar_Util.smap;
  includes: FStar_Ident.lident Prims.list FStar_ST.ref FStar_Util.smap;
  sigaccum: FStar_Syntax_Syntax.sigelts;
  sigmap:
    (FStar_Syntax_Syntax.sigelt,Prims.bool) FStar_Pervasives_Native.tuple2
      FStar_Util.smap;
  iface: Prims.bool;
  admitted_iface: Prims.bool;
  expect_typ: Prims.bool;
  docs: FStar_Parser_AST.fsdoc FStar_Util.smap;
  remaining_iface_decls:
    (FStar_Ident.lident,FStar_Parser_AST.decl Prims.list)
      FStar_Pervasives_Native.tuple2 Prims.list;
  syntax_only: Prims.bool;
  ds_hooks: dsenv_hooks;}[@@deriving show]
and dsenv_hooks =
  {
  ds_push_open_hook: env -> open_module_or_namespace -> Prims.unit;
  ds_push_include_hook: env -> FStar_Ident.lident -> Prims.unit;
  ds_push_module_abbrev_hook:
    env -> FStar_Ident.ident -> FStar_Ident.lident -> Prims.unit;}[@@deriving
                                                                    show]
let __proj__Mkenv__item__curmodule:
  env -> FStar_Ident.lident FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__curmodule
let __proj__Mkenv__item__curmonad:
  env -> FStar_Ident.ident FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__curmonad
let __proj__Mkenv__item__modules:
  env ->
    (FStar_Ident.lident,FStar_Syntax_Syntax.modul)
      FStar_Pervasives_Native.tuple2 Prims.list
  =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__modules
let __proj__Mkenv__item__scope_mods: env -> scope_mod Prims.list =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__scope_mods
let __proj__Mkenv__item__exported_ids: env -> exported_id_set FStar_Util.smap
  =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__exported_ids
let __proj__Mkenv__item__trans_exported_ids:
  env -> exported_id_set FStar_Util.smap =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__trans_exported_ids
let __proj__Mkenv__item__includes:
  env -> FStar_Ident.lident Prims.list FStar_ST.ref FStar_Util.smap =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__includes
let __proj__Mkenv__item__sigaccum: env -> FStar_Syntax_Syntax.sigelts =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__sigaccum
let __proj__Mkenv__item__sigmap:
  env ->
    (FStar_Syntax_Syntax.sigelt,Prims.bool) FStar_Pervasives_Native.tuple2
      FStar_Util.smap
  =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__sigmap
let __proj__Mkenv__item__iface: env -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__iface
let __proj__Mkenv__item__admitted_iface: env -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__admitted_iface
let __proj__Mkenv__item__expect_typ: env -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__expect_typ
let __proj__Mkenv__item__docs: env -> FStar_Parser_AST.fsdoc FStar_Util.smap
  =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__docs
let __proj__Mkenv__item__remaining_iface_decls:
  env ->
    (FStar_Ident.lident,FStar_Parser_AST.decl Prims.list)
      FStar_Pervasives_Native.tuple2 Prims.list
  =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__remaining_iface_decls
let __proj__Mkenv__item__syntax_only: env -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__syntax_only
let __proj__Mkenv__item__ds_hooks: env -> dsenv_hooks =
  fun projectee  ->
    match projectee with
    | { curmodule = __fname__curmodule; curmonad = __fname__curmonad;
        modules = __fname__modules; scope_mods = __fname__scope_mods;
        exported_ids = __fname__exported_ids;
        trans_exported_ids = __fname__trans_exported_ids;
        includes = __fname__includes; sigaccum = __fname__sigaccum;
        sigmap = __fname__sigmap; iface = __fname__iface;
        admitted_iface = __fname__admitted_iface;
        expect_typ = __fname__expect_typ; docs = __fname__docs;
        remaining_iface_decls = __fname__remaining_iface_decls;
        syntax_only = __fname__syntax_only; ds_hooks = __fname__ds_hooks;_}
        -> __fname__ds_hooks
let __proj__Mkdsenv_hooks__item__ds_push_open_hook:
  dsenv_hooks -> env -> open_module_or_namespace -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { ds_push_open_hook = __fname__ds_push_open_hook;
        ds_push_include_hook = __fname__ds_push_include_hook;
        ds_push_module_abbrev_hook = __fname__ds_push_module_abbrev_hook;_}
        -> __fname__ds_push_open_hook
let __proj__Mkdsenv_hooks__item__ds_push_include_hook:
  dsenv_hooks -> env -> FStar_Ident.lident -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { ds_push_open_hook = __fname__ds_push_open_hook;
        ds_push_include_hook = __fname__ds_push_include_hook;
        ds_push_module_abbrev_hook = __fname__ds_push_module_abbrev_hook;_}
        -> __fname__ds_push_include_hook
let __proj__Mkdsenv_hooks__item__ds_push_module_abbrev_hook:
  dsenv_hooks -> env -> FStar_Ident.ident -> FStar_Ident.lident -> Prims.unit
  =
  fun projectee  ->
    match projectee with
    | { ds_push_open_hook = __fname__ds_push_open_hook;
        ds_push_include_hook = __fname__ds_push_include_hook;
        ds_push_module_abbrev_hook = __fname__ds_push_module_abbrev_hook;_}
        -> __fname__ds_push_module_abbrev_hook
type 'a withenv = env -> ('a,env) FStar_Pervasives_Native.tuple2[@@deriving
                                                                  show]
let default_ds_hooks: dsenv_hooks =
  {
    ds_push_open_hook = (fun uu____1523  -> fun uu____1524  -> ());
    ds_push_include_hook = (fun uu____1527  -> fun uu____1528  -> ());
    ds_push_module_abbrev_hook =
      (fun uu____1532  -> fun uu____1533  -> fun uu____1534  -> ())
  }
type foundname =
  | Term_name of (FStar_Syntax_Syntax.typ,Prims.bool)
  FStar_Pervasives_Native.tuple2
  | Eff_name of (FStar_Syntax_Syntax.sigelt,FStar_Ident.lident)
  FStar_Pervasives_Native.tuple2[@@deriving show]
let uu___is_Term_name: foundname -> Prims.bool =
  fun projectee  ->
    match projectee with | Term_name _0 -> true | uu____1559 -> false
let __proj__Term_name__item___0:
  foundname ->
    (FStar_Syntax_Syntax.typ,Prims.bool) FStar_Pervasives_Native.tuple2
  = fun projectee  -> match projectee with | Term_name _0 -> _0
let uu___is_Eff_name: foundname -> Prims.bool =
  fun projectee  ->
    match projectee with | Eff_name _0 -> true | uu____1587 -> false
let __proj__Eff_name__item___0:
  foundname ->
    (FStar_Syntax_Syntax.sigelt,FStar_Ident.lident)
      FStar_Pervasives_Native.tuple2
  = fun projectee  -> match projectee with | Eff_name _0 -> _0
let set_iface: env -> Prims.bool -> env =
  fun env  ->
    fun b  ->
      let uu___187_1613 = env in
      {
        curmodule = (uu___187_1613.curmodule);
        curmonad = (uu___187_1613.curmonad);
        modules = (uu___187_1613.modules);
        scope_mods = (uu___187_1613.scope_mods);
        exported_ids = (uu___187_1613.exported_ids);
        trans_exported_ids = (uu___187_1613.trans_exported_ids);
        includes = (uu___187_1613.includes);
        sigaccum = (uu___187_1613.sigaccum);
        sigmap = (uu___187_1613.sigmap);
        iface = b;
        admitted_iface = (uu___187_1613.admitted_iface);
        expect_typ = (uu___187_1613.expect_typ);
        docs = (uu___187_1613.docs);
        remaining_iface_decls = (uu___187_1613.remaining_iface_decls);
        syntax_only = (uu___187_1613.syntax_only);
        ds_hooks = (uu___187_1613.ds_hooks)
      }
let iface: env -> Prims.bool = fun e  -> e.iface
let set_admitted_iface: env -> Prims.bool -> env =
  fun e  ->
    fun b  ->
      let uu___188_1623 = e in
      {
        curmodule = (uu___188_1623.curmodule);
        curmonad = (uu___188_1623.curmonad);
        modules = (uu___188_1623.modules);
        scope_mods = (uu___188_1623.scope_mods);
        exported_ids = (uu___188_1623.exported_ids);
        trans_exported_ids = (uu___188_1623.trans_exported_ids);
        includes = (uu___188_1623.includes);
        sigaccum = (uu___188_1623.sigaccum);
        sigmap = (uu___188_1623.sigmap);
        iface = (uu___188_1623.iface);
        admitted_iface = b;
        expect_typ = (uu___188_1623.expect_typ);
        docs = (uu___188_1623.docs);
        remaining_iface_decls = (uu___188_1623.remaining_iface_decls);
        syntax_only = (uu___188_1623.syntax_only);
        ds_hooks = (uu___188_1623.ds_hooks)
      }
let admitted_iface: env -> Prims.bool = fun e  -> e.admitted_iface
let set_expect_typ: env -> Prims.bool -> env =
  fun e  ->
    fun b  ->
      let uu___189_1633 = e in
      {
        curmodule = (uu___189_1633.curmodule);
        curmonad = (uu___189_1633.curmonad);
        modules = (uu___189_1633.modules);
        scope_mods = (uu___189_1633.scope_mods);
        exported_ids = (uu___189_1633.exported_ids);
        trans_exported_ids = (uu___189_1633.trans_exported_ids);
        includes = (uu___189_1633.includes);
        sigaccum = (uu___189_1633.sigaccum);
        sigmap = (uu___189_1633.sigmap);
        iface = (uu___189_1633.iface);
        admitted_iface = (uu___189_1633.admitted_iface);
        expect_typ = b;
        docs = (uu___189_1633.docs);
        remaining_iface_decls = (uu___189_1633.remaining_iface_decls);
        syntax_only = (uu___189_1633.syntax_only);
        ds_hooks = (uu___189_1633.ds_hooks)
      }
let expect_typ: env -> Prims.bool = fun e  -> e.expect_typ
let all_exported_id_kinds: exported_id_kind Prims.list =
  [Exported_id_field; Exported_id_term_type]
let transitive_exported_ids:
  env -> FStar_Ident.lident -> Prims.string Prims.list =
  fun env  ->
    fun lid  ->
      let module_name = FStar_Ident.string_of_lid lid in
      let uu____1648 =
        FStar_Util.smap_try_find env.trans_exported_ids module_name in
      match uu____1648 with
      | FStar_Pervasives_Native.None  -> []
      | FStar_Pervasives_Native.Some exported_id_set ->
          let uu____1654 =
            let uu____1655 = exported_id_set Exported_id_term_type in
            FStar_ST.op_Bang uu____1655 in
          FStar_All.pipe_right uu____1654 FStar_Util.set_elements
let open_modules:
  env ->
    (FStar_Ident.lident,FStar_Syntax_Syntax.modul)
      FStar_Pervasives_Native.tuple2 Prims.list
  = fun e  -> e.modules
let open_modules_and_namespaces: env -> FStar_Ident.lident Prims.list =
  fun env  ->
    FStar_List.filter_map
      (fun uu___155_1918  ->
         match uu___155_1918 with
         | Open_module_or_namespace (lid,_info) ->
             FStar_Pervasives_Native.Some lid
         | uu____1923 -> FStar_Pervasives_Native.None) env.scope_mods
let set_current_module: env -> FStar_Ident.lident -> env =
  fun e  ->
    fun l  ->
      let uu___190_1930 = e in
      {
        curmodule = (FStar_Pervasives_Native.Some l);
        curmonad = (uu___190_1930.curmonad);
        modules = (uu___190_1930.modules);
        scope_mods = (uu___190_1930.scope_mods);
        exported_ids = (uu___190_1930.exported_ids);
        trans_exported_ids = (uu___190_1930.trans_exported_ids);
        includes = (uu___190_1930.includes);
        sigaccum = (uu___190_1930.sigaccum);
        sigmap = (uu___190_1930.sigmap);
        iface = (uu___190_1930.iface);
        admitted_iface = (uu___190_1930.admitted_iface);
        expect_typ = (uu___190_1930.expect_typ);
        docs = (uu___190_1930.docs);
        remaining_iface_decls = (uu___190_1930.remaining_iface_decls);
        syntax_only = (uu___190_1930.syntax_only);
        ds_hooks = (uu___190_1930.ds_hooks)
      }
let current_module: env -> FStar_Ident.lident =
  fun env  ->
    match env.curmodule with
    | FStar_Pervasives_Native.None  -> failwith "Unset current module"
    | FStar_Pervasives_Native.Some m -> m
let iface_decls:
  env ->
    FStar_Ident.lident ->
      FStar_Parser_AST.decl Prims.list FStar_Pervasives_Native.option
  =
  fun env  ->
    fun l  ->
      let uu____1945 =
        FStar_All.pipe_right env.remaining_iface_decls
          (FStar_List.tryFind
             (fun uu____1979  ->
                match uu____1979 with
                | (m,uu____1987) -> FStar_Ident.lid_equals l m)) in
      match uu____1945 with
      | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
      | FStar_Pervasives_Native.Some (uu____2004,decls) ->
          FStar_Pervasives_Native.Some decls
let set_iface_decls:
  env -> FStar_Ident.lident -> FStar_Parser_AST.decl Prims.list -> env =
  fun env  ->
    fun l  ->
      fun ds  ->
        let uu____2031 =
          FStar_List.partition
            (fun uu____2061  ->
               match uu____2061 with
               | (m,uu____2069) -> FStar_Ident.lid_equals l m)
            env.remaining_iface_decls in
        match uu____2031 with
        | (uu____2074,rest) ->
            let uu___191_2108 = env in
            {
              curmodule = (uu___191_2108.curmodule);
              curmonad = (uu___191_2108.curmonad);
              modules = (uu___191_2108.modules);
              scope_mods = (uu___191_2108.scope_mods);
              exported_ids = (uu___191_2108.exported_ids);
              trans_exported_ids = (uu___191_2108.trans_exported_ids);
              includes = (uu___191_2108.includes);
              sigaccum = (uu___191_2108.sigaccum);
              sigmap = (uu___191_2108.sigmap);
              iface = (uu___191_2108.iface);
              admitted_iface = (uu___191_2108.admitted_iface);
              expect_typ = (uu___191_2108.expect_typ);
              docs = (uu___191_2108.docs);
              remaining_iface_decls = ((l, ds) :: rest);
              syntax_only = (uu___191_2108.syntax_only);
              ds_hooks = (uu___191_2108.ds_hooks)
            }
let qual: FStar_Ident.lident -> FStar_Ident.ident -> FStar_Ident.lident =
  FStar_Syntax_Util.qual_id
let qualify: env -> FStar_Ident.ident -> FStar_Ident.lident =
  fun env  ->
    fun id1  ->
      match env.curmonad with
      | FStar_Pervasives_Native.None  ->
          let uu____2127 = current_module env in qual uu____2127 id1
      | FStar_Pervasives_Native.Some monad ->
          let uu____2129 =
            let uu____2130 = current_module env in qual uu____2130 monad in
          FStar_Syntax_Util.mk_field_projector_name_from_ident uu____2129 id1
let syntax_only: env -> Prims.bool = fun env  -> env.syntax_only
let set_syntax_only: env -> Prims.bool -> env =
  fun env  ->
    fun b  ->
      let uu___192_2140 = env in
      {
        curmodule = (uu___192_2140.curmodule);
        curmonad = (uu___192_2140.curmonad);
        modules = (uu___192_2140.modules);
        scope_mods = (uu___192_2140.scope_mods);
        exported_ids = (uu___192_2140.exported_ids);
        trans_exported_ids = (uu___192_2140.trans_exported_ids);
        includes = (uu___192_2140.includes);
        sigaccum = (uu___192_2140.sigaccum);
        sigmap = (uu___192_2140.sigmap);
        iface = (uu___192_2140.iface);
        admitted_iface = (uu___192_2140.admitted_iface);
        expect_typ = (uu___192_2140.expect_typ);
        docs = (uu___192_2140.docs);
        remaining_iface_decls = (uu___192_2140.remaining_iface_decls);
        syntax_only = b;
        ds_hooks = (uu___192_2140.ds_hooks)
      }
let ds_hooks: env -> dsenv_hooks = fun env  -> env.ds_hooks
let set_ds_hooks: env -> dsenv_hooks -> env =
  fun env  ->
    fun hooks  ->
      let uu___193_2150 = env in
      {
        curmodule = (uu___193_2150.curmodule);
        curmonad = (uu___193_2150.curmonad);
        modules = (uu___193_2150.modules);
        scope_mods = (uu___193_2150.scope_mods);
        exported_ids = (uu___193_2150.exported_ids);
        trans_exported_ids = (uu___193_2150.trans_exported_ids);
        includes = (uu___193_2150.includes);
        sigaccum = (uu___193_2150.sigaccum);
        sigmap = (uu___193_2150.sigmap);
        iface = (uu___193_2150.iface);
        admitted_iface = (uu___193_2150.admitted_iface);
        expect_typ = (uu___193_2150.expect_typ);
        docs = (uu___193_2150.docs);
        remaining_iface_decls = (uu___193_2150.remaining_iface_decls);
        syntax_only = (uu___193_2150.syntax_only);
        ds_hooks = hooks
      }
let new_sigmap: 'Auu____2153 . Prims.unit -> 'Auu____2153 FStar_Util.smap =
  fun uu____2159  -> FStar_Util.smap_create (Prims.parse_int "100")
let empty_env: Prims.unit -> env =
  fun uu____2162  ->
    let uu____2163 = new_sigmap () in
    let uu____2166 = new_sigmap () in
    let uu____2169 = new_sigmap () in
    let uu____2180 = new_sigmap () in
    let uu____2191 = new_sigmap () in
    {
      curmodule = FStar_Pervasives_Native.None;
      curmonad = FStar_Pervasives_Native.None;
      modules = [];
      scope_mods = [];
      exported_ids = uu____2163;
      trans_exported_ids = uu____2166;
      includes = uu____2169;
      sigaccum = [];
      sigmap = uu____2180;
      iface = false;
      admitted_iface = false;
      expect_typ = false;
      docs = uu____2191;
      remaining_iface_decls = [];
      syntax_only = false;
      ds_hooks = default_ds_hooks
    }
let sigmap:
  env ->
    (FStar_Syntax_Syntax.sigelt,Prims.bool) FStar_Pervasives_Native.tuple2
      FStar_Util.smap
  = fun env  -> env.sigmap
let has_all_in_scope: env -> Prims.bool =
  fun env  ->
    FStar_List.existsb
      (fun uu____2223  ->
         match uu____2223 with
         | (m,uu____2229) ->
             FStar_Ident.lid_equals m FStar_Parser_Const.all_lid) env.modules
let set_bv_range:
  FStar_Syntax_Syntax.bv -> FStar_Range.range -> FStar_Syntax_Syntax.bv =
  fun bv  ->
    fun r  ->
      let id1 =
        let uu___194_2237 = bv.FStar_Syntax_Syntax.ppname in
        {
          FStar_Ident.idText = (uu___194_2237.FStar_Ident.idText);
          FStar_Ident.idRange = r
        } in
      let uu___195_2238 = bv in
      {
        FStar_Syntax_Syntax.ppname = id1;
        FStar_Syntax_Syntax.index = (uu___195_2238.FStar_Syntax_Syntax.index);
        FStar_Syntax_Syntax.sort = (uu___195_2238.FStar_Syntax_Syntax.sort)
      }
let bv_to_name:
  FStar_Syntax_Syntax.bv -> FStar_Range.range -> FStar_Syntax_Syntax.term =
  fun bv  -> fun r  -> FStar_Syntax_Syntax.bv_to_name (set_bv_range bv r)
let unmangleMap:
  (Prims.string,Prims.string,FStar_Syntax_Syntax.delta_depth,FStar_Syntax_Syntax.fv_qual
                                                               FStar_Pervasives_Native.option)
    FStar_Pervasives_Native.tuple4 Prims.list
  =
  [("op_ColonColon", "Cons", FStar_Syntax_Syntax.Delta_constant,
     (FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Data_ctor));
  ("not", "op_Negation", FStar_Syntax_Syntax.Delta_equational,
    FStar_Pervasives_Native.None)]
let unmangleOpName:
  FStar_Ident.ident ->
    (FStar_Syntax_Syntax.term,Prims.bool) FStar_Pervasives_Native.tuple2
      FStar_Pervasives_Native.option
  =
  fun id1  ->
    let t =
      FStar_Util.find_map unmangleMap
        (fun uu____2325  ->
           match uu____2325 with
           | (x,y,dd,dq) ->
               if id1.FStar_Ident.idText = x
               then
                 let uu____2348 =
                   let uu____2349 =
                     FStar_Ident.lid_of_path ["Prims"; y]
                       id1.FStar_Ident.idRange in
                   FStar_Syntax_Syntax.fvar uu____2349 dd dq in
                 FStar_Pervasives_Native.Some uu____2348
               else FStar_Pervasives_Native.None) in
    match t with
    | FStar_Pervasives_Native.Some v1 ->
        FStar_Pervasives_Native.Some (v1, false)
    | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
type 'a cont_t =
  | Cont_ok of 'a
  | Cont_fail
  | Cont_ignore[@@deriving show]
let uu___is_Cont_ok: 'a . 'a cont_t -> Prims.bool =
  fun projectee  ->
    match projectee with | Cont_ok _0 -> true | uu____2392 -> false
let __proj__Cont_ok__item___0: 'a . 'a cont_t -> 'a =
  fun projectee  -> match projectee with | Cont_ok _0 -> _0
let uu___is_Cont_fail: 'a . 'a cont_t -> Prims.bool =
  fun projectee  ->
    match projectee with | Cont_fail  -> true | uu____2421 -> false
let uu___is_Cont_ignore: 'a . 'a cont_t -> Prims.bool =
  fun projectee  ->
    match projectee with | Cont_ignore  -> true | uu____2435 -> false
let option_of_cont:
  'a .
    (Prims.unit -> 'a FStar_Pervasives_Native.option) ->
      'a cont_t -> 'a FStar_Pervasives_Native.option
  =
  fun k_ignore  ->
    fun uu___156_2458  ->
      match uu___156_2458 with
      | Cont_ok a -> FStar_Pervasives_Native.Some a
      | Cont_fail  -> FStar_Pervasives_Native.None
      | Cont_ignore  -> k_ignore ()
let find_in_record:
  'Auu____2471 .
    FStar_Ident.ident Prims.list ->
      FStar_Ident.ident ->
        record_or_dc ->
          (record_or_dc -> 'Auu____2471 cont_t) -> 'Auu____2471 cont_t
  =
  fun ns  ->
    fun id1  ->
      fun record  ->
        fun cont  ->
          let typename' =
            FStar_Ident.lid_of_ids
              (FStar_List.append ns [(record.typename).FStar_Ident.ident]) in
          if FStar_Ident.lid_equals typename' record.typename
          then
            let fname =
              FStar_Ident.lid_of_ids
                (FStar_List.append (record.typename).FStar_Ident.ns [id1]) in
            let find1 =
              FStar_Util.find_map record.fields
                (fun uu____2517  ->
                   match uu____2517 with
                   | (f,uu____2525) ->
                       if id1.FStar_Ident.idText = f.FStar_Ident.idText
                       then FStar_Pervasives_Native.Some record
                       else FStar_Pervasives_Native.None) in
            match find1 with
            | FStar_Pervasives_Native.Some r -> cont r
            | FStar_Pervasives_Native.None  -> Cont_ignore
          else Cont_ignore
let get_exported_id_set:
  env ->
    Prims.string ->
      (exported_id_kind -> string_set FStar_ST.ref)
        FStar_Pervasives_Native.option
  = fun e  -> fun mname  -> FStar_Util.smap_try_find e.exported_ids mname
let get_trans_exported_id_set:
  env ->
    Prims.string ->
      (exported_id_kind -> string_set FStar_ST.ref)
        FStar_Pervasives_Native.option
  =
  fun e  -> fun mname  -> FStar_Util.smap_try_find e.trans_exported_ids mname
let string_of_exported_id_kind: exported_id_kind -> Prims.string =
  fun uu___157_2571  ->
    match uu___157_2571 with
    | Exported_id_field  -> "field"
    | Exported_id_term_type  -> "term/type"
let find_in_module_with_includes:
  'a .
    exported_id_kind ->
      (FStar_Ident.lident -> 'a cont_t) ->
        'a cont_t ->
          env -> FStar_Ident.lident -> FStar_Ident.ident -> 'a cont_t
  =
  fun eikind  ->
    fun find_in_module  ->
      fun find_in_module_default  ->
        fun env  ->
          fun ns  ->
            fun id1  ->
              let idstr = id1.FStar_Ident.idText in
              let rec aux uu___158_2627 =
                match uu___158_2627 with
                | [] -> find_in_module_default
                | modul::q ->
                    let mname = modul.FStar_Ident.str in
                    let not_shadowed =
                      let uu____2638 = get_exported_id_set env mname in
                      match uu____2638 with
                      | FStar_Pervasives_Native.None  -> true
                      | FStar_Pervasives_Native.Some mex ->
                          let mexports =
                            let uu____2659 = mex eikind in
                            FStar_ST.op_Bang uu____2659 in
                          FStar_Util.set_mem idstr mexports in
                    let mincludes =
                      let uu____2906 =
                        FStar_Util.smap_try_find env.includes mname in
                      match uu____2906 with
                      | FStar_Pervasives_Native.None  -> []
                      | FStar_Pervasives_Native.Some minc ->
                          FStar_ST.op_Bang minc in
                    let look_into =
                      if not_shadowed
                      then
                        let uu____3001 = qual modul id1 in
                        find_in_module uu____3001
                      else Cont_ignore in
                    (match look_into with
                     | Cont_ignore  -> aux (FStar_List.append mincludes q)
                     | uu____3005 -> look_into) in
              aux [ns]
let is_exported_id_field: exported_id_kind -> Prims.bool =
  fun uu___159_3010  ->
    match uu___159_3010 with
    | Exported_id_field  -> true
    | uu____3011 -> false
let try_lookup_id'':
  'a .
    env ->
      FStar_Ident.ident ->
        exported_id_kind ->
          (local_binding -> 'a cont_t) ->
            (rec_binding -> 'a cont_t) ->
              (record_or_dc -> 'a cont_t) ->
                (FStar_Ident.lident -> 'a cont_t) ->
                  ('a cont_t -> FStar_Ident.ident -> 'a cont_t) ->
                    'a FStar_Pervasives_Native.option
  =
  fun env  ->
    fun id1  ->
      fun eikind  ->
        fun k_local_binding  ->
          fun k_rec_binding  ->
            fun k_record  ->
              fun find_in_module  ->
                fun lookup_default_id  ->
                  let check_local_binding_id uu___160_3113 =
                    match uu___160_3113 with
                    | (id',uu____3115,uu____3116) ->
                        id'.FStar_Ident.idText = id1.FStar_Ident.idText in
                  let check_rec_binding_id uu___161_3120 =
                    match uu___161_3120 with
                    | (id',uu____3122,uu____3123) ->
                        id'.FStar_Ident.idText = id1.FStar_Ident.idText in
                  let curmod_ns =
                    let uu____3127 = current_module env in
                    FStar_Ident.ids_of_lid uu____3127 in
                  let proc uu___162_3133 =
                    match uu___162_3133 with
                    | Local_binding l when check_local_binding_id l ->
                        k_local_binding l
                    | Rec_binding r when check_rec_binding_id r ->
                        k_rec_binding r
                    | Open_module_or_namespace (ns,Open_module ) ->
                        find_in_module_with_includes eikind find_in_module
                          Cont_ignore env ns id1
                    | Top_level_def id' when
                        id'.FStar_Ident.idText = id1.FStar_Ident.idText ->
                        lookup_default_id Cont_ignore id1
                    | Record_or_dc r when is_exported_id_field eikind ->
                        let uu____3141 = FStar_Ident.lid_of_ids curmod_ns in
                        find_in_module_with_includes Exported_id_field
                          (fun lid  ->
                             let id2 = lid.FStar_Ident.ident in
                             find_in_record lid.FStar_Ident.ns id2 r k_record)
                          Cont_ignore env uu____3141 id1
                    | uu____3146 -> Cont_ignore in
                  let rec aux uu___163_3154 =
                    match uu___163_3154 with
                    | a::q ->
                        let uu____3163 = proc a in
                        option_of_cont (fun uu____3167  -> aux q) uu____3163
                    | [] ->
                        let uu____3168 = lookup_default_id Cont_fail id1 in
                        option_of_cont
                          (fun uu____3172  -> FStar_Pervasives_Native.None)
                          uu____3168 in
                  aux env.scope_mods
let found_local_binding:
  'Auu____3177 'Auu____3178 .
    FStar_Range.range ->
      ('Auu____3178,FStar_Syntax_Syntax.bv,'Auu____3177)
        FStar_Pervasives_Native.tuple3 ->
        (FStar_Syntax_Syntax.term,'Auu____3177)
          FStar_Pervasives_Native.tuple2
  =
  fun r  ->
    fun uu____3196  ->
      match uu____3196 with
      | (id',x,mut) -> let uu____3206 = bv_to_name x r in (uu____3206, mut)
let find_in_module:
  'Auu____3212 .
    env ->
      FStar_Ident.lident ->
        (FStar_Ident.lident ->
           (FStar_Syntax_Syntax.sigelt,Prims.bool)
             FStar_Pervasives_Native.tuple2 -> 'Auu____3212)
          -> 'Auu____3212 -> 'Auu____3212
  =
  fun env  ->
    fun lid  ->
      fun k_global_def  ->
        fun k_not_found  ->
          let uu____3247 =
            FStar_Util.smap_try_find (sigmap env) lid.FStar_Ident.str in
          match uu____3247 with
          | FStar_Pervasives_Native.Some sb -> k_global_def lid sb
          | FStar_Pervasives_Native.None  -> k_not_found
let try_lookup_id:
  env ->
    FStar_Ident.ident ->
      (FStar_Syntax_Syntax.term,Prims.bool) FStar_Pervasives_Native.tuple2
        FStar_Pervasives_Native.option
  =
  fun env  ->
    fun id1  ->
      let uu____3283 = unmangleOpName id1 in
      match uu____3283 with
      | FStar_Pervasives_Native.Some f -> FStar_Pervasives_Native.Some f
      | uu____3309 ->
          try_lookup_id'' env id1 Exported_id_term_type
            (fun r  ->
               let uu____3323 = found_local_binding id1.FStar_Ident.idRange r in
               Cont_ok uu____3323) (fun uu____3333  -> Cont_fail)
            (fun uu____3339  -> Cont_ignore)
            (fun i  ->
               find_in_module env i
                 (fun uu____3354  -> fun uu____3355  -> Cont_fail)
                 Cont_ignore)
            (fun uu____3370  -> fun uu____3371  -> Cont_fail)
let lookup_default_id:
  'a .
    env ->
      FStar_Ident.ident ->
        (FStar_Ident.lident ->
           (FStar_Syntax_Syntax.sigelt,Prims.bool)
             FStar_Pervasives_Native.tuple2 -> 'a cont_t)
          -> 'a cont_t -> 'a cont_t
  =
  fun env  ->
    fun id1  ->
      fun k_global_def  ->
        fun k_not_found  ->
          let find_in_monad =
            match env.curmonad with
            | FStar_Pervasives_Native.Some uu____3441 ->
                let lid = qualify env id1 in
                let uu____3443 =
                  FStar_Util.smap_try_find (sigmap env) lid.FStar_Ident.str in
                (match uu____3443 with
                 | FStar_Pervasives_Native.Some r ->
                     let uu____3467 = k_global_def lid r in
                     FStar_Pervasives_Native.Some uu____3467
                 | FStar_Pervasives_Native.None  ->
                     FStar_Pervasives_Native.None)
            | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None in
          match find_in_monad with
          | FStar_Pervasives_Native.Some v1 -> v1
          | FStar_Pervasives_Native.None  ->
              let lid =
                let uu____3490 = current_module env in qual uu____3490 id1 in
              find_in_module env lid k_global_def k_not_found
let module_is_defined: env -> FStar_Ident.lident -> Prims.bool =
  fun env  ->
    fun lid  ->
      (match env.curmodule with
       | FStar_Pervasives_Native.None  -> false
       | FStar_Pervasives_Native.Some m ->
           let uu____3500 = current_module env in
           FStar_Ident.lid_equals lid uu____3500)
        ||
        (FStar_List.existsb
           (fun x  ->
              FStar_Ident.lid_equals lid (FStar_Pervasives_Native.fst x))
           env.modules)
let resolve_module_name:
  env ->
    FStar_Ident.lident ->
      Prims.bool -> FStar_Ident.lident FStar_Pervasives_Native.option
  =
  fun env  ->
    fun lid  ->
      fun honor_ns  ->
        let nslen = FStar_List.length lid.FStar_Ident.ns in
        let rec aux uu___164_3532 =
          match uu___164_3532 with
          | [] ->
              let uu____3537 = module_is_defined env lid in
              if uu____3537
              then FStar_Pervasives_Native.Some lid
              else FStar_Pervasives_Native.None
          | (Open_module_or_namespace (ns,Open_namespace ))::q when honor_ns
              ->
              let new_lid =
                let uu____3546 =
                  let uu____3549 = FStar_Ident.path_of_lid ns in
                  let uu____3552 = FStar_Ident.path_of_lid lid in
                  FStar_List.append uu____3549 uu____3552 in
                FStar_Ident.lid_of_path uu____3546
                  (FStar_Ident.range_of_lid lid) in
              let uu____3555 = module_is_defined env new_lid in
              if uu____3555
              then FStar_Pervasives_Native.Some new_lid
              else aux q
          | (Module_abbrev (name,modul))::uu____3561 when
              (nslen = (Prims.parse_int "0")) &&
                (name.FStar_Ident.idText =
                   (lid.FStar_Ident.ident).FStar_Ident.idText)
              -> FStar_Pervasives_Native.Some modul
          | uu____3568::q -> aux q in
        aux env.scope_mods
let fail_if_curmodule:
  env -> FStar_Ident.lident -> FStar_Ident.lident -> Prims.unit =
  fun env  ->
    fun ns_original  ->
      fun ns_resolved  ->
        let uu____3581 =
          let uu____3582 = current_module env in
          FStar_Ident.lid_equals ns_resolved uu____3582 in
        if uu____3581
        then
          (if FStar_Ident.lid_equals ns_resolved FStar_Parser_Const.prims_lid
           then ()
           else
             (let uu____3584 =
                let uu____3589 =
                  FStar_Util.format1
                    "Reference %s to current module is forbidden (see GitHub issue #451)"
                    ns_original.FStar_Ident.str in
                (FStar_Errors.Fatal_ForbiddenReferenceToCurrentModule,
                  uu____3589) in
              FStar_Errors.raise_error uu____3584
                (FStar_Ident.range_of_lid ns_original)))
        else ()
let fail_if_qualified_by_curmodule: env -> FStar_Ident.lident -> Prims.unit =
  fun env  ->
    fun lid  ->
      match lid.FStar_Ident.ns with
      | [] -> ()
      | uu____3597 ->
          let modul_orig = FStar_Ident.lid_of_ids lid.FStar_Ident.ns in
          let uu____3601 = resolve_module_name env modul_orig true in
          (match uu____3601 with
           | FStar_Pervasives_Native.Some modul_res ->
               fail_if_curmodule env modul_orig modul_res
           | uu____3605 -> ())
let namespace_is_open: env -> FStar_Ident.lident -> Prims.bool =
  fun env  ->
    fun lid  ->
      FStar_List.existsb
        (fun uu___165_3616  ->
           match uu___165_3616 with
           | Open_module_or_namespace (ns,Open_namespace ) ->
               FStar_Ident.lid_equals lid ns
           | uu____3618 -> false) env.scope_mods
let shorten_module_path:
  env ->
    FStar_Ident.ident Prims.list ->
      Prims.bool ->
        (FStar_Ident.ident Prims.list,FStar_Ident.ident Prims.list)
          FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun ids  ->
      fun is_full_path  ->
        let rec aux revns id1 =
          let lid = FStar_Ident.lid_of_ns_and_id (FStar_List.rev revns) id1 in
          if namespace_is_open env lid
          then
            FStar_Pervasives_Native.Some
              ((FStar_List.rev (id1 :: revns)), [])
          else
            (match revns with
             | [] -> FStar_Pervasives_Native.None
             | ns_last_id::rev_ns_prefix ->
                 let uu____3707 = aux rev_ns_prefix ns_last_id in
                 FStar_All.pipe_right uu____3707
                   (FStar_Util.map_option
                      (fun uu____3757  ->
                         match uu____3757 with
                         | (stripped_ids,rev_kept_ids) ->
                             (stripped_ids, (id1 :: rev_kept_ids))))) in
        let uu____3788 =
          is_full_path &&
            (let uu____3790 = FStar_Ident.lid_of_ids ids in
             module_is_defined env uu____3790) in
        if uu____3788
        then (ids, [])
        else
          (match FStar_List.rev ids with
           | [] -> ([], [])
           | ns_last_id::ns_rev_prefix ->
               let uu____3820 = aux ns_rev_prefix ns_last_id in
               (match uu____3820 with
                | FStar_Pervasives_Native.None  -> ([], ids)
                | FStar_Pervasives_Native.Some (stripped_ids,rev_kept_ids) ->
                    (stripped_ids, (FStar_List.rev rev_kept_ids))))
let shorten_lid: env -> FStar_Ident.lid -> FStar_Ident.lid =
  fun env  ->
    fun lid  ->
      let uu____3879 = shorten_module_path env lid.FStar_Ident.ns true in
      match uu____3879 with
      | (uu____3888,short) ->
          FStar_Ident.lid_of_ns_and_id short lid.FStar_Ident.ident
let resolve_in_open_namespaces'':
  'a .
    env ->
      FStar_Ident.lident ->
        exported_id_kind ->
          (local_binding -> 'a cont_t) ->
            (rec_binding -> 'a cont_t) ->
              (record_or_dc -> 'a cont_t) ->
                (FStar_Ident.lident -> 'a cont_t) ->
                  ('a cont_t -> FStar_Ident.ident -> 'a cont_t) ->
                    'a FStar_Pervasives_Native.option
  =
  fun env  ->
    fun lid  ->
      fun eikind  ->
        fun k_local_binding  ->
          fun k_rec_binding  ->
            fun k_record  ->
              fun f_module  ->
                fun l_default  ->
                  match lid.FStar_Ident.ns with
                  | uu____3996::uu____3997 ->
                      let uu____4000 =
                        let uu____4003 =
                          let uu____4004 =
                            FStar_Ident.lid_of_ids lid.FStar_Ident.ns in
                          FStar_Ident.set_lid_range uu____4004
                            (FStar_Ident.range_of_lid lid) in
                        resolve_module_name env uu____4003 true in
                      (match uu____4000 with
                       | FStar_Pervasives_Native.None  ->
                           FStar_Pervasives_Native.None
                       | FStar_Pervasives_Native.Some modul ->
                           let uu____4008 =
                             find_in_module_with_includes eikind f_module
                               Cont_fail env modul lid.FStar_Ident.ident in
                           option_of_cont
                             (fun uu____4012  -> FStar_Pervasives_Native.None)
                             uu____4008)
                  | [] ->
                      try_lookup_id'' env lid.FStar_Ident.ident eikind
                        k_local_binding k_rec_binding k_record f_module
                        l_default
let cont_of_option:
  'a . 'a cont_t -> 'a FStar_Pervasives_Native.option -> 'a cont_t =
  fun k_none  ->
    fun uu___166_4030  ->
      match uu___166_4030 with
      | FStar_Pervasives_Native.Some v1 -> Cont_ok v1
      | FStar_Pervasives_Native.None  -> k_none
let resolve_in_open_namespaces':
  'a .
    env ->
      FStar_Ident.lident ->
        (local_binding -> 'a FStar_Pervasives_Native.option) ->
          (rec_binding -> 'a FStar_Pervasives_Native.option) ->
            (FStar_Ident.lident ->
               (FStar_Syntax_Syntax.sigelt,Prims.bool)
                 FStar_Pervasives_Native.tuple2 ->
                 'a FStar_Pervasives_Native.option)
              -> 'a FStar_Pervasives_Native.option
  =
  fun env  ->
    fun lid  ->
      fun k_local_binding  ->
        fun k_rec_binding  ->
          fun k_global_def  ->
            let k_global_def' k lid1 def =
              let uu____4129 = k_global_def lid1 def in
              cont_of_option k uu____4129 in
            let f_module lid' =
              let k = Cont_ignore in
              find_in_module env lid' (k_global_def' k) k in
            let l_default k i = lookup_default_id env i (k_global_def' k) k in
            resolve_in_open_namespaces'' env lid Exported_id_term_type
              (fun l  ->
                 let uu____4159 = k_local_binding l in
                 cont_of_option Cont_fail uu____4159)
              (fun r  ->
                 let uu____4165 = k_rec_binding r in
                 cont_of_option Cont_fail uu____4165)
              (fun uu____4169  -> Cont_ignore) f_module l_default
let fv_qual_of_se:
  FStar_Syntax_Syntax.sigelt ->
    FStar_Syntax_Syntax.fv_qual FStar_Pervasives_Native.option
  =
  fun se  ->
    match se.FStar_Syntax_Syntax.sigel with
    | FStar_Syntax_Syntax.Sig_datacon
        (uu____4177,uu____4178,uu____4179,l,uu____4181,uu____4182) ->
        let qopt =
          FStar_Util.find_map se.FStar_Syntax_Syntax.sigquals
            (fun uu___167_4193  ->
               match uu___167_4193 with
               | FStar_Syntax_Syntax.RecordConstructor (uu____4196,fs) ->
                   FStar_Pervasives_Native.Some
                     (FStar_Syntax_Syntax.Record_ctor (l, fs))
               | uu____4208 -> FStar_Pervasives_Native.None) in
        (match qopt with
         | FStar_Pervasives_Native.None  ->
             FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Data_ctor
         | x -> x)
    | FStar_Syntax_Syntax.Sig_declare_typ (uu____4214,uu____4215,uu____4216)
        -> FStar_Pervasives_Native.None
    | uu____4217 -> FStar_Pervasives_Native.None
let lb_fv:
  FStar_Syntax_Syntax.letbinding Prims.list ->
    FStar_Ident.lident -> FStar_Syntax_Syntax.fv
  =
  fun lbs  ->
    fun lid  ->
      let uu____4228 =
        FStar_Util.find_map lbs
          (fun lb  ->
             let fv = FStar_Util.right lb.FStar_Syntax_Syntax.lbname in
             let uu____4236 = FStar_Syntax_Syntax.fv_eq_lid fv lid in
             if uu____4236
             then FStar_Pervasives_Native.Some fv
             else FStar_Pervasives_Native.None) in
      FStar_All.pipe_right uu____4228 FStar_Util.must
let ns_of_lid_equals: FStar_Ident.lident -> FStar_Ident.lident -> Prims.bool
  =
  fun lid  ->
    fun ns  ->
      ((FStar_List.length lid.FStar_Ident.ns) =
         (FStar_List.length (FStar_Ident.ids_of_lid ns)))
        &&
        (let uu____4249 = FStar_Ident.lid_of_ids lid.FStar_Ident.ns in
         FStar_Ident.lid_equals uu____4249 ns)
let try_lookup_name:
  Prims.bool ->
    Prims.bool ->
      env -> FStar_Ident.lident -> foundname FStar_Pervasives_Native.option
  =
  fun any_val  ->
    fun exclude_interf  ->
      fun env  ->
        fun lid  ->
          let occurrence_range = FStar_Ident.range_of_lid lid in
          let k_global_def source_lid uu___172_4279 =
            match uu___172_4279 with
            | (uu____4286,true ) when exclude_interf ->
                FStar_Pervasives_Native.None
            | (se,uu____4288) ->
                (match se.FStar_Syntax_Syntax.sigel with
                 | FStar_Syntax_Syntax.Sig_inductive_typ uu____4291 ->
                     let uu____4308 =
                       let uu____4309 =
                         let uu____4314 =
                           FStar_Syntax_Syntax.fvar source_lid
                             FStar_Syntax_Syntax.Delta_constant
                             FStar_Pervasives_Native.None in
                         (uu____4314, false) in
                       Term_name uu____4309 in
                     FStar_Pervasives_Native.Some uu____4308
                 | FStar_Syntax_Syntax.Sig_datacon uu____4315 ->
                     let uu____4330 =
                       let uu____4331 =
                         let uu____4336 =
                           let uu____4337 = fv_qual_of_se se in
                           FStar_Syntax_Syntax.fvar source_lid
                             FStar_Syntax_Syntax.Delta_constant uu____4337 in
                         (uu____4336, false) in
                       Term_name uu____4331 in
                     FStar_Pervasives_Native.Some uu____4330
                 | FStar_Syntax_Syntax.Sig_let ((uu____4340,lbs),uu____4342)
                     ->
                     let fv = lb_fv lbs source_lid in
                     let uu____4358 =
                       let uu____4359 =
                         let uu____4364 =
                           FStar_Syntax_Syntax.fvar source_lid
                             fv.FStar_Syntax_Syntax.fv_delta
                             fv.FStar_Syntax_Syntax.fv_qual in
                         (uu____4364, false) in
                       Term_name uu____4359 in
                     FStar_Pervasives_Native.Some uu____4358
                 | FStar_Syntax_Syntax.Sig_declare_typ
                     (lid1,uu____4366,uu____4367) ->
                     let quals = se.FStar_Syntax_Syntax.sigquals in
                     let uu____4371 =
                       any_val ||
                         (FStar_All.pipe_right quals
                            (FStar_Util.for_some
                               (fun uu___168_4375  ->
                                  match uu___168_4375 with
                                  | FStar_Syntax_Syntax.Assumption  -> true
                                  | uu____4376 -> false))) in
                     if uu____4371
                     then
                       let lid2 =
                         FStar_Ident.set_lid_range lid1
                           (FStar_Ident.range_of_lid source_lid) in
                       let dd =
                         let uu____4381 =
                           (FStar_Syntax_Util.is_primop_lid lid2) ||
                             (FStar_All.pipe_right quals
                                (FStar_Util.for_some
                                   (fun uu___169_4386  ->
                                      match uu___169_4386 with
                                      | FStar_Syntax_Syntax.Projector
                                          uu____4387 -> true
                                      | FStar_Syntax_Syntax.Discriminator
                                          uu____4392 -> true
                                      | uu____4393 -> false))) in
                         if uu____4381
                         then FStar_Syntax_Syntax.Delta_equational
                         else FStar_Syntax_Syntax.Delta_constant in
                       let dd1 =
                         let uu____4396 =
                           FStar_All.pipe_right quals
                             (FStar_Util.for_some
                                (fun uu___170_4400  ->
                                   match uu___170_4400 with
                                   | FStar_Syntax_Syntax.Abstract  -> true
                                   | uu____4401 -> false)) in
                         if uu____4396
                         then FStar_Syntax_Syntax.Delta_abstract dd
                         else dd in
                       let uu____4403 =
                         FStar_Util.find_map quals
                           (fun uu___171_4408  ->
                              match uu___171_4408 with
                              | FStar_Syntax_Syntax.Reflectable refl_monad ->
                                  FStar_Pervasives_Native.Some refl_monad
                              | uu____4412 -> FStar_Pervasives_Native.None) in
                       (match uu____4403 with
                        | FStar_Pervasives_Native.Some refl_monad ->
                            let refl_const =
                              FStar_Syntax_Syntax.mk
                                (FStar_Syntax_Syntax.Tm_constant
                                   (FStar_Const.Const_reflect refl_monad))
                                FStar_Pervasives_Native.None occurrence_range in
                            FStar_Pervasives_Native.Some
                              (Term_name (refl_const, false))
                        | uu____4421 ->
                            let uu____4424 =
                              let uu____4425 =
                                let uu____4430 =
                                  let uu____4431 = fv_qual_of_se se in
                                  FStar_Syntax_Syntax.fvar lid2 dd1
                                    uu____4431 in
                                (uu____4430, false) in
                              Term_name uu____4425 in
                            FStar_Pervasives_Native.Some uu____4424)
                     else FStar_Pervasives_Native.None
                 | FStar_Syntax_Syntax.Sig_new_effect_for_free ne ->
                     FStar_Pervasives_Native.Some
                       (Eff_name
                          (se,
                            (FStar_Ident.set_lid_range
                               ne.FStar_Syntax_Syntax.mname
                               (FStar_Ident.range_of_lid source_lid))))
                 | FStar_Syntax_Syntax.Sig_new_effect ne ->
                     FStar_Pervasives_Native.Some
                       (Eff_name
                          (se,
                            (FStar_Ident.set_lid_range
                               ne.FStar_Syntax_Syntax.mname
                               (FStar_Ident.range_of_lid source_lid))))
                 | FStar_Syntax_Syntax.Sig_effect_abbrev uu____4437 ->
                     FStar_Pervasives_Native.Some (Eff_name (se, source_lid))
                 | uu____4450 -> FStar_Pervasives_Native.None) in
          let k_local_binding r =
            let uu____4469 =
              let uu____4470 =
                found_local_binding (FStar_Ident.range_of_lid lid) r in
              Term_name uu____4470 in
            FStar_Pervasives_Native.Some uu____4469 in
          let k_rec_binding uu____4486 =
            match uu____4486 with
            | (id1,l,dd) ->
                let uu____4498 =
                  let uu____4499 =
                    let uu____4504 =
                      FStar_Syntax_Syntax.fvar
                        (FStar_Ident.set_lid_range l
                           (FStar_Ident.range_of_lid lid)) dd
                        FStar_Pervasives_Native.None in
                    (uu____4504, false) in
                  Term_name uu____4499 in
                FStar_Pervasives_Native.Some uu____4498 in
          let found_unmangled =
            match lid.FStar_Ident.ns with
            | [] ->
                let uu____4510 = unmangleOpName lid.FStar_Ident.ident in
                (match uu____4510 with
                 | FStar_Pervasives_Native.Some f ->
                     FStar_Pervasives_Native.Some (Term_name f)
                 | uu____4528 -> FStar_Pervasives_Native.None)
            | uu____4535 -> FStar_Pervasives_Native.None in
          match found_unmangled with
          | FStar_Pervasives_Native.None  ->
              resolve_in_open_namespaces' env lid k_local_binding
                k_rec_binding k_global_def
          | x -> x
let try_lookup_effect_name':
  Prims.bool ->
    env ->
      FStar_Ident.lident ->
        (FStar_Syntax_Syntax.sigelt,FStar_Ident.lident)
          FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option
  =
  fun exclude_interf  ->
    fun env  ->
      fun lid  ->
        let uu____4564 = try_lookup_name true exclude_interf env lid in
        match uu____4564 with
        | FStar_Pervasives_Native.Some (Eff_name (o,l)) ->
            FStar_Pervasives_Native.Some (o, l)
        | uu____4579 -> FStar_Pervasives_Native.None
let try_lookup_effect_name:
  env ->
    FStar_Ident.lident -> FStar_Ident.lident FStar_Pervasives_Native.option
  =
  fun env  ->
    fun l  ->
      let uu____4594 =
        try_lookup_effect_name' (Prims.op_Negation env.iface) env l in
      match uu____4594 with
      | FStar_Pervasives_Native.Some (o,l1) ->
          FStar_Pervasives_Native.Some l1
      | uu____4609 -> FStar_Pervasives_Native.None
let try_lookup_effect_name_and_attributes:
  env ->
    FStar_Ident.lident ->
      (FStar_Ident.lident,FStar_Syntax_Syntax.cflags Prims.list)
        FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option
  =
  fun env  ->
    fun l  ->
      let uu____4630 =
        try_lookup_effect_name' (Prims.op_Negation env.iface) env l in
      match uu____4630 with
      | FStar_Pervasives_Native.Some
          ({
             FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_new_effect
               ne;
             FStar_Syntax_Syntax.sigrng = uu____4646;
             FStar_Syntax_Syntax.sigquals = uu____4647;
             FStar_Syntax_Syntax.sigmeta = uu____4648;
             FStar_Syntax_Syntax.sigattrs = uu____4649;_},l1)
          ->
          FStar_Pervasives_Native.Some
            (l1, (ne.FStar_Syntax_Syntax.cattributes))
      | FStar_Pervasives_Native.Some
          ({
             FStar_Syntax_Syntax.sigel =
               FStar_Syntax_Syntax.Sig_new_effect_for_free ne;
             FStar_Syntax_Syntax.sigrng = uu____4668;
             FStar_Syntax_Syntax.sigquals = uu____4669;
             FStar_Syntax_Syntax.sigmeta = uu____4670;
             FStar_Syntax_Syntax.sigattrs = uu____4671;_},l1)
          ->
          FStar_Pervasives_Native.Some
            (l1, (ne.FStar_Syntax_Syntax.cattributes))
      | FStar_Pervasives_Native.Some
          ({
             FStar_Syntax_Syntax.sigel =
               FStar_Syntax_Syntax.Sig_effect_abbrev
               (uu____4689,uu____4690,uu____4691,uu____4692,cattributes);
             FStar_Syntax_Syntax.sigrng = uu____4694;
             FStar_Syntax_Syntax.sigquals = uu____4695;
             FStar_Syntax_Syntax.sigmeta = uu____4696;
             FStar_Syntax_Syntax.sigattrs = uu____4697;_},l1)
          -> FStar_Pervasives_Native.Some (l1, cattributes)
      | uu____4719 -> FStar_Pervasives_Native.None
let try_lookup_effect_defn:
  env ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.eff_decl FStar_Pervasives_Native.option
  =
  fun env  ->
    fun l  ->
      let uu____4740 =
        try_lookup_effect_name' (Prims.op_Negation env.iface) env l in
      match uu____4740 with
      | FStar_Pervasives_Native.Some
          ({
             FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_new_effect
               ne;
             FStar_Syntax_Syntax.sigrng = uu____4750;
             FStar_Syntax_Syntax.sigquals = uu____4751;
             FStar_Syntax_Syntax.sigmeta = uu____4752;
             FStar_Syntax_Syntax.sigattrs = uu____4753;_},uu____4754)
          -> FStar_Pervasives_Native.Some ne
      | FStar_Pervasives_Native.Some
          ({
             FStar_Syntax_Syntax.sigel =
               FStar_Syntax_Syntax.Sig_new_effect_for_free ne;
             FStar_Syntax_Syntax.sigrng = uu____4764;
             FStar_Syntax_Syntax.sigquals = uu____4765;
             FStar_Syntax_Syntax.sigmeta = uu____4766;
             FStar_Syntax_Syntax.sigattrs = uu____4767;_},uu____4768)
          -> FStar_Pervasives_Native.Some ne
      | uu____4777 -> FStar_Pervasives_Native.None
let is_effect_name: env -> FStar_Ident.lident -> Prims.bool =
  fun env  ->
    fun lid  ->
      let uu____4790 = try_lookup_effect_name env lid in
      match uu____4790 with
      | FStar_Pervasives_Native.None  -> false
      | FStar_Pervasives_Native.Some uu____4793 -> true
let try_lookup_root_effect_name:
  env ->
    FStar_Ident.lident -> FStar_Ident.lident FStar_Pervasives_Native.option
  =
  fun env  ->
    fun l  ->
      let uu____4802 =
        try_lookup_effect_name' (Prims.op_Negation env.iface) env l in
      match uu____4802 with
      | FStar_Pervasives_Native.Some
          ({
             FStar_Syntax_Syntax.sigel =
               FStar_Syntax_Syntax.Sig_effect_abbrev
               (l',uu____4812,uu____4813,uu____4814,uu____4815);
             FStar_Syntax_Syntax.sigrng = uu____4816;
             FStar_Syntax_Syntax.sigquals = uu____4817;
             FStar_Syntax_Syntax.sigmeta = uu____4818;
             FStar_Syntax_Syntax.sigattrs = uu____4819;_},uu____4820)
          ->
          let rec aux new_name =
            let uu____4839 =
              FStar_Util.smap_try_find (sigmap env) new_name.FStar_Ident.str in
            match uu____4839 with
            | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
            | FStar_Pervasives_Native.Some (s,uu____4857) ->
                (match s.FStar_Syntax_Syntax.sigel with
                 | FStar_Syntax_Syntax.Sig_new_effect_for_free ne ->
                     FStar_Pervasives_Native.Some
                       (FStar_Ident.set_lid_range
                          ne.FStar_Syntax_Syntax.mname
                          (FStar_Ident.range_of_lid l))
                 | FStar_Syntax_Syntax.Sig_new_effect ne ->
                     FStar_Pervasives_Native.Some
                       (FStar_Ident.set_lid_range
                          ne.FStar_Syntax_Syntax.mname
                          (FStar_Ident.range_of_lid l))
                 | FStar_Syntax_Syntax.Sig_effect_abbrev
                     (uu____4866,uu____4867,uu____4868,cmp,uu____4870) ->
                     let l'' = FStar_Syntax_Util.comp_effect_name cmp in
                     aux l''
                 | uu____4876 -> FStar_Pervasives_Native.None) in
          aux l'
      | FStar_Pervasives_Native.Some (uu____4877,l') ->
          FStar_Pervasives_Native.Some l'
      | uu____4883 -> FStar_Pervasives_Native.None
let lookup_letbinding_quals:
  env -> FStar_Ident.lident -> FStar_Syntax_Syntax.qualifier Prims.list =
  fun env  ->
    fun lid  ->
      let k_global_def lid1 uu___173_4912 =
        match uu___173_4912 with
        | ({
             FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_declare_typ
               (uu____4921,uu____4922,uu____4923);
             FStar_Syntax_Syntax.sigrng = uu____4924;
             FStar_Syntax_Syntax.sigquals = quals;
             FStar_Syntax_Syntax.sigmeta = uu____4926;
             FStar_Syntax_Syntax.sigattrs = uu____4927;_},uu____4928)
            -> FStar_Pervasives_Native.Some quals
        | uu____4935 -> FStar_Pervasives_Native.None in
      let uu____4942 =
        resolve_in_open_namespaces' env lid
          (fun uu____4950  -> FStar_Pervasives_Native.None)
          (fun uu____4954  -> FStar_Pervasives_Native.None) k_global_def in
      match uu____4942 with
      | FStar_Pervasives_Native.Some quals -> quals
      | uu____4964 -> []
let try_lookup_module:
  env ->
    Prims.string Prims.list ->
      FStar_Syntax_Syntax.modul FStar_Pervasives_Native.option
  =
  fun env  ->
    fun path  ->
      let uu____4981 =
        FStar_List.tryFind
          (fun uu____4996  ->
             match uu____4996 with
             | (mlid,modul) ->
                 let uu____5003 = FStar_Ident.path_of_lid mlid in
                 uu____5003 = path) env.modules in
      match uu____4981 with
      | FStar_Pervasives_Native.Some (uu____5010,modul) ->
          FStar_Pervasives_Native.Some modul
      | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
let try_lookup_let:
  env ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option
  =
  fun env  ->
    fun lid  ->
      let k_global_def lid1 uu___174_5040 =
        match uu___174_5040 with
        | ({
             FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_let
               ((uu____5047,lbs),uu____5049);
             FStar_Syntax_Syntax.sigrng = uu____5050;
             FStar_Syntax_Syntax.sigquals = uu____5051;
             FStar_Syntax_Syntax.sigmeta = uu____5052;
             FStar_Syntax_Syntax.sigattrs = uu____5053;_},uu____5054)
            ->
            let fv = lb_fv lbs lid1 in
            let uu____5074 =
              FStar_Syntax_Syntax.fvar lid1 fv.FStar_Syntax_Syntax.fv_delta
                fv.FStar_Syntax_Syntax.fv_qual in
            FStar_Pervasives_Native.Some uu____5074
        | uu____5075 -> FStar_Pervasives_Native.None in
      resolve_in_open_namespaces' env lid
        (fun uu____5081  -> FStar_Pervasives_Native.None)
        (fun uu____5083  -> FStar_Pervasives_Native.None) k_global_def
let try_lookup_definition:
  env ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option
  =
  fun env  ->
    fun lid  ->
      let k_global_def lid1 uu___175_5106 =
        match uu___175_5106 with
        | ({
             FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_let
               (lbs,uu____5116);
             FStar_Syntax_Syntax.sigrng = uu____5117;
             FStar_Syntax_Syntax.sigquals = uu____5118;
             FStar_Syntax_Syntax.sigmeta = uu____5119;
             FStar_Syntax_Syntax.sigattrs = uu____5120;_},uu____5121)
            ->
            FStar_Util.find_map (FStar_Pervasives_Native.snd lbs)
              (fun lb  ->
                 match lb.FStar_Syntax_Syntax.lbname with
                 | FStar_Util.Inr fv when
                     FStar_Syntax_Syntax.fv_eq_lid fv lid1 ->
                     FStar_Pervasives_Native.Some
                       (lb.FStar_Syntax_Syntax.lbdef)
                 | uu____5144 -> FStar_Pervasives_Native.None)
        | uu____5151 -> FStar_Pervasives_Native.None in
      resolve_in_open_namespaces' env lid
        (fun uu____5161  -> FStar_Pervasives_Native.None)
        (fun uu____5165  -> FStar_Pervasives_Native.None) k_global_def
let empty_include_smap:
  FStar_Ident.lident Prims.list FStar_ST.ref FStar_Util.smap = new_sigmap ()
let empty_exported_id_smap: exported_id_set FStar_Util.smap = new_sigmap ()
let try_lookup_lid':
  Prims.bool ->
    Prims.bool ->
      env ->
        FStar_Ident.lident ->
          (FStar_Syntax_Syntax.term,Prims.bool)
            FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option
  =
  fun any_val  ->
    fun exclude_interface  ->
      fun env  ->
        fun lid  ->
          let uu____5204 = try_lookup_name any_val exclude_interface env lid in
          match uu____5204 with
          | FStar_Pervasives_Native.Some (Term_name (e,mut)) ->
              FStar_Pervasives_Native.Some (e, mut)
          | uu____5219 -> FStar_Pervasives_Native.None
let try_lookup_lid:
  env ->
    FStar_Ident.lident ->
      (FStar_Syntax_Syntax.term,Prims.bool) FStar_Pervasives_Native.tuple2
        FStar_Pervasives_Native.option
  = fun env  -> fun l  -> try_lookup_lid' env.iface false env l
let resolve_to_fully_qualified_name:
  env ->
    FStar_Ident.lident -> FStar_Ident.lident FStar_Pervasives_Native.option
  =
  fun env  ->
    fun l  ->
      let uu____5246 = try_lookup_lid env l in
      match uu____5246 with
      | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
      | FStar_Pervasives_Native.Some (e,uu____5260) ->
          let uu____5265 =
            let uu____5266 = FStar_Syntax_Subst.compress e in
            uu____5266.FStar_Syntax_Syntax.n in
          (match uu____5265 with
           | FStar_Syntax_Syntax.Tm_fvar fv ->
               FStar_Pervasives_Native.Some
                 ((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)
           | uu____5272 -> FStar_Pervasives_Native.None)
let try_lookup_lid_no_resolve:
  env ->
    FStar_Ident.lident ->
      (FStar_Syntax_Syntax.term,Prims.bool) FStar_Pervasives_Native.tuple2
        FStar_Pervasives_Native.option
  =
  fun env  ->
    fun l  ->
      let env' =
        let uu___196_5286 = env in
        {
          curmodule = (uu___196_5286.curmodule);
          curmonad = (uu___196_5286.curmonad);
          modules = (uu___196_5286.modules);
          scope_mods = [];
          exported_ids = empty_exported_id_smap;
          trans_exported_ids = (uu___196_5286.trans_exported_ids);
          includes = empty_include_smap;
          sigaccum = (uu___196_5286.sigaccum);
          sigmap = (uu___196_5286.sigmap);
          iface = (uu___196_5286.iface);
          admitted_iface = (uu___196_5286.admitted_iface);
          expect_typ = (uu___196_5286.expect_typ);
          docs = (uu___196_5286.docs);
          remaining_iface_decls = (uu___196_5286.remaining_iface_decls);
          syntax_only = (uu___196_5286.syntax_only);
          ds_hooks = (uu___196_5286.ds_hooks)
        } in
      try_lookup_lid env' l
let try_lookup_doc:
  env ->
    FStar_Ident.lid -> FStar_Parser_AST.fsdoc FStar_Pervasives_Native.option
  = fun env  -> fun l  -> FStar_Util.smap_try_find env.docs l.FStar_Ident.str
let try_lookup_datacon:
  env ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.fv FStar_Pervasives_Native.option
  =
  fun env  ->
    fun lid  ->
      let k_global_def lid1 uu___177_5315 =
        match uu___177_5315 with
        | ({
             FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_declare_typ
               (uu____5322,uu____5323,uu____5324);
             FStar_Syntax_Syntax.sigrng = uu____5325;
             FStar_Syntax_Syntax.sigquals = quals;
             FStar_Syntax_Syntax.sigmeta = uu____5327;
             FStar_Syntax_Syntax.sigattrs = uu____5328;_},uu____5329)
            ->
            let uu____5334 =
              FStar_All.pipe_right quals
                (FStar_Util.for_some
                   (fun uu___176_5338  ->
                      match uu___176_5338 with
                      | FStar_Syntax_Syntax.Assumption  -> true
                      | uu____5339 -> false)) in
            if uu____5334
            then
              let uu____5342 =
                FStar_Syntax_Syntax.lid_as_fv lid1
                  FStar_Syntax_Syntax.Delta_constant
                  FStar_Pervasives_Native.None in
              FStar_Pervasives_Native.Some uu____5342
            else FStar_Pervasives_Native.None
        | ({
             FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_datacon
               uu____5344;
             FStar_Syntax_Syntax.sigrng = uu____5345;
             FStar_Syntax_Syntax.sigquals = uu____5346;
             FStar_Syntax_Syntax.sigmeta = uu____5347;
             FStar_Syntax_Syntax.sigattrs = uu____5348;_},uu____5349)
            ->
            let uu____5368 =
              FStar_Syntax_Syntax.lid_as_fv lid1
                FStar_Syntax_Syntax.Delta_constant
                (FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Data_ctor) in
            FStar_Pervasives_Native.Some uu____5368
        | uu____5369 -> FStar_Pervasives_Native.None in
      resolve_in_open_namespaces' env lid
        (fun uu____5375  -> FStar_Pervasives_Native.None)
        (fun uu____5377  -> FStar_Pervasives_Native.None) k_global_def
let find_all_datacons:
  env ->
    FStar_Ident.lident ->
      FStar_Ident.lident Prims.list FStar_Pervasives_Native.option
  =
  fun env  ->
    fun lid  ->
      let k_global_def lid1 uu___178_5402 =
        match uu___178_5402 with
        | ({
             FStar_Syntax_Syntax.sigel =
               FStar_Syntax_Syntax.Sig_inductive_typ
               (uu____5411,uu____5412,uu____5413,uu____5414,datas,uu____5416);
             FStar_Syntax_Syntax.sigrng = uu____5417;
             FStar_Syntax_Syntax.sigquals = uu____5418;
             FStar_Syntax_Syntax.sigmeta = uu____5419;
             FStar_Syntax_Syntax.sigattrs = uu____5420;_},uu____5421)
            -> FStar_Pervasives_Native.Some datas
        | uu____5436 -> FStar_Pervasives_Native.None in
      resolve_in_open_namespaces' env lid
        (fun uu____5446  -> FStar_Pervasives_Native.None)
        (fun uu____5450  -> FStar_Pervasives_Native.None) k_global_def
let record_cache_aux_with_filter:
  ((Prims.unit -> Prims.unit,Prims.unit -> Prims.unit,Prims.unit ->
                                                        record_or_dc
                                                          Prims.list,
     record_or_dc -> Prims.unit) FStar_Pervasives_Native.tuple4,Prims.unit ->
                                                                  Prims.unit)
    FStar_Pervasives_Native.tuple2
  =
  let record_cache = FStar_Util.mk_ref [[]] in
  let push1 uu____5495 =
    let uu____5496 =
      let uu____5501 =
        let uu____5504 = FStar_ST.op_Bang record_cache in
        FStar_List.hd uu____5504 in
      let uu____5579 = FStar_ST.op_Bang record_cache in uu____5501 ::
        uu____5579 in
    FStar_ST.op_Colon_Equals record_cache uu____5496 in
  let pop1 uu____5725 =
    let uu____5726 =
      let uu____5731 = FStar_ST.op_Bang record_cache in
      FStar_List.tl uu____5731 in
    FStar_ST.op_Colon_Equals record_cache uu____5726 in
  let peek1 uu____5879 =
    let uu____5880 = FStar_ST.op_Bang record_cache in
    FStar_List.hd uu____5880 in
  let insert r =
    let uu____5959 =
      let uu____5964 = let uu____5967 = peek1 () in r :: uu____5967 in
      let uu____5970 =
        let uu____5975 = FStar_ST.op_Bang record_cache in
        FStar_List.tl uu____5975 in
      uu____5964 :: uu____5970 in
    FStar_ST.op_Colon_Equals record_cache uu____5959 in
  let filter1 uu____6123 =
    let rc = peek1 () in
    let filtered =
      FStar_List.filter
        (fun r  -> Prims.op_Negation r.is_private_or_abstract) rc in
    let uu____6132 =
      let uu____6137 =
        let uu____6142 = FStar_ST.op_Bang record_cache in
        FStar_List.tl uu____6142 in
      filtered :: uu____6137 in
    FStar_ST.op_Colon_Equals record_cache uu____6132 in
  let aux = (push1, pop1, peek1, insert) in (aux, filter1)
let record_cache_aux:
  (Prims.unit -> Prims.unit,Prims.unit -> Prims.unit,Prims.unit ->
                                                       record_or_dc
                                                         Prims.list,record_or_dc
                                                                    ->
                                                                    Prims.unit)
    FStar_Pervasives_Native.tuple4
  =
  let uu____6354 = record_cache_aux_with_filter in
  match uu____6354 with | (aux,uu____6398) -> aux
let filter_record_cache: Prims.unit -> Prims.unit =
  let uu____6441 = record_cache_aux_with_filter in
  match uu____6441 with | (uu____6468,filter1) -> filter1
let push_record_cache: Prims.unit -> Prims.unit =
  let uu____6512 = record_cache_aux in
  match uu____6512 with | (push1,uu____6534,uu____6535,uu____6536) -> push1
let pop_record_cache: Prims.unit -> Prims.unit =
  let uu____6559 = record_cache_aux in
  match uu____6559 with | (uu____6580,pop1,uu____6582,uu____6583) -> pop1
let peek_record_cache: Prims.unit -> record_or_dc Prims.list =
  let uu____6608 = record_cache_aux in
  match uu____6608 with | (uu____6631,uu____6632,peek1,uu____6634) -> peek1
let insert_record_cache: record_or_dc -> Prims.unit =
  let uu____6657 = record_cache_aux in
  match uu____6657 with | (uu____6678,uu____6679,uu____6680,insert) -> insert
let extract_record:
  env ->
    scope_mod Prims.list FStar_ST.ref ->
      FStar_Syntax_Syntax.sigelt -> Prims.unit
  =
  fun e  ->
    fun new_globs  ->
      fun se  ->
        match se.FStar_Syntax_Syntax.sigel with
        | FStar_Syntax_Syntax.Sig_bundle (sigs,uu____6734) ->
            let is_record =
              FStar_Util.for_some
                (fun uu___179_6750  ->
                   match uu___179_6750 with
                   | FStar_Syntax_Syntax.RecordType uu____6751 -> true
                   | FStar_Syntax_Syntax.RecordConstructor uu____6760 -> true
                   | uu____6769 -> false) in
            let find_dc dc =
              FStar_All.pipe_right sigs
                (FStar_Util.find_opt
                   (fun uu___180_6791  ->
                      match uu___180_6791 with
                      | {
                          FStar_Syntax_Syntax.sigel =
                            FStar_Syntax_Syntax.Sig_datacon
                            (lid,uu____6793,uu____6794,uu____6795,uu____6796,uu____6797);
                          FStar_Syntax_Syntax.sigrng = uu____6798;
                          FStar_Syntax_Syntax.sigquals = uu____6799;
                          FStar_Syntax_Syntax.sigmeta = uu____6800;
                          FStar_Syntax_Syntax.sigattrs = uu____6801;_} ->
                          FStar_Ident.lid_equals dc lid
                      | uu____6810 -> false)) in
            FStar_All.pipe_right sigs
              (FStar_List.iter
                 (fun uu___181_6845  ->
                    match uu___181_6845 with
                    | {
                        FStar_Syntax_Syntax.sigel =
                          FStar_Syntax_Syntax.Sig_inductive_typ
                          (typename,univs1,parms,uu____6849,uu____6850,dc::[]);
                        FStar_Syntax_Syntax.sigrng = uu____6852;
                        FStar_Syntax_Syntax.sigquals = typename_quals;
                        FStar_Syntax_Syntax.sigmeta = uu____6854;
                        FStar_Syntax_Syntax.sigattrs = uu____6855;_} ->
                        let uu____6866 =
                          let uu____6867 = find_dc dc in
                          FStar_All.pipe_left FStar_Util.must uu____6867 in
                        (match uu____6866 with
                         | {
                             FStar_Syntax_Syntax.sigel =
                               FStar_Syntax_Syntax.Sig_datacon
                               (constrname,uu____6873,t,uu____6875,uu____6876,uu____6877);
                             FStar_Syntax_Syntax.sigrng = uu____6878;
                             FStar_Syntax_Syntax.sigquals = uu____6879;
                             FStar_Syntax_Syntax.sigmeta = uu____6880;
                             FStar_Syntax_Syntax.sigattrs = uu____6881;_} ->
                             let uu____6890 =
                               FStar_Syntax_Util.arrow_formals t in
                             (match uu____6890 with
                              | (formals,uu____6904) ->
                                  let is_rec = is_record typename_quals in
                                  let formals' =
                                    FStar_All.pipe_right formals
                                      (FStar_List.collect
                                         (fun uu____6953  ->
                                            match uu____6953 with
                                            | (x,q) ->
                                                let uu____6966 =
                                                  (FStar_Syntax_Syntax.is_null_bv
                                                     x)
                                                    ||
                                                    (is_rec &&
                                                       (FStar_Syntax_Syntax.is_implicit
                                                          q)) in
                                                if uu____6966
                                                then []
                                                else [(x, q)])) in
                                  let fields' =
                                    FStar_All.pipe_right formals'
                                      (FStar_List.map
                                         (fun uu____7023  ->
                                            match uu____7023 with
                                            | (x,q) ->
                                                let uu____7036 =
                                                  if is_rec
                                                  then
                                                    FStar_Syntax_Util.unmangle_field_name
                                                      x.FStar_Syntax_Syntax.ppname
                                                  else
                                                    x.FStar_Syntax_Syntax.ppname in
                                                (uu____7036,
                                                  (x.FStar_Syntax_Syntax.sort)))) in
                                  let fields = fields' in
                                  let record =
                                    {
                                      typename;
                                      constrname =
                                        (constrname.FStar_Ident.ident);
                                      parms;
                                      fields;
                                      is_private_or_abstract =
                                        ((FStar_List.contains
                                            FStar_Syntax_Syntax.Private
                                            typename_quals)
                                           ||
                                           (FStar_List.contains
                                              FStar_Syntax_Syntax.Abstract
                                              typename_quals));
                                      is_record = is_rec
                                    } in
                                  ((let uu____7051 =
                                      let uu____7054 =
                                        FStar_ST.op_Bang new_globs in
                                      (Record_or_dc record) :: uu____7054 in
                                    FStar_ST.op_Colon_Equals new_globs
                                      uu____7051);
                                   (match () with
                                    | () ->
                                        ((let add_field uu____7195 =
                                            match uu____7195 with
                                            | (id1,uu____7203) ->
                                                let modul =
                                                  let uu____7209 =
                                                    FStar_Ident.lid_of_ids
                                                      constrname.FStar_Ident.ns in
                                                  uu____7209.FStar_Ident.str in
                                                let uu____7210 =
                                                  get_exported_id_set e modul in
                                                (match uu____7210 with
                                                 | FStar_Pervasives_Native.Some
                                                     my_ex ->
                                                     let my_exported_ids =
                                                       my_ex
                                                         Exported_id_field in
                                                     ((let uu____7237 =
                                                         let uu____7238 =
                                                           FStar_ST.op_Bang
                                                             my_exported_ids in
                                                         FStar_Util.set_add
                                                           id1.FStar_Ident.idText
                                                           uu____7238 in
                                                       FStar_ST.op_Colon_Equals
                                                         my_exported_ids
                                                         uu____7237);
                                                      (match () with
                                                       | () ->
                                                           let projname =
                                                             let uu____7362 =
                                                               let uu____7363
                                                                 =
                                                                 FStar_Syntax_Util.mk_field_projector_name_from_ident
                                                                   constrname
                                                                   id1 in
                                                               uu____7363.FStar_Ident.ident in
                                                             uu____7362.FStar_Ident.idText in
                                                           let uu____7365 =
                                                             let uu____7366 =
                                                               FStar_ST.op_Bang
                                                                 my_exported_ids in
                                                             FStar_Util.set_add
                                                               projname
                                                               uu____7366 in
                                                           FStar_ST.op_Colon_Equals
                                                             my_exported_ids
                                                             uu____7365))
                                                 | FStar_Pervasives_Native.None
                                                      -> ()) in
                                          FStar_List.iter add_field fields');
                                         (match () with
                                          | () -> insert_record_cache record)))))
                         | uu____7499 -> ())
                    | uu____7500 -> ()))
        | uu____7501 -> ()
let try_lookup_record_or_dc_by_field_name:
  env -> FStar_Ident.lident -> record_or_dc FStar_Pervasives_Native.option =
  fun env  ->
    fun fieldname  ->
      let find_in_cache fieldname1 =
        let uu____7516 =
          ((fieldname1.FStar_Ident.ns), (fieldname1.FStar_Ident.ident)) in
        match uu____7516 with
        | (ns,id1) ->
            let uu____7533 = peek_record_cache () in
            FStar_Util.find_map uu____7533
              (fun record  ->
                 let uu____7539 =
                   find_in_record ns id1 record (fun r  -> Cont_ok r) in
                 option_of_cont
                   (fun uu____7545  -> FStar_Pervasives_Native.None)
                   uu____7539) in
      resolve_in_open_namespaces'' env fieldname Exported_id_field
        (fun uu____7547  -> Cont_ignore) (fun uu____7549  -> Cont_ignore)
        (fun r  -> Cont_ok r)
        (fun fn  ->
           let uu____7555 = find_in_cache fn in
           cont_of_option Cont_ignore uu____7555)
        (fun k  -> fun uu____7561  -> k)
let try_lookup_record_by_field_name:
  env -> FStar_Ident.lident -> record_or_dc FStar_Pervasives_Native.option =
  fun env  ->
    fun fieldname  ->
      let uu____7572 = try_lookup_record_or_dc_by_field_name env fieldname in
      match uu____7572 with
      | FStar_Pervasives_Native.Some r when r.is_record ->
          FStar_Pervasives_Native.Some r
      | uu____7578 -> FStar_Pervasives_Native.None
let belongs_to_record:
  env -> FStar_Ident.lident -> record_or_dc -> Prims.bool =
  fun env  ->
    fun lid  ->
      fun record  ->
        let uu____7590 = try_lookup_record_by_field_name env lid in
        match uu____7590 with
        | FStar_Pervasives_Native.Some record' when
            let uu____7594 =
              let uu____7595 =
                FStar_Ident.path_of_ns (record.typename).FStar_Ident.ns in
              FStar_Ident.text_of_path uu____7595 in
            let uu____7598 =
              let uu____7599 =
                FStar_Ident.path_of_ns (record'.typename).FStar_Ident.ns in
              FStar_Ident.text_of_path uu____7599 in
            uu____7594 = uu____7598 ->
            let uu____7602 =
              find_in_record (record.typename).FStar_Ident.ns
                lid.FStar_Ident.ident record (fun uu____7606  -> Cont_ok ()) in
            (match uu____7602 with
             | Cont_ok uu____7607 -> true
             | uu____7608 -> false)
        | uu____7611 -> false
let try_lookup_dc_by_field_name:
  env ->
    FStar_Ident.lident ->
      (FStar_Ident.lident,Prims.bool) FStar_Pervasives_Native.tuple2
        FStar_Pervasives_Native.option
  =
  fun env  ->
    fun fieldname  ->
      let uu____7626 = try_lookup_record_or_dc_by_field_name env fieldname in
      match uu____7626 with
      | FStar_Pervasives_Native.Some r ->
          let uu____7636 =
            let uu____7641 =
              let uu____7642 =
                FStar_Ident.lid_of_ids
                  (FStar_List.append (r.typename).FStar_Ident.ns
                     [r.constrname]) in
              FStar_Ident.set_lid_range uu____7642
                (FStar_Ident.range_of_lid fieldname) in
            (uu____7641, (r.is_record)) in
          FStar_Pervasives_Native.Some uu____7636
      | uu____7647 -> FStar_Pervasives_Native.None
let string_set_ref_new:
  Prims.unit -> Prims.string FStar_Util.set FStar_ST.ref =
  fun uu____7667  ->
    let uu____7668 = FStar_Util.new_set FStar_Util.compare in
    FStar_Util.mk_ref uu____7668
let exported_id_set_new:
  Prims.unit -> exported_id_kind -> Prims.string FStar_Util.set FStar_ST.ref
  =
  fun uu____7688  ->
    let term_type_set = string_set_ref_new () in
    let field_set = string_set_ref_new () in
    fun uu___182_7699  ->
      match uu___182_7699 with
      | Exported_id_term_type  -> term_type_set
      | Exported_id_field  -> field_set
let unique:
  Prims.bool -> Prims.bool -> env -> FStar_Ident.lident -> Prims.bool =
  fun any_val  ->
    fun exclude_interface  ->
      fun env  ->
        fun lid  ->
          let filter_scope_mods uu___183_7733 =
            match uu___183_7733 with
            | Rec_binding uu____7734 -> true
            | uu____7735 -> false in
          let this_env =
            let uu___197_7737 = env in
            let uu____7738 =
              FStar_List.filter filter_scope_mods env.scope_mods in
            {
              curmodule = (uu___197_7737.curmodule);
              curmonad = (uu___197_7737.curmonad);
              modules = (uu___197_7737.modules);
              scope_mods = uu____7738;
              exported_ids = empty_exported_id_smap;
              trans_exported_ids = (uu___197_7737.trans_exported_ids);
              includes = empty_include_smap;
              sigaccum = (uu___197_7737.sigaccum);
              sigmap = (uu___197_7737.sigmap);
              iface = (uu___197_7737.iface);
              admitted_iface = (uu___197_7737.admitted_iface);
              expect_typ = (uu___197_7737.expect_typ);
              docs = (uu___197_7737.docs);
              remaining_iface_decls = (uu___197_7737.remaining_iface_decls);
              syntax_only = (uu___197_7737.syntax_only);
              ds_hooks = (uu___197_7737.ds_hooks)
            } in
          let uu____7741 =
            try_lookup_lid' any_val exclude_interface this_env lid in
          match uu____7741 with
          | FStar_Pervasives_Native.None  -> true
          | FStar_Pervasives_Native.Some uu____7752 -> false
let push_scope_mod: env -> scope_mod -> env =
  fun env  ->
    fun scope_mod  ->
      let uu___198_7767 = env in
      {
        curmodule = (uu___198_7767.curmodule);
        curmonad = (uu___198_7767.curmonad);
        modules = (uu___198_7767.modules);
        scope_mods = (scope_mod :: (env.scope_mods));
        exported_ids = (uu___198_7767.exported_ids);
        trans_exported_ids = (uu___198_7767.trans_exported_ids);
        includes = (uu___198_7767.includes);
        sigaccum = (uu___198_7767.sigaccum);
        sigmap = (uu___198_7767.sigmap);
        iface = (uu___198_7767.iface);
        admitted_iface = (uu___198_7767.admitted_iface);
        expect_typ = (uu___198_7767.expect_typ);
        docs = (uu___198_7767.docs);
        remaining_iface_decls = (uu___198_7767.remaining_iface_decls);
        syntax_only = (uu___198_7767.syntax_only);
        ds_hooks = (uu___198_7767.ds_hooks)
      }
let push_bv':
  env ->
    FStar_Ident.ident ->
      Prims.bool ->
        (env,FStar_Syntax_Syntax.bv) FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun x  ->
      fun is_mutable  ->
        let bv =
          FStar_Syntax_Syntax.gen_bv x.FStar_Ident.idText
            (FStar_Pervasives_Native.Some (x.FStar_Ident.idRange))
            FStar_Syntax_Syntax.tun in
        ((push_scope_mod env (Local_binding (x, bv, is_mutable))), bv)
let push_bv_mutable:
  env ->
    FStar_Ident.ident ->
      (env,FStar_Syntax_Syntax.bv) FStar_Pervasives_Native.tuple2
  = fun env  -> fun x  -> push_bv' env x true
let push_bv:
  env ->
    FStar_Ident.ident ->
      (env,FStar_Syntax_Syntax.bv) FStar_Pervasives_Native.tuple2
  = fun env  -> fun x  -> push_bv' env x false
let push_top_level_rec_binding:
  env -> FStar_Ident.ident -> FStar_Syntax_Syntax.delta_depth -> env =
  fun env  ->
    fun x  ->
      fun dd  ->
        let l = qualify env x in
        let uu____7812 =
          (unique false true env l) || (FStar_Options.interactive ()) in
        if uu____7812
        then push_scope_mod env (Rec_binding (x, l, dd))
        else
          FStar_Errors.raise_error
            (FStar_Errors.Fatal_DuplicateTopLevelNames,
              (Prims.strcat "Duplicate top-level names " l.FStar_Ident.str))
            (FStar_Ident.range_of_lid l)
let push_sigelt: env -> FStar_Syntax_Syntax.sigelt -> env =
  fun env  ->
    fun s  ->
      let err l =
        let sopt = FStar_Util.smap_try_find (sigmap env) l.FStar_Ident.str in
        let r =
          match sopt with
          | FStar_Pervasives_Native.Some (se,uu____7837) ->
              let uu____7842 =
                FStar_Util.find_opt (FStar_Ident.lid_equals l)
                  (FStar_Syntax_Util.lids_of_sigelt se) in
              (match uu____7842 with
               | FStar_Pervasives_Native.Some l1 ->
                   FStar_All.pipe_left FStar_Range.string_of_range
                     (FStar_Ident.range_of_lid l1)
               | FStar_Pervasives_Native.None  -> "<unknown>")
          | FStar_Pervasives_Native.None  -> "<unknown>" in
        let uu____7850 =
          let uu____7855 =
            FStar_Util.format2
              "Duplicate top-level names [%s]; previously declared at %s"
              (FStar_Ident.text_of_lid l) r in
          (FStar_Errors.Fatal_DuplicateTopLevelNames, uu____7855) in
        FStar_Errors.raise_error uu____7850 (FStar_Ident.range_of_lid l) in
      let globals = FStar_Util.mk_ref env.scope_mods in
      let env1 =
        let uu____7864 =
          match s.FStar_Syntax_Syntax.sigel with
          | FStar_Syntax_Syntax.Sig_let uu____7873 -> (false, true)
          | FStar_Syntax_Syntax.Sig_bundle uu____7880 -> (false, true)
          | uu____7889 -> (false, false) in
        match uu____7864 with
        | (any_val,exclude_interface) ->
            let lids = FStar_Syntax_Util.lids_of_sigelt s in
            let uu____7895 =
              FStar_Util.find_map lids
                (fun l  ->
                   let uu____7901 =
                     let uu____7902 = unique any_val exclude_interface env l in
                     Prims.op_Negation uu____7902 in
                   if uu____7901
                   then FStar_Pervasives_Native.Some l
                   else FStar_Pervasives_Native.None) in
            (match uu____7895 with
             | FStar_Pervasives_Native.Some l -> err l
             | uu____7907 ->
                 (extract_record env globals s;
                  (let uu___199_7925 = env in
                   {
                     curmodule = (uu___199_7925.curmodule);
                     curmonad = (uu___199_7925.curmonad);
                     modules = (uu___199_7925.modules);
                     scope_mods = (uu___199_7925.scope_mods);
                     exported_ids = (uu___199_7925.exported_ids);
                     trans_exported_ids = (uu___199_7925.trans_exported_ids);
                     includes = (uu___199_7925.includes);
                     sigaccum = (s :: (env.sigaccum));
                     sigmap = (uu___199_7925.sigmap);
                     iface = (uu___199_7925.iface);
                     admitted_iface = (uu___199_7925.admitted_iface);
                     expect_typ = (uu___199_7925.expect_typ);
                     docs = (uu___199_7925.docs);
                     remaining_iface_decls =
                       (uu___199_7925.remaining_iface_decls);
                     syntax_only = (uu___199_7925.syntax_only);
                     ds_hooks = (uu___199_7925.ds_hooks)
                   }))) in
      let env2 =
        let uu___200_7927 = env1 in
        let uu____7928 = FStar_ST.op_Bang globals in
        {
          curmodule = (uu___200_7927.curmodule);
          curmonad = (uu___200_7927.curmonad);
          modules = (uu___200_7927.modules);
          scope_mods = uu____7928;
          exported_ids = (uu___200_7927.exported_ids);
          trans_exported_ids = (uu___200_7927.trans_exported_ids);
          includes = (uu___200_7927.includes);
          sigaccum = (uu___200_7927.sigaccum);
          sigmap = (uu___200_7927.sigmap);
          iface = (uu___200_7927.iface);
          admitted_iface = (uu___200_7927.admitted_iface);
          expect_typ = (uu___200_7927.expect_typ);
          docs = (uu___200_7927.docs);
          remaining_iface_decls = (uu___200_7927.remaining_iface_decls);
          syntax_only = (uu___200_7927.syntax_only);
          ds_hooks = (uu___200_7927.ds_hooks)
        } in
      let uu____7995 =
        match s.FStar_Syntax_Syntax.sigel with
        | FStar_Syntax_Syntax.Sig_bundle (ses,uu____8021) ->
            let uu____8030 =
              FStar_List.map
                (fun se  -> ((FStar_Syntax_Util.lids_of_sigelt se), se)) ses in
            (env2, uu____8030)
        | uu____8057 -> (env2, [((FStar_Syntax_Util.lids_of_sigelt s), s)]) in
      match uu____7995 with
      | (env3,lss) ->
          (FStar_All.pipe_right lss
             (FStar_List.iter
                (fun uu____8116  ->
                   match uu____8116 with
                   | (lids,se) ->
                       FStar_All.pipe_right lids
                         (FStar_List.iter
                            (fun lid  ->
                               (let uu____8138 =
                                  let uu____8141 = FStar_ST.op_Bang globals in
                                  (Top_level_def (lid.FStar_Ident.ident)) ::
                                    uu____8141 in
                                FStar_ST.op_Colon_Equals globals uu____8138);
                               (match () with
                                | () ->
                                    let modul =
                                      let uu____8273 =
                                        FStar_Ident.lid_of_ids
                                          lid.FStar_Ident.ns in
                                      uu____8273.FStar_Ident.str in
                                    ((let uu____8275 =
                                        get_exported_id_set env3 modul in
                                      match uu____8275 with
                                      | FStar_Pervasives_Native.Some f ->
                                          let my_exported_ids =
                                            f Exported_id_term_type in
                                          let uu____8301 =
                                            let uu____8302 =
                                              FStar_ST.op_Bang
                                                my_exported_ids in
                                            FStar_Util.set_add
                                              (lid.FStar_Ident.ident).FStar_Ident.idText
                                              uu____8302 in
                                          FStar_ST.op_Colon_Equals
                                            my_exported_ids uu____8301
                                      | FStar_Pervasives_Native.None  -> ());
                                     (match () with
                                      | () ->
                                          let is_iface =
                                            env3.iface &&
                                              (Prims.op_Negation
                                                 env3.admitted_iface) in
                                          FStar_Util.smap_add (sigmap env3)
                                            lid.FStar_Ident.str
                                            (se,
                                              (env3.iface &&
                                                 (Prims.op_Negation
                                                    env3.admitted_iface))))))))));
           (let env4 =
              let uu___201_8435 = env3 in
              let uu____8436 = FStar_ST.op_Bang globals in
              {
                curmodule = (uu___201_8435.curmodule);
                curmonad = (uu___201_8435.curmonad);
                modules = (uu___201_8435.modules);
                scope_mods = uu____8436;
                exported_ids = (uu___201_8435.exported_ids);
                trans_exported_ids = (uu___201_8435.trans_exported_ids);
                includes = (uu___201_8435.includes);
                sigaccum = (uu___201_8435.sigaccum);
                sigmap = (uu___201_8435.sigmap);
                iface = (uu___201_8435.iface);
                admitted_iface = (uu___201_8435.admitted_iface);
                expect_typ = (uu___201_8435.expect_typ);
                docs = (uu___201_8435.docs);
                remaining_iface_decls = (uu___201_8435.remaining_iface_decls);
                syntax_only = (uu___201_8435.syntax_only);
                ds_hooks = (uu___201_8435.ds_hooks)
              } in
            env4))
let push_namespace: env -> FStar_Ident.lident -> env =
  fun env  ->
    fun ns  ->
      let uu____8509 =
        let uu____8514 = resolve_module_name env ns false in
        match uu____8514 with
        | FStar_Pervasives_Native.None  ->
            let modules = env.modules in
            let uu____8528 =
              FStar_All.pipe_right modules
                (FStar_Util.for_some
                   (fun uu____8542  ->
                      match uu____8542 with
                      | (m,uu____8548) ->
                          FStar_Util.starts_with
                            (Prims.strcat (FStar_Ident.text_of_lid m) ".")
                            (Prims.strcat (FStar_Ident.text_of_lid ns) "."))) in
            if uu____8528
            then (ns, Open_namespace)
            else
              (let uu____8554 =
                 let uu____8559 =
                   FStar_Util.format1 "Namespace %s cannot be found"
                     (FStar_Ident.text_of_lid ns) in
                 (FStar_Errors.Fatal_NameSpaceNotFound, uu____8559) in
               FStar_Errors.raise_error uu____8554
                 (FStar_Ident.range_of_lid ns))
        | FStar_Pervasives_Native.Some ns' ->
            (fail_if_curmodule env ns ns'; (ns', Open_module)) in
      match uu____8509 with
      | (ns',kd) ->
          ((env.ds_hooks).ds_push_open_hook env (ns', kd);
           push_scope_mod env (Open_module_or_namespace (ns', kd)))
let push_include: env -> FStar_Ident.lident -> env =
  fun env  ->
    fun ns  ->
      let ns0 = ns in
      let uu____8576 = resolve_module_name env ns false in
      match uu____8576 with
      | FStar_Pervasives_Native.Some ns1 ->
          ((env.ds_hooks).ds_push_include_hook env ns1;
           fail_if_curmodule env ns0 ns1;
           (let env1 =
              push_scope_mod env
                (Open_module_or_namespace (ns1, Open_module)) in
            let curmod =
              let uu____8584 = current_module env1 in
              uu____8584.FStar_Ident.str in
            (let uu____8586 = FStar_Util.smap_try_find env1.includes curmod in
             match uu____8586 with
             | FStar_Pervasives_Native.None  -> ()
             | FStar_Pervasives_Native.Some incl ->
                 let uu____8610 =
                   let uu____8613 = FStar_ST.op_Bang incl in ns1 ::
                     uu____8613 in
                 FStar_ST.op_Colon_Equals incl uu____8610);
            (match () with
             | () ->
                 let uu____8744 =
                   get_trans_exported_id_set env1 ns1.FStar_Ident.str in
                 (match uu____8744 with
                  | FStar_Pervasives_Native.Some ns_trans_exports ->
                      ((let uu____8761 =
                          let uu____8778 = get_exported_id_set env1 curmod in
                          let uu____8785 =
                            get_trans_exported_id_set env1 curmod in
                          (uu____8778, uu____8785) in
                        match uu____8761 with
                        | (FStar_Pervasives_Native.Some
                           cur_exports,FStar_Pervasives_Native.Some
                           cur_trans_exports) ->
                            let update_exports k =
                              let ns_ex =
                                let uu____8839 = ns_trans_exports k in
                                FStar_ST.op_Bang uu____8839 in
                              let ex = cur_exports k in
                              (let uu____9094 =
                                 let uu____9095 = FStar_ST.op_Bang ex in
                                 FStar_Util.set_difference uu____9095 ns_ex in
                               FStar_ST.op_Colon_Equals ex uu____9094);
                              (match () with
                               | () ->
                                   let trans_ex = cur_trans_exports k in
                                   let uu____9229 =
                                     let uu____9230 =
                                       FStar_ST.op_Bang trans_ex in
                                     FStar_Util.set_union uu____9230 ns_ex in
                                   FStar_ST.op_Colon_Equals trans_ex
                                     uu____9229) in
                            FStar_List.iter update_exports
                              all_exported_id_kinds
                        | uu____9353 -> ());
                       (match () with | () -> env1))
                  | FStar_Pervasives_Native.None  ->
                      let uu____9374 =
                        let uu____9379 =
                          FStar_Util.format1
                            "include: Module %s was not prepared"
                            ns1.FStar_Ident.str in
                        (FStar_Errors.Fatal_IncludeModuleNotPrepared,
                          uu____9379) in
                      FStar_Errors.raise_error uu____9374
                        (FStar_Ident.range_of_lid ns1)))))
      | uu____9380 ->
          let uu____9383 =
            let uu____9388 =
              FStar_Util.format1 "include: Module %s cannot be found"
                ns.FStar_Ident.str in
            (FStar_Errors.Fatal_ModuleNotFound, uu____9388) in
          FStar_Errors.raise_error uu____9383 (FStar_Ident.range_of_lid ns)
let push_module_abbrev: env -> FStar_Ident.ident -> FStar_Ident.lident -> env
  =
  fun env  ->
    fun x  ->
      fun l  ->
        let uu____9398 = module_is_defined env l in
        if uu____9398
        then
          (fail_if_curmodule env l l;
           (env.ds_hooks).ds_push_module_abbrev_hook env x l;
           push_scope_mod env (Module_abbrev (x, l)))
        else
          (let uu____9402 =
             let uu____9407 =
               FStar_Util.format1 "Module %s cannot be found"
                 (FStar_Ident.text_of_lid l) in
             (FStar_Errors.Fatal_ModuleNotFound, uu____9407) in
           FStar_Errors.raise_error uu____9402 (FStar_Ident.range_of_lid l))
let push_doc:
  env ->
    FStar_Ident.lident ->
      FStar_Parser_AST.fsdoc FStar_Pervasives_Native.option -> env
  =
  fun env  ->
    fun l  ->
      fun doc_opt  ->
        match doc_opt with
        | FStar_Pervasives_Native.None  -> env
        | FStar_Pervasives_Native.Some doc1 ->
            ((let uu____9423 =
                FStar_Util.smap_try_find env.docs l.FStar_Ident.str in
              match uu____9423 with
              | FStar_Pervasives_Native.None  -> ()
              | FStar_Pervasives_Native.Some old_doc ->
                  let uu____9427 =
                    let uu____9432 =
                      let uu____9433 = FStar_Ident.string_of_lid l in
                      let uu____9434 =
                        FStar_Parser_AST.string_of_fsdoc old_doc in
                      let uu____9435 = FStar_Parser_AST.string_of_fsdoc doc1 in
                      FStar_Util.format3
                        "Overwriting doc of %s; old doc was [%s]; new doc are [%s]"
                        uu____9433 uu____9434 uu____9435 in
                    (FStar_Errors.Warning_DocOverwrite, uu____9432) in
                  FStar_Errors.log_issue (FStar_Ident.range_of_lid l)
                    uu____9427);
             FStar_Util.smap_add env.docs l.FStar_Ident.str doc1;
             env)
let check_admits: env -> Prims.unit =
  fun env  ->
    FStar_All.pipe_right env.sigaccum
      (FStar_List.iter
         (fun se  ->
            match se.FStar_Syntax_Syntax.sigel with
            | FStar_Syntax_Syntax.Sig_declare_typ (l,u,t) ->
                let uu____9451 = try_lookup_lid env l in
                (match uu____9451 with
                 | FStar_Pervasives_Native.None  ->
                     ((let uu____9463 =
                         let uu____9464 = FStar_Options.interactive () in
                         Prims.op_Negation uu____9464 in
                       if uu____9463
                       then
                         let uu____9465 =
                           let uu____9470 =
                             let uu____9471 =
                               FStar_Syntax_Print.lid_to_string l in
                             FStar_Util.format1
                               "Admitting %s without a definition" uu____9471 in
                           (FStar_Errors.Warning_AdmitWithoutDefinition,
                             uu____9470) in
                         FStar_Errors.log_issue (FStar_Ident.range_of_lid l)
                           uu____9465
                       else ());
                      (let quals = FStar_Syntax_Syntax.Assumption ::
                         (se.FStar_Syntax_Syntax.sigquals) in
                       FStar_Util.smap_add (sigmap env) l.FStar_Ident.str
                         ((let uu___202_9481 = se in
                           {
                             FStar_Syntax_Syntax.sigel =
                               (uu___202_9481.FStar_Syntax_Syntax.sigel);
                             FStar_Syntax_Syntax.sigrng =
                               (uu___202_9481.FStar_Syntax_Syntax.sigrng);
                             FStar_Syntax_Syntax.sigquals = quals;
                             FStar_Syntax_Syntax.sigmeta =
                               (uu___202_9481.FStar_Syntax_Syntax.sigmeta);
                             FStar_Syntax_Syntax.sigattrs =
                               (uu___202_9481.FStar_Syntax_Syntax.sigattrs)
                           }), false)))
                 | FStar_Pervasives_Native.Some uu____9482 -> ())
            | uu____9491 -> ()))
let finish: env -> FStar_Syntax_Syntax.modul -> env =
  fun env  ->
    fun modul  ->
      FStar_All.pipe_right modul.FStar_Syntax_Syntax.declarations
        (FStar_List.iter
           (fun se  ->
              let quals = se.FStar_Syntax_Syntax.sigquals in
              match se.FStar_Syntax_Syntax.sigel with
              | FStar_Syntax_Syntax.Sig_bundle (ses,uu____9508) ->
                  if
                    (FStar_List.contains FStar_Syntax_Syntax.Private quals)
                      ||
                      (FStar_List.contains FStar_Syntax_Syntax.Abstract quals)
                  then
                    FStar_All.pipe_right ses
                      (FStar_List.iter
                         (fun se1  ->
                            match se1.FStar_Syntax_Syntax.sigel with
                            | FStar_Syntax_Syntax.Sig_datacon
                                (lid,uu____9528,uu____9529,uu____9530,uu____9531,uu____9532)
                                ->
                                FStar_Util.smap_remove (sigmap env)
                                  lid.FStar_Ident.str
                            | uu____9541 -> ()))
                  else ()
              | FStar_Syntax_Syntax.Sig_declare_typ
                  (lid,uu____9544,uu____9545) ->
                  if FStar_List.contains FStar_Syntax_Syntax.Private quals
                  then
                    FStar_Util.smap_remove (sigmap env) lid.FStar_Ident.str
                  else ()
              | FStar_Syntax_Syntax.Sig_let ((uu____9551,lbs),uu____9553) ->
                  (if
                     (FStar_List.contains FStar_Syntax_Syntax.Private quals)
                       ||
                       (FStar_List.contains FStar_Syntax_Syntax.Abstract
                          quals)
                   then
                     FStar_All.pipe_right lbs
                       (FStar_List.iter
                          (fun lb  ->
                             let uu____9574 =
                               let uu____9575 =
                                 let uu____9576 =
                                   let uu____9579 =
                                     FStar_Util.right
                                       lb.FStar_Syntax_Syntax.lbname in
                                   uu____9579.FStar_Syntax_Syntax.fv_name in
                                 uu____9576.FStar_Syntax_Syntax.v in
                               uu____9575.FStar_Ident.str in
                             FStar_Util.smap_remove (sigmap env) uu____9574))
                   else ();
                   if
                     (FStar_List.contains FStar_Syntax_Syntax.Abstract quals)
                       &&
                       (Prims.op_Negation
                          (FStar_List.contains FStar_Syntax_Syntax.Private
                             quals))
                   then
                     FStar_All.pipe_right lbs
                       (FStar_List.iter
                          (fun lb  ->
                             let lid =
                               let uu____9593 =
                                 let uu____9596 =
                                   FStar_Util.right
                                     lb.FStar_Syntax_Syntax.lbname in
                                 uu____9596.FStar_Syntax_Syntax.fv_name in
                               uu____9593.FStar_Syntax_Syntax.v in
                             let quals1 = FStar_Syntax_Syntax.Assumption ::
                               quals in
                             let decl =
                               let uu___203_9601 = se in
                               {
                                 FStar_Syntax_Syntax.sigel =
                                   (FStar_Syntax_Syntax.Sig_declare_typ
                                      (lid, (lb.FStar_Syntax_Syntax.lbunivs),
                                        (lb.FStar_Syntax_Syntax.lbtyp)));
                                 FStar_Syntax_Syntax.sigrng =
                                   (uu___203_9601.FStar_Syntax_Syntax.sigrng);
                                 FStar_Syntax_Syntax.sigquals = quals1;
                                 FStar_Syntax_Syntax.sigmeta =
                                   (uu___203_9601.FStar_Syntax_Syntax.sigmeta);
                                 FStar_Syntax_Syntax.sigattrs =
                                   (uu___203_9601.FStar_Syntax_Syntax.sigattrs)
                               } in
                             FStar_Util.smap_add (sigmap env)
                               lid.FStar_Ident.str (decl, false)))
                   else ())
              | uu____9611 -> ()));
      (let curmod =
         let uu____9613 = current_module env in uu____9613.FStar_Ident.str in
       (let uu____9615 =
          let uu____9632 = get_exported_id_set env curmod in
          let uu____9639 = get_trans_exported_id_set env curmod in
          (uu____9632, uu____9639) in
        match uu____9615 with
        | (FStar_Pervasives_Native.Some cur_ex,FStar_Pervasives_Native.Some
           cur_trans_ex) ->
            let update_exports eikind =
              let cur_ex_set =
                let uu____9693 = cur_ex eikind in FStar_ST.op_Bang uu____9693 in
              let cur_trans_ex_set_ref = cur_trans_ex eikind in
              let uu____9947 =
                let uu____9948 = FStar_ST.op_Bang cur_trans_ex_set_ref in
                FStar_Util.set_union cur_ex_set uu____9948 in
              FStar_ST.op_Colon_Equals cur_trans_ex_set_ref uu____9947 in
            FStar_List.iter update_exports all_exported_id_kinds
        | uu____10071 -> ());
       (match () with
        | () ->
            (filter_record_cache ();
             (match () with
              | () ->
                  let uu___204_10089 = env in
                  {
                    curmodule = FStar_Pervasives_Native.None;
                    curmonad = (uu___204_10089.curmonad);
                    modules = (((modul.FStar_Syntax_Syntax.name), modul) ::
                      (env.modules));
                    scope_mods = [];
                    exported_ids = (uu___204_10089.exported_ids);
                    trans_exported_ids = (uu___204_10089.trans_exported_ids);
                    includes = (uu___204_10089.includes);
                    sigaccum = [];
                    sigmap = (uu___204_10089.sigmap);
                    iface = (uu___204_10089.iface);
                    admitted_iface = (uu___204_10089.admitted_iface);
                    expect_typ = (uu___204_10089.expect_typ);
                    docs = (uu___204_10089.docs);
                    remaining_iface_decls =
                      (uu___204_10089.remaining_iface_decls);
                    syntax_only = (uu___204_10089.syntax_only);
                    ds_hooks = (uu___204_10089.ds_hooks)
                  }))))
let stack: env Prims.list FStar_ST.ref = FStar_Util.mk_ref []
let push: env -> env =
  fun env  ->
    push_record_cache ();
    (let uu____10112 =
       let uu____10115 = FStar_ST.op_Bang stack in env :: uu____10115 in
     FStar_ST.op_Colon_Equals stack uu____10112);
    (let uu___205_10218 = env in
     let uu____10219 = FStar_Util.smap_copy (sigmap env) in
     let uu____10230 = FStar_Util.smap_copy env.docs in
     {
       curmodule = (uu___205_10218.curmodule);
       curmonad = (uu___205_10218.curmonad);
       modules = (uu___205_10218.modules);
       scope_mods = (uu___205_10218.scope_mods);
       exported_ids = (uu___205_10218.exported_ids);
       trans_exported_ids = (uu___205_10218.trans_exported_ids);
       includes = (uu___205_10218.includes);
       sigaccum = (uu___205_10218.sigaccum);
       sigmap = uu____10219;
       iface = (uu___205_10218.iface);
       admitted_iface = (uu___205_10218.admitted_iface);
       expect_typ = (uu___205_10218.expect_typ);
       docs = uu____10230;
       remaining_iface_decls = (uu___205_10218.remaining_iface_decls);
       syntax_only = (uu___205_10218.syntax_only);
       ds_hooks = (uu___205_10218.ds_hooks)
     })
let pop: Prims.unit -> env =
  fun uu____10235  ->
    let uu____10236 = FStar_ST.op_Bang stack in
    match uu____10236 with
    | env::tl1 ->
        (pop_record_cache (); FStar_ST.op_Colon_Equals stack tl1; env)
    | uu____10345 -> failwith "Impossible: Too many pops"
let export_interface: FStar_Ident.lident -> env -> env =
  fun m  ->
    fun env  ->
      let sigelt_in_m se =
        match FStar_Syntax_Util.lids_of_sigelt se with
        | l::uu____10359 -> l.FStar_Ident.nsstr = m.FStar_Ident.str
        | uu____10362 -> false in
      let sm = sigmap env in
      let env1 = pop () in
      let keys = FStar_Util.smap_keys sm in
      let sm' = sigmap env1 in
      FStar_All.pipe_right keys
        (FStar_List.iter
           (fun k  ->
              let uu____10396 = FStar_Util.smap_try_find sm' k in
              match uu____10396 with
              | FStar_Pervasives_Native.Some (se,true ) when sigelt_in_m se
                  ->
                  (FStar_Util.smap_remove sm' k;
                   (let se1 =
                      match se.FStar_Syntax_Syntax.sigel with
                      | FStar_Syntax_Syntax.Sig_declare_typ (l,u,t) ->
                          let uu___206_10421 = se in
                          {
                            FStar_Syntax_Syntax.sigel =
                              (uu___206_10421.FStar_Syntax_Syntax.sigel);
                            FStar_Syntax_Syntax.sigrng =
                              (uu___206_10421.FStar_Syntax_Syntax.sigrng);
                            FStar_Syntax_Syntax.sigquals =
                              (FStar_Syntax_Syntax.Assumption ::
                              (se.FStar_Syntax_Syntax.sigquals));
                            FStar_Syntax_Syntax.sigmeta =
                              (uu___206_10421.FStar_Syntax_Syntax.sigmeta);
                            FStar_Syntax_Syntax.sigattrs =
                              (uu___206_10421.FStar_Syntax_Syntax.sigattrs)
                          }
                      | uu____10422 -> se in
                    FStar_Util.smap_add sm' k (se1, false)))
              | uu____10427 -> ()));
      env1
let finish_module_or_interface: env -> FStar_Syntax_Syntax.modul -> env =
  fun env  ->
    fun modul  ->
      if Prims.op_Negation modul.FStar_Syntax_Syntax.is_interface
      then check_admits env
      else ();
      finish env modul
type exported_ids =
  {
  exported_id_terms: Prims.string Prims.list;
  exported_id_fields: Prims.string Prims.list;}[@@deriving show]
let __proj__Mkexported_ids__item__exported_id_terms:
  exported_ids -> Prims.string Prims.list =
  fun projectee  ->
    match projectee with
    | { exported_id_terms = __fname__exported_id_terms;
        exported_id_fields = __fname__exported_id_fields;_} ->
        __fname__exported_id_terms
let __proj__Mkexported_ids__item__exported_id_fields:
  exported_ids -> Prims.string Prims.list =
  fun projectee  ->
    match projectee with
    | { exported_id_terms = __fname__exported_id_terms;
        exported_id_fields = __fname__exported_id_fields;_} ->
        __fname__exported_id_fields
let as_exported_ids: exported_id_set -> exported_ids =
  fun e  ->
    let terms =
      let uu____10507 =
        let uu____10510 = e Exported_id_term_type in
        FStar_ST.op_Bang uu____10510 in
      FStar_Util.set_elements uu____10507 in
    let fields =
      let uu____10757 =
        let uu____10760 = e Exported_id_field in FStar_ST.op_Bang uu____10760 in
      FStar_Util.set_elements uu____10757 in
    { exported_id_terms = terms; exported_id_fields = fields }
let as_exported_id_set:
  exported_ids FStar_Pervasives_Native.option ->
    exported_id_kind -> Prims.string FStar_Util.set FStar_ST.ref
  =
  fun e  ->
    match e with
    | FStar_Pervasives_Native.None  -> exported_id_set_new ()
    | FStar_Pervasives_Native.Some e1 ->
        let terms =
          let uu____11036 =
            FStar_Util.as_set e1.exported_id_terms FStar_Util.compare in
          FStar_Util.mk_ref uu____11036 in
        let fields =
          let uu____11046 =
            FStar_Util.as_set e1.exported_id_fields FStar_Util.compare in
          FStar_Util.mk_ref uu____11046 in
        (fun uu___184_11051  ->
           match uu___184_11051 with
           | Exported_id_term_type  -> terms
           | Exported_id_field  -> fields)
type module_inclusion_info =
  {
  mii_exported_ids: exported_ids FStar_Pervasives_Native.option;
  mii_trans_exported_ids: exported_ids FStar_Pervasives_Native.option;
  mii_includes: FStar_Ident.lident Prims.list FStar_Pervasives_Native.option;}
[@@deriving show]
let __proj__Mkmodule_inclusion_info__item__mii_exported_ids:
  module_inclusion_info -> exported_ids FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { mii_exported_ids = __fname__mii_exported_ids;
        mii_trans_exported_ids = __fname__mii_trans_exported_ids;
        mii_includes = __fname__mii_includes;_} -> __fname__mii_exported_ids
let __proj__Mkmodule_inclusion_info__item__mii_trans_exported_ids:
  module_inclusion_info -> exported_ids FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { mii_exported_ids = __fname__mii_exported_ids;
        mii_trans_exported_ids = __fname__mii_trans_exported_ids;
        mii_includes = __fname__mii_includes;_} ->
        __fname__mii_trans_exported_ids
let __proj__Mkmodule_inclusion_info__item__mii_includes:
  module_inclusion_info ->
    FStar_Ident.lident Prims.list FStar_Pervasives_Native.option
  =
  fun projectee  ->
    match projectee with
    | { mii_exported_ids = __fname__mii_exported_ids;
        mii_trans_exported_ids = __fname__mii_trans_exported_ids;
        mii_includes = __fname__mii_includes;_} -> __fname__mii_includes
let default_mii: module_inclusion_info =
  {
    mii_exported_ids = FStar_Pervasives_Native.None;
    mii_trans_exported_ids = FStar_Pervasives_Native.None;
    mii_includes = FStar_Pervasives_Native.None
  }
let as_includes:
  'Auu____11159 .
    'Auu____11159 Prims.list FStar_Pervasives_Native.option ->
      'Auu____11159 Prims.list FStar_ST.ref
  =
  fun uu___185_11171  ->
    match uu___185_11171 with
    | FStar_Pervasives_Native.None  -> FStar_Util.mk_ref []
    | FStar_Pervasives_Native.Some l -> FStar_Util.mk_ref l
let inclusion_info: env -> FStar_Ident.lident -> module_inclusion_info =
  fun env  ->
    fun l  ->
      let mname = FStar_Ident.string_of_lid l in
      let as_ids_opt m =
        let uu____11204 = FStar_Util.smap_try_find m mname in
        FStar_Util.map_opt uu____11204 as_exported_ids in
      let uu____11207 = as_ids_opt env.exported_ids in
      let uu____11210 = as_ids_opt env.trans_exported_ids in
      let uu____11213 =
        let uu____11218 = FStar_Util.smap_try_find env.includes mname in
        FStar_Util.map_opt uu____11218 (fun r  -> FStar_ST.op_Bang r) in
      {
        mii_exported_ids = uu____11207;
        mii_trans_exported_ids = uu____11210;
        mii_includes = uu____11213
      }
let prepare_module_or_interface:
  Prims.bool ->
    Prims.bool ->
      env ->
        FStar_Ident.lident ->
          module_inclusion_info ->
            (env,Prims.bool) FStar_Pervasives_Native.tuple2
  =
  fun intf  ->
    fun admitted  ->
      fun env  ->
        fun mname  ->
          fun mii  ->
            let prep env1 =
              let filename =
                FStar_Util.strcat (FStar_Ident.text_of_lid mname) ".fst" in
              let auto_open =
                FStar_Parser_Dep.hard_coded_dependencies filename in
              let auto_open1 =
                let convert_kind uu___186_11353 =
                  match uu___186_11353 with
                  | FStar_Parser_Dep.Open_namespace  -> Open_namespace
                  | FStar_Parser_Dep.Open_module  -> Open_module in
                FStar_List.map
                  (fun uu____11365  ->
                     match uu____11365 with
                     | (lid,kind) -> (lid, (convert_kind kind))) auto_open in
              let namespace_of_module =
                if
                  (FStar_List.length mname.FStar_Ident.ns) >
                    (Prims.parse_int "0")
                then
                  let uu____11389 =
                    let uu____11394 =
                      FStar_Ident.lid_of_ids mname.FStar_Ident.ns in
                    (uu____11394, Open_namespace) in
                  [uu____11389]
                else [] in
              let auto_open2 =
                FStar_List.append namespace_of_module
                  (FStar_List.rev auto_open1) in
              (let uu____11424 = as_exported_id_set mii.mii_exported_ids in
               FStar_Util.smap_add env1.exported_ids mname.FStar_Ident.str
                 uu____11424);
              (match () with
               | () ->
                   ((let uu____11440 =
                       as_exported_id_set mii.mii_trans_exported_ids in
                     FStar_Util.smap_add env1.trans_exported_ids
                       mname.FStar_Ident.str uu____11440);
                    (match () with
                     | () ->
                         ((let uu____11456 = as_includes mii.mii_includes in
                           FStar_Util.smap_add env1.includes
                             mname.FStar_Ident.str uu____11456);
                          (match () with
                           | () ->
                               let env' =
                                 let uu___207_11480 = env1 in
                                 let uu____11481 =
                                   FStar_List.map
                                     (fun x  -> Open_module_or_namespace x)
                                     auto_open2 in
                                 {
                                   curmodule =
                                     (FStar_Pervasives_Native.Some mname);
                                   curmonad = (uu___207_11480.curmonad);
                                   modules = (uu___207_11480.modules);
                                   scope_mods = uu____11481;
                                   exported_ids =
                                     (uu___207_11480.exported_ids);
                                   trans_exported_ids =
                                     (uu___207_11480.trans_exported_ids);
                                   includes = (uu___207_11480.includes);
                                   sigaccum = (uu___207_11480.sigaccum);
                                   sigmap = (env1.sigmap);
                                   iface = intf;
                                   admitted_iface = admitted;
                                   expect_typ = (uu___207_11480.expect_typ);
                                   docs = (uu___207_11480.docs);
                                   remaining_iface_decls =
                                     (uu___207_11480.remaining_iface_decls);
                                   syntax_only = (uu___207_11480.syntax_only);
                                   ds_hooks = (uu___207_11480.ds_hooks)
                                 } in
                               (FStar_List.iter
                                  (fun op  ->
                                     (env1.ds_hooks).ds_push_open_hook env'
                                       op) (FStar_List.rev auto_open2);
                                env')))))) in
            let uu____11493 =
              FStar_All.pipe_right env.modules
                (FStar_Util.find_opt
                   (fun uu____11519  ->
                      match uu____11519 with
                      | (l,uu____11525) -> FStar_Ident.lid_equals l mname)) in
            match uu____11493 with
            | FStar_Pervasives_Native.None  ->
                let uu____11534 = prep env in (uu____11534, false)
            | FStar_Pervasives_Native.Some (uu____11535,m) ->
                ((let uu____11542 =
                    (let uu____11545 = FStar_Options.interactive () in
                     Prims.op_Negation uu____11545) &&
                      ((Prims.op_Negation m.FStar_Syntax_Syntax.is_interface)
                         || intf) in
                  if uu____11542
                  then
                    let uu____11546 =
                      let uu____11551 =
                        FStar_Util.format1
                          "Duplicate module or interface name: %s"
                          mname.FStar_Ident.str in
                      (FStar_Errors.Fatal_DuplicateModuleOrInterface,
                        uu____11551) in
                    FStar_Errors.raise_error uu____11546
                      (FStar_Ident.range_of_lid mname)
                  else ());
                 (let uu____11553 =
                    let uu____11554 = push env in prep uu____11554 in
                  (uu____11553, true)))
let enter_monad_scope: env -> FStar_Ident.ident -> env =
  fun env  ->
    fun mname  ->
      match env.curmonad with
      | FStar_Pervasives_Native.Some mname' ->
          FStar_Errors.raise_error
            (FStar_Errors.Fatal_MonadAlreadyDefined,
              (Prims.strcat "Trying to define monad "
                 (Prims.strcat mname.FStar_Ident.idText
                    (Prims.strcat ", but already in monad scope "
                       mname'.FStar_Ident.idText))))
            mname.FStar_Ident.idRange
      | FStar_Pervasives_Native.None  ->
          let uu___208_11562 = env in
          {
            curmodule = (uu___208_11562.curmodule);
            curmonad = (FStar_Pervasives_Native.Some mname);
            modules = (uu___208_11562.modules);
            scope_mods = (uu___208_11562.scope_mods);
            exported_ids = (uu___208_11562.exported_ids);
            trans_exported_ids = (uu___208_11562.trans_exported_ids);
            includes = (uu___208_11562.includes);
            sigaccum = (uu___208_11562.sigaccum);
            sigmap = (uu___208_11562.sigmap);
            iface = (uu___208_11562.iface);
            admitted_iface = (uu___208_11562.admitted_iface);
            expect_typ = (uu___208_11562.expect_typ);
            docs = (uu___208_11562.docs);
            remaining_iface_decls = (uu___208_11562.remaining_iface_decls);
            syntax_only = (uu___208_11562.syntax_only);
            ds_hooks = (uu___208_11562.ds_hooks)
          }
let fail_or:
  'a .
    env ->
      (FStar_Ident.lident -> 'a FStar_Pervasives_Native.option) ->
        FStar_Ident.lident -> 'a
  =
  fun env  ->
    fun lookup  ->
      fun lid  ->
        let uu____11589 = lookup lid in
        match uu____11589 with
        | FStar_Pervasives_Native.None  ->
            let opened_modules =
              FStar_List.map
                (fun uu____11602  ->
                   match uu____11602 with
                   | (lid1,uu____11608) -> FStar_Ident.text_of_lid lid1)
                env.modules in
            let msg =
              FStar_Util.format1 "Identifier not found: [%s]"
                (FStar_Ident.text_of_lid lid) in
            let msg1 =
              if
                (FStar_List.length lid.FStar_Ident.ns) =
                  (Prims.parse_int "0")
              then msg
              else
                (let modul =
                   let uu____11613 =
                     FStar_Ident.lid_of_ids lid.FStar_Ident.ns in
                   FStar_Ident.set_lid_range uu____11613
                     (FStar_Ident.range_of_lid lid) in
                 let uu____11614 = resolve_module_name env modul true in
                 match uu____11614 with
                 | FStar_Pervasives_Native.None  ->
                     let opened_modules1 =
                       FStar_String.concat ", " opened_modules in
                     FStar_Util.format3
                       "%s\nModule %s does not belong to the list of modules in scope, namely %s"
                       msg modul.FStar_Ident.str opened_modules1
                 | FStar_Pervasives_Native.Some modul' when
                     Prims.op_Negation
                       (FStar_List.existsb
                          (fun m  -> m = modul'.FStar_Ident.str)
                          opened_modules)
                     ->
                     let opened_modules1 =
                       FStar_String.concat ", " opened_modules in
                     FStar_Util.format4
                       "%s\nModule %s resolved into %s, which does not belong to the list of modules in scope, namely %s"
                       msg modul.FStar_Ident.str modul'.FStar_Ident.str
                       opened_modules1
                 | FStar_Pervasives_Native.Some modul' ->
                     FStar_Util.format4
                       "%s\nModule %s resolved into %s, definition %s not found"
                       msg modul.FStar_Ident.str modul'.FStar_Ident.str
                       (lid.FStar_Ident.ident).FStar_Ident.idText) in
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_IdentifierNotFound, msg1)
              (FStar_Ident.range_of_lid lid)
        | FStar_Pervasives_Native.Some r -> r
let fail_or2:
  'a .
    (FStar_Ident.ident -> 'a FStar_Pervasives_Native.option) ->
      FStar_Ident.ident -> 'a
  =
  fun lookup  ->
    fun id1  ->
      let uu____11645 = lookup id1 in
      match uu____11645 with
      | FStar_Pervasives_Native.None  ->
          FStar_Errors.raise_error
            (FStar_Errors.Fatal_IdentifierNotFound,
              (Prims.strcat "Identifier not found ["
                 (Prims.strcat id1.FStar_Ident.idText "]")))
            id1.FStar_Ident.idRange
      | FStar_Pervasives_Native.Some r -> r