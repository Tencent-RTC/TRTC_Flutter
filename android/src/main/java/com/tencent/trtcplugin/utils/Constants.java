package com.tencent.trtcplugin.utils;

public class Constants {
    public static final int SUCCESS = 0;

    //region Common Errors (-6000~6099)
    public static final int INVALID_PARAMETER    = -6001;
    public static final int PERMISSION_DENIED    = -6002;

    //region File system errors (-6100~6199)
    public static final int FILE_NOT_EXIST         = -6101;
    public static final int IS_DIRECTORY           = -6102;
    public static final int FILE_ALREADY_EXISTS    = -6103;
    public static final int STORAGE_UNMOUNTED      = -6104;
    public static final int PARENT_DIR_CREATE_FAIL = -6105;
    public static final int IO_ERROR               = -6106;
    //endregion

    //region Data validation errors (-6200~6299)
    public static final int EMPTY_DATA           = -6201;
    public static final int INVALID_IMAGE_DATA  = -6202;
    public static final int ZERO_SIZE_IMAGE     = -6203;
    public static final int UNSUPPORTED_FORMAT   = -6204;
    //endregion
}
