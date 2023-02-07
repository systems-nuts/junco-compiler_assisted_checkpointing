; ModuleID = '../../examples/ex4/testing/split_kernel.ll'
source_filename = "kernel.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%"class.std::basic_ostream" = type { i32 (...)**, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", %"class.std::basic_ostream"*, i8, i8, %"class.std::basic_streambuf"*, %"class.std::ctype"*, %"class.std::num_put"*, %"class.std::num_get"* }
%"class.std::ios_base" = type { i32 (...)**, i64, i64, i32, i32, i32, %"struct.std::ios_base::_Callback_list"*, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, %"struct.std::ios_base::_Words"*, %"class.std::locale" }
%"struct.std::ios_base::_Callback_list" = type { %"struct.std::ios_base::_Callback_list"*, void (i32, %"class.std::ios_base"*, i32)*, i32, i32 }
%"struct.std::ios_base::_Words" = type { i8*, i64 }
%"class.std::locale" = type { %"class.std::locale::_Impl"* }
%"class.std::locale::_Impl" = type { i32, %"class.std::locale::facet"**, i64, %"class.std::locale::facet"**, i8** }
%"class.std::locale::facet" = type <{ i32 (...)**, i32, [4 x i8] }>
%"class.std::basic_streambuf" = type { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, %"class.std::locale" }
%"class.std::ctype" = type <{ %"class.std::locale::facet.base", [4 x i8], %struct.__locale_struct*, i8, [7 x i8], i32*, i32*, i16*, i8, [256 x i8], [256 x i8], i8, [6 x i8] }>
%"class.std::locale::facet.base" = type <{ i32 (...)**, i32 }>
%struct.__locale_struct = type { [13 x %struct.__locale_data*], i16*, i32*, i32*, [13 x i8*] }
%struct.__locale_data = type opaque
%"class.std::num_put" = type { %"class.std::locale::facet.base", [4 x i8] }
%"class.std::num_get" = type { %"class.std::locale::facet.base", [4 x i8] }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [38 x i8] c"Start of function: workload. l_id=%d\0A\00", align 1
@_ZSt4cout = external global %"class.std::basic_ostream", align 8
@.str.1 = private unnamed_addr constant [10 x i8] c"ckpt_mem=\00", align 1
@.str.2 = private unnamed_addr constant [7 x i8] c", arr=\00", align 1
@.str.3 = private unnamed_addr constant [17 x i8] c">> initial == 1:\00", align 1
@.str.4 = private unnamed_addr constant [12 x i8] c">> l_id = 7\00", align 1
@.str.5 = private unnamed_addr constant [15 x i8] c">> arr[0] = 19\00", align 1
@.str.6 = private unnamed_addr constant [15 x i8] c">> arr[1] = 96\00", align 1
@.str.7 = private unnamed_addr constant [34 x i8] c"initial=%d, arr[0]=%d, arr[1]=%d\0A\00", align 1
@.str.8 = private unnamed_addr constant [12 x i8] c"BEFORE CKPT\00", align 1
@.str.9 = private unnamed_addr constant [11 x i8] c"AFTER CKPT\00", align 1
@.str.10 = private unnamed_addr constant [9 x i8] c"Initial \00", align 1
@.str.11 = private unnamed_addr constant [26 x i8] c"arr[0] = %d, arr[1] = %d\0A\00", align 1
@.str.12 = private unnamed_addr constant [112 x i8] c"process l_id = %d, ckpt_mem ptr %p, heartbeat %d, CKPT_ID %d, VAR_0 %d, VAR_1 %d, VAR_2 %d, VAR_3 %d, VAR_4 %d\0A\00", align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_kernel.cpp, i8* null }]

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
entry:
  call void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"* noundef nonnull align 1 dereferenceable(1) @_ZStL8__ioinit)
  %0 = call i32 @__cxa_atexit(void (i8*)* bitcast (void (%"class.std::ios_base::Init"*)* @_ZNSt8ios_base4InitD1Ev to void (i8*)*), i8* getelementptr inbounds (%"class.std::ios_base::Init", %"class.std::ios_base::Init"* @_ZStL8__ioinit, i32 0, i32 0), i8* @__dso_handle) #3
  ret void
}

