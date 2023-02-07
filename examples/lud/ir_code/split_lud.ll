; ModuleID = '../../examples/lud/ir_code/lud.ll'
source_filename = "lud.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

$_ZSt5roundf = comdat any

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@_ZL9heartbeat = internal global i32 0, align 4
@.str = private unnamed_addr constant [23 x i8] c"restore from index %d\0A\00", align 1
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
define dso_local void @checkpoint(float* noundef %ckpt_mem, i32 noundef %i, float* noundef %result, i32 noundef %size, i32 noundef %id, i8 noundef signext %inst) #4 {
entry:
  %ckpt_mem.addr = alloca float*, align 8
  %i.addr = alloca i32, align 4
  %result.addr = alloca float*, align 8
  %size.addr = alloca i32, align 4
  %id.addr = alloca i32, align 4
  %inst.addr = alloca i8, align 1
  %ind = alloca i32, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  store i32 %i, i32* %i.addr, align 4
  store float* %result, float** %result.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  store i32 %id, i32* %id.addr, align 4
  store i8 %inst, i8* %inst.addr, align 1
  %0 = load i32, i32* @_ZL9heartbeat, align 4
  %inc = add i32 %0, 1
  store i32 %inc, i32* @_ZL9heartbeat, align 4
  %conv = uitofp i32 %0 to float
  %1 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %1, i64 1
  store float %conv, float* %arrayidx, align 4
  %2 = load i32, i32* %id.addr, align 4
  %conv1 = sitofp i32 %2 to float
  %3 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx2 = getelementptr inbounds float, float* %3, i64 2
  store float %conv1, float* %arrayidx2, align 4
  %4 = load i32, i32* %i.addr, align 4
  %conv3 = sitofp i32 %4 to float
  %5 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx4 = getelementptr inbounds float, float* %5, i64 3
  store float %conv3, float* %arrayidx4, align 4
  store i32 0, i32* %ind, align 4
  br label %for.cond.upper

for.cond.upper:                                   ; preds = %for.inc, %entry
  %6 = load i32, i32* %ind, align 4
  %7 = load i32, i32* %size.addr, align 4
  %8 = load i32, i32* %size.addr, align 4
  %mul = mul nsw i32 %7, %8
  br label %for.cond.lower

for.cond.lower:                                   ; preds = %for.cond.upper
  %cmp = icmp slt i32 %6, %mul
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond.lower
  %9 = load float*, float** %result.addr, align 8
  %10 = load i32, i32* %ind, align 4
  %idxprom = sext i32 %10 to i64
  %arrayidx5 = getelementptr inbounds float, float* %9, i64 %idxprom
  %11 = load float, float* %arrayidx5, align 4
  %12 = load float*, float** %ckpt_mem.addr, align 8
  %13 = load i32, i32* %ind, align 4
  %add = add nsw i32 4, %13
  %idxprom6 = sext i32 %add to i64
  %arrayidx7 = getelementptr inbounds float, float* %12, i64 %idxprom6
  store float %11, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %14 = load i32, i32* %ind, align 4
  %inc8 = add nsw i32 %14, 1
  store i32 %inc8, i32* %ind, align 4
  br label %for.cond.upper, !llvm.loop !6

for.end:                                          ; preds = %for.cond.lower
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
  %ind = alloca i32, align 4
  store float* %result, float** %result.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  store i32 %ckpt_id, i32* %ckpt_id.addr, align 4
  %0 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %0, i64 0
  store float 0.000000e+00, float* %arrayidx, align 4
  store i32 0, i32* %init_i, align 4
  %1 = load i32, i32* %ckpt_id.addr, align 4
  br label %entry.lower

entry.lower:                                      ; preds = %entry.upper
  %cmp = icmp eq i32 %1, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry.lower
  %2 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx1 = getelementptr inbounds float, float* %2, i64 3
  %3 = load float, float* %arrayidx1, align 4
  %call = call noundef float @_ZSt5roundf(float noundef %3)
  %add = fadd float %call, 1.000000e+00
  %conv = fptosi float %add to i32
  store i32 %conv, i32* %init_i, align 4
  store i32 0, i32* %ind, align 4
  br label %for.cond.upper

