; ModuleID = '../blur.cpp'
source_filename = "../blur.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@_ZL9heartbeat = internal global i32 0, align 4
@_ZL6filter = internal constant [100 x float] [float 0x3F84B6DBC0000000, float 0x3F84B5C1E0000000, float 0x3F84B29CA0000000, float 0x3F84AD5100000000, float 0x3F84A5DF20000000, float 0x3F849C61C0000000, float 0x3F8490CBA0000000, float 0x3F84831C80000000, float 0x3F847364A0000000, float 0x3F8461A000000000, float 0x3F84B5C1E0000000, float 0x3F84B4B580000000, float 0x3F84B19040000000, float 0x3F84AC44A0000000, float 0x3F84A4D2C0000000, float 0x3F849B5560000000, float 0x3F848FBF20000000, float 0x3F84821020000000, float 0x3F84725840000000, float 0x3F846094E0000000, float 0x3F84B29CA0000000, float 0x3F84B19040000000, float 0x3F84AE5D80000000, float 0x3F84A911E0000000, float 0x3F84A1AD60000000, float 0x3F84983000000000, float 0x3F848C99E0000000, float 0x3F847EEAC0000000, float 0x3F846F35A0000000, float 0x3F845D73A0000000, float 0x3F84AD5100000000, float 0x3F84AC44A0000000, float 0x3F84A911E0000000, float 0x3F84A3C640000000, float 0x3F849C61C0000000, float 0x3F8492E480000000, float 0x3F84874E40000000, float 0x3F8479ADE0000000, float 0x3F8469FA20000000, float 0x3F84583D80000000, float 0x3F84A5DF20000000, float 0x3F84A4D2C0000000, float 0x3F84A1AD60000000, float 0x3F849C61C0000000, float 0x3F8494FD60000000, float 0x3F848B8D60000000, float 0x3F847FF740000000, float 0x3F84725840000000, float 0x3F8462AB20000000, float 0x3F8450F3E0000000, float 0x3F849C61C0000000, float 0x3F849B5560000000, float 0x3F84983000000000, float 0x3F8492E480000000, float 0x3F848B8D60000000, float 0x3F84821020000000, float 0x3F847688A0000000, float 0x3F8468EF00000000, float 0x3F845948A0000000, float 0x3F84479980000000, float 0x3F8490CBA0000000, float 0x3F848FBF20000000, float 0x3F848C99E0000000, float 0x3F84874E40000000, float 0x3F847FF740000000, float 0x3F847688A0000000, float 0x3F846B0680000000, float 0x3F845D73A0000000, float 0x3F844DD540000000, float 0x3F843C30E0000000, float 0x3F84831C80000000, float 0x3F84821020000000, float 0x3F847EEAC0000000, float 0x3F8479ADE0000000, float 0x3F84725840000000, float 0x3F8468EF00000000, float 0x3F845D73A0000000, float 0x3F844FEA20000000, float 0x3F84405680000000, float 0x3F842EBE20000000, float 0x3F847364A0000000, float 0x3F84725840000000, float 0x3F846F35A0000000, float 0x3F8469FA20000000, float 0x3F8462AB20000000, float 0x3F845948A0000000, float 0x3F844DD540000000, float 0x3F84405680000000, float 0x3F8430CF00000000, float 0x3F841F4420000000, float 0x3F8461A000000000, float 0x3F846094E0000000, float 0x3F845D73A0000000, float 0x3F84583D80000000, float 0x3F8450F3E0000000, float 0x3F84479980000000, float 0x3F843C30E0000000, float 0x3F842EBE20000000, float 0x3F841F4420000000, float 0x3F840DC7E0000000], align 16

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @checkpoint(float* noundef %ckpt_mem, i32 noundef %d, i32 noundef %i, float* noundef %ouputs, i32 noundef %size, i32 noundef %id, i8 noundef signext %inst) #0 {
entry:
  %ckpt_mem.addr = alloca float*, align 8
  %d.addr = alloca i32, align 4
  %i.addr = alloca i32, align 4
  %ouputs.addr = alloca float*, align 8
  %size.addr = alloca i32, align 4
  %id.addr = alloca i32, align 4
  %inst.addr = alloca i8, align 1
  store float* %ckpt_mem, float** %ckpt_mem.addr, align 8
  store i32 %d, i32* %d.addr, align 4
  store i32 %i, i32* %i.addr, align 4
  store float* %ouputs, float** %ouputs.addr, align 8
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
  %4 = load i32, i32* %d.addr, align 4
  %conv3 = sitofp i32 %4 to float
  %5 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx4 = getelementptr inbounds float, float* %5, i64 3
  store float %conv3, float* %arrayidx4, align 4
  %6 = load i32, i32* %i.addr, align 4
  %conv5 = sitofp i32 %6 to float
  %7 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx6 = getelementptr inbounds float, float* %7, i64 4
  store float %conv5, float* %arrayidx6, align 4
  %8 = load float*, float** %ckpt_mem.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %8, i64 5
  %9 = bitcast float* %arrayidx7 to i8*
  %10 = load float*, float** %ouputs.addr, align 8
  %11 = bitcast float* %10 to i8*
  %12 = load i32, i32* %size.addr, align 4
  %conv8 = sext i32 %12 to i64
  %mul = mul i64 %conv8, 4
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %9, i8* align 4 %11, i64 %mul, i1 false)
  ret void
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @blur(float* noundef %newImage, float* noundef %image, float* noundef %mem_ckpt) #0 {
entry:
  %newImage.addr = alloca float*, align 8
  %image.addr = alloca float*, align 8
  %mem_ckpt.addr = alloca float*, align 8
  %d = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %h = alloca i32, align 4
  %w = alloca i32, align 4
  %ind = alloca i32, align 4
  %init_i = alloca i32, align 4
  %init_d = alloca i32, align 4
  %l_sum0 = alloca float, align 4
  %l_sum1 = alloca float, align 4
  %l_sum2 = alloca float, align 4
  %ind5 = alloca i32, align 4
  store float* %newImage, float** %newImage.addr, align 8
  store float* %image, float** %image.addr, align 8
  store float* %mem_ckpt, float** %mem_ckpt.addr, align 8
  store i32 0, i32* %init_i, align 4
  store i32 0, i32* %init_d, align 4
  store float 0.000000e+00, float* %l_sum0, align 4
  store float 0.000000e+00, float* %l_sum1, align 4
  store float 0.000000e+00, float* %l_sum2, align 4
  %0 = load float*, float** %mem_ckpt.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %0, i64 0
  store float 0.000000e+00, float* %arrayidx, align 4
  %1 = load float*, float** %mem_ckpt.addr, align 8
  %arrayidx1 = getelementptr inbounds float, float* %1, i64 2
  %2 = load float, float* %arrayidx1, align 4
  %cmp = fcmp oeq float %2, 1.000000e+00
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %3 = load float*, float** %mem_ckpt.addr, align 8
  %arrayidx2 = getelementptr inbounds float, float* %3, i64 3
  %4 = load float, float* %arrayidx2, align 4
  %conv = fptosi float %4 to i32
  store i32 %conv, i32* %init_d, align 4
  %5 = load float*, float** %mem_ckpt.addr, align 8
  %arrayidx3 = getelementptr inbounds float, float* %5, i64 4
  %6 = load float, float* %arrayidx3, align 4
  %conv4 = fptosi float %6 to i32
  %add = add nsw i32 %conv4, 1
  store i32 %add, i32* %init_i, align 4
  store i32 0, i32* %ind5, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.then
  %7 = load i32, i32* %ind5, align 4
  %cmp6 = icmp slt i32 %7, 10890000
  br i1 %cmp6, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %8 = load float*, float** %mem_ckpt.addr, align 8
  %9 = load i32, i32* %ind5, align 4
  %add7 = add nsw i32 5, %9
  %idxprom = sext i32 %add7 to i64
  %arrayidx8 = getelementptr inbounds float, float* %8, i64 %idxprom
  %10 = load float, float* %arrayidx8, align 4
  %11 = load float*, float** %newImage.addr, align 8
  %12 = load i32, i32* %ind5, align 4
  %idxprom9 = sext i32 %12 to i64
  %arrayidx10 = getelementptr inbounds float, float* %11, i64 %idxprom9
  store float %10, float* %arrayidx10, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %13 = load i32, i32* %ind5, align 4
  %inc = add nsw i32 %13, 1
  store i32 %inc, i32* %ind5, align 4
  br label %for.cond, !llvm.loop !6

