package com.tencent.trtcplugin.utils;

import android.Manifest;
import android.content.Context;
import java.util.Arrays;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Environment;

import androidx.core.content.ContextCompat;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Locale;
import java.util.UUID;

public class ImageIO {

    public static class SaveResult {
        public int code;
        public String message;
        public String path;

        SaveResult(int code, String message, String path) {
            this.code = code;
            this.message = message;
            this.path = path;
        };  // CHECKSTYLE:SUPPRESS EmptyLineSeparator
    }

    public static SaveResult save(Context context, Bitmap bitmap, String fullPath) {
        if (bitmap == null || bitmap.isRecycled()) {
            TRTCLogger.e("BitmapSaver | invalid bitmap");
            return new SaveResult(Constants.INVALID_PARAMETER, "invalid bitmap", "");
        }

        File targetFile;
        try {
            if (fullPath == null || fullPath.isEmpty()) {
                targetFile = generateDefaultFile(context, bitmap);
                TRTCLogger.i("BitmapSaver | generated default file path: " + targetFile.getPath());
            } else {
                targetFile = new File(fullPath);
                TRTCLogger.i("BitmapSaver | using provided file path: " + fullPath);
            }
        } catch (Exception e) {
            TRTCLogger.e("BitmapSaver | invalid path: " + fullPath + " | error: " + e);
            return new SaveResult(Constants.INVALID_PARAMETER, "invalid path: " + fullPath, "");
        }

        if (!isPathSafe(targetFile)) {
            TRTCLogger.e("BitmapSaver | invalid path (unsafe): " + fullPath);
            return new SaveResult(Constants.INVALID_PARAMETER, "invalid path: " + fullPath, "");
        }

        if (!checkPathPermission(context, targetFile, true)) {
            TRTCLogger.e("BitmapSaver | permission denied for path: " + fullPath);
            return new SaveResult(Constants.PERMISSION_DENIED, "permission denied", "");
        }

        if (isPublicPath(targetFile) && !isStorageMounted()) {
            TRTCLogger.e("BitmapSaver | storage unmounted for path: " + fullPath);
            return new SaveResult(Constants.STORAGE_UNMOUNTED, "storage unmounted", "");
        }

        if (targetFile.exists()) {
            TRTCLogger.e("BitmapSaver | file already exists: " + fullPath);
            return new SaveResult(Constants.FILE_ALREADY_EXISTS, "file already exists: " + fullPath, "");
        }

        if (!prepareParentDirectory(targetFile)) {
            TRTCLogger.e("BitmapSaver | parent directory create failed: " + fullPath);
            return new SaveResult(Constants.PARENT_DIR_CREATE_FAIL, "parent directory create failed: " + fullPath, "");
        }

        Bitmap.CompressFormat format = parseCompressFormat(targetFile);
        if (format == null) {
            TRTCLogger.e("BitmapSaver | unsupported file format, please use .jpg or .png");
            return new SaveResult(Constants.UNSUPPORTED_FORMAT, "unsupported file format, please use .jpg or .png", "");
        }

        try (FileOutputStream fos = new FileOutputStream(targetFile)) {
            int quality = (format == Bitmap.CompressFormat.JPEG) ? 90 : 100;
            bitmap.compress(format, quality, fos);
            fos.flush();
            TRTCLogger.i("BitmapSaver | file saved successfully: " + targetFile.getPath());
            return new SaveResult(Constants.SUCCESS, "success", targetFile.getPath());
        } catch (IOException e) {
            TRTCLogger.e("BitmapSaver | IO error: " + e);
            return new SaveResult(Constants.IO_ERROR, "IO error: " + e, "");
        }
    }

    public static Bitmap loadBitmapFromFile(Context context, String filePath) {
        if (filePath == null || filePath.isEmpty()) {
            TRTCLogger.e("BitmapSaver | invalid file path");
            return null;
        }

        File file = new File(filePath);
        if (!file.exists()) {
            TRTCLogger.e("BitmapSaver | file not found: " + filePath);
            return null;
        }

        String name = file.getName().toLowerCase(Locale.US);
        if (!name.endsWith(".png") && !name.endsWith(".jpg") && !name.endsWith(".jpeg")) {
            TRTCLogger.e("BitmapSaver | unsupported file format, please use .jpg or .png");
            return null;
        }

        if (!checkPathPermission(context, file, false)) {
            TRTCLogger.e("BitmapSaver | permission denied for path: " + filePath);
            return null;
        }

        try {
            Bitmap bitmap = BitmapFactory.decodeFile(filePath);
            if (bitmap == null) {
                TRTCLogger.e("BitmapSaver | failed to decode bitmap");
            }
            return bitmap;
        } catch (Exception e) {
            TRTCLogger.e("BitmapSaver | IO error: " + e.getMessage());
            return null;
        }
    }

