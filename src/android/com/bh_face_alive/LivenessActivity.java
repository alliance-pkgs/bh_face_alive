package com.bh_face_alive;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.apache.cordova.CordovaActivity;

import com.bh_face_alive.MainFragment.GetSurfaceView;
import com.bh_face_alive.util.DensityUtil;
import com.bh_face_alive.util.ImageHelper;
import com.bh_face_alive.util.MediaController;
import com.sensetime.library.finance.common.camera.CameraError;
import com.sensetime.library.finance.common.camera.CameraPreviewView;
import com.sensetime.library.finance.common.camera.CameraUtil;
import com.sensetime.library.finance.common.camera.OnCameraListener;
import com.sensetime.library.finance.common.type.PixelFormat;
import com.sensetime.library.finance.common.type.Size;
import com.sensetime.library.finance.common.util.FileUtil;
import com.sensetime.library.finance.liveness.DetectInfo;
import com.sensetime.library.finance.liveness.LivenessCode;
import com.sensetime.library.finance.liveness.MotionLivenessApi;
import com.sensetime.library.finance.liveness.NativeComplexity;
import com.sensetime.library.finance.liveness.NativeMotion;
import com.sensetime.library.finance.liveness.type.BoundInfo;

import android.annotation.SuppressLint;
import android.app.FragmentTransaction;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.SystemClock;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.Typeface;
import android.widget.Button;
import android.graphics.drawable.Drawable;
import android.graphics.Color;

import com.alliance.AOPMobileApp.R;

import bh_face_alive.BH_Face_Alive;

@SuppressLint("NewApi")
public class LivenessActivity extends CordovaActivity {
    private final String TAG = LivenessActivity.class.getSimpleName();
    private CameraPreviewView mCameraPreviewView = null;
    private final byte[] mImageData = new byte[CameraUtil.DEFAULT_PREVIEW_WIDTH * CameraUtil.DEFAULT_PREVIEW_HEIGHT * 3
            / 2];
    private boolean mIsImageDataChanged = false;
    private final String FILES_PATH = "/boomhope/";
    private static final String MODEL_FILE_NAME = "M_Finance_Composite_General_Liveness_1.0.model";
    private static final String LICENSE_FILE_NAME = "SenseID_Liveness.lic";
    private ExecutorService mLivenessExecutor = null;
    private int mDifficulty = NativeComplexity.WRAPPER_COMPLEXITY_NORMAL;
    private boolean mIsStopped = true;
    private LivenessState mState = new AlignmentState();
    private long mAlignedStartTime = -1L;
    private static final int DELAY_ALIGN_DURATION = 1000;
    private static final int RESULT_CODE = 1;
    private byte[] mDetectImageData = null;
    private int mCurrentMotionIndex = -1;
    private int[] mSequences = new int[]{NativeMotion.CV_LIVENESS_BLINK, NativeMotion.CV_LIVENESS_MOUTH,
            NativeMotion.CV_LIVENESS_HEADNOD, NativeMotion.CV_LIVENESS_HEADYAW};
    private String uploadImgPath;// 要上传的图片路径
    private boolean mMotionChanged = false;
    private boolean mIsVoiceOn = true;
    private boolean isOpenHackerDetection = true;// 是否开启防黑客攻击检测
    private MainFragment mainFragment = null;
    private int screenHeight = 0;
    private int screenMarginTop = 0;
    private ImageView head_img;
    private TextView txt_note;
    private ImageView aliveImage;
    private AnimationDrawable animationDrawable;
    private TextView aliveTime;
    private String title;
    private TextView txt_title;
    private String nricReg;
    private boolean isNricReg = false;
    private Button back;
    private View view;
    private TextView footer_title;
    private FrameLayout footerFrame;
    private FrameLayout footerFrame2;

    private CountDownTimer countDownTimer;
    private boolean isCountingDown = false;

    private final int DEFAULT_ALIVE_TIMEOUT = 60;
    private int language;

    private int stepTip = -1;

    private interface LivenessState {
        void checkResult(DetectInfo info);

