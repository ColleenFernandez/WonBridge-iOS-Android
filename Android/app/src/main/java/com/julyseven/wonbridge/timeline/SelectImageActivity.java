package com.julyseven.wonbridge.timeline;

import android.app.Dialog;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.FriendSelectAdapter;
import com.julyseven.wonbridge.adapter.ImageGalleryAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.utils.BitmapUtils;
import com.julyseven.wonbridge.utils.Database;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.TimeZone;


public class SelectImageActivity extends CommonActivity implements View.OnClickListener{

    private TextView ui_txvConfirm;
    private ImageView ui_imvBack;
    private GridView ui_gridView;
    private ImageGalleryAdapter _imageAdapter;
    private ArrayList<String> _imageUrls = new ArrayList<>();
    private ArrayList<String> _selectedImages = new ArrayList<>();
    public int _existCount = 0;


    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_image);

        _existCount = getIntent().getIntExtra(Constants.KEY_COUNT, 0);

        loadLayout();
    }


    private void loadLayout(){

        ui_txvConfirm = (TextView)findViewById(R.id.txv_confirm);
        ui_txvConfirm.setOnClickListener(this);

        ui_imvBack = (ImageView)findViewById(R.id.imv_back);
        ui_imvBack.setOnClickListener(this);

        ui_gridView = (GridView) findViewById(R.id.grid_image);

        loadImages();
    }

    public void loadImages() {

        if (_imageUrls.size() == 0) {

            final String[] columns = {MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID};

            Cursor imagecursor = managedQuery(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
                    null, MediaStore.Images.Media.DATE_TAKEN + " DESC");

            for (int i = 0; i < imagecursor.getCount(); i++) {
                imagecursor.moveToPosition(i);
                int dataColumnIndex = imagecursor.getColumnIndex(MediaStore.Images.Media.DATA);
                _imageUrls.add(imagecursor.getString(dataColumnIndex));

            }
        }

        _imageAdapter = new ImageGalleryAdapter(this, _imageUrls);
        ui_gridView.setAdapter(_imageAdapter);

    }


    public void displayCount() {

        int count = _imageAdapter.getCheckedItems().size();

        if (count == 0)
            ui_txvConfirm.setText(getString(R.string.confirm));
        else
            ui_txvConfirm.setText(getString(R.string.confirm) + "(" + count + ")");

    }


    public void onConfirm() {

        _selectedImages.clear();

        if (_imageAdapter.getCheckedItems().size() == 0) return;

        for (String path : _imageAdapter.getCheckedItems()) {

            String filename = Commons.fileNameWithoutExtFromUrl(path) + ".png";

            Bitmap w_bmpGallery = BitmapUtils.loadOrientationAdjustedBitmap(path);

            String w_strLimitedImageFilePath = BitmapUtils.getUploadImageFilePath(w_bmpGallery, filename);

            if (w_strLimitedImageFilePath != null) {
                path = w_strLimitedImageFilePath;
            }

            _selectedImages.add(path);

        }

        Intent intent = new Intent();
        intent.putExtra(Constants.KEY_IMAGES, _selectedImages);
        setResult(RESULT_OK, intent);
        finish();

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){

            case R.id.imv_back:
                finish();
                break;
            case R.id.txv_confirm:
                onConfirm();
                break;
        }
    }
}