for.cond.upper:                                   ; preds = %for.inc, %if.then
  %4 = load i32, i32* %ind, align 4
  %5 = load i32, i32* %size.addr, align 4
  %6 = load i32, i32* %size.addr, align 4
  %mul = mul nsw i32 %5, %6
  br label %for.cond.lower

for.cond.lower:                                   ; preds = %for.cond.upper
  %cmp2 = icmp slt i32 %4, %mul
  br i1 %cmp2, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond.lower
  %7 = load float*, float** %ckpt_mem.addr, align 8
  %8 = load i32, i32* %ind, align 4
  %add3 = add nsw i32 4, %8
  %idxprom = sext i32 %add3 to i64
  %arrayidx4 = getelementptr inbounds float, float* %7, i64 %idxprom
  %9 = load float, float* %arrayidx4, align 4
  %10 = load float*, float** %result.addr, align 8
  %11 = load i32, i32* %ind, align 4
  %idxprom5 = sext i32 %11 to i64
  %arrayidx6 = getelementptr inbounds float, float* %10, i64 %idxprom5
  store float %9, float* %arrayidx6, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %12 = load i32, i32* %ind, align 4
  %inc = add nsw i32 %12, 1
  store i32 %inc, i32* %ind, align 4
  br label %for.cond.upper, !llvm.loop !8

for.end:                                          ; preds = %for.cond.lower
  %13 = load i32, i32* %init_i, align 4
  %call7 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([23 x i8], [23 x i8]* @.str, i64 0, i64 0), i32 noundef %13)
  br label %if.end

if.end:                                           ; preds = %for.end, %entry.lower
  %14 = load i32, i32* %init_i, align 4
  store i32 %14, i32* %i, align 4
  br label %for.cond8.upper

for.cond8.upper:                                  ; preds = %for.inc75, %if.end
  %15 = load i32, i32* %i, align 4
  %16 = load i32, i32* %size.addr, align 4
  br label %for.cond8.lower

for.cond8.lower:                                  ; preds = %for.cond8.upper
  %cmp9 = icmp slt i32 %15, %16
  br i1 %cmp9, label %for.body10, label %for.end77

for.body10:                                       ; preds = %for.cond8.lower
  %17 = load i32, i32* %i, align 4
  store i32 %17, i32* %j, align 4
  br label %for.cond11.upper

for.cond11.upper:                                 ; preds = %for.inc37, %for.body10
  %18 = load i32, i32* %j, align 4
  %19 = load i32, i32* %size.addr, align 4
  br label %for.cond11.lower

for.cond11.lower:                                 ; preds = %for.cond11.upper
  %cmp12 = icmp slt i32 %18, %19
  br i1 %cmp12, label %for.body13, label %for.end39

for.body13:                                       ; preds = %for.cond11.lower
  %20 = load float*, float** %result.addr, align 8
  %21 = load i32, i32* %i, align 4
  %22 = load i32, i32* %size.addr, align 4
  %mul14 = mul nsw i32 %21, %22
  %23 = load i32, i32* %j, align 4
  %add15 = add nsw i32 %mul14, %23
  %idxprom16 = sext i32 %add15 to i64
  %arrayidx17 = getelementptr inbounds float, float* %20, i64 %idxprom16
  %24 = load float, float* %arrayidx17, align 4
  store float %24, float* %sum, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond18.upper

for.cond18.upper:                                 ; preds = %for.inc30, %for.body13
  %25 = load i32, i32* %k, align 4
  %26 = load i32, i32* %i, align 4
  br label %for.cond18.lower

for.cond18.lower:                                 ; preds = %for.cond18.upper
  %cmp19 = icmp slt i32 %25, %26
  br i1 %cmp19, label %for.body20, label %for.end32