        void beforeDetect();
    }

    private void handleIntent() {
        screenMarginTop = DensityUtil.dip2px(this,
                getIntent().getIntExtra(com.bh_face_alive.configure.Consts.SCREEN_TOP, 55));

        int sequence[] = getIntent().getIntArrayExtra(com.bh_face_alive.configure.Consts.TYPE);
        if (sequence != null && sequence.length > 0) {
            mSequences = sequence;
        }

        title = getIntent().getStringExtra("title");
        language = getIntent().getIntExtra("language", 1);
        nricReg = getIntent().getStringExtra("nricReg");

        if ("NricReg".equals(nricReg)) {
            isNricReg = true;
        } else {
            isNricReg = false;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        clearPreviousResult();
        super.onCreate(savedInstanceState);
        // if (!checkPermission()) {
        // exit();
        // }
        setContentView(R.layout.activity_liveness);
        handleIntent();
        initViews();
        initScreen();
    }

    @Override
    public void onDestroy() {
        if (countDownTimer != null && isCountingDown) {
            countDownTimer.cancel();
        }
        super.onDestroy();
    }

    @Override
    protected void createViews() {
    }

    @Override
    protected void onResume() {
        super.onResume();

        File dir = new File(LivenessActivity.this.getExternalFilesDir(null), FILES_PATH);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        FileUtil.copyAssetsToFile(LivenessActivity.this, MODEL_FILE_NAME, dir.getPath() + MODEL_FILE_NAME);
        FileUtil.copyAssetsToFile(LivenessActivity.this, LICENSE_FILE_NAME, dir.getPath() + LICENSE_FILE_NAME);
        LivenessCode result = MotionLivenessApi.init(LivenessActivity.this, dir.getPath() + LICENSE_FILE_NAME,
                dir.getPath() + MODEL_FILE_NAME);

        if (result != LivenessCode.OK) {
            Log.d(TAG, "12345" + result);
            // setResult(RESULT_CODE, new Intent().putExtra("errContent", "2"));
            BH_Face_Alive.error = "2";
            Log.d(TAG, "MotionLivenessApi init error...");
            finish();
            return;
        }
        startDetectThread();
    }

    private void initViews() {
        aliveTime = (TextView) findViewById(R.id.alive_time);

        aliveImage = (ImageView) this.findViewById(R.id.alive_image_toast);
        animationDrawable = new AnimationDrawable();

        txt_title = (TextView) findViewById(R.id.txt_title);
        Typeface custom_font = Typeface.createFromAsset(getAssets(), "fonts/ZawgyiOne2008.ttf");
        txt_title.setTypeface(custom_font);
        txt_title.setText(title);

        if (isNricReg) {
            LayoutParams lp = (LayoutParams) txt_title.getLayoutParams();
            lp.addRule(RelativeLayout.CENTER_HORIZONTAL);
            txt_title.setLayoutParams(lp);

            back = (Button) findViewById(R.id.back_camera);

            Drawable img = getResources().getDrawable(R.drawable.btn_back);
            img.setBounds(0, 0, (int) (img.getIntrinsicWidth() * 0.4), (int) (img.getIntrinsicHeight() * 0.4));
            back.setCompoundDrawables(img, null, null, null);
            back.setTextColor(Color.rgb(255, 255, 255));
            back.setText("Back");
            back.setVisibility(Button.VISIBLE);

            back.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    finish();
                }
            });

            view = (View) findViewById(R.id.view1);
            view.setVisibility(View.VISIBLE);

            footer_title = (TextView) findViewById(R.id.footer_title);
            footer_title.setText("Position your face within the frame");
            footer_title.setVisibility(TextView.GONE);

            footerFrame = (FrameLayout) findViewById(R.id.frame1);
            LayoutParams lp2 = (LayoutParams) footerFrame.getLayoutParams();
            lp2.addRule(RelativeLayout.BELOW, R.id.footer_title);
            footerFrame.setLayoutParams(lp2);

