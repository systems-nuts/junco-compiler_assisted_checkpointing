; ModuleID = '../../examples/lud/ir_code/split_lud.ll'
source_filename = "../lud.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [47 x i8] c"lud run from process PID = %d (ckpt id %d) %p\0A\00", align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_lud.cpp, i8* null }]

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
define dso_local void @lud(float* noundef %result, i32 noundef %size, float* noundef %ckpt_mem, i32 noundef %ckpt_id) #5 {
entry.upper:
  %result.addr = alloca float*, align 8
  %size.addr = alloca i32, align 4
  %ckpt_mem.addr = alloca float*, align 8
  %ckpt_id.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %sum = alloca float, align 4
  %init_i = alloca i32, align 4
  store float* %result, float** %result.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  store i32 %ckpt_id, i32* %ckpt_id.addr, align 4
  store i32 0, i32* %init_i, align 4
  %0 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %0, i64 0
  store float 0.000000e+00, float* %arrayidx, align 4
  %call = call i32 @getpid() #3
  %1 = load i32, i32* %ckpt_id.addr, align 4
  %2 = load float*, float** %ckpt_mem.addr, align 8
  %call1 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([47 x i8], [47 x i8]* @.str, i64 0, i64 0), i32 noundef %call, i32 noundef %1, float* noundef %2)
  %3 = load i32, i32* %init_i, align 4
  store i32 %3, i32* %i, align 4
  br label %lud.restoreControllerBB

lud.restoreControllerBB:                          ; preds = %entry.upper
  %idx_ckpt_id_load = getelementptr inbounds float, float* %ckpt_mem, i32 1
  %load_ckpt_id = load float, float* %idx_ckpt_id_load, align 4
  %int_ckpt_id = fptosi float %load_ckpt_id to i32
  switch i32 %int_ckpt_id, label %entry.lower [
    i32 1, label %for.end59.restoreBB.id1
  ]

entry.lower:                                      ; preds = %lud.restoreControllerBB
  br label %for.cond.upper

for.cond.upper:                                   ; preds = %for.inc60, %entry.lower
  %new.sum.phi = phi float* [ %new.sum, %for.inc60 ], [ %sum, %entry.lower ]
  %new.k.phi = phi i32* [ %new.k, %for.inc60 ], [ %k, %entry.lower ]
  %new.j.phi = phi i32* [ %new.j, %for.inc60 ], [ %j, %entry.lower ]
  %new.i.phi = phi i32* [ %new.i, %for.inc60 ], [ %i, %entry.lower ]
  %new.size.addr.phi = phi i32* [ %new.size.addr, %for.inc60 ], [ %size.addr, %entry.lower ]
  %new.result.addr.phi = phi float** [ %new.result.addr, %for.inc60 ], [ %result.addr, %entry.lower ]
  %4 = load i32, i32* %new.i.phi, align 4
  %5 = load i32, i32* %new.size.addr.phi, align 4
  br label %for.cond.lower

for.cond.lower:                                   ; preds = %for.cond.upper
  %cmp = icmp slt i32 %4, %5
  br i1 %cmp, label %for.body, label %for.end62

for.body:                                         ; preds = %for.cond.lower
  %6 = load i32, i32* %new.i.phi, align 4
  store i32 %6, i32* %new.j.phi, align 4
  br label %for.cond2.upper

for.cond2.upper:                                  ; preds = %for.inc22, %for.body
  %new.sum.phi.phi = phi float* [ %new.sum.phi.phi.phi, %for.inc22 ], [ %new.sum.phi, %for.body ]
  %new.k.phi.phi = phi i32* [ %new.k.phi.phi.phi, %for.inc22 ], [ %new.k.phi, %for.body ]
  %new.j.phi.phi = phi i32* [ %new.j.phi.phi.phi, %for.inc22 ], [ %new.j.phi, %for.body ]
  %new.i.phi.phi = phi i32* [ %new.i.phi.phi.phi, %for.inc22 ], [ %new.i.phi, %for.body ]
  %new.size.addr.phi.phi = phi i32* [ %new.size.addr.phi.phi.phi, %for.inc22 ], [ %new.size.addr.phi, %for.body ]
  %new.result.addr.phi.phi = phi float** [ %new.result.addr.phi.phi.phi, %for.inc22 ], [ %new.result.addr.phi, %for.body ]
  %7 = load i32, i32* %new.j.phi.phi, align 4
  %8 = load i32, i32* %new.size.addr.phi.phi, align 4
  br label %for.cond2.lower

