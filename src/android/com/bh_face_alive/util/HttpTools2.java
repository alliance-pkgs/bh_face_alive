package com.bh_face_alive.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.CoreConnectionPNames;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;
import encode_base64.ByteBase64;

/**
 * 博宏人脸接口2.0
 * 
 * @author yaoshuzhi
 * 
 */
public class HttpTools2 {

	private static final String name_exist = "existPerson";
	private static final String name_register = "addFace";
	private static final String name_login = "checkPerson";
	private static final String name_delete_all = "deleteFaces";
	private static final String name_delete_one = "deleteFace";
	private static final String name_update = "updateFaces";
	private static final String name_search_one = "searchPerson";
	private static final String name_search_more = "searchPersons";
	/** 二次成像检测接口名称 */
	public static final String name_hack_liveness = "liveness";
	// 清空缓存
	private static final String name_clean = "/bioauth-face-ws/comn/cache/clean";

	private static Bitmap bitmap = null;
	private static double defaultSim;
	private static String responseMsg = "";
	private static String serialNumber = "";
	private static String interface_url = "/bioauth-face-ws/face/";
	private static String feedback_url = "/bioauth-face-ws/facefeedback/add";
	private static String image_url = "/bioauth-face-ws/file/image/face/";

	public static String getMessage() {
		return responseMsg;
	}

	public static String getSerialNumber() {
		return serialNumber;
	}

	public static void clearMessage() {
		responseMsg = "";
		serialNumber = "";
		defaultSim = 0;
	}

	public static Bitmap getBitmap() {
		return bitmap;
	}

	public static double getDefaultSim() {
		return defaultSim;
	}

	public static void clearBitmap() {
		bitmap = null;
	}

	private static String getAddress(String submit_url, int submit_port) {
		return "http://" + submit_url + ":" + submit_port;
	}

	private static String getInterfaceUrl(String submit_url, int submit_port, String mainName) {
		return getAddress(submit_url, submit_port) + interface_url + mainName;
	}

	private static String getImageUrl(String submit_url, int submit_port, String channel, String userId, int faceId) {
		return getAddress(submit_url, submit_port) + image_url + faceId + "/" + userId;
	}

	private static String getJson(Map<String, Object> map) {
		try {
			return JsonUtil.toJson(map);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	private static Map<String, Object> getMap(String userId) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("id", userId);
		// map.put("channel", "4");
		return map;
	}

	private static Map<String, Object> getMap(int faceId) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("faceId", faceId);
		// map.put("channel", "4");
		return map;
	}

	private static Map<String, Object> getMap(String imgPath, String channel, int userCnt) {
		Map<String, Object> map = new HashMap<String, Object>();
		byte[] binImage1 = ByteBase64.getBytes(imgPath);
		String base64Str = Base64.encodeToString(binImage1, Base64.NO_WRAP);
		map.put("img1", base64Str);
		map.put("channel", channel + "");// 后台配置的渠道后
		// if(userCnt<=0){
		// map.put("userCnt", 1);
		// }else{
		// map.put("userCnt", userCnt);
		// }
		return map;
	}

	private static Map<String, Object> getMap(String userId, String imgPath, String channel) {
		Map<String, Object> map = new HashMap<String, Object>();
		byte[] binImage1 = ByteBase64.getBytes(imgPath);
		String base64Str = Base64.encodeToString(binImage1, Base64.NO_WRAP);
		map.put("id", userId);
		map.put("img1", base64Str);
		// map.put("baseFlag", "0");//非基准照
		map.put("channel", channel + "");// 后台配置的渠道后
		return map;
	}

	/**
	 * 检测用户存在接口
	 * 
	 * @param userId
	 *            注册的用户名
	 * @return true 请求服务器成功，有返回数据，false 连接失败
	 */
	public static boolean existPerson(String submit_url, int submit_port, String userId) {
		String url = getInterfaceUrl(submit_url, submit_port, name_exist);
		String json = getJson(getMap(userId));
		// Log.e("url", url);
		// Log.e("json", json);

		return getConnection(url, json);
	}