declare void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"* noundef nonnull align 1 dereferenceable(1)) unnamed_addr #1

; Function Attrs: nounwind
declare void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init"* noundef nonnull align 1 dereferenceable(1)) unnamed_addr #2

; Function Attrs: nounwind
declare i32 @__cxa_atexit(void (i8*)*, i8*, i8*) #3

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @checkpoint() #4 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline uwtable
define dso_local i32 @workload(i32* noundef %ckpt_mem, i32 noundef %initial, i32* noundef %arr) #5 {
entry.upper:
  %ckpt_mem.addr = alloca i32*, align 8
  %initial.addr = alloca i32, align 4
  %arr.addr = alloca i32*, align 8
  %l_id = alloca i32, align 4
  store i32* %ckpt_mem, i32** %ckpt_mem.addr, align 8
  store i32 %initial, i32* %initial.addr, align 4
  store i32* %arr, i32** %arr.addr, align 8
  store i32 0, i32* %l_id, align 4
  %0 = load i32, i32* %l_id, align 4
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([38 x i8], [38 x i8]* @.str, i64 0, i64 0), i32 noundef %0)
  %call1 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([10 x i8], [10 x i8]* @.str.1, i64 0, i64 0))
  %1 = load i32*, i32** %ckpt_mem.addr, align 8
  %2 = bitcast i32* %1 to i8*
  %call2 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPKv(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call1, i8* noundef %2)
  %call3 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call2, i8* noundef getelementptr inbounds ([7 x i8], [7 x i8]* @.str.2, i64 0, i64 0))
  %3 = load i32*, i32** %arr.addr, align 8
  %4 = bitcast i32* %3 to i8*
  %call4 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPKv(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call3, i8* noundef %4)
  %call5 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call4, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %5 = load i32, i32* %initial.addr, align 4
  br label %workload.restoreControllerBB

workload.restoreControllerBB:                     ; preds = %entry.upper
  %idx_ckpt_id_load = getelementptr inbounds i32, i32* %ckpt_mem, i32 1
  %load_ckpt_id = load i32, i32* %idx_ckpt_id_load, align 4
  switch i32 %load_ckpt_id, label %entry.lower [
    i32 1, label %if.end.upper.restoreBB.id1
  ]

entry.lower:                                      ; preds = %workload.restoreControllerBB
  %cmp = icmp eq i32 %5, 1
  br i1 %cmp, label %if.then, label %if.end.upper

if.then:                                          ; preds = %entry.lower
  %call6 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([17 x i8], [17 x i8]* @.str.3, i64 0, i64 0))
  %call7 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call6, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  store i32 7, i32* %l_id, align 4
  %call8 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([12 x i8], [12 x i8]* @.str.4, i64 0, i64 0))
  %call9 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call8, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %6 = load i32*, i32** %arr.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %6, i64 0
  store i32 19, i32* %arrayidx, align 4
  %call10 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([15 x i8], [15 x i8]* @.str.5, i64 0, i64 0))
  %call11 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call10, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %7 = load i32*, i32** %arr.addr, align 8
  %arrayidx12 = getelementptr inbounds i32, i32* %7, i64 1
  store i32 96, i32* %arrayidx12, align 4
  %call13 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([15 x i8], [15 x i8]* @.str.6, i64 0, i64 0))
  %call14 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call13, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  br label %if.end.upper

