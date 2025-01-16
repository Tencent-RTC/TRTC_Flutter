const path = require('path');
const packageInfo = require('./package.json');
module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';
  return {
    entry: {
      TrtcWrapper: './src/TrtcWrapper.ts',
      JsGenerateTestUserSig: './src/JsGenerateTestUserSig.ts',
      // BeautyManagerWrapper: './src/BeautyManagerWrapper.ts',
    },
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
      ],
    },
    resolve: {
      extensions: ['.tsx', '.ts', '.js'],
    },
    devServer: {
      // 端口，默认8080
      port: '8099',
      // 进度条
      progress: true,
      // 启动后访问目录，默认是项目根目录，这个设置到打包后目录
      contentBase: './build',
      // 启动压缩
      //compress: true
    },
    watch: true,
    watchOptions: {
      poll: 1000,
      aggregateTimeout: 500,
      ignored: /node_modules/,
    },
    output: {
      filename: '[name].' + packageInfo.version + '.bundle.js',
      library: '[name]',
      libraryTarget: 'umd',
      libraryExport: 'default',
      path: isDevelopment
        ? path.resolve(__dirname, '../example/web')
        : path.resolve(__dirname, 'dist'),
    },
  };
};
