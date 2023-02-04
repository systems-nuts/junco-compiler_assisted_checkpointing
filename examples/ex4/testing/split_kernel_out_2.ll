; ModuleID = '../../examples/ex4/testing/split_kernel.ll'
source_filename = "kernel.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [29 x i8] c"Start of function: workload\0A\00", align 1
@.str.1 = private unnamed_addr constant [35 x i8] c"initial=%d, arr[0]=%d, arr[1]]=%d\0A\00", align 1
@.str.2 = private unnamed_addr constant [9 x i8] c"Initial \00", align 1
@.str.3 = private unnamed_addr constant [26 x i8] c"arr[0] = %d, arr[1] = %d\0A\00", align 1
@.str.4 = private unnamed_addr constant [112 x i8] c"process l_id = %d, ckpt_mem ptr %p, heartbeat %d, CKPT_ID %d, VAR_0 %d, VAR_1 %d, VAR_2 %d, VAR_3 %d, VAR_4 %d\0A\00", align 1
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
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([29 x i8], [29 x i8]* @.str, i64 0, i64 0))
  %0 = load i32, i32* %initial.addr, align 4
  br label %workload.restoreControllerBB

workload.restoreControllerBB:                     ; preds = %entry.upper
  %idx_ckpt_id_load = getelementptr inbounds i32, i32* %ckpt_mem, i32 1
  %load.ckpt_id = load i32, i32* %idx_ckpt_id_load, align 4
  switch i32 %load.ckpt_id, label %entry.lower [
    i32 1, label %if.end.upper.restoreBB.id1
  ]

entry.lower:                                      ; preds = %workload.restoreControllerBB
  %cmp = icmp eq i32 %0, 1
  br i1 %cmp, label %if.then, label %if.end.upper

if.then:                                          ; preds = %entry.lower
  store i32 7, i32* %l_id, align 4
  %1 = load i32*, i32** %arr.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %1, i64 0
  store i32 19, i32* %arrayidx, align 4
  %2 = load i32*, i32** %arr.addr, align 8
  %arrayidx1 = getelementptr inbounds i32, i32* %2, i64 1
  store i32 96, i32* %arrayidx1, align 4
  br label %if.end.upper

if.end.upper:                                     ; preds = %if.then, %entry.lower
  %3 = load i32, i32* %initial.addr, align 4
  %4 = load i32*, i32** %arr.addr, align 8
  %arrayidx2 = getelementptr inbounds i32, i32* %4, i64 0
  %5 = load i32, i32* %arrayidx2, align 4
  %6 = load i32*, i32** %arr.addr, align 8
  %arrayidx3 = getelementptr inbounds i32, i32* %6, i64 1
  %7 = load i32, i32* %arrayidx3, align 4
  %call4 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([35 x i8], [35 x i8]* @.str.1, i64 0, i64 0), i32 noundef %3, i32 noundef %5, i32 noundef %7)
  %8 = load i32, i32* %initial.addr, align 4
  br label %if.end.upper.saveBB.id1

if.end.upper.saveBB.id1:                          ; preds = %if.end.upper
  %idx_arr.addr = getelementptr inbounds i32, i32* %ckpt_mem, i32 3
  %9 = bitcast i32* %idx_arr.addr to i8*
  %10 = bitcast i32** %arr.addr to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %9, i8* align 8 %10, i64 8, i1 true)
  %idx_l_id = getelementptr inbounds i32, i32* %ckpt_mem, i32 5
  %11 = bitcast i32* %idx_l_id to i8*
  %12 = bitcast i32* %l_id to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %11, i8* align 8 %12, i64 4, i1 true)
  %idx_8 = getelementptr inbounds i32, i32* %ckpt_mem, i32 6
  store i32 %8, i32* %idx_8, align 4
  %idx_isComplete = getelementptr inbounds i32, i32* %ckpt_mem, i32 2
  store i32 1, i32* %idx_isComplete, align 4
  %idx_ckpt_id = getelementptr inbounds i32, i32* %ckpt_mem, i32 1
  store i32 1, i32* %idx_ckpt_id, align 4
  %idx_heartbeat = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  %load.heartbeat = load i32, i32* %idx_heartbeat, align 4
  %heartbeat_incr = add i32 %load.heartbeat, 1
  store i32 %heartbeat_incr, i32* %idx_heartbeat, align 4
  br label %if.end.upper.junctionBB.id1

