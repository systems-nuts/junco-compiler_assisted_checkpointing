; ModuleID = '/home/dale/Documents/minimap2-fpga/device/minimap2_opencl.cpp'
source_filename = "/home/dale/Documents/minimap2-fpga/device/minimap2_opencl.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

$ilog2_32 = comdat any

@sync_bit = dso_local global i8 0, align 1
@LogTable256 = dso_local global [256 x i8] c"\FF\00\01\01\02\02\02\02\03\03\03\03\03\03\03\03\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\05\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\06\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07\07", align 16

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @cpy_wrapper_f(double* noundef %dest, i8* noundef %src, i32 noundef %size) #0 {
entry:
  %dest.addr = alloca double*, align 8
  %src.addr = alloca i8*, align 8
  %size.addr = alloca i32, align 4
  store double* %dest, double** %dest.addr, align 8
  store i8* %src, i8** %src.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  %0 = load double*, double** %dest.addr, align 8
  %1 = bitcast double* %0 to i8*
  %2 = load i8*, i8** %src.addr, align 8
  %3 = load i32, i32* %size.addr, align 4
  %conv = sext i32 %3 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %1, i8* align 1 %2, i64 %conv, i1 false)
  store i8 1, i8* @sync_bit, align 1
  ret void
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @cpy_wrapper_i8(i8* noundef %dest, i8* noundef %src, i32 noundef %size) #0 {
entry:
  %dest.addr = alloca i8*, align 8
  %src.addr = alloca i8*, align 8
  %size.addr = alloca i32, align 4
  store i8* %dest, i8** %dest.addr, align 8
  store i8* %src, i8** %src.addr, align 8
  store i32 %size, i32* %size.addr, align 4
  %0 = load i8*, i8** %dest.addr, align 8
  %1 = load i8*, i8** %src.addr, align 8
  %2 = load i32, i32* %size.addr, align 4
  %conv = sext i32 %2 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %0, i8* align 1 %1, i64 %conv, i1 false)
  store i8 1, i8* @sync_bit, align 1
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @mem_cpy_index_f(double* noundef %dest, double* noundef %src, i32* noundef %index_list, i32* noundef %sp) #0 {
entry:
  %dest.addr = alloca double*, align 8
  %src.addr = alloca double*, align 8
  %index_list.addr = alloca i32*, align 8
  %sp.addr = alloca i32*, align 8
  %index = alloca i32, align 4
  store double* %dest, double** %dest.addr, align 8
  store double* %src, double** %src.addr, align 8
  store i32* %index_list, i32** %index_list.addr, align 8
  store i32* %sp, i32** %sp.addr, align 8
  %0 = load double*, double** %dest.addr, align 8
  %cmp = icmp eq double* %0, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  br label %while.cond

while.cond:                                       ; preds = %while.body, %if.end
  %1 = load i32*, i32** %sp.addr, align 8
  %2 = load i32, i32* %1, align 4
  %cmp1 = icmp sgt i32 %2, 0
  br i1 %cmp1, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %3 = load i32*, i32** %sp.addr, align 8
  %4 = load i32, i32* %3, align 4
  %dec = add nsw i32 %4, -1
  store i32 %dec, i32* %3, align 4
  %5 = load i32*, i32** %index_list.addr, align 8
  %6 = load i32*, i32** %sp.addr, align 8
  %7 = load i32, i32* %6, align 4
  %idxprom = sext i32 %7 to i64
  %arrayidx = getelementptr inbounds i32, i32* %5, i64 %idxprom
  %8 = load i32, i32* %arrayidx, align 4
  store i32 %8, i32* %index, align 4
  %9 = load double*, double** %src.addr, align 8
  %10 = load i32, i32* %index, align 4
  %idxprom2 = sext i32 %10 to i64
  %arrayidx3 = getelementptr inbounds double, double* %9, i64 %idxprom2
  %11 = load double, double* %arrayidx3, align 8
  %12 = load double*, double** %dest.addr, align 8
  %13 = load i32, i32* %index, align 4
  %idxprom4 = sext i32 %13 to i64
  %arrayidx5 = getelementptr inbounds double, double* %12, i64 %idxprom4
  store double %11, double* %arrayidx5, align 8
  br label %while.cond, !llvm.loop !6

while.end:                                        ; preds = %while.cond
  store i8 1, i8* @sync_bit, align 1
  br label %return

return:                                           ; preds = %while.end, %if.then
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @checkpoint() #0 {
entry:
  call void @mem_cpy_index_f(double* noundef null, double* noundef null, i32* noundef null, i32* noundef null)
  call void @cpy_wrapper_f(double* noundef null, i8* noundef null, i32 noundef 0)
  call void @cpy_wrapper_i8(i8* noundef null, i8* noundef null, i32 noundef 0)
  ret void
}

