; ModuleID = '../../examples/ex2/testing2/split_kernel2.ll'
source_filename = "kernel.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [29 x i8] c"Start of function: workload\0A\00", align 1
@.str.1 = private unnamed_addr constant [39 x i8] c"The task has been restored! l_id = %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [43 x i8] c"The task has NOT been restored! l_id = %d\0A\00", align 1
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
define dso_local i32 @workload(i32* noundef %ckpt_mem) #5 {
entry.upper:
  %retval = alloca i32, align 4
  %ckpt_mem.addr = alloca i32*, align 8
  %l_id = alloca i32, align 4
  store i32* %ckpt_mem, i32** %ckpt_mem.addr, align 8
  store i32 0, i32* %l_id, align 4
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([29 x i8], [29 x i8]* @.str, i64 0, i64 0))
  %0 = load i32, i32* %l_id, align 4
  br label %workload.restoreControllerBB

workload.restoreControllerBB:                     ; preds = %entry.upper
  %idx_ckpt_id_load = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  %load.ckpt_id = load i32, i32* %idx_ckpt_id_load, align 4
  switch i32 %load.ckpt_id, label %entry.lower [
    i32 1, label %if.else.restoreBB.id1
  ]

entry.lower:                                      ; preds = %workload.restoreControllerBB
  %cmp = icmp ne i32 %0, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry.lower
  %1 = load i32, i32* %l_id, align 4
  %call1 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([39 x i8], [39 x i8]* @.str.1, i64 0, i64 0), i32 noundef %1)
  store i32 1, i32* %retval, align 4
  br label %return

if.else:                                          ; preds = %entry.lower
  %2 = load i32, i32* %l_id, align 4
  %call2 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([43 x i8], [43 x i8]* @.str.2, i64 0, i64 0), i32 noundef %2)
  store i32 1, i32* %l_id, align 4
  store i32 0, i32* %retval, align 4
  br label %if.else.saveBB.id1

if.else.saveBB.id1:                               ; preds = %if.else
  %deref_retval = load i32, i32* %retval, align 4
  %idx_retval = getelementptr inbounds i32, i32* %ckpt_mem, i32 2
  store i32 %deref_retval, i32* %idx_retval, align 4
  %idx_iscomplete = getelementptr inbounds i32, i32* %ckpt_mem, i32 1
  store i32 1, i32* %idx_iscomplete, align 4
  %idx_ckpt_id = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  store i32 1, i32* %idx_ckpt_id, align 4
  br label %if.else.junctionBB.id1

if.else.junctionBB.id1:                           ; preds = %if.else.restoreBB.id1, %if.else.saveBB.id1
  %new.retval = phi i32* [ %retval, %if.else.saveBB.id1 ], [ %alloca.retval, %if.else.restoreBB.id1 ]
  br label %return

return:                                           ; preds = %if.else.junctionBB.id1, %if.then
  %new.retval.phi = phi i32* [ %new.retval, %if.else.junctionBB.id1 ], [ %retval, %if.then ]
  %3 = load i32, i32* %new.retval.phi, align 4
  ret i32 %3

if.else.restoreBB.id1:                            ; preds = %workload.restoreControllerBB
  %idx_retval1 = getelementptr inbounds i32, i32* %ckpt_mem, i32 2
  %load.retval = load i32, i32* %idx_retval1, align 4
  %alloca.retval = alloca i32, align 4
  store i32 %load.retval, i32* %alloca.retval, align 4
  br label %if.else.junctionBB.id1
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