for.body20:                                       ; preds = %for.cond18.lower
  %27 = load float*, float** %result.addr, align 8
  %28 = load i32, i32* %i, align 4
  %29 = load i32, i32* %size.addr, align 4
  %mul21 = mul nsw i32 %28, %29
  %30 = load i32, i32* %k, align 4
  %add22 = add nsw i32 %mul21, %30
  %idxprom23 = sext i32 %add22 to i64
  %arrayidx24 = getelementptr inbounds float, float* %27, i64 %idxprom23
  %31 = load float, float* %arrayidx24, align 4
  %32 = load float*, float** %result.addr, align 8
  %33 = load i32, i32* %k, align 4
  %34 = load i32, i32* %size.addr, align 4
  %mul25 = mul nsw i32 %33, %34
  %35 = load i32, i32* %j, align 4
  %add26 = add nsw i32 %mul25, %35
  %idxprom27 = sext i32 %add26 to i64
  %arrayidx28 = getelementptr inbounds float, float* %32, i64 %idxprom27
  %36 = load float, float* %arrayidx28, align 4
  %37 = load float, float* %sum, align 4
  %neg = fneg float %31
  %38 = call float @llvm.fmuladd.f32(float %neg, float %36, float %37)
  store float %38, float* %sum, align 4
  br label %for.inc30

for.inc30:                                        ; preds = %for.body20
  %39 = load i32, i32* %k, align 4
  %inc31 = add nsw i32 %39, 1
  store i32 %inc31, i32* %k, align 4
  br label %for.cond18.upper, !llvm.loop !9

for.end32:                                        ; preds = %for.cond18.lower
  %40 = load float, float* %sum, align 4
  %41 = load float*, float** %result.addr, align 8
  %42 = load i32, i32* %i, align 4
  %43 = load i32, i32* %size.addr, align 4
  %mul33 = mul nsw i32 %42, %43
  %44 = load i32, i32* %j, align 4
  %add34 = add nsw i32 %mul33, %44
  %idxprom35 = sext i32 %add34 to i64
  %arrayidx36 = getelementptr inbounds float, float* %41, i64 %idxprom35
  store float %40, float* %arrayidx36, align 4
  br label %for.inc37

for.inc37:                                        ; preds = %for.end32
  %45 = load i32, i32* %j, align 4
  %inc38 = add nsw i32 %45, 1
  store i32 %inc38, i32* %j, align 4
  br label %for.cond11.upper, !llvm.loop !10

for.end39:                                        ; preds = %for.cond11.lower
  %46 = load i32, i32* %i, align 4
  %add40 = add nsw i32 %46, 1
  store i32 %add40, i32* %j, align 4
  br label %for.cond41.upper

for.cond41.upper:                                 ; preds = %for.inc72, %for.end39
  %47 = load i32, i32* %j, align 4
  %48 = load i32, i32* %size.addr, align 4
  br label %for.cond41.lower

for.cond41.lower:                                 ; preds = %for.cond41.upper
  %cmp42 = icmp slt i32 %47, %48
  br i1 %cmp42, label %for.body43, label %for.end74

for.body43:                                       ; preds = %for.cond41.lower
  %49 = load float*, float** %result.addr, align 8
  %50 = load i32, i32* %j, align 4
  %51 = load i32, i32* %size.addr, align 4
  %mul44 = mul nsw i32 %50, %51
  %52 = load i32, i32* %i, align 4
  %add45 = add nsw i32 %mul44, %52
  %idxprom46 = sext i32 %add45 to i64
  %arrayidx47 = getelementptr inbounds float, float* %49, i64 %idxprom46
  %53 = load float, float* %arrayidx47, align 4
  store float %53, float* %sum, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond48.upper

for.cond48.upper:                                 ; preds = %for.inc61, %for.body43
  %54 = load i32, i32* %k, align 4
  %55 = load i32, i32* %i, align 4
  br label %for.cond48.lower

for.cond48.lower:                                 ; preds = %for.cond48.upper
  %cmp49 = icmp slt i32 %54, %55
  br i1 %cmp49, label %for.body50, label %for.end63

for.body50:                                       ; preds = %for.cond48.lower
  %56 = load float*, float** %result.addr, align 8
  %57 = load i32, i32* %j, align 4
  %58 = load i32, i32* %size.addr, align 4
  %mul51 = mul nsw i32 %57, %58
  %59 = load i32, i32* %k, align 4
  %add52 = add nsw i32 %mul51, %59
  %idxprom53 = sext i32 %add52 to i64
  %arrayidx54 = getelementptr inbounds float, float* %56, i64 %idxprom53
  %60 = load float, float* %arrayidx54, align 4
  %61 = load float*, float** %result.addr, align 8
  %62 = load i32, i32* %k, align 4
  %63 = load i32, i32* %size.addr, align 4
  %mul55 = mul nsw i32 %62, %63
  %64 = load i32, i32* %i, align 4
  %add56 = add nsw i32 %mul55, %64
  %idxprom57 = sext i32 %add56 to i64
  %arrayidx58 = getelementptr inbounds float, float* %61, i64 %idxprom57
  %65 = load float, float* %arrayidx58, align 4
  %66 = load float, float* %sum, align 4
  %neg60 = fneg float %60
  %67 = call float @llvm.fmuladd.f32(float %neg60, float %65, float %66)
  store float %67, float* %sum, align 4
  br label %for.inc61

