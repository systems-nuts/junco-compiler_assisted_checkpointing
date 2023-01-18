; ModuleID = 'blur.cpp'
source_filename = "blur.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@_ZL9heartbeat = internal unnamed_addr global i32 0, align 4
@_ZL6filter = internal unnamed_addr constant [100 x float] [float 0x3F84B6DBC0000000, float 0x3F84B5C1E0000000, float 0x3F84B29CA0000000, float 0x3F84AD5100000000, float 0x3F84A5DF20000000, float 0x3F849C61C0000000, float 0x3F8490CBA0000000, float 0x3F84831C80000000, float 0x3F847364A0000000, float 0x3F8461A000000000, float 0x3F84B5C1E0000000, float 0x3F84B4B580000000, float 0x3F84B19040000000, float 0x3F84AC44A0000000, float 0x3F84A4D2C0000000, float 0x3F849B5560000000, float 0x3F848FBF20000000, float 0x3F84821020000000, float 0x3F84725840000000, float 0x3F846094E0000000, float 0x3F84B29CA0000000, float 0x3F84B19040000000, float 0x3F84AE5D80000000, float 0x3F84A911E0000000, float 0x3F84A1AD60000000, float 0x3F84983000000000, float 0x3F848C99E0000000, float 0x3F847EEAC0000000, float 0x3F846F35A0000000, float 0x3F845D73A0000000, float 0x3F84AD5100000000, float 0x3F84AC44A0000000, float 0x3F84A911E0000000, float 0x3F84A3C640000000, float 0x3F849C61C0000000, float 0x3F8492E480000000, float 0x3F84874E40000000, float 0x3F8479ADE0000000, float 0x3F8469FA20000000, float 0x3F84583D80000000, float 0x3F84A5DF20000000, float 0x3F84A4D2C0000000, float 0x3F84A1AD60000000, float 0x3F849C61C0000000, float 0x3F8494FD60000000, float 0x3F848B8D60000000, float 0x3F847FF740000000, float 0x3F84725840000000, float 0x3F8462AB20000000, float 0x3F8450F3E0000000, float 0x3F849C61C0000000, float 0x3F849B5560000000, float 0x3F84983000000000, float 0x3F8492E480000000, float 0x3F848B8D60000000, float 0x3F84821020000000, float 0x3F847688A0000000, float 0x3F8468EF00000000, float 0x3F845948A0000000, float 0x3F84479980000000, float 0x3F8490CBA0000000, float 0x3F848FBF20000000, float 0x3F848C99E0000000, float 0x3F84874E40000000, float 0x3F847FF740000000, float 0x3F847688A0000000, float 0x3F846B0680000000, float 0x3F845D73A0000000, float 0x3F844DD540000000, float 0x3F843C30E0000000, float 0x3F84831C80000000, float 0x3F84821020000000, float 0x3F847EEAC0000000, float 0x3F8479ADE0000000, float 0x3F84725840000000, float 0x3F8468EF00000000, float 0x3F845D73A0000000, float 0x3F844FEA20000000, float 0x3F84405680000000, float 0x3F842EBE20000000, float 0x3F847364A0000000, float 0x3F84725840000000, float 0x3F846F35A0000000, float 0x3F8469FA20000000, float 0x3F8462AB20000000, float 0x3F845948A0000000, float 0x3F844DD540000000, float 0x3F84405680000000, float 0x3F8430CF00000000, float 0x3F841F4420000000, float 0x3F8461A000000000, float 0x3F846094E0000000, float 0x3F845D73A0000000, float 0x3F84583D80000000, float 0x3F8450F3E0000000, float 0x3F84479980000000, float 0x3F843C30E0000000, float 0x3F842EBE20000000, float 0x3F841F4420000000, float 0x3F840DC7E0000000], align 16

