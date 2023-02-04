; ModuleID = 'kernel.cpp'
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

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define dso_local void @checkpoint() #4 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline optnone uwtable
define dso_local i32 @workload(i32* noundef %ckpt_mem, i32 noundef %initial, i32* noundef %arr) #5 {
entry:
  %ckpt_mem.addr = alloca i32*, align 8
  %initial.addr = alloca i32, align 4
  %arr.addr = alloca i32*, align 8
  %l_id = alloca i32, align 4
  store i32* %ckpt_mem, i32** %ckpt_mem.addr, align 8
  store i32 %initial, i32* %initial.addr, align 4
  store i32* %arr, i32** %arr.addr, align 8
  store i32 0, i32* %l_id, align 4

  %0 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 3
  %1 = bitcast i32* %arrayidx to i8*
  %2 = load i32*, i32** %arr.addr, align 8
  %3 = bitcast i32* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %1, i8* align 4 %3, i64 8, i1 false)

  %4 = load i32*, i32** %arr.addr, align 8
  %5 = bitcast i32* %4 to i8*
  %6 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx1 = getelementptr inbounds i32, i32* %6, i64 3
  %7 = bitcast i32* %arrayidx1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %5, i8* align 4 %7, i64 8, i1 false)
  
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([29 x i8], [29 x i8]* @.str, i64 0, i64 0))
  %8 = load i32, i32* %initial.addr, align 4
  %cmp = icmp eq i32 %8, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 7, i32* %l_id, align 4
  %9 = load i32*, i32** %arr.addr, align 8
  %arrayidx2 = getelementptr inbounds i32, i32* %9, i64 0
  store i32 19, i32* %arrayidx2, align 4
  %10 = load i32*, i32** %arr.addr, align 8
  %arrayidx3 = getelementptr inbounds i32, i32* %10, i64 1
  store i32 96, i32* %arrayidx3, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %11 = load i32, i32* %initial.addr, align 4
  %12 = load i32*, i32** %arr.addr, align 8
  %arrayidx4 = getelementptr inbounds i32, i32* %12, i64 0
  %13 = load i32, i32* %arrayidx4, align 4
  %14 = load i32*, i32** %arr.addr, align 8
  %arrayidx5 = getelementptr inbounds i32, i32* %14, i64 1
  %15 = load i32, i32* %arrayidx5, align 4
  %call6 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([35 x i8], [35 x i8]* @.str.1, i64 0, i64 0), i32 noundef %11, i32 noundef %13, i32 noundef %15)
  call void @checkpoint()
  %16 = load i32, i32* %initial.addr, align 4
  %cmp7 = icmp eq i32 %16, 1
  br i1 %cmp7, label %if.then8, label %if.end10

if.then8:                                         ; preds = %if.end
  %call9 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i64 0, i64 0))
  br label %if.end10

if.end10:                                         ; preds = %if.then8, %if.end
  %17 = load i32*, i32** %arr.addr, align 8
  %arrayidx11 = getelementptr inbounds i32, i32* %17, i64 0
  %18 = load i32, i32* %arrayidx11, align 4
  %19 = load i32*, i32** %arr.addr, align 8
  %arrayidx12 = getelementptr inbounds i32, i32* %19, i64 1
  %20 = load i32, i32* %arrayidx12, align 4
  %call13 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([26 x i8], [26 x i8]* @.str.3, i64 0, i64 0), i32 noundef %18, i32 noundef %20)
  %21 = load i32, i32* %l_id, align 4
  %22 = load i32*, i32** %ckpt_mem.addr, align 8
  %23 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx14 = getelementptr inbounds i32, i32* %23, i64 0
  %24 = load i32, i32* %arrayidx14, align 4
  %25 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx15 = getelementptr inbounds i32, i32* %25, i64 1
  %26 = load i32, i32* %arrayidx15, align 4
  %27 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx16 = getelementptr inbounds i32, i32* %27, i64 3
  %28 = load i32, i32* %arrayidx16, align 4
  %29 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx17 = getelementptr inbounds i32, i32* %29, i64 4
  %30 = load i32, i32* %arrayidx17, align 4
  %31 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx18 = getelementptr inbounds i32, i32* %31, i64 5
  %32 = load i32, i32* %arrayidx18, align 4
  %33 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx19 = getelementptr inbounds i32, i32* %33, i64 6
  %34 = load i32, i32* %arrayidx19, align 4
  %35 = load i32*, i32** %ckpt_mem.addr, align 8
  %arrayidx20 = getelementptr inbounds i32, i32* %35, i64 7
  %36 = load i32, i32* %arrayidx20, align 4
  %call21 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([112 x i8], [112 x i8]* @.str.4, i64 0, i64 0), i32 noundef %21, i32* noundef %22, i32 noundef %24, i32 noundef %26, i32 noundef %28, i32 noundef %30, i32 noundef %32, i32 noundef %34, i32 noundef %36)
  %37 = load i32, i32* %initial.addr, align 4
  %cmp22 = icmp eq i32 %37, 1
  %38 = zext i1 %cmp22 to i64
  %cond = select i1 %cmp22, i32 0, i32 1
  ret i32 %cond
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #6

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
attributes #4 = { mustprogress noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress noinline optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { argmemonly nofree nounwind willreturn }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.6"}
