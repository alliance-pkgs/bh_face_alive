package com.bh_face_alive.util;

import java.io.File;

import android.content.Context;
import android.os.Environment;
import android.os.StatFs;
import android.util.Log;

/**
 * SD卡相关的辅助类
 * 
 * @author Tailyou
 * 
 */
public class SDCardUtils {
	private SDCardUtils() {
		/* cannot be instantiated */
		throw new UnsupportedOperationException("cannot be instantiated");
	}

	/**
	 * 删除指定路径下的文件
	 */
	public static boolean deleteFile(String path) {
		File file = new File(path);
		if (file.exists()) {
			Log.d("File exist?", "true");
			return file.delete();
		}
		Log.d("File exist?", "false.");
		return false;
	}

}
