; ModuleID = '../ir/cholesky.ll'
source_filename = "../cholesky_kernel_cpu.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [20 x i8] c">> cholesky_kernel\0A\00", align 1
@.str.1 = private unnamed_addr constant [21 x i8] c">> ckpt_mem[3] = %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [4 x i8] c"%d \00", align 1
@.str.3 = private unnamed_addr constant [16 x i8] c"\0A>> end kernel\0A\00", align 1
@.str.4 = private unnamed_addr constant [31 x i8] c"> workload: Starting workload\0A\00", align 1
@.str.5 = private unnamed_addr constant [27 x i8] c"> workload: isComplete=%f\0A\00", align 1

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @checkpoint() #0 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline uwtable
define dso_local void @cholesky_kernel(i32 noundef %diagSize, double* noundef %matrixA, double* noundef %ckpt_mem) #1 {
entry.upper:
  %diagSize.addr = alloca i32, align 4
  %matrixA.addr = alloca double*, align 8
  %ckpt_mem.addr = alloca double*, align 8
  %dataA = alloca [650 x [650 x double]], align 16
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %tmp1 = alloca double, align 8
  %i18 = alloca i32, align 4
  %j31 = alloca i32, align 4
  %tmp = alloca double, align 8
  %k = alloca i32, align 4
  %i61 = alloca i32, align 4
  %tmp2 = alloca double, align 8
  %k66 = alloca i32, align 4
  %i103 = alloca i32, align 4
  %j107 = alloca i32, align 4
  store i32 %diagSize, i32* %diagSize.addr, align 4
  store double* %matrixA, double** %matrixA.addr, align 8
  store double* %ckpt_mem, double** %ckpt_mem.addr, align 8
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0))
  %0 = load double*, double** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds double, double* %0, i64 3
  %1 = load double, double* %arrayidx, align 8
  %call1 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([21 x i8], [21 x i8]* @.str.1, i64 0, i64 0), double noundef %1)
  store i32 0, i32* %i, align 4
  br label %cholesky_kernel.restoreControllerBB

cholesky_kernel.restoreControllerBB:              ; preds = %entry.upper
  %idx_ckpt_id_load = getelementptr inbounds double, double* %ckpt_mem, i32 1
  %load_ckpt_id = load double, double* %idx_ckpt_id_load, align 8
  %i32_ckpt_id = fptosi double %load_ckpt_id to i32
  switch i32 %i32_ckpt_id, label %entry.lower [
    i32 1, label %if.end.restoreBB.id1
  ]

entry.lower:                                      ; preds = %cholesky_kernel.restoreControllerBB
  br label %for.cond.upper

for.cond.upper:                                   ; preds = %for.inc10, %entry.lower
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %diagSize.addr, align 4
  br label %for.cond.lower

for.cond.lower:                                   ; preds = %for.cond.upper
  %cmp = icmp slt i32 %2, %3
  br i1 %cmp, label %for.body, label %for.end12

for.body:                                         ; preds = %for.cond.lower
  store i32 0, i32* %j, align 4
  br label %for.cond2.upper

for.cond2.upper:                                  ; preds = %for.inc, %for.body
  %4 = load i32, i32* %j, align 4
  %5 = load i32, i32* %diagSize.addr, align 4
  br label %for.cond2.lower

for.cond2.lower:                                  ; preds = %for.cond2.upper
  %cmp3 = icmp slt i32 %4, %5
  br i1 %cmp3, label %for.body4, label %for.end

for.body4:                                        ; preds = %for.cond2.lower
  %6 = load double*, double** %matrixA.addr, align 8
  %7 = load i32, i32* %i, align 4
  %8 = load i32, i32* %diagSize.addr, align 4
  %mul = mul nsw i32 %7, %8
  %9 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %9
  %idxprom = sext i32 %add to i64
  %arrayidx5 = getelementptr inbounds double, double* %6, i64 %idxprom
  %10 = load double, double* %arrayidx5, align 8
  %11 = load i32, i32* %i, align 4
  %idxprom6 = sext i32 %11 to i64
  %arrayidx7 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom6
  %12 = load i32, i32* %j, align 4
  %idxprom8 = sext i32 %12 to i64
  %arrayidx9 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx7, i64 0, i64 %idxprom8
  store double %10, double* %arrayidx9, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body4
  %13 = load i32, i32* %j, align 4
  %inc = add nsw i32 %13, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond2.upper, !llvm.loop !6

for.end:                                          ; preds = %for.cond2.lower
  br label %for.inc10

for.inc10:                                        ; preds = %for.end
  %14 = load i32, i32* %i, align 4
  %inc11 = add nsw i32 %14, 1
  store i32 %inc11, i32* %i, align 4
  br label %for.cond.upper, !llvm.loop !8

for.end12:                                        ; preds = %for.cond.lower
  %arrayidx13 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 0
  %arrayidx14 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx13, i64 0, i64 0
  %15 = load double, double* %arrayidx14, align 16
  %call15 = call double @sqrt(double noundef %15) #6
  store double %call15, double* %tmp1, align 8
  %16 = load double, double* %tmp1, align 8
  %arrayidx16 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 0
  %arrayidx17 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx16, i64 0, i64 0
  store double %16, double* %arrayidx17, align 16
  br label %Loop_first_col

Loop_first_col:                                   ; preds = %for.end12
  store i32 1, i32* %i18, align 4
  br label %for.cond19.upper

