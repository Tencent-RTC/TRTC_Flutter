// Copyright (c) Tencent. All rights reserved.
//
// main_thread_dispatcher.cpp
//

#include "view/main_thread_dispatcher.h"

#include <queue>
#include <utility>

namespace trtc_sdk_flutter {

MainThreadDispatcher::MainThreadDispatcher() = default;

MainThreadDispatcher::~MainThreadDispatcher() {
    if (hwnd_) {
        DestroyWindow(hwnd_);
        hwnd_ = nullptr;
    }
    std::queue<Task> empty;
    {
        std::lock_guard<std::mutex> lock(mutex_);
        std::swap(tasks_, empty);
    }
    initialized_.store(false);
}

bool MainThreadDispatcher::Initialize() {
    if (initialized_.load()) {
        return true;
    }

    main_thread_id_ = GetCurrentThreadId();

    WNDCLASSEXW wc = {};
    wc.cbSize = sizeof(WNDCLASSEXW);
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = GetModuleHandle(nullptr);
    wc.lpszClassName = L"TRTCFlutterDispatcher";

    if (RegisterClassExW(&wc) == 0 && GetLastError() != ERROR_CLASS_ALREADY_EXISTS) {
        return false;
    }

    hwnd_ = CreateWindowExW(0, L"TRTCFlutterDispatcher", L"", 0, 0, 0, 0, 0,
                            HWND_MESSAGE, nullptr, GetModuleHandle(nullptr), this);
    if (hwnd_ == nullptr) {
        return false;
    }

    initialized_.store(true);
    return true;
}

LRESULT CALLBACK MainThreadDispatcher::WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (msg == WM_NCCREATE) {
        auto* cs = reinterpret_cast<CREATESTRUCT*>(lParam);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(cs->lpCreateParams));
        return DefWindowProcW(hwnd, msg, wParam, lParam);
    }

    if (msg == WM_DISPATCH_TASK) {
        auto* self = reinterpret_cast<MainThreadDispatcher*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
        if (self) {
            self->ProcessTasks();
        }
        return 0;
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam);
}

void MainThreadDispatcher::ProcessTasks() {
    std::queue<Task> tasks_to_run;
    {
        std::lock_guard<std::mutex> lock(mutex_);
        std::swap(tasks_to_run, tasks_);
    }

    while (!tasks_to_run.empty()) {
        auto task = std::move(tasks_to_run.front());
        tasks_to_run.pop();
        if (task) {
            task();
        }
    }
}

void MainThreadDispatcher::Post(Task task) {
    if (!task) {
        return;
    }

    if (initialized_.load() && GetCurrentThreadId() == main_thread_id_) {
        task();
        return;
    }

    if (!initialized_.load() || hwnd_ == nullptr) {
        return;
    }

    {
        std::lock_guard<std::mutex> lock(mutex_);
        tasks_.push(std::move(task));
    }
    PostMessageW(hwnd_, WM_DISPATCH_TASK, 0, 0);
}

}  // namespace trtc_sdk_flutter
