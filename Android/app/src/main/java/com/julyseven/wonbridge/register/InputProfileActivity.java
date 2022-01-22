package com.julyseven.wonbridge.register;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.utils.BitmapUtils;
import com.julyseven.wonbridge.utils.MultiPartRequest;
import com.soundcloud.android.crop.Crop;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

public class InputProfileActivity extends CommonActivity implements View.OnClickListener {

    private String _email;
    private String _phonenumber;
    private String _wechatId;
    private String _qqId;

    private int _sex = 0;
    private EditText ui_edtNickname, ui_edtPwd, ui_edtConfirm;
    private TextView ui_txvSex;
    private ImageView ui_imvPhoto;

    private Uri _imageCaptureUri;
    String _photoPath = "";
    String _photoUrl = "";

    private LinearLayout ui_rootView;

    private int _idx = 0;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_input_profile);

        _email = getIntent().getStringExtra(Constants.KEY_EMAIL);
        _phonenumber = getIntent().getStringExtra(Constants.KEY_PHONENUMBER);
        _wechatId = getIntent().getStringExtra(Constants.KEY_WECHATID);
        _qqId = getIntent().getStringExtra(Constants.KEY_QQID);

        loadLayout();

        checkKeyboardHeight();
    }

    private void checkKeyboardHeight() {

        ui_rootView = (LinearLayout) findViewById(R.id.lyt_container);

        ui_rootView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                Rect r = new Rect();

                ui_rootView.getWindowVisibleDisplayFrame(r);

                int screenHeight = ui_rootView.getRootView().getHeight();
                int keyboardHeight = screenHeight - (r.bottom);

                if (keyboardHeight > 150) {

                    if (keyboardHeight != Preference.getInstance().getValue(InputProfileActivity.this, PrefConst.KEYBOARD_HEIGHT, 0))
                        Preference.getInstance().put(InputProfileActivity.this, PrefConst.KEYBOARD_HEIGHT, keyboardHeight);
                }
            }
        });
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.register_profile));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvEmail = (TextView) findViewById(R.id.txv_email);

        if (_email != null)
            txvEmail.setText(_email);
        else if (_phonenumber != null)
            txvEmail.setText("+" + _phonenumber);
        else if (_wechatId != null)
            txvEmail.setText(_wechatId);
        else if (_qqId != null)
            txvEmail.setText(_qqId);

        ImageView imvCamera = (ImageView) findViewById(R.id.imv_camera);
        imvCamera.setOnClickListener(this);

        ui_imvPhoto = (ImageView) findViewById(R.id.imv_photo);

        if (_wechatId != null) {

            final String wechatPhotoUrl = Preference.getInstance().getValue(this, PrefConst.PREFKEY_WECHAT_PHOTOURL, null);

            if (wechatPhotoUrl != null) {

                new Thread(new Runnable() {
                    @Override
                    public void run() {

                        final Bitmap bitmap = BitmapUtils.getBitmapFromURL(wechatPhotoUrl);
                        final File outFile = BitmapUtils.getOutputMediaFile(InputProfileActivity.this);

                        if (outFile != null && bitmap != null) {
                            BitmapUtils.saveOutput(outFile, bitmap);

                            //set The bitmap data to image View
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    ui_imvPhoto.setImageBitmap(bitmap);
                                    _photoPath = outFile.getAbsolutePath();
                                }
                            });
                        }

                    }
                }).start();
            }
        } else if (_qqId != null) {

            final String qqPhotoUrl = Preference.getInstance().getValue(this, PrefConst.PREFKEY_QQ_PHOTOURL, null);

            if (qqPhotoUrl != null) {

                new Thread(new Runnable() {
                    @Override
                    public void run() {

                        final Bitmap bitmap = BitmapUtils.getBitmapFromURL(qqPhotoUrl);
                        final File outFile = BitmapUtils.getOutputMediaFile(InputProfileActivity.this);

                        if (outFile != null && bitmap != null) {
                            BitmapUtils.saveOutput(outFile, bitmap);

                            //set The bitmap data to image View
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    ui_imvPhoto.setImageBitmap(bitmap);
                                    _photoPath = outFile.getAbsolutePath();
                                }
                            });
                        }

                    }
                }).start();
            }
        }

        ui_edtNickname = (EditText) findViewById(R.id.edt_nickname);

        if (_wechatId != null) {
            String nick = Preference.getInstance().getValue(this, PrefConst.PREFKEY_WECHAT_NICKNAME, null);
            if (nick != null)
                ui_edtNickname.setText(nick);
        } else if (_qqId != null) {

            String nick = Preference.getInstance().getValue(this, PrefConst.PREFKEY_QQ_NICKNAME, null);
            if (nick != null)
                ui_edtNickname.setText(nick);
        }

        TextView txvConflict = (TextView) findViewById(R.id.txv_conflict);
        txvConflict.setOnClickListener(this);

        ui_txvSex = (TextView) findViewById(R.id.txv_sex);
        ui_txvSex.setOnClickListener(this);

        ui_edtPwd = (EditText) findViewById(R.id.edt_pwd);
        ui_edtConfirm = (EditText) findViewById(R.id.edt_pwd_confirm);

        if (_wechatId != null || _qqId != null) {
            LinearLayout lytPwd = (LinearLayout) findViewById(R.id.lyt_pwd);
            lytPwd.setVisibility(View.GONE);
            LinearLayout lytConfirmPwd = (LinearLayout) findViewById(R.id.lyt_pwd_confirm);
            lytConfirmPwd.setVisibility(View.GONE);
        }

        TextView txvRegister = (TextView) findViewById(R.id.txv_register);
        txvRegister.setOnClickListener(this);

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtNickname.getWindowToken(), 0);
                return false;
            }
        });

        FrameLayout fltPhoto = (FrameLayout) findViewById(R.id.flt_photo);
        fltPhoto.setOnClickListener(this);

    }

    private boolean checkValid() {

        if (ui_edtNickname.getText().length() < 2) {
            showAlertDialog(getString(R.string.input_nickname));
            return false;
        }

        if (ui_txvSex.getText().toString().equals(getString(R.string.select_sex))) {
            showAlertDialog(getString(R.string.input_sex));
            return false;
        }

        if (_wechatId == null && _qqId == null) {

            if (ui_edtPwd.getText().length() < 4) {
                showAlertDialog(getString(R.string.input_pwd));
                return false;
            }

            if (!ui_edtPwd.getText().toString().equals(ui_edtConfirm.getText().toString())) {
                showAlertDialog(getString(R.string.input_confirm));
                return false;
            }
        }


        return true;
    }

    private void onConfirmConflict() {

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtNickname.getWindowToken(), 0);

        if (ui_edtNickname.getText().length() < 2) {
            showAlertDialog(getString(R.string.input_nickname));
            return;
        }

        checkNickname();
    }

    private void onSelectSex() {

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(getString(R.string.select_sex));

        final String[] items = {getString(R.string.man), getString(R.string.woman)};

        builder.setItems(items, new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int item) {
                _sex = item;
                ui_txvSex.setText(items[_sex]);
            }
        });
        AlertDialog alert = builder.create();
        alert.show();

    }

    private void checkNickname() {


        String url = ReqConst.SERVER_URL + ReqConst.REQ_CHECKNICKNAME;

        String nickname = ui_edtNickname.getText().toString().replace(" ", "%20");
        nickname = nickname.replace("/", Constants.SLASH);

        try {
            nickname = URLEncoder.encode(nickname, "utf-8");
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String params = String.format("/%s", nickname);

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseNicknameResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseNicknameResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){

                showAlertDialog(getString(R.string.nick_available));

            }else {
                showAlertDialog(getString(R.string.nick_confiict));
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

    }

    private void onSelectPhoto() {

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

        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType(MediaStore.Images.Media.CONTENT_TYPE);
        startActivityForResult(intent, Constants.PICK_FROM_ALBUM);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data){

        switch (requestCode){

            case Crop.REQUEST_CROP: {

                if (resultCode == RESULT_OK){
                    try {

                        File outFile = BitmapUtils.getOutputMediaFile(this);

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

                        //set The bitmap data to image View
                        ui_imvPhoto.setImageBitmap(w_bmpSizeLimited);
                        _photoPath = outFile.getAbsolutePath();

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                break;
            }
            case Constants.PICK_FROM_ALBUM:

                if (resultCode == RESULT_OK){
                    _imageCaptureUri = data.getData();
                }

            case Constants.PICK_FROM_CAMERA:
            {
                if (resultCode == RESULT_OK) {
                    try {

                        _photoPath = BitmapUtils.getRealPathFromURI(this, _imageCaptureUri);
                        beginCrop(_imageCaptureUri);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                break;
            }
        }
    }

    private void beginCrop(Uri source) {
        Uri destination = Uri.fromFile(BitmapUtils.getOutputMediaFile(this));
        Crop.of(source, destination).asSquare().start(this);
    }

    private void onRegister() {

        if (checkValid()) {
            register();
        }
    }

    private void register() {

        String url = ReqConst.SERVER_URL;

        if (_email != null)
            url += ReqConst.REQ_REGISTER;
        else if (_phonenumber != null)
            url += ReqConst.REQ_REGISTERWITHPHONE;
        else if (_wechatId != null)
            url += ReqConst.REQ_REGISTERWITHWECHAT;
        else if (_qqId != null)
            url += ReqConst.REQ_REGISTERWITHQQ;

        try {
            String name = ui_edtNickname.getText().toString().trim().replace(" ", "%20");
            name = name.replace("/", Constants.SLASH);
            name = URLEncoder.encode(name, "utf-8");
            String params = "";

            if (_email != null)
                params = String.format("/%s/%s/%d/%s", _email, name, _sex, ui_edtPwd.getText().toString());
            else if (_phonenumber != null)
                params = String.format("/%s/%s/%d/%s", _phonenumber, name, _sex, ui_edtPwd.getText().toString());
            else if (_wechatId != null)
                params = String.format("/%s/%s/%d/%s", _wechatId, name, _sex, Constants.DEFAULT_WECHAT_PWD.toString());
            else if (_qqId != null)
                params = String.format("/%s/%s/%d/%s", _qqId, name, _sex, Constants.DEFAULT_QQ_PWD.toString());

            url += params;

        } catch (Exception ex) {
            return;
        }

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url , new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseRegisterResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError volleyError) {

                closeProgress();
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseRegisterResponse(String json){

        try{
            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){

                _idx = response.getInt(ReqConst.RES_ID);

                uploadImage();

            } else if (result_code == 102){

                closeProgress();
                showAlertDialog(getString(R.string.exist_email));

            }else if (result_code == 112){
                closeProgress();
                showAlertDialog(getString(R.string.exist_phone));

            }else if (result_code == 118){

                closeProgress();
                showAlertDialog(getString(R.string.exist_wechat));

            }else if (result_code == 101){

                closeProgress();
                showAlertDialog(getString(R.string.nick_confiict));
            } else {
                closeProgress();
                showAlertDialog(getString(R.string.register_fail));
            }

        } catch (JSONException e){
            closeProgress();
            showAlertDialog(getString(R.string.register_fail));

            e.printStackTrace();
        }

    }

    /*Upload the userPhoto to server*/
    public void uploadImage() {

        //if no profile photo
        if (_photoPath.length() == 0) {

            onSuccessRegister();
            return;
        }

        try {

            File file = new File(_photoPath);

            Map<String, String> params = new HashMap<String, String>();
            params.put(ReqConst.PARAM_ID, String.valueOf(_idx));

            String url = ReqConst.SERVER_URL + ReqConst.REQ_UPLOADPROFILE;

            MultiPartRequest reqMultiPart = new MultiPartRequest(url, new Response.ErrorListener() {

                @Override
                public void onErrorResponse(VolleyError error) {

                    showToast(getString(R.string.photo_upload_fail));
                    onSuccessRegister();
                }
            }, new Response.Listener<String>() {

                @Override
                public void onResponse(String json) {

                    ParseUploadImgResponse(json);
                }
            }, file, ReqConst.PARAM_FILE, params);

            reqMultiPart.setRetryPolicy(new DefaultRetryPolicy(
                    Constants.VOLLEY_TIME_OUT, 0,
                    DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

            WonBridgeApplication.getInstance().addToRequestQueue(reqMultiPart, url);

        } catch (Exception e) {

            e.printStackTrace();

            showToast(getString(R.string.photo_upload_fail));
            onSuccessRegister();
        }
    }

    public void ParseUploadImgResponse(String json){

        try{
            JSONObject response = new JSONObject(json);
            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == 0){
                _photoUrl = response.getString(ReqConst.RES_PHOTO_URL);
            }
            else if(result_code == 111){
                showToast(getString(R.string.photo_upload_fail));
            }
        }catch (JSONException e){
            e.printStackTrace();
        }

        onSuccessRegister();
    }


    private void onSuccessRegister() {

        UserEntity userEntity = new UserEntity();

        userEntity.set_name(ui_edtNickname.getText().toString());

        if (_email != null)
            userEntity.set_email(_email);
        else if (_phonenumber != null)
            userEntity.set_phoneNumber(_phonenumber);
        else if (_wechatId != null)
            userEntity.set_wechatId(_wechatId);
        else if (_qqId != null)
            userEntity.set_qqId(_qqId);

        userEntity.set_idx(_idx);
        userEntity.set_photoUrl(_photoUrl);
        userEntity.set_sex(_sex);
        userEntity.set_password(ui_edtPwd.getText().toString());

        Commons.g_user = userEntity;

        Intent intent = new Intent(InputProfileActivity.this, InputUserInfoActivity.class);

        if (_photoPath.length() > 0) {
            intent.putExtra(Constants.KEY_PHOTOPATH, _photoPath);
        }

        startActivity(intent);
        finish();
    }

    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;

            case R.id.txv_conflict:
                onConfirmConflict();
                break;

            case R.id.txv_sex:
                onSelectSex();
                break;

            case R.id.txv_register:
                onRegister();
                break;

            case R.id.flt_photo:
                onSelectPhoto();
                break;

        }

    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if(grantResults[0]== PackageManager.PERMISSION_GRANTED){
            //resume tasks needing this permission
        }
    }


}
