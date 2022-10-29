; ModuleID = 'for_loop_1.c'
source_filename = "for_loop_1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@z = dso_local local_unnamed_addr global i32 44, align 4
@arr = dso_local local_unnamed_addr global [10 x i32] zeroinitializer, align 16
@offset = dso_local local_unnamed_addr global i32 0, align 4

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @func() local_unnamed_addr #0 {
entry:
  %0 = load i32, i32* @offset, align 4, !tbaa !5
  %1 = load i32, i32* @z, align 4
  %2 = zext i32 %0 to i64
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret void

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %cmp1 = icmp eq i64 %indvars.iv, %2
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* @arr, i64 0, i64 %indvars.iv
  %3 = trunc i64 %indvars.iv to i32
  %.sink = select i1 %cmp1, i32 %1, i32 %3
  store i32 %.sink, i32* %arrayidx, align 4, !tbaa !5
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, 10
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !9
}

attributes #0 = { nofree norecurse nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

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
!8 = !{!"Simple C/C++ TBAA"}
!9 = distinct !{!9, !10, !11}
!10 = !{!"llvm.loop.mustprogress"}
!11 = !{!"llvm.loop.unroll.disable"}
