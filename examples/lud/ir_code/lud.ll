; ModuleID = '../lud.cpp'
source_filename = "../lud.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
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

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @lud(float* noundef %result, i32 noundef %size, float* noundef %ckpt_mem, i32 noundef %ckpt_id) #4 {
entry:
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
  %1 = load i32, i32* %init_i, align 4
  store i32 %1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc59, %entry
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %size.addr, align 4
  %cmp = icmp slt i32 %2, %3
  br i1 %cmp, label %for.body, label %for.end61

for.body:                                         ; preds = %for.cond
  %4 = load i32, i32* %i, align 4
  store i32 %4, i32* %j, align 4
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc21, %for.body
  %5 = load i32, i32* %j, align 4
  %6 = load i32, i32* %size.addr, align 4
  %cmp2 = icmp slt i32 %5, %6
  br i1 %cmp2, label %for.body3, label %for.end23

for.body3:                                        ; preds = %for.cond1
  %7 = load float*, float** %result.addr, align 8
  %8 = load i32, i32* %i, align 4
  %9 = load i32, i32* %size.addr, align 4
  %mul = mul nsw i32 %8, %9
  %10 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %10
  %idxprom = sext i32 %add to i64
  %arrayidx4 = getelementptr inbounds float, float* %7, i64 %idxprom
  %11 = load float, float* %arrayidx4, align 4
  store float %11, float* %sum, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond5

for.cond5:                                        ; preds = %for.inc, %for.body3
  %12 = load i32, i32* %k, align 4
  %13 = load i32, i32* %i, align 4
  %cmp6 = icmp slt i32 %12, %13
  br i1 %cmp6, label %for.body7, label %for.end

for.body7:                                        ; preds = %for.cond5
  %14 = load float*, float** %result.addr, align 8
  %15 = load i32, i32* %i, align 4
  %16 = load i32, i32* %size.addr, align 4
  %mul8 = mul nsw i32 %15, %16
  %17 = load i32, i32* %k, align 4
  %add9 = add nsw i32 %mul8, %17
  %idxprom10 = sext i32 %add9 to i64
  %arrayidx11 = getelementptr inbounds float, float* %14, i64 %idxprom10
  %18 = load float, float* %arrayidx11, align 4
  %19 = load float*, float** %result.addr, align 8
  %20 = load i32, i32* %k, align 4
  %21 = load i32, i32* %size.addr, align 4
  %mul12 = mul nsw i32 %20, %21
  %22 = load i32, i32* %j, align 4
  %add13 = add nsw i32 %mul12, %22
  %idxprom14 = sext i32 %add13 to i64
  %arrayidx15 = getelementptr inbounds float, float* %19, i64 %idxprom14
  %23 = load float, float* %arrayidx15, align 4
  %24 = load float, float* %sum, align 4
  %neg = fneg float %18
  %25 = call float @llvm.fmuladd.f32(float %neg, float %23, float %24)
  store float %25, float* %sum, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body7
  %26 = load i32, i32* %k, align 4
  %inc = add nsw i32 %26, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond5, !llvm.loop !6

for.end:                                          ; preds = %for.cond5
  %27 = load float, float* %sum, align 4
  %28 = load float*, float** %result.addr, align 8
  %29 = load i32, i32* %i, align 4
  %30 = load i32, i32* %size.addr, align 4
  %mul17 = mul nsw i32 %29, %30
  %31 = load i32, i32* %j, align 4
  %add18 = add nsw i32 %mul17, %31
  %idxprom19 = sext i32 %add18 to i64
  %arrayidx20 = getelementptr inbounds float, float* %28, i64 %idxprom19
  store float %27, float* %arrayidx20, align 4
  br label %for.inc21

for.inc21:                                        ; preds = %for.end
  %32 = load i32, i32* %j, align 4
  %inc22 = add nsw i32 %32, 1
  store i32 %inc22, i32* %j, align 4
  br label %for.cond1, !llvm.loop !8

for.end23:                                        ; preds = %for.cond1
  %33 = load i32, i32* %i, align 4
  %add24 = add nsw i32 %33, 1
  store i32 %add24, i32* %j, align 4
  br label %for.cond25

for.cond25:                                       ; preds = %for.inc56, %for.end23
  %34 = load i32, i32* %j, align 4
  %35 = load i32, i32* %size.addr, align 4
  %cmp26 = icmp slt i32 %34, %35
  br i1 %cmp26, label %for.body27, label %for.end58

