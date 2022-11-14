; ModuleID = 'for_loop.c'
source_filename = "for_loop.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@z = dso_local local_unnamed_addr global i32 3, align 4
@y = dso_local local_unnamed_addr global i32 0, align 4

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @func(i32 noundef %num) local_unnamed_addr #0 {
entry:
  %cmp5 = icmp sgt i32 %num, 0
  br i1 %cmp5, label %for.body.lr.ph, label %for.cond.cleanup

for.body.lr.ph:                                   ; preds = %entry
  %0 = load i32, i32* @z, align 4, !tbaa !5
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.inc, %entry
  ret void

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %i.06 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.inc ]
  %cmp1 = icmp eq i32 %i.06, %0
  br i1 %cmp1, label %if.then, label %for.inc

if.then:                                          ; preds = %for.body
  store i32 1, i32* @y, align 4, !tbaa !5
  br label %for.inc

for.inc:                                          ; preds = %for.body, %if.then
  %inc = add nuw nsw i32 %i.06, 1
  %exitcond.not = icmp eq i32 %inc, %num
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !9
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @func2(i32 noundef %num) local_unnamed_addr #0 {
entry:
  %cmp8 = icmp sgt i32 %num, 0
  br i1 %cmp8, label %for.body.lr.ph, label %for.cond.cleanup

for.body.lr.ph:                                   ; preds = %entry
  %y.promoted = load i32, i32* @y, align 4, !tbaa !5
  %0 = load i32, i32* @z, align 4, !tbaa !5
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.inc, %entry
  ret void

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %i.010 = phi i32 [ 0, %for.body.lr.ph ], [ %inc2, %for.inc ]
  %inc79 = phi i32 [ %y.promoted, %for.body.lr.ph ], [ %inc6, %for.inc ]
  %cmp1.not = icmp eq i32 %i.010, %0
  br i1 %cmp1.not, label %for.inc, label %if.then

if.then:                                          ; preds = %for.body
  %inc = add nsw i32 %inc79, 1
  store i32 %inc, i32* @y, align 4, !tbaa !5
  br label %for.inc

for.inc:                                          ; preds = %for.body, %if.then
  %inc6 = phi i32 [ %inc79, %for.body ], [ %inc, %if.then ]
  %inc2 = add nuw nsw i32 %i.010, 1
  %exitcond.not = icmp eq i32 %inc2, %num
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !12
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
!12 = distinct !{!12, !10, !11}
