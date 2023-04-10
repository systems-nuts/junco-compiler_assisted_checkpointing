; ModuleID = 'foo.ll'
source_filename = "foo.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

$_ZSt3minIiERKT_S2_S2_ = comdat any

@__const._Z3fooPi.arr = private unnamed_addr constant [4 x i32] [i32 0, i32 1, i32 2, i32 3], align 16

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local void @_Z10checkpointv() #0 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline uwtable
define dso_local noundef i32 @_Z3fooPi(i32* noundef %ckpt_mem) #1 {
entry.upper:
  %ckpt_mem.addr = alloca i32*, align 8
  %k = alloca i32, align 4
  %arr = alloca [4 x i32], align 16
  %i = alloca i32, align 4
  store i32* %ckpt_mem, i32** %ckpt_mem.addr, align 8
  store i32 0, i32* %k, align 4
  %0 = bitcast [4 x i32]* %arr to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %0, i8* align 16 bitcast ([4 x i32]* @__const._Z3fooPi.arr to i8*), i64 16, i1 false)
  store i32 0, i32* %i, align 4
  br label %_Z3fooPi.restoreControllerBB

_Z3fooPi.restoreControllerBB:                     ; preds = %entry.upper
  %idx_ckpt_id_load = getelementptr inbounds i32, i32* %ckpt_mem, i32 1
  %load_ckpt_id = load i32, i32* %idx_ckpt_id_load, align 4
  switch i32 %load_ckpt_id, label %entry.lower [
    i32 1, label %for.body.restoreBB.id1
  ]

entry.lower:                                      ; preds = %_Z3fooPi.restoreControllerBB
  br label %for.cond.upper

for.cond.upper:                                   ; preds = %for.inc, %entry.lower
  %new_i.phi = phi i32* [ %new_i, %for.inc ], [ %i, %entry.lower ]
  %new_k.phi = phi i32* [ %new_k, %for.inc ], [ %k, %entry.lower ]
  %1 = load i32, i32* %new_i.phi, align 4
  br label %for.cond.lower

for.cond.lower:                                   ; preds = %for.cond.upper
  %cmp = icmp slt i32 %1, 3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond.lower
  %2 = load i32, i32* %new_i.phi, align 4
  %mul = mul nsw i32 %2, 2
  %add = add nsw i32 1, %mul
  %3 = load i32, i32* %new_i.phi, align 4
  %idxprom = sext i32 %3 to i64
  %arrayidx = getelementptr inbounds [4 x i32], [4 x i32]* %arr, i64 0, i64 %idxprom
  store i32 %add, i32* %arrayidx, align 4
  %4 = load i32, i32* %new_i.phi, align 4
  %idxprom1 = sext i32 %4 to i64
  %arrayidx2 = getelementptr inbounds [4 x i32], [4 x i32]* %arr, i64 0, i64 %idxprom1
  %call = call noundef nonnull align 4 dereferenceable(4) i32* @_ZSt3minIiERKT_S2_S2_(i32* noundef nonnull align 4 dereferenceable(4) %new_k.phi, i32* noundef nonnull align 4 dereferenceable(4) %arrayidx2)
  %5 = load i32, i32* %call, align 4
  store i32 %5, i32* %new_k.phi, align 4
  br label %for.body.saveBB.id1

for.body.saveBB.id1:                              ; preds = %for.body
  %idx_arr = getelementptr inbounds i32, i32* %ckpt_mem, i32 3
  %6 = bitcast i32* %idx_arr to i8*
  %7 = bitcast [4 x i32]* %arr to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %6, i8* align 8 %7, i64 16, i1 true)
  %idx_i = getelementptr inbounds i32, i32* %ckpt_mem, i32 7
  %deref_i = load i32, i32* %new_i.phi, align 4
  store i32 %deref_i, i32* %idx_i, align 4
  %idx_k = getelementptr inbounds i32, i32* %ckpt_mem, i32 8
  %deref_k = load i32, i32* %new_k.phi, align 4
  store i32 %deref_k, i32* %idx_k, align 4
  %idx_ckpt_id = getelementptr inbounds i32, i32* %ckpt_mem, i32 1
  store i32 1, i32* %idx_ckpt_id, align 4
  %idx_heartbeat = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  %load_heartbeat = load i32, i32* %idx_heartbeat, align 4
  %heartbeat_incr = add i32 %load_heartbeat, 1
  store i32 %heartbeat_incr, i32* %idx_heartbeat, align 4
  br label %for.body.junctionBB.id1