for.body27:                                       ; preds = %for.cond25
  %36 = load float*, float** %result.addr, align 8
  %37 = load i32, i32* %j, align 4
  %38 = load i32, i32* %size.addr, align 4
  %mul28 = mul nsw i32 %37, %38
  %39 = load i32, i32* %i, align 4
  %add29 = add nsw i32 %mul28, %39
  %idxprom30 = sext i32 %add29 to i64
  %arrayidx31 = getelementptr inbounds float, float* %36, i64 %idxprom30
  %40 = load float, float* %arrayidx31, align 4
  store float %40, float* %sum, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond32

for.cond32:                                       ; preds = %for.inc45, %for.body27
  %41 = load i32, i32* %k, align 4
  %42 = load i32, i32* %i, align 4
  %cmp33 = icmp slt i32 %41, %42
  br i1 %cmp33, label %for.body34, label %for.end47

for.body34:                                       ; preds = %for.cond32
  %43 = load float*, float** %result.addr, align 8
  %44 = load i32, i32* %j, align 4
  %45 = load i32, i32* %size.addr, align 4
  %mul35 = mul nsw i32 %44, %45
  %46 = load i32, i32* %k, align 4
  %add36 = add nsw i32 %mul35, %46
  %idxprom37 = sext i32 %add36 to i64
  %arrayidx38 = getelementptr inbounds float, float* %43, i64 %idxprom37
  %47 = load float, float* %arrayidx38, align 4
  %48 = load float*, float** %result.addr, align 8
  %49 = load i32, i32* %k, align 4
  %50 = load i32, i32* %size.addr, align 4
  %mul39 = mul nsw i32 %49, %50
  %51 = load i32, i32* %i, align 4
  %add40 = add nsw i32 %mul39, %51
  %idxprom41 = sext i32 %add40 to i64
  %arrayidx42 = getelementptr inbounds float, float* %48, i64 %idxprom41
  %52 = load float, float* %arrayidx42, align 4
  %53 = load float, float* %sum, align 4
  %neg44 = fneg float %47
  %54 = call float @llvm.fmuladd.f32(float %neg44, float %52, float %53)
  store float %54, float* %sum, align 4
  br label %for.inc45

for.inc45:                                        ; preds = %for.body34
  %55 = load i32, i32* %k, align 4
  %inc46 = add nsw i32 %55, 1
  store i32 %inc46, i32* %k, align 4
  br label %for.cond32, !llvm.loop !9

for.end47:                                        ; preds = %for.cond32
  %56 = load float, float* %sum, align 4
  %57 = load float*, float** %result.addr, align 8
  %58 = load i32, i32* %i, align 4
  %59 = load i32, i32* %size.addr, align 4
  %mul48 = mul nsw i32 %58, %59
  %60 = load i32, i32* %i, align 4
  %add49 = add nsw i32 %mul48, %60
  %idxprom50 = sext i32 %add49 to i64
  %arrayidx51 = getelementptr inbounds float, float* %57, i64 %idxprom50
  %61 = load float, float* %arrayidx51, align 4
  %div = fdiv float %56, %61
  %62 = load float*, float** %result.addr, align 8
  %63 = load i32, i32* %j, align 4
  %64 = load i32, i32* %size.addr, align 4
  %mul52 = mul nsw i32 %63, %64
  %65 = load i32, i32* %i, align 4
  %add53 = add nsw i32 %mul52, %65
  %idxprom54 = sext i32 %add53 to i64
  %arrayidx55 = getelementptr inbounds float, float* %62, i64 %idxprom54
  store float %div, float* %arrayidx55, align 4
  br label %for.inc56

for.inc56:                                        ; preds = %for.end47
  %66 = load i32, i32* %j, align 4
  %inc57 = add nsw i32 %66, 1
  store i32 %inc57, i32* %j, align 4
  br label %for.cond25, !llvm.loop !10

for.end58:                                        ; preds = %for.cond25
  call void @checkpoint()
  br label %for.inc59

for.inc59:                                        ; preds = %for.end58
  %67 = load i32, i32* %i, align 4
  %inc60 = add nsw i32 %67, 1
  store i32 %inc60, i32* %i, align 4
  br label %for.cond, !llvm.loop !11

for.end61:                                        ; preds = %for.cond
  %68 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx62 = getelementptr inbounds float, float* %68, i64 0
  store float 1.000000e+00, float* %arrayidx62, align 4
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #5

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @workload(float* noundef %result, i32 noundef %size, float* noundef %ckpt_mem) #4 {
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

attributes #0 = { noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind }
attributes #4 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nofree nosync nounwind readnone speculatable willreturn }

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