; Function Attrs: mustprogress noinline uwtable
define dso_local void @chain(i64 noundef %total_subparts, i32 noundef %max_dist_x, i32 noundef %max_dist_y, i32 noundef %bw, i32 noundef %q_span, float noundef %avg_qspan_scaled, i64* noundef %a, i32* noundef %f, i32* noundef %p, i8* noundef %num_subparts, double* noundef %ckpt_mem) #2 {
entry:
  %total_subparts.addr = alloca i64, align 8
  %max_dist_x.addr = alloca i32, align 4
  %max_dist_y.addr = alloca i32, align 4
  %bw.addr = alloca i32, align 4
  %q_span.addr = alloca i32, align 4
  %avg_qspan_scaled.addr = alloca float, align 4
  %a.addr = alloca i64*, align 8
  %f.addr = alloca i32*, align 8
  %p.addr = alloca i32*, align 8
  %num_subparts.addr = alloca i8*, align 8
  %ckpt_mem.addr = alloca double*, align 8
  %a_x_local = alloca [513 x i64], align 16
  %a_y_local = alloca [513 x i32], align 16
  %f_local = alloca [513 x i32], align 16
  %subparts_processed = alloca i8, align 1
  %subparts_to_process = alloca i8, align 1
  %a_local_next = alloca [128 x i64], align 16
  %subparts_to_process_next = alloca [64 x i8], align 16
  %j = alloca i32, align 4
  %prefetch_ptr = alloca i32, align 4
  %i = alloca i64, align 8
  %g = alloca i64, align 8
  %a_local_x = alloca i64, align 8
  %a_local_y = alloca i64, align 8
  %j25 = alloca i32, align 4
  %ri = alloca i64, align 8
  %qi = alloca i32, align 4
  %sc_a = alloca [64 x i64], align 16
  %j66 = alloca i32, align 4
  %a_x_local_j = alloca i64, align 8
  %a_y_local_j = alloca i64, align 8
  %f_local_j = alloca i32, align 4
  %dr = alloca i64, align 8
  %dq = alloca i32, align 4
  %dd = alloca i32, align 4
  %log_dd = alloca i32, align 4
  %min_d = alloca i32, align 4
  %sc = alloca i32, align 4
  %max_j = alloca i64, align 8
  %max_f = alloca i32, align 4
  %j242 = alloca i32, align 4
  %sc246 = alloca i32, align 4
  %reg = alloca i32, align 4
  store i64 %total_subparts, i64* %total_subparts.addr, align 8
  store i32 %max_dist_x, i32* %max_dist_x.addr, align 4
  store i32 %max_dist_y, i32* %max_dist_y.addr, align 4
  store i32 %bw, i32* %bw.addr, align 4
  store i32 %q_span, i32* %q_span.addr, align 4
  store float %avg_qspan_scaled, float* %avg_qspan_scaled.addr, align 4
  store i64* %a, i64** %a.addr, align 8
  store i32* %f, i32** %f.addr, align 8
  store i32* %p, i32** %p.addr, align 8
  store i8* %num_subparts, i8** %num_subparts.addr, align 8
  store double* %ckpt_mem, double** %ckpt_mem.addr, align 8
  %0 = bitcast [513 x i64]* %a_x_local to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %0, i8 0, i64 4104, i1 false)
  %1 = bitcast [513 x i32]* %a_y_local to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %1, i8 0, i64 2052, i1 false)
  %2 = bitcast [513 x i32]* %f_local to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %2, i8 0, i64 2052, i1 false)
  store i8 0, i8* %subparts_processed, align 1
  store i8 0, i8* %subparts_to_process, align 1
  store i32 0, i32* %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %3 = load i32, i32* %j, align 4
  %cmp = icmp slt i32 %3, 64
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %4 = load i64*, i64** %a.addr, align 8
  %5 = load i32, i32* %j, align 4
  %mul = mul nsw i32 %5, 2
  %idxprom = sext i32 %mul to i64
  %arrayidx = getelementptr inbounds i64, i64* %4, i64 %idxprom
  %6 = load i64, i64* %arrayidx, align 8
  %7 = load i32, i32* %j, align 4
  %mul1 = mul nsw i32 %7, 2
  %idxprom2 = sext i32 %mul1 to i64
  %arrayidx3 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 %idxprom2
  store i64 %6, i64* %arrayidx3, align 8
  %8 = load i64*, i64** %a.addr, align 8
  %9 = load i32, i32* %j, align 4
  %mul4 = mul nsw i32 %9, 2
  %add = add nsw i32 %mul4, 1
  %idxprom5 = sext i32 %add to i64
  %arrayidx6 = getelementptr inbounds i64, i64* %8, i64 %idxprom5
  %10 = load i64, i64* %arrayidx6, align 8
  %11 = load i32, i32* %j, align 4
  %mul7 = mul nsw i32 %11, 2
  %add8 = add nsw i32 %mul7, 1
  %idxprom9 = sext i32 %add8 to i64
  %arrayidx10 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 %idxprom9
  store i64 %10, i64* %arrayidx10, align 8
  %12 = load i8*, i8** %num_subparts.addr, align 8
  %13 = load i32, i32* %j, align 4
  %idxprom11 = sext i32 %13 to i64
  %arrayidx12 = getelementptr inbounds i8, i8* %12, i64 %idxprom11
  %14 = load i8, i8* %arrayidx12, align 1
  %15 = load i32, i32* %j, align 4
  %idxprom13 = sext i32 %15 to i64
  %arrayidx14 = getelementptr inbounds [64 x i8], [64 x i8]* %subparts_to_process_next, i64 0, i64 %idxprom13
  store i8 %14, i8* %arrayidx14, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %16 = load i32, i32* %j, align 4
  %inc = add nsw i32 %16, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond, !llvm.loop !8

for.end:                                          ; preds = %for.cond
  store i32 64, i32* %prefetch_ptr, align 4
  store i64 0, i64* %i, align 8
  store i64 0, i64* %g, align 8
  br label %for.cond15

for.cond15:                                       ; preds = %for.inc355, %for.end
  %17 = load i64, i64* %g, align 8
  %18 = load i64, i64* %total_subparts.addr, align 8
  %cmp16 = icmp slt i64 %17, %18
  br i1 %cmp16, label %for.body17, label %for.end357

for.body17:                                       ; preds = %for.cond15
  %19 = load i8, i8* %subparts_processed, align 1
  %conv = zext i8 %19 to i32
  %cmp18 = icmp eq i32 %conv, 0
  br i1 %cmp18, label %if.then, label %if.end

if.then:                                          ; preds = %for.body17
  %arrayidx19 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 0
  %20 = load i64, i64* %arrayidx19, align 16
  store i64 %20, i64* %a_local_x, align 8
  %arrayidx20 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 1
  %21 = load i64, i64* %arrayidx20, align 8
  store i64 %21, i64* %a_local_y, align 8
  %22 = load i64, i64* %a_local_x, align 8
  %arrayidx21 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 0
  store i64 %22, i64* %arrayidx21, align 16
  %23 = load i64, i64* %a_local_y, align 8
  %conv22 = trunc i64 %23 to i32
  %arrayidx23 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 0
  store i32 %conv22, i32* %arrayidx23, align 16
  %arrayidx24 = getelementptr inbounds [64 x i8], [64 x i8]* %subparts_to_process_next, i64 0, i64 0
  %24 = load i8, i8* %arrayidx24, align 16
  store i8 %24, i8* %subparts_to_process, align 1
  store i32 0, i32* %j25, align 4
  br label %for.cond26

for.cond26:                                       ; preds = %for.inc50, %if.then
  %25 = load i32, i32* %j25, align 4
  %cmp27 = icmp slt i32 %25, 63
  br i1 %cmp27, label %for.body28, label %for.end52

