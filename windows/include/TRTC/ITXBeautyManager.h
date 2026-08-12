/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Module:   美颜与图像处理参数设置类
 * Function: 修改美颜、滤镜、绿幕等参数
 */
#ifndef __ITXBEAUTYMANAGER_H__
#define __ITXBEAUTYMANAGER_H__

#include <stdint.h>
#ifdef __APPLE__
#include <TargetConditionals.h>
#endif

namespace liteav {

/**
 * 图像信息
 */
struct TXImageBuffer {
    /// 图像存储的内容，一般为 BGRA 结构。
    const char* buffer;

    /// 图像数据的大小。
    uint32_t length;

    /// 图像的宽度。
    uint32_t width;

    /// 图像的高度。
    uint32_t height;

    TXImageBuffer() : buffer(nullptr), length(0), width(0), height(0) {
    }
};

/**
 * 美颜（磨皮）算法。
 *
 * TRTC 内置多种不同的磨皮算法，您可以选择最适合您产品定位的方案。
 */
enum TXBeautyStyle {

    /// 光滑，算法比较激进，磨皮效果比较明显，适用于秀场直播。
    TXBeautyStyleSmooth = 0,

    /// 自然，算法更多地保留了面部细节，磨皮效果更加自然，适用于绝大多数直播场景。
    TXBeautyStyleNature = 1,

    /// 优图，由优图实验室提供，磨皮效果介于光滑和自然之间，比光滑保留更多皮肤细节，比自然磨皮程度更高。
    TXBeautyStylePitu = 2
};

/////////////////////////////////////////////////////////////////////////////////
//
//                    美颜相关接口
//
/////////////////////////////////////////////////////////////////////////////////

class ITXBeautyManager {
   protected:
    ITXBeautyManager() {
    }
    virtual ~ITXBeautyManager() {
    }

   public:
    /**
     * 设置美颜（磨皮）算法。
     *
     * TRTC 内置多种不同的磨皮算法，您可以选择最适合您产品定位的方案：
     * @param beautyStyle 美颜风格，TXBeautyStyleSmooth：光滑；TXBeautyStyleNature：自然；TXBeautyStylePitu：优图。
     */
    virtual void setBeautyStyle(TXBeautyStyle beautyStyle) = 0;

    /**
     * 设置美颜级别。
     *
     * @param beautyLevel 美颜级别，取值范围 [0, 9]； 0 表示关闭，9 表示效果最明显。
     */
    virtual void setBeautyLevel(float beautyLevel) = 0;

    /**
     * 设置美白级别。
     *
     * @param whitenessLevel 美白级别，取值范围 [0, 9]；0 表示关闭，9 表示效果最明显。
     */
    virtual void setWhitenessLevel(float whitenessLevel) = 0;

    /**
     * 设置红润级别。
     *
     * @param ruddyLevel 红润级别，取值范围 [0, 9]；0 表示关闭，9 表示效果最明显。
     */
    virtual void setRuddyLevel(float ruddyLevel) = 0;

    /**
     * 设置色彩滤镜效果。
     *
     * 色彩滤镜，是一张包含色彩映射关系的颜色查找表图片，您可以在我们提供的官方 Demo 中找到预先准备好的几张滤镜图片。
     * SDK 会根据该查找表中的映射关系，对摄像头采集出的原始视频画面进行二次处理，以达到预期的滤镜效果。
     * @param image 包含色彩映射关系的颜色查找表图片，必须是 png 格式。
     */
    virtual void setFilter(TXImageBuffer* image) = 0;

    /**
     * 设置色彩滤镜的强度。
     *
     * 该数值越高，色彩滤镜的作用强度越明显，经过滤镜处理后的视频画面跟原画面的颜色差异越大。
     * 默认的滤镜浓度为 0.5，如果您觉得默认的滤镜效果不明显，可以设置为 0.5 以上的数字，最大值为 1。
     * @param strength 取值范围 [0, 1]，数值越大滤镜效果越明显，默认值为 0.5。
     */
    virtual void setFilterStrength(float strength) = 0;
};
}  // namespace liteav
#ifdef _WIN32
using namespace liteav;
#endif
#endif