for.body.junctionBB.id1:                          ; preds = %for.body.restoreBB.id1, %for.body.saveBB.id1
  %new_i = phi i32* [ %alloca_i, %for.body.restoreBB.id1 ], [ %new_i.phi, %for.body.saveBB.id1 ]
  %new_k = phi i32* [ %alloca_k, %for.body.restoreBB.id1 ], [ %new_k.phi, %for.body.saveBB.id1 ]
  br label %for.inc

for.inc:                                          ; preds = %for.body.junctionBB.id1
  %8 = load i32, i32* %new_i, align 4
  %inc = add nsw i32 %8, 1
  store i32 %inc, i32* %new_i, align 4
  br label %for.cond.upper, !llvm.loop !6

for.end:                                          ; preds = %for.cond.lower
  %9 = load i32, i32* %new_k.phi, align 4
  %idx_isComplete = getelementptr inbounds i32, i32* %ckpt_mem, i32 2
  store i32 %9, i32* %idx_isComplete, align 4
  ret i32 %9

for.body.restoreBB.id1:                           ; preds = %_Z3fooPi.restoreControllerBB
  %idx_arr1 = getelementptr inbounds i32, i32* %ckpt_mem, i32 3
  %10 = bitcast [4 x i32]* %arr to i8*
  %11 = bitcast i32* %idx_arr1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %10, i8* align 8 %11, i64 16, i1 true)
  %idx_i2 = getelementptr inbounds i32, i32* %ckpt_mem, i32 7
  %alloca_i = alloca i32, align 4
  %load_derefed_i = load i32, i32* %idx_i2, align 4
  store i32 %load_derefed_i, i32* %alloca_i, align 4
  %idx_k3 = getelementptr inbounds i32, i32* %ckpt_mem, i32 8
  %alloca_k = alloca i32, align 4
  %load_derefed_k = load i32, i32* %idx_k3, align 4
  store i32 %load_derefed_k, i32* %alloca_k, align 4
  %idx_heartbeat4 = getelementptr inbounds i32, i32* %ckpt_mem, i32 0
  %load_heartbeat5 = load i32, i32* %idx_heartbeat4, align 4
  %heartbeat_incr6 = add i32 %load_heartbeat5, 1
  store i32 %heartbeat_incr6, i32* %idx_heartbeat4, align 4
  br label %for.body.junctionBB.id1
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef nonnull align 4 dereferenceable(4) i32* @_ZSt3minIiERKT_S2_S2_(i32* noundef nonnull align 4 dereferenceable(4) %__a, i32* noundef nonnull align 4 dereferenceable(4) %__b) #0 comdat {
entry:
  %retval = alloca i32*, align 8
  %__a.addr = alloca i32*, align 8
  %__b.addr = alloca i32*, align 8
  store i32* %__a, i32** %__a.addr, align 8
  store i32* %__b, i32** %__b.addr, align 8
  %0 = load i32*, i32** %__b.addr, align 8
  %1 = load i32, i32* %0, align 4
  %2 = load i32*, i32** %__a.addr, align 8
  %3 = load i32, i32* %2, align 4
  %cmp = icmp slt i32 %1, %3
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = load i32*, i32** %__b.addr, align 8
  store i32* %4, i32** %retval, align 8
  br label %return

if.end:                                           ; preds = %entry
  %5 = load i32*, i32** %__a.addr, align 8
  store i32* %5, i32** %retval, align 8
  br label %return

return:                                           ; preds = %if.end, %if.then
  %6 = load i32*, i32** %retval, align 8
  ret i32* %6
}

; Function Attrs: mustprogress noinline norecurse uwtable
define dso_local noundef i32 @main() #3 {
entry:
  %ckpt_mem = alloca [10 x i32], align 16
  %arraydecay = getelementptr inbounds [10 x i32], [10 x i32]* %ckpt_mem, i64 0, i64 0
  %call = call noundef i32 @_Z3fooPi(i32* noundef %arraydecay)
  ret i32 0
}

attributes #0 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { argmemonly nofree nounwind willreturn }
attributes #3 = { mustprogress noinline norecurse uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

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
