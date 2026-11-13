/**
 * Navigation Watch App - Entry Point
 * Ứng dụng dẫn đường trên Huawei Watch GT 3 SE
 * 
 * App lifecycle: onCreate → onShow → onHide → onDestroy
 */

export default {
  /**
   * Khởi tạo ứng dụng
   * Chạy khi app được tạo lần đầu
   */
  onCreate() {
    console.info('[NavApp] Application onCreate');

    // Trạng thái kết nối toàn cục
    this.connectionStatus = 'disconnected';

    // Dữ liệu navigation hiện tại
    this.currentNavData = null;
  },

  /**
   * App hiển thị trên màn hình
   */
  onShow() {
    console.info('[NavApp] Application onShow');
  },

  /**
   * App bị ẩn (chạy nền)
   */
  onHide() {
    console.info('[NavApp] Application onHide');
  },

  /**
   * Hủy ứng dụng
   */
  onDestroy() {
    console.info('[NavApp] Application onDestroy');
    this.currentNavData = null;
    this.connectionStatus = 'disconnected';
  }
};