for.body28:                                       ; preds = %for.cond26
  %26 = load i32, i32* %j25, align 4
  %mul29 = mul nsw i32 %26, 2
  %add30 = add nsw i32 %mul29, 2
  %idxprom31 = sext i32 %add30 to i64
  %arrayidx32 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 %idxprom31
  %27 = load i64, i64* %arrayidx32, align 8
  %28 = load i32, i32* %j25, align 4
  %mul33 = mul nsw i32 %28, 2
  %idxprom34 = sext i32 %mul33 to i64
  %arrayidx35 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 %idxprom34
  store i64 %27, i64* %arrayidx35, align 8
  %29 = load i32, i32* %j25, align 4
  %mul36 = mul nsw i32 %29, 2
  %add37 = add nsw i32 %mul36, 1
  %add38 = add nsw i32 %add37, 2
  %idxprom39 = sext i32 %add38 to i64
  %arrayidx40 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 %idxprom39
  %30 = load i64, i64* %arrayidx40, align 8
  %31 = load i32, i32* %j25, align 4
  %mul41 = mul nsw i32 %31, 2
  %add42 = add nsw i32 %mul41, 1
  %idxprom43 = sext i32 %add42 to i64
  %arrayidx44 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 %idxprom43
  store i64 %30, i64* %arrayidx44, align 8
  %32 = load i32, i32* %j25, align 4
  %add45 = add nsw i32 %32, 1
  %idxprom46 = sext i32 %add45 to i64
  %arrayidx47 = getelementptr inbounds [64 x i8], [64 x i8]* %subparts_to_process_next, i64 0, i64 %idxprom46
  %33 = load i8, i8* %arrayidx47, align 1
  %34 = load i32, i32* %j25, align 4
  %idxprom48 = sext i32 %34 to i64
  %arrayidx49 = getelementptr inbounds [64 x i8], [64 x i8]* %subparts_to_process_next, i64 0, i64 %idxprom48
  store i8 %33, i8* %arrayidx49, align 1
  br label %for.inc50

for.inc50:                                        ; preds = %for.body28
  %35 = load i32, i32* %j25, align 4
  %inc51 = add nsw i32 %35, 1
  store i32 %inc51, i32* %j25, align 4
  br label %for.cond26, !llvm.loop !9

for.end52:                                        ; preds = %for.cond26
  %36 = load i64*, i64** %a.addr, align 8
  %37 = load i32, i32* %prefetch_ptr, align 4
  %idxprom53 = sext i32 %37 to i64
  %arrayidx54 = getelementptr inbounds i64, i64* %36, i64 %idxprom53
  %38 = load i64, i64* %arrayidx54, align 8
  %arrayidx55 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 62
  store i64 %38, i64* %arrayidx55, align 16
  %39 = load i64*, i64** %a.addr, align 8
  %40 = load i32, i32* %prefetch_ptr, align 4
  %add56 = add nsw i32 %40, 1
  %idxprom57 = sext i32 %add56 to i64
  %arrayidx58 = getelementptr inbounds i64, i64* %39, i64 %idxprom57
  %41 = load i64, i64* %arrayidx58, align 8
  %arrayidx59 = getelementptr inbounds [128 x i64], [128 x i64]* %a_local_next, i64 0, i64 63
  store i64 %41, i64* %arrayidx59, align 8
  %42 = load i8*, i8** %num_subparts.addr, align 8
  %43 = load i32, i32* %prefetch_ptr, align 4
  %idxprom60 = sext i32 %43 to i64
  %arrayidx61 = getelementptr inbounds i8, i8* %42, i64 %idxprom60
  %44 = load i8, i8* %arrayidx61, align 1
  %arrayidx62 = getelementptr inbounds [64 x i8], [64 x i8]* %subparts_to_process_next, i64 0, i64 63
  store i8 %44, i8* %arrayidx62, align 1
  %45 = load i32, i32* %prefetch_ptr, align 4
  %inc63 = add nsw i32 %45, 1
  store i32 %inc63, i32* %prefetch_ptr, align 4
  br label %if.end

if.end:                                           ; preds = %for.end52, %for.body17
  %arrayidx64 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 0
  %46 = load i64, i64* %arrayidx64, align 16
  store i64 %46, i64* %ri, align 8
  %arrayidx65 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 0
  %47 = load i32, i32* %arrayidx65, align 16
  store i32 %47, i32* %qi, align 4
  %48 = bitcast [64 x i64]* %sc_a to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %48, i8 0, i64 512, i1 false)
  store i32 64, i32* %j66, align 4
  br label %for.cond67

for.cond67:                                       ; preds = %for.inc240, %if.end
  %49 = load i32, i32* %j66, align 4
  %cmp68 = icmp sgt i32 %49, 0
  br i1 %cmp68, label %for.body69, label %for.end241

for.body69:                                       ; preds = %for.cond67
  %50 = load i8, i8* %subparts_processed, align 1
  %conv70 = zext i8 %50 to i32
  %cmp71 = icmp eq i32 %conv70, 0
  br i1 %cmp71, label %if.then72, label %if.end80

if.then72:                                        ; preds = %for.body69
  %51 = load i32, i32* %j66, align 4
  %idxprom73 = sext i32 %51 to i64
  %arrayidx74 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom73
  %52 = load i64, i64* %arrayidx74, align 8
  store i64 %52, i64* %a_x_local_j, align 8
  %53 = load i32, i32* %j66, align 4
  %idxprom75 = sext i32 %53 to i64
  %arrayidx76 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom75
  %54 = load i32, i32* %arrayidx76, align 4
  %conv77 = sext i32 %54 to i64
  store i64 %conv77, i64* %a_y_local_j, align 8
  %55 = load i32, i32* %j66, align 4
  %idxprom78 = sext i32 %55 to i64
  %arrayidx79 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom78
  %56 = load i32, i32* %arrayidx79, align 4
  store i32 %56, i32* %f_local_j, align 4
  br label %if.end80

if.end80:                                         ; preds = %if.then72, %for.body69
  %57 = load i8, i8* %subparts_processed, align 1
  %conv81 = zext i8 %57 to i32
  %cmp82 = icmp eq i32 %conv81, 1
  br i1 %cmp82, label %if.then83, label %if.end94

if.then83:                                        ; preds = %if.end80
  %58 = load i32, i32* %j66, align 4
  %add84 = add nsw i32 64, %58
  %idxprom85 = sext i32 %add84 to i64
  %arrayidx86 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom85
  %59 = load i64, i64* %arrayidx86, align 8
  store i64 %59, i64* %a_x_local_j, align 8
  %60 = load i32, i32* %j66, align 4
  %add87 = add nsw i32 64, %60
  %idxprom88 = sext i32 %add87 to i64
  %arrayidx89 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom88
  %61 = load i32, i32* %arrayidx89, align 4
  %conv90 = sext i32 %61 to i64
  store i64 %conv90, i64* %a_y_local_j, align 8
  %62 = load i32, i32* %j66, align 4
  %add91 = add nsw i32 64, %62
  %idxprom92 = sext i32 %add91 to i64
  %arrayidx93 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom92
  %63 = load i32, i32* %arrayidx93, align 4
  store i32 %63, i32* %f_local_j, align 4
  br label %if.end94