for.end:                                          ; preds = %for.cond
  br label %if.end

if.end:                                           ; preds = %for.end, %entry
  %14 = load i32, i32* %init_d, align 4
  store i32 %14, i32* %d, align 4
  br label %for.cond11

for.cond11:                                       ; preds = %for.inc98, %if.end
  %15 = load i32, i32* %d, align 4
  %cmp12 = icmp slt i32 %15, 10
  br i1 %cmp12, label %for.body13, label %for.end100

for.body13:                                       ; preds = %for.cond11
  %16 = load i32, i32* %init_i, align 4
  store i32 %16, i32* %i, align 4
  br label %for.cond14

for.cond14:                                       ; preds = %for.inc85, %for.body13
  %17 = load i32, i32* %i, align 4
  %cmp15 = icmp slt i32 %17, 1641
  br i1 %cmp15, label %for.body16, label %for.end87

for.body16:                                       ; preds = %for.cond14
  store i32 0, i32* %j, align 4
  br label %for.cond17

for.cond17:                                       ; preds = %for.inc82, %for.body16
  %18 = load i32, i32* %j, align 4
  %cmp18 = icmp slt i32 %18, 2191
  br i1 %cmp18, label %for.body19, label %for.end84

for.body19:                                       ; preds = %for.cond17
  store i32 0, i32* %h, align 4
  br label %for.cond20

