package com.bh_face_alive.util;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.util.Log;

/**
 * 图像处理 com.bh_face_alive.CameraUtils.ImageHelper
 * 
 * @author 姚述智 <br/>
 *         create at 2016-1-18 上午10:55:26
 */
public class ImageHelper {

	/**
	 * 根据图片需要旋转的角度进行图片旋转
	 * 
	 * @param yuv420sp
	 *            图片数据
	 * @param width
	 * @param height
	 * @param angle
	 *            需要旋转的角度 只支持 90度 180度 270度
	 * @return
	 */
	public static byte[] rotateYUV420sp(byte[] yuv420sp, int width, int height, int angle) {
		switch (angle) {
		case 0:
			return yuv420sp;
		case 90:
			return rotate90YUV420SP(yuv420sp, width, height);
		case 180:
			return rotate180YUV420SP(yuv420sp, width, height);
		case 270:
			return rotate270YUV420SP(yuv420sp, width, height);
		}
		return yuv420sp;
	}

	/**
	 * 顺时针旋转270.
	 * 
	 * @param yuv420sp
	 * @param width
	 * @param height
	 * @return
	 */
	public static byte[] rotate270YUV420SP(byte[] yuv420sp, int width, int height) {
		byte[] des = new byte[yuv420sp.length];
		int wh = width * height;
		// 旋转Y
		// b[w-j-1,i] = a[i,j]
		// => b[i,j] = a[j,w - i - 1]
		// j*w+w-i-1
		int k = 0;
		for (int i = 0; i < width; i++) {
			for (int j = 0; j < height; j++) {
				des[k] = yuv420sp[width * j + width - i - 1];
				k++;
			}
		}

		// b[w-j-1,i] = a[i,j]
		// => b[i,j] = a[j,w - i - 1]
		for (int i = 0; i < width; i += 2) {
			for (int j = 0; j < height / 2; j++) {
				des[k] = yuv420sp[wh + width * j + width - i - 2];
				des[k + 1] = yuv420sp[wh + width * j + width - i - 1];
				k += 2;
			}
		}
		return des;
	}

	/**
	 * 顺时针旋转90.
	 * 
	 * @param yuv420sp
	 * @param width
	 * @param height
	 * @return
	 */
	public static byte[] rotate90YUV420SP(byte[] yuv420sp, int width, int height) {
		byte[] des = new byte[yuv420sp.length];
		int wh = width * height;
		// 旋转Y
		// => b[i,j] = a[h - j - 1, i]
		// j*w+i
		int k = 0;
		for (int i = 0; i < width; i++) {
			for (int j = 0; j < height; j++) {
				des[k] = yuv420sp[width * (height - j - 1) + i];
				k++;
			}
		}

		// b[w-j-1,i] = a[i,j]
		// => b[i,j] = a[j,i]
		//
		for (int i = 0; i < width; i += 2) {
			for (int j = 0; j < height / 2; j++) {
				des[k] = yuv420sp[wh + width * (height / 2 - j - 1) + i];
				des[k + 1] = yuv420sp[wh + width * (height / 2 - j - 1) + i + 1];
				k += 2;
			}
		}
		return des;
	}

	/**
	 * 顺时针旋转180.
	 * 
	 * @param yuv420sp
	 * @param width
	 * @param height
	 * @return
	 */
	public static byte[] rotate180YUV420SP(byte[] yuv420sp, int width, int height) {
		// 旋转Y
		int length = width * height;
		for (int i = 0; i < length / 2 - 1; i++) {
			byte temp = yuv420sp[i];
			yuv420sp[i] = yuv420sp[length - 1 - i];
			yuv420sp[length - 1 - i] = temp;
		}
		int startIndex = width * height;
		int count = width * height / 4;
		// 旋转uv
		for (int i = 0; i < count / 2 - 1; ++i) {
			byte temp = yuv420sp[i * 2 + startIndex];
			yuv420sp[i * 2 + startIndex] = yuv420sp[(count - i - 1) * 2 + startIndex];
			yuv420sp[(count - i - 1) * 2 + startIndex] = temp;

			temp = yuv420sp[i * 2 + 1 + startIndex];
			yuv420sp[i * 2 + 1 + startIndex] = yuv420sp[(count - i - 1) * 2 + 1 + startIndex];
			yuv420sp[(count - i - 1) * 2 + 1 + startIndex] = temp;
		}
		return yuv420sp;
	}

	public static void cropYUV420SP(byte[] yuv420sp, byte[] croppedYUV420sp, Rect rectangle, Rect originalRect) {

		if (!originalRect.contains(rectangle)) {
			throw new IllegalArgumentException("rectangle is not inside the image");
		}

		int width = rectangle.width();
		int height = rectangle.height();
		// Make sure left, top, width and height are all even.
		width &= ~1;
		height &= ~1;
		rectangle.left &= ~1;
		rectangle.top &= ~1;
		rectangle.right = rectangle.left + width;
		rectangle.bottom = rectangle.top + height;

		width = rectangle.width();
		height = rectangle.height();
		int top = rectangle.top;
		// int bottom = rectangle.bottom;
		int left = rectangle.left;
		// int right = rectangle.right;

		croppedYUV420sp = new byte[width * height * 3 / 2];

		// Crop Y
		for (int i = 0; i < height; i++) {
			for (int j = 0; j < width; j++) {
				croppedYUV420sp[i * width + j] = yuv420sp[(top + i) * width + (left + j)];
			}
		}
		// Crop UV
		int widthCountOfUV = originalRect.width() / 2;
		int LeftOffsetCountOfUV = left / 2;
		int originalOffSet = originalRect.width() * originalRect.height();
		int croppedOffSet = width * height;
		int k = 0;
		for (int i = 0; i <= height; i += 2) {
			for (int j = 0; j < width; j += 2) {
				int orignalIndex = (top + i) * widthCountOfUV + LeftOffsetCountOfUV * 2 + j + originalOffSet;
				croppedYUV420sp[croppedOffSet + k] = yuv420sp[orignalIndex];
				croppedYUV420sp[croppedOffSet + k + 1] = yuv420sp[orignalIndex + 1];
				k += 2;
			}
		}
	}

