; ModuleID = '../../examples/ex4_float/testing/split_kernel.ll'
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
@.str = private unnamed_addr constant [38 x i8] c"Start of function: workload. l_id=%f\0A\00", align 1
@_ZSt4cout = external global %"class.std::basic_ostream", align 8
@.str.1 = private unnamed_addr constant [10 x i8] c"ckpt_mem=\00", align 1
@.str.2 = private unnamed_addr constant [7 x i8] c", arr=\00", align 1
@.str.3 = private unnamed_addr constant [17 x i8] c">> initial == 1:\00", align 1
@.str.4 = private unnamed_addr constant [12 x i8] c">> l_id = 7\00", align 1
@.str.5 = private unnamed_addr constant [15 x i8] c">> arr[0] = 19\00", align 1
@.str.6 = private unnamed_addr constant [15 x i8] c">> arr[1] = 96\00", align 1
@.str.7 = private unnamed_addr constant [34 x i8] c"initial=%f, arr[0]=%f, arr[1]=%f\0A\00", align 1
@.str.8 = private unnamed_addr constant [12 x i8] c"BEFORE CKPT\00", align 1
@.str.9 = private unnamed_addr constant [11 x i8] c"AFTER CKPT\00", align 1
@.str.10 = private unnamed_addr constant [9 x i8] c"Initial \00", align 1
@.str.11 = private unnamed_addr constant [26 x i8] c"arr[0] = %f, arr[1] = %f\0A\00", align 1
@.str.12 = private unnamed_addr constant [112 x i8] c"process l_id = %f, ckpt_mem ptr %p, heartbeat %f, CKPT_ID %f, VAR_0 %f, VAR_1 %f, VAR_2 %f, VAR_3 %f, VAR_4 %f\0A\00", align 1
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
define dso_local float @workload(float* noundef %ckpt_mem, float noundef %initial, float* noundef %arr) #5 {
entry.upper:
  %ckpt_mem.addr = alloca float*, align 8
  %initial.addr = alloca float, align 4
  %arr.addr = alloca float*, align 8
  %l_id = alloca float, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  store float %initial, float* %initial.addr, align 4
  store float* %arr, float** %arr.addr, align 8
  store float 0.000000e+00, float* %l_id, align 4
  %0 = load float, float* %l_id, align 4
  %conv = fpext float %0 to double
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([38 x i8], [38 x i8]* @.str, i64 0, i64 0), double noundef %conv)
  %call1 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([10 x i8], [10 x i8]* @.str.1, i64 0, i64 0))
  %1 = load float*, float** %ckpt_mem.addr, align 8
  %2 = bitcast float* %1 to i8*
  %call2 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPKv(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call1, i8* noundef %2)
  %call3 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call2, i8* noundef getelementptr inbounds ([7 x i8], [7 x i8]* @.str.2, i64 0, i64 0))
  %3 = load float*, float** %arr.addr, align 8
  %4 = bitcast float* %3 to i8*
  %call4 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPKv(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call3, i8* noundef %4)
  %call5 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call4, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %5 = load float, float* %initial.addr, align 4
  br label %workload.restoreControllerBB

workload.restoreControllerBB:                     ; preds = %entry.upper
  %idx_ckpt_id_load = getelementptr inbounds float, float* %ckpt_mem, i32 1
  %load_ckpt_id = load float, float* %idx_ckpt_id_load, align 4
  %int_ckpt_id = fptosi float %load_ckpt_id to i32
  switch i32 %int_ckpt_id, label %entry.lower [
    i32 1, label %if.end.upper.restoreBB.id1
  ]

entry.lower:                                      ; preds = %workload.restoreControllerBB
  %cmp = fcmp oeq float %5, 1.000000e+00
  br i1 %cmp, label %if.then, label %if.end.upper

if.then:                                          ; preds = %entry.lower
  %call6 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([17 x i8], [17 x i8]* @.str.3, i64 0, i64 0))
  %call7 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call6, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  store float 7.000000e+00, float* %l_id, align 4
  %call8 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([12 x i8], [12 x i8]* @.str.4, i64 0, i64 0))
  %call9 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call8, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %6 = load float*, float** %arr.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %6, i64 0
  store float 1.900000e+01, float* %arrayidx, align 4
  %call10 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([15 x i8], [15 x i8]* @.str.5, i64 0, i64 0))
  %call11 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call10, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %7 = load float*, float** %arr.addr, align 8
  %arrayidx12 = getelementptr inbounds float, float* %7, i64 1
  store float 9.600000e+01, float* %arrayidx12, align 4
  %call13 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([15 x i8], [15 x i8]* @.str.6, i64 0, i64 0))
  %call14 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call13, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  br label %if.end.upper

