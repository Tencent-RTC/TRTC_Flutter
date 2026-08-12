// ignore_for_file: constant_identifier_names

typedef V2TXLiveCode = int;

/// Success
const V2TXLiveCode V2TXLIVE_OK = 0;

/// A generic error that has not yet been classified
const V2TXLiveCode V2TXLIVE_ERROR_FAILED = -1;

/// The parameter is invalid
const V2TXLiveCode V2TXLIVE_ERROR_INVALID_PARAMETER = -2;

/// The API call was rejected
const V2TXLiveCode V2TXLIVE_ERROR_REFUSED = -3;

/// The current API does not support calls
const V2TXLiveCode V2TXLIVE_ERROR_NOT_SUPPORTED = -4;

/// The license is invalid and the call failed
const V2TXLiveCode V2TXLIVE_ERROR_INVALID_LICENSE = -5;

/// The request server timed out
const V2TXLiveCode V2TXLIVE_ERROR_REQUEST_TIMEOUT = -6;

/// The server is unable to process your request
const V2TXLiveCode V2TXLIVE_ERROR_SERVER_PROCESS_FAILED = -7;

/// The connection is lost
const V2TXLiveCode V2TXLIVE_ERROR_DISCONNECTED = -8;

// ///////////////////////////////////////////////////////////////////////////////
//
//      Network-related warning codes
//
// ///////////////////////////////////////////////////////////////////////////////

/// Poor network conditions: The uplink bandwidth is too small and the upload data is blocked
const V2TXLiveCode V2TXLIVE_WARNING_NETWORK_BUSY = 1101;

/// The current video is playing stuttering
const V2TXLiveCode V2TXLIVE_WARNING_VIDEO_BLOCK = 2105;

// ///////////////////////////////////////////////////////////////////////////////
//
//            Camera-related warning codes
//
// ///////////////////////////////////////////////////////////////////////////////

/// The camera failed to turn on
const V2TXLiveCode V2TXLIVE_WARNING_CAMERA_START_FAILED = -1301;

/// The camera is occupied, try turning on a different camera
const V2TXLiveCode V2TXLIVE_WARNING_CAMERA_OCCUPIED = -1316;

///  The camera device is not authorized, usually on mobile devices, and it may be that the permission has been denied by the user
const V2TXLiveCode V2TXLIVE_WARNING_CAMERA_NO_PERMISSION = -1314;

// ///////////////////////////////////////////////////////////////////////////////
//
//             Microphone-related warning codes
//
// ///////////////////////////////////////////////////////////////////////////////

/// The microphone failed to turn on
const V2TXLiveCode V2TXLIVE_WARNING_MICROPHONE_START_FAILED = -1302;

/// The microphone is being occupied, such as when a mobile device is on a call, and turning on the microphone fails
const V2TXLiveCode V2TXLIVE_WARNING_MICROPHONE_OCCUPIED = -1319;

/// The microphone device is not authorized, usually on mobile devices, and it may be that the permission has been denied by the user
const V2TXLiveCode V2TXLIVE_WARNING_MICROPHONE_NO_PERMISSION = -1317;

// ///////////////////////////////////////////////////////////////////////////////
//
//            Warning codes related to screen sharing
//
// ///////////////////////////////////////////////////////////////////////////////

/// The current system does not support screen sharing
const V2TXLiveCode V2TXLIVE_WARNING_SCREEN_CAPTURE_NOT_SUPPORTED = -1309;

/// If it fails to start screen recording, if it appears on a mobile device, it may be that the permission has been denied by the user
const V2TXLiveCode V2TXLIVE_WARNING_SCREEN_CAPTURE_START_FAILED = -1308;

/// The screen recording is interrupted by the system
const V2TXLiveCode V2TXLIVE_WARNING_SCREEN_CAPTURE_INTERRUPTED = -7001;
