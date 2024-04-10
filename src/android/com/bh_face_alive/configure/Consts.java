package com.bh_face_alive.configure;

public class Consts {
	// 已打开的摄像头id
	public static int mOpenCameraId = -1;

	// 通知窗口关闭
	public static final String ACTIVITY_FINISH = "activity_finish";

	public static boolean alive = false;

	// plugin和alive activity之间传递参数
	public static final String TYPE = "type";

	// plugn和alive activity之间传递参数，需要加载的html页面地址
	public static final String URL = "url";

	// 客户自定义的视屏区的宽高
	public static final String SCREEN_TOP = "screen_top";
	public static final String SCREEN_HEIGHT = "screen_height";

	/**
	 * 播放验证开始
	 */
	public static final int PLAY_UI_ALIVE_START = 1;

	// 动作摇晃幅度过大
	public static final int RANGE_OVER_SIZE = 2;

	// 活体检测初始化成功
	public static final int INIT_ALIVE_SUCCESS = 3;

}
