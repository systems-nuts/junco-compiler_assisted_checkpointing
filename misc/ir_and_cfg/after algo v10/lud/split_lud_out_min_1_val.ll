; ModuleID = '../../inputs/ll_files/split_lud.ll'
source_filename = "lud.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@_ZL9heartbeat = internal unnamed_addr global i32 0, align 4
@.str = private unnamed_addr constant [23 x i8] c"restore from index %d\0A\00", align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_lud.cpp, i8* null }]

declare void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"* noundef nonnull align 1 dereferenceable(1)) unnamed_addr #0

; Function Attrs: nounwind
declare void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init"* noundef nonnull align 1 dereferenceable(1)) unnamed_addr #1

; Function Attrs: nofree nounwind
declare i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #2

; Function Attrs: mustprogress nofree norecurse nosync nounwind uwtable
define dso_local void @checkpoint(float* nocapture noundef writeonly %ckpt_mem, i32 noundef %i, float* nocapture noundef readonly %result, i32 noundef %size, i32 noundef %id, i8 noundef signext %inst) local_unnamed_addr #3 {
entry.upper:
  %0 = load i32, i32* @_ZL9heartbeat, align 4, !tbaa !5
  %inc = add i32 %0, 1
  store i32 %inc, i32* @_ZL9heartbeat, align 4, !tbaa !5
  %conv = uitofp i32 %0 to float
  %arrayidx = getelementptr inbounds float, float* %ckpt_mem, i64 1
  store float %conv, float* %arrayidx, align 4, !tbaa !9
  %conv1 = sitofp i32 %id to float
  %arrayidx2 = getelementptr inbounds float, float* %ckpt_mem, i64 2
  store float %conv1, float* %arrayidx2, align 4, !tbaa !9
  %conv3 = sitofp i32 %i to float
  %arrayidx4 = getelementptr inbounds float, float* %ckpt_mem, i64 3
  store float %conv3, float* %arrayidx4, align 4, !tbaa !9
  %mul = mul i32 %size, %size
  br label %checkpoint.restoreControllerBB

checkpoint.restoreControllerBB:                   ; preds = %entry.upper
  %load.CheckpointID_address = alloca i8, align 1
  %loaded.CheckpointID = load i8, i8* %load.CheckpointID_address, align 1
  switch i8 %loaded.CheckpointID, label %entry.lower [
    i8 0, label %for.body.upper.restoreBB.id0
  ]

entry.lower:                                      ; preds = %checkpoint.restoreControllerBB
  %cmp17.not = icmp eq i32 %mul, 0
  br i1 %cmp17.not, label %for.cond.cleanup, label %for.body.preheader

for.body.preheader:                               ; preds = %entry.lower
  %wide.trip.count = zext i32 %mul to i64
  br label %for.body.upper

for.cond.cleanup:                                 ; preds = %for.body.lower, %entry.lower
  ret void

for.body.upper:                                   ; preds = %for.body.lower, %for.body.preheader
  %new.wide.trip.count.phi = phi i64 [ %new.wide.trip.count, %for.body.lower ], [ %wide.trip.count, %for.body.preheader ]
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %new.indvars.iv.next, %for.body.lower ]
  %arrayidx5 = getelementptr inbounds float, float* %result, i64 %indvars.iv
  %1 = load float, float* %arrayidx5, align 4, !tbaa !9
  %2 = add nuw nsw i64 %indvars.iv, 4
  %arrayidx7 = getelementptr inbounds float, float* %ckpt_mem, i64 %2
  store float %1, float* %arrayidx7, align 4, !tbaa !9
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %for.body.upper.saveBB.id0

for.body.upper.saveBB.id0:                        ; preds = %for.body.upper
  %store.wide.trip.count_address = alloca i64, align 8
  store i64 %new.wide.trip.count.phi, i64* %store.wide.trip.count_address, align 8
  %store.indvars.iv.next_address = alloca i64, align 8
  store i64 %indvars.iv.next, i64* %store.indvars.iv.next_address, align 8
  br label %for.body.upper.junctionBB.id0

for.body.upper.junctionBB.id0:                    ; preds = %for.body.upper.restoreBB.id0, %for.body.upper.saveBB.id0
  %new.wide.trip.count = phi i64 [ %new.wide.trip.count.phi, %for.body.upper.saveBB.id0 ], [ %loaded.wide.trip.count, %for.body.upper.restoreBB.id0 ]
  %new.indvars.iv.next = phi i64 [ %indvars.iv.next, %for.body.upper.saveBB.id0 ], [ %loaded.indvars.iv.next, %for.body.upper.restoreBB.id0 ]
  br label %for.body.lower