for.cond2.lower:                                  ; preds = %for.cond2.upper
  %cmp3 = icmp slt i32 %7, %8
  br i1 %cmp3, label %for.body4, label %for.end24

for.body4:                                        ; preds = %for.cond2.lower
  %9 = load float*, float** %new.result.addr.phi.phi, align 8
  %10 = load i32, i32* %new.i.phi.phi, align 4
  %11 = load i32, i32* %new.size.addr.phi.phi, align 4
  %mul = mul nsw i32 %10, %11
  %12 = load i32, i32* %new.j.phi.phi, align 4
  %add = add nsw i32 %mul, %12
  %idxprom = sext i32 %add to i64
  %arrayidx5 = getelementptr inbounds float, float* %9, i64 %idxprom
  %13 = load float, float* %arrayidx5, align 4
  store float %13, float* %new.sum.phi.phi, align 4
  store i32 0, i32* %new.k.phi.phi, align 4
  br label %for.cond6.upper

for.cond6.upper:                                  ; preds = %for.inc, %for.body4
  %new.sum.phi.phi.phi = phi float* [ %new.sum.phi.phi.phi, %for.inc ], [ %new.sum.phi.phi, %for.body4 ]
  %new.k.phi.phi.phi = phi i32* [ %new.k.phi.phi.phi, %for.inc ], [ %new.k.phi.phi, %for.body4 ]
  %new.j.phi.phi.phi = phi i32* [ %new.j.phi.phi.phi, %for.inc ], [ %new.j.phi.phi, %for.body4 ]
  %new.i.phi.phi.phi = phi i32* [ %new.i.phi.phi.phi, %for.inc ], [ %new.i.phi.phi, %for.body4 ]
  %new.size.addr.phi.phi.phi = phi i32* [ %new.size.addr.phi.phi.phi, %for.inc ], [ %new.size.addr.phi.phi, %for.body4 ]
  %new.result.addr.phi.phi.phi = phi float** [ %new.result.addr.phi.phi.phi, %for.inc ], [ %new.result.addr.phi.phi, %for.body4 ]
  %14 = load i32, i32* %new.k.phi.phi.phi, align 4
  %15 = load i32, i32* %new.i.phi.phi.phi, align 4
  br label %for.cond6.lower

for.cond6.lower:                                  ; preds = %for.cond6.upper
  %cmp7 = icmp slt i32 %14, %15
  br i1 %cmp7, label %for.body8, label %for.end

for.body8:                                        ; preds = %for.cond6.lower
  %16 = load float*, float** %new.result.addr.phi.phi.phi, align 8
  %17 = load i32, i32* %new.i.phi.phi.phi, align 4
  %18 = load i32, i32* %new.size.addr.phi.phi.phi, align 4
  %mul9 = mul nsw i32 %17, %18
  %19 = load i32, i32* %new.k.phi.phi.phi, align 4
  %add10 = add nsw i32 %mul9, %19
  %idxprom11 = sext i32 %add10 to i64
  %arrayidx12 = getelementptr inbounds float, float* %16, i64 %idxprom11
  %20 = load float, float* %arrayidx12, align 4
  %21 = load float*, float** %new.result.addr.phi.phi.phi, align 8
  %22 = load i32, i32* %new.k.phi.phi.phi, align 4
  %23 = load i32, i32* %new.size.addr.phi.phi.phi, align 4
  %mul13 = mul nsw i32 %22, %23
  %24 = load i32, i32* %new.j.phi.phi.phi, align 4
  %add14 = add nsw i32 %mul13, %24
  %idxprom15 = sext i32 %add14 to i64
  %arrayidx16 = getelementptr inbounds float, float* %21, i64 %idxprom15
  %25 = load float, float* %arrayidx16, align 4
  %26 = load float, float* %new.sum.phi.phi.phi, align 4
  %neg = fneg float %20
  %27 = call float @llvm.fmuladd.f32(float %neg, float %25, float %26)
  store float %27, float* %new.sum.phi.phi.phi, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body8
  %28 = load i32, i32* %new.k.phi.phi.phi, align 4
  %inc = add nsw i32 %28, 1
  store i32 %inc, i32* %new.k.phi.phi.phi, align 4
  br label %for.cond6.upper, !llvm.loop !6