if.end94:                                         ; preds = %if.then83, %if.end80
  %64 = load i8, i8* %subparts_processed, align 1
  %conv95 = zext i8 %64 to i32
  %cmp96 = icmp eq i32 %conv95, 2
  br i1 %cmp96, label %if.then97, label %if.end108

if.then97:                                        ; preds = %if.end94
  %65 = load i32, i32* %j66, align 4
  %add98 = add nsw i32 128, %65
  %idxprom99 = sext i32 %add98 to i64
  %arrayidx100 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom99
  %66 = load i64, i64* %arrayidx100, align 8
  store i64 %66, i64* %a_x_local_j, align 8
  %67 = load i32, i32* %j66, align 4
  %add101 = add nsw i32 128, %67
  %idxprom102 = sext i32 %add101 to i64
  %arrayidx103 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom102
  %68 = load i32, i32* %arrayidx103, align 4
  %conv104 = sext i32 %68 to i64
  store i64 %conv104, i64* %a_y_local_j, align 8
  %69 = load i32, i32* %j66, align 4
  %add105 = add nsw i32 128, %69
  %idxprom106 = sext i32 %add105 to i64
  %arrayidx107 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom106
  %70 = load i32, i32* %arrayidx107, align 4
  store i32 %70, i32* %f_local_j, align 4
  br label %if.end108

if.end108:                                        ; preds = %if.then97, %if.end94
  %71 = load i8, i8* %subparts_processed, align 1
  %conv109 = zext i8 %71 to i32
  %cmp110 = icmp eq i32 %conv109, 3
  br i1 %cmp110, label %if.then111, label %if.end122

if.then111:                                       ; preds = %if.end108
  %72 = load i32, i32* %j66, align 4
  %add112 = add nsw i32 192, %72
  %idxprom113 = sext i32 %add112 to i64
  %arrayidx114 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom113
  %73 = load i64, i64* %arrayidx114, align 8
  store i64 %73, i64* %a_x_local_j, align 8
  %74 = load i32, i32* %j66, align 4
  %add115 = add nsw i32 192, %74
  %idxprom116 = sext i32 %add115 to i64
  %arrayidx117 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom116
  %75 = load i32, i32* %arrayidx117, align 4
  %conv118 = sext i32 %75 to i64
  store i64 %conv118, i64* %a_y_local_j, align 8
  %76 = load i32, i32* %j66, align 4
  %add119 = add nsw i32 192, %76
  %idxprom120 = sext i32 %add119 to i64
  %arrayidx121 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom120
  %77 = load i32, i32* %arrayidx121, align 4
  store i32 %77, i32* %f_local_j, align 4
  br label %if.end122

if.end122:                                        ; preds = %if.then111, %if.end108
  %78 = load i8, i8* %subparts_processed, align 1
  %conv123 = zext i8 %78 to i32
  %cmp124 = icmp eq i32 %conv123, 4
  br i1 %cmp124, label %if.then125, label %if.end136

if.then125:                                       ; preds = %if.end122
  %79 = load i32, i32* %j66, align 4
  %add126 = add nsw i32 256, %79
  %idxprom127 = sext i32 %add126 to i64
  %arrayidx128 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom127
  %80 = load i64, i64* %arrayidx128, align 8
  store i64 %80, i64* %a_x_local_j, align 8
  %81 = load i32, i32* %j66, align 4
  %add129 = add nsw i32 256, %81
  %idxprom130 = sext i32 %add129 to i64
  %arrayidx131 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom130
  %82 = load i32, i32* %arrayidx131, align 4
  %conv132 = sext i32 %82 to i64
  store i64 %conv132, i64* %a_y_local_j, align 8
  %83 = load i32, i32* %j66, align 4
  %add133 = add nsw i32 256, %83
  %idxprom134 = sext i32 %add133 to i64
  %arrayidx135 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom134
  %84 = load i32, i32* %arrayidx135, align 4
  store i32 %84, i32* %f_local_j, align 4
  br label %if.end136

if.end136:                                        ; preds = %if.then125, %if.end122
  %85 = load i8, i8* %subparts_processed, align 1
  %conv137 = zext i8 %85 to i32
  %cmp138 = icmp eq i32 %conv137, 5
  br i1 %cmp138, label %if.then139, label %if.end150

if.then139:                                       ; preds = %if.end136
  %86 = load i32, i32* %j66, align 4
  %add140 = add nsw i32 320, %86
  %idxprom141 = sext i32 %add140 to i64
  %arrayidx142 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom141
  %87 = load i64, i64* %arrayidx142, align 8
  store i64 %87, i64* %a_x_local_j, align 8
  %88 = load i32, i32* %j66, align 4
  %add143 = add nsw i32 320, %88
  %idxprom144 = sext i32 %add143 to i64
  %arrayidx145 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom144
  %89 = load i32, i32* %arrayidx145, align 4
  %conv146 = sext i32 %89 to i64
  store i64 %conv146, i64* %a_y_local_j, align 8
  %90 = load i32, i32* %j66, align 4
  %add147 = add nsw i32 320, %90
  %idxprom148 = sext i32 %add147 to i64
  %arrayidx149 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom148
  %91 = load i32, i32* %arrayidx149, align 4
  store i32 %91, i32* %f_local_j, align 4
  br label %if.end150

if.end150:                                        ; preds = %if.then139, %if.end136
  %92 = load i8, i8* %subparts_processed, align 1
  %conv151 = zext i8 %92 to i32
  %cmp152 = icmp eq i32 %conv151, 6
  br i1 %cmp152, label %if.then153, label %if.end164

if.then153:                                       ; preds = %if.end150
  %93 = load i32, i32* %j66, align 4
  %add154 = add nsw i32 384, %93
  %idxprom155 = sext i32 %add154 to i64
  %arrayidx156 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom155
  %94 = load i64, i64* %arrayidx156, align 8
  store i64 %94, i64* %a_x_local_j, align 8
  %95 = load i32, i32* %j66, align 4
  %add157 = add nsw i32 384, %95
  %idxprom158 = sext i32 %add157 to i64
  %arrayidx159 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom158
  %96 = load i32, i32* %arrayidx159, align 4
  %conv160 = sext i32 %96 to i64
  store i64 %conv160, i64* %a_y_local_j, align 8
  %97 = load i32, i32* %j66, align 4
  %add161 = add nsw i32 384, %97
  %idxprom162 = sext i32 %add161 to i64
  %arrayidx163 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom162
  %98 = load i32, i32* %arrayidx163, align 4
  store i32 %98, i32* %f_local_j, align 4
  br label %if.end164