for.cond19.upper:                                 ; preds = %for.inc28, %Loop_first_col
  %17 = load i32, i32* %i18, align 4
  %18 = load i32, i32* %diagSize.addr, align 4
  br label %for.cond19.lower

for.cond19.lower:                                 ; preds = %for.cond19.upper
  %cmp20 = icmp slt i32 %17, %18
  br i1 %cmp20, label %for.body21, label %for.end30

for.body21:                                       ; preds = %for.cond19.lower
  %19 = load i32, i32* %i18, align 4
  %idxprom22 = sext i32 %19 to i64
  %arrayidx23 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom22
  %arrayidx24 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx23, i64 0, i64 0
  %20 = load double, double* %arrayidx24, align 16
  %21 = load double, double* %tmp1, align 8
  %div = fdiv double %20, %21
  %22 = load i32, i32* %i18, align 4
  %idxprom25 = sext i32 %22 to i64
  %arrayidx26 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom25
  %arrayidx27 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx26, i64 0, i64 0
  store double %div, double* %arrayidx27, align 16
  br label %for.inc28

for.inc28:                                        ; preds = %for.body21
  %23 = load i32, i32* %i18, align 4
  %inc29 = add nsw i32 %23, 1
  store i32 %inc29, i32* %i18, align 4
  br label %for.cond19.upper, !llvm.loop !9

for.end30:                                        ; preds = %for.cond19.lower
  br label %Loop_col

Loop_col:                                         ; preds = %for.end30
  store i32 1, i32* %j31, align 4
  br label %for.cond32.upper

for.cond32.upper:                                 ; preds = %for.inc100, %Loop_col
  %new_j107.phi = phi i32* [ %new_j107, %for.inc100 ], [ %j107, %Loop_col ]
  %new_i103.phi = phi i32* [ %new_i103, %for.inc100 ], [ %i103, %Loop_col ]
  %new_k66.phi = phi i32* [ %new_k66, %for.inc100 ], [ %k66, %Loop_col ]
  %new_tmp2.phi = phi double* [ %new_tmp2, %for.inc100 ], [ %tmp2, %Loop_col ]
  %new_i61.phi = phi i32* [ %new_i61, %for.inc100 ], [ %i61, %Loop_col ]
  %new_k.phi = phi i32* [ %new_k, %for.inc100 ], [ %k, %Loop_col ]
  %new_tmp.phi = phi double* [ %new_tmp, %for.inc100 ], [ %tmp, %Loop_col ]
  %new_j31.phi = phi i32* [ %new_j31, %for.inc100 ], [ %j31, %Loop_col ]
  %new_diagSize.addr.phi = phi i32* [ %new_diagSize.addr, %for.inc100 ], [ %diagSize.addr, %Loop_col ]
  %24 = load i32, i32* %new_j31.phi, align 4
  %25 = load i32, i32* %new_diagSize.addr.phi, align 4
  br label %for.cond32.lower

for.cond32.lower:                                 ; preds = %for.cond32.upper
  %cmp33 = icmp slt i32 %24, %25
  br i1 %cmp33, label %for.body34, label %for.end102

for.body34:                                       ; preds = %for.cond32.lower
  store double 0.000000e+00, double* %new_tmp.phi, align 8
  br label %Loop_diag

Loop_diag:                                        ; preds = %for.body34
  store i32 0, i32* %new_k.phi, align 4
  br label %for.cond35.upper

for.cond35.upper:                                 ; preds = %for.inc47, %Loop_diag
  %new_j107.phi.phi23 = phi i32* [ %new_j107.phi.phi23, %for.inc47 ], [ %new_j107.phi, %Loop_diag ]
  %new_i103.phi.phi21 = phi i32* [ %new_i103.phi.phi21, %for.inc47 ], [ %new_i103.phi, %Loop_diag ]
  %new_k66.phi.phi = phi i32* [ %new_k66.phi.phi, %for.inc47 ], [ %new_k66.phi, %Loop_diag ]
  %new_tmp2.phi.phi = phi double* [ %new_tmp2.phi.phi, %for.inc47 ], [ %new_tmp2.phi, %Loop_diag ]
  %new_i61.phi.phi = phi i32* [ %new_i61.phi.phi, %for.inc47 ], [ %new_i61.phi, %Loop_diag ]
  %new_k.phi.phi = phi i32* [ %new_k.phi.phi, %for.inc47 ], [ %new_k.phi, %Loop_diag ]
  %new_tmp.phi.phi = phi double* [ %new_tmp.phi.phi, %for.inc47 ], [ %new_tmp.phi, %Loop_diag ]
  %new_j31.phi.phi = phi i32* [ %new_j31.phi.phi, %for.inc47 ], [ %new_j31.phi, %Loop_diag ]
  %new_diagSize.addr.phi.phi13 = phi i32* [ %new_diagSize.addr.phi.phi13, %for.inc47 ], [ %new_diagSize.addr.phi, %Loop_diag ]
  %26 = load i32, i32* %new_k.phi.phi, align 4
  %27 = load i32, i32* %new_j31.phi.phi, align 4
  br label %for.cond35.lower

for.cond35.lower:                                 ; preds = %for.cond35.upper
  %cmp36 = icmp slt i32 %26, %27
  br i1 %cmp36, label %for.body37, label %for.end49.upper