if.end.upper:                                     ; preds = %if.then, %entry.lower
  %8 = load i32, i32* %initial.addr, align 4
  %9 = load i32*, i32** %arr.addr, align 8
  %arrayidx15 = getelementptr inbounds i32, i32* %9, i64 0
  %10 = load i32, i32* %arrayidx15, align 4
  %11 = load i32*, i32** %arr.addr, align 8
  %arrayidx16 = getelementptr inbounds i32, i32* %11, i64 1
  %12 = load i32, i32* %arrayidx16, align 4
  %call17 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([34 x i8], [34 x i8]* @.str.7, i64 0, i64 0), i32 noundef %8, i32 noundef %10, i32 noundef %12)
  %call18 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([12 x i8], [12 x i8]* @.str.8, i64 0, i64 0))
  %call19 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call18, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %call20 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([11 x i8], [11 x i8]* @.str.9, i64 0, i64 0))
  %call21 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call20, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %13 = load i32, i32* %initial.addr, align 4
  br label %if.end.upper.saveBB.id1

if.end.upper.saveBB.id1:                          ; preds = %if.end.upper
  %idx_arr.addr = getelementptr inbounds i32, i32* %ckpt_mem, i32 3
  %loaded.arr.addr = load i32*, i32** %arr.addr, align 8
  %14 = bitcast i32* %idx_arr.addr to i8*
  %15 = bitcast i32* %loaded.arr.addr to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %14, i8* align 8 %15, i64 8, i1 true)
  %idx_l_id = getelementptr inbounds i32, i32* %ckpt_mem, i32 5
  %16 = bitcast i32* %idx_l_id to i8*
  %17 = bitcast i32* %l_id to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %16, i8* align 8 %17, i64 4, i1 true)
  %idx_13 = getelementptr inbounds i32, i32* %ckpt_mem, i32 6
  store i32 %13, i32* %idx_13, align 4
  %idx_ckpt_id = getelementptr inbounds i32, i32* %ckpt_mem, i32 1
  store i32 1, i32* %idx_ckpt_id, align 4
  %idx_heartbeat = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  %load_heartbeat = load i32, i32* %idx_heartbeat, align 4
  %heartbeat_incr = add i32 %load_heartbeat, 1
  store i32 %heartbeat_incr, i32* %idx_heartbeat, align 4
  br label %if.end.upper.junctionBB.id1

if.end.upper.junctionBB.id1:                      ; preds = %if.end.upper.restoreBB.id1, %if.end.upper.saveBB.id1
  %new.arr.addr = phi i32** [ %arr.addr, %if.end.upper.saveBB.id1 ], [ %alloca.arr.addr, %if.end.upper.restoreBB.id1 ]
  %new.l_id = phi i32* [ %l_id, %if.end.upper.saveBB.id1 ], [ %alloca.l_id, %if.end.upper.restoreBB.id1 ]
  %new.13 = phi i32 [ %13, %if.end.upper.saveBB.id1 ], [ %load.13, %if.end.upper.restoreBB.id1 ]
  br label %if.end.lower

if.end.lower:                                     ; preds = %if.end.upper.junctionBB.id1
  %cmp22 = icmp eq i32 %new.13, 1
  br i1 %cmp22, label %if.then23, label %if.end25

if.then23:                                        ; preds = %if.end.lower
  %call24 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([9 x i8], [9 x i8]* @.str.10, i64 0, i64 0))
  br label %if.end25

