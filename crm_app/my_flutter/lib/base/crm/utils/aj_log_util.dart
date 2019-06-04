class AJLogUtil {
  static const String _TAG_DEF = "###AJLogUtil###";
  static const int _strLength  = 250;
  static bool debuggable = true; //是否是debug模式,true: log v 不输出.
  static String TAG = _TAG_DEF;

  static void init({bool isDebug = false, String tag = _TAG_DEF}) {
    debuggable = isDebug;
    TAG = tag;
  }

  static void e(Object object, {String tag}) {
    _printLog(tag, '  e  ', object);
  }

  static void v(Object object, {String tag}) {
    if (debuggable) {
      _printLog(tag, '  v  ', object);
    }
  }

  static void _printLog(String tag, String stag, Object object) {
    if(object.toString().length > _strLength){
      StringBuffer sb = _stringBuffer(tag, stag, object);
      _stringInterception(sb);
    } else {
      StringBuffer sb = _stringBuffer(tag, stag, object);
      print(sb.toString());
    }

  }

  static void _stringInterception(Object object){
    String str = object.toString();
    String str1 = str.substring(0, _strLength);
    String str2 = str.substring(_strLength);
    if(str2.length > _strLength){
      print(str1);
      _stringInterception(str2);
    } else {
      print(str1);
      print(str2);
    }
  }

  /// 转化 StringBuffer
  static StringBuffer _stringBuffer(String tag, String stag, Object object) {
    StringBuffer sb = new StringBuffer();
    sb.write((tag == null || tag.isEmpty) ? TAG : tag);
    sb.write(stag);
    sb.write(object);
    return sb;
  }




}