for.end:                                          ; preds = %for.cond6.lower
  %29 = load float, float* %new.sum.phi.phi.phi, align 4
  %30 = load float*, float** %new.result.addr.phi.phi.phi, align 8
  %31 = load i32, i32* %new.i.phi.phi.phi, align 4
  %32 = load i32, i32* %new.size.addr.phi.phi.phi, align 4
  %mul18 = mul nsw i32 %31, %32
  %33 = load i32, i32* %new.j.phi.phi.phi, align 4
  %add19 = add nsw i32 %mul18, %33
  %idxprom20 = sext i32 %add19 to i64
  %arrayidx21 = getelementptr inbounds float, float* %30, i64 %idxprom20
  store float %29, float* %arrayidx21, align 4
  br label %for.inc22

for.inc22:                                        ; preds = %for.end
  %34 = load i32, i32* %new.j.phi.phi.phi, align 4
  %inc23 = add nsw i32 %34, 1
  store i32 %inc23, i32* %new.j.phi.phi.phi, align 4
  br label %for.cond2.upper, !llvm.loop !8

for.end24:                                        ; preds = %for.cond2.lower
  %35 = load i32, i32* %new.i.phi.phi, align 4
  %add25 = add nsw i32 %35, 1
  store i32 %add25, i32* %new.j.phi.phi, align 4
  br label %for.cond26.upper

for.cond26.upper:                                 ; preds = %for.inc57, %for.end24
  %new.sum.phi.phi.phi12 = phi float* [ %new.sum.phi.phi.phi12.phi, %for.inc57 ], [ %new.sum.phi.phi, %for.end24 ]
  %new.k.phi.phi.phi11 = phi i32* [ %new.k.phi.phi.phi11.phi, %for.inc57 ], [ %new.k.phi.phi, %for.end24 ]
  %new.j.phi.phi.phi10 = phi i32* [ %new.j.phi.phi.phi10.phi, %for.inc57 ], [ %new.j.phi.phi, %for.end24 ]
  %new.i.phi.phi.phi9 = phi i32* [ %new.i.phi.phi.phi9.phi, %for.inc57 ], [ %new.i.phi.phi, %for.end24 ]
  %new.size.addr.phi.phi.phi8 = phi i32* [ %new.size.addr.phi.phi.phi8.phi, %for.inc57 ], [ %new.size.addr.phi.phi, %for.end24 ]
  %new.result.addr.phi.phi.phi7 = phi float** [ %new.result.addr.phi.phi.phi7.phi, %for.inc57 ], [ %new.result.addr.phi.phi, %for.end24 ]
  %36 = load i32, i32* %new.j.phi.phi.phi10, align 4
  %37 = load i32, i32* %new.size.addr.phi.phi.phi8, align 4
  br label %for.cond26.lower

for.cond26.lower:                                 ; preds = %for.cond26.upper
  %cmp27 = icmp slt i32 %36, %37
  br i1 %cmp27, label %for.body28, label %for.end59

for.body28:                                       ; preds = %for.cond26.lower
  %38 = load float*, float** %new.result.addr.phi.phi.phi7, align 8
  %39 = load i32, i32* %new.j.phi.phi.phi10, align 4
  %40 = load i32, i32* %new.size.addr.phi.phi.phi8, align 4
  %mul29 = mul nsw i32 %39, %40
  %41 = load i32, i32* %new.i.phi.phi.phi9, align 4
  %add30 = add nsw i32 %mul29, %41
  %idxprom31 = sext i32 %add30 to i64
  %arrayidx32 = getelementptr inbounds float, float* %38, i64 %idxprom31
  %42 = load float, float* %arrayidx32, align 4
  store float %42, float* %new.sum.phi.phi.phi12, align 4
  store i32 0, i32* %new.k.phi.phi.phi11, align 4
  br label %for.cond33.upper

for.cond33.upper:                                 ; preds = %for.inc46, %for.body28
  %new.sum.phi.phi.phi12.phi = phi float* [ %new.sum.phi.phi.phi12.phi, %for.inc46 ], [ %new.sum.phi.phi.phi12, %for.body28 ]
  %new.k.phi.phi.phi11.phi = phi i32* [ %new.k.phi.phi.phi11.phi, %for.inc46 ], [ %new.k.phi.phi.phi11, %for.body28 ]
  %new.j.phi.phi.phi10.phi = phi i32* [ %new.j.phi.phi.phi10.phi, %for.inc46 ], [ %new.j.phi.phi.phi10, %for.body28 ]
  %new.i.phi.phi.phi9.phi = phi i32* [ %new.i.phi.phi.phi9.phi, %for.inc46 ], [ %new.i.phi.phi.phi9, %for.body28 ]
  %new.size.addr.phi.phi.phi8.phi = phi i32* [ %new.size.addr.phi.phi.phi8.phi, %for.inc46 ], [ %new.size.addr.phi.phi.phi8, %for.body28 ]
  %new.result.addr.phi.phi.phi7.phi = phi float** [ %new.result.addr.phi.phi.phi7.phi, %for.inc46 ], [ %new.result.addr.phi.phi.phi7, %for.body28 ]
  %43 = load i32, i32* %new.k.phi.phi.phi11.phi, align 4
  %44 = load i32, i32* %new.i.phi.phi.phi9.phi, align 4
  br label %for.cond33.lower