for.body37:                                       ; preds = %for.cond35.lower
  %28 = load i32, i32* %new_j31.phi.phi, align 4
  %idxprom38 = sext i32 %28 to i64
  %arrayidx39 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom38
  %29 = load i32, i32* %new_k.phi.phi, align 4
  %idxprom40 = sext i32 %29 to i64
  %arrayidx41 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx39, i64 0, i64 %idxprom40
  %30 = load double, double* %arrayidx41, align 8
  %31 = load i32, i32* %new_j31.phi.phi, align 4
  %idxprom42 = sext i32 %31 to i64
  %arrayidx43 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom42
  %32 = load i32, i32* %new_k.phi.phi, align 4
  %idxprom44 = sext i32 %32 to i64
  %arrayidx45 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx43, i64 0, i64 %idxprom44
  %33 = load double, double* %arrayidx45, align 8
  %34 = load double, double* %new_tmp.phi.phi, align 8
  %35 = call double @llvm.fmuladd.f64(double %30, double %33, double %34)
  store double %35, double* %new_tmp.phi.phi, align 8
  br label %for.inc47

for.inc47:                                        ; preds = %for.body37
  %36 = load i32, i32* %new_k.phi.phi, align 4
  %inc48 = add nsw i32 %36, 1
  store i32 %inc48, i32* %new_k.phi.phi, align 4
  br label %for.cond35.upper, !llvm.loop !10

for.end49.upper:                                  ; preds = %for.cond35.lower
  %37 = load i32, i32* %new_j31.phi.phi, align 4
  %idxprom50 = sext i32 %37 to i64
  %arrayidx51 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom50
  %38 = load i32, i32* %new_j31.phi.phi, align 4
  %idxprom52 = sext i32 %38 to i64
  %arrayidx53 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx51, i64 0, i64 %idxprom52
  %39 = load double, double* %arrayidx53, align 8
  %40 = load double, double* %new_tmp.phi.phi, align 8
  %sub = fsub double %39, %40
  %call54 = call double @sqrt(double noundef %sub) #6
  %41 = load i32, i32* %new_j31.phi.phi, align 4
  %idxprom55 = sext i32 %41 to i64
  %arrayidx56 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom55
  %42 = load i32, i32* %new_j31.phi.phi, align 4
  %idxprom57 = sext i32 %42 to i64
  %arrayidx58 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx56, i64 0, i64 %idxprom57
  store double %call54, double* %arrayidx58, align 8
  %43 = load i32, i32* %new_j31.phi.phi, align 4
  %44 = load i32, i32* %new_diagSize.addr.phi.phi13, align 4
  %sub59 = sub nsw i32 %44, 1
  br label %for.end49.lower

for.end49.lower:                                  ; preds = %for.end49.upper
  %cmp60 = icmp slt i32 %43, %sub59
  br i1 %cmp60, label %if.then, label %if.end

if.then:                                          ; preds = %for.end49.lower
  br label %Loop_row

Loop_row:                                         ; preds = %if.then
  %45 = load i32, i32* %new_j31.phi.phi, align 4
  %add62 = add nsw i32 %45, 1
  store i32 %add62, i32* %new_i61.phi.phi, align 4
  br label %for.cond63.upper

for.cond63.upper:                                 ; preds = %for.inc96, %Loop_row
  %new_j107.phi.phi23.phi24 = phi i32* [ %new_j107.phi.phi23.phi24.phi, %for.inc96 ], [ %new_j107.phi.phi23, %Loop_row ]
  %new_i103.phi.phi21.phi22 = phi i32* [ %new_i103.phi.phi21.phi22.phi, %for.inc96 ], [ %new_i103.phi.phi21, %Loop_row ]
  %new_k66.phi.phi.phi20 = phi i32* [ %new_k66.phi.phi.phi20.phi, %for.inc96 ], [ %new_k66.phi.phi, %Loop_row ]
  %new_tmp2.phi.phi.phi19 = phi double* [ %new_tmp2.phi.phi.phi19.phi, %for.inc96 ], [ %new_tmp2.phi.phi, %Loop_row ]
  %new_i61.phi.phi.phi18 = phi i32* [ %new_i61.phi.phi.phi18.phi, %for.inc96 ], [ %new_i61.phi.phi, %Loop_row ]
  %new_k.phi.phi.phi17 = phi i32* [ %new_k.phi.phi.phi17.phi, %for.inc96 ], [ %new_k.phi.phi, %Loop_row ]
  %new_tmp.phi.phi.phi16 = phi double* [ %new_tmp.phi.phi.phi16.phi, %for.inc96 ], [ %new_tmp.phi.phi, %Loop_row ]
  %new_j31.phi.phi.phi15 = phi i32* [ %new_j31.phi.phi.phi15.phi, %for.inc96 ], [ %new_j31.phi.phi, %Loop_row ]
  %new_diagSize.addr.phi.phi13.phi14 = phi i32* [ %new_diagSize.addr.phi.phi13.phi14.phi, %for.inc96 ], [ %new_diagSize.addr.phi.phi13, %Loop_row ]
  %46 = load i32, i32* %new_i61.phi.phi.phi18, align 4
  %47 = load i32, i32* %new_diagSize.addr.phi.phi13.phi14, align 4
  br label %for.cond63.lower

for.cond63.lower:                                 ; preds = %for.cond63.upper
  %cmp64 = icmp slt i32 %46, %47
  br i1 %cmp64, label %for.body65, label %for.end98

for.body65:                                       ; preds = %for.cond63.lower
  store double 0.000000e+00, double* %new_tmp2.phi.phi.phi19, align 8
  br label %Loop_vec_mul

