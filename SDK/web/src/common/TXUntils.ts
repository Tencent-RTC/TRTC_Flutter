const sdkName = '<TRTC Wrapper>';
function getNowTime() {
  var date = new Date();
  var fmt = 'hh:mm:ss:S';
  var o = {
    'M+': date.getMonth() + 1, //月份
    'd+': date.getDate(), //日
    'h+': date.getHours(), //小时
    'm+': date.getMinutes(), //分
    's+': date.getSeconds(), //秒
    'q+': Math.floor((date.getMonth() + 3) / 3), //季度
    'S': date.getMilliseconds(), //毫秒
  };
  if (/(y+)/.test(fmt))
    fmt = fmt.replace(
      RegExp.$1,
      (date.getFullYear() + '').substr(4 - RegExp.$1.length)
    );
  for (var k in o)
    if (new RegExp('(' + k + ')').test(fmt))
      fmt = fmt.replace(
        RegExp.$1,
        // eslint-disable-next-line eqeqeq
        RegExp.$1.length == 1 ? o[k] : ('00' + o[k]).substr(('' + o[k]).length)
      );
  return fmt;
}
export function getFlutterArgs(_args, key: string) {
  try {
    return JSON.parse(_args)[key];
  } catch (ex) {
    logError(`_getFlutterArgs error _args: ${_args} ,key:${key}`);
  }
}
export function noSupportFunction(funName) {
  console.warn(`[${getNowTime()}] ${sdkName} web sdk not supper ${funName}`);
}
export function logSuccess(line) {
  console.info(
    `%c [${getNowTime()}] ${sdkName} ${line}`,
    'color:green;font-size:18px;'
  );
}
export function logInfo(line) {
  console.info(
    `%c [${getNowTime()}] ${sdkName} ${line}`,
    'font-size:18px;color:blue;'
  );
}
export function logError(line) {
  console.error(
    `%c [${getNowTime()}] ${sdkName} ${line}`,
    'color:red;font-size:18px'
  );
}
export function getVideoResolution(_videoResolution: Number): string {
  const line = `120*120 = 1;
  160*160 = 3;
  270*270 = 5;
  480*480 = 7;
  160*120 = 50;
  240*180 = 52;
  280*210 = 54;
  320*240 = 56;
  400*300 = 58;
  480*360 = 60;
  640*480 = 62;
  960*720 = 64;
  160*90 = 100;
  256*144 = 102;
  320*180 = 104;
  480*270 = 106;
  640*360 = 108;
  960*540 = 110;
  1280*720 = 112;
  1920*1080 = 114;`;
  const ls = line.split(';');
  let v = '360*360';
  ls.forEach((item) => {
    if (item.indexOf('=') >= 0 && item.endsWith(`= ${_videoResolution}`)) {
      v = item.split('=')[0].trim().replace(/\n/g, '');
      return v;
    }
  });
  return v;
}