for.inc61:                                        ; preds = %for.body50
  %68 = load i32, i32* %k, align 4
  %inc62 = add nsw i32 %68, 1
  store i32 %inc62, i32* %k, align 4
  br label %for.cond48.upper, !llvm.loop !11

for.end63:                                        ; preds = %for.cond48.lower
  %69 = load float, float* %sum, align 4
  %70 = load float*, float** %result.addr, align 8
  %71 = load i32, i32* %i, align 4
  %72 = load i32, i32* %size.addr, align 4
  %mul64 = mul nsw i32 %71, %72
  %73 = load i32, i32* %i, align 4
  %add65 = add nsw i32 %mul64, %73
  %idxprom66 = sext i32 %add65 to i64
  %arrayidx67 = getelementptr inbounds float, float* %70, i64 %idxprom66
  %74 = load float, float* %arrayidx67, align 4
  %div = fdiv float %69, %74
  %75 = load float*, float** %result.addr, align 8
  %76 = load i32, i32* %j, align 4
  %77 = load i32, i32* %size.addr, align 4
  %mul68 = mul nsw i32 %76, %77
  %78 = load i32, i32* %i, align 4
  %add69 = add nsw i32 %mul68, %78
  %idxprom70 = sext i32 %add69 to i64
  %arrayidx71 = getelementptr inbounds float, float* %75, i64 %idxprom70
  store float %div, float* %arrayidx71, align 4
  br label %for.inc72

for.inc72:                                        ; preds = %for.end63
  %79 = load i32, i32* %j, align 4
  %inc73 = add nsw i32 %79, 1
  store i32 %inc73, i32* %j, align 4
  br label %for.cond41.upper, !llvm.loop !12

for.end74:                                        ; preds = %for.cond41.lower
  br label %for.inc75

for.inc75:                                        ; preds = %for.end74
  %80 = load i32, i32* %i, align 4
  %inc76 = add nsw i32 %80, 1
  store i32 %inc76, i32* %i, align 4
  br label %for.cond8.upper, !llvm.loop !13

for.end77:                                        ; preds = %for.cond8.lower
  %81 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx78 = getelementptr inbounds float, float* %81, i64 0
  store float 1.000000e+00, float* %arrayidx78, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef float @_ZSt5roundf(float noundef %__x) #4 comdat {
entry:
  %__x.addr = alloca float, align 4
  store float %__x, float* %__x.addr, align 4
  %0 = load float, float* %__x.addr, align 4
  %1 = call float @llvm.round.f32(float %0)
  ret float %1
}

declare i32 @printf(i8* noundef, ...) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #6

; Function Attrs: mustprogress noinline uwtable
define dso_local void @workload(float* noundef %result, i32 noundef %size, float* noundef %ckpt_mem) #5 {
entry:
  %result.addr = alloca float*, align 8
  %size.addr = alloca i32, align 4
  %ckpt_mem.addr = alloca float*, align 8
  store float* %result, float** %result.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  %0 = load float*, float** %result.addr, align 8
  %1 = load i32, i32* %size.addr, align 4
  %2 = load float*, float** %ckpt_mem.addr, align 8
  %3 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 2
  %4 = load float, float* %arrayidx, align 4
  %conv = fptosi float %4 to i32
  call void @lud(float* noundef %0, i32 noundef %1, float* noundef %2, i32 noundef %conv)
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.round.f32(float) #6

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_lud.cpp() #0 section ".text.startup" {
entry:
  call void @__cxx_global_var_init()
  ret void
}

attributes #0 = { noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind }
attributes #4 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nofree nosync nounwind readnone speculatable willreturn }

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
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
