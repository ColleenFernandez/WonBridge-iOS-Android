package com.julyseven.wonbridge.timeline;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import com.appyvet.rangebar.RangeBar;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;


public class FilterActivity extends CommonActivity implements View.OnClickListener {

    TextView ui_txvDistance, ui_txvAge, ui_txvSexAll, ui_txvSexMan, ui_txvSexWoman;
    TextView ui_txvRecentOnline, ui_txvRecent1dayAgo, ui_txvRecent3daysAgo, ui_txvRecent7daysAgo;
    TextView ui_txvRelationAll, ui_txvRelationFriend;

    RangeBar ui_rangeDistance, ui_rangeAge;

    int _ageStart, _ageEnd, _distance;
    int _sex;   // 0:man, 1:woman, 2:all
    int _lastLogin; // 0:online, 1:1day ago, 3:3days ago, 7:7days ago
    int _relation;  // 0: all, 1: friend

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_filter);

        loadLayout();

        initValues();
    }


    private void loadLayout() {

        ui_txvDistance = (TextView) findViewById(R.id.txv_distance);
        ui_txvAge = (TextView) findViewById(R.id.txv_age);

        ui_txvSexAll = (TextView) findViewById(R.id.txv_sex_all);
        ui_txvSexAll.setOnClickListener(this);
        ui_txvSexMan = (TextView) findViewById(R.id.txv_sex_man);
        ui_txvSexMan.setOnClickListener(this);
        ui_txvSexWoman = (TextView) findViewById(R.id.txv_sex_woman);
        ui_txvSexWoman.setOnClickListener(this);

        ui_txvRecentOnline = (TextView) findViewById(R.id.txv_recent_online);
        ui_txvRecentOnline.setOnClickListener(this);
        ui_txvRecent1dayAgo = (TextView) findViewById(R.id.txv_oneday_ago);
        ui_txvRecent1dayAgo.setOnClickListener(this);
        ui_txvRecent3daysAgo = (TextView) findViewById(R.id.txv_threedays_ago);
        ui_txvRecent3daysAgo.setOnClickListener(this);
        ui_txvRecent7daysAgo = (TextView) findViewById(R.id.txv_sevendays_ago);
        ui_txvRecent7daysAgo.setOnClickListener(this);

        ui_txvRelationAll = (TextView) findViewById(R.id.txv_relation_all);
        ui_txvRelationAll.setOnClickListener(this);
        ui_txvRelationFriend = (TextView) findViewById(R.id.txv_relation_friend);
        ui_txvRelationFriend.setOnClickListener(this);

        ui_rangeAge = (RangeBar) findViewById(R.id.age_rangebar);
        ui_rangeAge.setOnRangeBarChangeListener(new RangeBar.OnRangeBarChangeListener() {
            @Override
            public void onRangeChangeListener(RangeBar rangeBar, int leftPinIndex, int rightPinIndex, String leftPinValue, String rightPinValue) {

                _ageStart = Integer.valueOf(leftPinValue);
                _ageEnd = Integer.valueOf(rightPinValue);
                ui_txvAge.setText(_ageStart + getString(R.string.age_unit) + "~" + _ageEnd + getString(R.string.age_unit));

            }
        });

        ui_rangeDistance = (RangeBar) findViewById(R.id.distance_rangebar);
        ui_rangeDistance.setOnRangeBarChangeListener(new RangeBar.OnRangeBarChangeListener() {
            @Override
            public void onRangeChangeListener(RangeBar rangeBar, int leftPinIndex, int rightPinIndex, String leftPinValue, String rightPinValue) {

                _distance = Integer.valueOf(rightPinValue);
                ui_txvDistance.setText(_distance + "km");

            }
        });

        TextView txvCancel = (TextView) findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(this);

        TextView txvOk = (TextView) findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(this);

    }

    private void initValues() {

        _distance = Preference.getInstance().getValue(this, PrefConst.PREFKEY_DISTANCE, 10);
        ui_txvDistance.setText(_distance + "km");
        ui_rangeDistance.setRangePinsByValue(1, _distance);

        _ageStart = Preference.getInstance().getValue(this, PrefConst.PREFKEY_AGE_START, 1);
        _ageEnd = Preference.getInstance().getValue(this, PrefConst.PREFKEY_AGE_END, 100);
        ui_txvAge.setText(_ageStart + getString(R.string.age_unit) + "~" + _ageEnd + getString(R.string.age_unit));
        ui_rangeAge.setRangePinsByValue(_ageStart, _ageEnd);

        _sex = Preference.getInstance().getValue(this, PrefConst.PREFKEY_SEX, 2);
        selectSex(_sex);

        _lastLogin = Preference.getInstance().getValue(this, PrefConst.PREFKEY_LASTLOGIN, 7);
        selectRecent(_lastLogin);

        _relation = Preference.getInstance().getValue(this, PrefConst.PREFKEY_RELATION, 0);
        selectRelation(_relation);

    }


    public void selectSex(int index) {

        _sex = index;

        TextView txvSexs[] = {ui_txvSexMan, ui_txvSexWoman, ui_txvSexAll};
        for (TextView textView : txvSexs) {
            textView.setSelected(false);
        }

        txvSexs[index].setSelected(true);


    }

    public void selectRecent(int index) {

        _lastLogin = index;

        if (index == 3) index = 2;
        if (index == 7) index = 3;

        TextView txvRecents[] = {ui_txvRecentOnline, ui_txvRecent1dayAgo, ui_txvRecent3daysAgo, ui_txvRecent7daysAgo};
        for (TextView textView : txvRecents) {
            textView.setSelected(false);
        }

        txvRecents[index].setSelected(true);
    }

    public void selectRelation(int index) {

        _relation = index;

        if (index == 0) {
            ui_txvRelationAll.setSelected(true);
            ui_txvRelationFriend.setSelected(false);
        } else {
            ui_txvRelationAll.setSelected(false);
            ui_txvRelationFriend.setSelected(true);
        }
    }



    private void onSave() {

        Preference.getInstance().put(this, PrefConst.PREFKEY_DISTANCE, _distance);
        Preference.getInstance().put(this, PrefConst.PREFKEY_AGE_START, _ageStart);
        Preference.getInstance().put(this, PrefConst.PREFKEY_AGE_END, _ageEnd);
        Preference.getInstance().put(this, PrefConst.PREFKEY_SEX, _sex);
        Preference.getInstance().put(this, PrefConst.PREFKEY_LASTLOGIN, _lastLogin);
        Preference.getInstance().put(this, PrefConst.PREFKEY_RELATION, _relation);

        finish();

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

            case R.id.txv_ok:
                onSave();
                break;

            case R.id.txv_sex_all:
                selectSex(2);
                break;

            case R.id.txv_sex_man:
                selectSex(0);
                break;

            case R.id.txv_sex_woman:
                selectSex(1);
                break;

            case R.id.txv_recent_online:
                selectRecent(0);
                break;

            case R.id.txv_oneday_ago:
                selectRecent(1);
                break;

            case R.id.txv_threedays_ago:
                selectRecent(3);
                break;

            case R.id.txv_sevendays_ago:
                selectRecent(7);
                break;

            case R.id.txv_relation_all:
                selectRelation(0);
                break;

            case R.id.txv_relation_friend:
                selectRelation(1);
                break;
        }

    }



}