Loop_vec_mul:                                     ; preds = %for.body65
  store i32 0, i32* %new_k66.phi.phi.phi20, align 4
  br label %for.cond67.upper

for.cond67.upper:                                 ; preds = %for.inc79, %Loop_vec_mul
  %new_j107.phi.phi23.phi24.phi = phi i32* [ %new_j107.phi.phi23.phi24.phi, %for.inc79 ], [ %new_j107.phi.phi23.phi24, %Loop_vec_mul ]
  %new_i103.phi.phi21.phi22.phi = phi i32* [ %new_i103.phi.phi21.phi22.phi, %for.inc79 ], [ %new_i103.phi.phi21.phi22, %Loop_vec_mul ]
  %new_k66.phi.phi.phi20.phi = phi i32* [ %new_k66.phi.phi.phi20.phi, %for.inc79 ], [ %new_k66.phi.phi.phi20, %Loop_vec_mul ]
  %new_tmp2.phi.phi.phi19.phi = phi double* [ %new_tmp2.phi.phi.phi19.phi, %for.inc79 ], [ %new_tmp2.phi.phi.phi19, %Loop_vec_mul ]
  %new_i61.phi.phi.phi18.phi = phi i32* [ %new_i61.phi.phi.phi18.phi, %for.inc79 ], [ %new_i61.phi.phi.phi18, %Loop_vec_mul ]
  %new_k.phi.phi.phi17.phi = phi i32* [ %new_k.phi.phi.phi17.phi, %for.inc79 ], [ %new_k.phi.phi.phi17, %Loop_vec_mul ]
  %new_tmp.phi.phi.phi16.phi = phi double* [ %new_tmp.phi.phi.phi16.phi, %for.inc79 ], [ %new_tmp.phi.phi.phi16, %Loop_vec_mul ]
  %new_j31.phi.phi.phi15.phi = phi i32* [ %new_j31.phi.phi.phi15.phi, %for.inc79 ], [ %new_j31.phi.phi.phi15, %Loop_vec_mul ]
  %new_diagSize.addr.phi.phi13.phi14.phi = phi i32* [ %new_diagSize.addr.phi.phi13.phi14.phi, %for.inc79 ], [ %new_diagSize.addr.phi.phi13.phi14, %Loop_vec_mul ]
  %48 = load i32, i32* %new_k66.phi.phi.phi20.phi, align 4
  %49 = load i32, i32* %new_j31.phi.phi.phi15.phi, align 4
  br label %for.cond67.lower

for.cond67.lower:                                 ; preds = %for.cond67.upper
  %cmp68 = icmp slt i32 %48, %49
  br i1 %cmp68, label %for.body69, label %for.end81

for.body69:                                       ; preds = %for.cond67.lower
  %50 = load i32, i32* %new_i61.phi.phi.phi18.phi, align 4
  %idxprom70 = sext i32 %50 to i64
  %arrayidx71 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom70
  %51 = load i32, i32* %new_k66.phi.phi.phi20.phi, align 4
  %idxprom72 = sext i32 %51 to i64
  %arrayidx73 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx71, i64 0, i64 %idxprom72
  %52 = load double, double* %arrayidx73, align 8
  %53 = load i32, i32* %new_j31.phi.phi.phi15.phi, align 4
  %idxprom74 = sext i32 %53 to i64
  %arrayidx75 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom74
  %54 = load i32, i32* %new_k66.phi.phi.phi20.phi, align 4
  %idxprom76 = sext i32 %54 to i64
  %arrayidx77 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx75, i64 0, i64 %idxprom76
  %55 = load double, double* %arrayidx77, align 8
  %56 = load double, double* %new_tmp2.phi.phi.phi19.phi, align 8
  %57 = call double @llvm.fmuladd.f64(double %52, double %55, double %56)
  store double %57, double* %new_tmp2.phi.phi.phi19.phi, align 8
  br label %for.inc79

for.inc79:                                        ; preds = %for.body69
  %58 = load i32, i32* %new_k66.phi.phi.phi20.phi, align 4
  %inc80 = add nsw i32 %58, 1
  store i32 %inc80, i32* %new_k66.phi.phi.phi20.phi, align 4
  br label %for.cond67.upper, !llvm.loop !11

for.end81:                                        ; preds = %for.cond67.lower
  %59 = load i32, i32* %new_i61.phi.phi.phi18.phi, align 4
  %idxprom82 = sext i32 %59 to i64
  %arrayidx83 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom82
  %60 = load i32, i32* %new_j31.phi.phi.phi15.phi, align 4
  %idxprom84 = sext i32 %60 to i64
  %arrayidx85 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx83, i64 0, i64 %idxprom84
  %61 = load double, double* %arrayidx85, align 8
  %62 = load double, double* %new_tmp2.phi.phi.phi19.phi, align 8
  %sub86 = fsub double %61, %62
  %63 = load i32, i32* %new_j31.phi.phi.phi15.phi, align 4
  %idxprom87 = sext i32 %63 to i64
  %arrayidx88 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom87
  %64 = load i32, i32* %new_j31.phi.phi.phi15.phi, align 4
  %idxprom89 = sext i32 %64 to i64
  %arrayidx90 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx88, i64 0, i64 %idxprom89
  %65 = load double, double* %arrayidx90, align 8
  %div91 = fdiv double %sub86, %65
  %66 = load i32, i32* %new_i61.phi.phi.phi18.phi, align 4
  %idxprom92 = sext i32 %66 to i64
  %arrayidx93 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom92
  %67 = load i32, i32* %new_j31.phi.phi.phi15.phi, align 4
  %idxprom94 = sext i32 %67 to i64
  %arrayidx95 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx93, i64 0, i64 %idxprom94
  store double %div91, double* %arrayidx95, align 8
  br label %for.inc96