if.end164:                                        ; preds = %if.then153, %if.end150
  %99 = load i8, i8* %subparts_processed, align 1
  %conv165 = zext i8 %99 to i32
  %cmp166 = icmp eq i32 %conv165, 7
  br i1 %cmp166, label %if.then167, label %if.end178

if.then167:                                       ; preds = %if.end164
  %100 = load i32, i32* %j66, align 4
  %add168 = add nsw i32 448, %100
  %idxprom169 = sext i32 %add168 to i64
  %arrayidx170 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom169
  %101 = load i64, i64* %arrayidx170, align 8
  store i64 %101, i64* %a_x_local_j, align 8
  %102 = load i32, i32* %j66, align 4
  %add171 = add nsw i32 448, %102
  %idxprom172 = sext i32 %add171 to i64
  %arrayidx173 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom172
  %103 = load i32, i32* %arrayidx173, align 4
  %conv174 = sext i32 %103 to i64
  store i64 %conv174, i64* %a_y_local_j, align 8
  %104 = load i32, i32* %j66, align 4
  %add175 = add nsw i32 448, %104
  %idxprom176 = sext i32 %add175 to i64
  %arrayidx177 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom176
  %105 = load i32, i32* %arrayidx177, align 4
  store i32 %105, i32* %f_local_j, align 4
  br label %if.end178

if.end178:                                        ; preds = %if.then167, %if.end164
  %106 = load i64, i64* %ri, align 8
  %107 = load i64, i64* %a_x_local_j, align 8
  %sub = sub i64 %106, %107
  store i64 %sub, i64* %dr, align 8
  %108 = load i64, i64* %dr, align 8
  %109 = load i32, i32* %max_dist_x.addr, align 4
  %conv179 = sext i32 %109 to i64
  %cmp180 = icmp sgt i64 %108, %conv179
  br i1 %cmp180, label %if.then182, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %if.end178
  %110 = load i64, i64* %dr, align 8
  %cmp181 = icmp sle i64 %110, 0
  br i1 %cmp181, label %if.then182, label %if.end183

if.then182:                                       ; preds = %lor.lhs.false, %if.end178
  br label %for.inc240

if.end183:                                        ; preds = %lor.lhs.false
  %111 = load i32, i32* %qi, align 4
  %112 = load i64, i64* %a_y_local_j, align 8
  %conv184 = trunc i64 %112 to i32
  %sub185 = sub nsw i32 %111, %conv184
  store i32 %sub185, i32* %dq, align 4
  %113 = load i32, i32* %dq, align 4
  %cmp186 = icmp sle i32 %113, 0
  br i1 %cmp186, label %if.then187, label %if.end188

if.then187:                                       ; preds = %if.end183
  br label %for.inc240

if.end188:                                        ; preds = %if.end183
  %114 = load i32, i32* %dq, align 4
  %115 = load i32, i32* %max_dist_y.addr, align 4
  %cmp189 = icmp sgt i32 %114, %115
  br i1 %cmp189, label %if.then192, label %lor.lhs.false190

lor.lhs.false190:                                 ; preds = %if.end188
  %116 = load i32, i32* %dq, align 4
  %117 = load i32, i32* %max_dist_x.addr, align 4
  %cmp191 = icmp sgt i32 %116, %117
  br i1 %cmp191, label %if.then192, label %if.end193

if.then192:                                       ; preds = %lor.lhs.false190, %if.end188
  br label %for.inc240

if.end193:                                        ; preds = %lor.lhs.false190
  %118 = load i64, i64* %dr, align 8
  %119 = load i32, i32* %dq, align 4
  %conv194 = sext i32 %119 to i64
  %cmp195 = icmp sgt i64 %118, %conv194
  br i1 %cmp195, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.end193
  %120 = load i64, i64* %dr, align 8
  %121 = load i32, i32* %dq, align 4
  %conv196 = sext i32 %121 to i64
  %sub197 = sub nsw i64 %120, %conv196
  br label %cond.end

cond.false:                                       ; preds = %if.end193
  %122 = load i32, i32* %dq, align 4
  %conv198 = sext i32 %122 to i64
  %123 = load i64, i64* %dr, align 8
  %sub199 = sub nsw i64 %conv198, %123
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i64 [ %sub197, %cond.true ], [ %sub199, %cond.false ]
  %conv200 = trunc i64 %cond to i32
  store i32 %conv200, i32* %dd, align 4
  %124 = load i32, i32* %dd, align 4
  %125 = load i32, i32* %bw.addr, align 4
  %cmp201 = icmp sgt i32 %124, %125
  br i1 %cmp201, label %if.then202, label %if.end203

if.then202:                                       ; preds = %cond.end
  br label %for.inc240

if.end203:                                        ; preds = %cond.end
  %126 = load i32, i32* %dq, align 4
  %conv204 = sext i32 %126 to i64
  %127 = load i64, i64* %dr, align 8
  %cmp205 = icmp slt i64 %conv204, %127
  br i1 %cmp205, label %cond.true206, label %cond.false208

cond.true206:                                     ; preds = %if.end203
  %128 = load i32, i32* %dq, align 4
  %conv207 = sext i32 %128 to i64
  br label %cond.end209

cond.false208:                                    ; preds = %if.end203
  %129 = load i64, i64* %dr, align 8
  br label %cond.end209

cond.end209:                                      ; preds = %cond.false208, %cond.true206
  %cond210 = phi i64 [ %conv207, %cond.true206 ], [ %129, %cond.false208 ]
  %conv211 = trunc i64 %cond210 to i32
  store i32 %conv211, i32* %min_d, align 4
  %130 = load i32, i32* %min_d, align 4
  %131 = load i32, i32* %q_span.addr, align 4
  %cmp212 = icmp sgt i32 %130, %131
  br i1 %cmp212, label %cond.true213, label %cond.false215

cond.true213:                                     ; preds = %cond.end209
  %132 = load i32, i32* %q_span.addr, align 4
  %conv214 = sext i32 %132 to i64
  br label %cond.end223