for.body.lower:                                   ; preds = %for.body.upper.junctionBB.id0
  %exitcond.not = icmp eq i64 %new.indvars.iv.next, %new.wide.trip.count
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body.upper, !llvm.loop !11

for.body.upper.restoreBB.id0:                     ; preds = %checkpoint.restoreControllerBB
  %load.wide.trip.count_address = alloca i64, align 8
  %loaded.wide.trip.count = load i64, i64* %load.wide.trip.count_address, align 8
  %load.indvars.iv.next_address = alloca i64, align 8
  %loaded.indvars.iv.next = load i64, i64* %load.indvars.iv.next_address, align 8
  br label %for.body.upper.junctionBB.id0
}

; Function Attrs: mustprogress nofree nounwind uwtable
define dso_local void @lud(float* nocapture noundef %result, i32 noundef %size, float* nocapture noundef %ckpt_mem, i32 noundef %ckpt_id) local_unnamed_addr #4 {
entry.upper:
  store float 0.000000e+00, float* %ckpt_mem, align 4, !tbaa !9
  br label %lud.restoreControllerBB

lud.restoreControllerBB:                          ; preds = %entry.upper
  %load.CheckpointID_address = alloca i8, align 1
  %loaded.CheckpointID = load i8, i8* %load.CheckpointID_address, align 1
  switch i8 %loaded.CheckpointID, label %entry.lower [
    i8 0, label %if.end.upper.restoreBB.id0
  ]

entry.lower:                                      ; preds = %lud.restoreControllerBB
  %cmp = icmp eq i32 %ckpt_id, 1
  br i1 %cmp, label %if.then.upper, label %if.end.upper

if.then.upper:                                    ; preds = %entry.lower
  %arrayidx1 = getelementptr inbounds float, float* %ckpt_mem, i64 3
  %0 = load float, float* %arrayidx1, align 4, !tbaa !9
  %1 = call float @llvm.round.f32(float %0) #8
  %add = fadd float %1, 1.000000e+00
  %conv = fptosi float %add to i32
  %mul = mul i32 %size, %size
  br label %if.then.lower

if.then.lower:                                    ; preds = %if.then.upper
  %cmp2146.not = icmp eq i32 %mul, 0
  br i1 %cmp2146.not, label %for.cond.cleanup, label %for.body.preheader

for.body.preheader:                               ; preds = %if.then.lower
  %wide.trip.count = zext i32 %mul to i64
  br label %for.body.upper

for.cond.cleanup:                                 ; preds = %for.body.lower, %if.then.lower
  %call7 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @.str, i64 0, i64 0), i32 noundef %conv)
  br label %if.end.upper

for.body.upper:                                   ; preds = %for.body.lower, %for.body.preheader
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body.lower ]
  %2 = add nuw nsw i64 %indvars.iv, 4
  %arrayidx4 = getelementptr inbounds float, float* %ckpt_mem, i64 %2
  %3 = load float, float* %arrayidx4, align 4, !tbaa !9
  %arrayidx6 = getelementptr inbounds float, float* %result, i64 %indvars.iv
  store float %3, float* %arrayidx6, align 4, !tbaa !9
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %for.body.lower

for.body.lower:                                   ; preds = %for.body.upper
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body.upper, !llvm.loop !14

if.end.upper:                                     ; preds = %for.cond.cleanup, %entry.lower
  %init_i.0 = phi i32 [ %conv, %for.cond.cleanup ], [ 0, %entry.lower ]
  br label %if.end.upper.saveBB.id0

if.end.upper.saveBB.id0:                          ; preds = %if.end.upper
  %store.result_address = alloca float*, align 8
  store float* %result, float** %store.result_address, align 8
  %store.size_address = alloca i32, align 4
  store i32 %size, i32* %store.size_address, align 4
  %store.ckpt_mem_address = alloca float*, align 8
  store float* %ckpt_mem, float** %store.ckpt_mem_address, align 8
  %store.init_i.0_address = alloca i32, align 4
  store i32 %init_i.0, i32* %store.init_i.0_address, align 4
  br label %if.end.upper.junctionBB.id0

