package com.julyseven.wonbridge.timeline;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.LikeUserGridAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.FriendEntity;

import java.util.ArrayList;

public class LikeUsersActivity extends CommonActivity implements View.OnClickListener {

    ArrayList<FriendEntity> _likeUsers = new ArrayList<>();
    String _username = "";

    GridView ui_gridView;
    LikeUserGridAdapter _adapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_like_users);

        _username = getIntent().getStringExtra(Constants.KEY_USERNAME);
        _likeUsers = (ArrayList<FriendEntity>) getIntent().getSerializableExtra(Constants.KEY_LIKEUSER);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(_username + ": " + getString(R.string.like_users));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_gridView = (GridView) findViewById(R.id.grd_users);

        _adapter = new LikeUserGridAdapter(this);
        ui_gridView.setAdapter(_adapter);
        _adapter.setDatas(_likeUsers);

        ui_gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long l) {

                Intent intent = new Intent(LikeUsersActivity.this, UserProfileActivity.class);
                intent.putExtra(Constants.KEY_FRIEND, (FriendEntity) _adapter.getItem(position));
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(intent);

            }
        });

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



        }

    }


}