for.cond20:                                       ; preds = %for.inc64, %for.body19
  %19 = load i32, i32* %h, align 4
  %cmp21 = icmp slt i32 %19, 10
  br i1 %cmp21, label %for.body22, label %for.end66

for.body22:                                       ; preds = %for.cond20
  store i32 0, i32* %w, align 4
  br label %for.cond23

for.cond23:                                       ; preds = %for.inc61, %for.body22
  %20 = load i32, i32* %w, align 4
  %cmp24 = icmp slt i32 %20, 10
  br i1 %cmp24, label %for.body25, label %for.end63

for.body25:                                       ; preds = %for.cond23
  %21 = load i32, i32* %h, align 4
  %mul = mul nsw i32 %21, 10
  %22 = load i32, i32* %w, align 4
  %add26 = add nsw i32 %mul, %22
  %idxprom27 = sext i32 %add26 to i64
  %arrayidx28 = getelementptr inbounds [100 x float], [100 x float]* @_ZL6filter, i64 0, i64 %idxprom27
  %23 = load float, float* %arrayidx28, align 4
  %24 = load float*, float** %image.addr, align 8
  %25 = load i32, i32* %h, align 4
  %26 = load i32, i32* %i, align 4
  %add29 = add nsw i32 %25, %26
  %mul30 = mul nsw i32 %add29, 2200
  %add31 = add nsw i32 0, %mul30
  %27 = load i32, i32* %w, align 4
  %28 = load i32, i32* %j, align 4
  %add32 = add nsw i32 %27, %28
  %add33 = add nsw i32 %add31, %add32
  %idxprom34 = sext i32 %add33 to i64
  %arrayidx35 = getelementptr inbounds float, float* %24, i64 %idxprom34
  %29 = load float, float* %arrayidx35, align 4
  %30 = load float, float* %l_sum0, align 4
  %31 = call float @llvm.fmuladd.f32(float %23, float %29, float %30)
  store float %31, float* %l_sum0, align 4
  %32 = load i32, i32* %h, align 4
  %mul37 = mul nsw i32 %32, 10
  %33 = load i32, i32* %w, align 4
  %add38 = add nsw i32 %mul37, %33
  %idxprom39 = sext i32 %add38 to i64
  %arrayidx40 = getelementptr inbounds [100 x float], [100 x float]* @_ZL6filter, i64 0, i64 %idxprom39
  %34 = load float, float* %arrayidx40, align 4
  %35 = load float*, float** %image.addr, align 8
  %36 = load i32, i32* %h, align 4
  %37 = load i32, i32* %i, align 4
  %add41 = add nsw i32 %36, %37
  %mul42 = mul nsw i32 %add41, 2200
  %add43 = add nsw i32 3630000, %mul42
  %38 = load i32, i32* %w, align 4
  %39 = load i32, i32* %j, align 4
  %add44 = add nsw i32 %38, %39
  %add45 = add nsw i32 %add43, %add44
  %idxprom46 = sext i32 %add45 to i64
  %arrayidx47 = getelementptr inbounds float, float* %35, i64 %idxprom46
  %40 = load float, float* %arrayidx47, align 4
  %41 = load float, float* %l_sum1, align 4
  %42 = call float @llvm.fmuladd.f32(float %34, float %40, float %41)
  store float %42, float* %l_sum1, align 4
  %43 = load i32, i32* %h, align 4
  %mul49 = mul nsw i32 %43, 10
  %44 = load i32, i32* %w, align 4
  %add50 = add nsw i32 %mul49, %44
  %idxprom51 = sext i32 %add50 to i64
  %arrayidx52 = getelementptr inbounds [100 x float], [100 x float]* @_ZL6filter, i64 0, i64 %idxprom51
  %45 = load float, float* %arrayidx52, align 4
  %46 = load float*, float** %image.addr, align 8
  %47 = load i32, i32* %h, align 4
  %48 = load i32, i32* %i, align 4
  %add53 = add nsw i32 %47, %48
  %mul54 = mul nsw i32 %add53, 2200
  %add55 = add nsw i32 7260000, %mul54
  %49 = load i32, i32* %w, align 4
  %50 = load i32, i32* %j, align 4
  %add56 = add nsw i32 %49, %50
  %add57 = add nsw i32 %add55, %add56
  %idxprom58 = sext i32 %add57 to i64
  %arrayidx59 = getelementptr inbounds float, float* %46, i64 %idxprom58
  %51 = load float, float* %arrayidx59, align 4
  %52 = load float, float* %l_sum2, align 4
  %53 = call float @llvm.fmuladd.f32(float %45, float %51, float %52)
  store float %53, float* %l_sum2, align 4
  br label %for.inc61