if.end.upper.junctionBB.id0:                      ; preds = %if.end.upper.restoreBB.id0, %if.end.upper.saveBB.id0
  %new.result = phi float* [ %result, %if.end.upper.saveBB.id0 ], [ %loaded.result, %if.end.upper.restoreBB.id0 ]
  %new.size = phi i32 [ %size, %if.end.upper.saveBB.id0 ], [ %loaded.size, %if.end.upper.restoreBB.id0 ]
  %new.ckpt_mem = phi float* [ %ckpt_mem, %if.end.upper.saveBB.id0 ], [ %loaded.ckpt_mem, %if.end.upper.restoreBB.id0 ]
  %new.init_i.0 = phi i32 [ %init_i.0, %if.end.upper.saveBB.id0 ], [ %loaded.init_i.0, %if.end.upper.restoreBB.id0 ]
  br label %if.end.lower

if.end.lower:                                     ; preds = %if.end.upper.junctionBB.id0
  %cmp9160 = icmp slt i32 %new.init_i.0, %new.size
  br i1 %cmp9160, label %for.cond11.preheader.preheader, label %for.end77

for.cond11.preheader.preheader:                   ; preds = %if.end.lower
  %4 = sext i32 %new.size to i64
  %5 = sext i32 %new.init_i.0 to i64
  %6 = sext i32 %new.size to i64
  %7 = sext i32 %new.size to i64
  %8 = sext i32 %new.size to i64
  %9 = sext i32 %new.size to i64
  %10 = sext i32 %new.size to i64
  %11 = sext i32 %new.size to i64
  %wide.trip.count200 = sext i32 %new.size to i64
  br label %for.cond11.preheader

for.cond8.loopexit.upper:                         ; preds = %for.end63.lower, %for.end39.lower
  %new.ckpt_mem.phi7.phi.phi8.phi = phi float* [ %new.ckpt_mem.phi7.phi.phi8.phi9.phi10, %for.end63.lower ], [ %new.ckpt_mem.phi7.phi.phi8, %for.end39.lower ]
  %new.size.phi.phi.phi4.phi = phi i32 [ %new.size.phi.phi.phi4.phi5.phi6, %for.end63.lower ], [ %new.size.phi.phi.phi4, %for.end39.lower ]
  %new.result.phi.phi.phi1.phi = phi float* [ %new.result.phi.phi.phi1.phi2.phi3, %for.end63.lower ], [ %new.result.phi.phi.phi1, %for.end39.lower ]
  br label %for.cond8.loopexit.lower

for.cond8.loopexit.lower:                         ; preds = %for.cond8.loopexit.upper
  %exitcond201.not = icmp eq i64 %indvars.iv.next176, %wide.trip.count200
  br i1 %exitcond201.not, label %for.end77, label %for.cond11.preheader, !llvm.loop !15

for.cond11.preheader:                             ; preds = %for.cond8.loopexit.lower, %for.cond11.preheader.preheader
  %new.ckpt_mem.phi7 = phi float* [ %new.ckpt_mem.phi7.phi.phi8.phi, %for.cond8.loopexit.lower ], [ %new.ckpt_mem, %for.cond11.preheader.preheader ]
  %new.size.phi = phi i32 [ %new.size.phi.phi.phi4.phi, %for.cond8.loopexit.lower ], [ %new.size, %for.cond11.preheader.preheader ]
  %new.result.phi = phi float* [ %new.result.phi.phi.phi1.phi, %for.cond8.loopexit.lower ], [ %new.result, %for.cond11.preheader.preheader ]
  %indvars.iv189.in = phi i64 [ %5, %for.cond11.preheader.preheader ], [ %indvars.iv189, %for.cond8.loopexit.lower ]
  %indvars.iv175 = phi i64 [ %5, %for.cond11.preheader.preheader ], [ %indvars.iv.next176, %for.cond8.loopexit.lower ]
  %indvars.iv189 = add nsw i64 %indvars.iv189.in, 1
  %indvars199 = trunc i64 %indvars.iv175 to i32
  %12 = mul nsw i64 %indvars.iv175, %10
  %cmp19148 = icmp sgt i64 %indvars.iv175, 0
  %wide.trip.count173 = and i64 %indvars.iv175, 4294967295
  br label %for.body13.upper