	/**
	 * 
	 * @param submit_url
	 * @param submit_port
	 * @param serialnumber
	 *            可在人脸验证，比对和搜索接口返回报文中获取得到
	 * @param resultl
	 *            1为正确，0为失败
	 * @return
	 */
	public static boolean feedBack(String submit_url, int submit_port, String serialnumber, int resultl) {
		String url = getAddress(submit_url, submit_port) + feedback_url;
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("serialnumber", serialnumber);
		map.put("result", resultl);
		// map.put("channel", "4");
		String json = getJson(map);
		// Log.e("url", url);
		// Log.e("json", json);

		return getConnection(url, json);
	}

	/**
	 * 根据existPerson(String userId)获取到的responseMsg解析该用户名是否存在
	 * 
	 * @return exist == 1 存在，exist == 0 不存在
	 */
	public static boolean ifExist() {
		try {
			JSONObject results = new JSONObject(responseMsg);
			clearMessage();
			int exist = results.getInt("exist");
			if (exist == 1) {
				return true;
			} else if (exist == 0) {
				return false;
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * 注册人脸接口
	 * 
	 * @param userId
	 *            注册的用户名
	 * @param imgPath
	 *            注册的人脸图像路径
	 * @return true 请求服务器成功，有返回数据，false 连接失败
	 */
	public static boolean addFaces(String submit_url, int submit_port, String channel, String userId, String imgPath) {
		String url = getInterfaceUrl(submit_url, submit_port, name_register);
		String json = getJson(getMap(userId, imgPath, channel));
		// Log.e("url", url);
		// Log.e("json", "addFaces:"+json);

		return getConnection(url, json);
	}

	public static boolean clean(String submit_url, int submit_port) {

		String url = getAddress(submit_url, submit_port) + name_clean;

		return getConnection(url, "");
	}

	/**
	 * 根据addFaces(String userId, String imgPath)获取到的responseMsg解析该用户名是否注册成功
	 * 
	 * @return result == 1 注册成功， else 不成功
	 */
	public static boolean ifRegisterSuccess() {
		return getResult();
	}

	/**
	 * 1:1比对接口
	 * 
	 * @param channel
	 *            渠道号
	 * @param userId
	 *            比对的用户名
	 * @param imgPath
	 *            传入到服务器与模板进行比对的图像的路径
	 * @return true 请求服务器成功，有返回数据，false 连接失败
	 */
	public static boolean checkPerson(String submit_url, int submit_port, String channel, String userId,
			String imgPath) {
		String url = getInterfaceUrl(submit_url, submit_port, name_login);
		String json = getJson(getMap(userId, imgPath, channel));
		// Log.e("url", url);
		// Log.e("json", json);

		return getConnection(url, json);
	}

	/**
	 * 删除指定人脸接口
	 * 
	 * @param faceId
	 *            要删除的人脸ID
	 * @return true 请求服务器成功，有返回数据，false 连接失败
	 */
	public static boolean deleteFace(String submit_url, int submit_port, int faceId) {
		String url = getInterfaceUrl(submit_url, submit_port, name_delete_one);
		String json = getJson(getMap(faceId));
		// Log.e("url", url);
		// Log.e("json", json);

		return getConnection(url, json);
	}

	/**
	 * 根据deleteFace(int faceId)获取到的responseMsg解析该人脸是否删除成功
	 * 
	 * @return result == 1 注册成功， else 不成功
	 */
	public static boolean ifDeleteFace() {
		return getResult();
	}

	/**
	 * 删除用户接口
	 * 
	 * @param userId
	 *            要删除的用户ID
	 * @return true 请求服务器成功，有返回数据，false 连接失败
	 */
	public static boolean deleteFaces(String submit_url, int submit_port, String userId) {
		String url = getInterfaceUrl(submit_url, submit_port, name_delete_all);
		String json = getJson(getMap(userId));
		// Log.e("url", url);
		// Log.e("json", json);

		return getConnection(url, json);
	}

	/**
	 * 根据deleteFaces(String userId)获取到的responseMsg解析该人脸是否删除成功
	 * 
	 * @return result == 1 注册成功， else 不成功
	 */
	public static boolean ifDeleteFaces() {
		return getResult();
	}

	/**
	 * 根据updateFaces(String userId, int faceId, String
	 * imgPath)获取到的responseMsg解析该用户的这一张faceId的照片是否替换
	 * 
	 * @return result == 1 注册成功， else 不成功
	 */
	public static boolean ifUpdateFace() {
		return getResult();
	}

	/**
	 * 1:N搜索（首位命中，获取到相似度最高的一张照片的用户信息）
	 * 
	 * @param imgPath
	 *            传入到服务器做1:N比对的图像路径
	 * @return
	 */
	public static boolean searchPerson(String submit_url, int submit_port, String channel, String imgPath) {
		String url = getInterfaceUrl(submit_url, submit_port, name_search_one);
		String json = getJson(getMap(imgPath, channel, 1));
		// Log.e("url", url);
		// Log.e("json", json);

		return getConnection(url, json);
	}

	/**
	 * 1:N搜索（高位命中，获取到相似度最高的多张照片的用户信息）
	 * 
	 * @param imgPath
	 *            传入到服务器做1:N比对的图像路径
	 * @param userCnt
	 *            需要从服务器获取到的照片的张数
	 * @return
	 */
	public static boolean searchPersons(String submit_url, int submit_port, String channel, String imgPath,
			int userCnt) {
		String url = getInterfaceUrl(submit_url, submit_port, name_search_more);
		String json = getJson(getMap(imgPath, channel, userCnt));
		// Log.e("url", url);
		// Log.e("json", json);

		return getConnection(url, json);
	}

	/**
	 * 根据调用搜索接口成功之后获取到的responseMsg来获取搜索到的用户信息的集合
	 * 
	 * @return 用户信息的集合
	 */
	public static List<Map<String, Object>> getUserInfos() {
		try {
			JSONObject results = new JSONObject(responseMsg);
			clearMessage();
			String result = results.optString("exCode");
			if ("0".equals(result)) {// 0为成功，其他为失败
				JSONObject data = results.getJSONObject("data");
				defaultSim = data.getDouble("defaultSim");
				String userInfos = data.getString("userInfos");
				return getList(userInfos);
			} else {
				return null;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static List<Map<String, Object>> getUserInfosNoClearMsg() {
		try {
			JSONObject results = new JSONObject(responseMsg);
			String result = results.optString("exCode");
			if ("0".equals(result)) {// 0为成功，其他为失败
				JSONObject data = results.getJSONObject("data");
				defaultSim = data.getDouble("defaultSim");
				String userInfos = data.getString("userInfos");
				return getList(userInfos);
			} else {
				return null;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 转化传入的用户信息的字符串
	 * 
	 * @param userInfos
	 *            用户信息
	 * @return 返回用户信息的集合
	 */
	@SuppressWarnings("rawtypes")
	private static List<Map<String, Object>> getList(String userInfos) {
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		if (userInfos != null) {
			try {
				JSONArray array = new JSONArray(userInfos);
				for (int i = 0; i < array.length(); i++) {
					Map<String, Object> map = new HashMap<String, Object>();
					JSONObject jsonObject = array.getJSONObject(i);
					Iterator iterable = jsonObject.keys();
					while (iterable.hasNext()) {
						String key = String.valueOf(iterable.next());
						String value = String.valueOf(jsonObject.get(key));
						map.put(key, value);
					}
					list.add(map);
				}
				return list;

			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		return null;
	}

	/**
	 * httppost提交提取出來连接服务器的公共方法
	 * 
	 * @param url
	 *            不同接口连接服务器的地址
	 * @param json
	 *            不同接口索要提交的数据json
	 * @return true 请求服务器成功，有返回数据，false 连接失败
	 */
	private static boolean getConnection(String url, String json) {
		boolean validate = false;
		try {
			clearMessage();
			List<NameValuePair> nvps = new ArrayList<NameValuePair>();
			nvps.add(new BasicNameValuePair("params", json));
			HttpClient client = new DefaultHttpClient();
			HttpPost post = new HttpPost(url);
			client.getParams().setParameter(CoreConnectionPNames.CONNECTION_TIMEOUT, 15000);
			client.getParams().setParameter(CoreConnectionPNames.SO_TIMEOUT, 15000);
			HttpEntity entity = new UrlEncodedFormEntity(nvps, HTTP.UTF_8);
			post.setEntity(entity);
			HttpResponse response = client.execute(post);
			// Log.e("response.getStatusLine().getStatusCode()",
			// response.getStatusLine().getStatusCode() + "");
			if (response.getStatusLine().getStatusCode() == 200) {
				responseMsg = EntityUtils.toString(response.getEntity());
				Log.e("", "response " + responseMsg);
				JSONObject results = new JSONObject(responseMsg);
				String exCode = results.optString("exCode");
				validate = "0".equals(exCode);// 0为成功，其他为失败
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return validate;
	}

	/**
	 * 根据调用所有接口获取到的responseMsg解析该人脸是否删除成功
	 * 
	 * @return result == 1 注册成功， else 不成功
	 */
	private static boolean getResult() {
		try {
			JSONObject results = new JSONObject(responseMsg);
			String result = results.optString("exCode");
			if ("0".equals(result)) {// 0为成功，其他为失败
				clearMessage();
				return true;
			} else {
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * 获取服务器图像的接口
	 * 
	 * @param userId
	 *            用户ID
	 * @param faceId
	 *            人脸ID
	 * @return true 请求服务器成功，有返回数据，false 连接失败
	 */
	public static boolean getImageBitmap(String submit_url, int submit_port, String channel, String userId,
			int faceId) {
		String image_url = getImageUrl(submit_url, submit_port, channel, userId, faceId);
		try {
			URL url = new URL(image_url);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setConnectTimeout(15000);
			connection.setRequestMethod("GET");
			if (connection.getResponseCode() == 200) {
				InputStream is = connection.getInputStream();
				bitmap = BitmapFactory.decodeStream(is);
				is.close();
				return true;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * post请求
	 * 
	 * @param submit_url
	 *            请求的地址
	 * @param submit_port
	 *            端口
	 * @param fuctionName
	 *            方法名称
	 * @param paramsJson
	 *            请求参数json字串
	 * @param responseHandler
	 *            异步返回操作处理回调
	 * @return void
	 */
	public static void doPost(String submit_url, int submit_port, String fuctionName, String paramsJson,
			AsyncHttpResponseHandler responseHandler) {
		String urlStr = getInterfaceUrl(submit_url, submit_port, fuctionName);
		Log.e("====", "===url==="+urlStr);
		AsyncHttpClient asyncHttpClient = new AsyncHttpClient();
		asyncHttpClient.setTimeout(15000);
		//responseHandler.setCharset("utf-8");
		RequestParams params = new RequestParams();
		params.put("params", paramsJson);
		asyncHttpClient.post(urlStr, params, responseHandler);
	}

	public static void doPost(String submit_url, int submit_port, String fuctionName, RequestParams params,
			AsyncHttpResponseHandler responseHandler) {
		String urlStr = getInterfaceUrl(submit_url, submit_port, fuctionName);
		// Log.e("", "===url==="+urlStr);
		AsyncHttpClient asyncHttpClient = new AsyncHttpClient();
		asyncHttpClient.setTimeout(20000);
		//responseHandler.setCharset("utf-8");
		asyncHttpClient.post(urlStr, params, responseHandler);
	}
}
