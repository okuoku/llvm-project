//===-- HostNativeThreadBase.cpp ------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "lldb/Host/HostNativeThreadBase.h"
#include "lldb/Host/HostInfo.h"
#include "lldb/Host/ThreadLauncher.h"
#include "lldb/Utility/Log.h"

#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/Threading.h"

using namespace lldb;
using namespace lldb_private;

HostNativeThreadBase::HostNativeThreadBase(thread_t thread)
    : m_thread(thread), m_result(0) {} // NOLINT(modernize-use-nullptr)

lldb::thread_t HostNativeThreadBase::GetSystemHandle() const {
  return m_thread;
}

lldb::thread_result_t HostNativeThreadBase::GetResult() const {
  return m_result;
}

bool HostNativeThreadBase::IsJoinable() const {
  return m_thread != LLDB_INVALID_HOST_THREAD;
}

void HostNativeThreadBase::Reset() {
  m_thread = LLDB_INVALID_HOST_THREAD;
  m_result = 0; // NOLINT(modernize-use-nullptr)
}

bool HostNativeThreadBase::EqualsThread(lldb::thread_t thread) const {
  return m_thread == thread;
}

lldb::thread_t HostNativeThreadBase::Release() {
  lldb::thread_t result = m_thread;
  m_thread = LLDB_INVALID_HOST_THREAD;
  m_result = 0; // NOLINT(modernize-use-nullptr)

  return result;
}

lldb::thread_result_t
HostNativeThreadBase::ThreadCreateTrampoline(lldb::thread_arg_t arg) {
  ThreadLauncher::HostThreadCreateInfo *info =
      (ThreadLauncher::HostThreadCreateInfo *)arg;
  llvm::set_thread_name(info->thread_name);

  thread_func_t thread_fptr = info->thread_fptr;
  thread_arg_t thread_arg = info->thread_arg;

  Log *log = GetLog(LLDBLog::Thread);
  LLDB_LOGF(log, "thread created");

  delete info;
  return thread_fptr(thread_arg);
}