cond.false215:                                    ; preds = %cond.end209
  %133 = load i32, i32* %dq, align 4
  %conv216 = sext i32 %133 to i64
  %134 = load i64, i64* %dr, align 8
  %cmp217 = icmp slt i64 %conv216, %134
  br i1 %cmp217, label %cond.true218, label %cond.false220

cond.true218:                                     ; preds = %cond.false215
  %135 = load i32, i32* %dq, align 4
  %conv219 = sext i32 %135 to i64
  br label %cond.end221

cond.false220:                                    ; preds = %cond.false215
  %136 = load i64, i64* %dr, align 8
  br label %cond.end221

cond.end221:                                      ; preds = %cond.false220, %cond.true218
  %cond222 = phi i64 [ %conv219, %cond.true218 ], [ %136, %cond.false220 ]
  br label %cond.end223

cond.end223:                                      ; preds = %cond.end221, %cond.true213
  %cond224 = phi i64 [ %conv214, %cond.true213 ], [ %cond222, %cond.end221 ]
  %conv225 = trunc i64 %cond224 to i32
  store i32 %conv225, i32* %sc, align 4
  %137 = load i32, i32* %dd, align 4
  %tobool = icmp ne i32 %137, 0
  br i1 %tobool, label %cond.true226, label %cond.false227

cond.true226:                                     ; preds = %cond.end223
  %138 = load i32, i32* %dd, align 4
  %call = call i32 @ilog2_32(i32 noundef %138)
  br label %cond.end228

cond.false227:                                    ; preds = %cond.end223
  br label %cond.end228

cond.end228:                                      ; preds = %cond.false227, %cond.true226
  %cond229 = phi i32 [ %call, %cond.true226 ], [ 0, %cond.false227 ]
  store i32 %cond229, i32* %log_dd, align 4
  %139 = load i32, i32* %dd, align 4
  %conv230 = sitofp i32 %139 to float
  %140 = load float, float* %avg_qspan_scaled.addr, align 4
  %mul231 = fmul float %conv230, %140
  %conv232 = fptosi float %mul231 to i32
  %141 = load i32, i32* %log_dd, align 4
  %shr = ashr i32 %141, 1
  %add233 = add nsw i32 %conv232, %shr
  %142 = load i32, i32* %sc, align 4
  %sub234 = sub nsw i32 %142, %add233
  store i32 %sub234, i32* %sc, align 4
  %143 = load i32, i32* %f_local_j, align 4
  %144 = load i32, i32* %sc, align 4
  %add235 = add nsw i32 %144, %143
  store i32 %add235, i32* %sc, align 4
  %145 = load i32, i32* %sc, align 4
  %conv236 = sext i32 %145 to i64
  %146 = load i32, i32* %j66, align 4
  %sub237 = sub nsw i32 %146, 1
  %idxprom238 = sext i32 %sub237 to i64
  %arrayidx239 = getelementptr inbounds [64 x i64], [64 x i64]* %sc_a, i64 0, i64 %idxprom238
  store i64 %conv236, i64* %arrayidx239, align 8
  br label %for.inc240

for.inc240:                                       ; preds = %cond.end228, %if.then202, %if.then192, %if.then187, %if.then182
  %147 = load i32, i32* %j66, align 4
  %dec = add nsw i32 %147, -1
  store i32 %dec, i32* %j66, align 4
  br label %for.cond67, !llvm.loop !10

for.end241:                                       ; preds = %for.cond67
  store i64 -1, i64* %max_j, align 8
  %148 = load i32, i32* %q_span.addr, align 4
  store i32 %148, i32* %max_f, align 4
  store i32 64, i32* %j242, align 4
  br label %for.cond243

for.cond243:                                      ; preds = %for.inc310, %for.end241
  %149 = load i32, i32* %j242, align 4
  %cmp244 = icmp sgt i32 %149, 0
  br i1 %cmp244, label %for.body245, label %for.end312

for.body245:                                      ; preds = %for.cond243
  %150 = load i32, i32* %j242, align 4
  %sub247 = sub nsw i32 %150, 1
  %idxprom248 = sext i32 %sub247 to i64
  %arrayidx249 = getelementptr inbounds [64 x i64], [64 x i64]* %sc_a, i64 0, i64 %idxprom248
  %151 = load i64, i64* %arrayidx249, align 8
  %conv250 = trunc i64 %151 to i32
  store i32 %conv250, i32* %sc246, align 4
  %152 = load i32, i32* %sc246, align 4
  %153 = load i32, i32* %max_f, align 4
  %cmp251 = icmp sge i32 %152, %153
  br i1 %cmp251, label %land.lhs.true, label %if.end309

land.lhs.true:                                    ; preds = %for.body245
  %154 = load i32, i32* %sc246, align 4
  %155 = load i32, i32* %q_span.addr, align 4
  %cmp252 = icmp ne i32 %154, %155
  br i1 %cmp252, label %if.then253, label %if.end309

if.then253:                                       ; preds = %land.lhs.true
  %156 = load i32, i32* %sc246, align 4
  store i32 %156, i32* %max_f, align 4
  %157 = load i8, i8* %subparts_processed, align 1
  %conv254 = zext i8 %157 to i32
  %cmp255 = icmp eq i32 %conv254, 0
  br i1 %cmp255, label %if.then256, label %if.end259

if.then256:                                       ; preds = %if.then253
  %158 = load i64, i64* %i, align 8
  %159 = load i32, i32* %j242, align 4
  %conv257 = sext i32 %159 to i64
  %sub258 = sub nsw i64 %158, %conv257
  store i64 %sub258, i64* %max_j, align 8
  br label %if.end259

if.end259:                                        ; preds = %if.then256, %if.then253
  %160 = load i8, i8* %subparts_processed, align 1
  %conv260 = zext i8 %160 to i32
  %cmp261 = icmp eq i32 %conv260, 1
  br i1 %cmp261, label %if.then262, label %if.end266

if.then262:                                       ; preds = %if.end259
  %161 = load i64, i64* %i, align 8
  %162 = load i32, i32* %j242, align 4
  %conv263 = sext i32 %162 to i64
  %sub264 = sub nsw i64 %161, %conv263
  %sub265 = sub nsw i64 %sub264, 64
  store i64 %sub265, i64* %max_j, align 8
  br label %if.end266