for.body13.upper:                                 ; preds = %for.end32.lower, %for.cond11.preheader
  %new.ckpt_mem.phi7.phi = phi float* [ %new.ckpt_mem.phi7.phi.phi8, %for.end32.lower ], [ %new.ckpt_mem.phi7, %for.cond11.preheader ]
  %new.size.phi.phi = phi i32 [ %new.size.phi.phi.phi4, %for.end32.lower ], [ %new.size.phi, %for.cond11.preheader ]
  %new.result.phi.phi = phi float* [ %new.result.phi.phi.phi1, %for.end32.lower ], [ %new.result.phi, %for.cond11.preheader ]
  %indvars.iv177 = phi i64 [ %indvars.iv175, %for.cond11.preheader ], [ %indvars.iv.next178, %for.end32.lower ]
  %13 = add nsw i64 %indvars.iv177, %12
  %arrayidx17 = getelementptr inbounds float, float* %new.result.phi.phi, i64 %13
  %14 = load float, float* %arrayidx17, align 4, !tbaa !9
  br label %for.body13.lower

for.body13.lower:                                 ; preds = %for.body13.upper
  br i1 %cmp19148, label %for.body20.upper, label %for.end32.upper

for.body20.upper:                                 ; preds = %for.body20.lower, %for.body13.lower
  %new.ckpt_mem.phi7.phi.phi = phi float* [ %new.ckpt_mem.phi7.phi.phi, %for.body20.lower ], [ %new.ckpt_mem.phi7.phi, %for.body13.lower ]
  %new.size.phi.phi.phi = phi i32 [ %new.size.phi.phi.phi, %for.body20.lower ], [ %new.size.phi.phi, %for.body13.lower ]
  %new.result.phi.phi.phi = phi float* [ %new.result.phi.phi.phi, %for.body20.lower ], [ %new.result.phi.phi, %for.body13.lower ]
  %indvars.iv167 = phi i64 [ %indvars.iv.next168, %for.body20.lower ], [ 0, %for.body13.lower ]
  %sum.0150 = phi float [ %20, %for.body20.lower ], [ %14, %for.body13.lower ]
  %15 = add nsw i64 %indvars.iv167, %12
  %arrayidx24 = getelementptr inbounds float, float* %new.result.phi.phi.phi, i64 %15
  %16 = load float, float* %arrayidx24, align 4, !tbaa !9
  %17 = mul nsw i64 %indvars.iv167, %4
  %18 = add nsw i64 %17, %indvars.iv177
  %arrayidx28 = getelementptr inbounds float, float* %new.result.phi.phi.phi, i64 %18
  %19 = load float, float* %arrayidx28, align 4, !tbaa !9
  %neg = fneg float %16
  %20 = call float @llvm.fmuladd.f32(float %neg, float %19, float %sum.0150)
  %indvars.iv.next168 = add nuw nsw i64 %indvars.iv167, 1
  br label %for.body20.lower

for.body20.lower:                                 ; preds = %for.body20.upper
  %exitcond174.not = icmp eq i64 %indvars.iv.next168, %wide.trip.count173
  br i1 %exitcond174.not, label %for.end32.upper, label %for.body20.upper, !llvm.loop !16

for.end32.upper:                                  ; preds = %for.body20.lower, %for.body13.lower
  %new.ckpt_mem.phi7.phi.phi8 = phi float* [ %new.ckpt_mem.phi7.phi.phi, %for.body20.lower ], [ %new.ckpt_mem.phi7.phi, %for.body13.lower ]
  %new.size.phi.phi.phi4 = phi i32 [ %new.size.phi.phi.phi, %for.body20.lower ], [ %new.size.phi.phi, %for.body13.lower ]
  %new.result.phi.phi.phi1 = phi float* [ %new.result.phi.phi.phi, %for.body20.lower ], [ %new.result.phi.phi, %for.body13.lower ]
  %sum.0.lcssa = phi float [ %14, %for.body13.lower ], [ %20, %for.body20.lower ]
  store float %sum.0.lcssa, float* %arrayidx17, align 4, !tbaa !9
  %indvars.iv.next178 = add nsw i64 %indvars.iv177, 1
  br label %for.end32.lower

for.end32.lower:                                  ; preds = %for.end32.upper
  %cmp12 = icmp slt i64 %indvars.iv.next178, %6
  br i1 %cmp12, label %for.body13.upper, label %for.end39.upper, !llvm.loop !17

