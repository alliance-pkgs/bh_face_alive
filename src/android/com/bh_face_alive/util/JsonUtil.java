package com.bh_face_alive.util;

import java.io.Serializable;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.codehaus.jackson.map.ObjectMapper;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class JsonUtil implements Serializable {

	private static ObjectMapper mapper = new ObjectMapper();

	private static final long serialVersionUID = -7609521898676321656L;

	/**
	 * 从对象转换成json字符串
	 * 
	 * @param params
	 * @return
	 */
	public static String toJson(Map<String, Object> params) throws Exception {
		try {
			return mapper.writeValueAsString(params);
		} catch (Exception e) {
			throw e;
		}
	}

	/**
	 * 反序列化
	 * 
	 * @param typeToken
	 *            目标类型
	 * @param json
	 *            json字符串
	 * @return
	 */
	public static final <T> T toObj(TypeToken<T> typeToken, String json) {
		Gson gson = new Gson();
		return gson.fromJson(json, typeToken.getType());
	}

	/**
	 * 反序列化
	 * 
	 * @param json
	 * @return
	 */
	public static <T> Collection<T> toCollection(String json, TypeToken<Collection<T>> typeToken) {
		return JsonUtil.toObj(typeToken, json);
	}

	/**
	 * 反序列化
	 * 
	 * @param json
	 *            json字符串
	 * @return
	 */
	public static <T> List<T> toList(String json, TypeToken<List<T>> typeToken) {
		return JsonUtil.toObj(typeToken, json);
	}

	/**
	 * 反序列化
	 * 
	 * @param json
	 *            json字符串
	 * @return
	 */
	public static <T> Set<T> toSet(String json, TypeToken<Set<T>> typeToken) {
		return JsonUtil.toObj(typeToken, json);
	}

	/**
	 * 反序列化
	 * 
	 * @param json
	 *            json字符串
	 * @return
	 */
	public static <K, V> Map<K, V> toMap(String json, TypeToken<Map<K, V>> typeToken) {
		return JsonUtil.toObj(typeToken, json);
	}

}
