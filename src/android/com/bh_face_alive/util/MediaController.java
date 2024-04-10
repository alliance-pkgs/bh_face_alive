package com.bh_face_alive.util;

import com.alliance.AOPMobileApp.R;

import com.sensetime.library.finance.liveness.NativeMotion;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;

/**
 * Created on 2016/11/01 10:45.
 *
 * @author Han Xu
 */
public final class MediaController {

	private MediaPlayer mMediaPlayer = null;

	public static MediaController getInstance() {
		return InstanceHolder.INSTANCE;
	}

	public void release() {
		if (mMediaPlayer == null) {
			return;
		}
		mMediaPlayer.setOnPreparedListener(null);
		mMediaPlayer.stop();
		mMediaPlayer.reset();
		mMediaPlayer.release();
		mMediaPlayer = null;
	}

	public void playNotice(Context context, int motion,int language) {
		switch (motion) {
		case NativeMotion.CV_LIVENESS_BLINK:
			play(context, getBlinkEyeVoice(language));
			break;
		case NativeMotion.CV_LIVENESS_MOUTH:
			play(context, R.raw.common_notice_mouth);
			break;
		case NativeMotion.CV_LIVENESS_HEADNOD:
			play(context, R.raw.common_notice_nod);
			break;
		case NativeMotion.CV_LIVENESS_HEADYAW:
			play(context, R.raw.common_notice_yaw);
			break;
		default:
			play(context, getFaceBoxVoice(language));
		break;
		}
	}

	private void play(Context context, int soundId) {
		if (mMediaPlayer != null) {
			mMediaPlayer.stop();
			mMediaPlayer.release();
			mMediaPlayer = null;
		}

		AudioManager audioManager = (AudioManager) context.getApplicationContext()
				.getSystemService(Context.AUDIO_SERVICE);
		audioManager.requestAudioFocus(new AudioManager.OnAudioFocusChangeListener() {
			@Override
			public void onAudioFocusChange(int focusChange) {
			}
		}, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN);

		mMediaPlayer = MediaPlayer.create(context, soundId);
		// mMediaPlayer.setLooping(true);
		mMediaPlayer.start();
	}

	private MediaController() {
		// Do nothing.
	}

	private static class InstanceHolder {
		private static final MediaController INSTANCE = new MediaController();
	}

	private static class Language{
		private static final int english = 1;
		private static final int bengali = 2;
		private static final int myanmar = 3;
		private static final int nepali = 4;
		private static final int bahasaMelayu = 5;
		private static final int hindi = 6;
	}

	private static int getFaceBoxVoice(int language){
		int faceBoxVoiceId = 0;
		switch(language){
			case Language.bengali:
			faceBoxVoiceId = R.raw.be_frontface;
			break;
			case Language.myanmar:
			faceBoxVoiceId = R.raw.mm_frontface;
			break;
			case Language.nepali:
			faceBoxVoiceId = R.raw.ne_frontface;
			break;
			case Language.bahasaMelayu:
			faceBoxVoiceId = R.raw.bm_frontface;
			break;
			case Language.hindi:
			faceBoxVoiceId = R.raw.hi_frontface;
			break;
			default:
			faceBoxVoiceId = R.raw.en_frontface;
			break;
			}
		return faceBoxVoiceId; 
	}

	private static int getBlinkEyeVoice(int language){
		int blinkEyeVoiceId = 0;
		switch(language){
			case Language.bengali:
			blinkEyeVoiceId = R.raw.be_notice_blink;
			break;
			case Language.myanmar:
			blinkEyeVoiceId = R.raw.mm_notice_blink;
			break;
			case Language.nepali:
			blinkEyeVoiceId = R.raw.ne_notice_blink;
			break;
			case Language.bahasaMelayu:
			blinkEyeVoiceId = R.raw.bm_notice_blink;
			break;
			case Language.hindi:
			blinkEyeVoiceId = R.raw.hi_notice_blink;
			break;
			default:
			blinkEyeVoiceId = R.raw.en_notice_blink;;
			break;
			}
		return blinkEyeVoiceId;
	}
}
