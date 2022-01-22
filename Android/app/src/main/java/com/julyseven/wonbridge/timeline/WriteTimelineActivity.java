package com.julyseven.wonbridge.timeline;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.TimelineImageEditAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.utils.BitmapUtils;
import com.julyseven.wonbridge.utils.CustomMultipartRequest;
import com.soundcloud.android.crop.Crop;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.File;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class WriteTimelineActivity extends CommonActivity implements View.OnClickListener {

    public static final int MAX_CHARS = 10000;
    public static final int MAX_IMAGES = 9;

    TextView ui_txvLeaveChars, ui_txvSave;
    EditText ui_edtContent;

    RecyclerView ui_recyclerImage;
    TimelineImageEditAdapter _adapter;

    ArrayList<String> _imagePaths = new ArrayList<>();

    private Uri _imageCaptureUri;
    String _photoPath = "";

    boolean _isSaving = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_writetimeline);

        _isSaving = false;

        loadLayout();
    }

    private void loadLayout() {

        TextView txvCancel = (TextView) findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(this);

        ui_txvSave = (TextView) findViewById(R.id.txv_save);
        ui_txvSave.setOnClickListener(this);

        ImageView imvCamera = (ImageView) findViewById(R.id.imv_camera);
        imvCamera.setOnClickListener(this);

        ui_txvLeaveChars = (TextView) findViewById(R.id.txv_leaveChars);

        ui_edtContent = (EditText) findViewById(R.id.edt_content);
        ui_edtContent.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                ui_txvLeaveChars.setText(String.valueOf(MAX_CHARS - s.length()));

                if (ui_edtContent.length() > 0 || _imagePaths.size() > 0) {
                    ui_txvSave.setTextColor(0xff5f99fb);
                } else {
                    ui_txvSave.setTextColor(0xff333333);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });


        ui_recyclerImage = (RecyclerView) findViewById(R.id.recycler_image);
        LinearLayoutManager layoutManager = new LinearLayoutManager(
                this, LinearLayoutManager.HORIZONTAL, false);
        ui_recyclerImage.setLayoutManager(layoutManager);

        _adapter = new TimelineImageEditAdapter(this);
        ui_recyclerImage.setAdapter(_adapter);

        deleteAllTempImages();

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtContent.getWindowToken(), 0);
                return false;
            }
        });

    }


    public void addImage(String path) {

        _imagePaths.add(path);
        _adapter.setDatas(_imagePaths);

        if (ui_edtContent.length() > 0 || _imagePaths.size() > 0) {
            ui_txvSave.setTextColor(0xff5f99fb);
        } else {
            ui_txvSave.setTextColor(0xff333333);
        }
    }

    public void addImages(ArrayList<String> paths) {

        _imagePaths.addAll(paths);

        _adapter.setDatas(_imagePaths);

        if (ui_edtContent.length() > 0 || _imagePaths.size() > 0) {
            ui_txvSave.setTextColor(0xff5f99fb);
        } else {
            ui_txvSave.setTextColor(0xff333333);
        }
    }

    public void removeImage(String path) {

        _imagePaths.remove(path);
        _adapter.setDatas(_imagePaths);

        if (ui_edtContent.length() > 0 || _imagePaths.size() > 0) {
            ui_txvSave.setTextColor(0xff5f99fb);
        } else {
            ui_txvSave.setTextColor(0xff333333);
        }
    }

    private void onSave() {

        if (ui_edtContent.length() == 0 && _imagePaths.size() == 0) {
            showAlertDialog(getString(R.string.input_timeline_content));
            return;
        }

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtContent.getWindowToken(), 0);

        saveTimeline();

    }

    public void saveTimeline() {

        if (_isSaving) {
            showToast(getString(R.string.saving));
            return;
        }

        _isSaving = true;

        showProgress();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SAVETIMELINE;

        // has image
        if (_imagePaths.size() > 0) {

            Map<String, String> mHeaderPart= new HashMap<>();
            mHeaderPart.put("Content-type", "multipart/form-data;");

            //File part
            Map<String, File> mFilePartData= new HashMap<>();

            for (int i = 0; i < _imagePaths.size(); i++) {

                String path = _imagePaths.get(i);
                if (path.length() > 0)
                    mFilePartData.put("file[" + i + "]", new File(path));
            }


            //String part
            Map<String, String> mStringPart= new HashMap<>();
            mStringPart.put(ReqConst.PARAM_ID, String.valueOf(Commons.g_user.get_idx()));

            try {
                String content = ui_edtContent.getText().toString().trim().replace(" ", "%20");
                content = URLEncoder.encode(content, "utf-8");
                mStringPart.put(ReqConst.PARAM_CONTENT, content);
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            float lat = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
            float lng = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

            mStringPart.put(ReqConst.PARAM_LATITUDE, String.valueOf(lat));
            mStringPart.put(ReqConst.PARAM_LONGITUDE, String.valueOf(lng));

            CustomMultipartRequest mCustomRequest = new CustomMultipartRequest(Request.Method.POST, this, url, new Response.Listener<JSONObject>() {
                @Override
                public void onResponse(JSONObject jsonObject) {
                    parseUploadResponse(jsonObject.toString());
                }
            }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError volleyError) {
                    showToast(getString(R.string.fail_upload_timeline));
                    closeProgress();
                    _isSaving = false;
                }
            }, mFilePartData, mStringPart, mHeaderPart);

            mCustomRequest.setRetryPolicy(new DefaultRetryPolicy(600000,
                    0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

            WonBridgeApplication.getInstance().addToRequestQueue(mCustomRequest, url);

        } else {    // no image

            url = ReqConst.SERVER_URL + ReqConst.REQ_SAVETEXTTIMELINE;

            StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    parseUploadResponse(response);
                }
            }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {
                    showToast(getString(R.string.fail_upload_timeline));
                    closeProgress();
                    _isSaving = false;
                }
            }){
                @Override
                protected Map<String,String> getParams(){
                    Map<String,String> params = new HashMap<>();
                    params.put(ReqConst.PARAM_ID, String.valueOf(Commons.g_user.get_idx()));
                    try {
                        String content = ui_edtContent.getText().toString().trim().replace(" ", "%20");
                        content = URLEncoder.encode(content, "utf-8");
                        params.put(ReqConst.PARAM_CONTENT, content);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                    float lat = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
                    float lng = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

                    params.put(ReqConst.PARAM_LATITUDE, String.valueOf(lat));
                    params.put(ReqConst.PARAM_LONGITUDE, String.valueOf(lng));

                    return params;
                }

                @Override
                public Map<String, String> getHeaders() throws AuthFailureError {
                    Map<String,String> params = new HashMap<>();
                    params.put("Content-Type","application/x-www-form-urlencoded");
                    return params;
                }
            };

            stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                    0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

            WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
        }


    }

    public void parseUploadResponse(String json){

        closeProgress();

        _isSaving = false;

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){
                finish();
            } else {
                showAlertDialog(getString(R.string.fail_upload_timeline));
            }

        }catch (JSONException e){
            showAlertDialog(getString(R.string.fail_upload_timeline));
            e.printStackTrace();
        }

    }

    private void onSelectPhoto() {

        if (_imagePaths.size() == MAX_IMAGES) {
            showAlertDialog(getString(R.string.max_image_count_9));
            return;
        }


        String[] PERMISSIONS = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE};

        if (Commons.hasPermissions(this, PERMISSIONS)){

            final String[] items = {getString(R.string.take_photo), getString(R.string.choose_gallery), getString(R.string.cancel)};

            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setItems(items, new DialogInterface.OnClickListener() {

                public void onClick(DialogInterface dialog, int item) {
                    if (item == 0) {
                        doTakePhoto();

                    } else if (item == 1) {
                        doTakeGallery();
                    } else {

                    }
                }
            });
            AlertDialog alert = builder.create();
            alert.show();
        }else {
            ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
        }
    }

    public void doTakePhoto(){

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        String picturePath = BitmapUtils.getTempFolderPath() + "photo_temp.png";
        _imageCaptureUri = Uri.fromFile(new File(picturePath));

        intent.putExtra(MediaStore.EXTRA_OUTPUT, _imageCaptureUri);
        startActivityForResult(intent, Constants.PICK_FROM_CAMERA);

    }

    private void doTakeGallery(){

//        Intent intent = new Intent(Intent.ACTION_PICK);
//        intent.setType(MediaStore.Images.Media.CONTENT_TYPE);
//        startActivityForResult(intent, Constants.PICK_FROM_ALBUM);

        Intent intent = new Intent(WriteTimelineActivity.this, SelectImageActivity.class);
        intent.putExtra(Constants.KEY_COUNT, _imagePaths.size());
        startActivityForResult(intent, Constants.PICK_FROM_IMAGES);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data){

        switch (requestCode){

            case Crop.REQUEST_CROP: {

                if (resultCode == RESULT_OK){
                    try {

                        File outFile = new File(_photoPath);

                        InputStream in = getContentResolver().openInputStream(Uri.fromFile(outFile));
                        BitmapFactory.Options bitOpt = new BitmapFactory.Options();
                        Bitmap bitmap = BitmapFactory.decodeStream(in, null, bitOpt);
                        in.close();

                        ExifInterface ei = new ExifInterface(outFile.getAbsolutePath());
                        int orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                                ExifInterface.ORIENTATION_NORMAL);

                        Bitmap returnedBitmap = bitmap;

                        switch (orientation) {

                            case ExifInterface.ORIENTATION_ROTATE_90:
                                returnedBitmap = BitmapUtils.rotateImage(bitmap, 90);
                                // Free up the memory
                                bitmap.recycle();
                                bitmap = null;
                                break;
                            case ExifInterface.ORIENTATION_ROTATE_180:
                                returnedBitmap = BitmapUtils.rotateImage(bitmap, 180);
                                // Free up the memory
                                bitmap.recycle();
                                bitmap = null;
                                break;
                            case ExifInterface.ORIENTATION_ROTATE_270:
                                returnedBitmap = BitmapUtils.rotateImage(bitmap, 270);
                                // Free up the memory
                                bitmap.recycle();
                                bitmap = null;
                                break;

                            default:
                                returnedBitmap = bitmap;
                        }

                        Bitmap w_bmpSizeLimited = Bitmap.createScaledBitmap(returnedBitmap, Constants.PROFILE_IMAGE_SIZE, Constants.PROFILE_IMAGE_SIZE, true);

                        BitmapUtils.saveOutput(outFile, w_bmpSizeLimited);

                        _photoPath = outFile.getAbsolutePath();
                        addImage(_photoPath);

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                break;
            }

            case Constants.PICK_FROM_IMAGES:

                if (resultCode == RESULT_OK){
                    ArrayList<String> paths = data.getStringArrayListExtra(Constants.KEY_IMAGES);
                    addImages(paths);
                }

                break;

            case Constants.PICK_FROM_ALBUM:

                if (resultCode == RESULT_OK) {
                    _imageCaptureUri = data.getData();
                }

            case Constants.PICK_FROM_CAMERA:
            {
                if (resultCode == RESULT_OK) {
                    try {

                        _photoPath = BitmapUtils.getRealPathFromURI(this, _imageCaptureUri);
                        //beginCrop(_imageCaptureUri);
                        showProgress();

                        new AsyncTask<Void, Void, Void>() {
                            @Override
                            protected Void doInBackground(Void... params) {
                                // We send the message here.
                                // You should also check if the username is valid here.
                                try {
                                    selectPhoto();
                                } catch (Exception e) {
                                }
                                return null;
                             }

                            @Override
                            protected void onPostExecute(Void aVoid) {
                                super.onPostExecute(aVoid);
                                closeProgress();
                                addImage(_photoPath);
                            }
                        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                break;
            }
        }
    }

    private void selectPhoto() {

        try {

            Bitmap returnedBitmap = BitmapUtils.loadOrientationAdjustedBitmap(_photoPath);

            File outFile = getOutputMediaFile();

            BitmapUtils.saveOutput(outFile, returnedBitmap);
            returnedBitmap.recycle();
            returnedBitmap = null;

            _photoPath = outFile.getAbsolutePath();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void beginCrop(Uri source) {

        File outFile = getOutputMediaFile();
        Uri destination = Uri.fromFile(outFile);
        _photoPath = outFile.getAbsolutePath();
        Crop.of(source, destination).asSquare().start(this);
    }


    public void deleteAllTempImages() {

        File mediaStorageDir = new File(
                Environment.getExternalStorageDirectory() + "/android/data/"
                        + this.getPackageName() + "/timeline");

        if (!mediaStorageDir.exists()) {
            if (!mediaStorageDir.mkdirs()) {
                return;
            }
        } else {
            String[] children = mediaStorageDir.list();
            for (int i = 0; i < children.length; i++)
            {
                new File(mediaStorageDir, children[i]).delete();
            }
        }
    }

    public File getOutputMediaFile() {

        File mediaStorageDir = new File(
                Environment.getExternalStorageDirectory() + "/android/data/"
                        + this.getPackageName() + "/timeline");

        if (!mediaStorageDir.exists()) {
            if (!mediaStorageDir.mkdirs()) {
                return null;
            }
        }

        long random = new Date().getTime();

        File mediaFile = new File(mediaStorageDir.getPath() + File.separator
                + "temp" + random + ".png");

        return mediaFile;
    }


    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.txv_cancel:
                onBack();
                break;

            case R.id.txv_save:
                onSave();
                break;

            case R.id.imv_camera:
                onSelectPhoto();
                break;


        }

    }



}
