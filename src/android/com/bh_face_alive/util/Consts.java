package com.bh_face_alive.util;

public class Consts {
	public final static String SWITCH_CAMERA = "swith_camera";

	// 已打开的摄像头id
	public static int mOpenCameraId = -1;

	// 打开文件
	public static boolean OPEN_FILE = false;

	public static String license_url;

	public static String license_port;

	// 通知窗口关闭
	public static final String ACTIVITY_FINISH = "activity_finish";

	public static final boolean IS_FIRST = true;

	public static final boolean IS_FIRST_REGISTER = true;
	// 默认语音验证准确率
	// 默认人脸离开时间
	// 默认最后一次张嘴时间
	/**
	 * 工行服务器备份
	 */
	// // 默认license地址--外网
	// public static final String LICENSE_URL = "122.18.61.153";
	// // 默认license端口--外网
	// public static final int LICENSE_PORT = 30052;
	// // 默认提交地址--外网
	// public static final String SUBMIT_URL = "122.18.61.153";
	// // 默认提交地址端口--外网
	// public static final int SUBMIT_PORT = 7001;

	/**
	 * 博宏服务器备份
	 */
	// public static final String LICENSE_URL = "172.16.8.85";
	// public static final String LICENSE_URL = "192.168.205.128";
	// 默认license端口--外网
	// public static final int LICENSE_PORT = 7001;
	// 默认提交地址--外网
	// public static final String SUBMIT_URL = "172.16.8.85";
	// public static final String SUBMIT_URL = "192.168.205.128";
	public static final String SUBMIT_URL = "52.26.98.143";
	// public static final String SUBMIT_URL = "120.24.222.237";
	// 默认提交地址端口--外网
	// public static final int SUBMIT_PORT = 7001;
	public static final int SUBMIT_PORT = 7001;

	public static final String SUBMIT_CHANNEL = "C00";

	// 默认的声音开关
	public static final boolean SY_SWITCH = true;
	// 默认摇头
	// 默认张嘴
	public static final boolean OPEN_MOUTH = true;
	// 默认眨眼
	public static final boolean BLINK_EYES = true;

	public static final boolean DOWN_PITCH = true;

	public static final boolean OPEN_YAW = true;

	public static boolean ILLEGAL = false;

	public final static String ID = "ID";
	public final static String ALIVE_TYPE = "ALIVE_TYPE";
	public final static int REGISTER_TYPE = 1;

	public final static int SEARCH_TYPE = 2;

	public final static int AUTHENITCATION_TYPE = 3;

	/**
	 * 摇头语音提示时间
	 */
	public static int HEAD_TIME = 6000;
	/**
	 * 提示拍照语音提示
	 */
	public static int TAKING_TIME = 8000;
	/**
	 * 没有设置活体检测
	 */
	public static int CLOSE_TIME = 5000;
	/**
	 * 拍照不成功
	 */
	public static int PHOTO_ERROR = 6000;

	/**
	 * 提示验证开始
	 */
	public static int START_ALIVE = 6500;
	/**
	 * 眨眼语音提示时间
	 */
	public static int EYE_TIME = 1500;
	/**
	 * 张嘴语音提示时间
	 */
	public static int MOUTH_TIME = 1500;
	/**
	 * 三秒后没有提交成功 重复提醒
	 */
	public static int PLAYE_REPEAT_ALIVE = 6000;
	/**
	 * 播放语音提示
	 */
	public static int PLAYE_ALIVE = 1000;

	// 默认的抓拍张数
	public static final int ZPZS = 1;

	public static final String ADDRESS_UPDATEAPK = "";

	// public static final String ADDRESS_VERSION =
	// "http://192.168.1168.173:8081/KFwebService/face/";
	public static final String ADDRESS_VERSION = "http://rz.kfsbj.cn:8081/face/";
	// http://192.168.1.103:8080/KFwebService/face/getVersion.action?param={"version":"121",
	// "type": 5}
	public static final String ACTIONNAME = "getVersion.action";

}
