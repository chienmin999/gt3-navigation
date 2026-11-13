/**
 * Compass Page - Trang la bàn
 * Hiển thị hướng la bàn đơn giản sử dụng sensor
 * Dùng @system.sensor để đọc dữ liệu từ cảm biến từ trường
 */

import sensor from '@system.sensor';

/**
 * Chuyển đổi góc heading sang tên hướng
 * @param {number} degrees - Góc 0-360
 * @returns {string} - Tên hướng (B, ĐB, Đ, ĐN, N, TN, T, TB)
 */
function degreesToDirection(degrees) {
  // Xử lý giá trị không hợp lệ
  if (degrees === null || degrees === undefined || isNaN(degrees)) {
    return '--';
  }

  // Chuẩn hóa về 0-360
  const normalized = ((degrees % 360) + 360) % 360;

  // 8 hướng, mỗi hướng 45°
  const directions = ['B', 'ĐB', 'Đ', 'ĐN', 'N', 'TN', 'T', 'TB'];
  const index = Math.round(normalized / 45) % 8;
  return directions[index];
}

export default {
  data: {
    // Góc xoay kim la bàn (CSS transform rotation)
    needleRotation: 0,
    // Số độ heading hiển thị
    headingDegrees: 0,
    // Nhãn hướng (B, ĐB, Đ, ĐN, N, TN, T, TB)
    headingDirection: '--',
    // Ghi chú trạng thái
    compassNote: 'Giữ đồng hồ ngang để đo chính xác',
    // Biến nội bộ
    _sensorSubscribed: false
  },

  /**
   * Khởi tạo trang
   */
  onInit() {
    console.info('[Compass] Page initialized');
  },

  /**
   * Trang hiển thị - bắt đầu đọc sensor
   */
  onShow() {
    console.info('[Compass] Page shown');
    this.subscribeSensor();
  },

  /**
   * Trang bị ẩn - dừng đọc sensor để tiết kiệm pin
   */
  onHide() {
    console.info('[Compass] Page hidden');
    this.unsubscribeSensor();
  },

  /**
   * Hủy trang
   */
  onDestroy() {
    console.info('[Compass] Page destroyed');
    this.unsubscribeSensor();
  },

  /**
   * Đăng ký lắng nghe cảm biến la bàn (compass/orientation)
   * Sử dụng @system.sensor API của HarmonyOS Lite
   */
  subscribeSensor() {
    if (this._sensorSubscribed) {
      return;
    }

    try {
      sensor.subscribeCompass({
        /**
         * Callback khi có dữ liệu mới từ compass sensor
         * @param {Object} data - { direction: number } - Góc heading 0-360
         */
        success: (data) => {
          this.updateCompass(data.direction);
        },
        fail: (data, code) => {
          console.error('[Compass] Sensor subscribe failed: code=' + code);
          this.compassNote = 'Lỗi cảm biến la bàn (mã: ' + code + ')';
        }
      });

      this._sensorSubscribed = true;
      console.info('[Compass] Sensor subscribed');
    } catch (error) {
      console.error('[Compass] Sensor error: ' + JSON.stringify(error));
      this.compassNote = 'Không thể truy cập cảm biến la bàn';
      // Hiển thị giá trị mặc định
      this.headingDegrees = 0;
      this.headingDirection = 'B';
    }
  },

  /**
   * Hủy đăng ký cảm biến
   */
  unsubscribeSensor() {
    if (!this._sensorSubscribed) {
      return;
    }

    try {
      sensor.unsubscribeCompass();
      this._sensorSubscribed = false;
      console.info('[Compass] Sensor unsubscribed');
    } catch (error) {
      console.error('[Compass] Unsubscribe error: ' + JSON.stringify(error));
    }
  },

  /**
   * Cập nhật hiển thị la bàn
   * @param {number} direction - Góc heading từ sensor (0-360, 0 = Bắc)
   */
  updateCompass(direction) {
    // Kiểm tra giá trị hợp lệ
    if (direction === null || direction === undefined || isNaN(direction)) {
      return;
    }

    // Làm tròn góc
    const degrees = Math.round(direction);

    // Cập nhật hiển thị
    this.headingDegrees = degrees;

    // Kim la bàn xoay ngược hướng heading
    // Để đầu kim Bắc luôn chỉ về Bắc thực tế
    this.needleRotation = -degrees;

    // Cập nhật nhãn hướng
    this.headingDirection = degreesToDirection(degrees);
  }
};
