# TrtcWrapper

TrtcWrapper 是基于 `trtc-js-sdk` 、 `rtc-beauty-plugin` 、`trtc-audio-mixer` 的包装库，该包装库主要是为了给 **flutter**调用，我们将其开源以便开发者定位和排查问题。


## 编译产物
- `dist/TrtcWrapper.[version].bundle.js` 该产物为TRTC的基础产物，trtc flutter for web必须引入
- `dist/BeautyManagerWrapper.[verion].bundle.js` 该产物为TRTC的基础美颜功能。用户可以调整美颜参数，实现自然的美颜效果。
- `dist/JSGenerateTestUserSig.[version].bundle.js`该产物为计算签名用的加密密钥，仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
## flutter 引入
需要在您的 `index.html` 中添加引用，可以参考 [web/index.html](web/index.html) 。

```html
<script src="TrtcWrapper.[version].bundle.js" type="application/javascript"></script>
<!-- 如没有用到美颜相关功能，可不引入该js -->
<script src="BeautyManagerWrapper.[version].bundle.js" type="application/javascript"></script>
<!-- 如没有用到本地计算加密密钥，可不引入该js -->
<script src="JSGenerateTestUserSig.[version].bundle.js" type="application/javascript"></script>
```

## Build

Use npm

```
npm install
npm run build
```

