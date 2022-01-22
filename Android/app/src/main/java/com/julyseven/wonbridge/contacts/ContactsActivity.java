package com.julyseven.wonbridge.contacts;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonTabActivity;
import com.julyseven.wonbridge.message.MsgActivity;
import com.julyseven.wonbridge.mypage.MyPageActivity;
import com.julyseven.wonbridge.timeline.TimelineActivity;

import java.util.ArrayList;
import java.util.List;

public class ContactsActivity extends CommonTabActivity implements View.OnClickListener {

    TabLayout ui_tabLayout;
    ViewPager ui_viewPager;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_contact);

        loadLayout();
    }

    @Override
    public void loadLayout() {

        super.loadLayout();

        ui_lytContact.setBackgroundColor(0xff23262b);
        ui_txvContact.setTextColor(getResources().getColor(R.color.colorWhiteBlue));
        ui_imvContact.setImageResource(R.drawable.button_contacts_on);

        setUnRead();

        ui_viewPager = (ViewPager)findViewById(R.id.viewpager);
        setupViewPager(ui_viewPager);

        ui_tabLayout = (TabLayout)findViewById(R.id.tabs);
        ui_tabLayout.setupWithViewPager(ui_viewPager);

    }

    private void setupViewPager(ViewPager viewPager){

        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());

        adapter.addFrag(new ContactsFriendFragment(), getString(R.string.friend));
        adapter.addFrag(new ContactsGroupFragment(), getString(R.string.group));
        adapter.addFrag(new ContactsPartnerFragment(), getString(R.string.partner));
        viewPager.setAdapter(adapter);
    }



    @Override
    public void onClick(View view) {

        switch (view.getId()){

            case R.id.lyt_timeline:
                gotoTimeline();
                break;
            case R.id.lyt_msg:
                gotoMessage();
                break;
            case R.id.lyt_mypage:
                gotoMyPage();
                break;

            case R.id.lyt_service:
                gotoService();
                break;
        }

    }

    class ViewPagerAdapter extends FragmentPagerAdapter {


        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFrag(Fragment fragment, String title) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {

            // return null to display only the icon
            return mFragmentTitleList.get(position);
        }
    }



}