if.end266:                                        ; preds = %if.then262, %if.end259
  %163 = load i8, i8* %subparts_processed, align 1
  %conv267 = zext i8 %163 to i32
  %cmp268 = icmp eq i32 %conv267, 2
  br i1 %cmp268, label %if.then269, label %if.end273

if.then269:                                       ; preds = %if.end266
  %164 = load i64, i64* %i, align 8
  %165 = load i32, i32* %j242, align 4
  %conv270 = sext i32 %165 to i64
  %sub271 = sub nsw i64 %164, %conv270
  %sub272 = sub nsw i64 %sub271, 128
  store i64 %sub272, i64* %max_j, align 8
  br label %if.end273

if.end273:                                        ; preds = %if.then269, %if.end266
  %166 = load i8, i8* %subparts_processed, align 1
  %conv274 = zext i8 %166 to i32
  %cmp275 = icmp eq i32 %conv274, 3
  br i1 %cmp275, label %if.then276, label %if.end280

if.then276:                                       ; preds = %if.end273
  %167 = load i64, i64* %i, align 8
  %168 = load i32, i32* %j242, align 4
  %conv277 = sext i32 %168 to i64
  %sub278 = sub nsw i64 %167, %conv277
  %sub279 = sub nsw i64 %sub278, 192
  store i64 %sub279, i64* %max_j, align 8
  br label %if.end280

if.end280:                                        ; preds = %if.then276, %if.end273
  %169 = load i8, i8* %subparts_processed, align 1
  %conv281 = zext i8 %169 to i32
  %cmp282 = icmp eq i32 %conv281, 4
  br i1 %cmp282, label %if.then283, label %if.end287

if.then283:                                       ; preds = %if.end280
  %170 = load i64, i64* %i, align 8
  %171 = load i32, i32* %j242, align 4
  %conv284 = sext i32 %171 to i64
  %sub285 = sub nsw i64 %170, %conv284
  %sub286 = sub nsw i64 %sub285, 256
  store i64 %sub286, i64* %max_j, align 8
  br label %if.end287

if.end287:                                        ; preds = %if.then283, %if.end280
  %172 = load i8, i8* %subparts_processed, align 1
  %conv288 = zext i8 %172 to i32
  %cmp289 = icmp eq i32 %conv288, 5
  br i1 %cmp289, label %if.then290, label %if.end294

if.then290:                                       ; preds = %if.end287
  %173 = load i64, i64* %i, align 8
  %174 = load i32, i32* %j242, align 4
  %conv291 = sext i32 %174 to i64
  %sub292 = sub nsw i64 %173, %conv291
  %sub293 = sub nsw i64 %sub292, 320
  store i64 %sub293, i64* %max_j, align 8
  br label %if.end294

if.end294:                                        ; preds = %if.then290, %if.end287
  %175 = load i8, i8* %subparts_processed, align 1
  %conv295 = zext i8 %175 to i32
  %cmp296 = icmp eq i32 %conv295, 6
  br i1 %cmp296, label %if.then297, label %if.end301

if.then297:                                       ; preds = %if.end294
  %176 = load i64, i64* %i, align 8
  %177 = load i32, i32* %j242, align 4
  %conv298 = sext i32 %177 to i64
  %sub299 = sub nsw i64 %176, %conv298
  %sub300 = sub nsw i64 %sub299, 384
  store i64 %sub300, i64* %max_j, align 8
  br label %if.end301

if.end301:                                        ; preds = %if.then297, %if.end294
  %178 = load i8, i8* %subparts_processed, align 1
  %conv302 = zext i8 %178 to i32
  %cmp303 = icmp eq i32 %conv302, 7
  br i1 %cmp303, label %if.then304, label %if.end308

if.then304:                                       ; preds = %if.end301
  %179 = load i64, i64* %i, align 8
  %180 = load i32, i32* %j242, align 4
  %conv305 = sext i32 %180 to i64
  %sub306 = sub nsw i64 %179, %conv305
  %sub307 = sub nsw i64 %sub306, 448
  store i64 %sub307, i64* %max_j, align 8
  br label %if.end308

if.end308:                                        ; preds = %if.then304, %if.end301
  br label %if.end309

if.end309:                                        ; preds = %if.end308, %land.lhs.true, %for.body245
  br label %for.inc310

for.inc310:                                       ; preds = %if.end309
  %181 = load i32, i32* %j242, align 4
  %dec311 = add nsw i32 %181, -1
  store i32 %dec311, i32* %j242, align 4
  br label %for.cond243, !llvm.loop !11

for.end312:                                       ; preds = %for.cond243
  %182 = load i32, i32* %max_f, align 4
  %arrayidx313 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 0
  %183 = load i32, i32* %arrayidx313, align 16
  %cmp314 = icmp sgt i32 %182, %183
  br i1 %cmp314, label %if.then315, label %if.end320

if.then315:                                       ; preds = %for.end312
  %184 = load i32, i32* %max_f, align 4
  %185 = load i32*, i32** %f.addr, align 8
  %186 = load i64, i64* %i, align 8
  %arrayidx316 = getelementptr inbounds i32, i32* %185, i64 %186
  store i32 %184, i32* %arrayidx316, align 4
  %187 = load i64, i64* %max_j, align 8
  %conv317 = trunc i64 %187 to i32
  %188 = load i32*, i32** %p.addr, align 8
  %189 = load i64, i64* %i, align 8
  %arrayidx318 = getelementptr inbounds i32, i32* %188, i64 %189
  store i32 %conv317, i32* %arrayidx318, align 4
  %190 = load i32, i32* %max_f, align 4
  %arrayidx319 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 0
  store i32 %190, i32* %arrayidx319, align 16
  br label %if.end320

if.end320:                                        ; preds = %if.then315, %for.end312
  %191 = load i8, i8* %subparts_processed, align 1
  %inc321 = add i8 %191, 1
  store i8 %inc321, i8* %subparts_processed, align 1
  store i32 512, i32* %reg, align 4
  br label %for.cond322

for.cond322:                                      ; preds = %for.inc345, %if.end320
  %192 = load i32, i32* %reg, align 4
  %cmp323 = icmp sgt i32 %192, 0
  br i1 %cmp323, label %for.body324, label %for.end347

for.body324:                                      ; preds = %for.cond322
  %193 = load i8, i8* %subparts_processed, align 1
  %conv325 = zext i8 %193 to i32
  %194 = load i8, i8* %subparts_to_process, align 1
  %conv326 = zext i8 %194 to i32
  %cmp327 = icmp eq i32 %conv325, %conv326
  br i1 %cmp327, label %if.then328, label %if.end344

