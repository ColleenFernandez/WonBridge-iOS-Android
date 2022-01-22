package com.julyseven.wonbridge.Chatting;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.GroupEntity;

public class GroupProfileActivity extends CommonActivity implements View.OnClickListener{

    GroupEntity _group;

    TextView ui_txvTitle, ui_txvCount, ui_txvGroupName;
    ImageView ui_imvGroupProfile;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_profile);

        GroupEntity group = (GroupEntity) getIntent().getSerializableExtra(Constants.KEY_GROUP);

        _group = Commons.g_user.getGroup(group.get_groupName());

        if (_group == null)
            _group = group;

        loadLayout();
    }

    private void loadLayout() {

        ui_txvTitle = (TextView) findViewById(R.id.header_title);

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_imvGroupProfile = (ImageView) findViewById(R.id.imv_profile);
        ui_imvGroupProfile.setOnClickListener(this);
        Glide.with(_context).load(_group.get_groupProfileUrl()).placeholder(R.drawable.img_group).error(R.drawable.img_group).into(ui_imvGroupProfile);

        ui_txvGroupName = (TextView) findViewById(R.id.txv_groupname);
        ui_txvGroupName.setOnClickListener(this);

        ui_txvCount = (TextView) findViewById(R.id.txv_member_count);

        updateUI();

    }


    public void updateUI() {

        ui_txvGroupName.setText(_group.get_groupNickname());

        int memberCount = _group.getMemeberCount();

        ui_txvTitle.setText(getString(R.string.group_info) + String.format("(%d)", memberCount));
        ui_txvCount.setText(getString(R.string.group_member_count) + String.format("(%d)", memberCount));

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