for.inc96:                                        ; preds = %for.end81
  %68 = load i32, i32* %new_i61.phi.phi.phi18.phi, align 4
  %inc97 = add nsw i32 %68, 1
  store i32 %inc97, i32* %new_i61.phi.phi.phi18.phi, align 4
  br label %for.cond63.upper, !llvm.loop !12

for.end98:                                        ; preds = %for.cond63.lower
  br label %if.end

if.end:                                           ; preds = %for.end98, %for.end49.lower
  %new_j107.phi.phi23.phi = phi i32* [ %new_j107.phi.phi23.phi24, %for.end98 ], [ %new_j107.phi.phi23, %for.end49.lower ]
  %new_i103.phi.phi21.phi = phi i32* [ %new_i103.phi.phi21.phi22, %for.end98 ], [ %new_i103.phi.phi21, %for.end49.lower ]
  %new_k66.phi.phi.phi = phi i32* [ %new_k66.phi.phi.phi20, %for.end98 ], [ %new_k66.phi.phi, %for.end49.lower ]
  %new_tmp2.phi.phi.phi = phi double* [ %new_tmp2.phi.phi.phi19, %for.end98 ], [ %new_tmp2.phi.phi, %for.end49.lower ]
  %new_i61.phi.phi.phi = phi i32* [ %new_i61.phi.phi.phi18, %for.end98 ], [ %new_i61.phi.phi, %for.end49.lower ]
  %new_k.phi.phi.phi = phi i32* [ %new_k.phi.phi.phi17, %for.end98 ], [ %new_k.phi.phi, %for.end49.lower ]
  %new_tmp.phi.phi.phi = phi double* [ %new_tmp.phi.phi.phi16, %for.end98 ], [ %new_tmp.phi.phi, %for.end49.lower ]
  %new_j31.phi.phi.phi = phi i32* [ %new_j31.phi.phi.phi15, %for.end98 ], [ %new_j31.phi.phi, %for.end49.lower ]
  %new_diagSize.addr.phi.phi13.phi = phi i32* [ %new_diagSize.addr.phi.phi13.phi14, %for.end98 ], [ %new_diagSize.addr.phi.phi13, %for.end49.lower ]
  %69 = load i32, i32* %new_j31.phi.phi.phi, align 4
  %call99 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([4 x i8], [4 x i8]* @.str.2, i64 0, i64 0), i32 noundef %69)
  br label %if.end.saveBB.id1

if.end.saveBB.id1:                                ; preds = %if.end
  %idx_dataA = getelementptr inbounds double, double* %ckpt_mem, i32 3
  %70 = bitcast double* %idx_dataA to i8*
  %71 = bitcast [650 x [650 x double]]* %dataA to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %70, i8* align 8 %71, i64 3380000, i1 true)
  %idx_diagSize.addr = getelementptr inbounds double, double* %ckpt_mem, i32 422503
  %deref_diagSize.addr = load i32, i32* %new_diagSize.addr.phi.phi13.phi, align 4
  %fp_deref_diagSize.addr = sitofp i32 %deref_diagSize.addr to double
  store double %fp_deref_diagSize.addr, double* %idx_diagSize.addr, align 8
  %idx_i103 = getelementptr inbounds double, double* %ckpt_mem, i32 422504
  %deref_i103 = load i32, i32* %new_i103.phi.phi21.phi, align 4
  %fp_deref_i103 = sitofp i32 %deref_i103 to double
  store double %fp_deref_i103, double* %idx_i103, align 8
  %idx_i61 = getelementptr inbounds double, double* %ckpt_mem, i32 422505
  %deref_i61 = load i32, i32* %new_i61.phi.phi.phi, align 4
  %fp_deref_i61 = sitofp i32 %deref_i61 to double
  store double %fp_deref_i61, double* %idx_i61, align 8
  %idx_j107 = getelementptr inbounds double, double* %ckpt_mem, i32 422506
  %deref_j107 = load i32, i32* %new_j107.phi.phi23.phi, align 4
  %fp_deref_j107 = sitofp i32 %deref_j107 to double
  store double %fp_deref_j107, double* %idx_j107, align 8
  %idx_j31 = getelementptr inbounds double, double* %ckpt_mem, i32 422507
  %deref_j31 = load i32, i32* %new_j31.phi.phi.phi, align 4
  %fp_deref_j31 = sitofp i32 %deref_j31 to double
  store double %fp_deref_j31, double* %idx_j31, align 8
  %idx_k = getelementptr inbounds double, double* %ckpt_mem, i32 422508
  %deref_k = load i32, i32* %new_k.phi.phi.phi, align 4
  %fp_deref_k = sitofp i32 %deref_k to double
  store double %fp_deref_k, double* %idx_k, align 8
  %idx_k66 = getelementptr inbounds double, double* %ckpt_mem, i32 422509
  %deref_k66 = load i32, i32* %new_k66.phi.phi.phi, align 4
  %fp_deref_k66 = sitofp i32 %deref_k66 to double
  store double %fp_deref_k66, double* %idx_k66, align 8
  %idx_matrixA.addr = getelementptr inbounds double, double* %ckpt_mem, i32 422510
  %loaded_matrixA.addr = load double*, double** %matrixA.addr, align 8
  %72 = bitcast double* %idx_matrixA.addr to i8*
  %73 = bitcast double* %loaded_matrixA.addr to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %72, i8* align 8 %73, i64 338000, i1 true)
  %idx_tmp = getelementptr inbounds double, double* %ckpt_mem, i32 464760
  %deref_tmp = load double, double* %new_tmp.phi.phi.phi, align 8
  store double %deref_tmp, double* %idx_tmp, align 8
  %idx_tmp2 = getelementptr inbounds double, double* %ckpt_mem, i32 464761
  %deref_tmp2 = load double, double* %new_tmp2.phi.phi.phi, align 8
  store double %deref_tmp2, double* %idx_tmp2, align 8
  %idx_ckpt_id = getelementptr inbounds double, double* %ckpt_mem, i32 1
  %fp_ckpt_id = sitofp i32 1 to double
  store double %fp_ckpt_id, double* %idx_ckpt_id, align 8
  %idx_heartbeat = getelementptr inbounds double, double* %ckpt_mem, i32 0
  %load_heartbeat = load double, double* %idx_heartbeat, align 8
  %i32_heartbeat = fptosi double %load_heartbeat to i32
  %heartbeat_incr = add i32 %i32_heartbeat, 1
  %fp_heartbeat_incr = sitofp i32 %heartbeat_incr to double
  store double %fp_heartbeat_incr, double* %idx_heartbeat, align 8
  br label %if.end.junctionBB.id1

