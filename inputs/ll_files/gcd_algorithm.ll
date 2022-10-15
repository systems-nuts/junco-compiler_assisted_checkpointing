; ModuleID = 'gcd.c'
source_filename = "gcd.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree nosync nounwind readnone uwtable
define dso_local i32 @gcd(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  br label %3

3:                                                ; preds = %11, %9, %2
  %4 = phi i32 [ %0, %2 ], [ %4, %9 ], [ %12, %11 ]
  %5 = phi i32 [ %1, %2 ], [ %10, %9 ], [ %5, %11 ]
  %6 = icmp eq i32 %4, %5
  br i1 %6, label %13, label %7

7:                                                ; preds = %3
  %8 = icmp ult i32 %4, %5
  br i1 %8, label %9, label %11

9:                                                ; preds = %7
  %10 = sub i32 %5, %4
  br label %3

11:                                               ; preds = %7
  %12 = sub i32 %4, %5
  br label %3

13:                                               ; preds = %3
  ret i32 %4
}

attributes #0 = { nofree nosync nounwind readnone uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Ubuntu clang version 15.0.2-++20220930063113+77ff99c10bee-1~exp1~20220930063206.71"}
