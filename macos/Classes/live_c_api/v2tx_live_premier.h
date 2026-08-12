// Copyright (c) 2023 Tencent. All rights reserved.
// Author: bluedang

#ifndef SDK_LIVE_C_V2TX_LIVE_PREMIER_H_  // NOLINT(build/header_guard)
#define SDK_LIVE_C_V2TX_LIVE_PREMIER_H_

#include "v2tx_live_def.h"

#ifdef __cplusplus
extern "C" {
#endif

v2tx_live_c_api void v2tx_live_premier_set_user_id(const char* userId);
v2tx_live_c_api int32_t v2tx_live_premier_set_environment(const char* env);
v2tx_live_c_api const char* v2tx_live_premier_get_sdk_version();

v2tx_live_c_api void v2tx_live_premier_set_license(const char* url, const char* key);
v2tx_live_c_api void v2tx_live_premier_set_log_config(v2tx_live_log_config_t log_config);
v2tx_live_c_api int32_t v2tx_live_premier_call_experimental_api(const char* json);

typedef void (*v2tx_live_premier_on_license_loaded_handler)(int result, const char* message);
typedef void (*v2tx_live_premier_on_log_handler)(v2tx_live_log_level_e log_level,
                                                 const char* message);

v2tx_live_c_api void v2tx_live_premier_set_on_license_loaded_handler(
    v2tx_live_premier_on_license_loaded_handler handler);
v2tx_live_c_api void v2tx_live_premier_set_on_log_handler(v2tx_live_premier_on_log_handler handler);

#ifdef __cplusplus
}
#endif

#endif  // SDK_LIVE_C_V2TX_LIVE_PREMIER_H_  // NOLINT(build/header_guard)
