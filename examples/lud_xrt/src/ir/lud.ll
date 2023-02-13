; ModuleID = 'lud.cpp'
source_filename = "lud.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [51 x i8] c">> lud: run from process PID = %d (ckpt id %d) %p\0A\00", align 1
@.str.1 = private unnamed_addr constant [29 x i8] c">> lud: i=%d, result[%d]=%f\0A\00", align 1
@.str.2 = private unnamed_addr constant [4 x i8] c">>\0A\00", align 1
@.str.3 = private unnamed_addr constant [27 x i8] c"\0A>> lud: after checkpoint\0A\00", align 1
@.str.4 = private unnamed_addr constant [31 x i8] c"> workload: Starting workload\0A\00", align 1
@.str.5 = private unnamed_addr constant [26 x i8] c"> workoad: result[%d]=%f\0A\00", align 1
@.str.6 = private unnamed_addr constant [27 x i8] c"> workload: isComplete=%f\0A\00", align 1
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
  %p = alloca i32, align 4
  store float* %result, float** %result.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  store i32 %ckpt_id, i32* %ckpt_id.addr, align 4
  store i32 0, i32* %init_i, align 4
  %call = call i32 @getpid() #3
  %0 = load i32, i32* %ckpt_id.addr, align 4
  %1 = load float*, float** %ckpt_mem.addr, align 8
  %call1 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([51 x i8], [51 x i8]* @.str, i64 0, i64 0), i32 noundef %call, i32 noundef %0, float* noundef %1)
  %2 = load i32, i32* %init_i, align 4
  store i32 %2, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc70, %entry
  %3 = load i32, i32* %i, align 4
  %4 = load i32, i32* %size.addr, align 4
  %cmp = icmp slt i32 %3, %4
  br i1 %cmp, label %for.body, label %for.end72

for.body:                                         ; preds = %for.cond
  %5 = load i32, i32* %i, align 4
  store i32 %5, i32* %j, align 4
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc21, %for.body
  %6 = load i32, i32* %j, align 4
  %7 = load i32, i32* %size.addr, align 4
  %cmp3 = icmp slt i32 %6, %7
  br i1 %cmp3, label %for.body4, label %for.end23

for.body4:                                        ; preds = %for.cond2
  %8 = load float*, float** %result.addr, align 8
  %9 = load i32, i32* %i, align 4
  %10 = load i32, i32* %size.addr, align 4
  %mul = mul nsw i32 %9, %10
  %11 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %11
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %8, i64 %idxprom
  %12 = load float, float* %arrayidx, align 4
  store float %12, float* %sum, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond5

for.cond5:                                        ; preds = %for.inc, %for.body4
  %13 = load i32, i32* %k, align 4
  %14 = load i32, i32* %i, align 4
  %cmp6 = icmp slt i32 %13, %14
  br i1 %cmp6, label %for.body7, label %for.end

for.body7:                                        ; preds = %for.cond5
  %15 = load float*, float** %result.addr, align 8
  %16 = load i32, i32* %i, align 4
  %17 = load i32, i32* %size.addr, align 4
  %mul8 = mul nsw i32 %16, %17
  %18 = load i32, i32* %k, align 4
  %add9 = add nsw i32 %mul8, %18
  %idxprom10 = sext i32 %add9 to i64
  %arrayidx11 = getelementptr inbounds float, float* %15, i64 %idxprom10
  %19 = load float, float* %arrayidx11, align 4
  %20 = load float*, float** %result.addr, align 8
  %21 = load i32, i32* %k, align 4
  %22 = load i32, i32* %size.addr, align 4
  %mul12 = mul nsw i32 %21, %22
  %23 = load i32, i32* %j, align 4
  %add13 = add nsw i32 %mul12, %23
  %idxprom14 = sext i32 %add13 to i64
  %arrayidx15 = getelementptr inbounds float, float* %20, i64 %idxprom14
  %24 = load float, float* %arrayidx15, align 4
  %25 = load float, float* %sum, align 4
  %neg = fneg float %19
  %26 = call float @llvm.fmuladd.f32(float %neg, float %24, float %25)
  store float %26, float* %sum, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body7
  %27 = load i32, i32* %k, align 4
  %inc = add nsw i32 %27, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond5, !llvm.loop !6

for.end:                                          ; preds = %for.cond5
  %28 = load float, float* %sum, align 4
  %29 = load float*, float** %result.addr, align 8
  %30 = load i32, i32* %i, align 4
  %31 = load i32, i32* %size.addr, align 4
  %mul17 = mul nsw i32 %30, %31
  %32 = load i32, i32* %j, align 4
  %add18 = add nsw i32 %mul17, %32
  %idxprom19 = sext i32 %add18 to i64
  %arrayidx20 = getelementptr inbounds float, float* %29, i64 %idxprom19
  store float %28, float* %arrayidx20, align 4
  br label %for.inc21

