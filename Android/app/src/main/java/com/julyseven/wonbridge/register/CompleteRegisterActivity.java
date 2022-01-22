package com.julyseven.wonbridge.register;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;

public class CompleteRegisterActivity extends CommonActivity implements View.OnClickListener {

    UserEntity _user;
    String _photoPath = "";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register_complete);

        _user = Commons.g_user;

        if (getIntent().getStringExtra(Constants.KEY_PHOTOPATH) != null) {
            _photoPath = getIntent().getStringExtra(Constants.KEY_PHOTOPATH);
        }
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.register_profile));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);
        imvBack.setVisibility(View.GONE);

        TextView txvUpdate = (TextView) findViewById(R.id.txv_update);
        txvUpdate.setOnClickListener(this);

        TextView txvComplete = (TextView) findViewById(R.id.txv_ok);
        txvComplete.setOnClickListener(this);

        TextView txvCountry= (TextView) findViewById(R.id.txv_countryname);
        txvCountry.setText(Commons.getCountryName(this));

        ImageView imvPhoto = (ImageView) findViewById(R.id.imv_photo);

        if (_photoPath.length() > 0) {
            BitmapFactory.Options bmOptions = new BitmapFactory.Options();
            Bitmap bitmap = BitmapFactory.decodeFile(_photoPath,bmOptions);
            imvPhoto.setImageBitmap(bitmap);
        } else {
            imvPhoto.setImageResource(R.drawable.img_user);
        }
//        Glide.with(this).load(_user.get_photoUrl()).placeholder(R.drawable.img_user).into(imvPhoto);

        TextView txvEmail = (TextView) findViewById(R.id.txv_email);

        if (_user.get_email() != null && _user.get_email().length() > 0)
            txvEmail.setText(_user.get_email());
        else
            txvEmail.setText(_user.get_phoneNumber());

        TextView txvName = (TextView) findViewById(R.id.txv_nickname);
        txvName.setText(_user.get_name());

        String sex[] = {getString(R.string.man), getString(R.string.woman)};
        TextView txvSex = (TextView) findViewById(R.id.txv_sex);
        txvSex.setText(sex[_user.get_sex()]);

        TextView txvPwd = (TextView) findViewById(R.id.txv_pwd);

        int pwdLength = _user.get_password().length();

        String pwd = "";
        if (pwdLength <= 4) {

            for (int i = 0; i < pwdLength; i++) {
                pwd += "*";
            }

        } else {

            pwd = _user.get_password().substring(0, 4);

            for (int i = 0; i < pwdLength - 4; i++) {
                pwd += "*";
            }

        }

        txvPwd.setText(pwd);


    }

    private void updateProfile() {

        showToast("Coming Soon!");
    }

    private void onComplete() {

        if (_user.get_email().length() > 0)
            Preference.getInstance().put(this, PrefConst.PREFKEY_USEREMAIL, _user.get_email());
        else if (_user.get_phoneNumber().length() > 0)
            Preference.getInstance().put(this, PrefConst.PREFKEY_USEREMAIL, _user.get_phoneNumber());
        else if (_user.get_wechatId().length() > 0)
            Preference.getInstance().put(this, PrefConst.PREFKEY_WECHATID, _user.get_wechatId());
        else if (_user.get_qqId().length() > 0)
            Preference.getInstance().put(this, PrefConst.PREFKEY_QQID, _user.get_qqId());

        Preference.getInstance().put(this, PrefConst.PREFKEY_USERPWD, _user.get_password());

        Intent intent = new Intent(CompleteRegisterActivity.this, LoginActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
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
                break;

            case R.id.txv_update:
                updateProfile();
                break;

            case R.id.txv_ok:
                onComplete();
                break;

        }

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            onComplete();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

}