for.end39.upper:                                  ; preds = %for.end32.lower
  %indvars.iv.next176 = add nsw i64 %indvars.iv175, 1
  br label %for.end39.lower

for.end39.lower:                                  ; preds = %for.end39.upper
  %cmp42158 = icmp slt i64 %indvars.iv.next176, %11
  br i1 %cmp42158, label %for.body43.lr.ph, label %for.cond8.loopexit.upper

for.body43.lr.ph:                                 ; preds = %for.end39.lower
  %cmp49154 = icmp sgt i64 %indvars.iv175, 0
  %mul64 = mul nsw i32 %indvars199, %new.size.phi.phi.phi4
  %21 = sext i32 %mul64 to i64
  %22 = add nsw i64 %indvars.iv175, %21
  %arrayidx67 = getelementptr inbounds float, float* %new.result.phi.phi.phi1, i64 %22
  %wide.trip.count187 = and i64 %indvars.iv175, 4294967295
  br label %for.body43.upper

for.body43.upper:                                 ; preds = %for.end63.lower, %for.body43.lr.ph
  %new.ckpt_mem.phi7.phi.phi8.phi9 = phi float* [ %new.ckpt_mem.phi7.phi.phi8.phi9.phi10, %for.end63.lower ], [ %new.ckpt_mem.phi7.phi.phi8, %for.body43.lr.ph ]
  %new.size.phi.phi.phi4.phi5 = phi i32 [ %new.size.phi.phi.phi4.phi5.phi6, %for.end63.lower ], [ %new.size.phi.phi.phi4, %for.body43.lr.ph ]
  %new.result.phi.phi.phi1.phi2 = phi float* [ %new.result.phi.phi.phi1.phi2.phi3, %for.end63.lower ], [ %new.result.phi.phi.phi1, %for.body43.lr.ph ]
  %indvars.iv191 = phi i64 [ %indvars.iv189, %for.body43.lr.ph ], [ %indvars.iv.next192, %for.end63.lower ]
  %23 = mul nsw i64 %indvars.iv191, %8
  %24 = add nsw i64 %23, %indvars.iv175
  %arrayidx47 = getelementptr inbounds float, float* %new.result.phi.phi.phi1.phi2, i64 %24
  %25 = load float, float* %arrayidx47, align 4, !tbaa !9
  br label %for.body43.lower

for.body43.lower:                                 ; preds = %for.body43.upper
  br i1 %cmp49154, label %for.body50.upper, label %for.end63.upper

for.body50.upper:                                 ; preds = %for.body50.lower, %for.body43.lower
  %new.ckpt_mem.phi7.phi.phi8.phi9.phi = phi float* [ %new.ckpt_mem.phi7.phi.phi8.phi9.phi, %for.body50.lower ], [ %new.ckpt_mem.phi7.phi.phi8.phi9, %for.body43.lower ]
  %new.size.phi.phi.phi4.phi5.phi = phi i32 [ %new.size.phi.phi.phi4.phi5.phi, %for.body50.lower ], [ %new.size.phi.phi.phi4.phi5, %for.body43.lower ]
  %new.result.phi.phi.phi1.phi2.phi = phi float* [ %new.result.phi.phi.phi1.phi2.phi, %for.body50.lower ], [ %new.result.phi.phi.phi1.phi2, %for.body43.lower ]
  %indvars.iv181 = phi i64 [ %indvars.iv.next182, %for.body50.lower ], [ 0, %for.body43.lower ]
  %sum.1156 = phi float [ %31, %for.body50.lower ], [ %25, %for.body43.lower ]
  %26 = add nsw i64 %indvars.iv181, %23
  %arrayidx54 = getelementptr inbounds float, float* %new.result.phi.phi.phi1.phi2.phi, i64 %26
  %27 = load float, float* %arrayidx54, align 4, !tbaa !9
  %28 = mul nsw i64 %indvars.iv181, %7
  %29 = add nsw i64 %28, %indvars.iv175
  %arrayidx58 = getelementptr inbounds float, float* %new.result.phi.phi.phi1.phi2.phi, i64 %29
  %30 = load float, float* %arrayidx58, align 4, !tbaa !9
  %neg60 = fneg float %27
  %31 = call float @llvm.fmuladd.f32(float %neg60, float %30, float %sum.1156)
  %indvars.iv.next182 = add nuw nsw i64 %indvars.iv181, 1
  br label %for.body50.lower