if.end.junctionBB.id1:                            ; preds = %if.end.restoreBB.id1, %if.end.saveBB.id1
  %new_diagSize.addr = phi i32* [ %alloca_diagSize.addr, %if.end.restoreBB.id1 ], [ %new_diagSize.addr.phi.phi13.phi, %if.end.saveBB.id1 ]
  %new_i103 = phi i32* [ %alloca_i103, %if.end.restoreBB.id1 ], [ %new_i103.phi.phi21.phi, %if.end.saveBB.id1 ]
  %new_i61 = phi i32* [ %alloca_i61, %if.end.restoreBB.id1 ], [ %new_i61.phi.phi.phi, %if.end.saveBB.id1 ]
  %new_j107 = phi i32* [ %alloca_j107, %if.end.restoreBB.id1 ], [ %new_j107.phi.phi23.phi, %if.end.saveBB.id1 ]
  %new_j31 = phi i32* [ %alloca_j31, %if.end.restoreBB.id1 ], [ %new_j31.phi.phi.phi, %if.end.saveBB.id1 ]
  %new_k = phi i32* [ %alloca_k, %if.end.restoreBB.id1 ], [ %new_k.phi.phi.phi, %if.end.saveBB.id1 ]
  %new_k66 = phi i32* [ %alloca_k66, %if.end.restoreBB.id1 ], [ %new_k66.phi.phi.phi, %if.end.saveBB.id1 ]
  %new_tmp = phi double* [ %alloca_tmp, %if.end.restoreBB.id1 ], [ %new_tmp.phi.phi.phi, %if.end.saveBB.id1 ]
  %new_tmp2 = phi double* [ %alloca_tmp2, %if.end.restoreBB.id1 ], [ %new_tmp2.phi.phi.phi, %if.end.saveBB.id1 ]
  br label %for.inc100

for.inc100:                                       ; preds = %if.end.junctionBB.id1
  %74 = load i32, i32* %new_j31, align 4
  %inc101 = add nsw i32 %74, 1
  store i32 %inc101, i32* %new_j31, align 4
  br label %for.cond32.upper, !llvm.loop !13

for.end102:                                       ; preds = %for.cond32.lower
  store i32 0, i32* %new_i103.phi, align 4
  br label %for.cond104.upper

for.cond104.upper:                                ; preds = %for.inc122, %for.end102
  %new_j107.phi.phi = phi i32* [ %new_j107.phi.phi.phi, %for.inc122 ], [ %new_j107.phi, %for.end102 ]
  %new_i103.phi.phi = phi i32* [ %new_i103.phi.phi.phi, %for.inc122 ], [ %new_i103.phi, %for.end102 ]
  %new_diagSize.addr.phi.phi = phi i32* [ %new_diagSize.addr.phi.phi.phi, %for.inc122 ], [ %new_diagSize.addr.phi, %for.end102 ]
  %75 = load i32, i32* %new_i103.phi.phi, align 4
  %76 = load i32, i32* %new_diagSize.addr.phi.phi, align 4
  br label %for.cond104.lower

for.cond104.lower:                                ; preds = %for.cond104.upper
  %cmp105 = icmp slt i32 %75, %76
  br i1 %cmp105, label %for.body106, label %for.end124

for.body106:                                      ; preds = %for.cond104.lower
  store i32 0, i32* %new_j107.phi.phi, align 4
  br label %for.cond108.upper

for.cond108.upper:                                ; preds = %for.inc119, %for.body106
  %new_j107.phi.phi.phi = phi i32* [ %new_j107.phi.phi.phi, %for.inc119 ], [ %new_j107.phi.phi, %for.body106 ]
  %new_i103.phi.phi.phi = phi i32* [ %new_i103.phi.phi.phi, %for.inc119 ], [ %new_i103.phi.phi, %for.body106 ]
  %new_diagSize.addr.phi.phi.phi = phi i32* [ %new_diagSize.addr.phi.phi.phi, %for.inc119 ], [ %new_diagSize.addr.phi.phi, %for.body106 ]
  %77 = load i32, i32* %new_j107.phi.phi.phi, align 4
  %78 = load i32, i32* %new_diagSize.addr.phi.phi.phi, align 4
  br label %for.cond108.lower