for.inc61:                                        ; preds = %for.body25
  %54 = load i32, i32* %w, align 4
  %inc62 = add nsw i32 %54, 1
  store i32 %inc62, i32* %w, align 4
  br label %for.cond23, !llvm.loop !8

for.end63:                                        ; preds = %for.cond23
  br label %for.inc64

for.inc64:                                        ; preds = %for.end63
  %55 = load i32, i32* %h, align 4
  %inc65 = add nsw i32 %55, 1
  store i32 %inc65, i32* %h, align 4
  br label %for.cond20, !llvm.loop !9

for.end66:                                        ; preds = %for.cond20
  %56 = load float, float* %l_sum0, align 4
  %57 = load float*, float** %newImage.addr, align 8
  %58 = load i32, i32* %i, align 4
  %mul67 = mul nsw i32 %58, 2200
  %add68 = add nsw i32 0, %mul67
  %59 = load i32, i32* %j, align 4
  %add69 = add nsw i32 %add68, %59
  %idxprom70 = sext i32 %add69 to i64
  %arrayidx71 = getelementptr inbounds float, float* %57, i64 %idxprom70
  store float %56, float* %arrayidx71, align 4
  %60 = load float, float* %l_sum1, align 4
  %61 = load float*, float** %newImage.addr, align 8
  %62 = load i32, i32* %i, align 4
  %mul72 = mul nsw i32 %62, 2200
  %add73 = add nsw i32 3630000, %mul72
  %63 = load i32, i32* %j, align 4
  %add74 = add nsw i32 %add73, %63
  %idxprom75 = sext i32 %add74 to i64
  %arrayidx76 = getelementptr inbounds float, float* %61, i64 %idxprom75
  store float %60, float* %arrayidx76, align 4
  %64 = load float, float* %l_sum2, align 4
  %65 = load float*, float** %newImage.addr, align 8
  %66 = load i32, i32* %i, align 4
  %mul77 = mul nsw i32 %66, 2200
  %add78 = add nsw i32 7260000, %mul77
  %67 = load i32, i32* %j, align 4
  %add79 = add nsw i32 %add78, %67
  %idxprom80 = sext i32 %add79 to i64
  %arrayidx81 = getelementptr inbounds float, float* %65, i64 %idxprom80
  store float %64, float* %arrayidx81, align 4
  store float 0.000000e+00, float* %l_sum0, align 4
  store float 0.000000e+00, float* %l_sum1, align 4
  store float 0.000000e+00, float* %l_sum2, align 4
  br label %for.inc82

