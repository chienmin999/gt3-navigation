/**
 * Waiting Page - Màn hình chờ kết nối
 * Hiển thị animation khi chưa nhận được data từ phone
 * Tự động chuyển sang trang navigation khi nhận được dữ liệu
 */

import router from '@system.router';

// Khoảng thời gian animation dots (ms)
const DOT_INTERVAL = 500;

export default {
  data: {
    // Tiêu đề trạng thái
    statusTitle: 'Đang chờ điện thoại',
    // Phụ đề hướng dẫn
    statusSubtitle: 'Mở ứng dụng dẫn đường trên điện thoại',
    // Trạng thái các dot animation
    dot1Class: 'dot-active',
    dot2Class: '',
    dot3Class: '',
    // Hiển thị nút retry khi mất kết nối
    showRetry: false,
    // Biến nội bộ
    _dotTimer: null,
    _currentDot: 0,
    _messageListener: null
  },

  /**
   * Khởi tạo trang
   * Bắt đầu animation và lắng nghe message từ phone
   */
  onInit() {
    console.info('[Waiting] Page initialized');
  },

  /**
   * Trang hiển thị trên màn hình
   */
  onShow() {
    console.info('[Waiting] Page shown');
    // Bắt đầu animation dots
    this.startDotAnimation();
    // Bắt đầu lắng nghe P2P message
    this.startListening();
  },

  /**
   * Trang bị ẩn
   */
  onHide() {
    console.info('[Waiting] Page hidden');
    this.stopDotAnimation();
  },

  /**
   * Hủy trang
   */
  onDestroy() {
    console.info('[Waiting] Page destroyed');
    this.stopDotAnimation();
    this.stopListening();
  },

  /**
   * Animation dots nhấp nháy
   * Tạo hiệu ứng loading bằng cách đổi class cho 3 dots
   */
  startDotAnimation() {
    this.stopDotAnimation(); // Dừng timer cũ nếu có
    this._currentDot = 0;

    this._dotTimer = setInterval(() => {
      this._currentDot = (this._currentDot + 1) % 3;
      this.isDot1Active = (this._currentDot === 0);
      this.isDot2Active = (this._currentDot === 1);
      this.isDot3Active = (this._currentDot === 2);
    }, DOT_INTERVAL);
  },

  /**
   * Dừng animation dots
   */
  stopDotAnimation() {
    if (this._dotTimer) {
      clearInterval(this._dotTimer);
      this._dotTimer = null;
    }
  },

  /**
   * Bắt đầu lắng nghe P2P messages từ phone companion
   * Sử dụng Wear Engine lite wearable messaging
   */
  startListening() {
    try {
      // Đăng ký listener cho P2P messages từ phone
      // Trên Lite Wearable, message được nhận qua app global event
      // hoặc qua @system.fetch polling endpoint
      const app = getApp();
      
      // Đăng ký callback xử lý message
      app._onP2PMessage = (messageData) => {
        this.handleMessage(messageData);
      };

      console.info('[Waiting] P2P listener registered');
    } catch (error) {
      console.error('[Waiting] Failed to start listening: ' + JSON.stringify(error));
      this.showDisconnected();
    }
  },

  /**
   * Dừng lắng nghe
   */
  stopListening() {
    try {
      const app = getApp();
      app._onP2PMessage = null;
    } catch (error) {
      console.error('[Waiting] Failed to stop listening: ' + error);
    }
  },

  /**
   * Xử lý message nhận được từ phone
   * @param {Object} data - JSON message từ phone companion
   */
  handleMessage(data) {
    if (!data || !data.type) {
      console.warn('[Waiting] Received invalid message');
      return;
    }

    switch (data.type) {
      case 'connection':
        this.handleConnectionStatus(data);
        break;

      case 'nav_update':
        // Nhận được dữ liệu navigation → chuyển sang trang chính
        console.info('[Waiting] Received nav data, switching to index');
        this.navigateToIndex(data);
        break;

      default:
        console.warn('[Waiting] Unknown message type: ' + data.type);
    }
  },

  /**
   * Xử lý thay đổi trạng thái kết nối
   * @param {Object} data - { type: "connection", status: "connected"|"disconnected" }
   */
  handleConnectionStatus(data) {
    const status = data.status || 'disconnected';
    console.info('[Waiting] Connection status: ' + status);

    if (status === 'connected') {
      this.statusTitle = 'Đã kết nối';
      this.statusSubtitle = 'Đang chờ dữ liệu dẫn đường...';
      this.showRetry = false;
    } else {
      this.showDisconnected();
    }
  },

  /**
   * Hiển thị trạng thái mất kết nối
   */
  showDisconnected() {
    this.statusTitle = 'Mất kết nối';
    this.statusSubtitle = 'Kiểm tra kết nối điện thoại';
    this.showRetry = true;
  },

  /**
   * Chuyển sang trang navigation chính
   * @param {Object} navData - Dữ liệu navigation đầu tiên
   */
  navigateToIndex(navData) {
    // Lưu data vào app global để trang index đọc
    const app = getApp();
    app.currentNavData = navData;
    app.connectionStatus = 'connected';

    router.replace({
      uri: 'pages/index/index'
    });
  },

  /**
   * Xử lý khi người dùng nhấn nút "Thử lại"
   */
  onRetryClick() {
    console.info('[Waiting] Retry connection');
    this.statusTitle = 'Đang kết nối...';
    this.statusSubtitle = 'Mở ứng dụng dẫn đường trên điện thoại';
    this.showRetry = false;
    // Thử kết nối lại
    this.startListening();
  }
};