for.inc21:                                        ; preds = %for.end
  %33 = load i32, i32* %j, align 4
  %inc22 = add nsw i32 %33, 1
  store i32 %inc22, i32* %j, align 4
  br label %for.cond2, !llvm.loop !8

for.end23:                                        ; preds = %for.cond2
  %34 = load i32, i32* %i, align 4
  %add24 = add nsw i32 %34, 1
  store i32 %add24, i32* %j, align 4
  br label %for.cond25

for.cond25:                                       ; preds = %for.inc56, %for.end23
  %35 = load i32, i32* %j, align 4
  %36 = load i32, i32* %size.addr, align 4
  %cmp26 = icmp slt i32 %35, %36
  br i1 %cmp26, label %for.body27, label %for.end58

for.body27:                                       ; preds = %for.cond25
  %37 = load float*, float** %result.addr, align 8
  %38 = load i32, i32* %j, align 4
  %39 = load i32, i32* %size.addr, align 4
  %mul28 = mul nsw i32 %38, %39
  %40 = load i32, i32* %i, align 4
  %add29 = add nsw i32 %mul28, %40
  %idxprom30 = sext i32 %add29 to i64
  %arrayidx31 = getelementptr inbounds float, float* %37, i64 %idxprom30
  %41 = load float, float* %arrayidx31, align 4
  store float %41, float* %sum, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond32

for.cond32:                                       ; preds = %for.inc45, %for.body27
  %42 = load i32, i32* %k, align 4
  %43 = load i32, i32* %i, align 4
  %cmp33 = icmp slt i32 %42, %43
  br i1 %cmp33, label %for.body34, label %for.end47

for.body34:                                       ; preds = %for.cond32
  %44 = load float*, float** %result.addr, align 8
  %45 = load i32, i32* %j, align 4
  %46 = load i32, i32* %size.addr, align 4
  %mul35 = mul nsw i32 %45, %46
  %47 = load i32, i32* %k, align 4
  %add36 = add nsw i32 %mul35, %47
  %idxprom37 = sext i32 %add36 to i64
  %arrayidx38 = getelementptr inbounds float, float* %44, i64 %idxprom37
  %48 = load float, float* %arrayidx38, align 4
  %49 = load float*, float** %result.addr, align 8
  %50 = load i32, i32* %k, align 4
  %51 = load i32, i32* %size.addr, align 4
  %mul39 = mul nsw i32 %50, %51
  %52 = load i32, i32* %i, align 4
  %add40 = add nsw i32 %mul39, %52
  %idxprom41 = sext i32 %add40 to i64
  %arrayidx42 = getelementptr inbounds float, float* %49, i64 %idxprom41
  %53 = load float, float* %arrayidx42, align 4
  %54 = load float, float* %sum, align 4
  %neg44 = fneg float %48
  %55 = call float @llvm.fmuladd.f32(float %neg44, float %53, float %54)
  store float %55, float* %sum, align 4
  br label %for.inc45

for.inc45:                                        ; preds = %for.body34
  %56 = load i32, i32* %k, align 4
  %inc46 = add nsw i32 %56, 1
  store i32 %inc46, i32* %k, align 4
  br label %for.cond32, !llvm.loop !9

for.end47:                                        ; preds = %for.cond32
  %57 = load float, float* %sum, align 4
  %58 = load float*, float** %result.addr, align 8
  %59 = load i32, i32* %i, align 4
  %60 = load i32, i32* %size.addr, align 4
  %mul48 = mul nsw i32 %59, %60
  %61 = load i32, i32* %i, align 4
  %add49 = add nsw i32 %mul48, %61
  %idxprom50 = sext i32 %add49 to i64
  %arrayidx51 = getelementptr inbounds float, float* %58, i64 %idxprom50
  %62 = load float, float* %arrayidx51, align 4
  %div = fdiv float %57, %62
  %63 = load float*, float** %result.addr, align 8
  %64 = load i32, i32* %j, align 4
  %65 = load i32, i32* %size.addr, align 4
  %mul52 = mul nsw i32 %64, %65
  %66 = load i32, i32* %i, align 4
  %add53 = add nsw i32 %mul52, %66
  %idxprom54 = sext i32 %add53 to i64
  %arrayidx55 = getelementptr inbounds float, float* %63, i64 %idxprom54
  store float %div, float* %arrayidx55, align 4
  br label %for.inc56

for.inc56:                                        ; preds = %for.end47
  %67 = load i32, i32* %j, align 4
  %inc57 = add nsw i32 %67, 1
  store i32 %inc57, i32* %j, align 4
  br label %for.cond25, !llvm.loop !10

for.end58:                                        ; preds = %for.cond25
  store i32 0, i32* %p, align 4
  br label %for.cond59