for.cond108.lower:                                ; preds = %for.cond108.upper
  %cmp109 = icmp slt i32 %77, %78
  br i1 %cmp109, label %for.body110, label %for.end121

for.body110:                                      ; preds = %for.cond108.lower
  %79 = load i32, i32* %new_i103.phi.phi.phi, align 4
  %idxprom111 = sext i32 %79 to i64
  %arrayidx112 = getelementptr inbounds [650 x [650 x double]], [650 x [650 x double]]* %dataA, i64 0, i64 %idxprom111
  %80 = load i32, i32* %new_j107.phi.phi.phi, align 4
  %idxprom113 = sext i32 %80 to i64
  %arrayidx114 = getelementptr inbounds [650 x double], [650 x double]* %arrayidx112, i64 0, i64 %idxprom113
  %81 = load double, double* %arrayidx114, align 8
  %82 = load double*, double** %matrixA.addr, align 8
  %83 = load i32, i32* %new_i103.phi.phi.phi, align 4
  %84 = load i32, i32* %new_diagSize.addr.phi.phi.phi, align 4
  %mul115 = mul nsw i32 %83, %84
  %85 = load i32, i32* %new_j107.phi.phi.phi, align 4
  %add116 = add nsw i32 %mul115, %85
  %idxprom117 = sext i32 %add116 to i64
  %arrayidx118 = getelementptr inbounds double, double* %82, i64 %idxprom117
  store double %81, double* %arrayidx118, align 8
  br label %for.inc119

for.inc119:                                       ; preds = %for.body110
  %86 = load i32, i32* %new_j107.phi.phi.phi, align 4
  %inc120 = add nsw i32 %86, 1
  store i32 %inc120, i32* %new_j107.phi.phi.phi, align 4
  br label %for.cond108.upper, !llvm.loop !14

for.end121:                                       ; preds = %for.cond108.lower
  br label %for.inc122

for.inc122:                                       ; preds = %for.end121
  %87 = load i32, i32* %new_i103.phi.phi.phi, align 4
  %inc123 = add nsw i32 %87, 1
  store i32 %inc123, i32* %new_i103.phi.phi.phi, align 4
  br label %for.cond104.upper, !llvm.loop !15

for.end124:                                       ; preds = %for.cond104.lower
  %call125 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([16 x i8], [16 x i8]* @.str.3, i64 0, i64 0))
  %88 = load double*, double** %ckpt_mem.addr, align 8
  %arrayidx126 = getelementptr inbounds double, double* %88, i64 3
  %89 = load double, double* %arrayidx126, align 8
  %call127 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([21 x i8], [21 x i8]* @.str.1, i64 0, i64 0), double noundef %89)
  %idx_isComplete = getelementptr inbounds double, double* %ckpt_mem, i32 2
  %fp_isComplete = sitofp i32 1 to double
  store double %fp_isComplete, double* %idx_isComplete, align 8
  ret void

