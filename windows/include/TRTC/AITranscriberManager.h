/**
 * Copyright (c) 2025 Tencent. All rights reserved.
 * Module:   AI 实时转录和翻译的管理类
 * Function: 用于对 AI 实时转录和翻译功能进行设置的管理类
 */
#ifndef __AITRANSCRIBERMANAGER_H__
#define __AITRANSCRIBERMANAGER_H__

#include <stdint.h>

namespace liteav {

/**
 * AI 转录相关的数据结构。
 *
 * 翻译文本信息的结构体。
 *
 * 该结构体用于存储翻译的目标语言代码及其对应的翻译文本。
 */
struct TranslationText {
    /// 【字段含义】目标语言的代码。
    /// 【特殊说明】支持的语言代码如下：
    /// “zh”（中文）、“en”（英语）、“vi”（越南语）、“ja”（日语）、“ko”（韩语）、“id”（印度尼西亚语）、“th”（泰语）、“pt”（葡萄牙语）、
    /// “ar”（阿拉伯语）、“es”（西班牙语）、“fr”（法语）、“ms”（马来语）、“de”（德语）、“it”（意大利语）、“ru”（俄语）。
    const char* language;

    /// 【字段含义】翻译文本。
    /// 【特殊说明】该文本使用 Unicode 编码。
    const char* translationText;

    TranslationText() {
        language = nullptr;
        translationText = nullptr;
    }
};

/**
 * 实时转录的配置参数。
 *
 * 该结构体用于在调用 {@link startRealtimeTranscriber} 接口时指定转录的相关参数，例如转录机器人的 ID、源语言、需要转录的用户列表以及翻译的目标语言等。
 */
struct TranscriberParams {
    /// 【字段含义】转录机器人的唯一标识 ID。
    /// 【特殊说明】如果您不指定该字段，SDK 会默认生成一个 ID，格式为“transcriber_${roomid}_robot_${userid}”。
    const char* transcriberRobotId;

    /// 【字段含义】源语言的代码。
    /// 【特殊说明】指定源音频的语言种类。请填写标准的语言代码（如“zh”），而不是语言名称（如“中文”）。
    /// 【特殊说明】支持的语言如下（如需其他语种支持可以联系我们）：
    /// “zh”（中文）、“en”（英语）、“zh-yue（中国粤语）”、“vi（越南语）”、“ja（日语）”、“ko（韩语）”、“id（印度尼西亚语）”、
    /// “th（泰语）”、“pt（葡萄牙语）”、“tr（土耳其语）”、“ar（阿拉伯语）”、“es（西班牙语）”、“hi（印地语）”、“fr（法语）”、
    /// “ms（马来语）”、“fil（菲律宾语）”、“de（德语）”、“it（意大利语）”、“ru（俄语）”、“sv（瑞典语）”、“da（丹麦语）”、“no（挪威语）”。
    const char* sourceLanguage;

    /// 【字段含义】需要进行转录的用户 ID 列表。
    /// 【特殊说明】如果不填，默认转录房间内所有用户的音频。
    const char** userIdsToTranscribe;

    /// 【字段含义】需要转录的用户 ID 列表的数量。
    uint32_t userIdsToTranscribeCount;

    /// 【字段含义】翻译的目标语言代码列表。
    /// 【特殊说明】如果您需要将转录结果翻译成其他语言，请在此设置目标语言的代码。
    /// 【特殊说明】支持的语言如下（如需其他语种支持可以联系我们）：
    /// “zh”（中文）、“en”（英语）、“vi”（越南语）、“ja”（日语）、“ko”（韩语）、“id”（印度尼西亚语）、“th”（泰语）、“pt”（葡萄牙语）、
    /// “ar”（阿拉伯语）、“es”（西班牙语）、“fr”（法语）、“ms”（马来语）、“de”（德语）、“it”（意大利语）、“ru”（俄语）。
    const char** translationLanguages;

    /// 【字段含义】翻译目标语言代码列表的数量。
    uint32_t translationLanguagesCount;

    TranscriberParams() {
        transcriberRobotId = nullptr;
        sourceLanguage = nullptr;
        userIdsToTranscribe = nullptr;
        userIdsToTranscribeCount = 0;
        translationLanguages = nullptr;
        translationLanguagesCount = 0;
    }
};

/**
 * 实时转录的消息结构体。
 *
 * SDK 通过此结构体将转录出的文本和翻译结果回调给您。
 */
struct TranscriberMessage {
    /// 【字段含义】消息段的唯一标识 ID。
    const char* segmentId;

    /// 【字段含义】说话用户的 ID。
    const char* speakerUserId;

    /// 【字段含义】识别出的源语言文本。
    /// 【特殊说明】该文本使用 Unicode 编码。
    const char* sourceText;

    /// 【字段含义】翻译后的目标语言文本列表。
    TranslationText* translationTexts;

    /// 【字段含义】翻译文本数量。
    uint32_t translationTextsCount;

    /// 【字段含义】消息生成的 UTC 时间戳，单位：毫秒。
    int64_t timestamp;

    /// 【字段含义】转录是否结束。
    /// 【特殊说明】true 表示该句话已说完，false 表示该句话还在进行中（中间结果）。
    bool isCompleted;

    TranscriberMessage() {
        segmentId = nullptr;
        speakerUserId = nullptr;
        sourceText = nullptr;
        translationTexts = nullptr;
        translationTextsCount = 0;
        timestamp = 0;
        isCompleted = false;
    }
};

/**
 * AI 实时转录的事件回调接口。
 */
class AITranscriberListener {
   public:
    virtual ~AITranscriberListener() {
    }