if.end25:                                         ; preds = %if.then23, %if.end.lower
  %new.l_id.phi = phi i32* [ %new.l_id, %if.then23 ], [ %new.l_id, %if.end.lower ]
  %new.arr.addr.phi = phi i32** [ %new.arr.addr, %if.then23 ], [ %new.arr.addr, %if.end.lower ]
  %18 = load i32*, i32** %new.arr.addr.phi, align 8
  %arrayidx26 = getelementptr inbounds i32, i32* %18, i64 0
  %19 = load i32, i32* %arrayidx26, align 4
  %20 = load i32*, i32** %new.arr.addr.phi, align 8
  %arrayidx27 = getelementptr inbounds i32, i32* %20, i64 1
  %21 = load i32, i32* %arrayidx27, align 4
  %call28 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([26 x i8], [26 x i8]* @.str.11, i64 0, i64 0), i32 noundef %19, i32 noundef %21)
  %22 = load i32, i32* %new.l_id.phi, align 4
  %23 = load i32*, i32** %ckpt_mem.addr, align 8
  %24 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx29 = getelementptr inbounds i32, i32* %24, i64 0
  %25 = load i32, i32* %arrayidx29, align 4
  %26 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx30 = getelementptr inbounds i32, i32* %26, i64 1
  %27 = load i32, i32* %arrayidx30, align 4
  %28 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx31 = getelementptr inbounds i32, i32* %28, i64 3
  %29 = load i32, i32* %arrayidx31, align 4
  %30 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx32 = getelementptr inbounds i32, i32* %30, i64 4
  %31 = load i32, i32* %arrayidx32, align 4
  %32 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx33 = getelementptr inbounds i32, i32* %32, i64 5
  %33 = load i32, i32* %arrayidx33, align 4
  %34 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx34 = getelementptr inbounds i32, i32* %34, i64 6
  %35 = load i32, i32* %arrayidx34, align 4
  %36 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx35 = getelementptr inbounds i32, i32* %36, i64 7
  %37 = load i32, i32* %arrayidx35, align 4
  %call36 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([112 x i8], [112 x i8]* @.str.12, i64 0, i64 0), i32 noundef %22, i32* noundef %23, i32 noundef %25, i32 noundef %27, i32 noundef %29, i32 noundef %31, i32 noundef %33, i32 noundef %35, i32 noundef %37)
  %38 = load i32, i32* %initial.addr, align 4
  %cmp37 = icmp eq i32 %38, 1
  %39 = zext i1 %cmp37 to i64
  %cond = select i1 %cmp37, i32 0, i32 1
  %idx_isComplete = getelementptr inbounds i32, i32* %ckpt_mem, i32 2
  store i32 %cond, i32* %idx_isComplete, align 4
  ret i32 %cond

if.end.upper.restoreBB.id1:                       ; preds = %workload.restoreControllerBB
  %idx_arr.addr1 = getelementptr inbounds i32, i32* %ckpt_mem, i32 3
  %alloca.arr.addr = alloca i32*, align 8
  %alloca_contained.arr.addr = alloca i32, i32 2, align 4
  store i32* %alloca_contained.arr.addr, i32** %alloca.arr.addr, align 8
  %40 = bitcast i32* %alloca_contained.arr.addr to i8*
  %41 = bitcast i32* %idx_arr.addr1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %40, i8* align 8 %41, i64 8, i1 true)
  %idx_l_id2 = getelementptr inbounds i32, i32* %ckpt_mem, i32 5
  %alloca.l_id = alloca i32, align 4
  %42 = bitcast i32* %alloca.l_id to i8*
  %43 = bitcast i32* %idx_l_id2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %42, i8* align 8 %43, i64 4, i1 true)
  %idx_133 = getelementptr inbounds i32, i32* %ckpt_mem, i32 6
  %load.13 = load i32, i32* %idx_133, align 4
  %idx_heartbeat4 = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  %load_heartbeat5 = load i32, i32* %idx_heartbeat4, align 4
  %heartbeat_incr6 = add i32 %load_heartbeat5, 1
  store i32 %heartbeat_incr6, i32* %idx_heartbeat4, align 4
  br label %if.end.upper.junctionBB.id1
}

declare i32 @printf(i8* noundef, ...) #1

declare noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8), i8* noundef) #1

declare noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPKv(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8), i8* noundef) #1

declare noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8), %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef) #1

declare noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8)) #1

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_kernel.cpp() #0 section ".text.startup" {
entry:
  call void @__cxx_global_var_init()
  ret void
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #6

attributes #0 = { noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind }
attributes #4 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { argmemonly nofree nounwind willreturn }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.6"}