for.cond33.lower:                                 ; preds = %for.cond33.upper
  %cmp34 = icmp slt i32 %43, %44
  br i1 %cmp34, label %for.body35, label %for.end48

for.body35:                                       ; preds = %for.cond33.lower
  %45 = load float*, float** %new.result.addr.phi.phi.phi7.phi, align 8
  %46 = load i32, i32* %new.j.phi.phi.phi10.phi, align 4
  %47 = load i32, i32* %new.size.addr.phi.phi.phi8.phi, align 4
  %mul36 = mul nsw i32 %46, %47
  %48 = load i32, i32* %new.k.phi.phi.phi11.phi, align 4
  %add37 = add nsw i32 %mul36, %48
  %idxprom38 = sext i32 %add37 to i64
  %arrayidx39 = getelementptr inbounds float, float* %45, i64 %idxprom38
  %49 = load float, float* %arrayidx39, align 4
  %50 = load float*, float** %new.result.addr.phi.phi.phi7.phi, align 8
  %51 = load i32, i32* %new.k.phi.phi.phi11.phi, align 4
  %52 = load i32, i32* %new.size.addr.phi.phi.phi8.phi, align 4
  %mul40 = mul nsw i32 %51, %52
  %53 = load i32, i32* %new.i.phi.phi.phi9.phi, align 4
  %add41 = add nsw i32 %mul40, %53
  %idxprom42 = sext i32 %add41 to i64
  %arrayidx43 = getelementptr inbounds float, float* %50, i64 %idxprom42
  %54 = load float, float* %arrayidx43, align 4
  %55 = load float, float* %new.sum.phi.phi.phi12.phi, align 4
  %neg45 = fneg float %49
  %56 = call float @llvm.fmuladd.f32(float %neg45, float %54, float %55)
  store float %56, float* %new.sum.phi.phi.phi12.phi, align 4
  br label %for.inc46

for.inc46:                                        ; preds = %for.body35
  %57 = load i32, i32* %new.k.phi.phi.phi11.phi, align 4
  %inc47 = add nsw i32 %57, 1
  store i32 %inc47, i32* %new.k.phi.phi.phi11.phi, align 4
  br label %for.cond33.upper, !llvm.loop !9

for.end48:                                        ; preds = %for.cond33.lower
  %58 = load float, float* %new.sum.phi.phi.phi12.phi, align 4
  %59 = load float*, float** %new.result.addr.phi.phi.phi7.phi, align 8
  %60 = load i32, i32* %new.i.phi.phi.phi9.phi, align 4
  %61 = load i32, i32* %new.size.addr.phi.phi.phi8.phi, align 4
  %mul49 = mul nsw i32 %60, %61
  %62 = load i32, i32* %new.i.phi.phi.phi9.phi, align 4
  %add50 = add nsw i32 %mul49, %62
  %idxprom51 = sext i32 %add50 to i64
  %arrayidx52 = getelementptr inbounds float, float* %59, i64 %idxprom51
  %63 = load float, float* %arrayidx52, align 4
  %div = fdiv float %58, %63
  %64 = load float*, float** %new.result.addr.phi.phi.phi7.phi, align 8
  %65 = load i32, i32* %new.j.phi.phi.phi10.phi, align 4
  %66 = load i32, i32* %new.size.addr.phi.phi.phi8.phi, align 4
  %mul53 = mul nsw i32 %65, %66
  %67 = load i32, i32* %new.i.phi.phi.phi9.phi, align 4
  %add54 = add nsw i32 %mul53, %67
  %idxprom55 = sext i32 %add54 to i64
  %arrayidx56 = getelementptr inbounds float, float* %64, i64 %idxprom55
  store float %div, float* %arrayidx56, align 4
  br label %for.inc57

