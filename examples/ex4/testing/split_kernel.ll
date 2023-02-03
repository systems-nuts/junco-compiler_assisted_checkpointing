; ModuleID = '../../examples/ex4/testing/kernel.ll'
source_filename = "kernel.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [29 x i8] c"Start of function: workload\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"initial=%d\0A\00", align 1
@.str.2 = private unnamed_addr constant [9 x i8] c"Initial \00", align 1
@.str.3 = private unnamed_addr constant [92 x i8] c"process l_id = %d, ckpt_mem ptr %p, heartbeat %d, CKPT_ID %d, VAR_0 %d, VAR_1 %d, VAR_2 %d\0A\00", align 1
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
define dso_local i32 @workload(i32* noundef %ckpt_mem, i32 noundef %initial) #5 {
entry.upper:
  %ckpt_mem.addr = alloca i32*, align 8
  %initial.addr = alloca i32, align 4
  %l_id = alloca i32, align 4
  store i32* %ckpt_mem, i32** %ckpt_mem.addr, align 8
  store i32 %initial, i32* %initial.addr, align 4
  store i32 0, i32* %l_id, align 4
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([29 x i8], [29 x i8]* @.str, i64 0, i64 0))
  %0 = load i32, i32* %initial.addr, align 4
  br label %entry.lower

entry.lower:                                      ; preds = %entry.upper
  %cmp = icmp eq i32 %0, 1
  br i1 %cmp, label %if.then, label %if.end.upper

if.then:                                          ; preds = %entry.lower
  store i32 1, i32* %l_id, align 4
  br label %if.end.upper

if.end.upper:                                     ; preds = %if.then, %entry.lower
  call void @checkpoint()
  %1 = load i32, i32* %initial.addr, align 4
  %call1 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), i32 noundef %1)
  %2 = load i32, i32* %initial.addr, align 4
  br label %if.end.lower

if.end.lower:                                     ; preds = %if.end.upper
  %cmp2 = icmp eq i32 %2, 1
  br i1 %cmp2, label %if.then3, label %if.end5

if.then3:                                         ; preds = %if.end.lower
  %call4 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i64 0, i64 0))
  br label %if.end5

if.end5:                                          ; preds = %if.then3, %if.end.lower
  %3 = load i32, i32* %l_id, align 4
  %4 = load i32*, i32** %ckpt_mem.addr, align 8
  %5 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %5, i64 0
  %6 = load i32, i32* %arrayidx, align 4
  %7 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx6 = getelementptr inbounds i32, i32* %7, i64 1
  %8 = load i32, i32* %arrayidx6, align 4
  %9 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx7 = getelementptr inbounds i32, i32* %9, i64 3
  %10 = load i32, i32* %arrayidx7, align 4
  %11 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx8 = getelementptr inbounds i32, i32* %11, i64 4
  %12 = load i32, i32* %arrayidx8, align 4
  %13 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx9 = getelementptr inbounds i32, i32* %13, i64 5
  %14 = load i32, i32* %arrayidx9, align 4
  %call10 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([92 x i8], [92 x i8]* @.str.3, i64 0, i64 0), i32 noundef %3, i32* noundef %4, i32 noundef %6, i32 noundef %8, i32 noundef %10, i32 noundef %12, i32 noundef %14)
  %15 = load i32, i32* %initial.addr, align 4
  %cmp11 = icmp eq i32 %15, 1
  %16 = zext i1 %cmp11 to i64
  %cond = select i1 %cmp11, i32 0, i32 1
  ret i32 %cond
}

declare i32 @printf(i8* noundef, ...) #1

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_kernel.cpp() #0 section ".text.startup" {
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

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.6"}