	public Boolean saveImage(byte[] data, Camera camera, int[] faceRects,
			String bigPicture/* , String smallPicture */) {
		int left = 0;
		int bottom = 0;
		int top = 0;
		left = faceRects[0];
		top = faceRects[1];
		bottom = faceRects[1] + faceRects[3];
		Log.i("huakuang", "left =" + left + "" + "   top = " + top + "" + "  button=" + bottom + "");
		YuvImage yuvimage = new YuvImage(data, ImageFormat.NV21, camera.getParameters().getPreviewSize().width,
				camera.getParameters().getPreviewSize().height, null);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		yuvimage.compressToJpeg(new Rect(0, 0, camera.getParameters().getPreviewSize().width,
				camera.getParameters().getPreviewSize().height), 100, baos);
		// Log.i("waaa",
		// "width="+camera.getParameters().getPreviewSize().width+""+"hig="+camera.getParameters().getPreviewSize().height+"");//width=320,hig=240
		byte[] dataBy = baos.toByteArray();
		Matrix matrix = new Matrix(); // 翻转图片，原图片长宽交换。
		if (Consts.mOpenCameraId == 1) {
			matrix.postRotate(270);
		} else {
			matrix.postRotate(90);
		}
		matrix.postScale(-1, 1); // 镜像水平翻转
		Bitmap bitmap = BitmapFactory.decodeByteArray(dataBy, 0, dataBy.length);
		Bitmap nbmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
		// 原数12 10
		File bigFile = new File(bigPicture);
		FileOutputStream bigOut = null;
		try {
			bigOut = new FileOutputStream(bigFile);
			nbmp.compress(Bitmap.CompressFormat.JPEG, 50, bigOut);
			bigOut.close();
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// try {
		// File smallFile = new File(smallPicture);
		// FileOutputStream smallOut = new FileOutputStream(smallFile);
		// Bitmap biduiBitmap = resizeBitmap(nbmp, 150, 150);
		// biduiBitmap.compress(Bitmap.CompressFormat.PNG, 80, smallOut);
		// Log.i("biduiBitmap.getHeight", "" + biduiBitmap.getHeight());
		// Log.i("biduiBitmap.getWidth()", "" + biduiBitmap.getWidth());
		// // picNewRes.compress(Bitmap.CompressFormat.PNG, 100, newOut);
		// smallOut.close();
		// } catch (FileNotFoundException e) {
		// e.printStackTrace();
		// return false;
		// } catch (IOException e) {
		// e.printStackTrace();
		// return false;
		// }
		return true;
	}

	public Boolean saveImage(byte[] data, Camera camera, String imagePath) {
		YuvImage yuvimage = new YuvImage(data, ImageFormat.NV21, camera.getParameters().getPreviewSize().width,
				camera.getParameters().getPreviewSize().height, null);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		yuvimage.compressToJpeg(new Rect(0, 0, camera.getParameters().getPreviewSize().width,
				camera.getParameters().getPreviewSize().height), 80, baos);
		byte[] dataBy = baos.toByteArray();
		Matrix matrix = new Matrix(); // 翻转图片，原图片长宽交换。
		if (Consts.mOpenCameraId == 1) {
			matrix.postRotate(270);
		} else {
			matrix.postRotate(90);
		}
		matrix.postScale(-1, 1); // 镜像水平翻转
		Bitmap bitmap = BitmapFactory.decodeByteArray(dataBy, 0, dataBy.length);
		Bitmap nbmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
		// 原数12 10
		File bigFile = new File(imagePath);
		FileOutputStream bigOut = null;
		try {
			bigOut = new FileOutputStream(bigFile);
			nbmp.compress(Bitmap.CompressFormat.PNG, 80, bigOut);
			bigOut.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	public static Bitmap resizeBitmap(Bitmap bitmap, int maxWidth, int maxHeight) {

		int originWidth = bitmap.getWidth();
		int originHeight = bitmap.getHeight();

		// no need to resize
		if (originWidth < maxWidth && originHeight < maxHeight) {
			return bitmap;
		}

		int width = originWidth;
		int height = originHeight;

		// 若图片过宽, 则保持长宽比缩放图片
		if (originWidth > maxWidth) {
			width = maxWidth;

			double i = originWidth * 1.0 / maxWidth;
			height = (int) Math.floor(originHeight / i);

			bitmap = Bitmap.createScaledBitmap(bitmap, width, height, false);
		}

		// 若图片过长, 则从上端截取
		if (height > maxHeight) {
			height = maxHeight;
			bitmap = Bitmap.createBitmap(bitmap, 0, 0, width, height);
		}

		// Log.i(TAG, width + " width");
		// Log.i(TAG, height + " height");

		return bitmap;
	}
}
