//接口返回的code 12位，？？
class AddressUtil {
  /**
   * adcode 转化为 省code
   */
  static String getProvinceCode(String adCode) =>
      (adCode.substring(0, 2) + '0000' + '000000');

  /**
   * adcode 转化为 市code
   */
  static String getCityCode(String adCode) =>
      (adCode.substring(0, 4) + '00' + '000000');

  /**
   * adcode 转化为 区code
   */
  static String getDistrictCode(String adCode) => (adCode + '000000');
}