for.body50.lower:                                 ; preds = %for.body50.upper
  %exitcond188.not = icmp eq i64 %indvars.iv.next182, %wide.trip.count187
  br i1 %exitcond188.not, label %for.end63.upper, label %for.body50.upper, !llvm.loop !18

for.end63.upper:                                  ; preds = %for.body50.lower, %for.body43.lower
  %new.ckpt_mem.phi7.phi.phi8.phi9.phi10 = phi float* [ %new.ckpt_mem.phi7.phi.phi8.phi9.phi, %for.body50.lower ], [ %new.ckpt_mem.phi7.phi.phi8.phi9, %for.body43.lower ]
  %new.size.phi.phi.phi4.phi5.phi6 = phi i32 [ %new.size.phi.phi.phi4.phi5.phi, %for.body50.lower ], [ %new.size.phi.phi.phi4.phi5, %for.body43.lower ]
  %new.result.phi.phi.phi1.phi2.phi3 = phi float* [ %new.result.phi.phi.phi1.phi2.phi, %for.body50.lower ], [ %new.result.phi.phi.phi1.phi2, %for.body43.lower ]
  %sum.1.lcssa = phi float [ %25, %for.body43.lower ], [ %31, %for.body50.lower ]
  %32 = load float, float* %arrayidx67, align 4, !tbaa !9
  %div = fdiv float %sum.1.lcssa, %32
  store float %div, float* %arrayidx47, align 4, !tbaa !9
  %indvars.iv.next192 = add nsw i64 %indvars.iv191, 1
  br label %for.end63.lower

for.end63.lower:                                  ; preds = %for.end63.upper
  %cmp42 = icmp slt i64 %indvars.iv.next192, %9
  br i1 %cmp42, label %for.body43.upper, label %for.cond8.loopexit.upper, !llvm.loop !19

for.end77:                                        ; preds = %for.cond8.loopexit.lower, %if.end.lower
  %new.ckpt_mem.phi = phi float* [ %new.ckpt_mem.phi7.phi.phi8.phi, %for.cond8.loopexit.lower ], [ %new.ckpt_mem, %if.end.lower ]
  store float 1.000000e+00, float* %new.ckpt_mem.phi, align 4, !tbaa !9
  ret void

if.end.upper.restoreBB.id0:                       ; preds = %lud.restoreControllerBB
  %load.result_address = alloca float*, align 8
  %loaded.result = load float*, float** %load.result_address, align 8
  %load.size_address = alloca i32, align 4
  %loaded.size = load i32, i32* %load.size_address, align 4
  %load.ckpt_mem_address = alloca float*, align 8
  %loaded.ckpt_mem = load float*, float** %load.ckpt_mem_address, align 8
  %load.init_i.0_address = alloca i32, align 4
  %loaded.init_i.0 = load i32, i32* %load.init_i.0_address, align 4
  br label %if.end.upper.junctionBB.id0
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #5

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #6

; Function Attrs: mustprogress nofree nounwind uwtable
define dso_local void @workload(float* nocapture noundef %result, i32 noundef %size, float* nocapture noundef %ckpt_mem) local_unnamed_addr #4 {
entry:
  %arrayidx = getelementptr inbounds float, float* %ckpt_mem, i64 2
  %0 = load float, float* %arrayidx, align 4, !tbaa !9
  %conv = fptosi float %0 to i32
  call void @lud(float* noundef %result, i32 noundef %size, float* noundef %ckpt_mem, i32 noundef %conv)
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.round.f32(float) #6

; Function Attrs: uwtable
define internal void @_GLOBAL__sub_I_lud.cpp() #7 section ".text.startup" {
entry:
  call void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init"* noundef nonnull align 1 dereferenceable(1) @_ZStL8__ioinit)
  %0 = call i32 @__cxa_atexit(void (i8*)* bitcast (void (%"class.std::ios_base::Init"*)* @_ZNSt8ios_base4InitD1Ev to void (i8*)*), i8* getelementptr inbounds (%"class.std::ios_base::Init", %"class.std::ios_base::Init"* @_ZStL8__ioinit, i64 0, i32 0), i8* nonnull @__dso_handle) #8
  ret void
}

attributes #0 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nofree nounwind }
attributes #3 = { mustprogress nofree norecurse nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress nofree nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { nounwind }

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