for.inc57:                                        ; preds = %for.end48
  %68 = load i32, i32* %new.j.phi.phi.phi10.phi, align 4
  %inc58 = add nsw i32 %68, 1
  store i32 %inc58, i32* %new.j.phi.phi.phi10.phi, align 4
  br label %for.cond26.upper, !llvm.loop !10

for.end59:                                        ; preds = %for.cond26.lower
  br label %for.end59.saveBB.id1

for.end59.saveBB.id1:                             ; preds = %for.end59
  %idx_result.addr = getelementptr inbounds float, float* %ckpt_mem, i32 3
  %loaded.result.addr = load float*, float** %new.result.addr.phi.phi.phi7, align 8
  %69 = bitcast float* %idx_result.addr to i8*
  %70 = bitcast float* %loaded.result.addr to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %69, i8* align 8 %70, i64 4194304, i1 true)

  %idx_size.addr = getelementptr inbounds float, float* %ckpt_mem, i32 1048579
  %71 = bitcast float* %idx_size.addr to i8*
  %72 = bitcast i32* %new.size.addr.phi.phi.phi8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %71, i8* align 8 %72, i64 4, i1 true)

  %idx_i = getelementptr inbounds float, float* %ckpt_mem, i32 1048580
  %73 = bitcast float* %idx_i to i8*
  %74 = bitcast i32* %new.i.phi.phi.phi9 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %73, i8* align 8 %74, i64 4, i1 true)

  %idx_j = getelementptr inbounds float, float* %ckpt_mem, i32 1048581
  %75 = bitcast float* %idx_j to i8*
  %76 = bitcast i32* %new.j.phi.phi.phi10 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %75, i8* align 8 %76, i64 4, i1 true)

  %idx_k = getelementptr inbounds float, float* %ckpt_mem, i32 1048582
  %77 = bitcast float* %idx_k to i8*
  %78 = bitcast i32* %new.k.phi.phi.phi11 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %77, i8* align 8 %78, i64 4, i1 true)

  %idx_sum = getelementptr inbounds float, float* %ckpt_mem, i32 1048583
  %79 = bitcast float* %idx_sum to i8*
  %80 = bitcast float* %new.sum.phi.phi.phi12 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %79, i8* align 8 %80, i64 4, i1 true)

  %idx_ckpt_id = getelementptr inbounds float, float* %ckpt_mem, i32 1
  %ckpt_id_float = sitofp i32 1 to float
  store float %ckpt_id_float, float* %idx_ckpt_id, align 4

  %idx_heartbeat = getelementptr inbounds float, float* %ckpt_mem, i32 0
  %load_heartbeat = load float, float* %idx_heartbeat, align 4
  %heartbeat_int = fptosi float %load_heartbeat to i32
  %heartbeat_incr = add i32 %heartbeat_int, 1
  %heartbeat_incr_int = sitofp i32 %heartbeat_incr to float
  store float %heartbeat_incr_int, float* %idx_heartbeat, align 4
  
  br label %for.end59.junctionBB.id1

for.end59.junctionBB.id1:                         ; preds = %for.end59.restoreBB.id1, %for.end59.saveBB.id1
  %new.result.addr = phi float** [ %new.result.addr.phi.phi.phi7, %for.end59.saveBB.id1 ], [ %alloca.result.addr, %for.end59.restoreBB.id1 ]
  %new.size.addr = phi i32* [ %new.size.addr.phi.phi.phi8, %for.end59.saveBB.id1 ], [ %alloca.size.addr, %for.end59.restoreBB.id1 ]
  %new.i = phi i32* [ %new.i.phi.phi.phi9, %for.end59.saveBB.id1 ], [ %alloca.i, %for.end59.restoreBB.id1 ]
  %new.j = phi i32* [ %new.j.phi.phi.phi10, %for.end59.saveBB.id1 ], [ %alloca.j, %for.end59.restoreBB.id1 ]
  %new.k = phi i32* [ %new.k.phi.phi.phi11, %for.end59.saveBB.id1 ], [ %alloca.k, %for.end59.restoreBB.id1 ]
  %new.sum = phi float* [ %new.sum.phi.phi.phi12, %for.end59.saveBB.id1 ], [ %alloca.sum, %for.end59.restoreBB.id1 ]
  br label %for.inc60

for.inc60:                                        ; preds = %for.end59.junctionBB.id1
  %81 = load i32, i32* %new.i, align 4
  %inc61 = add nsw i32 %81, 1
  store i32 %inc61, i32* %new.i, align 4
  br label %for.cond.upper, !llvm.loop !11