; Function Attrs: mustprogress nofree nosync nounwind uwtable willreturn
define dso_local void @checkpoint(float* nocapture noundef writeonly %ckpt_mem, i32 noundef %d, i32 noundef %i, float* nocapture noundef readonly %ouputs, i32 noundef %size, i32 noundef %id, i8 noundef signext %inst) local_unnamed_addr #0 {
entry:
  ; increment heartbeat
  %0 = load i32, i32* @_ZL9heartbeat, align 4, !tbaa !5
  %inc = add i32 %0, 1
  store i32 %inc, i32* @_ZL9heartbeat, align 4, !tbaa !5

  ; store i32 heartbeat (before increment) in ckpt_mem[1]
  %conv = uitofp i32 %0 to float                                    ; convert i32 heartbeat to float
  %arrayidx = getelementptr inbounds float, float* %ckpt_mem, i64 1 ; get arr index (float) for ckpt arr
  store float %conv, float* %arrayidx, align 4, !tbaa !9            ; store float heartbeat into arr @ arr index

  ; store i32 id in ckpt_mem[2]
  %conv1 = sitofp i32 %id to float
  %arrayidx2 = getelementptr inbounds float, float* %ckpt_mem, i64 2
  store float %conv1, float* %arrayidx2, align 4, !tbaa !9

  ; store i32 d in ckpt_mem[3]
  %conv3 = sitofp i32 %d to float
  %arrayidx4 = getelementptr inbounds float, float* %ckpt_mem, i64 3
  store float %conv3, float* %arrayidx4, align 4, !tbaa !9

  ; store i32 i into ckpt_mem[4]
  %conv5 = sitofp i32 %i to float
  %arrayidx6 = getelementptr inbounds float, float* %ckpt_mem, i64 4
  store float %conv5, float* %arrayidx6, align 4, !tbaa !9

  ; memcpy float output into ckpt_mem[5]
  %arrayidx7 = getelementptr inbounds float, float* %ckpt_mem, i64 5  ; get arr index for ckpt arr
  %1 = bitcast float* %arrayidx7 to i8*                               ; cast arr index to i8 ptr (dest location)
  %2 = bitcast float* %ouputs to i8*                                  ; cast outputs to i8 ptr (src location)
  %conv8 = sext i32 %size to i64                                      ; sign-extend size (num of bytes to copy)
  %mul = shl nsw i64 %conv8, 2                                        ; sign-extended size multiply by float size (=4bytes)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 4 %1, i8* align 4 %2, i64 %mul, i1 false)  ; is non-volatile
  ret void
}

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: mustprogress nofree nosync nounwind uwtable
define dso_local void @blur(float* nocapture noundef %newImage, float* nocapture noundef %image, float* nocapture noundef %mem_ckpt) local_unnamed_addr #2 {
entry:
  store float 0.000000e+00, float* %mem_ckpt, align 4, !tbaa !9
  %arrayidx1 = getelementptr inbounds float, float* %mem_ckpt, i64 2
  %0 = load float, float* %arrayidx1, align 4, !tbaa !9
  %cmp = fcmp oeq float %0, 1.000000e+00
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %arrayidx2 = getelementptr inbounds float, float* %mem_ckpt, i64 3
  %1 = load float, float* %arrayidx2, align 4, !tbaa !9
  %arrayidx3 = getelementptr inbounds float, float* %mem_ckpt, i64 4
  %2 = load float, float* %arrayidx3, align 4, !tbaa !9
  %conv4 = fptosi float %2 to i32
  br label %for.body

for.body:                                         ; preds = %if.then, %for.body
  %indvars.iv = phi i64 [ 0, %if.then ], [ %indvars.iv.next, %for.body ]
  %3 = add nuw nsw i64 %indvars.iv, 5
  %arrayidx8 = getelementptr inbounds float, float* %mem_ckpt, i64 %3
  %4 = load float, float* %arrayidx8, align 4, !tbaa !9
  %arrayidx10 = getelementptr inbounds float, float* %newImage, i64 %indvars.iv
  store float %4, float* %arrayidx10, align 4, !tbaa !9
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, 10890000
  br i1 %exitcond.not, label %if.end.loopexit, label %for.body, !llvm.loop !11

if.end.loopexit:                                  ; preds = %for.body
  %conv = fptosi float %1 to i32
  %add = add nsw i32 %conv4, 1
  br label %if.end

if.end:                                           ; preds = %if.end.loopexit, %entry
  %init_i.0 = phi i32 [ 0, %entry ], [ %add, %if.end.loopexit ]
  %init_d.0 = phi i32 [ 0, %entry ], [ %conv, %if.end.loopexit ]
  %cmp12185 = icmp slt i32 %init_d.0, 10
  br i1 %cmp12185, label %for.cond14.preheader.lr.ph, label %for.end100

for.cond14.preheader.lr.ph:                       ; preds = %if.end
  %cmp15182 = icmp slt i32 %init_i.0, 1641
  %5 = sext i32 %init_i.0 to i64
  br label %for.cond14.preheader

for.cond14.preheader:                             ; preds = %for.cond14.preheader.lr.ph, %for.inc98
  %d.0186 = phi i32 [ %init_d.0, %for.cond14.preheader.lr.ph ], [ %inc99, %for.inc98 ]
  br i1 %cmp15182, label %for.cond17.preheader, label %for.cond88.preheader

