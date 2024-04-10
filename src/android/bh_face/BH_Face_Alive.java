package bh_face_alive;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.bh_face_alive.LivenessActivity;
import com.bh_face_alive.configure.Consts;
import com.bh_face_alive.util.SDCardUtils;

import android.content.Intent;
import encode_base64.Base64;
import encode_base64.ByteBase64;
import android.util.Log;
/**
 * This class echoes a string called from JavaScript.
 */
public class BH_Face_Alive extends CordovaPlugin {
	private final String TAG = BH_Face_Alive.class.getSimpleName();
	CallbackContext callbackContext;
	public static String result = null;
	public static String error = null;

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (action.equals("bh_face_alive") && !Consts.alive) {
			this.callbackContext = callbackContext;
			initAlive(args);
			return true;
		} else if (action.equals("encode")) {
			String path = null;
			if (args.length() > 0) {
				path = args.getString(0);
			} else {
				callbackContext.error("param error!!");
				return true;
			}
			byte[] binImage1 = ByteBase64.getBytes(path);
			String base64Str = Base64.encodeToString(binImage1, Base64.NO_WRAP);
			callbackContext.success(base64Str);
			return true;
		}
		return false;
	}

	private void initAlive(JSONArray args) {
		Intent intent = new Intent(this.cordova.getActivity(), LivenessActivity.class);
		if (args.length() < 2) {
			Log.d(TAG, "args's length much too small");
			return;
		}
		try {
			String title = args.getString(0); // Get header title.
			intent.putExtra("title", title);

			JSONArray arrType = args.getJSONArray(1);// 检测活体的类型

			//Get Language For Multilingual Voice 
			int language = args.getInt(2);
			intent.putExtra("language",language);
			Log.d(TAG, "LanguagInt="+String.valueOf(language));

			String nricReg = args.length() > 3 ? args.getString(3) : null;
			intent.putExtra("nricReg", nricReg);

			int[] types = new int[arrType.length()];
			for (int i = 0; i < arrType.length(); i++) {
				types[i] = arrType.getInt(i);
			}
			intent.putExtra(Consts.TYPE, types);

			cordova.startActivityForResult(this, intent, 0);

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		super.onActivityResult(requestCode, resultCode, intent);
		try {
			JSONObject obj = new JSONObject();
			if (result != null) {
				byte[] binImage1 = ByteBase64.getBytes(result);
				String base64Str = Base64.encodeToString(binImage1, Base64.NO_WRAP);
				if (SDCardUtils.deleteFile(result)) {
					LOG.d("File is deleted :: ", "true");
				} else {
					LOG.d("File is deleted :: ", "false");
				}
				obj.put("imgBase64", base64Str);
				callbackContext.success(obj);
			} else {
				if (error != null) {
					callbackContext.error(obj.put("errContent", error));
				} else {
					callbackContext.error(obj.put("errContent", -2));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			callbackContext.error(e.getMessage());
		}
	}

}