for.end62:                                        ; preds = %for.cond.lower
  %82 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx63 = getelementptr inbounds float, float* %82, i64 0
  store float 1.000000e+00, float* %arrayidx63, align 4
  %idx_isComplete = getelementptr inbounds float, float* %ckpt_mem, i32 2
  store float 0.000000e+00, float* %idx_isComplete, align 4
  ret void

for.end59.restoreBB.id1:                          ; preds = %lud.restoreControllerBB
  %idx_result.addr1 = getelementptr inbounds float, float* %ckpt_mem, i32 3
  %alloca.result.addr = alloca float*, align 8
  %alloca_contained.result.addr = alloca float, i32 1048576, align 4
  store float* %alloca_contained.result.addr, float** %alloca.result.addr, align 8
  %83 = bitcast float* %alloca_contained.result.addr to i8*
  %84 = bitcast float* %idx_result.addr1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %83, i8* align 8 %84, i64 4194304, i1 true)
  %idx_size.addr2 = getelementptr inbounds float, float* %ckpt_mem, i32 1048579
  %alloca.size.addr = alloca i32, align 4
  %85 = bitcast i32* %alloca.size.addr to i8*
  %86 = bitcast float* %idx_size.addr2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %85, i8* align 8 %86, i64 4, i1 true)
  %idx_i3 = getelementptr inbounds float, float* %ckpt_mem, i32 1048580
  %alloca.i = alloca i32, align 4
  %87 = bitcast i32* %alloca.i to i8*
  %88 = bitcast float* %idx_i3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %87, i8* align 8 %88, i64 4, i1 true)
  %idx_j4 = getelementptr inbounds float, float* %ckpt_mem, i32 1048581
  %alloca.j = alloca i32, align 4
  %89 = bitcast i32* %alloca.j to i8*
  %90 = bitcast float* %idx_j4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %89, i8* align 8 %90, i64 4, i1 true)
  %idx_k5 = getelementptr inbounds float, float* %ckpt_mem, i32 1048582
  %alloca.k = alloca i32, align 4
  %91 = bitcast i32* %alloca.k to i8*
  %92 = bitcast float* %idx_k5 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %91, i8* align 8 %92, i64 4, i1 true)
  %idx_sum6 = getelementptr inbounds float, float* %ckpt_mem, i32 1048583
  %alloca.sum = alloca float, align 4
  %93 = bitcast float* %alloca.sum to i8*
  %94 = bitcast float* %idx_sum6 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %93, i8* align 8 %94, i64 4, i1 true)
  %idx_heartbeat13 = getelementptr inbounds float, float* %ckpt_mem, i32 0
  %load_heartbeat14 = load float, float* %idx_heartbeat13, align 4
  %heartbeat_int15 = fptosi float %load_heartbeat14 to i32
  %heartbeat_incr16 = add i32 %heartbeat_int15, 1
  %heartbeat_incr_int17 = sitofp i32 %heartbeat_incr16 to float
  store float %heartbeat_incr_int17, float* %idx_heartbeat13, align 4
  br label %for.end59.junctionBB.id1
}

declare i32 @printf(i8* noundef, ...) #1

; Function Attrs: nounwind
declare i32 @getpid() #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #6

; Function Attrs: mustprogress noinline uwtable
define dso_local void @workload(float* noundef %result, i32 noundef %size, float* noundef %ckpt_mem) #5 {
entry:
  %result.addr = alloca float*, align 8
  %size.addr = alloca i32, align 4
  %ckpt_mem.addr = alloca float*, align 8
  %ckpt_id = alloca i32, align 4
  store float* %result, float** %result.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  %0 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %0, i64 2
  %1 = load float, float* %arrayidx, align 4
  %conv = fptosi float %1 to i32
  store i32 %conv, i32* %ckpt_id, align 4
  %2 = load float*, float** %result.addr, align 8
  %3 = load i32, i32* %size.addr, align 4
  %4 = load float*, float** %ckpt_mem.addr, align 8
  %5 = load i32, i32* %ckpt_id, align 4
  call void @lud(float* noundef %2, i32 noundef %3, float* noundef %4, i32 noundef %5)
  ret void
}

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_lud.cpp() #0 section ".text.startup" {
entry:
  call void @__cxx_global_var_init()
  ret void
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #7

attributes #0 = { noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind }
attributes #4 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { argmemonly nofree nounwind willreturn }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.6"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