if.end.upper:                                     ; preds = %if.then, %entry.lower
  %8 = load float, float* %initial.addr, align 4
  %conv15 = fpext float %8 to double
  %9 = load float*, float** %arr.addr, align 8
  %arrayidx16 = getelementptr inbounds float, float* %9, i64 0
  %10 = load float, float* %arrayidx16, align 4
  %conv17 = fpext float %10 to double
  %11 = load float*, float** %arr.addr, align 8
  %arrayidx18 = getelementptr inbounds float, float* %11, i64 1
  %12 = load float, float* %arrayidx18, align 4
  %conv19 = fpext float %12 to double
  %call20 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([34 x i8], [34 x i8]* @.str.7, i64 0, i64 0), double noundef %conv15, double noundef %conv17, double noundef %conv19)
  %call21 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([12 x i8], [12 x i8]* @.str.8, i64 0, i64 0))
  %call22 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call21, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %call23 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i8* noundef getelementptr inbounds ([11 x i8], [11 x i8]* @.str.9, i64 0, i64 0))
  %call24 = call noundef nonnull align 8 dereferenceable(8) %"class.std::basic_ostream"* @_ZNSolsEPFRSoS_E(%"class.std::basic_ostream"* noundef nonnull align 8 dereferenceable(8) %call23, %"class.std::basic_ostream"* (%"class.std::basic_ostream"*)* noundef @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)
  %13 = load float, float* %initial.addr, align 4
  br label %if.end.upper.saveBB.id1

if.end.upper.saveBB.id1:                          ; preds = %if.end.upper
  %idx_arr.addr = getelementptr inbounds float, float* %ckpt_mem, i32 3
  %loaded.arr.addr = load float*, float** %arr.addr, align 8
  %14 = bitcast float* %idx_arr.addr to i8*
  %15 = bitcast float* %loaded.arr.addr to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %14, i8* align 8 %15, i64 8, i1 true)
  %idx_l_id = getelementptr inbounds float, float* %ckpt_mem, i32 5
  %deref_l_id = load float, float* %l_id, align 4
  store float %deref_l_id, float* %idx_l_id, align 4
  %idx_13 = getelementptr inbounds float, float* %ckpt_mem, i32 6
  store float %13, float* %idx_13, align 4
  %idx_ckpt_id = getelementptr inbounds float, float* %ckpt_mem, i32 1
  %ckpt_id_FP = sitofp i32 1 to float
  store float %ckpt_id_FP, float* %idx_ckpt_id, align 4
  %idx_heartbeat = getelementptr inbounds float, float* %ckpt_mem, i32 0
  %load_heartbeat = load float, float* %idx_heartbeat, align 4
  %heartbeat_int = fptosi float %load_heartbeat to i32
  %heartbeat_incr = add i32 %heartbeat_int, 1
  %heartbeat_incr_int = sitofp i32 %heartbeat_incr to float
  store float %heartbeat_incr_int, float* %idx_heartbeat, align 4
  br label %if.end.upper.junctionBB.id1

if.end.upper.junctionBB.id1:                      ; preds = %if.end.upper.restoreBB.id1, %if.end.upper.saveBB.id1
  %new.arr.addr = phi float** [ %arr.addr, %if.end.upper.saveBB.id1 ], [ %alloca_arr.addr, %if.end.upper.restoreBB.id1 ]
  %new.l_id = phi float* [ %l_id, %if.end.upper.saveBB.id1 ], [ %alloca_l_id, %if.end.upper.restoreBB.id1 ]
  %new.13 = phi float [ %13, %if.end.upper.saveBB.id1 ], [ %load.13, %if.end.upper.restoreBB.id1 ]
  br label %if.end.lower

if.end.lower:                                     ; preds = %if.end.upper.junctionBB.id1
  %cmp25 = fcmp oeq float %new.13, 1.000000e+00
  br i1 %cmp25, label %if.then26, label %if.end28

if.then26:                                        ; preds = %if.end.lower
  %call27 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([9 x i8], [9 x i8]* @.str.10, i64 0, i64 0))
  br label %if.end28