            footerFrame2 = (FrameLayout) findViewById(R.id.frame2);
            LayoutParams lp3 = (LayoutParams) footerFrame2.getLayoutParams();
            lp3.addRule(RelativeLayout.BELOW, R.id.footer_title);
            footerFrame2.setLayoutParams(lp3);
        }
    }

    private void initScreen() {
        txt_title = (TextView) findViewById(R.id.txt_title);
        Typeface custom_font = Typeface.createFromAsset(getAssets(), "fonts/ZawgyiOne2008.ttf");
        txt_title.setTypeface(custom_font);
        txt_title.setText(title);

        RelativeLayout container = (RelativeLayout) findViewById(R.id.container);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        params.topMargin = screenMarginTop;
        container.setLayoutParams(params);
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        mainFragment = new MainFragment(new GetSurfaceView() {
            @Override
            public void getInstance(CameraPreviewView surfaceView, ImageView imgView, TextView txt_v) {
                MediaController.getInstance().playNotice(LivenessActivity.this, -1, language);
                mCameraPreviewView = surfaceView;
                head_img = imgView;
                txt_note = txt_v;
                CameraUtil.INSTANCE.setPreviewView(mCameraPreviewView);
                CameraUtil.INSTANCE.setOnCameraListener(new OnCameraListener() {
                    @Override
                    public void onError(CameraError paramCameraError) {
                        // setResult(RESULT_CODE, new Intent().putExtra("errContent", "0"));
                        BH_Face_Alive.error = "0";
                        Log.d(TAG, "Camera init error  " + paramCameraError.OPEN_CAMERA);
                        finish();
                    }

                    @Override
                    public void onCameraDataFetched(byte[] data) {
                        synchronized (mImageData) {
                            if (data == null || data.length < 1) {
                                return;
                            }
                            Arrays.fill(mImageData, (byte) 0);
                            System.arraycopy(data, 0, mImageData, 0, data.length);
                            mIsImageDataChanged = true;
                        }
                    }
                });

            }
        });
        transaction.replace(R.id.container, mainFragment);
        transaction.commitAllowingStateLoss();
    }

    private void startDetectThread() {
        mLivenessExecutor = Executors.newSingleThreadExecutor();
        mLivenessExecutor.execute(new Runnable() {
            @Override
            public void run() {
                LivenessCode code = MotionLivenessApi.getInstance().prepare(mDifficulty);

                if (code != LivenessCode.OK) {
                    MotionLivenessApi.getInstance().stopDetect(false, false);
                    code = MotionLivenessApi.getInstance().prepare(mDifficulty);
                    if (code != LivenessCode.OK) {
                        Log.d(TAG, "MotionLivenessApi is not prepare...");
                        finish();
                        return;
                    }
                }

                while (true) {
                    if (mIsStopped) {
                        break;
                    }
                    if (!mIsImageDataChanged) {
                        try {
                            Thread.sleep(10);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        continue;
                    }
                    mState.beforeDetect();
                    synchronized (mImageData) {
                        if (mDetectImageData == null) {
                            mDetectImageData = new byte[mImageData.length];
                        }
                        System.arraycopy(mImageData, 0, mDetectImageData, 0, mImageData.length);
                    }
                    final DetectInfo info = MotionLivenessApi.getInstance().detect(mDetectImageData, PixelFormat.NV21,
                            new Size(CameraUtil.DEFAULT_PREVIEW_WIDTH, CameraUtil.DEFAULT_PREVIEW_HEIGHT),
                            new Size(mCameraPreviewView.getWidth(), mCameraPreviewView.getHeight()),
                            CameraUtil.INSTANCE.getCameraOrientation(),
                            new BoundInfo(((View) mCameraPreviewView.getParent()).getWidth() / 2,
                                    ((View) mCameraPreviewView.getParent()).getHeight() / 2,
                                    (((View) mCameraPreviewView.getParent()).getWidth() / 3)));
                    mIsImageDataChanged = false;
                    if (mIsStopped) {
                        break;
                    }
                    mState.checkResult(info);
                }
            }
        });
        mIsStopped = false;
    }

    @SuppressLint("NewApi")
    // Already check in first case(Build.VERSION.SDK_INT < 23);
    private boolean checkPermission() {
        return true;
        // return Build.VERSION.SDK_INT < 23
        // || (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
        // == PackageManager.PERMISSION_GRANTED &&
        // checkSelfPermission(Manifest.permission.CAMERA) ==
        // PackageManager.PERMISSION_GRANTED);
    }

    private class AlignmentState implements LivenessState {
        private boolean mIsMotionSet = false;

        @Override
        public void checkResult(DetectInfo info) {
            if (info.getFaceState() == DetectInfo.FaceState.NORMAL
                    && info.getFaceDistance() == DetectInfo.FaceDistance.NORMAL) {
                if (mAlignedStartTime < 0) {
                    mAlignedStartTime = SystemClock.uptimeMillis();
                } else {
                    if (SystemClock.uptimeMillis() - mAlignedStartTime > DELAY_ALIGN_DURATION) {
                        mAlignedStartTime = -1;
                        switchToDetectState();
                        return;
                    }
                }
            } else {
                mAlignedStartTime = -1L;
            }
            updateMessage(info.getFaceState(), info.getFaceDistance());
        }

        @Override
        public void beforeDetect() {
            if (!mIsMotionSet) {
                mIsMotionSet = MotionLivenessApi.getInstance().setMotion(mSequences[0]);
                nextAction(mSequences[0]);
            }
        }
    }

    public void updateMessage(final DetectInfo.FaceState faceState, final DetectInfo.FaceDistance faceDistance) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (faceDistance == DetectInfo.FaceDistance.CLOSE) {
                    txt_note.setText(R.string.common_face_too_close);
                } else if (faceDistance == DetectInfo.FaceDistance.FAR) {
                    txt_note.setText(R.string.common_face_too_far);
                } else if (faceState == DetectInfo.FaceState.NORMAL) {
                    if (stepTip == -1) {
                        txt_note.setText("");
                    } else {
                        txt_note.setText(stepTip);
                    }
                } else {
                    txt_note.setText(R.string.common_tracking_missed);
                }
            }
        });
    }

    /**
     * Remove persisted result from previous scan.
     * Run this when activity is just started.
     */
    private void clearPreviousResult() {
        BH_Face_Alive.result = null;
        BH_Face_Alive.error = null;
    }

    private class DetectState implements LivenessState {

        @Override
        public void checkResult(DetectInfo info) {
            if (info.getFaceState() == null || info.getFaceState() == DetectInfo.FaceState.UNKNOWN
                    || info.getFaceState() == DetectInfo.FaceState.MISSED) {

                return;
            }
            boolean b = info.isPass();
            Log.d("gg", "" + b);

            if (!info.isPass()) {
                return;
            }
            if (mCurrentMotionIndex == mSequences.length - 1) {
                MotionLivenessApi.getInstance().stopDetect(true, true);
                saveLivenessImage();// 保存图片


            } else {
                switchMotion(mCurrentMotionIndex + 1);
                nextAction(mSequences[mCurrentMotionIndex]);
            }
        }

        @Override
        public void beforeDetect() {
            if (mMotionChanged && mCurrentMotionIndex > -1) {
                if (MotionLivenessApi.getInstance().setMotion(mSequences[mCurrentMotionIndex])) {
                    mMotionChanged = false;
                }
            }
        }

    }

    private void switchMotion(final int index) {
        mCurrentMotionIndex = index;
        mMotionChanged = true;
        if (mIsVoiceOn) {
            MediaController.getInstance().playNotice(LivenessActivity.this, mSequences[mCurrentMotionIndex], language);
        }

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                playAnimation(mSequences[mCurrentMotionIndex]);
                if (countDownTimer != null && isCountingDown) {
                    Log.d("CountdownTimer ::", "Cancelled");
                    countDownTimer.cancel();
                }
                countDownTimer = new CountDownTimer(DEFAULT_ALIVE_TIMEOUT * 1000, 1000) {
                    public void onTick(long millisUntilFinished) {
                        isCountingDown = true;
                        aliveTime.setText(Long.toString(millisUntilFinished / 1000));
                    }

                    public void onFinish() {
                        isCountingDown = false;
                        Log.d("Biometric scanner ::", "TIMEOUT");
                        aliveTime.setText("0"); // Timeout. Close the scanner and pass message to JS layer.
                        BH_Face_Alive.error = "-1";
                        finish();
                    }
                };
                Log.d("CountdownTimer ::", "Start");
                countDownTimer.start();
            }
        });
    }

    private void playAnimation(int actionType) {
        animationDrawable.stop(); // Stop the previous animation.
        animationDrawable = null; // Clear the previous animation.
        animationDrawable = new AnimationDrawable(); // Reinstantiate a new animation.
        switch (actionType) {
            case NativeMotion.CV_LIVENESS_BLINK:
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt), 1500);
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt_eye), 1500);
                stepTip = R.string.txt_blink;
                break;
            case NativeMotion.CV_LIVENESS_MOUTH:
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt), 1500);
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt_mouth), 1500);
                stepTip = R.string.txt_mouth;
                break;
            case NativeMotion.CV_LIVENESS_HEADNOD:
                // No animation is provided for head nodding.
                // TODO: Add an animation.
                stepTip = R.string.txt_nod;
                break;
            case NativeMotion.CV_LIVENESS_HEADYAW:
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt), 1000);
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt_y), 1000);
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt), 1000);
                animationDrawable.addFrame(getResources().getDrawable(R.drawable.yt_z), 1000);
                stepTip = R.string.txt_yaw;
                break;
        }
        txt_note.setText(stepTip);
        animationDrawable.setOneShot(false);
        aliveImage.setImageDrawable(animationDrawable);
        animationDrawable.start();
    }

    private void destroyExecutor() {
        if (mLivenessExecutor == null) {
            return;
        }
        mLivenessExecutor.shutdown();
        try {
            mLivenessExecutor.awaitTermination(100, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        mLivenessExecutor = null;
    }

    public void aliveFinish() {
        mIsStopped = true;
        MediaController.getInstance().release();
        MotionLivenessApi.getInstance().release();
        destroyExecutor();
        BH_Face_Alive.result = uploadImgPath;
        finish();
    }

    byte[] dataBy = null;

    private void saveLivenessImage() {
        List<byte[]> images = MotionLivenessApi.getInstance().getLastDetectImages();
        if (images != null && !images.isEmpty()) {
            uploadImgPath = LivenessActivity.this.getExternalFilesDir(null) + FILES_PATH + "image" + ".jpg";

            dataBy = images.get(0);

            Bitmap bitmap = BitmapFactory.decodeByteArray(dataBy, 0, dataBy.length);
            Bitmap nbmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), null, false);

            FileOutputStream fos = null;
            try {
                fos = new FileOutputStream(uploadImgPath);
                nbmp = ImageHelper.resizeBitmap(nbmp, 240, 320);
                nbmp.compress(Bitmap.CompressFormat.JPEG, 35, fos);
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (fos != null) {
                    try {
                        fos.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        aliveFinish();
    }

    // 开始检测
    private void switchToDetectState() {
        mState = new DetectState();
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                head_img.setImageResource(R.drawable.icon_user_face);
                mIsStopped = true;
                destroyExecutor();
                startDetectThread();
                switchMotion(0);
            }
        });
    }

    @Override
    protected void onPause() {
        MediaController.getInstance().release();
        MotionLivenessApi.getInstance().release();
        destroyExecutor();
        Log.d("Biometric Scanner ::", "ON PAUSE!");
        finish();
        super.onPause();
    }


    boolean flag = true;// 是不是第一次消息返回判断

    public void nextAction(final int arg) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final String url = "javascript:nextAction(" + arg + ")";
                // mWebView.loadUrl(url);
            }
        });

    }

}