if.end.restoreBB.id1:                             ; preds = %cholesky_kernel.restoreControllerBB
  %idx_dataA1 = getelementptr inbounds double, double* %ckpt_mem, i32 3
  %90 = bitcast [650 x [650 x double]]* %dataA to i8*
  %91 = bitcast double* %idx_dataA1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %90, i8* align 8 %91, i64 3380000, i1 true)
  %idx_diagSize.addr2 = getelementptr inbounds double, double* %ckpt_mem, i32 422503
  %alloca_diagSize.addr = alloca i32, align 4
  %load_derefed_diagSize.addr = load double, double* %idx_diagSize.addr2, align 8
  %i32_load_derefed_diagSize.addr = fptosi double %load_derefed_diagSize.addr to i32
  store i32 %i32_load_derefed_diagSize.addr, i32* %alloca_diagSize.addr, align 4
  %idx_i1033 = getelementptr inbounds double, double* %ckpt_mem, i32 422504
  %alloca_i103 = alloca i32, align 4
  %load_derefed_i103 = load double, double* %idx_i1033, align 8
  %i32_load_derefed_i103 = fptosi double %load_derefed_i103 to i32
  store i32 %i32_load_derefed_i103, i32* %alloca_i103, align 4
  %idx_i614 = getelementptr inbounds double, double* %ckpt_mem, i32 422505
  %alloca_i61 = alloca i32, align 4
  %load_derefed_i61 = load double, double* %idx_i614, align 8
  %i32_load_derefed_i61 = fptosi double %load_derefed_i61 to i32
  store i32 %i32_load_derefed_i61, i32* %alloca_i61, align 4
  %idx_j1075 = getelementptr inbounds double, double* %ckpt_mem, i32 422506
  %alloca_j107 = alloca i32, align 4
  %load_derefed_j107 = load double, double* %idx_j1075, align 8
  %i32_load_derefed_j107 = fptosi double %load_derefed_j107 to i32
  store i32 %i32_load_derefed_j107, i32* %alloca_j107, align 4
  %idx_j316 = getelementptr inbounds double, double* %ckpt_mem, i32 422507
  %alloca_j31 = alloca i32, align 4
  %load_derefed_j31 = load double, double* %idx_j316, align 8
  %i32_load_derefed_j31 = fptosi double %load_derefed_j31 to i32
  store i32 %i32_load_derefed_j31, i32* %alloca_j31, align 4
  %idx_k7 = getelementptr inbounds double, double* %ckpt_mem, i32 422508
  %alloca_k = alloca i32, align 4
  %load_derefed_k = load double, double* %idx_k7, align 8
  %i32_load_derefed_k = fptosi double %load_derefed_k to i32
  store i32 %i32_load_derefed_k, i32* %alloca_k, align 4
  %idx_k668 = getelementptr inbounds double, double* %ckpt_mem, i32 422509
  %alloca_k66 = alloca i32, align 4
  %load_derefed_k66 = load double, double* %idx_k668, align 8
  %i32_load_derefed_k66 = fptosi double %load_derefed_k66 to i32
  store i32 %i32_load_derefed_k66, i32* %alloca_k66, align 4
  %idx_matrixA.addr9 = getelementptr inbounds double, double* %ckpt_mem, i32 422510
  %loaded_matrixA.addr10 = load double*, double** %matrixA.addr, align 8
  %92 = bitcast double* %loaded_matrixA.addr10 to i8*
  %93 = bitcast double* %idx_matrixA.addr9 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %92, i8* align 8 %93, i64 338000, i1 true)
  store double* %loaded_matrixA.addr10, double** %matrixA.addr, align 8
  %idx_tmp11 = getelementptr inbounds double, double* %ckpt_mem, i32 464760
  %alloca_tmp = alloca double, align 8
  %load_derefed_tmp = load double, double* %idx_tmp11, align 8
  store double %load_derefed_tmp, double* %alloca_tmp, align 8
  %idx_tmp212 = getelementptr inbounds double, double* %ckpt_mem, i32 464761
  %alloca_tmp2 = alloca double, align 8
  %load_derefed_tmp2 = load double, double* %idx_tmp212, align 8
  store double %load_derefed_tmp2, double* %alloca_tmp2, align 8
  %idx_heartbeat25 = getelementptr inbounds double, double* %ckpt_mem, i32 0
  %load_heartbeat26 = load double, double* %idx_heartbeat25, align 8
  %i32_heartbeat27 = fptosi double %load_heartbeat26 to i32
  %heartbeat_incr28 = add i32 %i32_heartbeat27, 1
  %fp_heartbeat_incr29 = sitofp i32 %heartbeat_incr28 to double
  store double %fp_heartbeat_incr29, double* %idx_heartbeat25, align 8
  br label %if.end.junctionBB.id1
}

declare i32 @printf(i8* noundef, ...) #2

; Function Attrs: nounwind
declare double @sqrt(double noundef) #3

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fmuladd.f64(double, double, double) #4

; Function Attrs: mustprogress noinline uwtable
define dso_local i32 @workload(i32 noundef %diagSize, double* noundef %matrixA, double* noundef %ckpt_mem, i32 noundef %initial) #1 {
entry:
  %diagSize.addr = alloca i32, align 4
  %matrixA.addr = alloca double*, align 8
  %ckpt_mem.addr = alloca double*, align 8
  %initial.addr = alloca i32, align 4
  %ckpt_id = alloca i32, align 4
  store i32 %diagSize, i32* %diagSize.addr, align 4
  store double* %matrixA, double** %matrixA.addr, align 8
  store double* %ckpt_mem, double** %ckpt_mem.addr, align 8
  store i32 %initial, i32* %initial.addr, align 4
  %call = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([31 x i8], [31 x i8]* @.str.4, i64 0, i64 0))
  %0 = load double*, double** %ckpt_mem.addr, align 8
  %arrayidx = getelementptr inbounds double, double* %0, i64 1
  %1 = load double, double* %arrayidx, align 8
  %conv = fptosi double %1 to i32
  store i32 %conv, i32* %ckpt_id, align 4
  %2 = load i32, i32* %diagSize.addr, align 4
  %3 = load double*, double** %matrixA.addr, align 8
  %4 = load double*, double** %ckpt_mem.addr, align 8
  call void @cholesky_kernel(i32 noundef %2, double* noundef %3, double* noundef %4)
  %5 = load i32, i32* %initial.addr, align 4
  %cmp = icmp eq i32 %5, 1
  %6 = zext i1 %cmp to i64
  %cond = select i1 %cmp, i32 0, i32 1
  %conv1 = sitofp i32 %cond to double
  %7 = load double*, double** %ckpt_mem.addr, align 8
  %arrayidx2 = getelementptr inbounds double, double* %7, i64 2
  store double %conv1, double* %arrayidx2, align 8
  %8 = load double*, double** %ckpt_mem.addr, align 8
  %arrayidx3 = getelementptr inbounds double, double* %8, i64 2
  %9 = load double, double* %arrayidx3, align 8
  %call4 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([27 x i8], [27 x i8]* @.str.5, i64 0, i64 0), double noundef %9)
  %10 = load double*, double** %ckpt_mem.addr, align 8
  %arrayidx5 = getelementptr inbounds double, double* %10, i64 2
  %11 = load double, double* %arrayidx5, align 8
  %conv6 = fptosi double %11 to i32
  ret i32 %conv6
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #5

attributes #0 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #5 = { argmemonly nofree nounwind willreturn }
attributes #6 = { nounwind }

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
!14 = distinct !{!14, !7}
!15 = distinct !{!15, !7}
