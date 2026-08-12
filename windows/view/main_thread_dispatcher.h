// Copyright (c) Tencent. All rights reserved.
//
// main_thread_dispatcher.h
//

#ifndef SDK_TRTC_V3_WINDOWS_VIEW_MAIN_THREAD_DISPATCHER_H_
#define SDK_TRTC_V3_WINDOWS_VIEW_MAIN_THREAD_DISPATCHER_H_

#include <windows.h>

#include <atomic>
#include <functional>
#include <mutex>
#include <queue>

namespace trtc_sdk_flutter {

class MainThreadDispatcher {
 public:
    using Task = std::function<void()>;

    MainThreadDispatcher();
    ~MainThreadDispatcher();

    MainThreadDispatcher(const MainThreadDispatcher&) = delete;
    MainThreadDispatcher& operator=(const MainThreadDispatcher&) = delete;

    bool Initialize();

    void Post(Task task);

 private:
    void ProcessTasks();
    static LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

 private:
    static constexpr UINT WM_DISPATCH_TASK = WM_USER + 0x1001;

    HWND hwnd_ = nullptr;
    DWORD main_thread_id_ = 0;
    std::atomic<bool> initialized_{false};
    std::mutex mutex_;
    std::queue<Task> tasks_;
};

}  // namespace trtc_sdk_flutter

#endif  // SDK_TRTC_V3_WINDOWS_VIEW_MAIN_THREAD_DISPATCHER_H_