    private static File generateDefaultFile(Context context, Bitmap bitmap) {
        File dir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        String fileName = UUID.randomUUID().toString() + ".jpg";
        return new File(dir, fileName);
    }

    private static boolean isPathSafe(File file) {
        try {
            return file.getCanonicalPath().equals(file.getAbsolutePath());
        } catch (IOException e) {
            return false;
        }
    }

    private static boolean isStorageMounted() {
        return Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState());
    }

    private static boolean prepareParentDirectory(File file) {
        File parent = file.getParentFile();
        return parent != null && (parent.exists() || parent.mkdirs());
    }

    private static Bitmap.CompressFormat parseCompressFormat(File file) {
        String name = file.getName().toLowerCase(Locale.US);
        if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
            return Bitmap.CompressFormat.JPEG;
        } else if (name.endsWith(".png")) {
            return Bitmap.CompressFormat.PNG;
        }
        return null;
    }

    public static boolean checkPathPermission(Context context, File file, boolean isWriteOperation) {
        if (file == null) {
            return false;
        }
        String filePath = file.getAbsolutePath();

        if (isAppPrivatePath(context, file)) {
            return true;
        }

        if (isExternalAppSpecificPath(context, file)) {
            return true;
        }

        if (isPublicPath(file)) {
            return checkPublicStoragePermission(context, isWriteOperation);
        }

        return false;
    }

    private static boolean isAppPrivatePath(Context context, File file) {
        File[] privateDirs = {
                context.getFilesDir().getParentFile(),
                context.getCacheDir(),
                context.getCodeCacheDir(),
                context.getNoBackupFilesDir()
        };

        return Arrays.stream(privateDirs)
                .filter(dir -> dir != null && file.getAbsolutePath().startsWith(dir.getAbsolutePath()))
                .findAny()
                .isPresent();
    }

    private static boolean isExternalAppSpecificPath(Context context, File file) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            return false;
        }

        File[] appSpecificDirs = {
                context.getExternalFilesDir(null),
                context.getExternalCacheDir(),
                context.getExternalMediaDirs().length > 0 ?  // CHECKSTYLE:SUPPRESS OperatorWrap
                        context.getExternalMediaDirs()[0] : null
        };

        return Arrays.stream(appSpecificDirs)
                .filter(dir -> dir != null && file.getAbsolutePath().startsWith(dir.getAbsolutePath()))
                .findAny()
                .isPresent();
    }

    private static boolean isPublicPath(File file) {
        File[] publicDirs = {
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM),
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
                Environment.getExternalStorageDirectory()
        };

        return Arrays.stream(publicDirs)
                .filter(dir -> dir != null && file.getAbsolutePath().startsWith(dir.getAbsolutePath()))
                .findAny()
                .isPresent();
    }

    private static boolean checkPublicStoragePermission(Context context, boolean isWriteOperation) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return checkScopedStoragePermission(context, isWriteOperation);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return checkLegacyStoragePermission(context, isWriteOperation);
        }

        return true;
    }

    private static boolean checkLegacyStoragePermission(Context context, boolean isWriteOperation) {
        int readPermission = ContextCompat.checkSelfPermission(
                context, Manifest.permission.READ_EXTERNAL_STORAGE);

        if (!isWriteOperation) {
            return readPermission == android.content.pm.PackageManager.PERMISSION_GRANTED;
        }

        int writePermission = ContextCompat.checkSelfPermission(
                context, Manifest.permission.WRITE_EXTERNAL_STORAGE);

        return readPermission == android.content.pm.PackageManager.PERMISSION_GRANTED
                && writePermission == android.content.pm.PackageManager.PERMISSION_GRANTED;
    }

    @androidx.annotation.RequiresApi(api = Build.VERSION_CODES.R)
    private static boolean checkScopedStoragePermission(Context context, boolean isWriteOperation) {
        if (!isWriteOperation) {
            return true;
        }

        return Environment.isExternalStorageManager();
    }

    public static boolean isExternalStorageManager(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return Environment.isExternalStorageManager();
        }
        return false;
    }
}