if.end.upper.junctionBB.id1:                      ; preds = %if.end.upper.restoreBB.id1, %if.end.upper.saveBB.id1
  %new.arr.addr = phi i32** [ %arr.addr, %if.end.upper.saveBB.id1 ], [ %alloca.arr.addr, %if.end.upper.restoreBB.id1 ]
  %new.l_id = phi i32* [ %l_id, %if.end.upper.saveBB.id1 ], [ %alloca.l_id, %if.end.upper.restoreBB.id1 ]
  %new.8 = phi i32 [ %8, %if.end.upper.saveBB.id1 ], [ %load.8, %if.end.upper.restoreBB.id1 ]
  br label %if.end.lower

if.end.lower:                                     ; preds = %if.end.upper.junctionBB.id1
  %cmp5 = icmp eq i32 %new.8, 1
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end.lower
  %call7 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i64 0, i64 0))
  br label %if.end8

if.end8:                                          ; preds = %if.then6, %if.end.lower
  %new.l_id.phi = phi i32* [ %new.l_id, %if.then6 ], [ %new.l_id, %if.end.lower ]
  %new.arr.addr.phi = phi i32** [ %new.arr.addr, %if.then6 ], [ %new.arr.addr, %if.end.lower ]
  %13 = load i32*, i32** %new.arr.addr.phi, align 8
  %arrayidx9 = getelementptr inbounds i32, i32* %13, i64 0
  %14 = load i32, i32* %arrayidx9, align 4
  %15 = load i32*, i32** %new.arr.addr.phi, align 8
  %arrayidx10 = getelementptr inbounds i32, i32* %15, i64 1
  %16 = load i32, i32* %arrayidx10, align 4
  %call11 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([26 x i8], [26 x i8]* @.str.3, i64 0, i64 0), i32 noundef %14, i32 noundef %16)
  %17 = load i32, i32* %new.l_id.phi, align 4
  %18 = load i32*, i32** %ckpt_mem.addr, align 8
  %19 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx12 = getelementptr inbounds i32, i32* %19, i64 0
  %20 = load i32, i32* %arrayidx12, align 4
  %21 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx13 = getelementptr inbounds i32, i32* %21, i64 1
  %22 = load i32, i32* %arrayidx13, align 4
  %23 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx14 = getelementptr inbounds i32, i32* %23, i64 3
  %24 = load i32, i32* %arrayidx14, align 4
  %25 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx15 = getelementptr inbounds i32, i32* %25, i64 4
  %26 = load i32, i32* %arrayidx15, align 4
  %27 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx16 = getelementptr inbounds i32, i32* %27, i64 5
  %28 = load i32, i32* %arrayidx16, align 4
  %29 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx17 = getelementptr inbounds i32, i32* %29, i64 6
  %30 = load i32, i32* %arrayidx17, align 4
  %31 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx18 = getelementptr inbounds i32, i32* %31, i64 7
  %32 = load i32, i32* %arrayidx18, align 4
  %call19 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([112 x i8], [112 x i8]* @.str.4, i64 0, i64 0), i32 noundef %17, i32* noundef %18, i32 noundef %20, i32 noundef %22, i32 noundef %24, i32 noundef %26, i32 noundef %28, i32 noundef %30, i32 noundef %32)
  %33 = load i32, i32* %initial.addr, align 4
  %cmp20 = icmp eq i32 %33, 1
  %34 = zext i1 %cmp20 to i64
  %cond = select i1 %cmp20, i32 0, i32 1
  ret i32 %cond

if.end.upper.restoreBB.id1:                       ; preds = %workload.restoreControllerBB
  %idx_arr.addr1 = getelementptr inbounds i32, i32* %ckpt_mem, i32 3
  %alloca.arr.addr = alloca i32*, align 8
  %35 = bitcast i32** %alloca.arr.addr to i8*
  %36 = bitcast i32* %idx_arr.addr1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %35, i8* align 8 %36, i64 8, i1 true)
  %idx_l_id2 = getelementptr inbounds i32, i32* %ckpt_mem, i32 5
  %alloca.l_id = alloca i32, align 4
  %37 = bitcast i32* %alloca.l_id to i8*
  %38 = bitcast i32* %idx_l_id2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %37, i8* align 8 %38, i64 4, i1 true)
  %idx_83 = getelementptr inbounds i32, i32* %ckpt_mem, i32 6
  %load.8 = load i32, i32* %idx_83, align 4
  %idx_heartbeat4 = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  %load.heartbeat5 = load i32, i32* %idx_heartbeat4, align 4
  %heartbeat_incr6 = add i32 %load.heartbeat5, 1
  store i32 %heartbeat_incr6, i32* %idx_heartbeat4, align 4
  br label %if.end.upper.junctionBB.id1
}

declare i32 @printf(i8* noundef, ...) #1

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
