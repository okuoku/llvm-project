; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -rewrite-statepoints-for-gc -S < %s | FileCheck %s
; RUN: opt -passes=rewrite-statepoints-for-gc -S < %s | FileCheck %s

; Ensure that the gc.statepoint calls / invokes we generate carry over
; the right calling conventions.

define i64 addrspace(1)* @test_invoke_format(i64 addrspace(1)* %obj, i64 addrspace(1)* %obj1) gc "statepoint-example" personality i32 ()* @personality {
; CHECK-LABEL: @test_invoke_format(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[STATEPOINT_TOKEN:%.*]] = invoke coldcc token (i64, i32, i64 addrspace(1)* (i64 addrspace(1)*)*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_p1i64p1i64f(i64 2882400000, i32 0, i64 addrspace(1)* (i64 addrspace(1)*)* @callee, i32 1, i32 0, i64 addrspace(1)* [[OBJ:%.*]], i32 0, i32 0) [ "gc-live"(i64 addrspace(1)* [[OBJ1:%.*]], i64 addrspace(1)* [[OBJ]]) ]
; CHECK-NEXT:    to label [[NORMAL_RETURN:%.*]] unwind label [[EXCEPTIONAL_RETURN:%.*]]
; CHECK:       normal_return:
; CHECK-NEXT:    [[RET_VAL1:%.*]] = call i64 addrspace(1)* @llvm.experimental.gc.result.p1i64(token [[STATEPOINT_TOKEN]])
; CHECK-NEXT:    [[OBJ1_RELOCATED2:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 0, i32 0)
; CHECK-NEXT:    [[OBJ1_RELOCATED2_CASTED:%.*]] = bitcast i8 addrspace(1)* [[OBJ1_RELOCATED2]] to i64 addrspace(1)*
; CHECK-NEXT:    [[OBJ_RELOCATED3:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 1, i32 1)
; CHECK-NEXT:    [[OBJ_RELOCATED3_CASTED:%.*]] = bitcast i8 addrspace(1)* [[OBJ_RELOCATED3]] to i64 addrspace(1)*
; CHECK-NEXT:    ret i64 addrspace(1)* [[RET_VAL1]]
; CHECK:       exceptional_return:
; CHECK-NEXT:    [[LANDING_PAD4:%.*]] = landingpad token
; CHECK-NEXT:    cleanup
; CHECK-NEXT:    [[OBJ1_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[LANDING_PAD4]], i32 0, i32 0)
; CHECK-NEXT:    [[OBJ1_RELOCATED_CASTED:%.*]] = bitcast i8 addrspace(1)* [[OBJ1_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    [[OBJ_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[LANDING_PAD4]], i32 1, i32 1)
; CHECK-NEXT:    [[OBJ_RELOCATED_CASTED:%.*]] = bitcast i8 addrspace(1)* [[OBJ_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    ret i64 addrspace(1)* [[OBJ1_RELOCATED_CASTED]]
;
entry:
  %ret_val = invoke coldcc i64 addrspace(1)* @callee(i64 addrspace(1)* %obj)
  to label %normal_return unwind label %exceptional_return

normal_return:
  ret i64 addrspace(1)* %ret_val

exceptional_return:
  %landing_pad4 = landingpad token
  cleanup
  ret i64 addrspace(1)* %obj1
}

define i64 addrspace(1)* @test_call_format(i64 addrspace(1)* %obj, i64 addrspace(1)* %obj1) gc "statepoint-example" {
; CHECK-LABEL: @test_call_format(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[STATEPOINT_TOKEN:%.*]] = call coldcc token (i64, i32, i64 addrspace(1)* (i64 addrspace(1)*)*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_p1i64p1i64f(i64 2882400000, i32 0, i64 addrspace(1)* (i64 addrspace(1)*)* @callee, i32 1, i32 0, i64 addrspace(1)* [[OBJ:%.*]], i32 0, i32 0) [ "gc-live"(i64 addrspace(1)* [[OBJ]]) ]
; CHECK-NEXT:    [[RET_VAL1:%.*]] = call i64 addrspace(1)* @llvm.experimental.gc.result.p1i64(token [[STATEPOINT_TOKEN]])
; CHECK-NEXT:    [[OBJ_RELOCATED:%.*]] = call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token [[STATEPOINT_TOKEN]], i32 0, i32 0)
; CHECK-NEXT:    [[OBJ_RELOCATED_CASTED:%.*]] = bitcast i8 addrspace(1)* [[OBJ_RELOCATED]] to i64 addrspace(1)*
; CHECK-NEXT:    ret i64 addrspace(1)* [[RET_VAL1]]
;
entry:
  %ret_val = call coldcc i64 addrspace(1)* @callee(i64 addrspace(1)* %obj)
  ret i64 addrspace(1)* %ret_val
}

; This function is inlined when inserting a poll.
declare void @do_safepoint()
define void @gc.safepoint_poll() {
; CHECK-LABEL: @gc.safepoint_poll(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @do_safepoint()
; CHECK-NEXT:    ret void
;
entry:
  call void @do_safepoint()
  ret void
}

declare coldcc i64 addrspace(1)* @callee(i64 addrspace(1)*)
declare i32 @personality()