if.then328:                                       ; preds = %for.body324
  %195 = load i32, i32* %reg, align 4
  %sub329 = sub nsw i32 %195, 1
  %idxprom330 = sext i32 %sub329 to i64
  %arrayidx331 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom330
  %196 = load i32, i32* %arrayidx331, align 4
  %197 = load i32, i32* %reg, align 4
  %idxprom332 = sext i32 %197 to i64
  %arrayidx333 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 %idxprom332
  store i32 %196, i32* %arrayidx333, align 4
  %198 = load i32, i32* %reg, align 4
  %sub334 = sub nsw i32 %198, 1
  %idxprom335 = sext i32 %sub334 to i64
  %arrayidx336 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom335
  %199 = load i64, i64* %arrayidx336, align 8
  %200 = load i32, i32* %reg, align 4
  %idxprom337 = sext i32 %200 to i64
  %arrayidx338 = getelementptr inbounds [513 x i64], [513 x i64]* %a_x_local, i64 0, i64 %idxprom337
  store i64 %199, i64* %arrayidx338, align 8
  %201 = load i32, i32* %reg, align 4
  %sub339 = sub nsw i32 %201, 1
  %idxprom340 = sext i32 %sub339 to i64
  %arrayidx341 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom340
  %202 = load i32, i32* %arrayidx341, align 4
  %203 = load i32, i32* %reg, align 4
  %idxprom342 = sext i32 %203 to i64
  %arrayidx343 = getelementptr inbounds [513 x i32], [513 x i32]* %a_y_local, i64 0, i64 %idxprom342
  store i32 %202, i32* %arrayidx343, align 4
  br label %if.end344

if.end344:                                        ; preds = %if.then328, %for.body324
  br label %for.inc345

for.inc345:                                       ; preds = %if.end344
  %204 = load i32, i32* %reg, align 4
  %dec346 = add nsw i32 %204, -1
  store i32 %dec346, i32* %reg, align 4
  br label %for.cond322, !llvm.loop !12

for.end347:                                       ; preds = %for.cond322
  %205 = load i8, i8* %subparts_processed, align 1
  %conv348 = zext i8 %205 to i32
  %206 = load i8, i8* %subparts_to_process, align 1
  %conv349 = zext i8 %206 to i32
  %cmp350 = icmp eq i32 %conv348, %conv349
  br i1 %cmp350, label %if.then351, label %if.end354

if.then351:                                       ; preds = %for.end347
  %arrayidx352 = getelementptr inbounds [513 x i32], [513 x i32]* %f_local, i64 0, i64 0
  store i32 0, i32* %arrayidx352, align 16
  %207 = load i64, i64* %i, align 8
  %inc353 = add nsw i64 %207, 1
  store i64 %inc353, i64* %i, align 8
  store i8 0, i8* %subparts_processed, align 1
  br label %if.end354

if.end354:                                        ; preds = %if.then351, %for.end347
  call void @checkpoint()
  br label %for.inc355

for.inc355:                                       ; preds = %if.end354
  %208 = load i64, i64* %g, align 8
  %inc356 = add nsw i64 %208, 1
  store i64 %inc356, i64* %g, align 8
  br label %for.cond15, !llvm.loop !13

for.end357:                                       ; preds = %for.cond15
  ret void
}

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local i32 @ilog2_32(i32 noundef %v) #0 comdat {
entry:
  %retval = alloca i32, align 4
  %v.addr = alloca i32, align 4
  %t = alloca i32, align 4
  %tt = alloca i32, align 4
  store i32 %v, i32* %v.addr, align 4
  %0 = load i32, i32* %v.addr, align 4
  %shr = lshr i32 %0, 16
  store i32 %shr, i32* %tt, align 4
  %tobool = icmp ne i32 %shr, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %1 = load i32, i32* %tt, align 4
  %shr1 = lshr i32 %1, 8
  store i32 %shr1, i32* %t, align 4
  %tobool2 = icmp ne i32 %shr1, 0
  br i1 %tobool2, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %2 = load i32, i32* %t, align 4
  %idxprom = zext i32 %2 to i64
  %arrayidx = getelementptr inbounds [256 x i8], [256 x i8]* @LogTable256, i64 0, i64 %idxprom
  %3 = load i8, i8* %arrayidx, align 1
  %conv = sext i8 %3 to i32
  %add = add nsw i32 24, %conv
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %4 = load i32, i32* %tt, align 4
  %idxprom3 = zext i32 %4 to i64
  %arrayidx4 = getelementptr inbounds [256 x i8], [256 x i8]* @LogTable256, i64 0, i64 %idxprom3
  %5 = load i8, i8* %arrayidx4, align 1
  %conv5 = sext i8 %5 to i32
  %add6 = add nsw i32 16, %conv5
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %add, %cond.true ], [ %add6, %cond.false ]
  store i32 %cond, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %6 = load i32, i32* %v.addr, align 4
  %shr7 = lshr i32 %6, 8
  store i32 %shr7, i32* %t, align 4
  %tobool8 = icmp ne i32 %shr7, 0
  br i1 %tobool8, label %cond.true9, label %cond.false14

cond.true9:                                       ; preds = %if.end
  %7 = load i32, i32* %t, align 4
  %idxprom10 = zext i32 %7 to i64
  %arrayidx11 = getelementptr inbounds [256 x i8], [256 x i8]* @LogTable256, i64 0, i64 %idxprom10
  %8 = load i8, i8* %arrayidx11, align 1
  %conv12 = sext i8 %8 to i32
  %add13 = add nsw i32 8, %conv12
  br label %cond.end18

cond.false14:                                     ; preds = %if.end
  %9 = load i32, i32* %v.addr, align 4
  %idxprom15 = zext i32 %9 to i64
  %arrayidx16 = getelementptr inbounds [256 x i8], [256 x i8]* @LogTable256, i64 0, i64 %idxprom15
  %10 = load i8, i8* %arrayidx16, align 1
  %conv17 = sext i8 %10 to i32
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false14, %cond.true9
  %cond19 = phi i32 [ %add13, %cond.true9 ], [ %conv17, %cond.false14 ]
  store i32 %cond19, i32* %retval, align 4
  br label %return

return:                                           ; preds = %cond.end18, %cond.end
  %11 = load i32, i32* %retval, align 4
  ret i32 %11
}

attributes #0 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly nofree nounwind willreturn }
attributes #2 = { mustprogress noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { argmemonly nofree nounwind willreturn writeonly }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