for.inc82:                                        ; preds = %for.end66
  %68 = load i32, i32* %j, align 4
  %inc83 = add nsw i32 %68, 1
  store i32 %inc83, i32* %j, align 4
  br label %for.cond17, !llvm.loop !10

for.end84:                                        ; preds = %for.cond17
  br label %for.inc85

for.inc85:                                        ; preds = %for.end84
  %69 = load i32, i32* %i, align 4
  %inc86 = add nsw i32 %69, 1
  store i32 %inc86, i32* %i, align 4
  br label %for.cond14, !llvm.loop !11

for.end87:                                        ; preds = %for.cond14
  store i32 0, i32* %ind, align 4
  br label %for.cond88

for.cond88:                                       ; preds = %for.inc95, %for.end87
  %70 = load i32, i32* %ind, align 4
  %cmp89 = icmp slt i32 %70, 10890000
  br i1 %cmp89, label %for.body90, label %for.end97

for.body90:                                       ; preds = %for.cond88
  %71 = load float*, float** %newImage.addr, align 8
  %72 = load i32, i32* %ind, align 4
  %idxprom91 = sext i32 %72 to i64
  %arrayidx92 = getelementptr inbounds float, float* %71, i64 %idxprom91
  %73 = load float, float* %arrayidx92, align 4
  %74 = load float*, float** %image.addr, align 8
  %75 = load i32, i32* %ind, align 4
  %idxprom93 = sext i32 %75 to i64
  %arrayidx94 = getelementptr inbounds float, float* %74, i64 %idxprom93
  store float %73, float* %arrayidx94, align 4
  br label %for.inc95

for.inc95:                                        ; preds = %for.body90
  %76 = load i32, i32* %ind, align 4
  %inc96 = add nsw i32 %76, 1
  store i32 %inc96, i32* %ind, align 4
  br label %for.cond88, !llvm.loop !12

for.end97:                                        ; preds = %for.cond88
  br label %for.inc98

for.inc98:                                        ; preds = %for.end97
  %77 = load i32, i32* %d, align 4
  %inc99 = add nsw i32 %77, 1
  store i32 %inc99, i32* %d, align 4
  br label %for.cond11, !llvm.loop !13

for.end100:                                       ; preds = %for.cond11
  %78 = load float*, float** %mem_ckpt.addr, align 8
  %arrayidx101 = getelementptr inbounds float, float* %78, i64 0
  store float 1.000000e+00, float* %arrayidx101, align 4
  %79 = load i32, i32* %d, align 4
  %conv102 = sitofp i32 %79 to float
  %80 = load float*, float** %mem_ckpt.addr, align 8
  %arrayidx103 = getelementptr inbounds float, float* %80, i64 3
  store float %conv102, float* %arrayidx103, align 4
  %81 = load i32, i32* %i, align 4
  %conv104 = sitofp i32 %81 to float
  %82 = load float*, float** %mem_ckpt.addr, align 8
  %arrayidx105 = getelementptr inbounds float, float* %82, i64 4
  store float %conv104, float* %arrayidx105, align 4
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #2

attributes #0 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly nofree nounwind willreturn }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }

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
