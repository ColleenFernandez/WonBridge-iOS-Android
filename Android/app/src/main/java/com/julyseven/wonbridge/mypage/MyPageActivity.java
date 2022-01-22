package com.julyseven.wonbridge.mypage;

import android.Manifest;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.view.View;
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
import com.julyseven.wonbridge.base.CommonTabActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.register.LoginActivity;
import com.julyseven.wonbridge.register.SelectCountryActivity;
import com.julyseven.wonbridge.timeline.TimelineListActivity;
import com.julyseven.wonbridge.utils.BitmapUtils;
import com.julyseven.wonbridge.utils.MultiPartRequest;
import com.soundcloud.android.crop.Crop;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class MyPageActivity extends CommonTabActivity implements View.OnClickListener {

    ImageView ui_imvProfile, ui_imvMyLocation, ui_imvMyTimeline;
    TextView ui_txvNickname, ui_txvSchool, ui_txvVillage, ui_txvCountry2, ui_txvWorking, ui_txvInterest;

    UserEntity _user;

    private Uri _imageCaptureUri;
    String _photoPath = "";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mypage);

        _user = Commons.g_user;

        loadLayout();
    }

    @Override
    public void loadLayout() {

        super.loadLayout();

        ui_lytMyPage.setBackgroundColor(0xff23262b);
        ui_txvMyPage.setTextColor(getResources().getColor(R.color.colorWhiteBlue));
        ui_imvMyPage.setImageResource(R.drawable.button_user_on);

        ui_imvProfile = (ImageView) findViewById(R.id.imv_profile);
        Glide.with(this).load(_user.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(ui_imvProfile);
        ui_imvProfile.setOnClickListener(this);

        TextView txvEmail = (TextView) findViewById(R.id.txv_email);
        txvEmail.setText(_user.get_email());

        ui_txvNickname = (TextView) findViewById(R.id.txv_nickname);
        ui_txvNickname.setText(_user.get_name());
        ui_txvNickname.setOnClickListener(this);

        TextView txvSex = (TextView) findViewById(R.id.txv_sex);
        txvSex.setText(_user.get_sex() == 0? getString(R.string.man) : getString(R.string.woman));

        TextView txvCustomId = (TextView) findViewById(R.id.txv_customId);

        ui_imvMyLocation = (ImageView) findViewById(R.id.imv_mylocation);
        ui_imvMyLocation.setSelected(_user.is_isPublicLocation());
        ui_imvMyLocation.setOnClickListener(this);

        ui_imvMyTimeline = (ImageView) findViewById(R.id.imv_mytimeline);
        ui_imvMyTimeline.setSelected(_user.is_isPublicTimeline());
        ui_imvMyTimeline.setOnClickListener(this);

        ImageView imvPromember = (ImageView) findViewById(R.id.imv_promember);
        imvPromember.setOnClickListener(this);

        ImageView imvHelp = (ImageView) findViewById(R.id.imv_help);
        imvHelp.setOnClickListener(this);

        ImageView imvSetting = (ImageView) findViewById(R.id.imv_setting);
        imvSetting.setOnClickListener(this);

        LinearLayout lytMyTimeline = (LinearLayout) findViewById(R.id.lyt_mytimeline);
        lytMyTimeline.setOnClickListener(this);

        ui_txvSchool = (TextView) findViewById(R.id.txv_school);
        if (_user.get_school().length() > 0)
            ui_txvSchool.setText(_user.get_school());
        else
            ui_txvSchool.setText(getString(R.string.not_input));
        ui_txvSchool.setOnClickListener(this);

        ui_txvVillage = (TextView) findViewById(R.id.txv_village);
        if (_user.get_village().length() > 0)
            ui_txvVillage.setText(_user.get_village());
        else
            ui_txvVillage.setText(getString(R.string.not_input));
        ui_txvVillage.setOnClickListener(this);

        ui_txvCountry2 = (TextView) findViewById(R.id.txv_country2);
        if (_user.get_country2().length() > 0) {
            Locale loc = new Locale("", _user.get_country2());
            ui_txvCountry2.setText(loc.getDisplayCountry());
        } else {
            ui_txvCountry2.setText(getString(R.string.not_input));
        }
        ui_txvCountry2.setOnClickListener(this);

        ui_txvWorking = (TextView) findViewById(R.id.txv_working);
        if (_user.get_working().length() > 0)
            ui_txvWorking.setText(_user.get_working());
        else
            ui_txvWorking.setText(getString(R.string.not_input));
        ui_txvWorking.setOnClickListener(this);

        ui_txvInterest = (TextView) findViewById(R.id.txv_interest);
        if (_user.get_interest().length() > 0)
            ui_txvInterest.setText(_user.get_interest());
        else
            ui_txvInterest.setText(getString(R.string.not_input));
        ui_txvInterest.setOnClickListener(this);

        setUnRead();

    }


    public void editProfile() {

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
        } else {
            ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
        }

    }

    public void doTakePhoto() {

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        String picturePath = BitmapUtils.getTempFolderPath() + "photo_temp.png";
        _imageCaptureUri = Uri.fromFile(new File(picturePath));

        intent.putExtra(MediaStore.EXTRA_OUTPUT, _imageCaptureUri);
        startActivityForResult(intent, Constants.PICK_FROM_CAMERA);
    }


    public void doTakeGallery() {

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
                        ui_imvProfile.setImageBitmap(w_bmpSizeLimited);
                        _photoPath = outFile.getAbsolutePath();

                        uploadImage();

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

                if (resultCode == RESULT_OK){

                    try {
                        _photoPath = BitmapUtils.getRealPathFromURI(this, _imageCaptureUri);
                        beginCrop(_imageCaptureUri);
                    }catch (Exception e){
                        e.printStackTrace();
                    }
                break;
            }

            case Constants.PICK_FROM_SETTING:

                if (resultCode == RESULT_OK) {

                    Intent intent = new Intent(MyPageActivity.this, LoginActivity.class);
                    startActivity(intent);
                    finish();
                }
                break;

            case Constants.PICK_FROM_NICKNAME:

                if (resultCode == RESULT_OK) {
                    ui_txvNickname.setText(_user.get_name());
                }
            break;

            case Constants.PICK_FROM_EDITWORKING:

                if (resultCode == RESULT_OK) {
                    ui_txvWorking.setText(_user.get_working());
                }
                break;

            case Constants.PICK_FROM_EDITINTEREST:

                if (resultCode == RESULT_OK) {
                    ui_txvInterest.setText(_user.get_interest());
                }
                break;

            case Constants.PICK_FROM_EDITCOUNTRY2:

                if (resultCode == RESULT_OK) {
                    Locale loc = new Locale("", _user.get_country2());
                    ui_txvCountry2.setText(loc.getDisplayCountry());
                }
                break;

            case Constants.PICK_FROM_EDITVILLAGE:

                if (resultCode == RESULT_OK) {
                    ui_txvVillage.setText(_user.get_village());
                }
                break;

            case Constants.PICK_FROM_EDITSCHOOL:

                if (resultCode == RESULT_OK) {
                    ui_txvSchool.setText(_user.get_school());
                }
                break;
        }
    }

    private void beginCrop(Uri source) {
        Uri destination = Uri.fromFile(BitmapUtils.getOutputMediaFile(this));
        Crop.of(source, destination).asSquare().start(this);
    }


    public void uploadImage() {

        //if no profile photo
        if (_photoPath.length() == 0) {
            return;
        }

        try {

            File file = new File(_photoPath);

            Map<String, String> params = new HashMap<String, String>();
            params.put(ReqConst.PARAM_ID, String.valueOf(_user.get_idx()));

            String url = ReqConst.SERVER_URL + ReqConst.REQ_UPLOADPROFILE;

            MultiPartRequest reqMultiPart = new MultiPartRequest(url, new Response.ErrorListener() {

                @Override
                public void onErrorResponse(VolleyError error) {

                    showToast(getString(R.string.photo_upload_fail));
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
        }
    }

    public void ParseUploadImgResponse(String json){

        try{
            JSONObject response = new JSONObject(json);
            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == 0){

                _user.set_photoUrl(response.getString(ReqConst.RES_PHOTO_URL));
                showToast(getString(R.string.success_updated));
            }
            else if(result_code == 111){
                showToast(getString(R.string.photo_upload_fail));
            }
        }catch (JSONException e){
            e.printStackTrace();
        }

    }


    public void editNickname() {

        Intent intent = new Intent(MyPageActivity.this, ChangeNicknameActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_NICKNAME);
    }

    public void editWorking() {

        Intent intent = new Intent(MyPageActivity.this, ChangeWorkingActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_EDITWORKING);
    }

    public void editInerest() {

        Intent intent = new Intent(MyPageActivity.this, ChangeInterestActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_EDITINTEREST);
    }

    public void editSchool() {

        Intent intent = new Intent(MyPageActivity.this, ChangeSchoolActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_EDITSCHOOL);
    }

    public void editVillage() {

        Intent intent = new Intent(MyPageActivity.this, ChangeVillageActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_EDITVILLAGE);
    }

    public void editCountry2() {

        Intent intent = new Intent(MyPageActivity.this, SelectCountryActivity.class);
        intent.putExtra(Constants.KEY_ONLY_COUNTRY, true);
        intent.putExtra(Constants.KEY_CHANGE_COUNTRY2, true);
        startActivityForResult(intent, Constants.PICK_FROM_EDITCOUNTRY2);
    }


    public void changeShareMyLocation() {

        boolean isPublic = ui_imvMyLocation.isSelected();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETPUBLICLOCATION;
        String params = String.format("/%d/%d", Commons.g_user.get_idx(), (!isPublic)? 1 : 0);

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseLocationResponse(json);
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

    public void parseLocationResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                _user.set_isPublicLocation(!ui_imvMyLocation.isSelected());
                ui_imvMyLocation.setSelected(_user.is_isPublicLocation());
            }else {
                showAlertDialog(getString(R.string.error));
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

    }

    public void changeShareMyTimeline() {

        boolean isPublic = ui_imvMyTimeline.isSelected();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETPUBLICTIMELINE;
        String params = String.format("/%d/%d", Commons.g_user.get_idx(), (!isPublic)? 1 : 0);

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseTimelineResponse(json);
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

    public void parseTimelineResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                _user.set_isPublicTimeline(!ui_imvMyTimeline.isSelected());
                ui_imvMyTimeline.setSelected(_user.is_isPublicTimeline());
            }else {
                showAlertDialog(getString(R.string.error));
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

    }


    public void gotoPromember() {

        Intent intent = new Intent(MyPageActivity.this, ProMemberActivity.class);
        startActivity(intent);
    }


    public void gotoQA() {

        Intent intent = new Intent(MyPageActivity.this, QAActivity.class);
        startActivity(intent);
    }


    public void gotoSetting() {

        Intent intent = new Intent(MyPageActivity.this, SettingActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_SETTING);

    }

    private void gotoMyTimeline() {

        Intent intent = new Intent(MyPageActivity.this, TimelineListActivity.class);
        intent.putExtra(Constants.KEY_USER_ID, _user.get_idx());
        intent.putExtra(Constants.KEY_USERNAME, _user.get_name());
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()){

            case R.id.imv_profile:
                editProfile();
                break;

            case R.id.txv_nickname:
                editNickname();
                break;

            case R.id.txv_working:
                editWorking();
                break;

            case R.id.txv_interest:
                editInerest();
                break;

            case R.id.txv_school:
                editSchool();
                break;

            case R.id.txv_village:
                editVillage();
                break;

            case R.id.txv_country2:
                editCountry2();
                break;

            case R.id.imv_mylocation:
                changeShareMyLocation();
                break;

            case R.id.imv_mytimeline:
                changeShareMyTimeline();
                break;

            case R.id.imv_promember:
                gotoPromember();
                break;

            case R.id.imv_help:
                gotoQA();
                break;

            case R.id.imv_setting:
                gotoSetting();
                break;

            case R.id.lyt_timeline:
                gotoTimeline();
                break;
            case R.id.lyt_msg:
                gotoMessage();
                break;

            case R.id.lyt_contact:
                gotoContact();
                break;

            case R.id.lyt_service:
                gotoService();
                break;

            case R.id.lyt_mytimeline:
                gotoMyTimeline();
                break;

        }

    }



}