for.cond59:                                       ; preds = %for.inc66, %for.end58
  %68 = load i32, i32* %p, align 4
  %69 = load i32, i32* %size.addr, align 4
  %70 = load i32, i32* %size.addr, align 4
  %mul60 = mul nsw i32 %69, %70
  %cmp61 = icmp slt i32 %68, %mul60
  br i1 %cmp61, label %for.body62, label %for.end68

for.body62:                                       ; preds = %for.cond59
  %71 = load i32, i32* %i, align 4
  %72 = load i32, i32* %p, align 4
  %73 = load float*, float** %result.addr, align 8
  %74 = load i32, i32* %p, align 4
  %idxprom63 = sext i32 %74 to i64
  %arrayidx64 = getelementptr inbounds float, float* %73, i64 %idxprom63
  %75 = load float, float* %arrayidx64, align 4
  %conv = fpext float %75 to double
  %call65 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([29 x i8], [29 x i8]* @.str.1, i64 0, i64 0), i32 noundef %71, i32 noundef %72, double noundef %conv)
  br label %for.inc66

for.inc66:                                        ; preds = %for.body62
  %76 = load i32, i32* %p, align 4
  %inc67 = add nsw i32 %76, 1
  store i32 %inc67, i32* %p, align 4
  br label %for.cond59, !llvm.loop !11

for.end68:                                        ; preds = %for.cond59
  call void @checkpoint()
  %call69 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([4 x i8], [4 x i8]* @.str.2, i64 0, i64 0))
  br label %for.inc70

for.inc70:                                        ; preds = %for.end68
  %77 = load i32, i32* %i, align 4
  %inc71 = add nsw i32 %77, 1
  store i32 %inc71, i32* %i, align 4
  br label %for.cond, !llvm.loop !12

for.end72:                                        ; preds = %for.cond
  %call73 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([27 x i8], [27 x i8]* @.str.3, i64 0, i64 0))
  ret void
}

declare i32 @printf(i8* noundef, ...) #1

; Function Attrs: nounwind
declare i32 @getpid() #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #6

; Function Attrs: mustprogress noinline uwtable
define dso_local i32 @workload(float* noundef %result, i32 noundef %size, float* noundef %ckpt_mem, i32 noundef %initial) #5 {
entry:
  %result.addr = alloca float*, align 8
  %size.addr = alloca i32, align 4
  %ckpt_mem.addr = alloca float*, align 8
  %initial.addr = alloca i32, align 4
  %ckpt_id = alloca i32, align 4
  %p = alloca i32, align 4
  store float* %result, float** %result.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  store i32 %initial, i32* %initial.addr, align 4
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([31 x i8], [31 x i8]* @.str.4, i64 0, i64 0))
  %0 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %0, i64 1
  %1 = load float, float* %arrayidx, align 4
  %conv = fptosi float %1 to i32
  store i32 %conv, i32* %ckpt_id, align 4
  %2 = load float*, float** %result.addr, align 8
  %3 = load i32, i32* %size.addr, align 4
  %4 = load float*, float** %ckpt_mem.addr, align 8
  %5 = load i32, i32* %ckpt_id, align 4
  call void @lud(float* noundef %2, i32 noundef %3, float* noundef %4, i32 noundef %5)
  %6 = load i32, i32* %initial.addr, align 4
  %cmp = icmp eq i32 %6, 1
  %7 = zext i1 %cmp to i64
  %cond = select i1 %cmp, i32 0, i32 1
  %conv1 = sitofp i32 %cond to float
  %8 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx2 = getelementptr inbounds float, float* %8, i64 2
  store float %conv1, float* %arrayidx2, align 4
  store i32 0, i32* %p, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %9 = load i32, i32* %p, align 4
  %10 = load i32, i32* %size.addr, align 4
  %11 = load i32, i32* %size.addr, align 4
  %mul = mul nsw i32 %10, %11
  %cmp3 = icmp slt i32 %9, %mul
  br i1 %cmp3, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %12 = load i32, i32* %p, align 4
  %13 = load float*, float** %result.addr, align 8
  %14 = load i32, i32* %p, align 4
  %idxprom = sext i32 %14 to i64
  %arrayidx4 = getelementptr inbounds float, float* %13, i64 %idxprom
  %15 = load float, float* %arrayidx4, align 4
  %conv5 = fpext float %15 to double
  %call6 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([26 x i8], [26 x i8]* @.str.5, i64 0, i64 0), i32 noundef %12, double noundef %conv5)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %16 = load i32, i32* %p, align 4
  %inc = add nsw i32 %16, 1
  store i32 %inc, i32* %p, align 4
  br label %for.cond, !llvm.loop !13

for.end:                                          ; preds = %for.cond
  %17 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %17, i64 2
  %18 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %18 to double
  %call9 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([27 x i8], [27 x i8]* @.str.6, i64 0, i64 0), double noundef %conv8)
  %19 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %19, i64 2
  %20 = load float, float* %arrayidx10, align 4
  %conv11 = fptosi float %20 to i32
  ret i32 %conv11
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