    /**
     * 实时转录开启成功的回调。
     *
     * 当您调用 startRealtimeTranscriber 成功开启转录任务后，会收到此回调。
     * @param roomId 房间 ID。
     * @param transcriberRobotId 转录机器人 ID。
     */
    virtual void onRealtimeTranscriberStarted(const char* roomId, const char* transcriberRobotId) = 0;

    /**
     * 收到实时转录消息的回调。
     *
     * 转录服务会将识别到的文字和翻译结果通过此回调实时推送给您。
     * @param roomId 房间 ID。
     * @param message 转录消息，包含转录文本和翻译结果。详情请参考 {@link TranscriberMessage}。
     */
    virtual void onReceiveTranscriberMessage(const char* roomId, const TranscriberMessage& message) = 0;

    /**
     * 实时转录停止的回调。
     *
     * 当实时转录任务被停止时，会收到此回调。
     * @param roomId 房间 ID。
     * @param transcriberRobotId 转录机器人 ID。
     * @param reason 原因。
     * - 0: 用户主动停止转录任务。
     * - 1: 房间被后台解散。
     * - 2: 参与转录的用户均已离开房间超过 30 秒，转录任务自动结束。
     */
    virtual void onRealtimeTranscriberStopped(const char* roomId, const char* transcriberRobotId, int reason) = 0;

    /**
     * 实时转录出错的回调。
     *
     * 当实时转录服务发生错误时，会收到此回调。
     * @param roomId 房间 ID。
     * @param transcriberRobotId 转录机器人 ID。
     * @param error 错误码。
     * @param errorInfo 具体错误信息。
     * 当 error 返回 ERR_SERVER_PROCESS_FAILED 时，表示服务器处理请求失败。具体错误码及建议处理措施如下：
     * - 2000: 参数错误。建议检查请求参数是否合法。
     * - 2002: 任务不存在。若是调用 stop 接口时返回，可忽略。
     * - 2026: 转录服务（ASR/翻译服务）未开通。请前往控制台开通相关服务。
     * - 3000: 内部错误。建议重试。
     * - 4003: 任务正在退出。若是调用 stop 接口时返回，可忽略。
     * - 5000: 资源过载。建议采用退避策略重试。
     * - 5001: 并发受限。请联系产品侧提升并发限制。
     * - -102009: 主播不在房间内。建议确认主播状态后延迟重试。
     * - -102005: 房间不存在。建议确认房间状态后延迟重试。
     */
    virtual void onRealtimeTranscriberError(const char* roomId, const char* transcriberRobotId, int error, const char* errorInfo) = 0;
};

class AITranscriberManager {
   protected:
    AITranscriberManager() {
    }
    virtual ~AITranscriberManager() {
    }

   public:
    /**
     * AI 转录相关接口。
     *
     * 启动实时转录任务。
     *
     * 参考文档：[实时转录与翻译功能介绍](https://cloud.tencent.com/document/product/647/126311)
     * @param params 转录参数，包含转录机器人 ID、源语言、用户 ID 列表和翻译语言列表。详情请参考 {@link TranscriberParams}。
     * @note
     * 1. 调用该接口前，您需要前往“控制台->功能配置->增值功能”开启 AI 智能识别的语音转文字、实时翻译功能。详情请参见 [开通服务](https://cloud.tencent.com/document/product/647/126312)
     * 2. 该接口支持覆盖调用。若您需在转录过程中更新参数，则可以直接调用该接口覆盖之前同一个转录机器人的转录任务。
     * 3. 启动转录任务成功后，如您需要停止转录任务则必须由发起者通过 stopRealtimeTranscriber 接口停止，房间内其他人无法停止任务。另外当发起者离开房间后，转录任务不会自动停止，需参与转录的用户均已离开房间超过 30 秒，转录任务将自动结束。
     * 4. 如果您需发起者重进房后停止转录，我们推荐重新调用 startRealtimeTranscriber 接口覆盖转录任务后再停止转录任务。
     */
    virtual void startRealtimeTranscriber(const TranscriberParams& params) = 0;

    /**
     * 停止实时转录。
     *
     * 停止 AI 实时转录任务。
     * @param transcriberRobotId 转录机器人 ID。
     * @note 若在开启转录时未指定机器人 ID，则停止时可传入空字符串。
     */
    virtual void stopRealtimeTranscriber(const char* transcriberRobotId) = 0;

    /**
     * 暂停接收转录消息。
     *
     * 暂停接收后，SDK 将不再分发转录消息回调，但后台的转录任务依然正常进行，SDK 也会继续拉取转录数据。
     */
    virtual void pauseReceivingMessage() = 0;

    /**
     * 恢复接收转录消息。
     *
     * 恢复接收后，SDK 将继续分发转录消息回调。
     */
    virtual void resumeReceivingMessage() = 0;

    /**
     * 设置事件回调。
     *
     * 用于接收实时转录和翻译的事件通知。
     * 当房间内其他用户已经开启转录任务时，您只需设置事件回调即可接收到实时转录与翻译消息。
     * @param listener 转录事件监听器。
     */
    virtual void addListener(AITranscriberListener* listener) = 0;

    /**
     * 移除事件回调。
     *
     * 当所有监听器都被移除后，SDK 会停止接收转录通知。
     * @param listener 转录事件监听器。
     */
    virtual void removeListener(AITranscriberListener* listener) = 0;
};
}  // namespace liteav

#ifdef _WIN32
using namespace liteav;
#endif

#endif