if.end28:                                         ; preds = %if.then26, %if.end.lower
  %new.l_id.phi = phi float* [ %new.l_id, %if.then26 ], [ %new.l_id, %if.end.lower ]
  %new.arr.addr.phi = phi float** [ %new.arr.addr, %if.then26 ], [ %new.arr.addr, %if.end.lower ]
  %16 = load float*, float** %new.arr.addr.phi, align 8
  %arrayidx29 = getelementptr inbounds float, float* %16, i64 0
  %17 = load float, float* %arrayidx29, align 4
  %conv30 = fpext float %17 to double
  %18 = load float*, float** %new.arr.addr.phi, align 8
  %arrayidx31 = getelementptr inbounds float, float* %18, i64 1
  %19 = load float, float* %arrayidx31, align 4
  %conv32 = fpext float %19 to double
  %call33 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([26 x i8], [26 x i8]* @.str.11, i64 0, i64 0), double noundef %conv30, double noundef %conv32)
  %20 = load float, float* %new.l_id.phi, align 4
  %conv34 = fpext float %20 to double
  %21 = load float*, float** %ckpt_mem.addr, align 8
  %22 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx35 = getelementptr inbounds float, float* %22, i64 0
  %23 = load float, float* %arrayidx35, align 4
  %conv36 = fpext float %23 to double
  %24 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx37 = getelementptr inbounds float, float* %24, i64 1
  %25 = load float, float* %arrayidx37, align 4
  %conv38 = fpext float %25 to double
  %26 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx39 = getelementptr inbounds float, float* %26, i64 3
  %27 = load float, float* %arrayidx39, align 4
  %conv40 = fpext float %27 to double
  %28 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx41 = getelementptr inbounds float, float* %28, i64 4
  %29 = load float, float* %arrayidx41, align 4
  %conv42 = fpext float %29 to double
  %30 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx43 = getelementptr inbounds float, float* %30, i64 5
  %31 = load float, float* %arrayidx43, align 4
  %conv44 = fpext float %31 to double
  %32 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx45 = getelementptr inbounds float, float* %32, i64 6
  %33 = load float, float* %arrayidx45, align 4
  %conv46 = fpext float %33 to double
  %34 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx47 = getelementptr inbounds float, float* %34, i64 7
  %35 = load float, float* %arrayidx47, align 4
  %conv48 = fpext float %35 to double
  %call49 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([112 x i8], [112 x i8]* @.str.12, i64 0, i64 0), double noundef %conv34, float* noundef %21, double noundef %conv36, double noundef %conv38, double noundef %conv40, double noundef %conv42, double noundef %conv44, double noundef %conv46, double noundef %conv48)
  %36 = load float, float* %initial.addr, align 4
  %cmp50 = fcmp oeq float %36, 1.000000e+00
  %37 = zext i1 %cmp50 to i64
  %cond = select i1 %cmp50, float 0.000000e+00, float 1.000000e+00
  %idx_isComplete = getelementptr inbounds float, float* %ckpt_mem, i32 2
  store float %cond, float* %idx_isComplete, align 4
  ret float %cond

if.end.upper.restoreBB.id1:                       ; preds = %workload.restoreControllerBB
  %idx_arr.addr1 = getelementptr inbounds float, float* %ckpt_mem, i32 3
  %alloca_arr.addr = alloca float*, align 8
  %alloca_contained_arr.addr = alloca float, i32 2, align 4
  store float* %alloca_contained_arr.addr, float** %alloca_arr.addr, align 8
  %38 = bitcast float* %alloca_contained_arr.addr to i8*
  %39 = bitcast float* %idx_arr.addr1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %38, i8* align 8 %39, i64 8, i1 true)
  %idx_l_id2 = getelementptr inbounds float, float* %ckpt_mem, i32 5
  %alloca_l_id = alloca float, align 4
  %load_derefed_l_id = load float, float* %idx_l_id2, align 4
  store float %load_derefed_l_id, float* %alloca_l_id, align 4
  %idx_133 = getelementptr inbounds float, float* %ckpt_mem, i32 6
  %load.13 = load float, float* %idx_133, align 4
  %idx_heartbeat4 = getelementptr inbounds float, float* %ckpt_mem, i32 0
  %load_heartbeat5 = load float, float* %idx_heartbeat4, align 4
  %heartbeat_int6 = fptosi float %load_heartbeat5 to i32
  %heartbeat_incr7 = add i32 %heartbeat_int6, 1
  %heartbeat_incr_int8 = sitofp i32 %heartbeat_incr7 to float
  store float %heartbeat_incr_int8, float* %idx_heartbeat4, align 4
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