for.cond88.preheader.loopexit:                    ; preds = %for.inc85
  %6 = trunc i64 %indvars.iv.next219 to i32
  br label %for.cond88.preheader

for.cond88.preheader:                             ; preds = %for.cond88.preheader.loopexit, %for.cond14.preheader
  %i.1.lcssa = phi i32 [ %init_i.0, %for.cond14.preheader ], [ %6, %for.cond88.preheader.loopexit ]
  br label %for.body90

for.cond17.preheader:                             ; preds = %for.cond14.preheader, %for.inc85
  %indvars.iv218 = phi i64 [ %indvars.iv.next219, %for.inc85 ], [ %5, %for.cond14.preheader ]
  %7 = mul nsw i64 %indvars.iv218, 2200
  br label %for.cond20.preheader

for.cond20.preheader:                             ; preds = %for.cond17.preheader, %for.end66
  %indvars.iv211 = phi i64 [ 0, %for.cond17.preheader ], [ %indvars.iv.next212, %for.end66 ]
  br label %for.cond23.preheader

for.cond23.preheader:                             ; preds = %for.cond20.preheader, %for.inc64
  %indvars.iv204 = phi i64 [ 0, %for.cond20.preheader ], [ %indvars.iv.next205, %for.inc64 ]
  %l_sum2.3180 = phi float [ 0.000000e+00, %for.cond20.preheader ], [ %22, %for.inc64 ]
  %l_sum1.3179 = phi float [ 0.000000e+00, %for.cond20.preheader ], [ %19, %for.inc64 ]
  %l_sum0.3178 = phi float [ 0.000000e+00, %for.cond20.preheader ], [ %16, %for.inc64 ]
  %8 = mul nuw nsw i64 %indvars.iv204, 10
  %9 = add nsw i64 %indvars.iv204, %indvars.iv218
  %10 = mul nsw i64 %9, 2200
  br label %for.body25

for.body25:                                       ; preds = %for.cond23.preheader, %for.body25
  %indvars.iv195 = phi i64 [ 0, %for.cond23.preheader ], [ %indvars.iv.next196, %for.body25 ]
  %l_sum2.4176 = phi float [ %l_sum2.3180, %for.cond23.preheader ], [ %22, %for.body25 ]
  %l_sum1.4175 = phi float [ %l_sum1.3179, %for.cond23.preheader ], [ %19, %for.body25 ]
  %l_sum0.4174 = phi float [ %l_sum0.3178, %for.cond23.preheader ], [ %16, %for.body25 ]
  %11 = add nuw nsw i64 %indvars.iv195, %8
  %arrayidx28 = getelementptr inbounds [100 x float], [100 x float]* @_ZL6filter, i64 0, i64 %11
  %12 = load float, float* %arrayidx28, align 4, !tbaa !9
  %13 = add nuw nsw i64 %indvars.iv195, %indvars.iv211
  %14 = add nsw i64 %13, %10
  %arrayidx35 = getelementptr inbounds float, float* %image, i64 %14
  %15 = load float, float* %arrayidx35, align 4, !tbaa !9
  %16 = call float @llvm.fmuladd.f32(float %12, float %15, float %l_sum0.4174)
  %17 = add nsw i64 %13, %10
  %add45 = shl i64 %17, 32
  %sext = add i64 %add45, 15590731284480000
  %idxprom46 = ashr exact i64 %sext, 32
  %arrayidx47 = getelementptr inbounds float, float* %image, i64 %idxprom46
  %18 = load float, float* %arrayidx47, align 4, !tbaa !9
  %19 = call float @llvm.fmuladd.f32(float %12, float %18, float %l_sum1.4175)
  %20 = add nsw i64 %13, %10
  %add57 = shl i64 %20, 32
  %sext230 = add i64 %add57, 31181462568960000
  %idxprom58 = ashr exact i64 %sext230, 32
  %arrayidx59 = getelementptr inbounds float, float* %image, i64 %idxprom58
  %21 = load float, float* %arrayidx59, align 4, !tbaa !9
  %22 = call float @llvm.fmuladd.f32(float %12, float %21, float %l_sum2.4176)
  %indvars.iv.next196 = add nuw nsw i64 %indvars.iv195, 1
  %exitcond203.not = icmp eq i64 %indvars.iv.next196, 10
  br i1 %exitcond203.not, label %for.inc64, label %for.body25, !llvm.loop !14

for.inc64:                                        ; preds = %for.body25
  %indvars.iv.next205 = add nuw nsw i64 %indvars.iv204, 1
  %exitcond210.not = icmp eq i64 %indvars.iv.next205, 10
  br i1 %exitcond210.not, label %for.end66, label %for.cond23.preheader, !llvm.loop !15

