//
//  txg_log.h
//  Pods
//
//  Created by 林智 on 2020/11/13.
//

#ifndef txg_log_h
#define txg_log_h

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

typedef enum {
	TXE_LOG_VERBOSE = 0,
	TXE_LOG_DEBUG,
	TXE_LOG_INFO,
	TXE_LOG_WARNING,
	TXE_LOG_ERROR,
	TXE_LOG_FATAL,
	TXE_LOG_NONE,
} TXELogLevel;

void txf_log(TXELogLevel level, const char *file, int line, const char *func, const char *format, ...);

void txf_log_swift(TXELogLevel level, const char *file, int line, const char *func, const char *content);

#ifdef __cplusplus
}
#endif

#endif /* txg_log_h */
