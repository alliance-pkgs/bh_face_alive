package com.bh_face_alive;

import com.alliance.AOPMobileApp.R;

import com.sensetime.library.finance.common.camera.CameraPreviewView;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

@SuppressLint("NewApi")
public class MainFragment extends Fragment {
	public CameraPreviewView surfaceView;
	public ImageView head_img;
	public TextView txt_note;

	public interface GetSurfaceView {
		void getInstance(CameraPreviewView surfaceView, ImageView img, TextView txt_note);
	}

	GetSurfaceView mainFragment;

	public MainFragment(GetSurfaceView mainFragment) {
		this.mainFragment = mainFragment;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View v = inflater.inflate(R.layout.screen, null);
		surfaceView = (CameraPreviewView) v.findViewById(R.id.camera_preview);
		head_img = (ImageView) v.findViewById(R.id.head_img);
		txt_note = (TextView) v.findViewById(R.id.txt_note);
		mainFragment.getInstance(surfaceView, head_img, txt_note);
		return v;
	}

}
