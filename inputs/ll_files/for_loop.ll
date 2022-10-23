; ModuleID = 'for_loop.c'
source_filename = "for_loop.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@z = dso_local local_unnamed_addr global i32 3, align 4
@y = dso_local local_unnamed_addr global i32 0, align 4

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @func(i32 %0) local_unnamed_addr #0 {
  %2 = load i32, i32* @z, align 4, !tbaa !5
  br label %4

3:                                                ; preds = %8
  ret void

4:                                                ; preds = %1, %8
  %5 = phi i32 [ 0, %1 ], [ %9, %8 ]
  %6 = icmp eq i32 %5, %2
  br i1 %6, label %7, label %8

7:                                                ; preds = %4
  store i32 1, i32* @y, align 4, !tbaa !5
  br label %8

8:                                                ; preds = %4, %7
  %9 = add nuw nsw i32 %5, 1
  %10 = icmp eq i32 %9, 4
  br i1 %10, label %3, label %4, !llvm.loop !9
}

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #0 {
  %1 = load i32, i32* @z, align 4, !tbaa !5
  br label %2

2:                                                ; preds = %6, %0
  %3 = phi i32 [ 0, %0 ], [ %7, %6 ]
  %4 = icmp eq i32 %3, %1
  br i1 %4, label %5, label %6

5:                                                ; preds = %2
  store i32 1, i32* @y, align 4, !tbaa !5
  br label %6

6:                                                ; preds = %5, %2
  %7 = add nuw nsw i32 %3, 1
  %8 = icmp eq i32 %7, 4
  br i1 %8, label %9, label %2, !llvm.loop !9

9:                                                ; preds = %6
  ret i32 0
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
