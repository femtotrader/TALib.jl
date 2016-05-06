#=

Constants, Enums for TA-Lib
inspired by https://github.com/stoni/ta-lib/blob/6edc8d665f145ca7eb19c6992191e0c4f0b61ec0/c/include/ta_defs.h

=#

@enum(RetCode, 
    TA_SUCCESS = 0,
    TA_LIB_NOT_INITIALIZE = 1,
    TA_BAD_PARAM = 2,
    TA_ALLOC_ERR = 3, 
    TA_GROUP_NOT_FOUND = 4,
    TA_FUNC_NOT_FOUND = 5,
    TA_INVALID_HANDLE = 6, 
    TA_INVALID_PARAM_HOLDER = 7,
    TA_INVALID_PARAM_HOLDER_TYPE = 8, 
    TA_INVALID_PARAM_FUNCTION = 9,
    TA_INPUT_NOT_ALL_INITIALIZE = 10, 
    TA_OUTPUT_NOT_ALL_INITIALIZE = 11,
    TA_OUT_OF_RANGE_START_INDEX = 12, 
    TA_OUT_OF_RANGE_END_INDEX = 13,
    TA_INVALID_LIST_TYPE = 14,
    TA_BAD_OBJECT = 15, 
    TA_NOT_SUPPORTED = 16,
    TA_INTERNAL_ERROR = 5000,
    TA_UNKNOWN_ERR = 0xFFFF
)

@enum(Compatibility, TA_COMPATIBILITY_DEFAULT = 0, TA_COMPATIBILITY_METASTOCK = 1)

@enum(MAType,
    TA_MAType_SMA = 0,
    TA_MAType_EMA = 1,
    TA_MAType_WMA = 2,
    TA_MAType_DEMA = 3,
    TA_MAType_TEMA = 4,
    TA_MAType_TRIMA = 5,
    TA_MAType_KAMA = 6,
    TA_MAType_MAMA = 7,
    TA_MAType_T3 = 8
)

@enum(FuncUnstId,
    TA_FUNC_UNST_ADX = 0,
    TA_FUNC_UNST_ADXR = 1,
    TA_FUNC_UNST_ATR = 2,
    TA_FUNC_UNST_CMO = 3,
    TA_FUNC_UNST_DX = 4,
    TA_FUNC_UNST_EMA = 5,
    TA_FUNC_UNST_HT_DCPERIOD = 6,
    TA_FUNC_UNST_HT_DCPHASE = 7,
    TA_FUNC_UNST_HD_PHASOR = 8,
    TA_FUNC_UNST_HT_SINE = 9,
    TA_FUNC_UNST_HT_TRENDLINE = 10,
    TA_FUNC_UNST_HT_TRENDMODE = 11,
    TA_FUNC_UNST_KAMA = 12,
    TA_FUNC_UNST_MAMA = 13,
    TA_FUNC_UNST_MFI = 14,
    TA_FUNC_UNST_MINUS_DI = 15,
    TA_FUNC_UNST_MINUS_DM = 16,
    TA_FUNC_UNST_NATR = 17,
    TA_FUNC_UNST_PLUS_DI = 18,
    TA_FUNC_UNST_PLUS_DM = 19,
    TA_FUNC_UNST_RSI = 20,
    TA_FUNC_UNST_STOCHRSI = 21,
    TA_FUNC_UNST_T3 = 22,
    TA_FUNC_UNST_ALL = 23,
    TA_FUNC_UNST_NONE = -1
)

@enum(RangeType,
    TA_RangeType_RealBody = 0,
    TA_RangeType_HighLow = 1,
    TA_RangeType_Shadows = 2
)

@enum(CandleSettingType,
    TA_BodyLong = 0,
    TA_BodyVeryLong = 1,
    TA_BodyShort = 2,
    TA_BodyDoji = 3,
    TA_ShadowLong = 4,
    TA_ShadowVeryLong = 5,
    TA_ShadowShort = 6,
    TA_ShadowVeryShort = 7,
    TA_Near = 8,
    TA_Far = 9,
    TA_Equal = 10,
    TA_AllCandleSettings = 11
)