for.end66:                                        ; preds = %for.inc64
  %23 = add nsw i64 %indvars.iv211, %7
  %arrayidx71 = getelementptr inbounds float, float* %newImage, i64 %23
  store float %16, float* %arrayidx71, align 4, !tbaa !9
  %24 = add nsw i64 %indvars.iv211, %7
  %add74 = shl i64 %24, 32
  %sext231 = add i64 %add74, 15590731284480000
  %idxprom75 = ashr exact i64 %sext231, 32
  %arrayidx76 = getelementptr inbounds float, float* %newImage, i64 %idxprom75
  store float %19, float* %arrayidx76, align 4, !tbaa !9
  %25 = add nsw i64 %indvars.iv211, %7
  %add79 = shl i64 %25, 32
  %sext232 = add i64 %add79, 31181462568960000
  %idxprom80 = ashr exact i64 %sext232, 32
  %arrayidx81 = getelementptr inbounds float, float* %newImage, i64 %idxprom80
  store float %22, float* %arrayidx81, align 4, !tbaa !9
  %indvars.iv.next212 = add nuw nsw i64 %indvars.iv211, 1
  %exitcond217.not = icmp eq i64 %indvars.iv.next212, 2191
  br i1 %exitcond217.not, label %for.inc85, label %for.cond20.preheader, !llvm.loop !16

for.inc85:                                        ; preds = %for.end66
  %indvars.iv.next219 = add nsw i64 %indvars.iv218, 1
  %exitcond222.not = icmp eq i64 %indvars.iv.next219, 1641
  br i1 %exitcond222.not, label %for.cond88.preheader.loopexit, label %for.cond17.preheader, !llvm.loop !17

for.body90:                                       ; preds = %for.cond88.preheader, %for.body90
  %indvars.iv225 = phi i64 [ 0, %for.cond88.preheader ], [ %indvars.iv.next226, %for.body90 ]
  %arrayidx92 = getelementptr inbounds float, float* %newImage, i64 %indvars.iv225
  %26 = load float, float* %arrayidx92, align 4, !tbaa !9
  %arrayidx94 = getelementptr inbounds float, float* %image, i64 %indvars.iv225
  store float %26, float* %arrayidx94, align 4, !tbaa !9
  %indvars.iv.next226 = add nuw nsw i64 %indvars.iv225, 1
  %exitcond228.not = icmp eq i64 %indvars.iv.next226, 10890000
  br i1 %exitcond228.not, label %for.inc98, label %for.body90, !llvm.loop !18

for.inc98:                                        ; preds = %for.body90
  %inc99 = add nsw i32 %d.0186, 1
  %exitcond229.not = icmp eq i32 %inc99, 10
  br i1 %exitcond229.not, label %for.end100, label %for.cond14.preheader, !llvm.loop !19

for.end100:                                       ; preds = %for.inc98, %if.end
  %d.0.lcssa = phi i32 [ %init_d.0, %if.end ], [ 10, %for.inc98 ]
  %i.0.lcssa = phi i32 [ undef, %if.end ], [ %i.1.lcssa, %for.inc98 ]
  store float 1.000000e+00, float* %mem_ckpt, align 4, !tbaa !9
  %conv102 = sitofp i32 %d.0.lcssa to float
  %arrayidx103 = getelementptr inbounds float, float* %mem_ckpt, i64 3
  store float %conv102, float* %arrayidx103, align 4, !tbaa !9
  %conv104 = sitofp i32 %i.0.lcssa to float
  %arrayidx105 = getelementptr inbounds float, float* %mem_ckpt, i64 4
  store float %conv104, float* %arrayidx105, align 4, !tbaa !9
  ret void
}

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #3

attributes #0 = { mustprogress nofree nosync nounwind uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #2 = { mustprogress nofree nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nofree nosync nounwind readnone speculatable willreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.6-++20221020091828+f28c006a5895-1~exp1~20221020211906.116"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = !{!10, !10, i64 0}
!10 = !{!"float", !7, i64 0}
!11 = distinct !{!11, !12, !13}
!12 = !{!"llvm.loop.mustprogress"}
!13 = !{!"llvm.loop.unroll.disable"}
!14 = distinct !{!14, !12, !13}
!15 = distinct !{!15, !12, !13}
!16 = distinct !{!16, !12, !13}
!17 = distinct !{!17, !12, !13}
!18 = distinct !{!18, !12, !13}
!19 = distinct !{!19, !12, !13}
